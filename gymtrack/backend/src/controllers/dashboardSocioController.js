const supabase = require('../config/supabase');

/**
 * Helper para resolver el id_socio desde el token
 */
const resolverIdSocio = async (req) => {
  let idSocio = req.usuario?.id_socio;

  if (!idSocio && req.usuario?.id_usuario) {
    const { data: socioAuth, error: socioAuthErr } = await supabase
      .from('socio')
      .select('id_socio')
      .eq('id_usuario', req.usuario.id_usuario)
      .maybeSingle();

    if (!socioAuthErr && socioAuth) {
      idSocio = socioAuth.id_socio;
    }
  }

  return idSocio;
};

/**
 * GET /api/socio/dashboard
 * Retorna la información completa para el Dashboard del Socio autenticado optimizado para PC / Desktop.
 */
const getDashboardSocio = async (req, res) => {
  try {
    const idSocio = await resolverIdSocio(req);

    if (!idSocio) {
      return res.status(401).json({ error: 'Usuario no autenticado como socio o perfil no encontrado.' });
    }

    // Calcular inicio de mes actual para asistencias mensuales
    const inicioMes = new Date();
    inicioMes.setDate(1);
    inicioMes.setHours(0, 0, 0, 0);

    // Consulta paralela de datos para máxima velocidad
    const [
      socioRes,
      membresiaRes,
      ultimoPagoRes,
      progresoRes,
      progresoHistorialRes,
      asistenciasTotalRes,
      asistenciasMesRes,
      asistenciasRecientesRes,
      rutinaRes
    ] = await Promise.all([
      // a. Datos del socio y de su gimnasio
      supabase
        .from('socio')
        .select(`
          id_socio,
          nombre,
          apellido,
          dni,
          email,
          telefono,
          id_gimnasio,
          gimnasio:id_gimnasio (
            id_gimnasio,
            nombre,
            direccion,
            telefono
          )
        `)
        .eq('id_socio', idSocio)
        .single(),

      // b. Membresías del socio (para resolver membresía activa vigente)
      supabase
        .from('membresia')
        .select(`
          id_membresia,
          fecha_inicio,
          fecha_vencimiento,
          estado,
          precio,
          plan_membresia (
            id_plan_membresia,
            nombre,
            descripcion,
            precio,
            duracion_dias,
            estado
          )
        `)
        .eq('id_socio', idSocio)
        .order('fecha_vencimiento', { ascending: false }),

      // c. Último pago realizado
      supabase
        .from('pago')
        .select(`
          id_pago,
          monto,
          fecha_pago,
          metodo_pago,
          estado,
          comprobante,
          referencia_pago,
          membresia!inner (
            id_socio
          )
        `)
        .eq('membresia.id_socio', idSocio)
        .order('fecha_pago', { ascending: false })
        .limit(1)
        .maybeSingle(),

      // d. Último registro de progreso (Peso actual)
      supabase
        .from('progreso')
        .select('id_progreso, peso, fecha, observaciones')
        .eq('id_socio', idSocio)
        .order('fecha', { ascending: false })
        .limit(1)
        .maybeSingle(),

      // d.2. Historial de progreso reciente (para evolución y gráfica)
      supabase
        .from('progreso')
        .select('id_progreso, peso, fecha, observaciones')
        .eq('id_socio', idSocio)
        .order('fecha', { ascending: false })
        .limit(6),

      // e.1 Total histórico de asistencias
      supabase
        .from('asistencia')
        .select('id_asistencia', { count: 'exact', head: true })
        .eq('id_socio', idSocio),

      // e.2 Asistencias del mes actual
      supabase
        .from('asistencia')
        .select('id_asistencia', { count: 'exact', head: true })
        .eq('id_socio', idSocio)
        .gte('hora_ingreso', inicioMes.toISOString()),

      // e.3 Asistencias recientes con fecha y hora
      supabase
        .from('asistencia')
        .select('id_asistencia, hora_ingreso, hora_salida, estado')
        .eq('id_socio', idSocio)
        .order('hora_ingreso', { ascending: false })
        .limit(14),

      // f. Rutina activa con detalle de ejercicios
      supabase
        .from('rutina')
        .select(`
          id_rutina,
          nombre,
          descripcion,
          estado,
          fecha_creacion,
          rutina_ejercicio (
            id_rutina_ejercicio,
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
        .eq('id_socio', idSocio)
        .eq('estado', 'activa')
        .order('id_rutina', { ascending: false })
        .limit(1)
        .maybeSingle()
    ]);

    // Validar error en datos de socio
    if (socioRes.error || !socioRes.data) {
      return res.status(404).json({ error: 'No se encontraron datos del socio en el sistema.' });
    }

    const socio = socioRes.data;

    // Filtrar para encontrar la membresía activa vigente (excluyendo pausadas, canceladas o inactivas)
    const ESTADOS_EXCLUIDOS = ['inactivo', 'inactiva', 'pausa', 'pausado', 'pausada', 'cancelado', 'cancelada', 'eliminado', 'eliminada', 'sin_membresia'];
    const rawMembresias = membresiaRes.data ? (Array.isArray(membresiaRes.data) ? membresiaRes.data : [membresiaRes.data]) : [];
    
    const membresia = rawMembresias.find(m => {
      const estMemb = (m.estado || '').toLowerCase().trim();
      const estPlan = (m.plan_membresia?.estado || '').toLowerCase().trim();
      return estMemb && !ESTADOS_EXCLUIDOS.includes(estMemb) && (!m.plan_membresia || !ESTADOS_EXCLUIDOS.includes(estPlan));
    }) || null;

    const ultimoPago = ultimoPagoRes.data || null;
    const ultimoProgreso = progresoRes.data || null;
    const historialProgreso = progresoHistorialRes.data || [];
    const totalAsistencias = asistenciasTotalRes.count || 0;
    const asistenciasMes = asistenciasMesRes.count || 0;
    const asistenciasRecientes = asistenciasRecientesRes.data || [];
    const rutinaActiva = rutinaRes.data || null;

    // Calcular días restantes y porcentaje de membresía
    let diasRestantes = null;
    let porcentajeTranscurrido = null;
    let membresiaExpirada = false;

    if (membresia?.fecha_vencimiento) {
      const hoy = new Date();
      hoy.setHours(0, 0, 0, 0);
      const fin = new Date(membresia.fecha_vencimiento);
      fin.setHours(0, 0, 0, 0);

      const diffTime = fin.getTime() - hoy.getTime();
      diasRestantes = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
      membresiaExpirada = diasRestantes < 0;

      if (membresia.fecha_inicio) {
        const inicio = new Date(membresia.fecha_inicio);
        const totalDias = Math.max(1, Math.ceil((fin - inicio) / (1000 * 60 * 60 * 24)));
        const diasUsados = Math.max(0, Math.ceil((hoy - inicio) / (1000 * 60 * 60 * 24)));
        porcentajeTranscurrido = Math.min(100, Math.max(0, Math.round((diasUsados / totalDias) * 100)));
      }
    }

    // Calcular variación de peso respecto al registro anterior
    let variacionPeso = null;
    if (historialProgreso.length >= 2) {
      const actual = Number(historialProgreso[0].peso);
      const previo = Number(historialProgreso[1].peso);
      if (!isNaN(actual) && !isNaN(previo)) {
        variacionPeso = Number((actual - previo).toFixed(1));
      }
    }

    // Ordenar ejercicios de la rutina por el campo orden
    let ejerciciosOrdenados = [];
    if (rutinaActiva?.rutina_ejercicio && Array.isArray(rutinaActiva.rutina_ejercicio)) {
      ejerciciosOrdenados = [...rutinaActiva.rutina_ejercicio].sort((a, b) => (a.orden || 0) - (b.orden || 0));
    }

    return res.status(200).json({
      socio: {
        id_socio: socio.id_socio,
        nombre: socio.nombre,
        apellido: socio.apellido,
        dni: socio.dni,
        email: socio.email,
        telefono: socio.telefono
      },
      gimnasio: socio.gimnasio || {
        nombre: 'GymTrack Fitness Club',
        direccion: 'Av. Central 1234',
        telefono: '+54 11 5555-8888'
      },
      membresia: membresia ? {
        id_membresia: membresia.id_membresia,
        plan: membresia.plan_membresia?.nombre || 'Plan Personalizado',
        descripcion_plan: membresia.plan_membresia?.descripcion || '',
        estado: membresia.estado,
        fecha_inicio: membresia.fecha_inicio,
        fecha_vencimiento: membresia.fecha_vencimiento,
        precio: membresia.precio || membresia.plan_membresia?.precio || 0,
        dias_restantes: diasRestantes,
        porcentaje_transcurrido: porcentajeTranscurrido,
        expirada: membresiaExpirada
      } : {
        id_membresia: null,
        estado: 'sin_membresia',
        plan: 'Sin Membresía Activa',
        mensaje: 'No tienes una membresía activa asignada actualmente.',
        dias_restantes: 0,
        porcentaje_transcurrido: 0,
        expirada: true
      },
      ultimo_pago: ultimoPago ? {
        id_pago: ultimoPago.id_pago,
        monto: ultimoPago.monto,
        fecha_pago: ultimoPago.fecha_pago,
        metodo_pago: ultimoPago.metodo_pago,
        estado: ultimoPago.estado,
        comprobante: ultimoPago.comprobante
      } : null,
      progreso: {
        peso_actual: ultimoProgreso?.peso || null,
        observaciones: ultimoProgreso?.observaciones || null,
        fecha_ultimo_registro: ultimoProgreso?.fecha || null,
        variacion_mes: variacionPeso,
        historial: historialProgreso
      },
      entrenamientos: {
        total_asistencias: totalAsistencias,
        asistencias_mes: asistenciasMes,
        recientes: asistenciasRecientes
      },
      rutina_activa: rutinaActiva ? {
        id_rutina: rutinaActiva.id_rutina,
        nombre: rutinaActiva.nombre,
        descripcion: rutinaActiva.descripcion,
        ejercicios: ejerciciosOrdenados
      } : null,
      acciones_rapidas: [
        { clave: 'ver_rutina', titulo: 'Mi Rutina', activo: !!rutinaActiva, link: '/rutinas' },
        { clave: 'mi_membresia', titulo: 'Membresía', activo: true, link: '/socio/membresia' },
        { clave: 'asistencias', titulo: 'Asistencias', activo: true, link: '/asistencias' },
        { clave: 'ejercicios', titulo: 'Ejercicios', activo: true, link: '/ejercicios' },
        { clave: 'perfil', titulo: 'Mi Perfil', activo: true, link: '/perfil' }
      ]
    });

  } catch (error) {
    console.error('Error en getDashboardSocio:', error);
    return res.status(500).json({ error: 'Error interno del servidor al cargar el dashboard: ' + error.message });
  }
};

/**
 * POST /api/socio/checkin
 * Permite al socio marcar su asistencia directamente desde su panel
 */
const registrarCheckinSocio = async (req, res) => {
  try {
    const idSocio = await resolverIdSocio(req);
    if (!idSocio) {
      return res.status(401).json({ error: 'Usuario no autenticado como socio.' });
    }

    const horaIngreso = new Date().toISOString();

    const { data, error } = await supabase
      .from('asistencia')
      .insert([
        {
          id_socio: idSocio,
          hora_ingreso: horaIngreso,
          estado: 'presente'
        }
      ])
      .select()
      .single();

    if (error) {
      return res.status(500).json({ error: 'Error al registrar el check-in: ' + error.message });
    }

    return res.status(201).json({
      mensaje: '¡Asistencia registrada con éxito! Que tengas un gran entrenamiento 💪',
      asistencia: data
    });
  } catch (error) {
    return res.status(500).json({ error: 'Error interno al registrar check-in: ' + error.message });
  }
};

/**
 * POST /api/socio/progreso
 * Permite al socio cargar su peso actual y notas desde su panel
 */
const registrarProgresoSocio = async (req, res) => {
  try {
    const idSocio = await resolverIdSocio(req);
    if (!idSocio) {
      return res.status(401).json({ error: 'Usuario no autenticado como socio.' });
    }

    const { peso, observaciones, fecha } = req.body;

    if (!peso || isNaN(peso) || Number(peso) <= 0) {
      return res.status(400).json({ error: 'Debes ingresar un valor de peso válido en kg.' });
    }

    const fechaRegistro = fecha || new Date().toISOString().split('T')[0];

    const { data, error } = await supabase
      .from('progreso')
      .insert([
        {
          id_socio: idSocio,
          peso: Number(peso),
          fecha: fechaRegistro,
          observaciones: observaciones || null
        }
      ])
      .select()
      .single();

    if (error) {
      return res.status(500).json({ error: 'Error al registrar el progreso: ' + error.message });
    }

    return res.status(201).json({
      mensaje: '¡Peso registrado exitosamente!',
      progreso: data
    });
  } catch (error) {
    return res.status(500).json({ error: 'Error interno al registrar progreso: ' + error.message });
  }
};

module.exports = {
  getDashboardSocio,
  registrarCheckinSocio,
  registrarProgresoSocio
};