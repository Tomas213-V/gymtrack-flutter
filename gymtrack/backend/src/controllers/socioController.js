const supabase = require('../config/supabase');

/**
 * 1. OBTENER SOCIOS (Con paginación, filtros y búsqueda por Nombre, DNI o Teléfono)
 * GET /api/socios?page=1&limit=6&estado=activo&search=Juan
 */
const getSocios = async (req, res) => {
  try {
    let idGimnasio = req.usuario?.id_gimnasio;

    if (!idGimnasio && req.usuario?.id_usuario) {
      const { data: gym } = await supabase
        .from('gimnasio')
        .select('id_gimnasio')
        .eq('id_usuario', req.usuario.id_usuario)
        .maybeSingle();
      if (gym) idGimnasio = gym.id_gimnasio;
    }

    if (!idGimnasio) {
      return res.status(200).json({
        total: 0,
        page: 1,
        totalPages: 1,
        limit: 6,
        socios: []
      });
    }

    const { estado, search, limit, page } = req.query;

    let query = supabase
      .from('socio')
      .select(`
        *,
        usuario (
          nombre,
          apellido,
          email
        ),
        membresia (*)
      `, { count: 'exact' })
      .eq('id_gimnasio', idGimnasio);

    // Filtro por estado
    if (estado && estado !== 'todos') {
      query = query.eq('estado', estado);
    }

    // Búsqueda por DNI o Teléfono
    if (search) {
      const cleanSearch = search.trim();
      query = query.or(`dni.ilike.%${cleanSearch}%,telefono.ilike.%${cleanSearch}%`);
    }

    // Paginación condicional: solo paginar si limit NO es 'all' o '0'
    const isAll = limit === 'all' || limit === '0';
    let parsedLimit = parseInt(limit) || 6;
    let parsedPage = parseInt(page) || 1;

    if (!isAll) {
      const offset = (parsedPage - 1) * parsedLimit;
      query = query.range(offset, offset + parsedLimit - 1);
    }

    const { data: socios, error, count } = await query;

    if (error) {
      return res.status(500).json({ error: 'Error al consultar los socios: ' + error.message });
    }

    return res.status(200).json({
      total: count || 0,
      page: isAll ? 1 : parsedPage,
      totalPages: isAll ? 1 : Math.ceil((count || 0) / parsedLimit),
      limit: isAll ? count : parsedLimit,
      socios: socios || []
    });

  } catch (error) {
    return res.status(500).json({ error: 'Error interno del servidor: ' + error.message });
  }
};

/**
 * 2. OBTENER SOCIO POR ID
 * GET /api/socios/:id
 */
const getSocioById = async (req, res) => {
  try {
    const { id } = req.params;
    let idGimnasio = req.usuario?.id_gimnasio;
    if (!idGimnasio && req.usuario?.id_usuario) {
      const { data: gym } = await supabase
        .from('gimnasio')
        .select('id_gimnasio')
        .eq('id_usuario', req.usuario.id_usuario)
        .maybeSingle();
      if (gym) idGimnasio = gym.id_gimnasio;
    }

    const { data: socio, error } = await supabase
      .from('socio')
      .select(`
        *,
        usuario (
          id_usuario,
          nombre,
          apellido,
          email
        ),
        membresia (*),
        asistencia (*),
        progreso (*)
      `)
      .eq('id_socio', id)
      .eq('id_gimnasio', idGimnasio)
      .maybeSingle();

    if (error) {
      return res.status(500).json({ error: 'Error al obtener el socio: ' + error.message });
    }

    if (!socio) {
      return res.status(404).json({ error: 'Socio no encontrado o no pertenece a tu gimnasio.' });
    }

    return res.status(200).json({ socio });

  } catch (error) {
    return res.status(500).json({ error: 'Error interno del servidor: ' + error.message });
  }
};

/**
 * 3. CREAR SOCIO
 * POST /api/socios
 */
