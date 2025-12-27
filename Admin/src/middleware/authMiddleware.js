const supabase = require('../config/supabaseClient');
const createHttpError = require('../utils/httpError');

/**
 * Middleware xác thực admin
 * Kiểm tra token từ header và verify user có trong bảng admins
 */
const authenticateAdmin = async (req, res, next) => {
  try {
    // 1. Lấy token từ header Authorization
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'Chưa đăng nhập. Vui lòng cung cấp token trong header Authorization: Bearer <token>',
      });
    }

    const token = authHeader.replace('Bearer ', '').trim();

    // 2. Verify token với Supabase
    const { data: { user }, error: authError } = await supabase.auth.getUser(token);

    if (authError || !user) {
      return res.status(401).json({
        success: false,
        message: 'Token không hợp lệ hoặc đã hết hạn',
      });
    }

    // 3. Kiểm tra user có trong bảng admins không
    const { data: admin, error: adminError } = await supabase
      .from('admins')
      .select(`
        user_id,
        role_id,
        roles!inner(
          id,
          name
        )
      `)
      .eq('user_id', user.id)
      .maybeSingle();

    if (adminError) {
      console.error('Error checking admin:', adminError);
      return res.status(500).json({
        success: false,
        message: 'Lỗi khi kiểm tra quyền admin',
      });
    }

    if (!admin) {
      return res.status(403).json({
        success: false,
        message: 'Bạn không có quyền truy cập trang quản trị',
      });
    }

    // 4. Lưu thông tin user và role vào request để dùng sau
    req.user = user;
    req.userId = user.id;
    req.userRole = admin.roles.name;
    req.userRoleId = admin.role_id;

    next();
  } catch (error) {
    console.error('Authentication middleware error:', error);
    next(createHttpError(error.message || 'Lỗi xác thực', 500));
  }
};

module.exports = authenticateAdmin;

