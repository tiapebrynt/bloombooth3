const express = require('express');
const router = express.Router();
const photoController = require('../controllers/photoController');
const { authMiddleware } = require('../middleware/auth');

router.put('/:id', authMiddleware, photoController.update);
router.delete('/:id', authMiddleware, photoController.remove);

module.exports = router;
