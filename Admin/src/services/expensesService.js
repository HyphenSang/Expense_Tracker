const supabase = require('../config/supabaseClient');
const createHttpError = require('../utils/httpError');

const getExpenses = async ({ limit = 25, status } = {}) => {
  // Query từ bảng transactions thay vì expenses
  // Join categories và profiles qua user_id
  let query = supabase
    .from('transactions')
    .select(`
      id,
      user_id,
      wallet_id,
      category_id,
      type,
      amount,
      note,
      occurred_at,
      created_at,
      categories(name)
    `)
    .eq('type', 'EXPENSE') // Chỉ lấy chi tiêu
    .order('occurred_at', { ascending: false })
    .limit(limit);

  // Note: Schema hiện tại không có field 'status', bỏ qua filter status
  // Nếu cần filter status, cần thêm field này vào bảng transactions

  const { data, error } = await query;
  if (error) {
    throw createHttpError(error.message, 400);
  }

  // Lấy thông tin profiles riêng vì không có foreign key trực tiếp
  const userIds = [...new Set((data || []).map((t) => t.user_id))];
  const profilesMap = {};

  if (userIds.length > 0) {
    const { data: profiles } = await supabase
      .from('profiles')
      .select('id, username, full_name')
      .in('id', userIds);

    if (profiles) {
      profiles.forEach((profile) => {
        profilesMap[profile.id] = profile;
      });
    }
  }

  // Transform data để match với format frontend mong đợi
  const transformed = (data || []).map((transaction) => {
    const profile = profilesMap[transaction.user_id];
    return {
      id: transaction.id,
      title: transaction.note || transaction.categories?.name || 'Chi tiêu',
      amount: Number(transaction.amount || 0),
      category: transaction.categories?.name || 'Khác',
      note: transaction.note || '',
      status: 'approved', // Mặc định vì không có status trong schema
      userId: transaction.user_id,
      username: profile?.username || profile?.full_name || 'N/A',
      createdAt: transaction.occurred_at || transaction.created_at,
    };
  });

  return transformed;
};

const createExpense = async (payload) => {
  if (!payload?.title && !payload?.amount) {
    throw createHttpError('title và amount là bắt buộc', 400);
  }

  // Lấy userId từ payload hoặc user đầu tiên
  let userId = payload.userId;
  if (!userId) {
    const { data: firstUser } = await supabase
      .from('profiles')
      .select('id')
      .limit(1)
      .maybeSingle();
    
    if (!firstUser) {
      throw createHttpError('Không tìm thấy user nào. Vui lòng tạo user trước.', 400);
    }
    userId = firstUser.id;
  }

  // Tìm wallet của user
  const { data: userWallet } = await supabase
    .from('wallets')
    .select('id')
    .eq('user_id', userId)
    .eq('is_active', true)
    .limit(1)
    .maybeSingle();

  if (!userWallet) {
    throw createHttpError('User chưa có ví. Vui lòng tạo ví trước.', 400);
  }

  // Tìm category theo tên cho user này
  let categoryId = null;
  if (payload.category) {
    const { data: existingCategory } = await supabase
      .from('categories')
      .select('id')
      .eq('name', payload.category)
      .eq('type', 'EXPENSE')
      .eq('user_id', userId)
      .limit(1)
      .maybeSingle();

    if (existingCategory) {
      categoryId = existingCategory.id;
    } else {
      // Tạo category mới nếu chưa có
      const { data: newCategory, error: catError } = await supabase
        .from('categories')
        .insert({
          user_id: userId,
          name: payload.category,
          type: 'EXPENSE',
        })
        .select('id')
        .single();

      if (catError) {
        throw createHttpError(`Không thể tạo danh mục: ${catError.message}`, 400);
      }
      categoryId = newCategory.id;
    }
  } else {
    // Nếu không có category, tìm category mặc định hoặc tạo "Khác"
    const { data: defaultCategory } = await supabase
      .from('categories')
      .select('id')
      .eq('name', 'Khác')
      .eq('type', 'EXPENSE')
      .eq('user_id', userId)
      .limit(1)
      .maybeSingle();

    if (defaultCategory) {
      categoryId = defaultCategory.id;
    } else {
      // Tạo category "Khác"
      const { data: newCategory } = await supabase
        .from('categories')
        .insert({
          user_id: userId,
          name: 'Khác',
          type: 'EXPENSE',
        })
        .select('id')
        .single();
      categoryId = newCategory.id;
    }
  }

  const newTransaction = {
    user_id: userId,
    wallet_id: userWallet.id,
    category_id: categoryId,
    type: 'EXPENSE',
    amount: payload.amount,
    note: payload.title || payload.note || null,
    occurred_at: payload.createdAt || new Date().toISOString(),
  };

  const { data, error } = await supabase
    .from('transactions')
    .insert(newTransaction)
    .select(`
      id,
      user_id,
      wallet_id,
      category_id,
      type,
      amount,
      note,
      occurred_at,
      created_at,
      categories(name)
    `)
    .single();

  if (error) {
    throw createHttpError(error.message, 400);
  }

  // Lấy thông tin profile riêng
  const { data: profile } = await supabase
    .from('profiles')
    .select('username, full_name')
    .eq('id', data.user_id)
    .maybeSingle();

  // Transform response
  return {
    id: data.id,
    title: data.note || data.categories?.name || 'Chi tiêu',
    amount: Number(data.amount || 0),
    category: data.categories?.name || 'Khác',
    note: data.note || '',
    status: 'approved',
    userId: data.user_id,
    username: profile?.username || profile?.full_name || 'N/A',
    createdAt: data.occurred_at || data.created_at,
  };
};

