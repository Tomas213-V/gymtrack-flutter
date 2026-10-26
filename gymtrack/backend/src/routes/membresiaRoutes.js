const express = require('express');
const router = express.Router();
const {
  getMembresias,
  getMembresiaById,
  createMembresia,
  updateMembresia,
  deleteMembresia
} = require('../controllers/membresiaController');
const { verifyToken } = require('../middlewares/authMiddleware');

router.use(verifyToken);

// CORRECTO: Usar '/' porque el prefijo '/api/membresias' se define en server.js
router.get('/', getMembresias);
router.get('/:id', getMembresiaById);
router.post('/', createMembresia);
router.patch('/:id', updateMembresia);
router.delete('/:id', deleteMembresia);

module.exports = router;