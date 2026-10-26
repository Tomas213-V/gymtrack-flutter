const supabase = require('../config/supabase');
const jwt = require('jsonwebtoken');

/**
 * Helper para resolver el usuario autenticado desde el token JWT
 */
const resolverUsuario = (req) => {
  if (req.usuario) return req.usuario;
  const authHeader = req.headers?.['authorization'] || req.headers?.['Authorization'];
  if (authHeader && authHeader.startsWith('Bearer ')) {
    try {
      const token = authHeader.split(' ')[1];
      const secret = process.env.JWT_SECRET || 'gymtrack_jwt_secret_key_2026';
      req.usuario = jwt.verify(token, secret);
      return req.usuario;
    } catch {
      // Ignorar si el token no es válido o ha expirado
    }
  }
  return null;
};

/**
 * 1. Consultar ejercicios disponibles para el socio
 * Devuelve ejercicios provistos por el gimnasio + ejercicios propios creados por el socio.
 * Soporta filtros: origen ('todos' | 'gimnasio' | 'propio'), grupo_muscular, search.
 */
const getEjerciciosDisponiblesSocio = async (req, res) => {
  try {
    const usuario = resolverUsuario(req);
    let { id_socio, origen = 'todos', grupo_muscular, search, limit = 100, page = 1 } = req.query;

    let targetSocioId = id_socio ? Number(id_socio) : usuario?.id_socio;

    if (!targetSocioId && usuario?.id_usuario) {
      const { data: socioAuth } = await supabase
        .from('socio')
        .select('id_socio, id_gimnasio')
        .eq('id_usuario', usuario.id_usuario)
        .maybeSingle();

      if (socioAuth) {
        targetSocioId = socioAuth.id_socio;
      }
    }

    let idGimnasio = usuario?.id_gimnasio || null;

    if (targetSocioId) {
      const { data: socioData } = await supabase
        .from('socio')
        .select('id_socio, id_gimnasio')
        .eq('id_socio', targetSocioId)
        .maybeSingle();

      if (socioData && socioData.id_gimnasio) {
        idGimnasio = socioData.id_gimnasio;
      }
    }

    let query = supabase.from('ejercicio').select('*');

    // Filtro por tipo de origen según el diagrama conceptual:
    // SOCIO -> Ejercicio Gimnasio | Ejercicio Propio
    if (origen === 'gimnasio') {
      if (idGimnasio) {
        query = query.eq('id_gimnasio', idGimnasio).is('id_socio', null);
      } else {
        query = query.is('id_socio', null);
      }
    } else if (origen === 'propio') {
      if (targetSocioId) {
        query = query.eq('id_socio', targetSocioId);
      } else {
        return res.status(200).json([]);
      }
    } else {
      // 'todos': Gimnasio disponible + Propios del socio
      if (targetSocioId && idGimnasio) {
        query = query.or(`and(id_gimnasio.eq.${idGimnasio},id_socio.is.null),id_socio.eq.${targetSocioId}`);
      } else if (targetSocioId) {
        query = query.or(`id_socio.is.null,id_socio.eq.${targetSocioId}`);
      } else if (idGimnasio) {
        query = query.or(`id_gimnasio.eq.${idGimnasio},id_socio.is.null`);
      }
    }

    if (grupo_muscular && grupo_muscular !== 'todos') {
      query = query.ilike('grupo_muscular', `%${grupo_muscular}%`);
    }

    if (search && search.trim()) {
      query = query.ilike('nombre', `%${search.trim()}%`);
    }

    query = query.order('nombre', { ascending: true });

    if (limit && limit !== 'all') {
      const numLimit = Number(limit);
      const offset = (Number(page) - 1) * numLimit;
      query = query.range(offset, offset + numLimit - 1);
    }

    const { data, error } = await query;
    if (error) throw error;

    // Enriquecer cada ejercicio con indicadores de origen
    const enriquecidos = (data || []).map((ej) => {
      const esPropio = Boolean(ej.id_socio && targetSocioId && Number(ej.id_socio) === Number(targetSocioId));
      return {
        ...ej,
        origen: ej.id_socio ? 'Mi ejercicio' : 'Gimnasio',
        tipo_origen: ej.id_socio ? 'propio' : 'gimnasio',
        es_propio: Boolean(ej.id_socio),
        es_gimnasio: !ej.id_socio,
        pertenece_al_socio: esPropio
      };
    });

    return res.status(200).json(enriquecidos);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

/**
 * 2. Consultar catálogo general de ejercicios (GET /api/ejercicios)
 */
const getEjercicios = async (req, res) => {
  try {
    const usuario = resolverUsuario(req);
    const { page = 1, limit = 50, grupo_muscular, search, id_socio, origen } = req.query;

    // Si viene id_socio o el usuario es un socio, redirigir la lógica a ejercicios disponibles
    if (id_socio || usuario?.rol === 'socio' || origen) {
      return getEjerciciosDisponiblesSocio(req, res);
    }

    const offset = (page - 1) * limit;

    let query = supabase
      .from('ejercicio')
      .select('*', { count: 'exact' });

    if (usuario?.id_gimnasio) {
      query = query.or(`id_gimnasio.eq.${usuario.id_gimnasio},id_gimnasio.is.null`);
    }

    if (grupo_muscular && grupo_muscular !== 'todos') {
      query = query.ilike('grupo_muscular', `%${grupo_muscular}%`);
    }

    if (search && search.trim()) {
      query = query.ilike('nombre', `%${search.trim()}%`);
    }

    query = query.order('id_ejercicio', { ascending: false });

    if (limit !== 'all') {
      query = query.range(offset, offset + Number(limit) - 1);
    }

    const { data, count, error } = await query;
    if (error) throw error;

    const datosEnriquecidos = (data || []).map((ej) => ({
      ...ej,
      origen: ej.id_socio ? 'Mi ejercicio' : 'Gimnasio',
      tipo_origen: ej.id_socio ? 'propio' : 'gimnasio',
      es_propio: Boolean(ej.id_socio),
      es_gimnasio: !ej.id_socio
    }));

    return res.status(200).json({
      total: count,
      pagina: Number(page),
      limite: Number(limit),
      datos: datosEnriquecidos
    });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

/**
 * 3. Obtener un ejercicio específico por ID (GET /api/ejercicios/:id)
 */
const getEjercicioById = async (req, res) => {
  try {
    const { id } = req.params;
    const { data, error } = await supabase
      .from('ejercicio')
      .select('*')
      .eq('id_ejercicio', id)
      .single();

    if (error || !data) {
      return res.status(404).json({ error: 'Ejercicio no encontrado.' });
    }

    return res.status(200).json({
      ...data,
      origen: data.id_socio ? 'Mi ejercicio' : 'Gimnasio',
      es_propio: Boolean(data.id_socio),
      es_gimnasio: !data.id_socio
    });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

/**
 * 4. Registrar un ejercicio personalizado creado por el socio (POST /api/ejercicios/personalizado)
 */
const crearEjercicioPersonalizado = async (req, res) => {
  try {
    const usuario = resolverUsuario(req);
    const { nombre, grupo_muscular, descripcion, dificultad, id_socio, id_gimnasio } = req.body;

    if (!nombre || !nombre.trim()) {
      return res.status(400).json({ error: 'El nombre del ejercicio es obligatorio.' });
    }

    let socioId = id_socio ? Number(id_socio) : usuario?.id_socio;

    if (!socioId && usuario?.id_usuario) {
      const { data: socioAuth } = await supabase
        .from('socio')
        .select('id_socio, id_gimnasio')
        .eq('id_usuario', usuario.id_usuario)
        .maybeSingle();

      if (socioAuth) {
        socioId = socioAuth.id_socio;
      }
    }

    if (!socioId) {
      return res.status(400).json({
        error: 'No se pudo identificar el socio creador. Proporciona id_socio o inicia sesión como socio.'
      });
    }

    let gymId = id_gimnasio ? Number(id_gimnasio) : usuario?.id_gimnasio;
    if (!gymId && socioId) {
      const { data: socioData } = await supabase
        .from('socio')
        .select('id_gimnasio')
        .eq('id_socio', socioId)
        .maybeSingle();

      if (socioData?.id_gimnasio) {
        gymId = socioData.id_gimnasio;
      }
    }

    const { data, error } = await supabase
      .from('ejercicio')
      .insert([
        {
          nombre: nombre.trim(),
          grupo_muscular: grupo_muscular ? grupo_muscular.trim() : 'General',
          descripcion: descripcion ? descripcion.trim() : null,
          dificultad: dificultad || 'Intermedia',
          id_socio: socioId,
          id_gimnasio: gymId || null
        }
      ])
      .select()
      .single();

    if (error) throw error;

    return res.status(201).json({
      mensaje: 'Ejercicio personalizado creado con éxito.',
      ejercicio: {
        ...data,
        origen: 'Mi ejercicio',
        tipo_origen: 'propio',
        es_propio: true,
        es_gimnasio: false,
        pertenece_al_socio: true
      }
    });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

/**
 * 5. Registrar un nuevo ejercicio estándar (POST /api/ejercicios)
 */
const crearEjercicio = async (req, res) => {
  try {
    const usuario = resolverUsuario(req);
    const { nombre, grupo_muscular, descripcion, dificultad, id_socio, id_gimnasio } = req.body;

    if (!nombre || !nombre.trim()) {
      return res.status(400).json({ error: 'El nombre del ejercicio es obligatorio.' });
    }

    // Si viene id_socio o el rol es socio, es un ejercicio personalizado
    if (id_socio || usuario?.rol === 'socio') {
      return crearEjercicioPersonalizado(req, res);
    }

    let gymId = id_gimnasio ? Number(id_gimnasio) : usuario?.id_gimnasio;

    const { data, error } = await supabase
      .from('ejercicio')
      .insert([
        {
          nombre: nombre.trim(),
          grupo_muscular: grupo_muscular ? grupo_muscular.trim() : 'General',
          descripcion: descripcion ? descripcion.trim() : null,
          dificultad: dificultad || 'Intermedia',
          id_gimnasio: gymId || null,
          id_socio: null
        }
      ])
      .select()
      .single();

    if (error) throw error;

    return res.status(201).json({
      mensaje: 'Ejercicio creado con éxito.',
      ejercicio: {
        ...data,
        origen: 'Gimnasio',
        tipo_origen: 'gimnasio',
        es_propio: false,
        es_gimnasio: true
      }
    });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

/**
 * 6. Actualizar ejercicio (PUT /api/ejercicios/:id)
 */
const actualizarEjercicio = async (req, res) => {
  try {
    const { id } = req.params;
    const { nombre, grupo_muscular, descripcion, dificultad } = req.body;

    const updateFields = {};
    if (nombre !== undefined) updateFields.nombre = nombre.trim();
    if (grupo_muscular !== undefined) updateFields.grupo_muscular = grupo_muscular.trim();
    if (descripcion !== undefined) updateFields.descripcion = descripcion;
    if (dificultad !== undefined) updateFields.dificultad = dificultad;

    const { data, error } = await supabase
      .from('ejercicio')
      .update(updateFields)
      .eq('id_ejercicio', id)
      .select()
      .single();

    if (error || !data) {
      return res.status(404).json({ error: 'Ejercicio no encontrado para actualizar.' });
    }

    return res.status(200).json({
      mensaje: 'Ejercicio actualizado con éxito.',
      ejercicio: {
        ...data,
        origen: data.id_socio ? 'Mi ejercicio' : 'Gimnasio',
        es_propio: Boolean(data.id_socio),
        es_gimnasio: !data.id_socio
      }
    });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

/**
 * 7. Eliminar ejercicio (DELETE /api/ejercicios/:id)
 */
const eliminarEjercicio = async (req, res) => {
  try {
    const { id } = req.params;

    // Verificar si está en uso en alguna rutina antes de eliminar
    const { count: usoCount } = await supabase
      .from('rutina_ejercicio')
      .select('id_rutina_ejercicio', { count: 'exact', head: true })
      .eq('id_ejercicio', id);

    if (usoCount && usoCount > 0) {
      return res.status(400).json({
        error: `No se puede eliminar el ejercicio porque está asignado a ${usoCount} rutina(s). Primero retíralo de las rutinas.`
      });
    }

    const { data, error } = await supabase
      .from('ejercicio')
      .delete()
      .eq('id_ejercicio', id)
      .select()
      .single();

    if (error || !data) {
      return res.status(404).json({ error: 'Ejercicio no encontrado para eliminar.' });
    }

    return res.status(200).json({ mensaje: 'Ejercicio eliminado con éxito.' });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

module.exports = {
  getEjercicios,
  getEjerciciosDisponiblesSocio,
  getEjercicioById,
  crearEjercicio,
  crearEjercicioPersonalizado,
  actualizarEjercicio,
  eliminarEjercicio
};