// ==============================================================================
// CONTROLADOR DE GESTIÓN DE MEMBRESÍA DEL SOCIO (GYMTRACK)
// ==============================================================================

const supabase = require('../config/supabase');
const {
  crearPreferenciaMercadoPago,
  crearOrdenUala
} = require('../services/paymentGatewayService');

// Nombres de meses en español para formateo visual idéntico a la UI
const MESES_ES = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

/**
 * Formatea una fecha 'YYYY-MM-DD' o ISO a formato amigable: '15 Dic 2025'
 */
function formatearFechaEspanol(fechaStr) {
  if (!fechaStr) return 'Sin fecha';
  try {
    const raw = String(fechaStr).split('T')[0];
    const parts = raw.split('-');
    if (parts.length === 3) {
      const anio = parts[0];
      const mesIndex = parseInt(parts[1], 10) - 1;
      const dia = parseInt(parts[2], 10);
      return `${dia} ${MESES_ES[mesIndex] || parts[1]} ${anio}`;
    }
    const d = new Date(fechaStr);
    if (!isNaN(d.getTime())) {
      return `${d.getDate()} ${MESES_ES[d.getMonth()]} ${d.getFullYear()}`;
    }
  } catch {
    // fallback
  }
  return fechaStr;
}

/**
 * Formatea un número a moneda argentina, ej: 12500 -> "$12.500"
 */
function formatearPrecioARS(monto) {
  if (monto === null || monto === undefined || isNaN(monto)) return '$0';
  return `$${Number(monto).toLocaleString('es-AR')}`;
}

// Estados que representan que una membresía o plan está dado de baja, pausado o inactivo
const ESTADOS_MEMBRESIA_INACTIVOS = [
  'inactivo',
  'inactiva',
  'pausa',
  'pausado',
  'pausada',
  'cancelado',
  'cancelada',
  'eliminado',
  'eliminada',
  'sin_membresia'
];

/**
 * Calcula métricas detalladas de vigencia, días restantes y progreso de membresía
 */
function calcularMetricasMembresia(membresia) {
  if (!membresia || !membresia.fecha_vencimiento) {
    return {
      tiene_membresia: false,
      estado_clave: 'sin_membresia',
      estado_etiqueta: 'Sin Membresía',
      dias_restantes: 0,
      tiempo_restante_texto: '0 días',
      porcentaje_transcurrido: 0,
      esta_vencida: true,
      fecha_inicio_formateada: '-',
      fecha_vencimiento_formateada: '-'
    };
  }

  const estadoClaveRaw = (membresia.estado || 'activo').toLowerCase().trim();
  const estadoPlanRaw = (membresia.plan_membresia?.estado || '').toLowerCase().trim();

  // Si la membresía o su plan asociado fueron pausados, cancelados o dejados inactivos
  if (ESTADOS_MEMBRESIA_INACTIVOS.includes(estadoClaveRaw) || (estadoPlanRaw && ESTADOS_MEMBRESIA_INACTIVOS.includes(estadoPlanRaw))) {
    return {
      tiene_membresia: false,
      estado_clave: 'sin_membresia',
      estado_etiqueta: 'Sin Membresía',
      dias_restantes: 0,
      tiempo_restante_texto: '0 días',
      porcentaje_transcurrido: 0,
      esta_vencida: true,
      fecha_inicio_formateada: '-',
      fecha_vencimiento_formateada: '-'
    };
  }

  const hoy = new Date();
  hoy.setHours(0, 0, 0, 0);

  const fVenc = new Date(String(membresia.fecha_vencimiento).split('T')[0] + 'T00:00:00');
  const fIni = membresia.fecha_inicio 
    ? new Date(String(membresia.fecha_inicio).split('T')[0] + 'T00:00:00')
    : new Date(fVenc.getTime() - 30 * 24 * 60 * 60 * 1000);

  const diffMs = fVenc.getTime() - hoy.getTime();
  const diasRestantes = Math.ceil(diffMs / (1000 * 60 * 60 * 24));

  // Duración total y cálculo de porcentaje transcurrido
  const duracionTotalMs = Math.max(1, fVenc.getTime() - fIni.getTime());
  const transcurridoMs = Math.max(0, hoy.getTime() - fIni.getTime());
  let porcentajeTranscurrido = Math.min(100, Math.max(0, Math.round((transcurridoMs / duracionTotalMs) * 100)));

  const estaVencida = diasRestantes < 0;
  let tiempoRestanteTexto = `${diasRestantes} días`;
  if (diasRestantes === 0) {
    tiempoRestanteTexto = 'Vence hoy';
  } else if (diasRestantes < 0) {
    tiempoRestanteTexto = `Vencida hace ${Math.abs(diasRestantes)} días`;
    porcentajeTranscurrido = 100;
  }

  let estadoClave = estadoClaveRaw;
  let estadoEtiqueta = 'Activa';

  if (estaVencida || estadoClave === 'vencido' || estadoClave === 'vencida') {
    estadoClave = 'vencida';
    estadoEtiqueta = 'Vencida';
  } else if (estadoClave === 'pendiente') {
    estadoEtiqueta = 'Pendiente de Pago';
  } else if (estadoClave === 'activo' || estadoClave === 'activa') {
    estadoClave = 'activa';
    estadoEtiqueta = 'Activa';
  }

  return {
    tiene_membresia: true,
    estado_clave: estadoClave,
    estado_etiqueta: estadoEtiqueta,
    dias_restantes: Math.max(0, diasRestantes),
    dias_reales: diasRestantes,
    tiempo_restante_texto: tiempoRestanteTexto,
    porcentaje_transcurrido: porcentajeTranscurrido,
    esta_vencida: estaVencida,
    fecha_inicio_formateada: formatearFechaEspanol(membresia.fecha_inicio),
    fecha_vencimiento_formateada: formatearFechaEspanol(membresia.fecha_vencimiento)
  };
}

