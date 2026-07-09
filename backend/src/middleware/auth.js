const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'photobooth_secret_key_change_me';

function authMiddleware(req, res, next) {
  const header = req.headers['authorization'];
  const token = header && header.startsWith('Bearer ') ? header.slice(7) : null;

  if (!token) {
    return res.status(401).json({ success: false, message: 'Token tidak ditemukan' });
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded; // { id, email, role }
    next();
  } catch (err) {
    return res.status(401).json({ success: false, message: 'Token tidak valid atau kadaluarsa' });
  }
}

module.exports = { authMiddleware, JWT_SECRET };
