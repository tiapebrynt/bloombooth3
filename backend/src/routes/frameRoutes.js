const express = require('express');
const router = express.Router();
const frameController = require('../controllers/frameController');
const { authMiddleware } = require('../middleware/auth');

router.get('/', authMiddleware, frameController.getAll);
router.get('/:id', authMiddleware, frameController.getOne);
router.post('/', authMiddleware, frameController.create);
router.put('/:id', authMiddleware, frameController.update);
router.delete('/:id', authMiddleware, frameController.remove);

module.exports = router;
