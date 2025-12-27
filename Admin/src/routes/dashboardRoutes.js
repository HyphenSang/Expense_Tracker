const express = require('express');
const dashboardService = require('../services/dashboardService');
// const authenticateAdmin = require('../middleware/authMiddleware');

const router = express.Router();

// ✅ Tạm thời bỏ authentication để test - gọi trực tiếp từ Supabase
// router.use(authenticateAdmin);

router.get('/overview', async (_req, res, next) => {
  try {
    const data = await dashboardService.getOverview();
    res.json({ success: true, data });
  } catch (error) {
    next(error);
  }
});

router.get('/category-breakdown', async (_req, res, next) => {
  try {
    const data = await dashboardService.getCategoryBreakdown();
    res.json({ success: true, data });
  } catch (error) {
    next(error);
  }
});

module.exports = router;

