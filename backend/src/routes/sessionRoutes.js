const express = require('express');
const router = express.Router();
const sessionController = require('../controllers/sessionController');
const { authMiddleware } = require('../middleware/auth');

router.get('/', authMiddleware, sessionController.getAll);
router.post('/', authMiddleware, sessionController.create);
router.get('/:id', authMiddleware, sessionController.getOne);
router.put('/:id', authMiddleware, sessionController.update);
router.delete('/:id', authMiddleware, sessionController.remove);

// Nested resources
router.post('/:id/photos', authMiddleware, sessionController.addPhoto);
router.post('/:id/decorations', authMiddleware, sessionController.addDecoration);

module.exports = router;
