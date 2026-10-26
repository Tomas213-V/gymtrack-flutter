const supabase = require('../config/supabase');

/**
 * GET /api/dashboard/admin
 * Obtiene métricas consolidadas, KPIs, gráficos y actividades recientes para el Dueño / Administrador del Gimnasio.
 */
const getDashboardAdmin = async (req, res) => {
  try {
    const gymId = req.usuario?.id_gimnasio || req.query.id_gimnasio;

    if (!gymId) {
      return res.status(400).json({ error: 'No se pudo identificar el gimnasio autenticado.' });
    }

    const ahora = new Date();
    const yearActual = ahora.getFullYear();
    const mesActual = ahora.getMonth();

    // Rango mes actual
    const inicioMesActual = new Date(yearActual, mesActual, 1).toISOString();
    const finMesActual = new Date(yearActual, mesActual + 1, 0, 23, 59, 59, 999).toISOString();

    // Rango mes anterior
    const inicioMesAnterior = new Date(yearActual, mesActual - 1, 1).toISOString();
    const finMesAnterior = new Date(yearActual, mesActual, 0, 23, 59, 59, 999).toISOString();

    // Rango hoy
    const inicioHoy = new Date(ahora.getFullYear(), ahora.getMonth(), ahora.getDate(), 0, 0, 0, 0).toISOString();
    const finHoy = new Date(ahora.getFullYear(), ahora.getMonth(), ahora.getDate(), 23, 59, 59, 999).toISOString();

    // Rango próximos 7 días para vencimientos
    const en7Dias = new Date(ahora.getTime() + 7 * 24 * 60 * 60 * 1000).toISOString();

    // 1. OBTENER INFORMACIÓN DEL GIMNASIO
    const { data: gimnasio } = await supabase
      .from('gimnasio')
      .select('*')
      .eq('id_gimnasio', gymId)
      .maybeSingle();

    // 2. CONSULTAR SOCIOS
    const { data: socios, error: errSocios } = await supabase
      .from('socio')
      .select('id_socio, nombre, apellido, dni, email, telefono, estado, fecha_alta')
      .eq('id_gimnasio', gymId);

    if (errSocios) {
      console.error('Error socios dashboard:', errSocios);
    }

    const totalSocios = socios?.length || 0;
    const sociosActivos = socios?.filter(s => (s.estado || '').toLowerCase() === 'activo').length || 0;
    const sociosInactivos = socios?.filter(s => (s.estado || '').toLowerCase() === 'inactivo').length || 0;
    const sociosPendientes = socios?.filter(s => (s.estado || '').toLowerCase() === 'pendiente').length || 0;

    const nuevosSociosMes = socios?.filter(s => {
      if (!s.fecha_alta) return false;
      return s.fecha_alta >= inicioMesActual && s.fecha_alta <= finMesActual;
    }).length || 0;

    // 3. CONSULTAR PAGOS
    const { data: pagos, error: errPagos } = await supabase
      .from('pago')
      .select(`
        id_pago,
        monto,
        fecha_pago,
        metodo_pago,
        estado,
        membresia!inner(
          id_membresia,
          plan_membresia(nombre),
          socio!inner(id_socio, nombre, apellido, dni, id_gimnasio)
        )
      `)
      .eq('membresia.socio.id_gimnasio', gymId)
      .order('id_pago', { ascending: false });

    if (errPagos) {
      console.error('Error pagos dashboard:', errPagos);
    }

    const pagosList = pagos || [];

    // Pagos del mes actual vs mes anterior
    let recaudacionMesActual = 0;
    let recaudacionMesAnterior = 0;
    let pagosRealizados = 0;
    let pagosPendientes = 0;
    let pagosVencidos = 0;

    pagosList.forEach(p => {
      const monto = Number(p.monto) || 0;
      const estado = (p.estado || '').toLowerCase();
      const fPago = p.fecha_pago ? new Date(p.fecha_pago).toISOString() : '';

      if (fPago >= inicioMesActual && fPago <= finMesActual) {
        if (estado === 'pagado') {
          recaudacionMesActual += monto;
          pagosRealizados += 1;
        }
      }

      if (estado === 'pendiente') {
        pagosPendientes += 1;
      } else if (estado === 'vencido') {
        pagosVencidos += 1;
      }

      if (fPago >= inicioMesAnterior && fPago <= finMesAnterior && estado === 'pagado') {
        recaudacionMesAnterior += monto;
      }
    });

    // Variación porcentual de ingresos
    let variacionIngresos = 0;
    if (recaudacionMesAnterior > 0) {
      variacionIngresos = Math.round(((recaudacionMesActual - recaudacionMesAnterior) / recaudacionMesAnterior) * 100);
    } else if (recaudacionMesActual > 0) {
      variacionIngresos = 100;
    }

    // Histórico de ingresos últimos 6 meses para gráfico
    const mesesNombres = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    const ingresosUltimos6Meses = [];

    for (let i = 5; i >= 0; i--) {
      const d = new Date(yearActual, mesActual - i, 1);
      const mIdx = d.getMonth();
      const yIdx = d.getFullYear();
      const mInicio = new Date(yIdx, mIdx, 1).toISOString();
      const mFin = new Date(yIdx, mIdx + 1, 0, 23, 59, 59, 999).toISOString();

      const totalMes = pagosList.reduce((acc, p) => {
        const est = (p.estado || '').toLowerCase();
        const f = p.fecha_pago ? new Date(p.fecha_pago).toISOString() : '';
        if (f >= mInicio && f <= mFin && est === 'pagado') {
          return acc + (Number(p.monto) || 0);
        }
        return acc;
      }, 0);

      ingresosUltimos6Meses.push({
        mes: `${mesesNombres[mIdx]} ${yIdx !== yearActual ? "'" + String(yIdx).slice(2) : ''}`,
        recaudacion: totalMes
      });
    }

    // 4. CONSULTAR ASISTENCIAS
    const { data: asistencias, error: errAsistencias } = await supabase
      .from('asistencia')
      .select(`
        id_asistencia,
        hora_ingreso,
        hora_salida,
        estado,
        socio!inner(id_socio, nombre, apellido, dni, id_gimnasio)
      `)
      .eq('socio.id_gimnasio', gymId)
      .order('hora_ingreso', { ascending: false });

    if (errAsistencias) {
      console.error('Error asistencias dashboard:', errAsistencias);
    }

    const asistenciasList = asistencias || [];

    // Asistencias hoy y mes actual
    const asistenciasHoy = asistenciasList.filter(a => {
      const h = a.hora_ingreso ? new Date(a.hora_ingreso).toISOString() : '';
      return h >= inicioHoy && h <= finHoy;
    }).length;

    const asistenciasMesActual = asistenciasList.filter(a => {
      const h = a.hora_ingreso ? new Date(a.hora_ingreso).toISOString() : '';
      return h >= inicioMesActual && h <= finMesActual;
    }).length;

    const asistenciasMesAnterior = asistenciasList.filter(a => {
      const h = a.hora_ingreso ? new Date(a.hora_ingreso).toISOString() : '';
      return h >= inicioMesAnterior && h <= finMesAnterior;
    }).length;

    let variacionAsistencias = 0;
    if (asistenciasMesAnterior > 0) {
      variacionAsistencias = Math.round(((asistenciasMesActual - asistenciasMesAnterior) / asistenciasMesAnterior) * 100);
    } else if (asistenciasMesActual > 0) {
      variacionAsistencias = 100;
    }

    // Afluencia por día de la semana (Lunes a Domingo)
    const diasSemanaMap = { 0: 'Dom', 1: 'Lun', 2: 'Mar', 3: 'Mié', 4: 'Jue', 5: 'Vie', 6: 'Sáb' };
    const ordenDias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    const conteoDias = { Lun: 0, Mar: 0, Mié: 0, Jue: 0, Vie: 0, Sáb: 0, Dom: 0 };

    asistenciasList.forEach(a => {
      if (a.hora_ingreso) {
        const diaNum = new Date(a.hora_ingreso).getDay();
        const nombreDia = diasSemanaMap[diaNum];
        if (conteoDias[nombreDia] !== undefined) {
          conteoDias[nombreDia] += 1;
        }
      }
    });

    const asistenciasPorDia = ordenDias.map(dia => ({
      dia,
      asistencias: conteoDias[dia]
    }));

    // 5. CONSULTAR MEMBRESÍAS Y PLANES
    const { data: membresias } = await supabase
      .from('membresia')
      .select(`
        id_membresia,
        fecha_inicio,
        fecha_vencimiento,
        estado,
        plan_membresia(nombre),
        socio!inner(id_socio, nombre, apellido, dni, id_gimnasio)
      `)
      .eq('socio.id_gimnasio', gymId);

    const membresiasList = membresias || [];

    // Distribución por planes
    const planesConteo = {};
    membresiasList.forEach(m => {
      const planNombre = m.plan_membresia?.nombre || 'General / Estándar';
      planesConteo[planNombre] = (planesConteo[planNombre] || 0) + 1;
    });

    const distribucionPlanes = Object.keys(planesConteo).map(nombre => ({
      name: nombre,
      value: planesConteo[nombre]
    }));

    // Fecha actual a medianoche para cálculo exacto de días
    const hoyDate = new Date();
    hoyDate.setHours(0, 0, 0, 0);

    let totalMembresiasVencidas = 0;
    let totalMembresiasPorVencer = 0;
    const proximosVencimientos = [];

    membresiasList.forEach(m => {
      const est = (m.estado || '').toLowerCase().trim();
      // Si la membresía está cancelada, no se cuenta como deuda o cuota a cobrar
      if (est === 'cancelada' || est === 'cancelado') return;

      let esVencida = est === 'vencida' || est === 'vencido';
      let esPorVencer = false;

      if (m.fecha_vencimiento) {
        const fStr = String(m.fecha_vencimiento).split('T')[0];
        const [y, mes, d] = fStr.split('-').map(Number);
        const fVencDate = new Date(y, mes - 1, d, 23, 59, 59, 999);
        const diffMs = fVencDate.getTime() - hoyDate.getTime();
        const diasRestantes = Math.ceil(diffMs / (1000 * 60 * 60 * 24));

        if (diasRestantes <= 0 || fVencDate < ahora) {
          esVencida = true;
        } else if (diasRestantes <= 7) {
          esPorVencer = true;
        }
      }

      if (esVencida) {
        totalMembresiasVencidas += 1;
      } else if (esPorVencer) {
        totalMembresiasPorVencer += 1;
        proximosVencimientos.push({
          id_membresia: m.id_membresia,
          socio: {
            id_socio: m.socio?.id_socio,
            nombre: `${m.socio?.nombre || ''} ${m.socio?.apellido || ''}`.trim(),
            dni: m.socio?.dni
          },
          plan: m.plan_membresia?.nombre || 'Estándar',
          fecha_fin: m.fecha_vencimiento,
          fecha_vencimiento: m.fecha_vencimiento
        });
      }
    });

    // 6. ACTIVIDAD RECIENTE (Últimas 6 asistencias y últimos 6 pagos)
    const ultimasAsistencias = asistenciasList.slice(0, 6).map(a => ({
      id: a.id_asistencia,
      socio: `${a.socio?.nombre || ''} ${a.socio?.apellido || ''}`.trim(),
      dni: a.socio?.dni || 'S/D',
      hora: a.hora_ingreso,
      estado: a.estado || 'presente'
    }));

    const ultimosPagos = pagosList.slice(0, 6).map(p => ({
      id: p.id_pago,
      socio: `${p.membresia?.socio?.nombre || ''} ${p.membresia?.socio?.apellido || ''}`.trim(),
      plan: p.membresia?.plan_membresia?.nombre || 'Cuota Gimnasio',
      monto: Number(p.monto) || 0,
      metodo: p.metodo_pago || 'Efectivo',
      estado: (p.estado || 'pagado').toLowerCase(),
      fecha: p.fecha_pago
    }));

    return res.status(200).json({
      gimnasio: {
        id: gimnasio?.id_gimnasio || gymId,
        nombre: gimnasio?.nombre || 'GymTrack Central',
        codigo_acceso: gimnasio?.codigo_acceso || ''
      },
      kpis: {
        socios: {
          total: totalSocios,
          activos: sociosActivos,
          inactivos: sociosInactivos,
          pendientes: sociosPendientes,
          nuevosMes: nuevosSociosMes
        },
        ingresos: {
          mesActual: recaudacionMesActual,
          mesAnterior: recaudacionMesAnterior,
          variacionPorcentaje: variacionIngresos,
          pagosRealizados,
          pagosPendientes,
          pagosVencidos
        },
        asistencias: {
          hoy: asistenciasHoy,
          mesActual: asistenciasMesActual,
          mesAnterior: asistenciasMesAnterior,
          variacionPorcentaje: variacionAsistencias
        },
        membresiasPorVencer: totalMembresiasPorVencer,
        membresiasVencidas: totalMembresiasVencidas
      },
      graficos: {
        ingresosMensuales: ingresosUltimos6Meses,
        asistenciasPorDia,
        distribucionPlanes: distribucionPlanes.length > 0 ? distribucionPlanes : [{ name: 'Estándar', value: Math.max(1, totalSocios) }]
      },
      actividadReciente: {
        asistencias: ultimasAsistencias,
        pagos: ultimosPagos
      },
      proximosVencimientos
    });

  } catch (error) {
    console.error('Error en getDashboardAdmin:', error);
    return res.status(500).json({ error: 'Error al compilar métricas del dashboard: ' + error.message });
  }
};

module.exports = {
  getDashboardAdmin
};
