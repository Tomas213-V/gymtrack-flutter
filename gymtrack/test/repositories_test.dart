import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrack/models/pago_model.dart';
import 'package:gymtrack/repositories/ejercicio_repository.dart';
import 'package:gymtrack/repositories/progreso_repository.dart';
import 'package:gymtrack/repositories/socio_repository.dart';
import 'package:gymtrack/services/pago_service.dart';

void main() {
  group('PagoModel y PagoService Tests (Socio Name & Planes Dinámicos)', () {
    test('PagoModel.fromJson extrae correctamente el nombre del socio y del plan desde la respuesta de Supabase', () {
      final jsonSupabase = {
        'id_pago': 25,
        'fecha_pago': '2026-10-31',
        'monto': 22000,
        'estado': 'pagado',
        'metodo_pago': 'efectivo',
        'membresia': {
          'id_membresia': 10,
          'socio': {
            'id_socio': 14,
            'nombre': 'Ezequiel',
            'apellido': 'Maron',
            'dni': '40123456',
          },
          'plan_membresia': {
            'id_plan_membresia': 3,
            'nombre': 'Plan Musculación Libre',
            'precio': 22000,
          }
        }
      };

      final pago = PagoModel.fromJson(jsonSupabase);
      expect(pago.socioNombre, 'Ezequiel Maron');
      expect(pago.plan, 'Plan Musculación Libre');
      expect(pago.monto, 22000.0);
      expect(pago.isPagado, isTrue);
      expect(pago.formattedMonto, '\$22.000');
    });

    test('PagoService registrarPago agrega el pago dinámicamente y getPagos filtra por búsqueda', () async {
      final pagoService = PagoService();
      final registrado = await pagoService.registrarPago(
        socioNombre: 'Camila Rodriguez',
        monto: 18000,
        plan: 'Plan Mensual',
        metodoPago: 'Efectivo',
        estado: 'pagado',
      );
      expect(registrado, isTrue);

      final pagos = await pagoService.getPagos(search: 'Camila');
      expect(pagos.any((p) => p.socioNombre.contains('Camila')), isTrue);
    });
  });

  group('ProgresoRepository Tests (Capa de Datos y Gestión del Estado)', () {
    final repository = ProgresoRepository.instance;

    test('getPerfilProgreso y getRegistrosProgreso devuelven información inicial', () async {
      final perfil = await repository.getPerfilProgreso();
      expect(perfil.nombre, 'Luciano');
      expect(perfil.pesoActual, greaterThan(0));

      final registros = await repository.getRegistrosProgreso();
      expect(registros.isNotEmpty, isTrue);

      final puntos = await repository.getPuntosGrafico();
      expect(puntos.isNotEmpty, isTrue);
    });

    test('registrarProgreso actualiza el historial y recalcula métricas de peso', () async {
      final perfilPrevio = await repository.getPerfilProgreso();
      final conteoPrevio = (await repository.getRegistrosProgreso()).length;

      final nuevoRegistro = await repository.registrarProgreso(
        peso: 76.5,
        fecha: '30 Oct 2026',
        nota: 'Prueba de integración de arquitectura',
        pecho: 101.5,
        cintura: 81.0,
      );

      expect(nuevoRegistro.peso, 76.5);
      expect(nuevoRegistro.nota, 'Prueba de integración de arquitectura');

      // Verificar que el listado incrementó
      final registrosActuales = await repository.getRegistrosProgreso();
      expect(registrosActuales.length, conteoPrevio + 1);
      expect(registrosActuales.first.peso, 76.5);

      // Verificar que el perfil actualizó el peso actual y recalculó el cambio total
      final perfilActual = await repository.getPerfilProgreso();
      expect(perfilActual.pesoActual, 76.5);
      expect(perfilActual.cambioTotal, 76.5 - perfilPrevio.pesoInicial);
    });
  });

  group('EjercicioRepository Tests', () {
    final repository = EjercicioRepository.instance;

    test('getEjerciciosSocio devuelve catálogo con filtros', () async {
      final todos = await repository.getEjerciciosSocio();
      expect(todos.isNotEmpty, isTrue);

      final pecho = await repository.getEjerciciosSocio(grupoMuscular: 'Pecho');
      expect(pecho.every((e) => e.grupoMuscular?.toLowerCase() == 'pecho'), isTrue);

      final gimnasio = await repository.getEjerciciosSocio(origen: 'gimnasio');
      expect(gimnasio.every((e) => e.esPropio == false), isTrue);
    });
  });

  group('SocioRepository Tests', () {
    final repository = SocioRepository.instance;

    test('getStats y getSocios funcionan con datos simulados y backend fallback', () async {
      final stats = await repository.getStats();
      expect(stats.total, greaterThanOrEqualTo(0));

      final result = await repository.getSocios(page: 1, limit: 5);
      expect(result.containsKey('socios'), isTrue);
    });
  });
}

