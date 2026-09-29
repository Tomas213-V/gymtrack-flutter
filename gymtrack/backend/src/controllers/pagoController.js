const supabase = require('../config/supabase');

// 1. GET /api/pagos (Listado, Paginación y Filtros)
const getPagos = async (req, res) => {
  try {
    const { page = 1, limit = 10, estado, desde, hasta, id_gimnasio } = req.query;
    const offset = (page - 1) * limit;

    let targetData = [];
    let targetCount = 0;

    if (id_gimnasio) {
      let gymQuery = supabase
        .from('pago')
        .select('*, membresia!inner(*, plan_membresia(*), socio!inner(*))', { count: 'exact' })
        .order('id_pago', { ascending: false })
        .range(offset, offset + Number(limit) - 1)
        .eq('membresia.socio.id_gimnasio', id_gimnasio);

      if (estado && estado !== 'todos') gymQuery = gymQuery.eq('estado', estado);
      if (desde) gymQuery = gymQuery.gte('fecha_pago', desde);
      if (hasta) gymQuery = gymQuery.lte('fecha_pago', hasta);

      const { data: gymData, count: gymCount, error: gymErr } = await gymQuery;
      if (gymErr) throw gymErr;

      targetData = gymData || [];
      targetCount = gymCount || 0;
    } else {
      let query = supabase
        .from('pago')
        .select('*, membresia(*, plan_membresia(*), socio(*))', { count: 'exact' })
        .order('id_pago', { ascending: false })
        .range(offset, offset + Number(limit) - 1);

      if (estado && estado !== 'todos') query = query.eq('estado', estado);
      if (desde) query = query.gte('fecha_pago', desde);
      if (hasta) query = query.lte('fecha_pago', hasta);

      const { data, count, error } = await query;
      if (error) throw error;
      targetData = data || [];
      targetCount = count || 0;
    }

    return res.status(200).json({
      total: targetCount,
      pagina: Number(page),
      limite: Number(limit),
      datos: targetData
    });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

// 2. GET /api/pagos/resumen (Tarjetas de métricas)
const getResumenPagos = async (req, res) => {
  try {
    const { desde, hasta, id_gimnasio } = req.query;

    let targetData = [];

    if (id_gimnasio) {
      let gymQuery = supabase
        .from('pago')
        .select('monto, estado, membresia!inner(socio!inner(id_gimnasio))')
        .eq('membresia.socio.id_gimnasio', id_gimnasio);

      if (desde) gymQuery = gymQuery.gte('fecha_pago', desde);
      if (hasta) gymQuery = gymQuery.lte('fecha_pago', hasta);

      const { data: gymData, error: gymErr } = await gymQuery;
      if (gymErr) throw gymErr;
      targetData = gymData || [];
    } else {
      let query = supabase
        .from('pago')
        .select('monto, estado, membresia(socio(id_gimnasio))');

      if (desde) query = query.gte('fecha_pago', desde);
      if (hasta) query = query.lte('fecha_pago', hasta);

      const { data, error } = await query;
      if (error) throw error;
      targetData = data || [];
    }

    const resumen = targetData.reduce((acc, pago) => {
      const estadoNorm = (pago.estado || '').toLowerCase();
      if (estadoNorm === 'pagado') {
        acc.total_recaudado += Number(pago.monto);
        acc.pagos_realizados += 1;
      } else if (estadoNorm === 'pendiente') {
        acc.pagos_pendientes += 1;
      } else if (estadoNorm === 'vencido') {
        acc.pagos_vencidos += 1;
      }
      return acc;
    }, { total_recaudado: 0, pagos_realizados: 0, pagos_pendientes: 0, pagos_vencidos: 0 });

    return res.status(200).json(resumen);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

// 3. GET /api/pagos/membresias (Listado de socios y membresías del gimnasio para registrar pagos)
const getMembresias = async (req, res) => {
  try {
    const { id_gimnasio } = req.query;

    let query = supabase
      .from('socio')
      .select(`
        id_socio,
        dni,
        telefono,
        nombre,
        apellido,
        email,
        estado,
        id_gimnasio,
        membresia (
          id_membresia,
          precio,
          fecha_inicio,
          fecha_vencimiento,
          estado,
          id_plan_membresia,
          plan_membresia (
            id_plan_membresia,
            nombre,
            precio,
            duracion_dias
          )
        )
      `)
      .order('id_socio', { ascending: false });

    if (id_gimnasio) {
      query = query.eq('id_gimnasio', id_gimnasio);
    }

    const { data: socios, error } = await query;
    if (error) throw error;

    const resultado = (socios || []).map((s) => {
      const membList = Array.isArray(s.membresia) 
        ? s.membresia 
        : (s.membresia ? [s.membresia] : []);

      const membresiaActiva = membList.length > 0
        ? (membList.find(m => m.estado === 'activo') || membList[0])
        : null;

      return {
        id_socio: s.id_socio,
        dni: s.dni,
        telefono: s.telefono,
        nombre: s.nombre,
        apellido: s.apellido,
        email: s.email,
        estado_socio: s.estado,
        id_gimnasio: s.id_gimnasio,
        socio: {
          id_socio: s.id_socio,
          dni: s.dni,
          nombre: s.nombre,
          apellido: s.apellido,
          email: s.email,
          id_gimnasio: s.id_gimnasio
        },
        id_membresia: membresiaActiva ? membresiaActiva.id_membresia : null,
        precio: membresiaActiva?.precio != null ? membresiaActiva.precio : (membresiaActiva?.plan_membresia?.precio || null),
        fecha_vencimiento: membresiaActiva?.fecha_vencimiento || null,
        estado: membresiaActiva?.estado || 'sin_membresia',
        id_plan_membresia: membresiaActiva?.id_plan_membresia || null,
        plan_membresia: membresiaActiva?.plan_membresia || null
      };
    });

    return res.status(200).json(resultado);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

// 4. GET /api/pagos/:id (Detalle)
const getPagoById = async (req, res) => {
  try {
    const { id } = req.params;
    const { data, error } = await supabase
      .from('pago')
      .select('*, membresia(*, plan_membresia(*), socio(*))')
      .eq('id_pago', id)
      .single();

    if (error || !data) return res.status(404).json({ error: 'Pago no encontrado.' });

    return res.status(200).json(data);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

// 5. POST /api/pagos (Registrar pago)
const registrarPago = async (req, res) => {
  try {
    let { 
      id_socio,
      id_membresia, 
      id_plan_membresia,
      monto, 
      fecha_pago, 
      metodo_pago, 
      estado, 
      comprobante,
      nombreSocio,
      dniSocio,
      plan,
      id_gimnasio
    } = req.body;

    const estadosPermitidos = ['pagado', 'pendiente', 'vencido'];

    // Validaciones
    if (!monto || !fecha_pago || !metodo_pago || !estado) {
      return res.status(400).json({ error: 'Faltan campos obligatorios.' });
    }
    if (isNaN(monto) || Number(monto) <= 0) {
      return res.status(400).json({ error: 'El monto ingresado no es válido.' });
    }
    if (isNaN(Date.parse(fecha_pago))) {
      return res.status(400).json({ error: 'La fecha no es válida.' });
    }
    if (!estadosPermitidos.includes(estado.toLowerCase())) {
      return res.status(400).json({ error: 'El estado no es un valor permitido.' });
    }

    let socioId = id_socio || null;

    // Si no se proporcionó id_socio pero sí DNI, buscar socio existente en este gimnasio
    if (!socioId && dniSocio) {
      const cleanDni = String(dniSocio).trim();
      let socioQuery = supabase
        .from('socio')
        .select('id_socio, id_gimnasio, nombre, apellido')
        .eq('dni', cleanDni);

      if (id_gimnasio) {
        socioQuery = socioQuery.eq('id_gimnasio', id_gimnasio);
      }

      const { data: socioExistente } = await socioQuery.maybeSingle();

      if (socioExistente) {
        socioId = socioExistente.id_socio;
      } else {
        // Registrar nuevo socio directamente en el gimnasio actual
        const partesNombre = (nombreSocio || 'Socio').trim().split(' ');
        const nombre = partesNombre[0] || 'Socio';
        const apellido = partesNombre.slice(1).join(' ') || '';
        const gymId = id_gimnasio;

        if (!gymId) {
          return res.status(400).json({ error: 'No se identificó el gimnasio para registrar el nuevo socio.' });
        }

        const { data: nuevoSocio, error: errSocio } = await supabase
          .from('socio')
          .insert([{
            id_gimnasio: gymId,
            nombre,
            apellido,
            dni: cleanDni,
            telefono: 'Sin teléfono',
            fecha_alta: new Date().toISOString().split('T')[0],
            estado: 'activo'
          }])
          .select('id_socio')
          .single();

        if (errSocio) throw errSocio;
        socioId = nuevoSocio.id_socio;
      }
    }

    if (!socioId && !id_membresia) {
      return res.status(400).json({ error: 'Debes seleccionar o registrar un socio para procesar el pago.' });
    }

    // Gestionar membresía asociada
    if (!id_membresia && socioId) {
      // Buscar si el socio ya tiene membresía activa
      let { data: membExistente } = await supabase
        .from('membresia')
        .select('id_membresia, id_plan_membresia')
        .eq('id_socio', socioId)
        .eq('estado', 'activo')
        .maybeSingle();

      if (membExistente) {
        id_membresia = membExistente.id_membresia;
      } else {
        // Resolver id_plan_membresia
        let planId = id_plan_membresia;
        let duracionDias = 30;

        if (planId) {
          const { data: pObj } = await supabase
            .from('plan_membresia')
            .select('duracion_dias')
            .eq('id_plan_membresia', planId)
            .maybeSingle();
          if (pObj?.duracion_dias) duracionDias = pObj.duracion_dias;
        } else if (plan) {
          let pQuery = supabase
            .from('plan_membresia')
            .select('id_plan_membresia, duracion_dias')
            .ilike('nombre', `%${plan}%`);
          if (id_gimnasio) {
            pQuery = pQuery.eq('id_gimnasio', id_gimnasio);
          }
          const { data: pFound } = await pQuery.limit(1).maybeSingle();
          if (pFound) {
            planId = pFound.id_plan_membresia;
            if (pFound.duracion_dias) duracionDias = pFound.duracion_dias;
          }
        }

        if (!planId) {
          let pDefQuery = supabase
            .from('plan_membresia')
            .select('id_plan_membresia, duracion_dias');
          if (id_gimnasio) {
            pDefQuery = pDefQuery.eq('id_gimnasio', id_gimnasio);
          }
          const { data: pDef } = await pDefQuery.limit(1).maybeSingle();
          if (pDef) {
            planId = pDef.id_plan_membresia;
            if (pDef.duracion_dias) duracionDias = pDef.duracion_dias;
          } else if (id_gimnasio) {
            const { data: pNuevo } = await supabase
              .from('plan_membresia')
              .insert([{
                id_gimnasio: Number(id_gimnasio),
                nombre: plan || 'Plan Premium',
                precio: Number(monto) || 18000,
                duracion_dias: 30,
                estado: 'Activo'
              }])
              .select('id_plan_membresia, duracion_dias')
              .single();

            if (pNuevo) {
              planId = pNuevo.id_plan_membresia;
              duracionDias = pNuevo.duracion_dias || 30;
            }
          }
        }

        const nuevaMembData = {
          id_socio: socioId,
          precio: Number(monto),
          fecha_inicio: fecha_pago,
          fecha_vencimiento: new Date(Date.now() + duracionDias * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
          estado: estado === 'pagado' ? 'activo' : (estado === 'vencido' ? 'vencido' : 'activo')
        };
        if (planId) {
          nuevaMembData.id_plan_membresia = planId;
        }

        const { data: nuevaMemb, error: errMemb } = await supabase
          .from('membresia')
          .insert([nuevaMembData])
          .select('id_membresia')
          .single();

        if (errMemb) throw errMemb;
        id_membresia = nuevaMemb.id_membresia;
      }
    }

    if (!id_membresia) {
      return res.status(400).json({ error: 'No se pudo vincular una membresía para este socio.' });
    }

    // Inserción en tabla pago
    const insertPago = {
      id_membresia,
      monto: Number(monto),
      fecha_pago,
      metodo_pago: metodo_pago.toLowerCase(),
      estado: estado.toLowerCase(),
      comprobante: comprobante || null
    };

    const { data: pagoCreado, error: errPago } = await supabase
      .from('pago')
      .insert([insertPago])
      .select('*, membresia(*, plan_membresia(*), socio(*))')
      .single();

    if (errPago) throw errPago;

    return res.status(201).json({ mensaje: 'Pago registrado con éxito.', pago: pagoCreado });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

// 6. PATCH /api/pagos/:id/estado (Actualizar estado)
const actualizarEstadoPago = async (req, res) => {
  try {
    const { id } = req.params;
    const { estado } = req.body;
    const estadosPermitidos = ['pagado', 'pendiente', 'vencido'];

    if (!estado || !estadosPermitidos.includes(estado.toLowerCase())) {
      return res.status(400).json({ error: 'Estado no válido o no proporcionado.' });
    }

    const nuevoEstado = estado.toLowerCase();

    const { data: pagoActualizado, error } = await supabase
      .from('pago')
      .update({ estado: nuevoEstado })
      .eq('id_pago', id)
      .select('*, membresia(*, plan_membresia(*), socio(*))')
      .single();

    if (error || !pagoActualizado) {
      return res.status(404).json({ error: 'Pago no encontrado para actualizar.' });
    }

    // Sincronizar estado en membresía y socio asociados
    if (pagoActualizado.id_membresia) {
      const estadoMemb = nuevoEstado === 'pagado' ? 'activo' : (nuevoEstado === 'vencido' ? 'vencido' : 'pendiente');
      await supabase
        .from('membresia')
        .update({ estado: estadoMemb })
        .eq('id_membresia', pagoActualizado.id_membresia);

      const socioId = pagoActualizado.membresia?.id_socio;
      if (socioId) {
        const estadoSocio = nuevoEstado === 'pagado' ? 'activo' : (nuevoEstado === 'vencido' ? 'inactivo' : 'activo');
        await supabase
          .from('socio')
          .update({ estado: estadoSocio })
          .eq('id_socio', socioId);
      }
    }

    return res.status(200).json({ 
      mensaje: 'Estado actualizado correctamente.', 
      pago: pagoActualizado 
    });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

// 7. DELETE /api/pagos/:id (Eliminar pago)
const eliminarPago = async (req, res) => {
  try {
    const { id } = req.params;

    const { data, error } = await supabase
      .from('pago')
      .delete()
      .eq('id_pago', id)
      .select()
      .single();

    if (error) throw error;
    if (!data) return res.status(404).json({ error: 'El pago que deseas eliminar no existe.' });

    return res.status(200).json({ mensaje: 'Pago eliminado exitosamente.', pago: data });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

// 8. GET /api/pagos/planes (Listar planes de membresía disponibles)
const getPlanes = async (req, res) => {
  try {
    const { id_gimnasio } = req.query;
    let query = supabase
      .from('plan_membresia')
      .select('*')
      .order('id_plan_membresia', { ascending: true });

    if (id_gimnasio) {
      query = query.eq('id_gimnasio', id_gimnasio);
    }

    let { data, error } = await query;
    if (error) throw error;

    // Si el gimnasio aún no tiene planes configurados, sembrar 3 planes iniciales
    if ((!data || data.length === 0) && id_gimnasio) {
      const planesIniciales = [
        { id_gimnasio: Number(id_gimnasio), nombre: 'Plan Básico', precio: 15000, duracion_dias: 30, estado: 'Activo' },
        { id_gimnasio: Number(id_gimnasio), nombre: 'Plan Premium', precio: 22000, duracion_dias: 30, estado: 'Activo' },
        { id_gimnasio: Number(id_gimnasio), nombre: 'Pase Libre', precio: 28000, duracion_dias: 30, estado: 'Activo' }
      ];
      const { data: insertados, error: errInsert } = await supabase
        .from('plan_membresia')
        .insert(planesIniciales)
        .select('*');

      if (!errInsert && insertados) {
        data = insertados;
      }
    }

    return res.status(200).json(data || []);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

module.exports = {
  getPagos,
  getPagoById,
  registrarPago,
  actualizarEstadoPago,
  eliminarPago,
  getResumenPagos,
  getMembresias,
  getPlanes
};