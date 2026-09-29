const express = require('express');
const router = express.Router();
const {
  getEjercicios,
  getEjercicioById,
  crearEjercicio,
  actualizarEjercicio,
  eliminarEjercicio
} = require('../controllers/ejercicioController');

router.get('/', getEjercicios);
router.get('/:id', getEjercicioById);
router.post('/', crearEjercicio);
router.put('/:id', actualizarEjercicio);
router.delete('/:id', eliminarEjercicio);

module.exports = router;