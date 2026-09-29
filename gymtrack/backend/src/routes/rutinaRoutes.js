// backend/src/routes/rutinaRoutes.js
const express = require('express');
const router = express.Router();
const rutinaController = require('../controllers/rutinaController');
const { validateRutina, validateEjercicioAsociacion } = require('../middlewares/rutinaValidator');

// Endpoints de Rutinas
router.get('/', rutinaController.getAllRutinas);
router.get('/:id', rutinaController.getRutinaById);
router.post('/', validateRutina, rutinaController.createRutina);
router.put('/:id', validateRutina, rutinaController.updateRutina);
router.delete('/:id', rutinaController.deleteRutina);

// Endpoints de relación con Ejercicios
router.get('/:id/ejercicios', rutinaController.getEjerciciosByRutina);
router.post('/:id/ejercicios', validateEjercicioAsociacion, rutinaController.addEjercicioToRutina);
router.put('/:id/ejercicios/:ejercicioId', rutinaController.updateEjercicioEnRutina);
router.delete('/:id/ejercicios/:ejercicioId', rutinaController.removeEjercicioFromRutina);

module.exports = router;