import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrack/screens/login_screen.dart';
import 'package:gymtrack/screens/socio/dashboard_socio_screen.dart';
import 'package:gymtrack/screens/socio/detalle_ejercicio_screen.dart';
import 'package:gymtrack/screens/socio/login_socio_screen.dart';
import 'package:gymtrack/screens/socio/mas_socio_screen.dart';
import 'package:gymtrack/screens/socio/mi_membresia_screen.dart';
import 'package:gymtrack/screens/socio/mi_progreso_screen.dart';
import 'package:gymtrack/screens/socio/mi_rutina_screen.dart';
import 'package:gymtrack/screens/socio/perfil_socio_screen.dart';
import 'package:gymtrack/screens/socio/registrar_progreso_screen.dart';
import 'package:gymtrack/screens/socio/socio_main_layout_screen.dart';
import 'package:gymtrack/theme/app_theme.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  Widget createWidgetForTesting({required Widget child}) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: child,
    );
  }

  void configureMobileViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  testWidgets('Navigation from LoginScreen to LoginSocioScreen via "¿Eres socio?"', (WidgetTester tester) async {
    configureMobileViewport(tester);
    await tester.pumpWidget(createWidgetForTesting(child: const LoginScreen()));
    await tester.pumpAndSettle();

    final eresSocioFinder = find.text('¿Eres socio?');
    expect(eresSocioFinder, findsOneWidget);

    await tester.tap(eresSocioFinder);
    await tester.pumpAndSettle();

    expect(find.byType(LoginSocioScreen), findsOneWidget);
    expect(find.text('Número de socio'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('DNI'), findsOneWidget);
    expect(find.text('Ingresar'), findsOneWidget);
    expect(find.text('Volver al acceso de administrador'), findsOneWidget);
  });

  testWidgets('LoginSocioScreen back button returns to previous screen', (WidgetTester tester) async {
    configureMobileViewport(tester);
    await tester.pumpWidget(createWidgetForTesting(child: const LoginScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('¿Eres socio?'));
    await tester.pumpAndSettle();

    final volverFinder = find.text('Volver al acceso de administrador');
    await tester.ensureVisible(volverFinder);
    await tester.tap(volverFinder);
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('LoginSocioScreen login navigates to SocioMainLayoutScreen', (WidgetTester tester) async {
    configureMobileViewport(tester);
    await tester.pumpWidget(createWidgetForTesting(child: const LoginSocioScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ingresar'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.byType(SocioMainLayoutScreen), findsOneWidget);
    expect(find.text('¡Hola, Luciano! 👋'), findsOneWidget);
  });

  testWidgets('DashboardSocioScreen displays membership, quick actions, and progress', (WidgetTester tester) async {
    configureMobileViewport(tester);
    await tester.pumpWidget(createWidgetForTesting(child: const DashboardSocioScreen()));
    await tester.pumpAndSettle();

    expect(find.text('¡Hola, Luciano! 👋'), findsOneWidget);
    expect(find.text('Bienvenido a tu gimnasio'), findsOneWidget);
    expect(find.text('Membresía'), findsWidgets);
    expect(find.text('Activa'), findsOneWidget);
    expect(find.text('15 Jun 2026'), findsOneWidget);
    expect(find.text('Acciones rápidas'), findsOneWidget);
    expect(find.text('Mi Rutina'), findsOneWidget);
    expect(find.text('Progreso'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('Resumen de progreso'), findsOneWidget);
    expect(find.text('78 kg'), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
  });

  testWidgets('MiRutinaScreen renders routine details and navigates to DetalleEjercicio', (WidgetTester tester) async {
    configureMobileViewport(tester);
    await tester.pumpWidget(createWidgetForTesting(child: const MiRutinaScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Mi Rutina'), findsOneWidget);
    expect(find.text('Fuerza - Nivel Intermedio'), findsOneWidget);
    expect(find.text('Asignada por: Prof. Martín'), findsOneWidget);
    expect(find.text('DÍAS DE ENTRENAMIENTO'), findsOneWidget);
    expect(find.text('Ejercicios de hoy'), findsOneWidget);
    expect(find.text('Press de banca'), findsOneWidget);
    expect(find.text('Sentadillas'), findsOneWidget);

    // Tap on Press de banca
    await tester.tap(find.text('Press de banca'));
    await tester.pumpAndSettle();

    expect(find.byType(DetalleEjercicioScreen), findsOneWidget);
    expect(find.text('Detalle del ejercicio'), findsOneWidget);
    expect(find.text('Pecho'), findsOneWidget);
    expect(find.text('Fuerza'), findsOneWidget);
    expect(find.text('INSTRUCCIONES'), findsOneWidget);
    expect(find.text('SERIES'), findsOneWidget);
    expect(find.text('REPETICIONES'), findsOneWidget);
    expect(find.text('PESO'), findsOneWidget);
    expect(find.text('DESCANSO'), findsOneWidget);

    // Tap Marcar como realizado
    final marcarBtn = find.text('Marcar como realizado');
    expect(marcarBtn, findsOneWidget);
    await tester.tap(marcarBtn);
    await tester.pumpAndSettle();

    expect(find.text('Ejercicio realizado'), findsOneWidget);
  });

  testWidgets('MiProgresoScreen renders charts and navigates to RegistrarProgresoScreen', (WidgetTester tester) async {
    configureMobileViewport(tester);
    await tester.pumpWidget(createWidgetForTesting(child: const MiProgresoScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Mi Progreso'), findsOneWidget);
    expect(find.text('PESO ACTUAL'), findsOneWidget);
    expect(find.text('PESO INICIAL'), findsOneWidget);
    expect(find.text('CAMBIO TOTAL'), findsOneWidget);
    expect(find.text('Evolución de peso'), findsOneWidget);
    expect(find.text('Historial de registros'), findsOneWidget);

    // Open registrar progreso via + button
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(RegistrarProgresoScreen), findsOneWidget);
    expect(find.text('Registrar progreso'), findsWidgets);
    expect(find.text('Peso (kg)'), findsOneWidget);
    expect(find.text('Fecha'), findsOneWidget);
    expect(find.text('Medidas opcionales'), findsOneWidget);
    expect(find.text('Observaciones'), findsOneWidget);

    // Submit new progress
    final submitButton = find.widgetWithText(ElevatedButton, 'Registrar progreso');
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    // Should return back to MiProgresoScreen
    expect(find.byType(MiProgresoScreen), findsOneWidget);
  });

  testWidgets('MiMembresiaScreen displays plan details and payment history', (WidgetTester tester) async {
    configureMobileViewport(tester);
    await tester.pumpWidget(createWidgetForTesting(child: const MiMembresiaScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Mi Membresía'), findsOneWidget);
    expect(find.text('Premium Plan'), findsOneWidget);
    expect(find.text('\$12,500 / mes'), findsOneWidget);
    expect(find.text('INICIO'), findsOneWidget);
    expect(find.text('15 Dic 2025'), findsOneWidget);
    expect(find.text('VENCIMIENTO'), findsOneWidget);
    expect(find.text('15 Jun 2026'), findsOneWidget);
    expect(find.text('Días restantes de acceso'), findsOneWidget);
    expect(find.text('120 días'), findsOneWidget);
    expect(find.text('Historial de pagos'), findsOneWidget);
    expect(find.text('15 May 2026'), findsOneWidget);
    expect(find.text('Tarjeta de Crédito'), findsWidgets);
    expect(find.text('Pagado'), findsWidgets);
  });

  testWidgets('MasSocioScreen renders all options and navigates to PerfilSocioScreen', (WidgetTester tester) async {
    configureMobileViewport(tester);
    await tester.pumpWidget(createWidgetForTesting(child: const MasSocioScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Más'), findsOneWidget);
    expect(find.text('Mi perfil'), findsOneWidget);
    expect(find.text('Mi membresía'), findsOneWidget);
    expect(find.text('Mis pagos'), findsOneWidget);
    expect(find.text('Mis rutinas'), findsOneWidget);
    expect(find.text('Mi progreso'), findsOneWidget);
    expect(find.text('Configuración'), findsOneWidget);
    expect(find.text('Ayuda y soporte'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);

    // Navigate to profile
    await tester.tap(find.text('Mi perfil'));
    await tester.pumpAndSettle();

    expect(find.byType(PerfilSocioScreen), findsOneWidget);
    expect(find.text('Luciano García'), findsOneWidget);
    expect(find.text('Socio GTM-1024'), findsOneWidget);
    expect(find.text('luciano@email.com'), findsOneWidget);
    expect(find.text('+54 11 5555-1234'), findsOneWidget);
    expect(find.text('41.234.567'), findsOneWidget);
  });

  testWidgets('SocioMainLayoutScreen switches between all 5 bottom tabs', (WidgetTester tester) async {
    configureMobileViewport(tester);
    await tester.pumpWidget(createWidgetForTesting(child: const SocioMainLayoutScreen()));
    await tester.pumpAndSettle();

    // Initial is Inicio (Dashboard)
    expect(find.text('¡Hola, Luciano! 👋'), findsOneWidget);

    // Tap Rutina
    await tester.tap(find.text('Rutina'));
    await tester.pumpAndSettle();
    expect(find.text('Fuerza - Nivel Intermedio'), findsOneWidget);

    // Tap Progreso
    await tester.tap(find.text('Progreso'));
    await tester.pumpAndSettle();
    expect(find.text('Evolución de peso'), findsOneWidget);

    // Tap Membresía
    await tester.tap(find.text('Membresía'));
    await tester.pumpAndSettle();
    expect(find.text('Premium Plan'), findsOneWidget);

    // Tap Más
    await tester.tap(find.text('Más'));
    await tester.pumpAndSettle();
    expect(find.text('Cerrar sesión'), findsOneWidget);
  });
}
