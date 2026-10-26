const express = require('express');
const router = express.Router();

// Importamos los controladores de autenticación
const { registerOwner, login, loginSocio, getMe, updateOwnerProfile } = require('../controllers/authController');

// Importamos middleware para proteger rutas que requieran token JWT
const { verifyToken } = require('../middlewares/authMiddleware');

// Ruta POST para el registro de gimnasio y dueño
// Endpoint: POST /api/auth/register
router.post('/register', registerOwner);

// Ruta POST para el inicio de sesión (General / Dueño)
// Endpoint: POST /api/auth/login
router.post('/login', login);

// Ruta POST para el inicio de sesión exclusivo de Socio (Issue #20)
// Endpoint: POST /api/auth/login-socio
router.post('/login-socio', loginSocio);

// Rutas GET y PUT para consultar y actualizar el perfil del usuario autenticado (requiere Bearer token)
// Endpoint: GET /api/auth/me
router.get('/me', verifyToken, getMe);

// Endpoint: PUT /api/auth/me y /api/auth/perfil
router.put('/me', verifyToken, updateOwnerProfile);
router.put('/perfil', verifyToken, updateOwnerProfile);

module.exports = router;