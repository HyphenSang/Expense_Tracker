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

module.exports = router;

