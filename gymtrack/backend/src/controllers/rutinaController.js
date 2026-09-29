// backend/src/controllers/rutinaController.js
const supabase = require('../config/supabase');

// 1. Obtener todas las rutinas con socio y ejercicios asociados
exports.getAllRutinas = async (req, res) => {
  try {
    const { search, id_socio, estado } = req.query;

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
            dificultad
          )
        )
      `)
      .order('id_rutina', { ascending: false });

    // Filtrar por socio si se proporciona
    if (id_socio && id_socio !== 'todos') {
      query = query.eq('id_socio', id_socio);
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
    return res.status(200).json(data || []);
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
            dificultad
          )
        )
      `)
      .eq('id_rutina', id)
      .single();

    if (error || !data) {
      return res.status(404).json({ message: `Rutina con ID ${id} no encontrada.` });
    }

    // Ordenar ejercicios por el campo orden ascendente
    if (data.rutina_ejercicio && Array.isArray(data.rutina_ejercicio)) {
      data.rutina_ejercicio.sort((a, b) => (a.orden || 0) - (b.orden || 0));
    }

    return res.status(200).json(data);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

// 3. Crear una nueva rutina
exports.createRutina = async (req, res) => {
  try {
    const { nombre, descripcion, id_socio, fecha_inicio, fecha_fin, estado } = req.body;

    if (!nombre || !nombre.trim()) {
      return res.status(400).json({ error: 'El nombre de la rutina es obligatorio.' });
    }

    const { data, error } = await supabase
      .from('rutina')
      .insert([
        {
          nombre: nombre.trim(),
          descripcion: descripcion ? descripcion.trim() : null,
          id_socio: id_socio ? Number(id_socio) : null,
          fecha_inicio: fecha_inicio || new Date().toISOString().split('T')[0],
          fecha_fin: fecha_fin || null,
          estado: estado || 'asignada'
        }
      ])
      .select()
      .single();

    if (error) throw error;
    return res.status(201).json(data);
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
    if (descripcion !== undefined) updateFields.descripcion = descripcion;
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
          dificultad
        )
      `)
      .eq('id_rutina', id)
      .order('orden', { ascending: true });

    if (error) throw error;
    return res.status(200).json(data || []);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

// 7. Asociar un ejercicio a la rutina
exports.addEjercicioToRutina = async (req, res) => {
  try {
    const { id } = req.params;
    const { id_ejercicio, series, serie, repeticiones, peso, descanso, orden } = req.body;

    const numSeries = Number(series || serie || 4);
    const numReps = Number(repeticiones || 12);
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
          dificultad
        )
      `)
      .single();

    if (error) {
      if (error.code === '23503') {
        return res.status(400).json({ error: 'El ejercicio especificado o la rutina no existen.' });
      }
      throw error;
    }

    return res.status(201).json(data);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

// 8. Actualizar parámetros de un ejercicio en la rutina
exports.updateEjercicioEnRutina = async (req, res) => {
  try {
    const { id, ejercicioId } = req.params;
    const { series, serie, repeticiones, peso, descanso, orden } = req.body;

    const updateFields = {};
    if (series !== undefined || serie !== undefined) updateFields.series = Number(series || serie);
    if (repeticiones !== undefined) updateFields.repeticiones = Number(repeticiones);
    if (peso !== undefined) updateFields.peso = Number(peso);
    if (descanso !== undefined) updateFields.descanso = Number(descanso);
    if (orden !== undefined) updateFields.orden = Number(orden);

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
          dificultad
        )
      `);

    if (error) throw error;
    return res.status(200).json(data && data.length > 0 ? data[0] : { message: 'Actualizado' });
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

    return res.status(200).json({ message: 'Ejercicio desvinculado con éxito.' });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};