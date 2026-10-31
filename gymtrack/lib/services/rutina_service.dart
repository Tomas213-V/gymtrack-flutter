import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ejercicio_model.dart';
import '../models/rutina_model.dart';
import 'api_config.dart';
import 'auth_service.dart';

class RutinaService {
  static final RutinaService _instance = RutinaService._internal();
  factory RutinaService() => _instance;
  RutinaService._internal();

  // Fallback demo program gym routines
  static final List<RutinaModel> _demoProgramasGym = [
    RutinaModel(
      idRutina: 101,
      nombre: 'Full Body Principiante (Oficial Gimnasio)',
      descripcion: 'Programa integral para iniciar entrenamiento de fuerza con movimientos fundamentales.',
      estado: 'activo',
      esOfrecidaGym: true,
      tipo: 'Full Body',
      dificultad: 'Principiante',
      dias: 'Lunes, Miércoles, Viernes',
      duracion: '50 min',
      objetivo: 'Acondicionamiento general y fortalecimiento global.',
      ejercicios: [
        RutinaEjercicioModel(
          idRutinaEjercicio: 1,
          idEjercicio: 1,
          series: 3,
          repeticiones: 12,
          peso: 15,
          descanso: 60,
          orden: 1,
          ejercicio: EjercicioModel(
            idEjercicio: 1,
            nombre: 'Sentadillas con mancuernas',
            grupoMuscular: 'Piernas',
            dificultad: 'Principiante',
            descripcion: 'Mantener la espalda recta y bajar hasta que los muslos queden paralelos al suelo.',
          ),
        ),
        RutinaEjercicioModel(
          idRutinaEjercicio: 2,
          idEjercicio: 2,
          series: 3,
          repeticiones: 10,
          peso: 30,
          descanso: 60,
          orden: 2,
          ejercicio: EjercicioModel(
            idEjercicio: 2,
            nombre: 'Press de banca plano',
            grupoMuscular: 'Pecho',
            dificultad: 'Principiante',
            descripcion: 'Bajar la barra de manera controlada al pecho y empujar con fuerza hasta extender brazos.',
          ),
        ),
        RutinaEjercicioModel(
          idRutinaEjercicio: 3,
          idEjercicio: 3,
          series: 3,
          repeticiones: 12,
          peso: 16,
          descanso: 60,
          orden: 3,
          ejercicio: EjercicioModel(
            idEjercicio: 3,
            nombre: 'Remo con mancuerna',
            grupoMuscular: 'Espalda',
            dificultad: 'Principiante',
            descripcion: 'Apoyar rodilla y mano contraria en el banco y traccionar la mancuerna hacia la cadera.',
          ),
        ),
        RutinaEjercicioModel(
          idRutinaEjercicio: 4,
          idEjercicio: 4,
          series: 3,
          repeticiones: 12,
          peso: 8,
          descanso: 45,
          orden: 4,
          ejercicio: EjercicioModel(
            idEjercicio: 4,
            nombre: 'Press militar con mancuernas',
            grupoMuscular: 'Hombros',
            dificultad: 'Principiante',
            descripcion: 'Sentado en banco a 90 grados, empujar las mancuernas por encima de la cabeza.',
          ),
        ),
        RutinaEjercicioModel(
          idRutinaEjercicio: 5,
          idEjercicio: 5,
          series: 3,
          repeticiones: 30,
          peso: 0,
          descanso: 45,
          orden: 5,
          ejercicio: EjercicioModel(
            idEjercicio: 5,
            nombre: 'Plancha abdominal',
            grupoMuscular: 'Abdomen',
            dificultad: 'Principiante',
            descripcion: 'Mantener cuerpo alineado y tensión activa en core y glúteos durante 30 segundos.',
          ),
        ),
      ],
    ),
    RutinaModel(
      idRutina: 102,
      nombre: 'Torso / Pierna Intermedio (Gimnasio)',
      descripcion: 'División clásica de 4 días para maximizar hipertrofia y recuperación muscular.',
      estado: 'activo',
      esOfrecidaGym: true,
      tipo: 'Hipertrofia',
      dificultad: 'Intermedia',
      dias: 'Lunes, Martes, Jueves, Viernes',
      duracion: '60 min',
      objetivo: 'Ganancia de masa muscular magra y mejora de composición corporal.',
      ejercicios: [
        RutinaEjercicioModel(
          idRutinaEjercicio: 6,
          idEjercicio: 6,
          series: 4,
          repeticiones: 10,
          peso: 45,
          descanso: 90,
          orden: 1,
          ejercicio: EjercicioModel(
            idEjercicio: 6,
            nombre: 'Press banca inclinado',
            grupoMuscular: 'Pecho',
            dificultad: 'Intermedia',
            descripcion: 'Enfocado en la porción clavicular del pectoral con banco a 30-45 grados.',
          ),
        ),
        RutinaEjercicioModel(
          idRutinaEjercicio: 7,
          idEjercicio: 7,
          series: 4,
          repeticiones: 10,
          peso: 45,
          descanso: 75,
          orden: 2,
          ejercicio: EjercicioModel(
            idEjercicio: 7,
            nombre: 'Jalón al pecho en polea',
            grupoMuscular: 'Espalda',
            dificultad: 'Intermedia',
            descripcion: 'Agarre amplio prono, llevar barra a la altura del esternón retrayendo escápulas.',
          ),
        ),
        RutinaEjercicioModel(
          idRutinaEjercicio: 8,
          idEjercicio: 8,
          series: 4,
          repeticiones: 12,
          peso: 120,
          descanso: 90,
          orden: 3,
          ejercicio: EjercicioModel(
            idEjercicio: 8,
            nombre: 'Prensa de piernas 45°',
            grupoMuscular: 'Piernas',
            dificultad: 'Intermedia',
            descripcion: 'Pies a la anchura de hombros, bajar con control hasta 90 grados en rodillas.',
          ),
        ),
        RutinaEjercicioModel(
          idRutinaEjercicio: 9,
          idEjercicio: 9,
          series: 3,
          repeticiones: 12,
          peso: 15,
          descanso: 60,
          orden: 4,
          ejercicio: EjercicioModel(
            idEjercicio: 9,
            nombre: 'Curl bíceps con barra Z',
            grupoMuscular: 'Brazos',
            dificultad: 'Intermedia',
            descripcion: 'Codos pegados al cuerpo, subir contrayendo bíceps y descender en 2 segundos.',
          ),
        ),
      ],
    ),
    RutinaModel(
      idRutina: 103,
      nombre: 'Push / Pull / Legs Avanzado (Gimnasio)',
      descripcion: 'Enfoque biomecánico en empujes, jalones y piernas para deportistas de alto rendimiento.',
      estado: 'activo',
      esOfrecidaGym: true,
      tipo: 'Fuerza & Hipertrofia',
      dificultad: 'Avanzada',
      dias: 'Lunes a Sábado',
      duracion: '70 min',
      objetivo: 'Máxima sobrecarga progresiva y desarrollo neuromuscular avanzado.',
      ejercicios: [
        RutinaEjercicioModel(
          idRutinaEjercicio: 10,
          idEjercicio: 10,
          series: 4,
          repeticiones: 8,
          peso: 70,
          descanso: 90,
          orden: 1,
          ejercicio: EjercicioModel(
            idEjercicio: 10,
            nombre: 'Press banca plano con barra',
            grupoMuscular: 'Pecho',
            dificultad: 'Avanzada',
            descripcion: 'Técnica de competición con retracción escapular y arco lumbar moderado.',
          ),
        ),
        RutinaEjercicioModel(
          idRutinaEjercicio: 11,
          idEjercicio: 11,
          series: 4,
          repeticiones: 8,
          peso: 40,
          descanso: 90,
          orden: 2,
          ejercicio: EjercicioModel(
            idEjercicio: 11,
            nombre: 'Press militar de pie con barra',
            grupoMuscular: 'Hombros',
            dificultad: 'Avanzada',
            descripcion: 'Core y glúteos tensos, empuje vertical completo bloqueando codos al final.',
          ),
        ),
        RutinaEjercicioModel(
          idRutinaEjercicio: 12,
          idEjercicio: 12,
          series: 4,
          repeticiones: 8,
          peso: 60,
          descanso: 90,
          orden: 3,
          ejercicio: EjercicioModel(
            idEjercicio: 12,
            nombre: 'Remo pendlay con barra',
            grupoMuscular: 'Espalda',
            dificultad: 'Avanzada',
            descripcion: 'Torso paralelo al suelo, barra toca el suelo en cada repetición para máxima potencia.',
          ),
        ),
        RutinaEjercicioModel(
          idRutinaEjercicio: 13,
          idEjercicio: 13,
          series: 4,
          repeticiones: 8,
          peso: 90,
          descanso: 120,
          orden: 4,
          ejercicio: EjercicioModel(
            idEjercicio: 13,
            nombre: 'Sentadilla trasera libre',
            grupoMuscular: 'Piernas',
            dificultad: 'Avanzada',
            descripcion: 'Profundidad por debajo de la paralela manteniendo el pecho erguido y core activo.',
          ),
        ),
      ],
    ),
    RutinaModel(
      idRutina: 104,
      nombre: 'Quema de Grasa & HIIT Funcional',
      descripcion: 'Circuitos de intervalos de alta intensidad para optimizar acondicionamiento y gasto calórico.',
      estado: 'activo',
      esOfrecidaGym: true,
      tipo: 'Funcional & HIIT',
      dificultad: 'Intermedia',
      dias: 'Lunes, Miércoles, Viernes',
      duracion: '45 min',
      objetivo: 'Acelerar el metabolismo y tonificar cuerpo completo.',
      ejercicios: [
        RutinaEjercicioModel(
          idRutinaEjercicio: 14,
          idEjercicio: 14,
          series: 4,
          repeticiones: 15,
          peso: 15,
          descanso: 45,
          orden: 1,
          ejercicio: EjercicioModel(
            idEjercicio: 14,
            nombre: 'Kettlebell swing',
            grupoMuscular: 'Piernas & Core',
            dificultad: 'Intermedia',
            descripcion: 'Bisagra de cadera explosiva, activando glúteos e isquiotibiales.',
          ),
        ),
        RutinaEjercicioModel(
          idRutinaEjercicio: 15,
          idEjercicio: 15,
          series: 4,
          repeticiones: 12,
          peso: 0,
          descanso: 45,
          orden: 2,
          ejercicio: EjercicioModel(
            idEjercicio: 15,
            nombre: 'Burpees completos',
            grupoMuscular: 'Cardio & Full Body',
            dificultad: 'Intermedia',
            descripcion: 'Pecho al suelo y salto vertical con palmada detrás de la cabeza.',
          ),
        ),
        RutinaEjercicioModel(
          idRutinaEjercicio: 16,
          idEjercicio: 16,
          series: 4,
          repeticiones: 20,
          peso: 0,
          descanso: 30,
          orden: 3,
          ejercicio: EjercicioModel(
            idEjercicio: 16,
            nombre: 'Mountain climbers',
            grupoMuscular: 'Core',
            dificultad: 'Intermedia',
            descripcion: 'En posición de plancha, llevar rodillas alternadamente al pecho con ritmo continuo.',
          ),
        ),
      ],
    ),
  ];