/**
 * Resuelve el id_socio y valida pertenencia del usuario autenticado
 */
async function obtenerSocioAutenticado(req) {
  let idSocio = req.usuario?.id_socio;

  if (!idSocio && req.usuario?.id_usuario) {
    const { data: socioEncontrado } = await supabase
      .from('socio')
      .select('id_socio, id_gimnasio')
      .eq('id_usuario', req.usuario.id_usuario)
      .maybeSingle();

    if (socioEncontrado) {
      idSocio = socioEncontrado.id_socio;
    }
  }

  if (!idSocio) {
    return null;
  }

  const { data: socio, error } = await supabase
    .from('socio')
    .select('id_socio, id_gimnasio, nombre, apellido, dni, email, telefono, estado, fecha_alta')
    .eq('id_socio', idSocio)
    .maybeSingle();

  if (error || !socio) {
    return null;
  }

  return socio;
}

/**
 * 1. OBTENER INFORMACIÓN COMPLETA DE LA MEMBRESÍA ACTUAL DEL SOCIO
 * GET /api/socio/membresia
 */
const getMiMembresia = async (req, res) => {
  try {
    const socio = await obtenerSocioAutenticado(req);
    if (!socio) {
      return res.status(401).json({ error: 'Acceso no autorizado. No se identificó el perfil de socio.' });
    }

    // 1. Obtener el listado de membresías del socio para buscar la membresía activa vigente
    const { data: listaMembresias, error: membErr } = await supabase
      .from('membresia')
      .select(`
        id_membresia,
        id_socio,
        id_plan_membresia,
        precio,
        fecha_inicio,
        fecha_vencimiento,
        estado,
        plan_membresia (
          id_plan_membresia,
          nombre,
          precio,
          duracion_dias,
          estado
        )
      `)
      .eq('id_socio', socio.id_socio)
      .order('fecha_vencimiento', { ascending: false });

    if (membErr) {
      return res.status(500).json({ error: 'Error al consultar la membresía: ' + membErr.message });
    }

    // Filtrar estrictamente: si la membresía o su plan asociado fueron pausados, cancelados, inactivados o eliminados, NO deben aparecer
    const membresia = (listaMembresias || []).find((m) => {
      const estMemb = (m.estado || '').toLowerCase().trim();
      const estPlan = (m.plan_membresia?.estado || '').toLowerCase().trim();

      const esMembValida = estMemb && !ESTADOS_MEMBRESIA_INACTIVOS.includes(estMemb);
      const esPlanValido = !m.plan_membresia || (!ESTADOS_MEMBRESIA_INACTIVOS.includes(estPlan));

      return esMembValida && esPlanValido;
    }) || null;

    // 2. Obtener datos del gimnasio
    let gimnasio = null;
    if (socio.id_gimnasio) {
      const { data: gymData } = await supabase
        .from('gimnasio')
        .select('id_gimnasio, nombre, direccion, telefono, email')
        .eq('id_gimnasio', socio.id_gimnasio)
        .maybeSingle();
      gimnasio = gymData;
    }

    // 3. Obtener el historial de pagos de este socio
    const { data: pagos, error: pagosErr } = await supabase
      .from('pago')
      .select(`
        id_pago,
        id_membresia,
        monto,
        fecha_pago,
        metodo_pago,
        estado,
        comprobante,
        membresia!inner (
          id_socio,
          id_plan_membresia,
          plan_membresia (
            nombre
          )
        )
      `)
      .eq('membresia.id_socio', socio.id_socio)
      .order('fecha_pago', { ascending: false });

    if (pagosErr) {
      console.warn('Advertencia al consultar pagos del socio:', pagosErr.message);
    }

    // 4. Formatear pagos para la vista
    const historialPagos = (pagos || []).map((pago) => {
      let metodoEtiqueta = 'Tarjeta de Crédito';
      const mNorm = (pago.metodo_pago || '').toLowerCase();
      if (mNorm.includes('mercadopago') || mNorm.includes('mp')) {
        metodoEtiqueta = 'Mercado Pago';
      } else if (mNorm.includes('uala')) {
        metodoEtiqueta = 'Ualá';
      } else if (mNorm.includes('efectivo')) {
        metodoEtiqueta = 'Efectivo';
      } else if (mNorm.includes('transferencia')) {
        metodoEtiqueta = 'Transferencia';
      } else if (mNorm.includes('debito')) {
        metodoEtiqueta = 'Tarjeta de Débito';
      }

      return {
        id_pago: pago.id_pago,
        id_membresia: pago.id_membresia,
        monto: pago.monto,
        monto_formateado: formatearPrecioARS(pago.monto),
        fecha_pago: pago.fecha_pago,
        fecha_formateada: formatearFechaEspanol(pago.fecha_pago),
        metodo_pago: pago.metodo_pago,
        metodo_pago_etiqueta: metodoEtiqueta,
        plan_nombre: pago.membresia?.plan_membresia?.nombre || 'Plan de Membresía',
        categoria: 'Membresía',
        estado: pago.estado || 'pagado',
        estado_etiqueta: (pago.estado || 'pagado').toLowerCase() === 'pagado' ? 'Pagado' : 'Pendiente',
        comprobante: pago.comprobante
      };
    });

    // 5. Calcular métricas temporales de la membresía
    const metricas = calcularMetricasMembresia(membresia);
    const plan = membresia?.plan_membresia || null;
    const precioNumerico = membresia?.precio != null 
      ? Number(membresia.precio) 
      : (plan?.precio != null ? Number(plan.precio) : 0);

    return res.status(200).json({
      socio: {
        id_socio: socio.id_socio,
        id_gimnasio: socio.id_gimnasio,
        nombre: socio.nombre,
        apellido: socio.apellido,
        nombre_completo: `${socio.nombre} ${socio.apellido}`.trim(),
        dni: socio.dni,
        email: socio.email,
        telefono: socio.telefono,
        estado: socio.estado
      },
      gimnasio: gimnasio || {
        id_gimnasio: socio.id_gimnasio,
        nombre: 'GymTrack'
      },
      membresia: (membresia && metricas.tiene_membresia) ? {
        tiene_membresia: true,
        id_membresia: membresia.id_membresia,
        id_plan_membresia: membresia.id_plan_membresia,
        nombre_plan: plan?.nombre || 'Plan Activo',
        precio: precioNumerico,
        precio_formateado: formatearPrecioARS(precioNumerico),
        duracion_dias: plan?.duracion_dias || 30,
        fecha_inicio: membresia.fecha_inicio,
        fecha_vencimiento: membresia.fecha_vencimiento,
        fecha_inicio_formateada: metricas.fecha_inicio_formateada,
        fecha_vencimiento_formateada: metricas.fecha_vencimiento_formateada,
        dias_restantes: metricas.dias_restantes,
        tiempo_restante_texto: metricas.tiempo_restante_texto,
        porcentaje_transcurrido: metricas.porcentaje_transcurrido,
        estado: metricas.estado_clave,
        estado_etiqueta: metricas.estado_etiqueta,
        esta_vencida: metricas.esta_vencida
      } : {
        tiene_membresia: false,
        id_membresia: null,
        id_plan_membresia: null,
        nombre_plan: 'Sin Membresía Activa',
        precio: 0,
        precio_formateado: '$0',
        duracion_dias: 0,
        fecha_inicio: null,
        fecha_vencimiento: null,
        fecha_inicio_formateada: '-',
        fecha_vencimiento_formateada: '-',
        dias_restantes: 0,
        tiempo_restante_texto: '0 días',
        porcentaje_transcurrido: 0,
        estado: 'sin_membresia',
        estado_etiqueta: 'Sin Membresía',
        esta_vencida: true
      },
      historial_pagos: historialPagos
    });

  } catch (error) {
    return res.status(500).json({ error: 'Error interno del servidor al consultar membresía: ' + error.message });
  }
};

