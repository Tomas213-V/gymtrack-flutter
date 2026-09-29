const express = require('express');
const router = express.Router();
const { getDashboardSocio } = require('../controllers/dashboardSocioController');
const { verifyToken } = require('../middlewares/authMiddleware');

// La ruta requiere autenticación obligatoria
router.use(verifyToken);

router.get('/dashboard', getDashboardSocio);

module.exports = router;