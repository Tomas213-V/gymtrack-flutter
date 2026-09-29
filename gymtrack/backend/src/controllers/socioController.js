const bcrypt = require('bcrypt');
const supabase = require('../config/supabase');

/**
 * 1. OBTENER SOCIOS (Con paginación, filtros y búsqueda por Nombre, Apellido, DNI o Teléfono)
 * GET /api/socios?page=1&limit=6&estado=activo&search=Juan
 */
const getSocios = async (req, res) => {
  try {
    const idGimnasio = req.usuario?.id_gimnasio;

    if (!idGimnasio) {
      return res.status(400).json({ error: 'No se identificó el gimnasio autenticado.' });
    }

    const { estado, search, limit, page } = req.query;

    let query = supabase
      .from('socio')
      .select(`
        *,
        membresia (
          *,
          plan_membresia (*)
        )
      `, { count: 'exact' })
      .eq('id_gimnasio', idGimnasio);

    // Filtro por estado
    if (estado && estado !== 'todos') {
      query = query.eq('estado', estado);
    }

    // Búsqueda por Nombre, Apellido, DNI o Teléfono
    if (search) {
      const cleanSearch = search.trim();
      query = query.or(`nombre.ilike.%${cleanSearch}%,apellido.ilike.%${cleanSearch}%,dni.ilike.%${cleanSearch}%,telefono.ilike.%${cleanSearch}%`);
    }

    // Paginación condicional: solo paginar si limit NO es 'all' o '0'
    const isAll = limit === 'all' || limit === '0';
    let parsedLimit = parseInt(limit) || 6;
    let parsedPage = parseInt(page) || 1;

    if (!isAll) {
      const offset = (parsedPage - 1) * parsedLimit;
      query = query.range(offset, offset + parsedLimit - 1);
    }

    const { data: socios, error, count } = await query.order('id_socio', { ascending: false });

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
    const idGimnasio = req.usuario?.id_gimnasio;

    let query = supabase
      .from('socio')
      .select(`
        *,
        gimnasio (*),
        membresia (
          *,
          plan_membresia (*)
        ),
        asistencia (*),
        progreso (*)
      `)
      .eq('id_socio', id);

    if (idGimnasio && req.usuario?.rol !== 'socio') {
      query = query.eq('id_gimnasio', idGimnasio);
    }

    const { data: socio, error } = await query.maybeSingle();

    if (error) {
      return res.status(500).json({ error: 'Error al obtener el socio: ' + error.message });
    }

    if (!socio) {
      return res.status(404).json({ error: 'Socio no encontrado o no pertenece a tu gimnasio.' });
    }

    if (socio.contrasena) {
      delete socio.contrasena;
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
    const idGimnasio = req.usuario?.id_gimnasio;
    const { 
      nombre, 
      apellido, 
      dni, 
      telefono, 
      email,
      contrasena,
      password,
      plan, 
      precio, 
      estado, 
      fecha_vencimiento,
      id_plan_membresia
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

    // Hash de contraseña si se proporcionó
    const rawPass = (contrasena || password)?.toString().trim();
    let contrasenaHash = null;
    if (rawPass) {
      contrasenaHash = await bcrypt.hash(rawPass, 10);
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

    // Crear la ficha de socio directamente
    const { data: nuevoSocio, error: errorSocio } = await supabase
      .from('socio')
      .insert([
        {
          id_gimnasio: idGimnasio,
          nombre: nombre.trim(),
          apellido: apellido ? apellido.trim() : '',
          dni: dni.toString().trim(),
          telefono: telefono ? telefono.trim() : null,
          email: email ? email.trim().toLowerCase() : null,
          contrasena: contrasenaHash,
          fecha_alta: new Date().toISOString().split('T')[0],
          estado: estado || 'activo'
        }
      ])
      .select()
      .single();

    if (errorSocio) {
      return res.status(500).json({ error: 'Error al crear el socio: ' + errorSocio.message });
    }

    // Registrar membresía (Plan y Fecha de Vencimiento) si se especificó
    let membresia = null;
    if (plan || id_plan_membresia || fecha_vencimiento) {
      let planId = id_plan_membresia;
      let planDuracion = 30;
      let planPrecio = precio;

      if (!planId && plan) {
        const { data: pData } = await supabase
          .from('plan_membresia')
          .select('id_plan_membresia, duracion_dias, precio')
          .ilike('nombre', `%${plan}%`)
          .eq('id_gimnasio', idGimnasio)
          .limit(1)
          .maybeSingle();
        if (pData) {
          planId = pData.id_plan_membresia;
          planDuracion = pData.duracion_dias || 30;
          if (!planPrecio && pData.precio) planPrecio = pData.precio;
        }
      }

      if (!planId) {
        const { data: pDef } = await supabase
          .from('plan_membresia')
          .select('id_plan_membresia, duracion_dias, precio')
          .eq('id_gimnasio', idGimnasio)
          .limit(1)
          .maybeSingle();
        if (pDef) {
          planId = pDef.id_plan_membresia;
          planDuracion = pDef.duracion_dias || 30;
          if (!planPrecio && pDef.precio) planPrecio = pDef.precio;
        }
      }

      const membData = {
        id_socio: nuevoSocio.id_socio,
        precio: planPrecio || 0,
        fecha_inicio: new Date().toISOString().split('T')[0],
        fecha_vencimiento: fecha_vencimiento || new Date(Date.now() + planDuracion * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
        estado: estado || 'activo'
      };
      if (planId) {
        membData.id_plan_membresia = planId;
      }

      const { data: nuevaMembresia, error: errorMembresia } = await supabase
        .from('membresia')
        .insert([membData])
        .select('*, plan_membresia(*)')
        .single();

      if (!errorMembresia) {
        membresia = nuevaMembresia;
      }
    }

    return res.status(201).json({
      mensaje: 'Socio registrado exitosamente.',
      socio: {
        ...nuevoSocio,
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
    const idGimnasio = req.usuario?.id_gimnasio;
    const { nombre, apellido, dni, telefono, email, estado, id_plan_membresia, plan, contrasena, password } = req.body;

    // Verificar pertenencia al gimnasio
    let query = supabase
      .from('socio')
      .select('id_socio, id_gimnasio')
      .eq('id_socio', id);

    if (idGimnasio) {
      query = query.eq('id_gimnasio', idGimnasio);
    }

    const { data: socioActual } = await query.maybeSingle();

    if (!socioActual) {
      return res.status(404).json({ error: 'Socio no encontrado o sin permisos.' });
    }

    // Hash de nueva contraseña si se envió
    const rawPass = (contrasena || password)?.toString().trim();
    let contrasenaHash = undefined;
    if (rawPass) {
      contrasenaHash = await bcrypt.hash(rawPass, 10);
    }

    // Actualizar datos de la tabla socio directamente
    const updateCampos = {
      ...(nombre && { nombre: nombre.trim() }),
      ...(apellido !== undefined && { apellido: apellido ? apellido.trim() : '' }),
      ...(dni && { dni: dni.toString().trim() }),
      ...(telefono !== undefined && { telefono: telefono ? telefono.trim() : null }),
      ...(email !== undefined && { email: email ? email.trim().toLowerCase() : null }),
      ...(estado && { estado: estado.toLowerCase() }),
      ...(contrasenaHash !== undefined && { contrasena: contrasenaHash })
    };

    const { data: socioActualizado, error: errorUpdate } = await supabase
      .from('socio')
      .update(updateCampos)
      .eq('id_socio', id)
      .select()
      .single();

    if (errorUpdate) {
      return res.status(500).json({ error: 'Error al actualizar socio: ' + errorUpdate.message });
    }

    // Actualizar o crear membresía si se especificó plan
    if (id_plan_membresia || plan) {
      let planId = id_plan_membresia;
      let duracionDias = 30;
      let planPrecio = null;

      if (planId) {
        const { data: pObj } = await supabase
          .from('plan_membresia')
          .select('id_plan_membresia, duracion_dias, precio')
          .eq('id_plan_membresia', planId)
          .maybeSingle();
        if (pObj) {
          duracionDias = pObj.duracion_dias || 30;
          planPrecio = pObj.precio;
        }
      } else if (plan) {
        let pQuery = supabase
          .from('plan_membresia')
          .select('id_plan_membresia, duracion_dias, precio')
          .ilike('nombre', `%${plan}%`);
        if (idGimnasio) pQuery = pQuery.eq('id_gimnasio', idGimnasio);
        const { data: pFound } = await pQuery.limit(1).maybeSingle();
        if (pFound) {
          planId = pFound.id_plan_membresia;
          duracionDias = pFound.duracion_dias || 30;
          planPrecio = pFound.precio;
        }
      }

      // Buscar membresía activa del socio
      const { data: membExistente } = await supabase
        .from('membresia')
        .select('id_membresia')
        .eq('id_socio', id)
        .eq('estado', 'activo')
        .maybeSingle();

      if (membExistente) {
        await supabase
          .from('membresia')
          .update({
            ...(planId && { id_plan_membresia: planId }),
            ...(planPrecio != null && { precio: planPrecio })
          })
          .eq('id_membresia', membExistente.id_membresia);
      } else if (planId) {
        await supabase
          .from('membresia')
          .insert([{
            id_socio: id,
            id_plan_membresia: planId,
            precio: planPrecio || 0,
            fecha_inicio: new Date().toISOString().split('T')[0],
            fecha_vencimiento: new Date(Date.now() + duracionDias * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
            estado: 'activo'
          }]);
      }
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
    const idGimnasio = req.usuario?.id_gimnasio;
    const { estado } = req.body;

    const estadosPermitidos = ['activo', 'pendiente', 'inactivo'];
    if (!estado || !estadosPermitidos.includes(estado.toLowerCase())) {
      return res.status(400).json({ 
        error: 'El estado enviado no es válido. Debe ser: activo, pendiente o inactivo.' 
      });
    }

    const estadoLimpio = estado.toLowerCase();

    let query = supabase
      .from('socio')
      .update({ estado: estadoLimpio })
      .eq('id_socio', id);

    if (idGimnasio) {
      query = query.eq('id_gimnasio', idGimnasio);
    }

    const { data: socioActualizado, error } = await query
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
 * 6. ELIMINAR SOCIO
 * DELETE /api/socios/:id
 */
const deleteSocio = async (req, res) => {
  try {
    const { id } = req.params;
    const idGimnasio = req.usuario?.id_gimnasio;

    let query = supabase
      .from('socio')
      .select('id_socio, id_gimnasio')
      .eq('id_socio', id);

    if (idGimnasio) {
      query = query.eq('id_gimnasio', idGimnasio);
    }

    const { data: socioActual, error: errSocio } = await query.maybeSingle();

    if (errSocio || !socioActual) {
      return res.status(404).json({ error: 'Socio no encontrado o sin permisos.' });
    }

    // 1. Eliminar pagos vinculados a las membresías del socio
    const { data: membresias } = await supabase
      .from('membresia')
      .select('id_membresia')
      .eq('id_socio', id);

    if (membresias && membresias.length > 0) {
      const membIds = membresias.map((m) => m.id_membresia);
      await supabase
        .from('pago')
        .delete()
        .in('id_membresia', membIds);

      await supabase
        .from('membresia')
        .delete()
        .eq('id_socio', id);
    }

    // 2. Eliminar asistencias y progresos si existieran
    await supabase.from('asistencia').delete().eq('id_socio', id);
    await supabase.from('progreso').delete().eq('id_socio', id);

    // 3. Eliminar registro del socio
    const { error: errDelSocio } = await supabase
      .from('socio')
      .delete()
      .eq('id_socio', id);

    if (errDelSocio) throw errDelSocio;

    return res.status(200).json({ mensaje: 'Socio eliminado exitosamente.' });
  } catch (error) {
    return res.status(500).json({ error: 'Error al eliminar socio: ' + error.message });
  }
};

/**
 * 7. OBTENER PERFIL DEL SOCIO
 * GET /api/socios/perfil
 * GET /api/socios/perfil?id=123 (para administradores)
 */
const getPerfilSocio = async (req, res) => {
  try {
    let targetId = req.query.id || req.params.id;

    // 1. Si no se especifica ID por query, verificar si el token pertenece a un socio
    if (!targetId && req.usuario?.id_socio) {
      targetId = req.usuario.id_socio;
    }

    // 2. Si no hay targetId y es un usuario (dueño/admin), buscar si tiene ficha de socio con el mismo email
    if (!targetId && req.usuario?.id_usuario) {
      const { data: sVinculado } = await supabase
        .from('socio')
        .select('id_socio')
        .ilike('email', req.usuario.email || '')
        .eq('id_gimnasio', req.usuario.id_gimnasio || 0)
        .maybeSingle();

      if (sVinculado) {
        targetId = sVinculado.id_socio;
      }
    }

    // 3. Si aún no hay targetId y es un dueño/admin, tomar el socio más reciente del gimnasio
    if (!targetId && req.usuario?.id_gimnasio) {
      const { data: sReciente } = await supabase
        .from('socio')
        .select('id_socio')
        .eq('id_gimnasio', req.usuario.id_gimnasio)
        .order('id_socio', { ascending: false })
        .limit(1)
        .maybeSingle();

      if (sReciente) {
        targetId = sReciente.id_socio;
      }
    }

    // 4. Si aún no hay ningún socio registrado en el gimnasio pero es dueño, retornar datos del dueño y su gimnasio
    if (!targetId && req.usuario?.id_usuario) {
      const { data: userProfile } = await supabase
        .from('usuario')
        .select('id_usuario, nombre, apellido, email, rol, estado, fecha_creacion')
        .eq('id_usuario', req.usuario.id_usuario)
        .maybeSingle();

      let gymData = null;
      if (req.usuario?.id_gimnasio) {
        const { data: g } = await supabase
          .from('gimnasio')
          .select('*')
          .eq('id_gimnasio', req.usuario.id_gimnasio)
          .maybeSingle();
        gymData = g;
      }

      return res.status(200).json({
        tipo: 'usuario',
        socio: {
          id_socio: null,
          nombre: userProfile?.nombre || 'Administrador',
          apellido: userProfile?.apellido || '',
          dni: '',
          telefono: '',
          email: userProfile?.email || '',
          fecha_alta: userProfile?.fecha_creacion?.split('T')[0] || '',
          estado: userProfile?.estado || 'activo'
        },
        gimnasio: gymData,
        membresia: null,
        historialMembresias: [],
        ultimosPagos: [],
        ultimasAsistencias: [],
        estadisticas: {
          totalAsistencias: 0,
          totalPagos: 0,
          estadoMembresia: 'dueño',
          diasRestantes: null
        },
        sociosDisponibles: []
      });
    }

    if (!targetId) {
      return res.status(400).json({ error: 'No se pudo identificar el socio a consultar.' });
    }

    // Permisos: Si quien consulta tiene rol de socio, sólo puede ver su propio perfil
    if (req.usuario?.rol === 'socio' && parseInt(req.usuario.id_socio) !== parseInt(targetId)) {
      return res.status(403).json({ error: 'No tienes permisos para visualizar el perfil de otro socio.' });
    }

    // Consultar el socio completo en la tabla socio
    let query = supabase
      .from('socio')
      .select(`
        id_socio,
        id_gimnasio,
        dni,
        telefono,
        fecha_alta,
        estado,
        nombre,
        apellido,
        email,
        gimnasio (
          id_gimnasio,
          nombre,
          direccion,
          telefono,
          email
        ),
        membresia (
          id_membresia,
          fecha_inicio,
          fecha_vencimiento,
          estado,
          precio,
          id_plan_membresia,
          plan_membresia (
            id_plan_membresia,
            nombre,
            duracion_dias,
            precio
          )
        ),
        asistencia (
          id_asistencia,
          hora_ingreso,
          hora_salida,
          estado
        )
      `)
      .eq('id_socio', targetId);

    // Si es administrador o dueño, validar que el socio pertenezca a su gimnasio
    if (req.usuario?.id_gimnasio && req.usuario?.rol !== 'socio') {
      query = query.eq('id_gimnasio', req.usuario.id_gimnasio);
    }

    const { data: socio, error } = await query.maybeSingle();

    if (error) {
      return res.status(500).json({ error: 'Error al consultar perfil del socio: ' + error.message });
    }

    if (!socio) {
      return res.status(404).json({ error: 'Perfil de socio no encontrado o no pertenece a tu gimnasio.' });
    }

    // Normalizar membresías: puede venir como objeto o array
    const membresiasLista = Array.isArray(socio.membresia)
      ? socio.membresia
      : (socio.membresia ? [socio.membresia] : []);

    // Consultar los últimos pagos vinculados a las membresías del socio
    let ultimosPagos = [];
    if (membresiasLista.length > 0) {
      const membIds = membresiasLista.map((m) => m.id_membresia).filter(Boolean);
      if (membIds.length > 0) {
        const { data: pagosData } = await supabase
          .from('pago')
          .select('id_pago, monto, fecha_pago, metodo_pago, estado, id_membresia')
          .in('id_membresia', membIds)
          .order('fecha_pago', { ascending: false })
          .limit(5);

        ultimosPagos = pagosData || [];
      }
    }

    // Identificar membresía activa o la más reciente
    const membresiaActiva = membresiasLista.find((m) => m.estado === 'activo')
      || membresiasLista[0]
      || null;

    // Normalizar asistencias y ordenar por hora_ingreso
    const asistenciasLista = Array.isArray(socio.asistencia)
      ? socio.asistencia
      : (socio.asistencia ? [socio.asistencia] : []);

    const asistenciasOrdenadas = asistenciasLista.sort((a, b) => {
      const dateA = a.hora_ingreso ? new Date(a.hora_ingreso) : new Date(0);
      const dateB = b.hora_ingreso ? new Date(b.hora_ingreso) : new Date(0);
      return dateB - dateA;
    });

    const totalAsistencias = asistenciasOrdenadas.length;
    const ultimasAsistencias = asistenciasOrdenadas.slice(0, 5);

    // Calcular días restantes de membresía si existe
    let diasRestantes = null;
    if (membresiaActiva && membresiaActiva.fecha_vencimiento) {
      const diffTime = new Date(membresiaActiva.fecha_vencimiento) - new Date();
      diasRestantes = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    }

    // Si quien consulta es dueño/admin, incluir lista de socios del gimnasio
    let sociosDelGimnasio = [];
    if (req.usuario?.rol !== 'socio' && req.usuario?.id_gimnasio) {
      const { data: sociosList } = await supabase
        .from('socio')
        .select('id_socio, nombre, apellido, dni, estado')
        .eq('id_gimnasio', req.usuario.id_gimnasio)
        .order('id_socio', { ascending: true });
      sociosDelGimnasio = sociosList || [];
    }

    return res.status(200).json({
      tipo: 'socio',
      socio: {
        id_socio: socio.id_socio,
        id_gimnasio: socio.id_gimnasio,
        dni: socio.dni,
        telefono: socio.telefono,
        fecha_alta: socio.fecha_alta,
        estado: socio.estado,
        nombre: socio.nombre,
        apellido: socio.apellido,
        email: socio.email
      },
      gimnasio: socio.gimnasio || null,
      membresia: membresiaActiva,
      historialMembresias: membresiasLista,
      ultimosPagos,
      ultimasAsistencias,
      estadisticas: {
        totalAsistencias,
        totalPagos: ultimosPagos.length,
        estadoMembresia: membresiaActiva ? membresiaActiva.estado : 'sin_membresia',
        diasRestantes
      },
      sociosDisponibles: sociosDelGimnasio
    });

  } catch (error) {
    return res.status(500).json({ error: 'Error interno del servidor al consultar perfil: ' + error.message });
  }
};

/**
 * 8. ACTUALIZAR PERFIL DEL SOCIO
 * PUT /api/socios/perfil
 */
const updatePerfilSocio = async (req, res) => {
  try {
    let targetId = req.body.id_socio || req.query.id;

    // Si no viene en el body o query, tomar id_socio del token
    if (!targetId && req.usuario?.id_socio) {
      targetId = req.usuario.id_socio;
    }

    // Si es socio autenticado, verificar que solo modifique su perfil
    if (req.usuario?.rol === 'socio') {
      if (!targetId || parseInt(req.usuario.id_socio) !== parseInt(targetId)) {
        return res.status(403).json({ error: 'No tienes autorización para modificar otro perfil.' });
      }
    }

    if (!targetId) {
      return res.status(400).json({ error: 'No se especificó el ID del socio a actualizar.' });
    }

    const {
      nombre,
      apellido,
      telefono,
      email,
      dni,
      contrasena_actual,
      nueva_contrasena,
      contrasena,
      password
    } = req.body;

    // 1. Buscar socio actual en la base de datos
    const { data: socioActual, error: errFetch } = await supabase
      .from('socio')
      .select('*')
      .eq('id_socio', targetId)
      .maybeSingle();

    if (errFetch || !socioActual) {
      return res.status(404).json({ error: 'Socio no encontrado.' });
    }

    // Si es administrador/dueño, validar pertenencia al gimnasio
    if (req.usuario?.id_gimnasio && req.usuario?.rol !== 'socio') {
      if (socioActual.id_gimnasio !== req.usuario.id_gimnasio) {
        return res.status(403).json({ error: 'El socio no pertenece a tu gimnasio.' });
      }
    }

    // 2. Gestión de cambio de contraseña
    const newPass = nueva_contrasena || contrasena || password;
    let nuevoHash = undefined;

    if (newPass && newPass.toString().trim()) {
      const passLimpia = newPass.toString().trim();
      if (passLimpia.length < 6) {
        return res.status(400).json({ error: 'La nueva contraseña debe tener al menos 6 caracteres.' });
      }

      // Si quien actualiza es el socio, requerir confirmación con contraseña actual
      if (req.usuario?.rol === 'socio') {
        if (!contrasena_actual) {
          return res.status(400).json({ error: 'Debes proporcionar tu contraseña actual para autorizar el cambio.' });
        }

        let passValida = false;
        if (socioActual.contrasena) {
          try {
            passValida = await bcrypt.compare(contrasena_actual, socioActual.contrasena);
          } catch {
            passValida = false;
          }
          if (!passValida && contrasena_actual === socioActual.contrasena) {
            passValida = true;
          }
        }

        if (!passValida) {
          return res.status(400).json({ error: 'La contraseña actual ingresada es incorrecta.' });
        }
      }

      nuevoHash = await bcrypt.hash(passLimpia, 10);
    }

    // 3. Validación de DNI único dentro del mismo gimnasio (si cambia)
    if (dni && dni.toString().trim() !== socioActual.dni) {
      const { data: dniExistente } = await supabase
        .from('socio')
        .select('id_socio')
        .eq('dni', dni.toString().trim())
        .eq('id_gimnasio', socioActual.id_gimnasio)
        .neq('id_socio', targetId)
        .maybeSingle();

      if (dniExistente) {
        return res.status(400).json({ error: 'El DNI ingresado ya está asignado a otro socio en este gimnasio.' });
      }
    }

    // 4. Preparar payload de actualización
    const updateCampos = {
      ...(nombre && { nombre: nombre.trim() }),
      ...(apellido !== undefined && { apellido: apellido ? apellido.trim() : '' }),
      ...(telefono !== undefined && { telefono: telefono ? telefono.trim() : null }),
      ...(email !== undefined && { email: email ? email.trim().toLowerCase() : null }),
      ...(dni && { dni: dni.toString().trim() }),
      ...(nuevoHash !== undefined && { contrasena: nuevoHash })
    };

    const { data: socioActualizado, error: errUpdate } = await supabase
      .from('socio')
      .update(updateCampos)
      .eq('id_socio', targetId)
      .select('id_socio, id_gimnasio, dni, telefono, fecha_alta, estado, nombre, apellido, email')
      .single();

    if (errUpdate) {
      return res.status(500).json({ error: 'Error al actualizar el perfil: ' + errUpdate.message });
    }

    return res.status(200).json({
      mensaje: 'Perfil actualizado exitosamente.',
      socio: socioActualizado
    });

  } catch (error) {
    return res.status(500).json({ error: 'Error interno del servidor al actualizar perfil: ' + error.message });
  }
};

module.exports = {
  getSocios,
  getSocioById,
  createSocio,
  updateSocio,
  changeEstadoSocio,
  deleteSocio,
  getPerfilSocio,
  updatePerfilSocio
};