/**
 * 2. OBTENER PLANES DISPONIBLES EXCLUSIVOS DEL GIMNASIO DEL SOCIO
 * GET /api/socio/planes-disponibles
 */
const getPlanesDisponibles = async (req, res) => {
  try {
    const socio = await obtenerSocioAutenticado(req);
    if (!socio) {
      return res.status(401).json({ error: 'Acceso no autorizado. Perfil de socio no encontrado.' });
    }

    // 1. Obtener la membresía activa actual para comparar y clasificar planes superiores
    const { data: listaMembresias } = await supabase
      .from('membresia')
      .select('id_membresia, id_plan_membresia, precio, estado, plan_membresia(estado)')
      .eq('id_socio', socio.id_socio)
      .order('fecha_vencimiento', { ascending: false });

    const membActual = (listaMembresias || []).find((m) => {
      const estMemb = (m.estado || '').toLowerCase().trim();
      const estPlan = (m.plan_membresia?.estado || '').toLowerCase().trim();
      return estMemb && !ESTADOS_MEMBRESIA_INACTIVOS.includes(estMemb) && (!m.plan_membresia || !ESTADOS_MEMBRESIA_INACTIVOS.includes(estPlan));
    }) || null;

    const planActualId = membActual?.id_plan_membresia || null;
    const precioActual = Number(membActual?.precio || 0);

    // 2. Consultar únicamente planes de membresía que pertenecen al gimnasio del socio
    let { data: planes, error } = await supabase
      .from('plan_membresia')
      .select('*')
      .eq('id_gimnasio', socio.id_gimnasio)
      .order('precio', { ascending: true });

    if (error) {
      return res.status(500).json({ error: 'Error al consultar planes disponibles: ' + error.message });
    }

    // Solo sembrar si el gimnasio NUNCA ha tenido ningún plan en el catálogo histórico
    if (!planes || planes.length === 0) {
      const { count: totalPlanesHist } = await supabase
        .from('plan_membresia')
        .select('id_plan_membresia', { count: 'exact', head: true })
        .eq('id_gimnasio', socio.id_gimnasio);

      if (!totalPlanesHist || totalPlanesHist === 0) {
        const planesSemilla = [
          { id_gimnasio: socio.id_gimnasio, nombre: 'Plan Básico', precio: 15000, duracion_dias: 30, estado: 'activo' },
          { id_gimnasio: socio.id_gimnasio, nombre: 'Plan Premium', precio: 22000, duracion_dias: 30, estado: 'activo' },
          { id_gimnasio: socio.id_gimnasio, nombre: 'Pase Libre Total', precio: 28000, duracion_dias: 30, estado: 'activo' }
        ];

        const { data: insertados } = await supabase
          .from('plan_membresia')
          .insert(planesSemilla)
          .select('*');

        planes = insertados || planesSemilla;
      }
    }

    // Beneficios sugeridos por nivel de plan para enriquecer la experiencia visual
    const sugerirBeneficios = (nombrePlan) => {
      const n = (nombrePlan || '').toLowerCase();
      if (n.includes('libre') || n.includes('total') || n.includes('vip')) {
        return [
          'Acceso ilimitado todos los días y horarios',
          'Acceso libre a sala de musculación y cardio',
          'Todas las clases grupales incluidas',
          'Plan de entrenamiento personalizado y seguimiento',
          'Acceso a vestuarios y casilleros premium'
        ];
      }
      if (n.includes('premium')) {
        return [
          'Acceso completo de lunes a sábado',
          'Sala de musculación y máquinas guiadas',
          'Hasta 3 clases grupales por semana',
          'Rutina personalizada inicial',
          'Descuentos en suplementos y merchandising'
        ];
      }
      return [
        'Acceso de lunes a viernes',
        'Sala de musculación y peso libre',
        'Evaluación inicial con profesor',
        'App de seguimiento de asistencias'
      ];
    };

    // 3. Estructurar y clasificar planes (EXCLUYENDO estrictamente planes pausados, inactivos, cancelados o eliminados)
    const planesFormateados = (planes || [])
      .filter((plan) => {
        const est = (plan.estado || '').toLowerCase().trim();
        // Solo permitir planes en estado activo que no estén en la lista de estados inactivos
        return (est === 'activo' || est === 'activa' || !est) && !ESTADOS_MEMBRESIA_INACTIVOS.includes(est);
      })
      .map((plan) => {
        const precioNum = Number(plan.precio);
        const esPlanActual = plan.id_plan_membresia === planActualId;
        const esSuperior = !esPlanActual && precioNum > precioActual;
        const diferencia = precioNum - precioActual;

        return {
          id_plan_membresia: plan.id_plan_membresia,
          id_gimnasio: plan.id_gimnasio,
          nombre: plan.nombre,
          precio: precioNum,
          precio_formateado: formatearPrecioARS(precioNum),
          duracion_dias: plan.duracion_dias,
          duracion_texto: `${plan.duracion_dias} días`,
          estado: plan.estado,
          es_plan_actual: esPlanActual,
          es_superior: esSuperior,
          diferencia_precio: diferencia > 0 ? diferencia : 0,
          diferencia_precio_formateada: diferencia > 0 ? formatearPrecioARS(diferencia) : null,
          beneficios: sugerirBeneficios(plan.nombre)
        };
      });

    return res.status(200).json({
      gimnasio_id: socio.id_gimnasio,
      plan_actual_id: planActualId,
      total_planes: planesFormateados.length,
      planes: planesFormateados
    });

  } catch (error) {
    return res.status(500).json({ error: 'Error interno del servidor al obtener planes: ' + error.message });
  }
};

