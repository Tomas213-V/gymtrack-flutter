const supabase = require('../config/supabase');

/**
 * 1. OBTENER TODAS LAS MEMBRESÍAS DE SOCIOS
 * GET /api/membresias?estado=activo&id_socio=1
 */
const getMembresias = async (req, res) => {
  try {
    const idGimnasio = req.usuario?.id_gimnasio;

    if (!idGimnasio) {
      return res.status(400).json({ error: 'No se identificó el gimnasio autenticado.' });
    }

    const { id_socio, estado } = req.query;

    let query = supabase
      .from('membresia')
      .select(`
        *,
        socio!inner (
          id_socio,
          nombre,
          apellido,
          dni,
          id_gimnasio
        ),
        plan_membresia (*)
      `)
      .eq('socio.id_gimnasio', idGimnasio)
      .order('fecha_vencimiento', { ascending: true });

    if (id_socio) {
      query = query.eq('id_socio', id_socio);
    }

    if (estado && estado.toLowerCase() !== 'todos') {
      query = query.eq('estado', estado.toLowerCase());
    }

    const { data: membresias, error } = await query;

    if (error) {
      return res.status(500).json({ error: 'Error al consultar las membresías: ' + error.message });
    }

    return res.status(200).json({ membresias: membresias || [] });

  } catch (error) {
    return res.status(500).json({ error: 'Error interno del servidor: ' + error.message });
  }
};

/**
 * 2. OBTENER UNA MEMBRESÍA POR ID
 * GET /api/membresias/:id
 */
const getMembresiaById = async (req, res) => {
  try {
    const { id } = req.params;
    const idGimnasio = req.usuario?.id_gimnasio;

    const { data: membresia, error } = await supabase
      .from('membresia')
      .select(`
        *,
        socio!inner (
          id_socio,
          nombre,
          apellido,
          dni,
          id_gimnasio
        ),
        plan_membresia (*)
      `)
      .eq('id_membresia', id)
      .eq('socio.id_gimnasio', idGimnasio)
      .maybeSingle();

    if (error) {
      return res.status(500).json({ error: 'Error al obtener la membresía: ' + error.message });
    }

    if (!membresia) {
      return res.status(404).json({ error: 'Membresía no encontrada o no pertenece a tu gimnasio.' });
    }

    return res.status(200).json({ membresia });

  } catch (error) {
    return res.status(500).json({ error: 'Error interno del servidor: ' + error.message });
  }
};

/**
 * 3. REGISTRAR / ASIGNAR UNA MEMBRESÍA A UN SOCIO
 * POST /api/membresias
 * Automático: Toma los días del plan y calcula fecha_vencimiento a partir de fecha_inicio.
 */
const createMembresia = async (req, res) => {
  try {
    const idGimnasio = req.usuario?.id_gimnasio;
    const { id_socio, id_plan_membresia, fecha_inicio, dias_adicionales, estado, precio } = req.body;

    // Validaciones básicas
    if (!id_socio) {
      return res.status(400).json({ error: 'El id_socio es obligatorio.' });
    }

    if (!id_plan_membresia) {
      return res.status(400).json({ error: 'El id_plan_membresia es obligatorio.' });
    }

    // 1. Validar que el socio existe y pertenece al gimnasio
    const { data: socio, error: socioErr } = await supabase
      .from('socio')
      .select('id_socio')
      .eq('id_socio', id_socio)
      .eq('id_gimnasio', idGimnasio)
      .maybeSingle();

    if (socioErr || !socio) {
      return res.status(404).json({ error: 'El socio especificado no existe o no pertenece a tu gimnasio.' });
    }

    // 2. Validar el plan seleccionado
    const { data: plan, error: planErr } = await supabase
      .from('plan_membresia')
      .select('*')
      .eq('id_plan_membresia', id_plan_membresia)
      .eq('id_gimnasio', idGimnasio)
      .maybeSingle();

    if (planErr || !plan) {
      return res.status(404).json({ error: 'El plan de membresía especificado no existe.' });
    }

    // 3. Cálculo automático: Fecha Inicio + Días del Plan (+ días adicionales si los hay)
    const fInicio = fecha_inicio ? new Date(fecha_inicio) : new Date();
    const duracionTotal = (plan.duracion_dias || 30) + (parseInt(dias_adicionales) || 0);

    const fVencimiento = new Date(fInicio);
    fVencimiento.setDate(fVencimiento.getDate() + duracionTotal);

    // 4. Armar datos e insertar
    const nuevaMembresiaData = {
      id_socio,
      id_plan_membresia,
      precio: precio !== undefined ? parseFloat(precio) : plan.precio,
      fecha_inicio: fInicio.toISOString().split('T')[0],
      fecha_vencimiento: fVencimiento.toISOString().split('T')[0],
      estado: estado ? estado.trim().toLowerCase() : 'activo'
    };

    const { data: nuevaMembresia, error: insertErr } = await supabase
      .from('membresia')
      .insert([nuevaMembresiaData])
      .select('*, plan_membresia(*)')
      .single();

    if (insertErr) {
      return res.status(500).json({ error: 'Error al registrar la membresía: ' + insertErr.message });
    }

    return res.status(201).json({
      mensaje: 'Membresía asignada al socio exitosamente.',
      membresia: nuevaMembresia
    });

  } catch (error) {
    return res.status(500).json({ error: 'Error interno del servidor: ' + error.message });
  }
};

