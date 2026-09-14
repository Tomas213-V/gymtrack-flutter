const express = require('express');
const router = express.Router();

// Importamos los controladores de autenticación
const { registerOwner, login, getMe } = require('../controllers/authController');

// Importamos middleware para proteger rutas que requieran token JWT
const { verifyToken } = require('../middlewares/authMiddleware');

// Ruta POST para el registro de gimnasio y dueño
// Endpoint: POST /api/auth/register
router.post('/register', registerOwner);

// Ruta POST para el inicio de sesión
// Endpoint: POST /api/auth/login
router.post('/login', login);

// Ruta GET para obtener los datos del usuario autenticado (requiere Bearer token)
// Endpoint: GET /api/auth/me
router.get('/me', verifyToken, getMe);

module.exports = router;