const createHttpError = require('../utils/httpError');

/**
 * Middleware kiểm tra role của user
 * @param {string[]} allowedRoles - Danh sách role được phép (ví dụ: ['Super_Admin', 'Admin'])
 */
const checkRole = (allowedRoles) => {
  if (!Array.isArray(allowedRoles) || allowedRoles.length === 0) {
    throw new Error('allowedRoles phải là một mảng không rỗng');
  }

  return async (req, res, next) => {
    try {
      // req.userRole đã được set từ authenticateAdmin middleware
      if (!req.userRole) {
        return res.status(401).json({
          success: false,
          message: 'Chưa xác thực. Vui lòng đăng nhập trước.',
        });
      }

      // Kiểm tra role có trong danh sách được phép không
      if (!allowedRoles.includes(req.userRole)) {
        return res.status(403).json({
          success: false,
          message: `Chỉ ${allowedRoles.join(', ')} mới có quyền thực hiện hành động này. Role hiện tại của bạn: ${req.userRole}`,
        });
      }

      next();
    } catch (error) {
      console.error('Role middleware error:', error);
      next(createHttpError(error.message || 'Lỗi kiểm tra quyền', 500));
    }
  };
};

module.exports = checkRole;

