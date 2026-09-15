import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrack/models/user_model.dart';
import 'package:gymtrack/screens/gym_setup_screen.dart';
import 'package:gymtrack/screens/main_layout_screen.dart';
import 'package:gymtrack/screens/pagos_screen.dart';
import 'package:gymtrack/screens/socios_screen.dart';

void main() {
  final userWithoutGym = UserModel(
    idUsuario: 1,
    nombre: 'Carlos',
    apellido: 'Dueño',
    email: 'carlos@gymtrack.com',
    rol: 'dueño',
    gimnasio: null,
  );

  final userWithGym = UserModel(
    idUsuario: 2,
    nombre: 'Laura',
    apellido: 'Admin',
    email: 'laura@gymtrack.com',
    rol: 'dueño',
    gimnasio: GymModel(
      idGimnasio: 10,
      nombre: 'Iron Fitness',
      direccion: 'Av Central 123',
    ),
  );

  testWidgets('GymSetupScreen renders all gym fields and CTA', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: GymSetupScreen(user: userWithoutGym),
      ),
    );

    expect(find.text('¡Bienvenido a GymTrack!'), findsOneWidget);
    expect(find.text('NOMBRE DEL GIMNASIO *'), findsOneWidget);
    expect(find.text('DIRECCIÓN'), findsOneWidget);
    expect(find.text('TELÉFONO DE CONTACTO'), findsOneWidget);
    expect(find.text('REGISTRAR Y ENTRAR AL DASHBOARD'), findsOneWidget);
  });

  testWidgets('SociosScreen renders metrics, tabs and new socio button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SociosScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Socios'), findsWidgets);
    expect(find.text('Nuevo socio'), findsOneWidget);
    expect(find.text('Total socios'), findsOneWidget);
    expect(find.text('Activos'), findsWidgets);
    expect(find.text('Pendientes'), findsWidgets);
    expect(find.text('Inactivos'), findsWidgets);
    expect(find.text('Todos'), findsOneWidget);
  });

  testWidgets('PagosScreen renders quick actions and resumen card', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: PagosScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Registrar pago'), findsOneWidget);
    expect(find.text('Estado de cuota'), findsOneWidget);
    expect(find.text('Pagos recientes'), findsOneWidget);
    expect(find.text('Resumen de pagos'), findsOneWidget);
    expect(find.text('Total recaudado'), findsOneWidget);
    expect(find.text('Pagos realizados'), findsOneWidget);
  });

  testWidgets('MainLayoutScreen renders bottom navigation and switches tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MainLayoutScreen(user: userWithGym),
      ),
    );
    await tester.pumpAndSettle();

    // Verify bottom nav items exist
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Socios'), findsOneWidget);
    expect(find.text('Pagos'), findsOneWidget);
    expect(find.text('Asistencia'), findsOneWidget);
    expect(find.text('Más'), findsOneWidget);

    // Tap on Socios tab
    await tester.tap(find.text('Socios'));
    await tester.pumpAndSettle();

    expect(find.text('Nuevo socio'), findsOneWidget);

    // Tap on Pagos tab
    await tester.tap(find.text('Pagos'));
    await tester.pumpAndSettle();

    expect(find.text('Registrar pago'), findsOneWidget);
  });
}
