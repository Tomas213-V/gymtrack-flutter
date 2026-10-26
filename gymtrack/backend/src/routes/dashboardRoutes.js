const express = require('express');
const router = express.Router();
const { getDashboardAdmin } = require('../controllers/dashboardController');
const { verifyToken } = require('../middlewares/authMiddleware');

// Endpoint de dashboard para Dueño / Administrador
router.get('/admin', verifyToken, getDashboardAdmin);

module.exports = router;