/**
 * Tạo một loạt bản ghi chi tiêu demo để phục vụ trình diễn dashboard.
 * Không kiểm tra trùng lặp, chỉ nên dùng trong môi trường dev.
 */
const seedDemoExpenses = async () => {
  // Lấy user đầu tiên để tạo demo data
  const { data: firstUser } = await supabase
    .from('profiles')
    .select('id')
    .limit(1)
    .maybeSingle();

  if (!firstUser) {
    throw createHttpError('Không tìm thấy user nào để tạo dữ liệu demo', 400);
  }

  const userId = firstUser.id;

  // Lấy wallet của user
  const { data: userWallet } = await supabase
    .from('wallets')
    .select('id')
    .eq('user_id', userId)
    .eq('is_active', true)
    .limit(1)
    .maybeSingle();

  if (!userWallet) {
    throw createHttpError('User chưa có ví. Vui lòng tạo ví trước.', 400);
  }

  // Lấy hoặc tạo categories
  const categories = ['Ăn uống', 'Tiện ích', 'Thu nhập', 'Mua sắm'];
  const categoryMap = {};

  for (const catName of categories) {
    const isIncome = catName === 'Thu nhập';
    let { data: category } = await supabase
      .from('categories')
      .select('id')
      .eq('name', catName)
      .eq('type', isIncome ? 'INCOME' : 'EXPENSE')
      .eq('user_id', userId)
      .maybeSingle();

    if (!category) {
      // Tạo category nếu chưa có
      const { data: newCategory, error: catError } = await supabase
        .from('categories')
        .insert({
          user_id: userId,
          name: catName,
          type: isIncome ? 'INCOME' : 'EXPENSE',
        })
        .select('id')
        .single();
      
      if (catError) {
        throw createHttpError(`Không thể tạo danh mục "${catName}": ${catError.message}`, 400);
      }
      category = newCategory;
    }
    categoryMap[catName] = category.id;
  }

  const now = new Date();
  const transactions = [
    {
      user_id: userId,
      wallet_id: userWallet.id,
      category_id: categoryMap['Ăn uống'],
      type: 'EXPENSE',
      amount: 45000,
      note: 'Mua cà phê demo',
      occurred_at: new Date(now.getTime() - 60 * 60 * 1000).toISOString(),
    },
    {
      user_id: userId,
      wallet_id: userWallet.id,
      category_id: categoryMap['Tiện ích'],
      type: 'EXPENSE',
      amount: 550000,
      note: 'Thanh toán tiền điện demo',
      occurred_at: new Date(now.getTime() - 24 * 60 * 60 * 1000).toISOString(),
    },
    {
      user_id: userId,
      wallet_id: userWallet.id,
      category_id: categoryMap['Thu nhập'],
      type: 'INCOME',
      amount: 15000000,
      note: 'Nhận lương demo',
      occurred_at: new Date(now.getTime() - 2 * 24 * 60 * 60 * 1000).toISOString(),
    },
    {
      user_id: userId,
      wallet_id: userWallet.id,
      category_id: categoryMap['Mua sắm'],
      type: 'EXPENSE',
      amount: 800000,
      note: 'Mua sắm siêu thị demo',
      occurred_at: new Date(now.getTime() - 3 * 24 * 60 * 60 * 1000).toISOString(),
    },
  ];

  // Tạo transactions trực tiếp
  const { data: createdTransactions, error: insertError } = await supabase
    .from('transactions')
    .insert(transactions)
    .select(`
      id,
      user_id,
      wallet_id,
      category_id,
      type,
      amount,
      note,
      occurred_at,
      created_at,
      categories(name)
    `);

  if (insertError) {
    throw createHttpError(insertError.message, 400);
  }

  // Lấy thông tin profiles
  const userIds = [...new Set((createdTransactions || []).map((t) => t.user_id))];
  const profilesMap = {};

  if (userIds.length > 0) {
    const { data: profiles } = await supabase
      .from('profiles')
      .select('id, username, full_name')
      .in('id', userIds);

    if (profiles) {
      profiles.forEach((profile) => {
        profilesMap[profile.id] = profile;
      });
    }
  }

  // Transform results
  const results = (createdTransactions || []).map((transaction) => {
    const profile = profilesMap[transaction.user_id];
    return {
      id: transaction.id,
      title: transaction.note || transaction.categories?.name || 'Chi tiêu',
      amount: Number(transaction.amount || 0),
      category: transaction.categories?.name || 'Khác',
      note: transaction.note || '',
      status: 'approved',
      userId: transaction.user_id,
      username: profile?.username || profile?.full_name || 'N/A',
      createdAt: transaction.occurred_at || transaction.created_at,
    };
  });

  return results;
};

module.exports = {
  getExpenses,
  createExpense,
  seedDemoExpenses,
};