/**
 * 4. ACTUALIZAR / EXTENDER FECHAS O ESTADO DE UNA MEMBRESÍA
 * PATCH /api/membresias/:id
 * Manual: Permite definir explicitamente fecha_vencimiento, fecha_inicio o sumar dias_extension.
 */
const updateMembresia = async (req, res) => {
  try {
    const idGimnasio = req.usuario?.id_gimnasio;
    const { id } = req.params;
    const { estado, fecha_inicio, fecha_vencimiento, dias_extension, precio } = req.body;

    // 1. Verificar que la membresía exista y pertenezca al gimnasio
    const { data: membActual, error: membErr } = await supabase
      .from('membresia')
      .select(`
        *,
        socio!inner (id_gimnasio)
      `)
      .eq('id_membresia', id)
      .eq('socio.id_gimnasio', idGimnasio)
      .maybeSingle();

    if (membErr || !membActual) {
      return res.status(404).json({ error: 'Membresía no encontrada o no pertenece a tu gimnasio.' });
    }

    const updateData = {};

    // 2. Manejo de Fechas (Manual o por días)
    if (fecha_inicio) {
      updateData.fecha_inicio = fecha_inicio; // Formato esperado: YYYY-MM-DD
    }

    if (fecha_vencimiento) {
      // Prioridad 1: Fecha fija asignada manualmente desde el frontend
      updateData.fecha_vencimiento = fecha_vencimiento; // Formato esperado: YYYY-MM-DD
    } else if (dias_extension && !isNaN(dias_extension)) {
      // Prioridad 2: Extensión rápida de días desde la fecha actual de vencimiento
      const baseDate = new Date(membActual.fecha_vencimiento);
      baseDate.setDate(baseDate.getDate() + parseInt(dias_extension));
      updateData.fecha_vencimiento = baseDate.toISOString().split('T')[0];
    }

    if (estado) {
      updateData.estado = estado.trim().toLowerCase();
    }

    if (precio !== undefined) {
      updateData.precio = parseFloat(precio);
    }

    // 3. Guardar cambios en Supabase
    const { data: membActualizada, error: updateErr } = await supabase
      .from('membresia')
      .update(updateData)
      .eq('id_membresia', id)
      .select('*, plan_membresia(*)')
      .single();

    if (updateErr) {
      return res.status(500).json({ error: 'Error al actualizar la membresía: ' + updateErr.message });
    }

    return res.status(200).json({
      mensaje: 'Membresía actualizada exitosamente.',
      membresia: membActualizada
    });

  } catch (error) {
    return res.status(500).json({ error: 'Error interno del servidor: ' + error.message });
  }
};

module.exports = {
  getMembresias,
  getMembresiaById,
  createMembresia,
  updateMembresia
};