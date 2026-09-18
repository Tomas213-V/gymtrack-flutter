import '../models/socio_mock_models.dart';

class SocioMockData {
  static final SocioMockData _instance = SocioMockData._internal();
  factory SocioMockData() => _instance;
  SocioMockData._internal();

  // Perfil del Socio Luciano García
  SocioProfileModel profile = SocioProfileModel(
    id: 'GTM-1024',
    nombre: 'Luciano',
    apellido: 'García',
    email: 'luciano@email.com',
    telefono: '+54 11 5555-1234',
    dni: '41.234.567',
    fechaNacimiento: '15 Mar 1998',
    plan: 'Premium Plan',
    precioPlan: '\$12,500 / mes',
    estado: 'Activa',
    fechaInicio: '15 Dic 2025',
    fechaVencimiento: '15 Jun 2026',
    diasRestantes: 120,
    ultimoPago: '\$12,500 — 15 May',
    pesoActual: 78.0,
    pesoInicial: 82.0,
    cambioTotal: -4.0,
    cambioMes: -2.5,
    entrenamientosMes: 24,
    totalEntrenamientos: 48,
  );

  // Historial de pagos
  List<PagoItemModel> pagos = [
    PagoItemModel(
      id: 'p-01',
      fecha: '15 May 2026',
      metodoPago: 'Tarjeta de Crédito',
      monto: '\$12,500',
      estado: 'Pagado',
    ),
    PagoItemModel(
      id: 'p-02',
      fecha: '15 Abr 2026',
      metodoPago: 'Tarjeta de Crédito',
      monto: '\$12,500',
      estado: 'Pagado',
    ),
    PagoItemModel(
      id: 'p-03',
      fecha: '15 Mar 2026',
      metodoPago: 'Tarjeta de Crédito',
      monto: '\$12,500',
      estado: 'Pagado',
    ),
    PagoItemModel(
      id: 'p-04',
      fecha: '15 Feb 2026',
      metodoPago: 'Efectivo',
      monto: '\$12,500',
      estado: 'Pagado',
    ),
    PagoItemModel(
      id: 'p-05',
      fecha: '15 Ene 2026',
      metodoPago: 'Transferencia',
      monto: '\$12,500',
      estado: 'Pagado',
    ),
  ];

  // Rutina asignada y ejercicios
  late RutinaModel rutina = RutinaModel(
    nombre: 'Fuerza - Nivel Intermedio',
    entrenador: 'Prof. Martín',
    diasSemana: ['L', 'M', 'X', 'J', 'V'],
    diasActivos: ['L', 'X', 'V'],
    ejercicios: [
      EjercicioModel(
        id: 'ej-01',
        nombre: 'Press de banca',
        grupoMuscular: 'Pecho',
        categoria: 'Fuerza',
        series: 4,
        repeticiones: 10,
        peso: '60 kg',
        descanso: '90s',
        instrucciones:
            'Acostado en el banco, agarra la barra con las manos a la anchura de los hombros. Baja la barra de forma controlada hasta el pecho y empuja con fuerza hacia arriba extendiendo los brazos.',
        completado: false,
      ),
      EjercicioModel(
        id: 'ej-02',
        nombre: 'Sentadillas',
        grupoMuscular: 'Piernas',
        categoria: 'Fuerza',
        series: 4,
        repeticiones: 8,
        peso: '80 kg',
        descanso: '120s',
        instrucciones:
            'Coloca la barra sobre los trapecios con agarre firme. Desciende flexionando rodillas y caderas con la espalda erguida hasta romper el paralelo. Empuja con talones para subir.',
        completado: false,
      ),
      EjercicioModel(
        id: 'ej-03',
        nombre: 'Peso muerto',
        grupoMuscular: 'Espalda',
        categoria: 'Fuerza',
        series: 3,
        repeticiones: 8,
        peso: '70 kg',
        descanso: '120s',
        instrucciones:
            'Pies a la anchura de caderas, barra pegada a las espinillas. Mantén la espalda neutra, pecho erguido y levanta el peso impulsando con glúteos e isquiotibiales.',
        completado: false,
      ),
      EjercicioModel(
        id: 'ej-04',
        nombre: 'Press militar',
        grupoMuscular: 'Hombros',
        categoria: 'Fuerza',
        series: 3,
        repeticiones: 10,
        peso: '40 kg',
        descanso: '90s',
        instrucciones:
            'De pie con abdomen y glúteos contraídos, empuja la barra verticalmente desde las clavículas por encima de la cabeza hasta el bloqueo de codos.',
        completado: false,
      ),
      EjercicioModel(
        id: 'ej-05',
        nombre: 'Curl bíceps',
        grupoMuscular: 'Bíceps',
        categoria: 'Hipertrofia',
        series: 3,
        repeticiones: 12,
        peso: '15 kg',
        descanso: '60s',
        instrucciones:
            'Con codos pegados a los costados, flexiona los brazos elevando la mancuerna o barra hacia los hombros sin balancear el torso.',
        completado: false,
      ),
      EjercicioModel(
        id: 'ej-06',
        nombre: 'Remo con barra',
        grupoMuscular: 'Espalda',
        categoria: 'Fuerza',
        series: 4,
        repeticiones: 10,
        peso: '50 kg',
        descanso: '90s',
        instrucciones:
            'Inclina el torso a 45 grados con espalda recta. Tira de la barra hacia la boca del estómago concentrando la contracción en los dorsales.',
        completado: false,
      ),
    ],
  );

