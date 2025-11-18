const supabase = require('../config/supabaseClient');
const createHttpError = require('../utils/httpError');

const getExpenses = async ({ limit = 25, status } = {}) => {
  let query = supabase.from('expenses').select('*').order('created_at', { ascending: false }).limit(limit);

  if (status) {
    query = query.eq('status', status);
  }

  const { data, error } = await query;
  if (error) {
    throw createHttpError(error.message, 400);
  }

  return data || [];
};

const createExpense = async (payload) => {
  if (!payload?.title || !payload?.amount) {
    throw createHttpError('title và amount là bắt buộc', 400);
  }

  const newExpense = {
    title: payload.title,
    amount: payload.amount,
    category: payload.category || 'Khác',
    status: payload.status || 'approved',
    note: payload.note || null,
    user_id: payload.userId || null,
    created_at: payload.createdAt || new Date().toISOString(),
  };

  const { data, error } = await supabase.from('expenses').insert(newExpense).select().single();

  if (error) {
    throw createHttpError(error.message, 400);
  }

  return data;
};

module.exports = {
  getExpenses,
  createExpense,
};

