const validateBody = (schema) => (req, res, next) => {
  try {
    req.body = schema.parse(req.body);
    return next();
  } catch (error) {
    const issues = error.issues || [];
    return res.status(400).json({
      error: 'Validation error',
      details: issues.map((issue) => ({
        path: issue.path.join('.'),
        message: issue.message,
      })),
    });
  }
};

module.exports = {
  validateBody,
};
