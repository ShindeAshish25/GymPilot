// Global Error Handler Middleware
const errorHandler = (err, req, res, next) => {
  if (!err) {
    return next();
  }

  console.error('Error Status:', res.statusCode);
  console.error('Error Message:', err.message);
  console.error('Error Stack:', err.stack);

  const statusCode = res.statusCode === 200 ? 500 : res.statusCode;

  res.status(statusCode).json({
    message: err.message || 'Internal Server Error',
    // Only show stack trace in development
    stack: process.env.NODE_ENV === 'production' ? null : err.stack,
  });
};

module.exports = { errorHandler };
