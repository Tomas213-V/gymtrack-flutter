// ==============================================================================
// MIDDLEWARE DE AUTENTICACIÓN Y AUTORIZACIÓN (JWT)
// ==============================================================================

const jwt = require('jsonwebtoken');
const supabase = require('../config/supabase');

/**
 * Middleware para verificar la validez del token JWT en peticiones protegidas.
 * Extrae y valida el token enviado en el encabezado Authorization: Bearer <token>
 * Además, si el token carece de id_gimnasio (ej. usuario recién registrado o token previo),
 * resuelve automáticamente el id_gimnasio desde Supabase o query/body para que
 * todos los controladores subsiguientes operen sin error 400.
 */
const verifyToken = async (req, res, next) => {
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

    // 7. Enriquecer id_gimnasio si no está presente en el payload del token
    if (req.usuario && (!req.usuario.id_gimnasio || req.usuario.id_gimnasio === null)) {
      try {
        if (req.usuario.id_usuario) {
          const { data: gym } = await supabase
            .from('gimnasio')
            .select('id_gimnasio')
            .eq('id_usuario', req.usuario.id_usuario)
            .maybeSingle();

          if (gym?.id_gimnasio) {
            req.usuario.id_gimnasio = gym.id_gimnasio;
          }
        }

        // Si todavía no se resolvió, buscar por id_socio
        if (!req.usuario.id_gimnasio && req.usuario.id_socio) {
          const { data: soc } = await supabase
            .from('socio')
            .select('id_gimnasio')
            .eq('id_socio', req.usuario.id_socio)
            .maybeSingle();

          if (soc?.id_gimnasio) {
            req.usuario.id_gimnasio = soc.id_gimnasio;
          }
        }

        // Si se envió en el body o query
        if (!req.usuario.id_gimnasio) {
          const candidateId = req.body?.id_gimnasio || req.query?.id_gimnasio;
          if (candidateId) {
            req.usuario.id_gimnasio = Number(candidateId);
          }
        }

        // Si aún no se resolvió, asignar el primer gimnasio disponible del sistema
        if (!req.usuario.id_gimnasio) {
          const { data: primerGym } = await supabase
            .from('gimnasio')
            .select('id_gimnasio')
            .order('id_gimnasio', { ascending: true })
            .limit(1)
            .maybeSingle();

          if (primerGym?.id_gimnasio) {
            req.usuario.id_gimnasio = primerGym.id_gimnasio;
          }
        }
      } catch (errEnrich) {
        console.warn('Aviso: No se pudo resolver automáticamente el id_gimnasio:', errEnrich.message);
      }
    }

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
