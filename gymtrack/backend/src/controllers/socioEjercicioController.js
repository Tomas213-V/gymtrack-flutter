// backend/src/controllers/socioEjercicioController.js
const supabase = require('../config/supabase');

/**
 * Helper para resolver el socio y su gimnasio a partir de la sesión JWT
 */
const resolverSocioAutenticado = async (req) => {
  let idSocio = req.usuario?.id_socio;
  let idGimnasio = req.usuario?.id_gimnasio;

  if (!idSocio && req.usuario?.id_usuario) {
    const { data: socioAuth } = await supabase
      .from('socio')
      .select('id_socio, id_gimnasio')
      .eq('id_usuario', req.usuario.id_usuario)
      .maybeSingle();

    if (socioAuth) {
      idSocio = socioAuth.id_socio;
      idGimnasio = socioAuth.id_gimnasio;
    }
  }

  if (idSocio && !idGimnasio) {
    const { data: sData } = await supabase
      .from('socio')
      .select('id_gimnasio')
      .eq('id_socio', idSocio)
      .maybeSingle();
    if (sData) idGimnasio = sData.id_gimnasio;
  }

  return { idSocio, idGimnasio };
};

/**
 * 1. GET /api/socio/ejercicios
 * Consultar ejercicios disponibles del gimnasio y propios creados por el socio.
 * Filtros opcionales: origen ('todos' | 'gimnasio' | 'propio'), grupo_muscular, search.
 */
const getEjerciciosSocio = async (req, res) => {
  try {
    const { idSocio, idGimnasio } = await resolverSocioAutenticado(req);

    if (!idSocio) {
      return res.status(401).json({ error: 'Acceso no autorizado: Perfil de socio no encontrado.' });
    }

    const { origen = 'todos', grupo_muscular, search } = req.query;

    let query = supabase.from('ejercicio').select('*');

    // Filtrar según el origen solicitado:
    if (origen === 'gimnasio') {
      // Sólo ejercicios oficiales del gimnasio (sin id_socio asignado)
      if (idGimnasio) {
        query = query.eq('id_gimnasio', idGimnasio).is('id_socio', null);
      } else {
        query = query.is('id_socio', null);
      }
    } else if (origen === 'propio') {
      // Sólo ejercicios creados por este socio
      query = query.eq('id_socio', idSocio);
    } else {
      // 'todos': ejercicios del gimnasio al que asiste + ejercicios propios
      if (idGimnasio) {
        query = query.or(`and(id_gimnasio.eq.${idGimnasio},id_socio.is.null),id_socio.eq.${idSocio}`);
      } else {
        query = query.or(`id_socio.is.null,id_socio.eq.${idSocio}`);
      }
    }

    // Filtro por grupo muscular
    if (grupo_muscular && grupo_muscular !== 'todos') {
      query = query.ilike('grupo_muscular', `%${grupo_muscular.trim()}%`);
    }

    // Buscador por nombre
    if (search && search.trim()) {
      query = query.ilike('nombre', `%${search.trim()}%`);
    }

    query = query.order('nombre', { ascending: true });

    const { data, error } = await query;
    if (error) throw error;

    // Enriquecer y diferenciar claramente ejercicios del gimnasio y propios
    const ejerciciosDiferenciados = (data || []).map((ej) => {
      const esPropio = Boolean(ej.id_socio && Number(ej.id_socio) === Number(idSocio));
      return {
        id_ejercicio: ej.id_ejercicio,
        nombre: ej.nombre,
        descripcion: ej.descripcion || 'Sin descripción técnica disponible',
        grupo_muscular: ej.grupo_muscular || 'General',
        dificultad: ej.dificultad || 'Intermedia',
        id_gimnasio: ej.id_gimnasio,
        id_socio: ej.id_socio,
        origen: esPropio ? 'Mi ejercicio' : 'Gimnasio',
        tipo_origen: esPropio ? 'propio' : 'gimnasio',
        es_propio: esPropio,
        es_gimnasio: !ej.id_socio,
        puede_editar: esPropio,
        puede_eliminar: esPropio
      };
    });

    return res.status(200).json(ejerciciosDiferenciados);
  } catch (error) {
    return res.status(500).json({ error: 'Error al consultar ejercicios del socio: ' + error.message });
  }
};

/**
 * 2. POST /api/socio/ejercicios
 * Crear un nuevo ejercicio personalizado propio del socio.
 */
const crearEjercicioSocio = async (req, res) => {
  try {
    const { idSocio, idGimnasio } = await resolverSocioAutenticado(req);

    if (!idSocio) {
      return res.status(401).json({ error: 'Acceso no autorizado: Perfil de socio no encontrado.' });
    }

    const { nombre, grupo_muscular, descripcion, dificultad } = req.body;

    if (!nombre || !nombre.trim()) {
      return res.status(400).json({ error: 'El nombre del ejercicio es obligatorio.' });
    }

    const { data, error } = await supabase
      .from('ejercicio')
      .insert([
        {
          nombre: nombre.trim(),
          grupo_muscular: grupo_muscular ? grupo_muscular.trim() : 'General',
          descripcion: descripcion ? descripcion.trim() : null,
          dificultad: dificultad || 'Intermedia',
          id_socio: idSocio,
          id_gimnasio: idGimnasio || null
        }
      ])
      .select()
      .single();

    if (error) throw error;

    return res.status(201).json({
      mensaje: '¡Ejercicio propio creado exitosamente!',
      ejercicio: {
        ...data,
        origen: 'Mi ejercicio',
        tipo_origen: 'propio',
        es_propio: true,
        es_gimnasio: false,
        puede_editar: true,
        puede_eliminar: true
      }
    });
  } catch (error) {
    return res.status(500).json({ error: 'Error al crear el ejercicio propio: ' + error.message });
  }
};

