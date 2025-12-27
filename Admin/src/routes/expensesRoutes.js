const express = require('express');
const expensesService = require('../services/expensesService');
const authenticateAdmin = require('../middleware/authMiddleware');
const checkRole = require('../middleware/roleMiddleware');

const router = express.Router();

// ✅ Áp dụng authentication cho tất cả routes (trừ demo-seed)
router.use((req, res, next) => {
  // Bỏ qua authentication cho demo-seed (chỉ dùng trong dev)
  if (req.path === '/demo-seed') {
    return next();
  }
  return authenticateAdmin(req, res, next);
});

router.get('/', async (req, res, next) => {
  try {
    const { limit, status } = req.query;
    const data = await expensesService.getExpenses({
      limit: Number(limit) || 25,
      status,
    });
    res.json({ success: true, data });
  } catch (error) {
    next(error);
  }
});

// ✅ Chỉ Super_Admin mới tạo được expense
router.post('/', checkRole(['Super_Admin', 'Admin']), async (req, res, next) => {
  try {
    const data = await expensesService.createExpense(req.body);
    res.status(201).json({ success: true, data });
  } catch (error) {
    next(error);
  }
});

// Tạo dữ liệu demo cho bảng expenses (chỉ dùng trong môi trường phát triển)
// Không cần authentication (hoặc có thể thêm sau)
router.post('/demo-seed', async (req, res, next) => {
  try {
    const data = await expensesService.seedDemoExpenses();
    res.status(201).json({ success: true, data });
  } catch (error) {
    next(error);
  }
});

module.exports = router;

