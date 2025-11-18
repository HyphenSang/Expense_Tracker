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

const normalizeCategory = (expense) => {
  if (!expense) return 'Khác';
  return (
    expense.category ||
    expense.category_name ||
    expense.categoryId ||
    expense.category_id ||
    'Khác'
  );
};

const getOverview = async () => {
  const { from, to } = getMonthRange();

  const expenseQuery = supabase
    .from('expenses')
    .select('amount,status,category,category_name,created_at')
    .gte('created_at', from)
    .lt('created_at', to);

  const { data: expenses, error: expenseError } = await expenseQuery;
  if (expenseError) {
    throw createHttpError(expenseError.message, 400);
  }

  const expenseRows = expenses || [];
  const totalExpenses = expenseRows.reduce((sum, item) => sum + (item.amount || 0), 0);
  const pendingTransactions = expenseRows.filter((item) => item.status === 'pending').length;

  const { count: userCount, error: userError } = await supabase
    .from('users')
    .select('*', { count: 'exact', head: true });

  if (userError) {
    throw createHttpError(userError.message, 400);
  }

  return {
    totalExpenses,
    totalTransactions: expenseRows.length,
    pendingTransactions,
    activeUsers: userCount || 0,
  };
};

const getCategoryBreakdown = async () => {
  const { from, to } = getMonthRange();
  const { data, error } = await supabase
    .from('expenses')
    .select('amount,category,category_name,category_id')
    .gte('created_at', from)
    .lt('created_at', to);

  if (error) {
    throw createHttpError(error.message, 400);
  }

  const rows = data || [];

  const breakdown = rows.reduce((acc, expense) => {
    const key = normalizeCategory(expense);
    acc[key] = (acc[key] || 0) + (expense.amount || 0);
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