/**
 * 3. PUT /api/socio/ejercicios/:id
 * Modificar un ejercicio propio.
 * Valida que el socio SOLO pueda modificar ejercicios creados por él.
 */
const actualizarEjercicioSocio = async (req, res) => {
  try {
    const { id } = req.params;
    const { idSocio } = await resolverSocioAutenticado(req);

    if (!idSocio) {
      return res.status(401).json({ error: 'Acceso no autorizado.' });
    }

    // 1. Consultar el ejercicio a editar
    const { data: ejercicioExistente, error: getErr } = await supabase
      .from('ejercicio')
      .select('id_ejercicio, id_socio, id_gimnasio, nombre')
      .eq('id_ejercicio', id)
      .maybeSingle();

    if (getErr || !ejercicioExistente) {
      return res.status(404).json({ error: 'El ejercicio solicitado no fue encontrado.' });
    }

    // 2. VALIDACIÓN ESTRICTA: El socio solamente puede modificar sus propios ejercicios
    if (!ejercicioExistente.id_socio || Number(ejercicioExistente.id_socio) !== Number(idSocio)) {
      return res.status(403).json({
        error: 'Permiso denegado: No tienes autorización para modificar ejercicios del gimnasio o pertenecientes a otros socios.'
      });
    }

    const { nombre, grupo_muscular, descripcion, dificultad } = req.body;

    const updateFields = {};
    if (nombre !== undefined && nombre.trim()) updateFields.nombre = nombre.trim();
    if (grupo_muscular !== undefined) updateFields.grupo_muscular = grupo_muscular.trim();
    if (descripcion !== undefined) updateFields.descripcion = descripcion ? descripcion.trim() : null;
    if (dificultad !== undefined) updateFields.dificultad = dificultad;

    const { data, error } = await supabase
      .from('ejercicio')
      .update(updateFields)
      .eq('id_ejercicio', id)
      .select()
      .single();

    if (error) throw error;

    return res.status(200).json({
      mensaje: 'Ejercicio propio actualizado con éxito.',
      ejercicio: {
        ...data,
        origen: 'Mi ejercicio',
        tipo_origen: 'propio',
        es_propio: true,
        es_gimnasio: false,
        puede_editar: true,
        puede_eliminar: true
      }
    });
  } catch (error) {
    return res.status(500).json({ error: 'Error al actualizar el ejercicio: ' + error.message });
  }
};

/**
 * 4. DELETE /api/socio/ejercicios/:id
 * Eliminar un ejercicio propio.
 * Valida que el socio SOLO pueda eliminar ejercicios creados por él.
 */
const eliminarEjercicioSocio = async (req, res) => {
  try {
    const { id } = req.params;
    const { idSocio } = await resolverSocioAutenticado(req);

    if (!idSocio) {
      return res.status(401).json({ error: 'Acceso no autorizado.' });
    }

    // 1. Consultar el ejercicio a eliminar
    const { data: ejercicioExistente, error: getErr } = await supabase
      .from('ejercicio')
      .select('id_ejercicio, id_socio, id_gimnasio, nombre')
      .eq('id_ejercicio', id)
      .maybeSingle();

    if (getErr || !ejercicioExistente) {
      return res.status(404).json({ error: 'El ejercicio solicitado no fue encontrado.' });
    }

    // 2. VALIDACIÓN ESTRICTA: El socio solamente puede eliminar sus propios ejercicios
    if (!ejercicioExistente.id_socio || Number(ejercicioExistente.id_socio) !== Number(idSocio)) {
      return res.status(403).json({
        error: 'Permiso denegado: No tienes autorización para eliminar ejercicios oficiales del gimnasio.'
      });
    }

    // 3. Limpiar dependencias en rutinas antes de eliminar
    await supabase
      .from('rutina_ejercicio')
      .delete()
      .eq('id_ejercicio', id);

    const { error } = await supabase
      .from('ejercicio')
      .delete()
      .eq('id_ejercicio', id);

    if (error) throw error;

    return res.status(200).json({
      mensaje: `El ejercicio propio "${ejercicioExistente.nombre}" fue eliminado exitosamente.`
    });
  } catch (error) {
    return res.status(500).json({ error: 'Error al eliminar el ejercicio propio: ' + error.message });
  }
};

module.exports = {
  getEjerciciosSocio,
  crearEjercicioSocio,
  actualizarEjercicioSocio,
  eliminarEjercicioSocio
};