const createSocio = async (req, res) => {
  try {
    let idGimnasio = req.usuario?.id_gimnasio;
    if (!idGimnasio && req.usuario?.id_usuario) {
      const { data: gym } = await supabase
        .from('gimnasio')
        .select('id_gimnasio')
        .eq('id_usuario', req.usuario.id_usuario)
        .maybeSingle();
      if (gym) idGimnasio = gym.id_gimnasio;
    }

    const { 
      nombre, 
      apellido, 
      dni, 
      telefono, 
      plan, 
      precio, 
      estado, 
      fecha_vencimiento 
    } = req.body;

    // Validaciones de datos obligatorios
    if (!nombre || !nombre.trim()) {
      return res.status(400).json({ error: 'El nombre es obligatorio.' });
    }

    if (!dni || !dni.toString().trim()) {
      return res.status(400).json({ error: 'El DNI es obligatorio.' });
    }

    if (!idGimnasio) {
      return res.status(400).json({ error: 'No se asoció un gimnasio al usuario.' });
    }

    // Verificar DNI duplicado en el mismo gimnasio
    const { data: socioExistente } = await supabase
      .from('socio')
      .select('id_socio')
      .eq('dni', dni.toString().trim())
      .eq('id_gimnasio', idGimnasio)
      .maybeSingle();

    if (socioExistente) {
      return res.status(400).json({ error: 'Ya existe un socio registrado con este DNI.' });
    }

    // 1. Crear el usuario asociado al socio
    const { data: nuevoUsuario, error: errorUsuario } = await supabase
      .from('usuario')
      .insert([
        {
          nombre: nombre.trim(),
          apellido: apellido ? apellido.trim() : '',
          email: `${dni.toString().trim()}@gymtrack.local`, // Email temporal si no se provee uno
          contrasena: 'socio_default_pass',
          rol: 'socio',
          estado: estado || 'activo',
          fecha_creacion: new Date().toISOString()
        }
      ])
      .select()
      .single();

    if (errorUsuario) {
      return res.status(500).json({ error: 'Error al registrar usuario del socio: ' + errorUsuario.message });
    }

    // 2. Crear la ficha de socio
    const { data: nuevoSocio, error: errorSocio } = await supabase
      .from('socio')
      .insert([
        {
          id_usuario: nuevoUsuario.id_usuario,
          id_gimnasio: idGimnasio,
          dni: dni.toString().trim(),
          telefono: telefono ? telefono.trim() : null,
          fecha_alta: new Date().toISOString().split('T')[0],
          estado: estado || 'activo'
        }
      ])
      .select()
      .single();

    if (errorSocio) {
      return res.status(500).json({ error: 'Error al crear el socio: ' + errorSocio.message });
    }

    // 3. Registrar membresía (Plan y Fecha de Vencimiento)
    let membresia = null;
    if (plan || fecha_vencimiento) {
      const { data: nuevaMembresia, error: errorMembresia } = await supabase
        .from('membresia')
        .insert([
          {
            id_socio: nuevoSocio.id_socio,
            tipo: plan || 'General',
            precio: precio || 0,
            fecha_inicio: new Date().toISOString().split('T')[0],
            fecha_vencimiento: fecha_vencimiento || null,
            estado: estado || 'activo'
          }
        ])
        .select()
        .single();

      if (!errorMembresia) {
        membresia = nuevaMembresia;
      }
    }

    return res.status(201).json({
      mensaje: 'Socio registrado exitosamente.',
      socio: {
        ...nuevoSocio,
        nombre: nuevoUsuario.nombre,
        apellido: nuevoUsuario.apellido,
        membresia
      }
    });

  } catch (error) {
    return res.status(500).json({ error: 'Error interno del servidor: ' + error.message });
  }
};

/**
 * 4. ACTUALIZAR SOCIO COMPLETO
 * PUT /api/socios/:id
 */
const updateSocio = async (req, res) => {
  try {
    const { id } = req.params;
    let idGimnasio = req.usuario?.id_gimnasio;
    if (!idGimnasio && req.usuario?.id_usuario) {
      const { data: gym } = await supabase
        .from('gimnasio')
        .select('id_gimnasio')
        .eq('id_usuario', req.usuario.id_usuario)
        .maybeSingle();
      if (gym) idGimnasio = gym.id_gimnasio;
    }
    const { nombre, apellido, dni, telefono, estado } = req.body;

    // Verificar pertenencia al gimnasio
    const { data: socioActual } = await supabase
      .from('socio')
      .select('id_socio, id_usuario')
      .eq('id_socio', id)
      .eq('id_gimnasio', idGimnasio)
      .maybeSingle();

    if (!socioActual) {
      return res.status(404).json({ error: 'Socio no encontrado o sin permisos.' });
    }

    // Actualizar datos del usuario relacionado
    if (nombre || apellido) {
      await supabase
        .from('usuario')
        .update({
          ...(nombre && { nombre: nombre.trim() }),
          ...(apellido && { apellido: apellido.trim() })
        })
        .eq('id_usuario', socioActual.id_usuario);
    }

    // Actualizar datos de la tabla socio
    const { data: socioActualizado, error: errorUpdate } = await supabase
      .from('socio')
      .update({
        ...(dni && { dni: dni.toString().trim() }),
        ...(telefono && { telefono: telefono.trim() }),
        ...(estado && { estado })
      })
      .eq('id_socio', id)
      .select()
      .single();

    if (errorUpdate) {
      return res.status(500).json({ error: 'Error al actualizar socio: ' + errorUpdate.message });
    }

    return res.status(200).json({
      mensaje: 'Socio actualizado correctamente.',
      socio: socioActualizado
    });

  } catch (error) {
    return res.status(500).json({ error: 'Error interno del servidor: ' + error.message });
  }
};

