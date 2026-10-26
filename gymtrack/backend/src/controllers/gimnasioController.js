const supabase = require('../config/supabase');

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

    return res.status(201).json({
      mensaje: 'Gimnasio registrado exitosamente.',
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

/**
 * CONTROLADOR: ACTUALIZAR EL GIMNASIO DEL USUARIO AUTENTICADO
 */
const actualizarMiGimnasio = async (req, res) => {
  try {
    const id_usuario = req.usuario?.id_usuario;
    const id_gimnasio = req.usuario?.id_gimnasio;

    if (!id_usuario && !id_gimnasio) {
      return res.status(401).json({ error: 'No se pudo identificar al usuario autenticado.' });
    }

    // Buscar el gimnasio actual
    let query = supabase.from('gimnasio').select('*');
    if (id_usuario) {
      query = query.eq('id_usuario', id_usuario);
    } else {
      query = query.eq('id_gimnasio', id_gimnasio);
    }

    const { data: gymExistente, error: errFetch } = await query.maybeSingle();

    if (errFetch || !gymExistente) {
      return res.status(404).json({ error: 'Gimnasio no encontrado o no pertenece a tu cuenta.' });
    }

    const { nombre, direccion, telefono, email } = req.body;

    const updateFields = {};
    if (nombre !== undefined) {
      if (!nombre.trim()) {
        return res.status(400).json({ error: 'El nombre del gimnasio no puede estar vacío.' });
      }
      updateFields.nombre = nombre.trim();
    }
    if (direccion !== undefined) updateFields.direccion = direccion ? direccion.trim() : null;
    if (telefono !== undefined) updateFields.telefono = telefono ? telefono.trim() : null;
    if (email !== undefined) updateFields.email = email ? email.trim().toLowerCase() : null;

    if (Object.keys(updateFields).length === 0) {
      return res.status(400).json({ error: 'No se enviaron datos para actualizar.' });
    }

    const { data: gymActualizado, error: errUpdate } = await supabase
      .from('gimnasio')
      .update(updateFields)
      .eq('id_gimnasio', gymExistente.id_gimnasio)
      .select()
      .single();

    if (errUpdate) {
      return res.status(500).json({ error: 'Error al actualizar el gimnasio: ' + errUpdate.message });
    }

    return res.status(200).json({
      mensaje: 'Datos del gimnasio actualizados exitosamente.',
      gimnasio: gymActualizado
    });
  } catch (error) {
    return res.status(500).json({ error: 'Error interno del servidor: ' + error.message });
  }
};

module.exports = {
  crearGimnasio,
  obtenerMiGimnasio,
  actualizarMiGimnasio
};
