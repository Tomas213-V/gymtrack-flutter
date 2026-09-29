const express = require('express');
const router = express.Router();
const {
  createAsistencia,
  getAsistencias,
  getAsistenciasBySocio,
  checkoutAsistencia,
  registrarAsistencia,
  getEstadisticas,
  getAsistenciasPorSocio,
  eliminarAsistencia
} = require('../controllers/asistenciaController');
const { verifyToken } = require('../middlewares/authMiddleware');

const optionalAuth = (req, res, next) => {
  const authHeader = req.headers['authorization'] || req.headers['Authorization'];
  if (authHeader && authHeader.startsWith('Bearer ')) {
    return verifyToken(req, res, next);
  }
  next();
};

router.get('/', optionalAuth, getAsistencias);
router.post('/', optionalAuth, registrarAsistencia);
router.get('/estadisticas', optionalAuth, getEstadisticas);
router.get('/socio/:id_socio', optionalAuth, getAsistenciasPorSocio);
router.delete('/:id', optionalAuth, eliminarAsistencia);
router.patch('/:id/checkout', optionalAuth, checkoutAsistencia);

module.exports = router;
