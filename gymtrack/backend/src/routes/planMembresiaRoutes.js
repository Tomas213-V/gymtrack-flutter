const express = require('express');
const router = express.Router();
const {
  getPlanesMembresia,
  getPlanMembresiaById,
  createPlanMembresia,
  updatePlanMembresia,
  deshabilitarPlanMembresia
} = require('../controllers/planMembresiaController');
const { verifyToken } = require('../middlewares/authMiddleware');

// Todas las rutas requieren autenticación
router.use(verifyToken);

router.get('/', getPlanesMembresia);
router.get('/:id', getPlanMembresiaById);
router.post('/', createPlanMembresia);
router.put('/:id', updatePlanMembresia);
router.patch('/:id/desactivar', deshabilitarPlanMembresia);

module.exports = router;