const express = require('express');
const router = express.Router();
const { 
  getSocios, 
  getSociosEstadisticas,
  getSocioById, 
  createSocio, 
  updateSocio, 
  changeEstadoSocio 
} = require('../controllers/socioController');
const { verifyToken } = require('../middlewares/authMiddleware');

// Proteger todas las rutas exigiendo JWT
router.use(verifyToken);

// Endpoints definidos
router.get('/', getSocios);
router.get('/estadisticas', getSociosEstadisticas);
router.get('/:id', getSocioById);
router.post('/', createSocio);
router.put('/:id', updateSocio);
router.patch('/:id/estado', changeEstadoSocio);

module.exports = router;