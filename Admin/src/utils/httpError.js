/**
 * @param {string} message
 * @param {number} status
 */
const createHttpError = (message, status = 500) => {
  const error = new Error(message);
  error.status = status;
  return error;
};

module.exports = createHttpError;

