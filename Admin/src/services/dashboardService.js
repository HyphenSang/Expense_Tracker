const supabase = require('../config/supabaseClient');
const createHttpError = require('../utils/httpError');

/**
 * Tính toán khoảng thời gian cho tháng hiện tại
 */
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

/**
 * Tính toán khoảng thời gian cho tháng hiện tại và tháng trước
 */
const getMonthRanges = () => {
  const now = new Date();
  
  // Tháng hiện tại: từ ngày 1 tháng này đến ngày 1 tháng sau
  const currentMonth = {
    from: new Date(now.getFullYear(), now.getMonth(), 1),
    to: new Date(now.getFullYear(), now.getMonth() + 1, 1),
  };
  
  // Tháng trước: từ ngày 1 tháng trước đến ngày 1 tháng này
  const lastMonth = {
    from: new Date(now.getFullYear(), now.getMonth() - 1, 1),
    to: new Date(now.getFullYear(), now.getMonth(), 1),
  };

  return {
    current: {
      from: currentMonth.from.toISOString(),
      to: currentMonth.to.toISOString(),
    },
    last: {
      from: lastMonth.from.toISOString(),
      to: lastMonth.to.toISOString(),
    },
  };
};

/**
 * Tính % thay đổi giữa 2 giá trị
 */
const calculateTrend = (current, last) => {
  if (last === 0) {
    // Nếu tháng trước = 0, tháng này > 0 → +100%
    return current > 0 ? '+100%' : '0%';
  }
  
  const change = ((current - last) / last) * 100;
  
  if (Math.abs(change) < 0.1) {
    return '0%';  // Thay đổi quá nhỏ, coi như không đổi
  }
  
  // Format: +X.X% hoặc -X.X%
  return change >= 0 
    ? `+${change.toFixed(1)}%` 
    : `${change.toFixed(1)}%`;
};

const getOverview = async () => {
  const { current, last } = getMonthRanges();

  // ========== QUERY THÁNG HIỆN TẠI ==========
  const { data: currentTransactions, error: currentError } = await supabase
    .from('transactions')
    .select('amount, type, occurred_at')
    .gte('occurred_at', current.from)
    .lt('occurred_at', current.to);

  if (currentError) {
    throw createHttpError(currentError.message, 400);
  }

  // ========== QUERY THÁNG TRƯỚC ==========
  const { data: lastTransactions, error: lastError } = await supabase
    .from('transactions')
    .select('amount, type, occurred_at')
    .gte('occurred_at', last.from)
    .lt('occurred_at', last.to);

  if (lastError) {
    throw createHttpError(lastError.message, 400);
  }

  // ========== TÍNH TỔNG CHI TIÊU ==========
  const currentExpenses = (currentTransactions || [])
    .filter((t) => t.type === 'EXPENSE')
    .reduce((sum, t) => sum + Number(t.amount || 0), 0);

  const lastExpenses = (lastTransactions || [])
    .filter((t) => t.type === 'EXPENSE')
    .reduce((sum, t) => sum + Number(t.amount || 0), 0);

  // ========== TÍNH TỔNG SỐ GIAO DỊCH ==========
  const currentTransactionCount = (currentTransactions || []).length;
  const lastTransactionCount = (lastTransactions || []).length;

  // ========== TÍNH TREND ==========
  const expenseTrend = calculateTrend(currentExpenses, lastExpenses);
  const transactionTrend = calculateTrend(currentTransactionCount, lastTransactionCount);

  // ========== ĐẾM USER ==========
  const { count: userCount, error: userError } = await supabase
    .from('profiles')
    .select('*', { count: 'exact', head: true });

  if (userError) {
    throw createHttpError(userError.message, 400);
  }

  // ========== PENDING TRANSACTIONS ==========
  // Schema không có field status, giữ nguyên = 0
  const pendingTransactions = 0;

  return {
    totalExpenses: currentExpenses,
    totalTransactions: currentTransactionCount,
    pendingTransactions,
    activeUsers: userCount || 0,
    // ✅ THÊM TREND VÀO RESPONSE
    expenseTrend,        // "+15.3%" hoặc "-8.2%" hoặc "0%"
    transactionTrend,   // "+5.0%" hoặc "-12.5%" hoặc "0%"
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
