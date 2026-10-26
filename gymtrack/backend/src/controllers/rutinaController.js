// backend/src/controllers/rutinaController.js
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
 * Enriquecer listado de ejercicios asociados con origen ('Gimnasio' vs 'Mi ejercicio')
 */
const enriquecerEjerciciosRutina = (rutinaEjercicios = []) => {
  if (!Array.isArray(rutinaEjercicios)) return [];
  return rutinaEjercicios.map((re) => {
    const ej = re.ejercicio || {};
    const esPropio = Boolean(ej.id_socio);
    return {
      ...re,
      origen: esPropio ? 'Mi ejercicio' : 'Gimnasio',
      tipo_origen: esPropio ? 'propio' : 'gimnasio',
      es_propio: esPropio,
      es_gimnasio: !esPropio
    };
  });
};

// 1. Obtener todas las rutinas con socio y ejercicios asociados
exports.getAllRutinas = async (req, res) => {
  try {
    const usuario = resolverUsuario(req);
    let { search, id_socio, estado } = req.query;

    // Si el usuario autenticado es socio, por defecto sólo ve sus propias rutinas
    if (!id_socio && usuario?.rol === 'socio' && usuario.id_socio) {
      id_socio = usuario.id_socio;
    }

    let query = supabase
      .from('rutina')
      .select(`
        id_rutina,
        nombre,
        descripcion,
        fecha_inicio,
        fecha_fin,
        estado,
        id_socio,
        id_gimnasio,
        socio (
          id_socio,
          nombre,
          apellido,
          dni,
          id_gimnasio
        ),
        rutina_ejercicio (
          id_rutina_ejercicio,
          id_ejercicio,
          series,
          repeticiones,
          peso,
          descanso,
          orden,
          ejercicio (
            id_ejercicio,
            nombre,
            grupo_muscular,
            dificultad,
            descripcion,
            id_gimnasio,
            id_socio
          )
        )
      `)
      .order('id_rutina', { ascending: false });

    // Filtrar por socio si se proporciona
    if (id_socio && id_socio !== 'todos') {
      query = query.eq('id_socio', Number(id_socio));
    }

    // Filtrar por estado si se proporciona
    if (estado && estado !== 'todos') {
      query = query.eq('estado', estado);
    }

    // Filtrar por nombre de rutina
    if (search && search.trim()) {
      const clean = search.trim();
      query = query.ilike('nombre', `%${clean}%`);
    }

    const { data, error } = await query;
    if (error) throw error;

    // Formatear y enriquecer ejercicios de cada rutina
    const rutinasFormateadas = (data || []).map((r) => {
      const ejercicios = enriquecerEjerciciosRutina(r.rutina_ejercicio);
      ejercicios.sort((a, b) => (a.orden || 0) - (b.orden || 0));
      return {
        ...r,
        rutina_ejercicio: ejercicios
      };
    });

    // Ordenar para que la rutina activa aparezca en primer lugar
    rutinasFormateadas.sort((a, b) => {
      if (a.estado === 'activa' && b.estado !== 'activa') return -1;
      if (b.estado === 'activa' && a.estado !== 'activa') return 1;
      return (b.id_rutina || 0) - (a.id_rutina || 0);
    });

    return res.status(200).json(rutinasFormateadas);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

// 2. Obtener rutina por ID junto a sus ejercicios completos
exports.getRutinaById = async (req, res) => {
  try {
    const { id } = req.params;

    const { data, error } = await supabase
      .from('rutina')
      .select(`
        id_rutina,
        nombre,
        descripcion,
        fecha_inicio,
        fecha_fin,
        estado,
        id_socio,
        id_gimnasio,
        socio (
          id_socio,
          nombre,
          apellido,
          dni,
          id_gimnasio
        ),
        rutina_ejercicio (
          id_rutina_ejercicio,
          id_ejercicio,
          series,
          repeticiones,
          peso,
          descanso,
          orden,
          ejercicio (
            id_ejercicio,
            nombre,
            grupo_muscular,
            dificultad,
            descripcion,
            id_gimnasio,
            id_socio
          )
        )
      `)
      .eq('id_rutina', id)
      .single();

    if (error || !data) {
      return res.status(404).json({ message: `Rutina con ID ${id} no encontrada.` });
    }

    // Enriquecer y ordenar ejercicios
    const ejercicios = enriquecerEjerciciosRutina(data.rutina_ejercicio);
    ejercicios.sort((a, b) => (a.orden || 0) - (b.orden || 0));
    data.rutina_ejercicio = ejercicios;

    return res.status(200).json(data);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

// 3. Crear una nueva rutina
exports.createRutina = async (req, res) => {
  try {
    const usuario = resolverUsuario(req);
    const { nombre, descripcion, id_socio, fecha_inicio, fecha_fin, estado } = req.body;

    if (!nombre || !nombre.trim()) {
      return res.status(400).json({ error: 'El nombre de la rutina es obligatorio.' });
    }

    let socioAsignado = id_socio ? Number(id_socio) : null;
    if (!socioAsignado && usuario?.rol === 'socio' && usuario.id_socio) {
      socioAsignado = usuario.id_socio;
    }

    // Si tenemos el socio, obtener su gimnasio
    let gymId = usuario?.id_gimnasio || null;
    if (socioAsignado && !gymId) {
      const { data: socioData } = await supabase
        .from('socio')
        .select('id_gimnasio')
        .eq('id_socio', socioAsignado)
        .maybeSingle();
      if (socioData) gymId = socioData.id_gimnasio;
    }

    const { data, error } = await supabase
      .from('rutina')
      .insert([
        {
          nombre: nombre.trim(),
          descripcion: descripcion ? (typeof descripcion === 'string' ? descripcion.trim() : JSON.stringify(descripcion)) : null,
          id_socio: socioAsignado,
          id_gimnasio: gymId,
          fecha_inicio: fecha_inicio || new Date().toISOString().split('T')[0],
          fecha_fin: fecha_fin || null,
          estado: estado || 'asignada'
        }
      ])
      .select(`
        id_rutina,
        nombre,
        descripcion,
        fecha_inicio,
        fecha_fin,
        estado,
        id_socio,
        id_gimnasio,
        socio (
          id_socio,
          nombre,
          apellido,
          dni
        )
      `)
      .single();

    if (error) throw error;
    return res.status(201).json({
      ...data,
      rutina_ejercicio: []
    });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

// 4. Actualizar rutina existente
exports.updateRutina = async (req, res) => {
  try {
    const { id } = req.params;
    const { nombre, descripcion, id_socio, fecha_inicio, fecha_fin, estado } = req.body;

    const updateFields = {};
    if (nombre !== undefined) updateFields.nombre = nombre.trim();
    if (descripcion !== undefined) {
      updateFields.descripcion = typeof descripcion === 'string' ? descripcion : JSON.stringify(descripcion);
    }
    if (id_socio !== undefined) updateFields.id_socio = id_socio ? Number(id_socio) : null;
    if (fecha_inicio !== undefined) updateFields.fecha_inicio = fecha_inicio;
    if (fecha_fin !== undefined) updateFields.fecha_fin = fecha_fin;
    if (estado !== undefined) updateFields.estado = estado;

    const { data, error } = await supabase
      .from('rutina')
      .update(updateFields)
      .eq('id_rutina', id)
      .select()
      .single();

    if (error) throw error;
    if (!data) {
      return res.status(404).json({ message: `No se encontró la rutina ${id} para actualizar.` });
    }

    return res.status(200).json(data);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

// 5. Eliminar rutina y limpiar dependencias
exports.deleteRutina = async (req, res) => {
  try {
    const { id } = req.params;

    // Eliminamos primero relaciones de ejercicios asociados
    await supabase.from('rutina_ejercicio').delete().eq('id_rutina', id);

    const { data, error } = await supabase
      .from('rutina')
      .delete()
      .eq('id_rutina', id)
      .select();

    if (error) throw error;
    if (!data || data.length === 0) {
      return res.status(404).json({ message: `La rutina ${id} no existe.` });
    }

    return res.status(200).json({ message: `Rutina ${id} eliminada correctamente.` });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

// 6. Consultar sólo los ejercicios de una rutina
exports.getEjerciciosByRutina = async (req, res) => {
  try {
    const { id } = req.params;

    const { data, error } = await supabase
      .from('rutina_ejercicio')
      .select(`
        id_rutina_ejercicio,
        id_ejercicio,
        series,
        repeticiones,
        peso,
        descanso,
        orden,
        ejercicio (
          id_ejercicio,
          nombre,
          grupo_muscular,
          dificultad,
          descripcion,
          id_gimnasio,
          id_socio
        )
      `)
      .eq('id_rutina', id)
      .order('orden', { ascending: true });

    if (error) throw error;

    const enriquecidos = enriquecerEjerciciosRutina(data || []);
    return res.status(200).json(enriquecidos);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

// 7. Asociar un ejercicio a la rutina con validación de permisos
exports.addEjercicioToRutina = async (req, res) => {
  try {
    const { id } = req.params;
    const { id_ejercicio, series, serie, repeticiones, peso, descanso, orden } = req.body;

    if (!id_ejercicio) {
      return res.status(400).json({ error: 'El id_ejercicio es obligatorio.' });
    }

    // A. Consultar la rutina para conocer su socio y gimnasio
    const { data: rutina, error: rutinaError } = await supabase
      .from('rutina')
      .select('id_rutina, id_socio, id_gimnasio')
      .eq('id_rutina', id)
      .maybeSingle();

    if (rutinaError || !rutina) {
      return res.status(404).json({ error: `La rutina con ID ${id} no existe.` });
    }

    // B. Consultar el ejercicio para verificar su disponibilidad
    const { data: ejercicio, error: ejError } = await supabase
      .from('ejercicio')
      .select('id_ejercicio, nombre, grupo_muscular, dificultad, descripcion, id_gimnasio, id_socio')
      .eq('id_ejercicio', id_ejercicio)
      .maybeSingle();

    if (ejError || !ejercicio) {
      return res.status(404).json({ error: `El ejercicio con ID ${id_ejercicio} no existe en el sistema.` });
    }

    // C. VALIDACIÓN: El socio sólo puede utilizar ejercicios disponibles para él
    // C.1. Si es un ejercicio propio (id_socio no nulo), DEBE pertenecer al socio de la rutina
    if (ejercicio.id_socio && rutina.id_socio && Number(ejercicio.id_socio) !== Number(rutina.id_socio)) {
      return res.status(403).json({
        error: 'Acceso denegado: No podés utilizar un ejercicio personalizado creado por otro socio.'
      });
    }

    // C.2. Si es un ejercicio del gimnasio (id_socio es nulo y tiene id_gimnasio), DEBE pertenecer al gimnasio del socio
    if (!ejercicio.id_socio && ejercicio.id_gimnasio) {
      let gymSocio = rutina.id_gimnasio;
      if (!gymSocio && rutina.id_socio) {
        const { data: socioData } = await supabase
          .from('socio')
          .select('id_gimnasio')
          .eq('id_socio', rutina.id_socio)
          .maybeSingle();
        if (socioData) gymSocio = socioData.id_gimnasio;
      }

      if (gymSocio && Number(ejercicio.id_gimnasio) !== Number(gymSocio)) {
        return res.status(403).json({
          error: 'Acceso denegado: El ejercicio pertenece a otro gimnasio y no está disponible para este socio.'
        });
      }
    }

    const numSeries = Number(series || serie || 4);
    let numReps = parseInt(repeticiones, 10);
    if (isNaN(numReps) || numReps <= 0) numReps = 12;

    const numPeso = Number(peso || 0);
    const numDescanso = Number(descanso || 60);
    const numOrden = Number(orden || 1);

    const { data, error } = await supabase
      .from('rutina_ejercicio')
      .insert([
        {
          id_rutina: Number(id),
          id_ejercicio: Number(id_ejercicio),
          series: numSeries,
          repeticiones: numReps,
          peso: numPeso,
          descanso: numDescanso,
          orden: numOrden
        }
      ])
      .select(`
        id_rutina_ejercicio,
        id_ejercicio,
        series,
        repeticiones,
        peso,
        descanso,
        orden,
        ejercicio (
          id_ejercicio,
          nombre,
          grupo_muscular,
          dificultad,
          descripcion,
          id_gimnasio,
          id_socio
        )
      `)
      .single();

    if (error) {
      if (error.code === '23503') {
        return res.status(400).json({ error: 'El ejercicio especificado o la rutina no existen.' });
      }
      throw error;
    }

    const esPropio = Boolean(data.ejercicio?.id_socio);
    const enriquecido = {
      ...data,
      origen: esPropio ? 'Mi ejercicio' : 'Gimnasio',
      tipo_origen: esPropio ? 'propio' : 'gimnasio',
      es_propio: esPropio,
      es_gimnasio: !esPropio
    };

    return res.status(201).json(enriquecido);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

// 8. Actualizar parámetros de un ejercicio en la rutina
exports.updateEjercicioEnRutina = async (req, res) => {
  try {
    const { id, ejercicioId } = req.params;
    const { series, serie, repeticiones, peso, descanso, orden, id_ejercicio } = req.body;

    // Si se modifica el id_ejercicio, validar disponibilidad
    if (id_ejercicio) {
      const { data: rutina } = await supabase
        .from('rutina')
        .select('id_rutina, id_socio, id_gimnasio')
        .eq('id_rutina', id)
        .maybeSingle();

      const { data: nuevoEj } = await supabase
        .from('ejercicio')
        .select('id_ejercicio, id_socio, id_gimnasio')
        .eq('id_ejercicio', id_ejercicio)
        .maybeSingle();

      if (nuevoEj?.id_socio && rutina?.id_socio && Number(nuevoEj.id_socio) !== Number(rutina.id_socio)) {
        return res.status(403).json({
          error: 'No podés asignar un ejercicio propio perteneciente a otro socio.'
        });
      }
    }

    const updateFields = {};
    if (series !== undefined || serie !== undefined) updateFields.series = Number(series || serie);
    if (repeticiones !== undefined) {
      const parsedReps = parseInt(repeticiones, 10);
      updateFields.repeticiones = isNaN(parsedReps) ? 12 : parsedReps;
    }
    if (peso !== undefined) updateFields.peso = Number(peso);
    if (descanso !== undefined) updateFields.descanso = Number(descanso);
    if (orden !== undefined) updateFields.orden = Number(orden);
    if (id_ejercicio !== undefined) updateFields.id_ejercicio = Number(id_ejercicio);

    let query = supabase
      .from('rutina_ejercicio')
      .update(updateFields)
      .eq('id_rutina', id);

    // Permitir identificar por id_rutina_ejercicio o id_ejercicio
    if (ejercicioId) {
      query = query.or(`id_rutina_ejercicio.eq.${ejercicioId},id_ejercicio.eq.${ejercicioId}`);
    }

    const { data, error } = await query
      .select(`
        id_rutina_ejercicio,
        id_ejercicio,
        series,
        repeticiones,
        peso,
        descanso,
        orden,
        ejercicio (
          id_ejercicio,
          nombre,
          grupo_muscular,
          dificultad,
          descripcion,
          id_gimnasio,
          id_socio
        )
      `);

    if (error) throw error;

    const resultado = data && data.length > 0 ? data[0] : null;
    if (!resultado) {
      return res.status(404).json({ error: 'El ejercicio a actualizar no fue encontrado en la rutina.' });
    }

    const esPropio = Boolean(resultado.ejercicio?.id_socio);
    return res.status(200).json({
      ...resultado,
      origen: esPropio ? 'Mi ejercicio' : 'Gimnasio',
      tipo_origen: esPropio ? 'propio' : 'gimnasio',
      es_propio: esPropio,
      es_gimnasio: !esPropio
    });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

// 9. Desvincular ejercicio de la rutina
exports.removeEjercicioFromRutina = async (req, res) => {
  try {
    const { id, ejercicioId } = req.params;

    // Intentar eliminar por id_rutina_ejercicio o id_ejercicio
    const { data, error } = await supabase
      .from('rutina_ejercicio')
      .delete()
      .eq('id_rutina', id)
      .or(`id_rutina_ejercicio.eq.${ejercicioId},id_ejercicio.eq.${ejercicioId}`)
      .select();

    if (error) throw error;
    if (!data || data.length === 0) {
      return res.status(404).json({ message: 'El ejercicio no estaba asociado a esta rutina.' });
    }

    return res.status(200).json({ message: 'Ejercicio desvinculado con éxito de la rutina.' });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

// 10. Catálogo de Rutinas Ofrecidas por el Gimnasio (Programas Oficiales)
exports.getRutinasOfrecidasGym = async (req, res) => {
  try {
    const usuario = resolverUsuario(req);
    const gymId = usuario?.id_gimnasio || null;

    // Consultamos los ejercicios disponibles en el gimnasio para asociarlos
    let ejQuery = supabase
      .from('ejercicio')
      .select('id_ejercicio, nombre, grupo_muscular, dificultad, descripcion')
      .is('id_socio', null);

    if (gymId) {
      ejQuery = ejQuery.or(`id_gimnasio.eq.${gymId},id_gimnasio.is.null`);
    }

    const { data: dbEjercicios } = await ejQuery.limit(100);
    const listaEj = dbEjercicios || [];

    // Helper para buscar ejercicio en DB por coincidencia de nombre o músculo
    const encontrarEj = (nombreParcial, musculo) => {
      const exact = listaEj.find((e) => e.nombre?.toLowerCase().includes(nombreParcial.toLowerCase()));
      if (exact) return exact;
      if (musculo) {
        const porMusculo = listaEj.find((e) => e.grupo_muscular?.toLowerCase() === musculo.toLowerCase());
        if (porMusculo) return porMusculo;
      }
      return listaEj[0] || null;
    };

    // Plantillas de rutinas diseñadas por el staff del gimnasio
    const programasGym = [
      {
        id_plantilla: 'gym-fullbody-intro',
        nombre: 'Full Body: Acondicionamiento & Fuerza Integral',
        tipo: 'Full Body',
        dificultad: 'Principiante',
        duracion: '50 min',
        dias: 'Lunes, Miércoles, Viernes',
        objetivo: 'Acondicionamiento físico, ganancia de fuerza inicial y adaptación neuromuscular.',
        notas: 'Ideal para quienes inician o retoman el gimnasio. Realizar calentamiento previo de 5 a 10 min.',
        nivel_badge: 'Principiante',
        frecuencia: '3 días por semana',
        ejercicios_plantilla: [
          { query: 'Sentadilla', musculo: 'Piernas', series: 3, repeticiones: 12, peso: 20, descanso: 60 },
          { query: 'banca plano', musculo: 'Pecho', series: 3, repeticiones: 10, peso: 30, descanso: 75 },
          { query: 'Jalón al pecho', musculo: 'Espalda', series: 3, repeticiones: 12, peso: 35, descanso: 60 },
          { query: 'Press militar', musculo: 'Hombros', series: 3, repeticiones: 10, peso: 12, descanso: 60 },
          { query: 'Curl de bíceps', musculo: 'Brazos', series: 3, repeticiones: 12, peso: 15, descanso: 45 },
          { query: 'Plancha', musculo: 'Abdomen', series: 3, repeticiones: 30, peso: 0, descanso: 45 }
        ]
      },
      {
        id_plantilla: 'gym-torso-pierna',
        nombre: 'Torso / Pierna: Hipertrofia & Rendimiento',
        tipo: 'Torso - Pierna',
        dificultad: 'Intermedia',
        duracion: '65 min',
        dias: 'Lunes, Martes, Jueves, Viernes',
        objetivo: 'Maximizar el crecimiento muscular con balance perfecto entre volumen y recuperación.',
        notas: 'Separar los días de torso y pierna para permitir la recuperación muscular adecuada.',
        nivel_badge: 'Intermedio',
        frecuencia: '4 días por semana',
        ejercicios_plantilla: [
          { query: 'banca plano', musculo: 'Pecho', series: 4, repeticiones: 8, peso: 50, descanso: 90 },
          { query: 'Remo con barra', musculo: 'Espalda', series: 4, repeticiones: 10, peso: 45, descanso: 75 },
          { query: 'Press inclinado', musculo: 'Pecho', series: 3, repeticiones: 12, peso: 20, descanso: 60 },
          { query: 'Dominadas', musculo: 'Espalda', series: 3, repeticiones: 8, peso: 0, descanso: 90 },
          { query: 'Sentadilla', musculo: 'Piernas', series: 4, repeticiones: 10, peso: 60, descanso: 90 },
          { query: 'Prensa de piernas', musculo: 'Piernas', series: 4, repeticiones: 12, peso: 100, descanso: 75 },
          { query: 'Extensiones de cuádriceps', musculo: 'Piernas', series: 3, repeticiones: 15, peso: 40, descanso: 60 },
          { query: 'Curl femoral', musculo: 'Piernas', series: 3, repeticiones: 12, peso: 35, descanso: 60 }
        ]
      },
      {
        id_plantilla: 'gym-ppl-elite',
        nombre: 'Push / Pull / Legs (PPL): Élite Muscular',
        tipo: 'Push - Pull - Legs',
        dificultad: 'Avanzada',
        duracion: '70 min',
        dias: 'Lunes a Viernes',
        objetivo: 'Enfoque biomecánico en empujes, jalones y piernas para atletas comprometidos.',
        notas: 'Controlar la fase excéntrica del movimiento (2-3 segundos) para máximo reclutamiento.',
        nivel_badge: 'Avanzado',
        frecuencia: '5 días por semana',
        ejercicios_plantilla: [
          { query: 'banca plano', musculo: 'Pecho', series: 4, repeticiones: 8, peso: 65, descanso: 90 },
          { query: 'Press militar', musculo: 'Hombros', series: 4, repeticiones: 10, peso: 22, descanso: 75 },
          { query: 'Aperturas en polea', musculo: 'Pecho', series: 3, repeticiones: 15, peso: 15, descanso: 60 },
          { query: 'Extensiones de tríceps', musculo: 'Brazos', series: 4, repeticiones: 12, peso: 25, descanso: 45 },
          { query: 'Dominadas', musculo: 'Espalda', series: 4, repeticiones: 8, peso: 0, descanso: 90 },
          { query: 'Remo con barra', musculo: 'Espalda', series: 4, repeticiones: 10, peso: 55, descanso: 75 },
          { query: 'Curl de bíceps', musculo: 'Brazos', series: 4, repeticiones: 12, peso: 20, descanso: 60 },
          { query: 'Sentadilla', musculo: 'Piernas', series: 4, repeticiones: 8, peso: 75, descanso: 120 }
        ]
      },
      {
        id_plantilla: 'gym-fatburn-hiit',
        nombre: 'Quema de Grasa & HIIT Funcional',
        tipo: 'Funcional & HIIT',
        dificultad: 'Intermedia',
        duracion: '45 min',
        dias: 'Lunes, Miércoles, Viernes',
        objetivo: 'Acelerar el metabolismo basal, elevar pulsaciones y tonificar cuerpo completo.',
        notas: 'Descansos cortos y dinámicos para optimizar el consumo de oxígeno post-entrenamiento (EPOC).',
        nivel_badge: 'Dinámico',
        frecuencia: '3 días por semana',
        ejercicios_plantilla: [
          { query: 'Sentadilla', musculo: 'Piernas', series: 4, repeticiones: 15, peso: 20, descanso: 45 },
          { query: 'banca plano', musculo: 'Pecho', series: 4, repeticiones: 12, peso: 25, descanso: 45 },
          { query: 'Jalón al pecho', musculo: 'Espalda', series: 4, repeticiones: 12, peso: 30, descanso: 45 },
          { query: 'Elevaciones laterales', musculo: 'Hombros', series: 3, repeticiones: 15, peso: 8, descanso: 30 },
          { query: 'Plancha', musculo: 'Abdomen', series: 4, repeticiones: 40, peso: 0, descanso: 30 }
        ]
      },
      {
        id_plantilla: 'gym-strength-5x5',
        nombre: 'Fuerza Bruta 5×5 Powerlifting',
        tipo: 'Fuerza Pura',
        dificultad: 'Avanzada',
        duracion: '60 min',
        dias: 'Lunes, Miércoles, Viernes',
        objetivo: 'Desarrollo de fuerza máxima en movimientos multiarticulares con progresión lineal.',
        notas: '5 series de 5 repeticiones efectivas con 80-85% del 1RM. Descansos largos de 2 a 3 minutos.',
        nivel_badge: 'Fuerza',
        frecuencia: '3 días por semana',
        ejercicios_plantilla: [
          { query: 'Sentadilla', musculo: 'Piernas', series: 5, repeticiones: 5, peso: 80, descanso: 120 },
          { query: 'banca plano', musculo: 'Pecho', series: 5, repeticiones: 5, peso: 70, descanso: 120 },
          { query: 'Remo con barra', musculo: 'Espalda', series: 5, repeticiones: 5, peso: 60, descanso: 120 },
          { query: 'Press militar', musculo: 'Hombros', series: 5, repeticiones: 5, peso: 40, descanso: 90 }
        ]
      },
      {
        id_plantilla: 'gym-gluteos-piernas',
        nombre: 'Glúteos & Tren Inferior Esculpido',
        tipo: 'Piernas & Glúteos',
        dificultad: 'Intermedia',
        duracion: '55 min',
        dias: 'Martes, Jueves, Sábado',
        objetivo: 'Focalización en desarrollo de glúteos, isquiosurales, cuádriceps y abdomen firme.',
        notas: 'Concentrarse en la contracción en el punto máximo y tensión mecánica constante.',
        nivel_badge: 'Especializado',
        frecuencia: '3 días por semana',
        ejercicios_plantilla: [
          { query: 'Sentadilla', musculo: 'Piernas', series: 4, repeticiones: 10, peso: 40, descanso: 90 },
          { query: 'Prensa de piernas', musculo: 'Piernas', series: 4, repeticiones: 12, peso: 80, descanso: 75 },
          { query: 'Extensiones de cuádriceps', musculo: 'Piernas', series: 3, repeticiones: 15, peso: 30, descanso: 60 },
          { query: 'Curl femoral', musculo: 'Piernas', series: 4, repeticiones: 12, peso: 25, descanso: 60 },
          { query: 'Plancha', musculo: 'Abdomen', series: 3, repeticiones: 45, peso: 0, descanso: 45 }
        ]
      }
    ];

    // Construir la respuesta asociando ejercicios reales de la base de datos
    const programasCompletos = programasGym.map((prog) => {
      const ejerciciosAsociados = prog.ejercicios_plantilla.map((item, idx) => {
        const ejDb = encontrarEj(item.query, item.musculo);
        return {
          id_ejercicio: ejDb ? ejDb.id_ejercicio : idx + 1,
          nombre: ejDb ? ejDb.nombre : `${item.query} oficial`,
          grupo_muscular: ejDb ? ejDb.grupo_muscular : item.musculo,
          dificultad: ejDb ? ejDb.dificultad : prog.dificultad,
          descripcion: ejDb ? ejDb.descripcion : 'Ejercicio oficial recomendado por el gimnasio',
          series: item.series,
          repeticiones: item.repeticiones,
          peso: item.peso,
          descanso: item.descanso,
          orden: idx + 1
        };
      });

      return {
        id_plantilla: prog.id_plantilla,
        nombre: prog.nombre,
        tipo: prog.tipo,
        dificultad: prog.dificultad,
        duracion: prog.duracion,
        dias: prog.dias,
        objetivo: prog.objetivo,
        notas: prog.notas,
        nivel_badge: prog.nivel_badge,
        frecuencia: prog.frecuencia,
        es_ofrecida_gym: true,
        total_ejercicios: ejerciciosAsociados.length,
        ejercicios: ejerciciosAsociados
      };
    });

    return res.status(200).json(programasCompletos);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

// 11. Adoptar / Comenzar una Rutina del Gimnasio
exports.adoptarRutinaGym = async (req, res) => {
  try {
    const usuario = resolverUsuario(req);
    const { plantilla, id_plantilla, id_socio, nombre_personalizado } = req.body;

    let targetSocioId = id_socio ? Number(id_socio) : (usuario?.id_socio || null);
    if (!targetSocioId) {
      return res.status(400).json({ error: 'Se requiere el ID del socio para adoptar la rutina.' });
    }

    // Si viene el objeto plantilla directamente o hay que buscarlo
    let plan = plantilla;
    if (!plan && id_plantilla) {
      // Re-invocamos lógica interna para buscar la plantilla
      const gymId = usuario?.id_gimnasio || null;
      const { data: dbEj } = await supabase.from('ejercicio').select('*').is('id_socio', null).limit(100);
      const listaEj = dbEj || [];
      const encontrarEj = (q, m) => {
        const found = listaEj.find((e) => e.nombre?.toLowerCase().includes(q.toLowerCase()));
        return found || listaEj[0];
      };

      // Si no tenemos plantilla completa enviada, creamos una básica
      plan = {
        nombre: nombre_personalizado || 'Rutina Adoptada del Gimnasio',
        tipo: 'Full Body',
        dificultad: 'Intermedia',
        duracion: '60 min',
        dias: 'Lunes, Miércoles, Viernes',
        objetivo: 'Plan de entrenamiento sugerido por el gimnasio',
        notas: 'Adoptada del catálogo de rutinas del gimnasio.',
        ejercicios: []
      };
    }

    if (!plan) {
      return res.status(400).json({ error: 'No se suministraron los datos de la rutina a adoptar.' });
    }

    // Obtener gimnasio del socio
    const { data: socioDb } = await supabase
      .from('socio')
      .select('id_gimnasio')
      .eq('id_socio', targetSocioId)
      .maybeSingle();

    const gymId = socioDb?.id_gimnasio || usuario?.id_gimnasio || null;

    // Desactivar cualquier otra rutina activa previa del socio para que esta sea la principal
    await supabase
      .from('rutina')
      .update({ estado: 'asignada' })
      .eq('id_socio', targetSocioId)
      .eq('estado', 'activa');

    // Insertar la nueva rutina para el socio
    const metaDescripcion = JSON.stringify({
      tipo: plan.tipo || 'Full Body',
      dificultad: plan.dificultad || 'Intermedia',
      duracion: plan.duracion || '60 min',
      dias: plan.dias || 'Lunes, Miércoles, Viernes',
      notas: plan.notas || 'Plan adoptado del gimnasio.',
      objetivo: plan.objetivo || '',
      origen_oficial_gym: true
    });

    const { data: rutinaCreada, error: errInsert } = await supabase
      .from('rutina')
      .insert([
        {
          nombre: (nombre_personalizado || plan.nombre || 'Mi Rutina del Gimnasio').trim(),
          descripcion: metaDescripcion,
          id_socio: targetSocioId,
          id_gimnasio: gymId,
          fecha_inicio: new Date().toISOString().split('T')[0],
          estado: 'activa'
        }
      ])
      .select()
      .single();

    if (errInsert || !rutinaCreada) {
      throw new Error(errInsert?.message || 'Error al crear la rutina para el socio.');
    }

    // Insertar ejercicios asociados en rutina_ejercicio
    const ejerciciosParaInsertar = plan.ejercicios || [];
    const asociados = [];

    for (let i = 0; i < ejerciciosParaInsertar.length; i++) {
      const item = ejerciciosParaInsertar[i];
      if (item.id_ejercicio) {
        try {
          const { data: reData } = await supabase
            .from('rutina_ejercicio')
            .insert([
              {
                id_rutina: rutinaCreada.id_rutina,
                id_ejercicio: Number(item.id_ejercicio),
                series: Number(item.series || 4),
                repeticiones: Number(item.repeticiones || 10),
                peso: Number(item.peso || 0),
                descanso: Number(item.descanso || 60),
                orden: i + 1
              }
            ])
            .select(`
              id_rutina_ejercicio,
              id_ejercicio,
              series,
              repeticiones,
              peso,
              descanso,
              orden,
              ejercicio (
                id_ejercicio,
                nombre,
                grupo_muscular,
                dificultad
              )
            `)
            .single();

          if (reData) asociados.push(reData);
        } catch (e) {
          console.warn('Error asociando ejercicio a rutina adoptada:', e.message);
        }
      }
    }

    rutinaCreada.rutina_ejercicio = asociados;

    return res.status(201).json({
      mensaje: '¡Rutina adoptada con éxito! Ya está configurada como tu rutina activa.',
      rutina: rutinaCreada
    });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

// 12. Activar Rutina (Establecer como la rutina principal del socio)
exports.activarRutina = async (req, res) => {
  try {
    const { id } = req.params;
    const usuario = resolverUsuario(req);

    // Obtener la rutina a activar
    const { data: rutina, error: errRutina } = await supabase
      .from('rutina')
      .select('id_rutina, id_socio')
      .eq('id_rutina', id)
      .maybeSingle();

    if (errRutina || !rutina) {
      return res.status(404).json({ error: 'La rutina especificada no existe.' });
    }

    const socioId = rutina.id_socio;

    // Desactivar cualquier otra rutina activa del socio
    await supabase
      .from('rutina')
      .update({ estado: 'asignada' })
      .eq('id_socio', socioId)
      .eq('estado', 'activa');

    // Activar la rutina deseada
    const { data: activada, error: errActivar } = await supabase
      .from('rutina')
      .update({ estado: 'activa' })
      .eq('id_rutina', id)
      .select(`
        id_rutina,
        nombre,
        descripcion,
        estado,
        id_socio,
        rutina_ejercicio (
          id_rutina_ejercicio,
          id_ejercicio,
          series,
          repeticiones,
          peso,
          descanso,
          orden,
          ejercicio (
            id_ejercicio,
            nombre,
            grupo_muscular,
            dificultad
          )
        )
      `)
      .single();

    if (errActivar) throw errActivar;

    return res.status(200).json({
      mensaje: '¡Rutina activada correctamente! Se mostrará en tu panel principal de entrenamiento.',
      rutina: activada
    });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};