/**
 * 3. SOLICITAR / PREPARAR ACTUALIZACIÓN O CAMBIO DE MEMBRESÍA
 * POST /api/socio/membresia/actualizar
 */
const solicitarActualizacion = async (req, res) => {
  try {
    const socio = await obtenerSocioAutenticado(req);
    if (!socio) {
      return res.status(401).json({ error: 'Acceso no autorizado.' });
    }

    const { id_plan_membresia } = req.body;
    if (!id_plan_membresia) {
      return res.status(400).json({ error: 'Debes indicar el plan de membresía seleccionado.' });
    }

    // Validar que el plan exista, corresponda al gimnasio y esté activo (no pausado/inactivo)
    const { data: plan, error: planErr } = await supabase
      .from('plan_membresia')
      .select('*')
      .eq('id_plan_membresia', id_plan_membresia)
      .eq('id_gimnasio', socio.id_gimnasio)
      .maybeSingle();

    if (planErr || !plan) {
      return res.status(404).json({ error: 'El plan seleccionado no pertenece a tu gimnasio o no existe.' });
    }

    const estadoPlan = (plan.estado || '').toLowerCase().trim();
    if (ESTADOS_MEMBRESIA_INACTIVOS.includes(estadoPlan)) {
      return res.status(400).json({ error: 'Este plan de membresía se encuentra en pausa o inactivo en este momento.' });
    }

    // Obtener membresía actual
    const { data: membActual } = await supabase
      .from('membresia')
      .select('*, plan_membresia(*)')
      .eq('id_socio', socio.id_socio)
      .order('fecha_vencimiento', { ascending: false })
      .limit(1)
      .maybeSingle();

    const hoy = new Date();
    let fechaInicioEstimada = hoy.toISOString().split('T')[0];
    let fechaVencimientoEstimada = new Date(hoy.getTime() + plan.duracion_dias * 24 * 60 * 60 * 1000).toISOString().split('T')[0];

    // Si la membresía actual está vigente y no vencida, se puede extender desde su fecha de vencimiento actual
    if (membActual && membActual.fecha_vencimiento) {
      const vtoDate = new Date(membActual.fecha_vencimiento + 'T00:00:00');
      if (vtoDate > hoy) {
        const nuevaVenc = new Date(vtoDate.getTime() + plan.duracion_dias * 24 * 60 * 60 * 1000);
        fechaInicioEstimada = membActual.fecha_inicio;
        fechaVencimientoEstimada = nuevaVenc.toISOString().split('T')[0];
      }
    }

    return res.status(200).json({
      mensaje: 'Plan preparado para actualización o pago.',
      plan_seleccionado: {
        id_plan_membresia: plan.id_plan_membresia,
        nombre: plan.nombre,
        precio: Number(plan.precio),
        precio_formateado: formatearPrecioARS(plan.precio),
        duracion_dias: plan.duracion_dias
      },
      vigencia_estimada: {
        fecha_inicio: fechaInicioEstimada,
        fecha_vencimiento: fechaVencimientoEstimada,
        fecha_inicio_formateada: formatearFechaEspanol(fechaInicioEstimada),
        fecha_vencimiento_formateada: formatearFechaEspanol(fechaVencimientoEstimada)
      },
      medios_pago_disponibles: ['mercadopago', 'uala', 'tarjeta', 'transferencia']
    });

  } catch (error) {
    return res.status(500).json({ error: 'Error interno del servidor: ' + error.message });
  }
};

