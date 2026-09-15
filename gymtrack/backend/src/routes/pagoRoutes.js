const express = require('express');
const router = express.Router();
const pagoController = require('../controllers/pagoController');

const {
  getPagos,
  getPagoById,
  registrarPago,
  actualizarEstadoPago,
  eliminarPago,
  getResumenPagos,
  getMembresias
} = pagoController;
const { verifyToken } = require('../middlewares/authMiddleware');

// Middleware opcional para poblar req.usuario si viene el header Authorization
const optionalAuth = (req, res, next) => {
  const authHeader = req.headers['authorization'] || req.headers['Authorization'];
  if (authHeader && authHeader.startsWith('Bearer ')) {
    return verifyToken(req, res, next);
  }
  next();
};

router.use(optionalAuth);

// Definición de Endpoints
router.get('/', getPagos);
router.get('/resumen', getResumenPagos);
router.get('/membresias', getMembresias);
router.get('/:id', getPagoById);
router.post('/', registrarPago);
router.patch('/:id/estado', actualizarEstadoPago);
router.delete('/:id', eliminarPago);

module.exports = router;