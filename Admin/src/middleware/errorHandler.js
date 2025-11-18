const errorHandler = (err, _req, res, _next) => {
  const status = err.status || 500;
  const message = err.message || 'Có lỗi xảy ra, vui lòng thử lại sau.';

  if (process.env.NODE_ENV !== 'production') {
    console.error('[Admin API]', err);
  }

  res.status(status).json({
    success: false,
    message,
  });
};

module.exports = errorHandler;