/**
 * ==============================================================================
 * ENDPOINT 4: INICIAR PAGO DIGITAL (MERCADO PAGO / UALÁ)
 * POST /api/socio/pagos/iniciar
 * ==============================================================================
 * 
 * GUÍA OPERATIVA DE MERCADO PAGO PARA ESTE ENDPOINT:
 * 1. Autenticación: Identifica al socio desde el token JWT (`req.usuario`).
 * 2. Validación de Plan: Comprueba que el `id_plan_membresia` solicitado pertenezca
 *    estrictamente al gimnasio del alumno (`id_gimnasio`) y no esté pausado/inactivo.
 * 3. Identificador de Correlación (`external_reference`):
 *    - Sintaxis: `GYM-{id_gimnasio}-SOC-{id_socio}-PL-{id_plan}-{timestamp}`.
 *    - Este ID garantiza trazabilidad total y permite al webhook o verificación por polling
 *      saber con certeza a qué socio y plan imputar el pago aprobado.
 * 4. Pasarela de Pago:
 *    - Invoca `crearPreferenciaMercadoPago()` generando el `init_point` oficial o de sandbox.
 *    - Retorna el link de checkout y código QR para que el socio complete la compra.
 */
const iniciarPago = async (req, res) => {
  try {
    const socio = await obtenerSocioAutenticado(req);
    if (!socio) {
      return res.status(401).json({ error: 'Acceso no autorizado.' });
    }

    const { id_plan_membresia, metodo_pago = 'mercadopago', tipo_operacion = 'renovacion' } = req.body;

    if (!id_plan_membresia) {
      return res.status(400).json({ error: 'El id_plan_membresia es requerido para iniciar el pago.' });
    }

    // 1. Validar plan del gimnasio y verificar que no esté en pausa o inactivo
    const { data: plan, error: planErr } = await supabase
      .from('plan_membresia')
      .select('*')
      .eq('id_plan_membresia', id_plan_membresia)
      .eq('id_gimnasio', socio.id_gimnasio)
      .maybeSingle();

    if (planErr || !plan) {
      return res.status(404).json({ error: 'El plan de membresía no pertenece a tu gimnasio.' });
    }

    const estadoPlan = (plan.estado || '').toLowerCase().trim();
    if (ESTADOS_MEMBRESIA_INACTIVOS.includes(estadoPlan)) {
      return res.status(400).json({ error: 'El plan de membresía seleccionado se encuentra pausado o inactivo y no admite nuevos pagos.' });
    }

    // 2. Obtener datos del gimnasio
    const { data: gimnasio } = await supabase
      .from('gimnasio')
      .select('id_gimnasio, nombre, direccion')
      .eq('id_gimnasio', socio.id_gimnasio)
      .maybeSingle();

    // 3. Generar referencia única del pago
    const timestamp = Date.now();
    const externalReference = `GYM-${socio.id_gimnasio}-SOC-${socio.id_socio}-PL-${plan.id_plan_membresia}-${timestamp}`;
    const monto = Number(plan.precio);

    let pasarelaResultado = null;
    const metodoNorm = (metodo_pago || '').toLowerCase();

    if (metodoNorm === 'uala') {
      pasarelaResultado = await crearOrdenUala({
        titulo: plan.nombre,
        monto,
        externalReference,
        socio,
        gimnasio
      });
    } else {
      // Por defecto Mercado Pago
      pasarelaResultado = await crearPreferenciaMercadoPago({
        titulo: plan.nombre,
        monto,
        externalReference,
        socio,
        gimnasio
      });
    }

    return res.status(200).json({
      exito: true,
      mensaje: `Sesión de pago iniciada correctamente con ${metodoNorm === 'uala' ? 'Ualá' : 'Mercado Pago'}.`,
      checkout: {
        ...pasarelaResultado,
        plan: {
          id_plan_membresia: plan.id_plan_membresia,
          nombre: plan.nombre,
          precio: monto,
          precio_formateado: formatearPrecioARS(monto),
          duracion_dias: plan.duracion_dias
        },
        socio: {
          id_socio: socio.id_socio,
          nombre_completo: `${socio.nombre} ${socio.apellido}`,
          dni: socio.dni
        },
        gimnasio: {
          id_gimnasio: socio.id_gimnasio,
          nombre: gimnasio?.nombre || 'GymTrack'
        },
        tipo_operacion
      }
    });

  } catch (error) {
    return res.status(500).json({ error: 'Error al iniciar el pago con la pasarela: ' + error.message });
  }
};

/**
 * ==============================================================================
 * ENDPOINT 5: CONFIRMAR REGISTRO DE PAGO Y ACTUALIZAR MEMBRESÍA
 * POST /api/socio/pagos/confirmar
 * ==============================================================================
 * 
 * GUÍA OPERATIVA DEL CICLO DE VIDA DE LA MEMBRESÍA:
 * 1. Validación de Plan: Corrobora que el plan adquirido pertenezca al gimnasio.
 * 2. Lógica Matemática de Vigencia:
 *    - Si el socio ya posee un plan vigente (`fecha_vencimiento > hoy`):
 *      Se conserva `fecha_inicio` y se añade la duración del nuevo plan (`duracion_dias`)
 *      a la fecha de vencimiento previa (extensión acumulativa, no pierde días).
 *    - Si el plan estaba vencido o es su primera suscripción:
 *      La fecha de inicio se fija en el día actual (`hoy`) y el vencimiento en `hoy + duracion_dias`.
 * 3. Persistencia en Base de Datos:
 *    - Tabla `membresia`: Actualiza o inserta la suscripción fijando `estado = 'activo'`.
 *    - Tabla `pago`: Inserta el registro contable de cobro con método 'mercadopago' y comprobante.
 *    - Tabla `socio`: Cambia el estado del alumno a `'activo'` para habilitar su acceso a molinetes/clases.
 */
