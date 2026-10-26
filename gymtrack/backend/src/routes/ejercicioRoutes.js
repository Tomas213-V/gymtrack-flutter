const express = require('express');
const router = express.Router();
const {
  getEjercicios,
  getEjerciciosDisponiblesSocio,
  getEjercicioById,
  crearEjercicio,
  crearEjercicioPersonalizado,
  actualizarEjercicio,
  eliminarEjercicio
} = require('../controllers/ejercicioController');

// 1. Consultar ejercicios disponibles para un socio (Gimnasio + Personalizados)
router.get('/disponibles', getEjerciciosDisponiblesSocio);

// 2. Registrar ejercicio personalizado del socio
router.post('/personalizado', crearEjercicioPersonalizado);

// 3. Endpoints estándar de catálogo
router.get('/', getEjercicios);
router.get('/:id', getEjercicioById);
router.post('/', crearEjercicio);
router.put('/:id', actualizarEjercicio);
router.delete('/:id', eliminarEjercicio);

module.exports = router;