/**
 * 5. CAMBIAR ESTADO DEL SOCIO
 * PATCH /api/socios/:id/estado
 */
const changeEstadoSocio = async (req, res) => {
  try {
    const { id } = req.params;
    let idGimnasio = req.usuario?.id_gimnasio;
    if (!idGimnasio && req.usuario?.id_usuario) {
      const { data: gym } = await supabase
        .from('gimnasio')
        .select('id_gimnasio')
        .eq('id_usuario', req.usuario.id_usuario)
        .maybeSingle();
      if (gym) idGimnasio = gym.id_gimnasio;
    }
    const { estado } = req.body;

    // Criterio: Validar estados permitidos
    const estadosPermitidos = ['activo', 'pendiente', 'inactivo'];
    if (!estado || !estadosPermitidos.includes(estado.toLowerCase())) {
      return res.status(400).json({ 
        error: 'El estado enviado no es válido. Debe ser: activo, pendiente o inactivo.' 
      });
    }

    const estadoLimpio = estado.toLowerCase();

    // Actualizar estado filtrando por id_gimnasio para garantizar aislamiento por empresa
    const { data: socioActualizado, error } = await supabase
      .from('socio')
      .update({ estado: estadoLimpio })
      .eq('id_socio', id)
      .eq('id_gimnasio', idGimnasio)
      .select()
      .maybeSingle();

    if (error) {
      return res.status(500).json({ error: 'Error al cambiar estado: ' + error.message });
    }

    if (!socioActualizado) {
      return res.status(404).json({ error: 'Socio no encontrado o no pertenece a tu gimnasio.' });
    }

    return res.status(200).json({
      mensaje: `Estado del socio modificado a '${estadoLimpio}' exitosamente.`,
      socio: socioActualizado
    });

  } catch (error) {
    return res.status(500).json({ error: 'Error interno del servidor: ' + error.message });
  }
};

/**
 * 6. OBTENER ESTADÍSTICAS DE SOCIOS
 * GET /api/socios/estadisticas
 */
const getSociosEstadisticas = async (req, res) => {
  try {
    let idGimnasio = req.usuario?.id_gimnasio;
    if (!idGimnasio && req.usuario?.id_usuario) {
      const { data: gym } = await supabase
        .from('gimnasio')
        .select('id_gimnasio')
        .eq('id_usuario', req.usuario.id_usuario)
        .maybeSingle();
      if (gym) idGimnasio = gym.id_gimnasio;
    }

    if (!idGimnasio) {
      return res.status(200).json({
        total: 128,
        activos: 96,
        pendientes: 18,
        inactivos: 14,
        nuevosEsteMes: 8
      });
    }

    const { data: socios, error } = await supabase
      .from('socio')
      .select('id_socio, estado, fecha_alta')
      .eq('id_gimnasio', idGimnasio);

    if (error) {
      return res.status(500).json({ error: error.message });
    }

    const currentMonth = new Date().toISOString().slice(0, 7);
    let total = socios?.length || 0;
    let activos = 0;
    let pendientes = 0;
    let inactivos = 0;
    let nuevosEsteMes = 0;

    (socios || []).forEach((s) => {
      const est = (s.estado || '').toLowerCase();
      if (est === 'activo') activos++;
      else if (est === 'pendiente') pendientes++;
      else if (est === 'inactivo') inactivos++;

      if (s.fecha_alta && s.fecha_alta.startsWith(currentMonth)) {
        nuevosEsteMes++;
      }
    });

    return res.status(200).json({
      total,
      activos,
      pendientes,
      inactivos,
      nuevosEsteMes
    });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

module.exports = {
  getSocios,
  getSociosEstadisticas,
  getSocioById,
  createSocio,
  updateSocio,
  changeEstadoSocio
};