const confirmarPago = async (req, res) => {
  try {
    const socio = await obtenerSocioAutenticado(req);
    if (!socio) {
      return res.status(401).json({ error: 'Acceso no autorizado.' });
    }

    const {
      id_plan_membresia,
      monto,
      metodo_pago = 'mercadopago',
      referencia_pago,
      comprobante
    } = req.body;

    if (!id_plan_membresia) {
      return res.status(400).json({ error: 'El id_plan_membresia es requerido para confirmar el pago.' });
    }

    // 1. Obtener y validar el plan de membresía
    const { data: plan, error: planErr } = await supabase
      .from('plan_membresia')
      .select('*')
      .eq('id_plan_membresia', id_plan_membresia)
      .eq('id_gimnasio', socio.id_gimnasio)
      .maybeSingle();

    if (planErr || !plan) {
      return res.status(404).json({ error: 'El plan de membresía no pertenece a tu gimnasio.' });
    }

    const montoFinal = Number(monto || plan.precio);
    const duracionDias = Number(plan.duracion_dias || 30);
    const hoy = new Date();
    const hoyStr = hoy.toISOString().split('T')[0];

    // 2. Buscar si el socio ya tiene una membresía registrada
    const { data: membActual } = await supabase
      .from('membresia')
      .select('*')
      .eq('id_socio', socio.id_socio)
      .order('fecha_vencimiento', { ascending: false })
      .limit(1)
      .maybeSingle();

    let nuevaFechaInicio = hoyStr;
    let nuevaFechaVencimiento;

    if (membActual && membActual.fecha_vencimiento) {
      const vtoDate = new Date(membActual.fecha_vencimiento + 'T00:00:00');
      // Si aún no ha vencido, extendemos desde la fecha de vencimiento actual
      if (vtoDate > hoy) {
        nuevaFechaInicio = membActual.fecha_inicio;
        const extendida = new Date(vtoDate.getTime() + duracionDias * 24 * 60 * 60 * 1000);
        nuevaFechaVencimiento = extendida.toISOString().split('T')[0];
      } else {
        // Estaba vencida: comienza hoy
        const nuevaVenc = new Date(hoy.getTime() + duracionDias * 24 * 60 * 60 * 1000);
        nuevaFechaVencimiento = nuevaVenc.toISOString().split('T')[0];
      }
    } else {
      // Primera membresía
      const nuevaVenc = new Date(hoy.getTime() + duracionDias * 24 * 60 * 60 * 1000);
      nuevaFechaVencimiento = nuevaVenc.toISOString().split('T')[0];
    }

    // 3. Crear o actualizar la fila en 'membresia'
    let idMembresiaFinal = null;
    let membresiaActualizada = null;

    if (membActual) {
      const { data: updated, error: updErr } = await supabase
        .from('membresia')
        .update({
          id_plan_membresia: plan.id_plan_membresia,
          precio: montoFinal,
          fecha_inicio: nuevaFechaInicio,
          fecha_vencimiento: nuevaFechaVencimiento,
          estado: 'activo'
        })
        .eq('id_membresia', membActual.id_membresia)
        .select('*, plan_membresia(*)')
        .single();

      if (updErr) throw updErr;
      idMembresiaFinal = membActual.id_membresia;
      membresiaActualizada = updated;
    } else {
      const { data: inserted, error: insErr } = await supabase
        .from('membresia')
        .insert([{
          id_socio: socio.id_socio,
          id_plan_membresia: plan.id_plan_membresia,
          precio: montoFinal,
          fecha_inicio: nuevaFechaInicio,
          fecha_vencimiento: nuevaFechaVencimiento,
          estado: 'activo'
        }])
        .select('*, plan_membresia(*)')
        .single();

      if (insErr) throw insErr;
      idMembresiaFinal = inserted.id_membresia;
      membresiaActualizada = inserted;
    }

    // 4. Registrar el pago en la tabla 'pago'
    const refFinal = referencia_pago || `PAY-${Date.now()}-${Math.floor(Math.random() * 10000)}`;
    const compFinal = comprobante || `COMP-${Date.now()}`;

    const { data: nuevoPago, error: pagoErr } = await supabase
      .from('pago')
      .insert([{
        id_membresia: idMembresiaFinal,
        monto: montoFinal,
        fecha_pago: hoyStr,
        metodo_pago: (metodo_pago || 'mercadopago').toLowerCase(),
        estado: 'pagado',
        comprobante: compFinal
      }])
      .select('*')
      .single();

    if (pagoErr) {
      console.warn('Error al insertar registro en tabla pago:', pagoErr.message);
    }

    // 5. Asegurar estado activo en tabla socio
    await supabase
      .from('socio')
      .update({ estado: 'activo' })
      .eq('id_socio', socio.id_socio);

    // 6. Retornar respuesta enriquecida
    const metricas = calcularMetricasMembresia(membresiaActualizada);

    return res.status(201).json({
      exito: true,
      mensaje: `¡Pago de $${montoFinal.toLocaleString('es-AR')} procesado con éxito! Tu membresía está activa.`,
      pago: {
        id_pago: nuevoPago?.id_pago || null,
        monto: montoFinal,
        monto_formateado: formatearPrecioARS(montoFinal),
        fecha_pago: hoyStr,
        fecha_formateada: formatearFechaEspanol(hoyStr),
        metodo_pago,
        comprobante: compFinal,
        referencia: refFinal,
        estado: 'pagado'
      },
      membresia: {
        id_membresia: idMembresiaFinal,
        id_plan_membresia: plan.id_plan_membresia,
        nombre_plan: plan.nombre,
        precio: montoFinal,
        precio_formateado: formatearPrecioARS(montoFinal),
        fecha_inicio: nuevaFechaInicio,
        fecha_vencimiento: nuevaFechaVencimiento,
        fecha_inicio_formateada: metricas.fecha_inicio_formateada,
        fecha_vencimiento_formateada: metricas.fecha_vencimiento_formateada,
        dias_restantes: metricas.dias_restantes,
        tiempo_restante_texto: metricas.tiempo_restante_texto,
        porcentaje_transcurrido: metricas.porcentaje_transcurrido,
        estado: 'activa',
        estado_etiqueta: 'Activa'
      }
    });

  } catch (error) {
    return res.status(500).json({ error: 'Error al confirmar el pago de la membresía: ' + error.message });
  }
};