  // Fallback demo member routines
  static final List<RutinaModel> _demoRutinasSocio = [
    RutinaModel(
      idRutina: 201,
      nombre: 'Fuerza - Nivel Intermedio',
      descripcion: 'Mi rutina principal asignada por el entrenador para progreso constante.',
      estado: 'activo',
      esOfrecidaGym: false,
      tipo: 'Fuerza',
      dificultad: 'Intermedia',
      dias: 'Lunes, Miércoles, Viernes',
      duracion: '55 min',
      objetivo: 'Fuerza funcional y desarrollo de masa muscular.',
      ejercicios: [
        RutinaEjercicioModel(
          idRutinaEjercicio: 21,
          idEjercicio: 101,
          series: 4,
          repeticiones: 8,
          peso: 60,
          descanso: 90,
          orden: 1,
          ejercicio: EjercicioModel(
            idEjercicio: 101,
            nombre: 'Press de banca',
            grupoMuscular: 'Pecho',
            dificultad: 'Intermedia',
            descripcion: 'Acostado en banco plano, bajar la barra al pecho y empujar extendiendo los brazos.',
          ),
        ),
        RutinaEjercicioModel(
          idRutinaEjercicio: 22,
          idEjercicio: 102,
          series: 4,
          repeticiones: 10,
          peso: 70,
          descanso: 90,
          orden: 2,
          ejercicio: EjercicioModel(
            idEjercicio: 102,
            nombre: 'Sentadillas',
            grupoMuscular: 'Piernas',
            dificultad: 'Intermedia',
            descripcion: 'Bajar cadera manteniendo espalda recta y rodillas alineadas con los pies.',
          ),
        ),
        RutinaEjercicioModel(
          idRutinaEjercicio: 23,
          idEjercicio: 103,
          series: 3,
          repeticiones: 10,
          peso: 50,
          descanso: 75,
          orden: 3,
          ejercicio: EjercicioModel(
            idEjercicio: 103,
            nombre: 'Remo con barra',
            grupoMuscular: 'Espalda',
            dificultad: 'Intermedia',
            descripcion: 'Inclinado hacia adelante, jalar la barra hacia el ombligo contrayendo dorsales.',
          ),
        ),
        RutinaEjercicioModel(
          idRutinaEjercicio: 24,
          idEjercicio: 104,
          series: 3,
          repeticiones: 12,
          peso: 14,
          descanso: 60,
          orden: 4,
          ejercicio: EjercicioModel(
            idEjercicio: 104,
            nombre: 'Elevaciones laterales',
            grupoMuscular: 'Hombros',
            dificultad: 'Intermedia',
            descripcion: 'Elevar mancuernas hasta la altura de los hombros con codos ligeramente flexionados.',
          ),
        ),
      ],
    ),
    RutinaModel(
      idRutina: 202,
      nombre: 'Mi Rutina de Fin de Semana & Core',
      descripcion: 'Entrenamiento complementario enfocado en movilidad, abdomen y brazos.',
      estado: 'inactivo',
      esOfrecidaGym: false,
      tipo: 'Funcional',
      dificultad: 'Principiante',
      dias: 'Sábado',
      duracion: '40 min',
      objetivo: 'Movilidad activa y trabajo accesorio.',
      ejercicios: [
        RutinaEjercicioModel(
          idRutinaEjercicio: 25,
          idEjercicio: 105,
          series: 3,
          repeticiones: 12,
          peso: 15,
          descanso: 45,
          orden: 1,
          ejercicio: EjercicioModel(
            idEjercicio: 105,
            nombre: 'Extensiones de tríceps en polea',
            grupoMuscular: 'Brazos',
            dificultad: 'Principiante',
            descripcion: 'Codos estables pegados al tronco, extender completamente hacia abajo.',
          ),
        ),
        RutinaEjercicioModel(
          idRutinaEjercicio: 26,
          idEjercicio: 106,
          series: 3,
          repeticiones: 12,
          peso: 18,
          descanso: 45,
          orden: 2,
          ejercicio: EjercicioModel(
            idEjercicio: 106,
            nombre: 'Curl de bíceps con mancuernas',
            grupoMuscular: 'Brazos',
            dificultad: 'Principiante',
            descripcion: 'Subir alternando brazos con supinación en el punto más alto.',
          ),
        ),
        RutinaEjercicioModel(
          idRutinaEjercicio: 27,
          idEjercicio: 107,
          series: 3,
          repeticiones: 20,
          peso: 0,
          descanso: 30,
          orden: 3,
          ejercicio: EjercicioModel(
            idEjercicio: 107,
            nombre: 'Abdominales Crunch',
            grupoMuscular: 'Abdomen',
            dificultad: 'Principiante',
            descripcion: 'Flexión controlada de tronco despegando escápulas del suelo.',
          ),
        ),
      ],
    ),
  ];

