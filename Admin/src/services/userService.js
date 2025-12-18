const supabase = require('../config/supabaseClient');
const createHttpError = require('../utils/httpError');

const getUsers = async ({ limit = 20 } = {}) => {
  // Lấy profiles
  const { data: profiles, error: profilesError } = await supabase
    .from('profiles')
    .select('id, username, full_name, avatar_url, created_at, updated_at')
    .order('created_at', { ascending: false, nullsFirst: false })
    .limit(limit);

  if (profilesError) {
    throw createHttpError(profilesError.message, 400);
  }

  if (!profiles || profiles.length === 0) {
    return [];
  }

  const userIds = profiles.map((p) => p.id);

  // Lấy thông tin từ auth.users thông qua Admin API
  // Với service role key, có thể dùng auth.admin.listUsers()
  let authUsersMap = {};
  try {
    const { data: authUsersData, error: authError } = await supabase.auth.admin.listUsers();
    
    if (!authError && authUsersData && authUsersData.users) {
      authUsersData.users.forEach((user) => {
        if (userIds.includes(user.id)) {
          authUsersMap[user.id] = {
            email: user.email,
            last_sign_in_at: user.last_sign_in_at,
          };
        }
      });
    }
  } catch (err) {
    // Nếu không có quyền admin, bỏ qua và tiếp tục
    console.warn('Không thể lấy thông tin auth.users:', err.message);
  }

  // Lấy role từ bảng admins nếu có
  const { data: admins } = await supabase
    .from('admins')
    .select('user_id, role_id, roles(name)')
    .in('user_id', userIds);

  const adminRolesMap = {};
  if (admins) {
    admins.forEach((admin) => {
      adminRolesMap[admin.user_id] = admin.roles?.name || 'Admin';
    });
  }

  // Combine data
  const result = profiles.map((profile) => {
    const authUser = authUsersMap[profile.id];
    const role = adminRolesMap[profile.id] || 'User';

    return {
      id: profile.id,
      email: authUser?.email || 'N/A',
      username: profile.username || 'N/A',
      full_name: profile.full_name || 'N/A',
      avatar_url: profile.avatar_url,
      role: role,
      status: 'Active', // Default status
      last_sign_in_at: authUser?.last_sign_in_at || null,
      created_at: profile.created_at,
      updated_at: profile.updated_at,
    };
  });

  return result;
};

module.exports = {
  getUsers,
};

