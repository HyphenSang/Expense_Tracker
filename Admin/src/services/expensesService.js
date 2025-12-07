const supabase = require('../config/supabaseClient');
const createHttpError = require('../utils/httpError');

const getExpenses = async ({ limit = 25, status } = {}) => {
  let query = supabase
    .from('expenses')
    .select('*')
    .order('created_at', { ascending: false })
    .limit(limit);

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

/**
 * Tạo một loạt bản ghi chi tiêu demo để phục vụ trình diễn dashboard.
 * Không kiểm tra trùng lặp, chỉ nên dùng trong môi trường dev.
 */
const seedDemoExpenses = async () => {
  const now = new Date();

  const payloads = [
    {
      title: 'Mua cà phê demo',
      amount: 45000,
      category: 'Ăn uống',
      status: 'approved',
      note: 'Chi tiêu nhỏ cho demo',
      createdAt: new Date(now.getTime() - 60 * 60 * 1000).toISOString(),
    },
    {
      title: 'Thanh toán tiền điện demo',
      amount: 550000,
      category: 'Tiện ích',
      status: 'approved',
      note: 'Hoá đơn tháng này',
      createdAt: new Date(now.getTime() - 24 * 60 * 60 * 1000).toISOString(),
    },
    {
      title: 'Nhận lương demo',
      amount: 15000000,
      category: 'Thu nhập',
      status: 'approved',
      note: 'Lương tháng',
      createdAt: new Date(now.getTime() - 2 * 24 * 60 * 60 * 1000).toISOString(),
    },
    {
      title: 'Mua sắm siêu thị demo',
      amount: 800000,
      category: 'Mua sắm',
      status: 'pending',
      note: 'Đơn hàng cuối tuần',
      createdAt: new Date(now.getTime() - 3 * 24 * 60 * 60 * 1000).toISOString(),
    },
  ];

  const results = [];

  // Dùng createExpense để đảm bảo cùng nghiệp vụ validate
  // eslint-disable-next-line no-restricted-syntax
  for (const p of payloads) {
    // eslint-disable-next-line no-await-in-loop
    const created = await createExpense(p);
    results.push(created);
  }

  return results;
};

module.exports = {
  getExpenses,
  createExpense,
  seedDemoExpenses,
};

