const express = require('express');
const router = express.Router();
const settingsController = require('../controllers/settingsController');
const { authMiddleware } = require('../middleware/auth');

router.get('/', authMiddleware, settingsController.get);
router.put('/', authMiddleware, settingsController.update);

module.exports = router;
