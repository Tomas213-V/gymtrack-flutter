const supabase = require('../config/supabase');

// 1. GET /api/pagos (Listado, Paginación y Filtros)
const getPagos = async (req, res) => {
  try {
    const { page = 1, limit = 10, estado, desde, hasta, id_gimnasio } = req.query;
    const offset = (page - 1) * limit;

    let query = supabase
      .from('pago')
      .select('*, membresia(*, socio(*, usuario(nombre, apellido)))', { count: 'exact' })
      .order('id_pago', { ascending: false })
      .range(offset, offset + Number(limit) - 1);

    if (estado && estado !== 'todos') query = query.eq('estado', estado);
    if (desde) query = query.gte('fecha_pago', desde);
    if (hasta) query = query.lte('fecha_pago', hasta);

    let targetData = null;
    let targetCount = 0;

    // Si se indicó un gimnasio, buscar primero si tiene pagos asociados
    if (id_gimnasio) {
      let gymQuery = supabase
        .from('pago')
        .select('*, membresia!inner(*, socio!inner(*, usuario(nombre, apellido)))', { count: 'exact' })
        .order('id_pago', { ascending: false })
        .range(offset, offset + Number(limit) - 1)
        .eq('membresia.socio.id_gimnasio', id_gimnasio);

      if (estado && estado !== 'todos') gymQuery = gymQuery.eq('estado', estado);
      if (desde) gymQuery = gymQuery.gte('fecha_pago', desde);
      if (hasta) gymQuery = gymQuery.lte('fecha_pago', hasta);

      const { data: gymData, count: gymCount, error: gymErr } = await gymQuery;
      if (!gymErr && gymData && gymData.length > 0) {
        targetData = gymData;
        targetCount = gymCount;
      }
    }

    // Fallback: si no hay pagos específicos para ese gym o no se pasó id_gimnasio, devolver pagos disponibles
    if (!targetData) {
      const { data, count, error } = await query;
      if (error) throw error;
      targetData = data;
      targetCount = count;
    }

    return res.status(200).json({
      total: targetCount,
      pagina: Number(page),
      limite: Number(limit),
      datos: targetData || []
    });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

// 2. GET /api/pagos/resumen (Tarjetas de métricas)
const getResumenPagos = async (req, res) => {
  try {
    const { desde, hasta, id_gimnasio } = req.query;

    let targetData = null;

    if (id_gimnasio) {
      let gymQuery = supabase
        .from('pago')
        .select('monto, estado, membresia!inner(socio!inner(id_gimnasio))')
        .eq('membresia.socio.id_gimnasio', id_gimnasio);

      if (desde) gymQuery = gymQuery.gte('fecha_pago', desde);
      if (hasta) gymQuery = gymQuery.lte('fecha_pago', hasta);

      const { data: gymData, error: gymErr } = await gymQuery;
      if (!gymErr && gymData && gymData.length > 0) {
        targetData = gymData;
      }
    }

    if (!targetData) {
      let query = supabase
        .from('pago')
        .select('monto, estado, membresia(socio(id_gimnasio))');

      if (desde) query = query.gte('fecha_pago', desde);
      if (hasta) query = query.lte('fecha_pago', hasta);

      const { data, error } = await query;
      if (error) throw error;
      targetData = data || [];
    }

    const resumen = (targetData || []).reduce((acc, pago) => {
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

// 3. GET /api/pagos/membresias (Listado de membresías y socios para registrar pagos)
const getMembresias = async (req, res) => {
  try {
    const { id_gimnasio } = req.query;

    if (id_gimnasio) {
      const { data: gymMemb, error: gymErr } = await supabase
        .from('membresia')
        .select('id_membresia, tipo, precio, estado, socio!inner(id_socio, dni, id_gimnasio, usuario(nombre, apellido))')
        .eq('socio.id_gimnasio', id_gimnasio);

      if (!gymErr && gymMemb && gymMemb.length > 0) {
        return res.status(200).json(gymMemb);
      }
    }

    // Fallback general si no hay miembros registrados específicamente en ese gimnasio
    const { data, error } = await supabase
      .from('membresia')
      .select('id_membresia, tipo, precio, estado, socio(id_socio, dni, id_gimnasio, usuario(nombre, apellido))');

    if (error) throw error;
    return res.status(200).json(data || []);
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
      .select('*, membresia(*, socio(*, usuario(nombre, apellido, email))))')
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
      id_membresia, 
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

    // Si no se proporcionó id_membresia pero sí datos de socio/DNI
    if (!id_membresia && dniSocio) {
      const cleanDni = dniSocio.trim();
      let { data: socioExistente } = await supabase
        .from('socio')
        .select('id_socio, id_gimnasio, usuario(nombre, apellido)')
        .eq('dni', cleanDni)
        .maybeSingle();

      let socioId = socioExistente?.id_socio;

      if (!socioExistente) {
        const partesNombre = (nombreSocio || 'Socio General').trim().split(' ');
        const nombre = partesNombre[0] || 'Socio';
        const apellido = partesNombre.slice(1).join(' ') || 'Gym';
        const gymId = id_gimnasio || 20;

        const { data: nuevoUser, error: errUser } = await supabase
          .from('usuario')
          .insert([{
            nombre,
            apellido,
            email: `${cleanDni}@gymtrack.local`,
            contrasena: 'socio_default_pass',
            rol: 'socio',
            estado: 'activo'
          }])
          .select('id_usuario')
          .single();

        if (errUser) throw errUser;

        const { data: nuevoSocio, error: errSocio } = await supabase
          .from('socio')
          .insert([{
            id_usuario: nuevoUser.id_usuario,
            id_gimnasio: gymId,
            dni: cleanDni,
            telefono: '1100000000',
            fecha_alta: new Date().toISOString().split('T')[0],
            estado: 'activo'
          }])
          .select('id_socio')
          .single();

        if (errSocio) throw errSocio;
        socioId = nuevoSocio.id_socio;
      }

      // Buscar si ya tiene membresía o crear una nueva
      let { data: membExistente } = await supabase
        .from('membresia')
        .select('id_membresia')
        .eq('id_socio', socioId)
        .maybeSingle();

      if (membExistente) {
        id_membresia = membExistente.id_membresia;
      } else {
        const { data: nuevaMemb, error: errMemb } = await supabase
          .from('membresia')
          .insert([{
            id_socio: socioId,
            tipo: plan || 'Plan Básico',
            precio: Number(monto),
            fecha_inicio: fecha_pago,
            fecha_vencimiento: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
            estado: 'activo'
          }])
          .select('id_membresia')
          .single();

        if (errMemb) throw errMemb;
        id_membresia = nuevaMemb.id_membresia;
      }
    }

    // Si aún no hay id_membresia, tomar la primera existente como fallback
    if (!id_membresia) {
      const { data: membDefault } = await supabase.from('membresia').select('id_membresia').limit(1).single();
      id_membresia = membDefault?.id_membresia;
    }

    if (!id_membresia) {
      return res.status(400).json({ error: 'No se encontró una membresía para asociar el pago.' });
    }

    // Inserción en tabla pago
    const { data: pagoCreado, error: errPago } = await supabase
      .from('pago')
      .insert([{ 
        id_membresia, 
        monto: Number(monto), 
        fecha_pago, 
        metodo_pago, 
        estado: estado.toLowerCase(),
        comprobante: comprobante || null
      }])
      .select('*, membresia(*, socio(*, usuario(nombre, apellido))))')
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
      .select('*, membresia(*, socio(*, usuario(nombre, apellido))))')
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

module.exports = {
  getPagos,
  getPagoById,
  registrarPago,
  actualizarEstadoPago,
  eliminarPago,
  getResumenPagos,
  getMembresias
};