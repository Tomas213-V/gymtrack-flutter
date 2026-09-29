const supabase = require('../config/supabase');

/**
 * 1. OBTENER PLANES DE MEMBRESÍA DEL GIMNASIO
 * GET /api/planes-membresia?estado=activo
 */
const getPlanesMembresia = async (req, res) => {
  try {
    const idGimnasio = req.usuario?.id_gimnasio;

    if (!idGimnasio) {
      return res.status(400).json({ error: 'No se identificó el gimnasio autenticado.' });
    }

    const { estado } = req.query;

    let query = supabase
      .from('plan_membresia')
      .select('*')
      .eq('id_gimnasio', idGimnasio);

    if (estado && estado.toLowerCase() !== 'todos') {
      query = query.eq('estado', estado.toLowerCase());
    }

    const { data: planes, error } = await query.order('id_plan_membresia', { ascending: true });

    if (error) {
      return res.status(500).json({ error: 'Error al consultar los planes de membresía: ' + error.message });
    }

    return res.status(200).json({ planes: planes || [] });

  } catch (error) {
    return res.status(500).json({ error: 'Error interno del servidor: ' + error.message });
  }
};

/**
 * 2. OBTENER UN PLAN POR ID
 * GET /api/planes-membresia/:id
 */
const getPlanMembresiaById = async (req, res) => {
  try {
    const { id } = req.params;
    const idGimnasio = req.usuario?.id_gimnasio;

    const { data: plan, error } = await supabase
      .from('plan_membresia')
      .select('*')
      .eq('id_plan_membresia', id)
      .eq('id_gimnasio', idGimnasio)
      .maybeSingle();

    if (error) {
      return res.status(500).json({ error: 'Error al obtener el plan de membresía: ' + error.message });
    }

    if (!plan) {
      return res.status(404).json({ error: 'El plan de membresía no existe o no pertenece a tu gimnasio.' });
    }

    return res.status(200).json({ plan });

  } catch (error) {
    return res.status(500).json({ error: 'Error interno del servidor: ' + error.message });
  }
};

/**
 * 3. CREAR UN NUEVO PLAN DE MEMBRESÍA
 * POST /api/planes-membresia
 */
const createPlanMembresia = async (req, res) => {
  try {
    const idGimnasio = req.usuario?.id_gimnasio;
    const { nombre, precio, duracion_dias, estado } = req.body;

    // Validaciones
    if (!idGimnasio) {
      return res.status(400).json({ error: 'No se identificó el gimnasio autenticado.' });
    }

    if (!nombre || !nombre.trim()) {
      return res.status(400).json({ error: 'El nombre del plan es obligatorio.' });
    }

    if (precio === undefined || isNaN(precio) || parseFloat(precio) < 0) {
      return res.status(400).json({ error: 'El precio debe ser un número válido igual o mayor a 0.' });
    }

    if (!duracion_dias || isNaN(duracion_dias) || parseInt(duracion_dias) <= 0) {
      return res.status(400).json({ error: 'La duración en días debe ser un número entero mayor a 0.' });
    }

    // Armar objeto a insertar
    const nuevoPlanData = {
      id_gimnasio: idGimnasio,
      nombre: nombre.trim(),
      precio: parseFloat(precio),
      duracion_dias: parseInt(duracion_dias),
      estado: estado ? estado.trim().toLowerCase() : 'activo'
    };

    // Insertar en Supabase
    const { data: nuevoPlan, error } = await supabase
      .from('plan_membresia')
      .insert([nuevoPlanData])
      .select()
      .single();

    if (error) {
      return res.status(500).json({ error: 'Error al crear el plan de membresía: ' + error.message });
    }

    return res.status(201).json({
      mensaje: 'Plan de membresía creado correctamente.',
      plan: nuevoPlan
    });

  } catch (error) {
    return res.status(500).json({ error: 'Error interno del servidor: ' + error.message });
  }
};

/**
 * 4. ACTUALIZAR PLAN DE MEMBRESÍA
 * PUT /api/planes-membresia/:id
 */
const updatePlanMembresia = async (req, res) => {
  try {
    const { id } = req.params;
    const idGimnasio = req.usuario?.id_gimnasio;
    const { nombre, precio, duracion_dias, estado } = req.body;

    if (precio !== undefined && (isNaN(precio) || parseFloat(precio) < 0)) {
      return res.status(400).json({ error: 'El precio debe ser un número válido igual o mayor a 0.' });
    }

    if (duracion_dias !== undefined && (isNaN(duracion_dias) || parseInt(duracion_dias) <= 0)) {
      return res.status(400).json({ error: 'La duración en días debe ser un número entero mayor a 0.' });
    }

    const updateData = {};
    if (nombre) updateData.nombre = nombre.trim();
    if (precio !== undefined) updateData.precio = parseFloat(precio);
    if (duracion_dias !== undefined) updateData.duracion_dias = parseInt(duracion_dias);
    if (estado) updateData.estado = estado.trim().toLowerCase();

    const { data: planActualizado, error } = await supabase
      .from('plan_membresia')
      .update(updateData)
      .eq('id_plan_membresia', id)
      .eq('id_gimnasio', idGimnasio)
      .select()
      .maybeSingle();

    if (error) {
      return res.status(500).json({ error: 'Error al actualizar el plan de membresía: ' + error.message });
    }

    if (!planActualizado) {
      return res.status(404).json({ error: 'Plan de membresía no encontrado o no pertenece a tu gimnasio.' });
    }

    return res.status(200).json({
      mensaje: 'Plan de membresía actualizado exitosamente.',
      plan: planActualizado
    });

  } catch (error) {
    return res.status(500).json({ error: 'Error interno del servidor: ' + error.message });
  }
};

/**
 * 5. DESACTIVAR PLAN DE MEMBRESÍA (Borrado lógico)
 * PATCH /api/planes-membresia/:id/desactivar
 */
const deshabilitarPlanMembresia = async (req, res) => {
  try {
    const { id } = req.params;
    const idGimnasio = req.usuario?.id_gimnasio;

    const { data: planDesactivado, error } = await supabase
      .from('plan_membresia')
      .update({ estado: 'inactivo' })
      .eq('id_plan_membresia', id)
      .eq('id_gimnasio', idGimnasio)
      .select()
      .maybeSingle();

    if (error) {
      return res.status(500).json({ error: 'Error al cambiar estado del plan: ' + error.message });
    }

    if (!planDesactivado) {
      return res.status(404).json({ error: 'Plan de membresía no encontrado o no pertenece a tu gimnasio.' });
    }

    return res.status(200).json({
      mensaje: "Plan de membresía marcado como 'inactivo' exitosamente.",
      plan: planDesactivado
    });

  } catch (error) {
    return res.status(500).json({ error: 'Error interno del servidor: ' + error.message });
  }
};

module.exports = {
  getPlanesMembresia,
  getPlanMembresiaById,
  createPlanMembresia,
  updatePlanMembresia,
  deshabilitarPlanMembresia
};