/**
 * ==============================================================================
 * ENDPOINT 6: WEBHOOK DE NOTIFICACIONES IPN (MERCADO PAGO / UALÁ)
 * POST /api/socio/pagos/webhook
 * ==============================================================================
 * 
 * GUÍA OPERATIVA DE NOTIFICACIONES ASÍNCRONAS:
 * 1. Propósito: Escucha los eventos `payment.created`, `payment.updated` que Mercado Pago
 *    emite de forma push cuando un usuario completa el pago en una pestaña externa o cajero.
 * 2. Acuse de Recibo Inmediato: Responde HTTP 200 de inmediato a Mercado Pago para confirmar
 *    la recepción del evento y evitar reintentos en bucle por timeout de red.
 */
const webhookPago = async (req, res) => {
  try {
    const { proveedor } = req.query;
    console.log(`🔔 Webhook recibido de pasarela [${proveedor || 'mercadopago'}]:`, req.body);

    // Responder 200 inmediatamente a la pasarela para evitar reintentos innecesarios
    return res.status(200).json({ received: true });
  } catch (error) {
    return res.status(200).json({ error: error.message });
  }
};

/**
 * ==============================================================================
 * ENDPOINT 7: VERIFICACIÓN ACTIVA DE PAGO EN MERCADO PAGO Y AUTO-ACREDITACIÓN
 * GET /api/socio/pagos/verificar-mp?external_reference=...&payment_id=...
 * ==============================================================================
 * 
 * GUÍA OPERATIVA DEL POLLING Y VALIDACIÓN DE MERCADO PAGO:
 * 1. Polling Reactivo: Cuando el alumno abre el checkout o regresa a la aplicación desde `back_urls`,
 *    el frontend llama a este endpoint para consultar el estado en tiempo real.
 * 2. Consulta a la API de Mercado Pago (`/v1/payments/search` o `/v1/payments/:id`):
 *    - Filtra por `external_reference` único para validar el importe y estado (`status === 'approved'`).
 * 3. Idempotencia y Protección Contra Doble Imputación:
 *    - Comprueba si el comprobante (`MP-{payment_id}`) ya fue asentado en la tabla `pago`.
 *    - Si ya existe, responde inmediatamente `ya_registrado: true` sin duplicar transacciones.
 * 4. Activación Automatizada:
 *    - Si el pago es legítimo y no estaba registrado, invoca la renovación de la membresía,
 *      crea el registro de caja en `pago` y habilita al socio (`estado = 'activo'`).
 */
