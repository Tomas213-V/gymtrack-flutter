const express = require('express');
const router = express.Router();
const { 
  getSocios, 
  getPerfilSocio,
  updatePerfilSocio,
  getSocioById, 
  createSocio, 
  updateSocio, 
  changeEstadoSocio,
  deleteSocio
} = require('../controllers/socioController');
const { verifyToken } = require('../middlewares/authMiddleware');

// Proteger todas las rutas exigiendo JWT
router.use(verifyToken);

// Rutas de Perfil (declaradas antes de /:id para evitar capturas accidentales)
router.get('/perfil', getPerfilSocio);
router.put('/perfil', updatePerfilSocio);

// Endpoints CRUD
router.get('/', getSocios);
router.get('/:id', getSocioById);
router.post('/', createSocio);
router.put('/:id', updateSocio);
router.patch('/:id/estado', changeEstadoSocio);
router.delete('/:id', deleteSocio);

module.exports = router;