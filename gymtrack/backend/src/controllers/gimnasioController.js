const supabase = require('../config/supabase');
const jwt = require('jsonwebtoken');

/**
 * CONTROLADOR: CREAR GIMNASIO PARA UN USUARIO AUTENTICADO
 * Asocia el nuevo gimnasio con el id_usuario
 */
const crearGimnasio = async (req, res) => {
  try {
    const { nombre, direccion, telefono, email } = req.body;
    // Extraer id_usuario del token JWT o del body
    const id_usuario = req.usuario?.id_usuario || req.body.id_usuario;

    if (!id_usuario) {
      return res.status(401).json({ error: 'No se pudo identificar al usuario autenticado.' });
    }

    if (!nombre || !nombre.trim()) {
      return res.status(400).json({ error: 'El nombre del gimnasio es obligatorio.' });
    }

    // Comprobar si el usuario ya tiene un gimnasio registrado
    const { data: gymExistente } = await supabase
      .from('gimnasio')
      .select('id_gimnasio, nombre')
      .eq('id_usuario', id_usuario)
      .maybeSingle();

    if (gymExistente) {
      return res.status(400).json({
        error: 'El usuario ya tiene un gimnasio registrado.',
        gimnasio: gymExistente
      });
    }

    // Insertar el nuevo gimnasio en Supabase
    const { data: nuevoGimnasio, error: errGym } = await supabase
      .from('gimnasio')
      .insert([
        {
          nombre: nombre.trim(),
          direccion: direccion ? direccion.trim() : null,
          telefono: telefono ? telefono.trim() : null,
          email: email ? email.trim().toLowerCase() : null,
          fecha_registro: new Date().toISOString().split('T')[0],
          estado: 'activo',
          id_usuario: id_usuario
        }
      ])
      .select()
      .single();

    if (errGym) {
      return res.status(500).json({ error: 'Error al registrar el gimnasio: ' + errGym.message });
    }

    // Generar token actualizado con el nuevo id_gimnasio
    const jwtSecret = process.env.JWT_SECRET || 'gymtrack_jwt_secret_key_2026';
    const expiresIn = process.env.JWT_EXPIRES_IN || '24h';
    const token = jwt.sign(
      {
        id_usuario: id_usuario,
        id_gimnasio: nuevoGimnasio.id_gimnasio,
        email: req.usuario?.email,
        rol: req.usuario?.rol || 'dueño'
      },
      jwtSecret,
      { expiresIn }
    );

    return res.status(201).json({
      mensaje: 'Gimnasio registrado exitosamente.',
      token,
      gimnasio: nuevoGimnasio
    });
  } catch (error) {
    return res.status(500).json({ error: 'Error interno del servidor: ' + error.message });
  }
};

/**
 * CONTROLADOR: OBTENER EL GIMNASIO DEL USUARIO AUTENTICADO
 */
const obtenerMiGimnasio = async (req, res) => {
  try {
    const id_usuario = req.usuario?.id_usuario || req.query.id_usuario;

    if (!id_usuario) {
      return res.status(401).json({ error: 'No se pudo identificar al usuario autenticado.' });
    }

    const { data: gimnasio, error } = await supabase
      .from('gimnasio')
      .select('*')
      .eq('id_usuario', id_usuario)
      .maybeSingle();

    if (error) {
      return res.status(500).json({ error: 'Error al consultar el gimnasio: ' + error.message });
    }

    return res.status(200).json({
      tieneGimnasio: !!gimnasio,
      gimnasio: gimnasio || null
    });
  } catch (error) {
    return res.status(500).json({ error: 'Error interno del servidor: ' + error.message });
  }
};

module.exports = {
  crearGimnasio,
  obtenerMiGimnasio
};
