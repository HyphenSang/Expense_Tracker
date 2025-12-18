const express = require('express');
const expensesService = require('../services/expensesService');

const router = express.Router();

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

router.post('/', async (req, res, next) => {
  try {
    const data = await expensesService.createExpense(req.body);
    res.status(201).json({ success: true, data });
  } catch (error) {
    next(error);
  }
});

// Tạo dữ liệu demo cho bảng expenses (chỉ dùng trong môi trường phát triển)
router.post('/demo-seed', async (req, res, next) => {
  try {
    const data = await expensesService.seedDemoExpenses();
    res.status(201).json({ success: true, data });
  } catch (error) {
    next(error);
  }
});

module.exports = router;

