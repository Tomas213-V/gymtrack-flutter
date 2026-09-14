// ==============================================================================
// MIDDLEWARE DE AUTENTICACIÓN Y AUTORIZACIÓN (JWT)
// ==============================================================================

const jwt = require('jsonwebtoken');

/**
 * Middleware para verificar la validez del token JWT en peticiones protegidas.
 * Extrae y valida el token enviado en el encabezado Authorization: Bearer <token>
 */
const verifyToken = (req, res, next) => {
  try {
    // 1. Obtener el header Authorization
    const authHeader = req.headers['authorization'] || req.headers['Authorization'];

    // 2. Validar que el header exista y tenga el prefijo Bearer
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        error: 'Acceso denegado. No se proporcionó un token de autenticación válido (Bearer token).'
      });
    }

    // 3. Extraer el token de la cadena "Bearer <token>"
    const token = authHeader.split(' ')[1];

    if (!token) {
      return res.status(401).json({
        error: 'Token no encontrado en la cabecera de autorización.'
      });
    }

    // 4. Clave secreta para verificar la firma del JWT
    const secret = process.env.JWT_SECRET || 'gymtrack_jwt_secret_key_2026';

    // 5. Verificar y decodificar el payload del token
    const decoded = jwt.verify(token, secret);

    // 6. Inyectar los datos del usuario en la solicitud para uso en controladores
    req.usuario = decoded;
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        error: 'La sesión ha expirado. Por favor, inicia sesión nuevamente.'
      });
    }
    return res.status(401).json({
      error: 'Token inválido o corrupto.'
    });
  }
};

/**
 * Middleware para validar si el usuario tiene uno de los roles permitidos.
 * Ejemplo de uso: router.get('/admin-dashboard', verifyToken, requireRoles('dueño', 'administrador'), ...)
 */
const requireRoles = (...rolesPermitidos) => {
  return (req, res, next) => {
    if (!req.usuario || !rolesPermitidos.includes(req.usuario.rol)) {
      return res.status(403).json({
        error: 'No tienes los permisos necesarios para realizar esta acción.'
      });
    }
    next();
  };
};

module.exports = {
  verifyToken,
  requireRoles
};