  Future<List<RutinaModel>> getRutinas({
    String? search,
    String? estado,
    int? idSocio,
  }) async {
    final token = AuthService().token;
    try {
      final queryParams = <String, String>{};
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }
      if (estado != null && estado.isNotEmpty && estado.toLowerCase() != 'todos') {
        queryParams['estado'] = estado;
      }
      if (idSocio != null) {
        queryParams['id_socio'] = idSocio.toString();
      }

      final uri = Uri.parse(ApiConfig.rutinasUrl).replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawList = data is List ? data : [];
        final parsed = rawList
            .map((e) => RutinaModel.fromJson(e as Map<String, dynamic>))
            .toList();
        if (parsed.isNotEmpty) {
          return parsed;
        }
      }
    } catch (_) {}

    // Fallback con rutinas propias
    return List<RutinaModel>.from(_demoRutinasSocio);
  }

  Future<RutinaModel?> getRutinaById(int idRutina) async {
    final token = AuthService().token;
    try {
      final uri = Uri.parse('${ApiConfig.rutinasUrl}/$idRutina');
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return RutinaModel.fromJson(data);
      }
    } catch (_) {}

    // Fallback buscar en demo
    for (final r in _demoRutinasSocio) {
      if (r.idRutina == idRutina) return r;
    }
    for (final r in _demoProgramasGym) {
      if (r.idRutina == idRutina) return r;
    }
    return null;
  }

  Future<bool> createRutina({
    required String nombre,
    String? descripcion,
    required int idSocio,
    String? fechaInicio,
    String? fechaFin,
    String estado = 'activo',
    String? dias,
    String? duracion,
  }) async {
    final token = AuthService().token;
    final now = DateTime.now();
    final defaultInicio = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Siempre registrar localmente en demo para persistencia inmediata en la UI
    final nuevaLocal = RutinaModel(
      idRutina: DateTime.now().millisecondsSinceEpoch % 1000000,
      nombre: nombre.trim(),
      descripcion: descripcion?.trim(),
      fechaInicio: fechaInicio ?? defaultInicio,
      fechaFin: fechaFin,
      estado: estado,
      idSocio: idSocio,
      esOfrecidaGym: false,
      tipo: 'Personalizada',
      dias: dias ?? '3 días por semana',
      duracion: duracion ?? '45 min',
      objetivo: 'Rutina creada por el socio.',
      ejercicios: [],
    );
    _demoRutinasSocio.insert(0, nuevaLocal);

    try {
      final uri = Uri.parse(ApiConfig.rutinasUrl);
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .post(
            uri,
            headers: headers,
            body: jsonEncode({
              'nombre': nombre.trim(),
              'descripcion': descripcion?.trim(),
              'id_socio': idSocio,
              'fecha_inicio': fechaInicio ?? defaultInicio,
              'fecha_fin': fechaFin,
              'estado': estado,
            }),
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return true; // Éxito local
    }
  }

  Future<bool> updateRutina({
    required int idRutina,
    required String nombre,
    String? descripcion,
    required String estado,
    String? fechaInicio,
    String? fechaFin,
  }) async {
    final token = AuthService().token;
    try {
      final uri = Uri.parse('${ApiConfig.rutinasUrl}/$idRutina');
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final body = <String, dynamic>{
        'nombre': nombre.trim(),
        'descripcion': descripcion?.trim(),
        'estado': estado,
      };
      if (fechaInicio != null) body['fecha_inicio'] = fechaInicio;
      if (fechaFin != null) body['fecha_fin'] = fechaFin;

      final response = await http
          .put(
            uri,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteRutina(int idRutina) async {
    // Eliminar localmente
    _demoRutinasSocio.removeWhere((r) => r.idRutina == idRutina);

    final token = AuthService().token;
    try {
      final uri = Uri.parse('${ApiConfig.rutinasUrl}/$idRutina');
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.delete(uri, headers: headers).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return true; // Éxito local
    }
  }

  Future<bool> addEjercicioToRutina({
    required int idRutina,
    required int idEjercicio,
    required int series,
    required int repeticiones,
    double? peso,
    int? descanso,
  }) async {
    final token = AuthService().token;
    try {
      final uri = Uri.parse('${ApiConfig.rutinasUrl}/$idRutina/ejercicios');
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final body = <String, dynamic>{
        'id_ejercicio': idEjercicio,
        'series': series,
        'repeticiones': repeticiones,
      };
      if (peso != null) body['peso'] = peso;
      if (descanso != null) body['descanso'] = descanso;

      final response = await http
          .post(
            uri,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeEjercicioFromRutina({
    required int idRutina,
    required int idEjercicio,
  }) async {
    final token = AuthService().token;
    try {
      final uri = Uri.parse('${ApiConfig.rutinasUrl}/$idRutina/ejercicios/$idEjercicio');
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.delete(uri, headers: headers).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Obtiene los programas oficiales del gimnasio ofrecidos a todos los socios
  Future<List<RutinaModel>> fetchRutinasOfrecidasGym() async {
    final token = AuthService().token;
    try {
      final uri = Uri.parse(ApiConfig.rutinasOfrecidasGymUrl);
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawList = data is List ? data : (data is Map && data['rutinas'] != null ? data['rutinas'] as List : []);
        final parsed = rawList
            .map((e) => RutinaModel.fromJson(e as Map<String, dynamic>))
            .toList();
        if (parsed.isNotEmpty) {
          return parsed;
        }
      }
    } catch (_) {}

    // Fallback con programas oficiales completos
    return List<RutinaModel>.from(_demoProgramasGym);
  }

  /// Adopta/clona un programa oficial del gimnasio a las rutinas personales del socio
  Future<Map<String, dynamic>> adoptarRutinaGym({
    int? idPlantilla,
    int? idSocio,
    String? nombrePersonalizado,
    Map<String, dynamic>? plantilla,
  }) async {
    // Clonar inmediatamente en memoria
    RutinaModel? foundPlantilla;
    if (idPlantilla != null) {
      for (final p in _demoProgramasGym) {
        if (p.idRutina == idPlantilla) {
          foundPlantilla = p;
          break;
        }
      }
    }
    foundPlantilla ??= _demoProgramasGym.first;

    final cloned = RutinaModel(
      idRutina: DateTime.now().millisecondsSinceEpoch % 1000000,
      nombre: nombrePersonalizado ?? foundPlantilla.nombre,
      descripcion: foundPlantilla.descripcion,
      estado: 'activo',
      idSocio: idSocio,
      esOfrecidaGym: false,
      tipo: foundPlantilla.tipo,
      dificultad: foundPlantilla.dificultad,
      dias: foundPlantilla.dias,
      duracion: foundPlantilla.duracion,
      objetivo: foundPlantilla.objetivo,
      ejercicios: List.from(foundPlantilla.ejercicios),
    );

    // Marcar otras como inactivas
    for (int i = 0; i < _demoRutinasSocio.length; i++) {
      _demoRutinasSocio[i] = _demoRutinasSocio[i].copyWith(estado: 'inactivo');
    }
    _demoRutinasSocio.insert(0, cloned);

    final token = AuthService().token;
    try {
      final uri = Uri.parse(ApiConfig.rutinasAdoptarUrl);
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final body = <String, dynamic>{};
      if (idPlantilla != null) body['id_plantilla'] = idPlantilla;
      if (idSocio != null) body['id_socio'] = idSocio;
      if (nombrePersonalizado != null) body['nombre_personalizado'] = nombrePersonalizado;
      if (plantilla != null) body['plantilla'] = plantilla;

      final response = await http
          .post(
            uri,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? data['mensaje'] ?? '¡Rutina adoptada con éxito!',
          'rutina': data['rutina'] != null ? RutinaModel.fromJson(data['rutina']) : cloned,
        };
      }
    } catch (_) {}

    return {
      'success': true,
      'message': '¡Rutina "${cloned.nombre}" adoptada como activa!',
      'rutina': cloned,
    };
  }

  /// Establece una rutina como la rutina activa principal del socio
  Future<bool> activarRutina(int idRutina) async {
    // Actualizar localmente
    for (int i = 0; i < _demoRutinasSocio.length; i++) {
      final r = _demoRutinasSocio[i];
      if (r.idRutina == idRutina) {
        _demoRutinasSocio[i] = r.copyWith(estado: 'activo');
      } else {
        _demoRutinasSocio[i] = r.copyWith(estado: 'inactivo');
      }
    }

    final token = AuthService().token;
    try {
      final uri = Uri.parse('${ApiConfig.rutinasUrl}/$idRutina/activar');
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.put(uri, headers: headers).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return true; // Éxito local
    }
  }

  /// Actualiza series, repeticiones, peso o descanso de un ejercicio en una rutina
  Future<bool> updateEjercicioEnRutina({
    required int idRutina,
    required int idEjercicio,
    required int series,
    required int repeticiones,
    double? peso,
    int? descanso,
  }) async {
    final token = AuthService().token;
    try {
      final uri = Uri.parse('${ApiConfig.rutinasUrl}/$idRutina/ejercicios/$idEjercicio');
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final body = <String, dynamic>{
        'series': series,
        'repeticiones': repeticiones,
      };
      if (peso != null) body['peso'] = peso;
      if (descanso != null) body['descanso'] = descanso;

      final response = await http
          .put(
            uri,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

