const supabase = require('../config/supabase');

/**
 * GET /api/socio/dashboard
 * Retorna la información completa para el Dashboard del Socio autenticado.
 */
const getDashboardSocio = async (req, res) => {
  try {
    // 1. Obtener el socio autenticado desde el token JWT
    // Se admite tanto si el token trae id_socio directamente o id_usuario
    let idSocio = req.usuario?.id_socio;

    if (!idSocio && req.usuario?.id_usuario) {
      const { data: socioAuth, error: socioAuthErr } = await supabase
        .from('socio')
        .select('id_socio')
        .eq('id_usuario', req.usuario.id_usuario)
        .maybeSingle();

      if (socioAuthErr || !socioAuth) {
        return res.status(404).json({ error: 'No se encontró un perfil de socio vinculado a este usuario.' });
      }
      idSocio = socioAuth.id_socio;
    }

    if (!idSocio) {
      return res.status(401).json({ error: 'Usuario no autenticado como socio.' });
    }

    // 2. Consulta paralela de datos para optimizar tiempo de respuesta
    const [
      socioRes,
      membresiaRes,
      ultimoPagoRes,
      progresoRes,
      asistenciasRes,
      rutinaRes
    ] = await Promise.all([
      // a. Datos básicos del socio
      supabase
        .from('socio')
        .select('id_socio, nombre, apellido, dni, email, telefono')
        .eq('id_socio', idSocio)
        .single(),

      // b. Estado de membresía activa / más reciente
      supabase
        .from('membresia')
        .select(`
          id_membresia,
          fecha_inicio,
          fecha_vencimiento,
          estado,
          precio,
          plan_membresia (nombre)
        `)
        .eq('id_socio', idSocio)
        .order('fecha_vencimiento', { ascending: false })
        .limit(1)
        .maybeSingle(),

      // c. Último pago realizado
      supabase
        .from('pago')
        .select(`
          id_pago,
          monto,
          fecha_pago,
          metodo_pago,
          estado,
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

      // e. Total de entrenamientos / asistencias
      supabase
        .from('asistencia')
        .select('id_asistencia', { count: 'exact', head: true })
        .eq('id_socio', idSocio),

      // f. Rutina activa del socio
      supabase
        .from('rutina')
        .select('id_rutina, nombre, descripcion, estado')
        .eq('id_socio', idSocio)
        .eq('estado', 'activa')
        .maybeSingle()
    ]);

    // Validar error en datos de socio
    if (socioRes.error || !socioRes.data) {
      return res.status(404).json({ error: 'No se encontraron datos del socio.' });
    }

    const socio = socioRes.data;
    const membresia = membresiaRes.data || null;
    const ultimoPago = ultimoPagoRes.data || null;
    const ultimoProgreso = progresoRes.data || null;
    const totalAsistencias = asistenciasRes.count || 0;
    const rutinaActiva = rutinaRes.data || null;

    // 3. Estructurar la respuesta limpia para el Dashboard
    return res.status(200).json({
      socio: {
        id_socio: socio.id_socio,
        nombre: socio.nombre,
        apellido: socio.apellido,
        dni: socio.dni,
        email: socio.email,
        telefono: socio.telefono
      },
      membresia: membresia ? {
        id_membresia: membresia.id_membresia,
        plan: membresia.plan_membresia?.nombre || 'Plan Personalizado',
        estado: membresia.estado,
        fecha_inicio: membresia.fecha_inicio,
        fecha_vencimiento: membresia.fecha_vencimiento
      } : {
        estado: 'sin_membresia',
        mensaje: 'No tienes una membresía activa asignada.'
      },
      ultimo_pago: ultimoPago ? {
        monto: ultimoPago.monto,
        fecha_pago: ultimoPago.fecha_pago,
        metodo_pago: ultimoPago.metodo_pago,
        estado: ultimoPago.estado
      } : null,
      progreso: {
        peso_actual: ultimoProgreso?.peso || null,
        observaciones: ultimoProgreso?.observaciones || null,
        fecha_ultimo_registro: ultimoProgreso?.fecha || null
      },
      entrenamientos: {
        total_asistencias: totalAsistencias
      },
      rutina_activa: rutinaActiva ? {
        id_rutina: rutinaActiva.id_rutina,
        nombre: rutinaActiva.nombre,
        descripcion: rutinaActiva.descripcion
      } : null,
      acciones_rapidas: [
        { clave: 'ver_rutina', titulo: 'Mi Rutina', activo: !!rutinaActiva },
        { clave: 'registrar_asistencia', titulo: 'Marcar Asistencia', activo: membresia?.estado === 'activo' },
        { clave: 'renovar_membresia', titulo: 'Renovar Membresía', activo: true }
      ]
    });

  } catch (error) {
    return res.status(500).json({ error: 'Error interno del servidor al cargar el dashboard: ' + error.message });
  }
};

module.exports = {
  getDashboardSocio
};