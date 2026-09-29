const supabase = require('../config/supabase');

// 1. Consultar todos los ejercicios (GET)
const getEjercicios = async (req, res) => {
  try {
    const { page = 1, limit = 10, grupo_muscular, search } = req.query;
    const offset = (page - 1) * limit;

    let query = supabase
      .from('ejercicio')
      .select('*', { count: 'exact' })
      .range(offset, offset + Number(limit) - 1);

    if (grupo_muscular) {
      query = query.ilike('grupo_muscular', `%${grupo_muscular}%`);
    }
    if (search) {
      query = query.ilike('nombre', `%${search}%`);
    }

    const { data, count, error } = await query;
    if (error) throw error;

    return res.status(200).json({
      total: count,
      pagina: Number(page),
      limite: Number(limit),
      datos: data
    });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

// 2. Obtener un ejercicio específico por ID (GET)
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

    return res.status(200).json(data);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

// 3. Registrar un nuevo ejercicio (POST)
const crearEjercicio = async (req, res) => {
  try {
    const { nombre, grupo_muscular, descripcion, dificultad } = req.body;

    if (!nombre) {
      return res.status(400).json({ error: 'El nombre del ejercicio es obligatorio.' });
    }

    const { data, error } = await supabase
      .from('ejercicio')
      .insert([{
        nombre,
        grupo_muscular: grupo_muscular || null,
        descripcion: descripcion || null,
        dificultad: dificultad || null
      }])
      .select()
      .single();

    if (error) throw error;

    return res.status(201).json({ mensaje: 'Ejercicio creado con éxito.', ejercicio: data });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

// 4. Actualizar la información de un ejercicio (PUT)
const actualizarEjercicio = async (req, res) => {
  try {
    const { id } = req.params;
    const { nombre, grupo_muscular, descripcion, dificultad } = req.body;

    const { data, error } = await supabase
      .from('ejercicio')
      .update({
        nombre,
        grupo_muscular,
        descripcion,
        dificultad
      })
      .eq('id_ejercicio', id)
      .select()
      .single();

    if (error || !data) {
      return res.status(404).json({ error: 'Ejercicio no encontrado para actualizar.' });
    }

    return res.status(200).json({ mensaje: 'Ejercicio actualizado con éxito.', ejercicio: data });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

// 5. Eliminar un ejercicio (DELETE)
const eliminarEjercicio = async (req, res) => {
  try {
    const { id } = req.params;
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
  getEjercicioById,
  crearEjercicio,
  actualizarEjercicio,
  eliminarEjercicio
};