  // Historial de pesajes y progresos
  List<ProgresoRegistroModel> registrosProgreso = [
    ProgresoRegistroModel(
      id: 'reg-01',
      fecha: '15 May 2026',
      nota: 'Meta mensual alcanzada',
      peso: 78.0,
      pecho: 102.0,
      cintura: 82.0,
      cadera: 98.0,
      brazo: 38.0,
    ),
    ProgresoRegistroModel(
      id: 'reg-02',
      fecha: '01 May 2026',
      nota: 'Progreso constante',
      peso: 79.2,
      pecho: 102.5,
      cintura: 83.0,
      cadera: 98.5,
      brazo: 37.8,
    ),
    ProgresoRegistroModel(
      id: 'reg-03',
      fecha: '15 Abr 2026',
      nota: 'Buena semana de cardio',
      peso: 80.1,
      pecho: 103.0,
      cintura: 84.0,
      cadera: 99.0,
      brazo: 37.5,
    ),
    ProgresoRegistroModel(
      id: 'reg-04',
      fecha: '01 Abr 2026',
      nota: 'Ajuste de dieta completado',
      peso: 81.0,
      pecho: 103.5,
      cintura: 85.0,
      cadera: 99.5,
      brazo: 37.2,
    ),
  ];

  // Puntos para el gráfico de evolución de peso
  List<ProgresoPuntoModel> puntosGrafico = [
    ProgresoPuntoModel(mes: 'Ene', peso: 82.0),
    ProgresoPuntoModel(mes: 'Feb', peso: 81.2),
    ProgresoPuntoModel(mes: 'Mar', peso: 80.5),
    ProgresoPuntoModel(mes: 'Abr', peso: 79.2),
    ProgresoPuntoModel(mes: 'May', peso: 78.0),
  ];

  void toggleEjercicioCompletado(String id) {
    for (var ej in rutina.ejercicios) {
      if (ej.id == id) {
        ej.completado = !ej.completado;
        break;
      }
    }
  }

  void agregarProgreso({
    required double peso,
    required String fecha,
    required String nota,
    double? pecho,
    double? cintura,
    double? cadera,
    double? brazo,
  }) {
    final nuevo = ProgresoRegistroModel(
      id: 'reg-${DateTime.now().millisecondsSinceEpoch}',
      fecha: fecha,
      nota: nota.isNotEmpty ? nota : 'Registro de progreso',
      peso: peso,
      pecho: pecho,
      cintura: cintura,
      cadera: cadera,
      brazo: brazo,
    );
    registrosProgreso.insert(0, nuevo);
    // Actualizar peso actual
    profile = SocioProfileModel(
      id: profile.id,
      nombre: profile.nombre,
      apellido: profile.apellido,
      email: profile.email,
      telefono: profile.telefono,
      dni: profile.dni,
      fechaNacimiento: profile.fechaNacimiento,
      plan: profile.plan,
      precioPlan: profile.precioPlan,
      estado: profile.estado,
      fechaInicio: profile.fechaInicio,
      fechaVencimiento: profile.fechaVencimiento,
      diasRestantes: profile.diasRestantes,
      ultimoPago: profile.ultimoPago,
      pesoActual: peso,
      pesoInicial: profile.pesoInicial,
      cambioTotal: (peso - profile.pesoInicial),
      cambioMes: profile.cambioMes,
      entrenamientosMes: profile.entrenamientosMes,
      totalEntrenamientos: profile.totalEntrenamientos,
    );
  }
}
