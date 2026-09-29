const express = require('express');
const router = express.Router();
const { crearGimnasio, obtenerMiGimnasio, actualizarMiGimnasio } = require('../controllers/gimnasioController');
const { verifyToken } = require('../middlewares/authMiddleware');

// Rutas para gestión del gimnasio
router.post('/', verifyToken, crearGimnasio);
router.get('/mi-gimnasio', verifyToken, obtenerMiGimnasio);
router.put('/mi-gimnasio', verifyToken, actualizarMiGimnasio);

module.exports = router;

