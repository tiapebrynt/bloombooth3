const UserModel = require('../models/userModel');

exports.updateProfile = (req, res) => {
  const { name, avatar_path } = req.body;
  const user = UserModel.update(req.user.id, { name, avatar_path });
  res.json({ success: true, message: 'Profil diperbarui', data: UserModel.toPublicJSON(user) });
};

exports.getProfile = (req, res) => {
  const user = UserModel.findById(req.params.id);
  if (!user) return res.status(404).json({ success: false, message: 'User tidak ditemukan' });
  res.json({ success: true, data: UserModel.toPublicJSON(user) });
};
