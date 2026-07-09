const db = require('../config/database');

const UserModel = {
  create({ name, email, password, role = 'user' }) {
    const stmt = db.prepare(
      `INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)`
    );
    const info = stmt.run(name, email, password, role);
    return this.findById(info.lastInsertRowid);
  },

  findById(id) {
    return db.prepare(`SELECT * FROM users WHERE id = ?`).get(id);
  },

  findByEmail(email) {
    return db.prepare(`SELECT * FROM users WHERE email = ?`).get(email);
  },

  update(id, { name, avatar_path }) {
    db.prepare(
      `UPDATE users SET name = COALESCE(?, name), avatar_path = COALESCE(?, avatar_path), updated_at = datetime('now') WHERE id = ?`
    ).run(name, avatar_path, id);
    return this.findById(id);
  },

  toPublicJSON(user) {
    if (!user) return null;
    const { password, ...publicUser } = user;
    return publicUser;
  },
};

module.exports = UserModel;
