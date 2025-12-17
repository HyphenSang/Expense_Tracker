const supabase = require('../config/supabaseClient');
const createHttpError = require('../utils/httpError');

const getMonthRange = () => {
  const from = new Date();
  from.setUTCDate(1);
  from.setUTCHours(0, 0, 0, 0);

  const to = new Date(from);
  to.setUTCMonth(to.getUTCMonth() + 1);

  return {
    from: from.toISOString(),
    to: to.toISOString(),
  };
};

const getOverview = async () => {
  const { from, to } = getMonthRange();

  // Query từ bảng transactions (thay vì expenses)
  const transactionQuery = supabase
    .from('transactions')
    .select('amount, type, occurred_at')
    .gte('occurred_at', from)
    .lt('occurred_at', to);

  const { data: transactions, error: transactionError } = await transactionQuery;
  if (transactionError) {
    throw createHttpError(transactionError.message, 400);
  }

  const transactionRows = transactions || [];
  
  // Tính tổng chi tiêu (chỉ tính EXPENSE)
  const totalExpenses = transactionRows
    .filter((item) => item.type === 'EXPENSE')
    .reduce((sum, item) => sum + Number(item.amount || 0), 0);
  
  // Tổng số giao dịch
  const totalTransactions = transactionRows.length;
  
  // Giao dịch chờ duyệt - không có trong schema hiện tại, trả về 0
  const pendingTransactions = 0;

  // Đếm số người dùng từ profiles
  const { count: userCount, error: userError } = await supabase
    .from('profiles')
    .select('*', { count: 'exact', head: true });

  if (userError) {
    throw createHttpError(userError.message, 400);
  }

  return {
    totalExpenses,
    totalTransactions,
    pendingTransactions,
    activeUsers: userCount || 0,
  };
};

const getCategoryBreakdown = async () => {
  const { from, to } = getMonthRange();
  
  // Query transactions kèm category name
  const { data, error } = await supabase
    .from('transactions')
    .select(`
      amount,
      type,
      category_id,
      categories!inner(name)
    `)
    .eq('type', 'EXPENSE')
    .gte('occurred_at', from)
    .lt('occurred_at', to);

  if (error) {
    throw createHttpError(error.message, 400);
  }

  const rows = data || [];

  // Nhóm theo category name
  const breakdown = rows.reduce((acc, transaction) => {
    const categoryName = transaction.categories?.name || 'Khác';
    acc[categoryName] = (acc[categoryName] || 0) + Number(transaction.amount || 0);
    return acc;
  }, {});

  return Object.entries(breakdown).map(([category, amount]) => ({
    category,
    amount,
  }));
};

module.exports = {
  getOverview,
  getCategoryBreakdown,
};