const verificarPagoMercadoPago = async (req, res) => {
  try {
    const socio = await obtenerSocioAutenticado(req);
    if (!socio) {
      return res.status(401).json({ error: 'Acceso no autorizado.' });
    }

    const { external_reference, payment_id } = req.query;
    const mpToken = process.env.MERCADOPAGO_ACCESS_TOKEN || process.env.Token_Mer || process.env.Api_MER;

    if (!mpToken) {
      return res.status(400).json({ error: 'No hay token de Mercado Pago configurado.' });
    }

    let urlSearch = '';
    if (external_reference) {
      urlSearch = `https://api.mercadopago.com/v1/payments/search?external_reference=${encodeURIComponent(external_reference)}`;
    } else if (payment_id) {
      urlSearch = `https://api.mercadopago.com/v1/payments/${encodeURIComponent(payment_id)}`;
    } else {
      urlSearch = `https://api.mercadopago.com/v1/payments/search?sort=date_created&criteria=desc&limit=10`;
    }

    const mpRes = await fetch(urlSearch, {
      headers: {
        'Authorization': `Bearer ${mpToken}`
      }
    });

    if (!mpRes.ok) {
      const errData = await mpRes.json().catch(() => ({}));
      return res.status(200).json({ aprobado: false, mensaje: 'No se encontró el pago en Mercado Pago.', detalle: errData });
    }

    const mpData = await mpRes.json();
    let pagoEncontrado = null;

    if (mpData.results && Array.isArray(mpData.results)) {
      if (external_reference) {
        pagoEncontrado = mpData.results.find(p => p.external_reference === external_reference && p.status === 'approved') || mpData.results[0];
      } else {
        // Buscar el primer pago aprobado de este socio
        pagoEncontrado = mpData.results.find(p => 
          p.status === 'approved' && 
          p.external_reference && 
          p.external_reference.includes(`-SOC-${socio.id_socio}-`)
        );
      }
    } else if (mpData.id && mpData.status === 'approved') {
      pagoEncontrado = mpData;
    }

    if (!pagoEncontrado || pagoEncontrado.status !== 'approved') {
      return res.status(200).json({
        aprobado: false,
        estado_mp: pagoEncontrado?.status || 'no_encontrado',
        mensaje: 'Aún no se detecta la aprobación de Mercado Pago.'
      });
    }

    const comprobanteStr = `MP-${pagoEncontrado.id}`;

    // Validar si el pago ya fue registrado en la base de datos
    const { data: pagoExistente } = await supabase
      .from('pago')
      .select('id_pago, id_membresia')
      .or(`comprobante.eq.${comprobanteStr},comprobante.eq.${pagoEncontrado.id}`)
      .maybeSingle();

    if (pagoExistente) {
      return res.status(200).json({
        aprobado: true,
        ya_registrado: true,
        mensaje: 'El pago ya se encuentra registrado y acreditado en GymTrack.',
        pago_id: pagoExistente.id_pago
      });
    }

    // Extraer id_plan_membresia del external_reference (ej: GYM-18-SOC-9-PL-3-179...)
    let planId = null;
    if (pagoEncontrado.external_reference) {
      const match = pagoEncontrado.external_reference.match(/-PL-(\d+)-/);
      if (match) planId = parseInt(match[1], 10);
    }

    let plan = null;
    if (planId) {
      const { data: p } = await supabase
        .from('plan_membresia')
        .select('*')
        .eq('id_plan_membresia', planId)
        .maybeSingle();
      plan = p;
    }

    if (!plan) {
      const { data: pFallback } = await supabase
        .from('plan_membresia')
        .select('*')
        .eq('id_gimnasio', socio.id_gimnasio)
        .eq('precio', pagoEncontrado.transaction_amount)
        .maybeSingle();
      plan = pFallback;
    }

    const montoFinal = Number(pagoEncontrado.transaction_amount || plan?.precio || 0);
    const duracionDias = Number(plan?.duracion_dias || 30);
    const hoy = new Date();
    const hoyStr = hoy.toISOString().split('T')[0];

    // Buscar membresía actual del socio
    const { data: membActual } = await supabase
      .from('membresia')
      .select('*')
      .eq('id_socio', socio.id_socio)
      .order('fecha_vencimiento', { ascending: false })
      .limit(1)
      .maybeSingle();

    let nuevaFechaInicio = hoyStr;
    let nuevaFechaVencimiento = new Date(hoy.getTime() + duracionDias * 24 * 60 * 60 * 1000).toISOString().split('T')[0];

    let idMembresiaFinal = null;
    let membresiaActualizada = null;

    if (membActual) {
      const vtoDate = new Date(membActual.fecha_vencimiento + 'T00:00:00');
      if (vtoDate > hoy) {
        nuevaFechaInicio = membActual.fecha_inicio;
        nuevaFechaVencimiento = new Date(vtoDate.getTime() + duracionDias * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
      }

      const { data: upd, error: updErr } = await supabase
        .from('membresia')
        .update({
          id_plan_membresia: plan?.id_plan_membresia || membActual.id_plan_membresia,
          precio: montoFinal,
          fecha_inicio: nuevaFechaInicio,
          fecha_vencimiento: nuevaFechaVencimiento,
          estado: 'activo'
        })
        .eq('id_membresia', membActual.id_membresia)
        .select('*, plan_membresia(*)')
        .single();

      if (updErr) throw updErr;
      idMembresiaFinal = membActual.id_membresia;
      membresiaActualizada = upd;
    } else {
      const { data: ins, error: insErr } = await supabase
        .from('membresia')
        .insert([{
          id_socio: socio.id_socio,
          id_plan_membresia: plan?.id_plan_membresia || null,
          precio: montoFinal,
          fecha_inicio: nuevaFechaInicio,
          fecha_vencimiento: nuevaFechaVencimiento,
          estado: 'activo'
        }])
        .select('*, plan_membresia(*)')
        .single();

      if (insErr) throw insErr;
      idMembresiaFinal = ins.id_membresia;
      membresiaActualizada = ins;
    }

    // Registrar en tabla 'pago'
    const { data: nuevoPago, error: pErr } = await supabase
      .from('pago')
      .insert([{
        id_membresia: idMembresiaFinal,
        monto: montoFinal,
        fecha_pago: hoyStr,
        metodo_pago: 'mercadopago',
        estado: 'pagado',
        comprobante: comprobanteStr
      }])
      .select('*')
      .single();

    if (pErr) console.warn('Error al registrar pago en base de datos:', pErr.message);

    // Actualizar estado activo en tabla socio
    await supabase.from('socio').update({ estado: 'activo' }).eq('id_socio', socio.id_socio);

    const metricas = calcularMetricasMembresia(membresiaActualizada);

    return res.status(200).json({
      aprobado: true,
      mensaje: `¡Pago de $${montoFinal.toLocaleString('es-AR')} acreditado exitosamente! Tu plan ahora es ${plan?.nombre || 'Plan Activo'}.`,
      pago: nuevoPago,
      membresia: {
        id_membresia: idMembresiaFinal,
        id_plan_membresia: plan?.id_plan_membresia,
        nombre_plan: plan?.nombre || 'Plan Activo',
        precio: montoFinal,
        precio_formateado: formatearPrecioARS(montoFinal),
        fecha_inicio: nuevaFechaInicio,
        fecha_vencimiento: nuevaFechaVencimiento,
        fecha_inicio_formateada: metricas.fecha_inicio_formateada,
        fecha_vencimiento_formateada: metricas.fecha_vencimiento_formateada,
        dias_restantes: metricas.dias_restantes,
        tiempo_restante_texto: metricas.tiempo_restante_texto,
        porcentaje_transcurrido: metricas.porcentaje_transcurrido,
        estado: 'activa',
        estado_etiqueta: 'Activa'
      }
    });

  } catch (error) {
    return res.status(500).json({ error: 'Error al verificar pago de Mercado Pago: ' + error.message });
  }
};

module.exports = {
  getMiMembresia,
  getPlanesDisponibles,
  solicitarActualizacion,
  iniciarPago,
  confirmarPago,
  verificarPagoMercadoPago,
  webhookPago
};

