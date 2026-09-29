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
  getMembresias,
  getPlanes
} = pagoController;

// Definición de Endpoints
router.get('/', getPagos);
router.get('/resumen', getResumenPagos);
router.get('/membresias', getMembresias);
router.get('/planes', getPlanes);
router.get('/:id', getPagoById);
router.post('/', registrarPago);
router.patch('/:id/estado', actualizarEstadoPago);
router.delete('/:id', eliminarPago);

module.exports = router;