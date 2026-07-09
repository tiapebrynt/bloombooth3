const express = require('express');
const router = express.Router();
const decorationController = require('../controllers/decorationController');
const { authMiddleware } = require('../middleware/auth');

router.put('/:id', authMiddleware, decorationController.update);
router.delete('/:id', authMiddleware, decorationController.remove);

module.exports = router;
