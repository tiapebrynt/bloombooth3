const express = require('express');
const router = express.Router();
const filterController = require('../controllers/filterController');
const { authMiddleware } = require('../middleware/auth');

router.get('/', authMiddleware, filterController.getAll);
router.get('/:id', authMiddleware, filterController.getOne);
router.post('/', authMiddleware, filterController.create);
router.put('/:id', authMiddleware, filterController.update);
router.delete('/:id', authMiddleware, filterController.remove);

module.exports = router;
