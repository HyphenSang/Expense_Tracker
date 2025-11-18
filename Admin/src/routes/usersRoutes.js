const express = require('express');
const userService = require('../services/userService');

const router = express.Router();

router.get('/', async (req, res, next) => {
  try {
    const { limit } = req.query;
    const data = await userService.getUsers({ limit: Number(limit) || 20 });
    res.json({ success: true, data });
  } catch (error) {
    next(error);
  }
});

module.exports = router;

