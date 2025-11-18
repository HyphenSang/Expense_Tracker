require('dotenv').config();

const express = require('express');
const cors = require('cors');

const dashboardRoutes = require('./routes/dashboardRoutes');
const expensesRoutes = require('./routes/expensesRoutes');
const usersRoutes = require('./routes/usersRoutes');
const errorHandler = require('./middleware/errorHandler');

const app = express();

const allowedOrigins = process.env.ADMIN_DASHBOARD_ORIGINS
  ? process.env.ADMIN_DASHBOARD_ORIGINS.split(',').map((origin) => origin.trim())
  : ['*'];

app.use(
  cors({
    origin: allowedOrigins,
    credentials: true,
  }),
);
app.use(express.json({ limit: '1mb' }));

app.get('/api/health', (_, res) => {
  res.json({ success: true, message: 'Admin API is healthy' });
});

app.use('/api/dashboard', dashboardRoutes);
app.use('/api/expenses', expensesRoutes);
app.use('/api/users', usersRoutes);

app.use(errorHandler);

const PORT = process.env.PORT || 4000;

app.listen(PORT, () => {
  console.log(`Admin API server listening on http://localhost:${PORT}`);
});

