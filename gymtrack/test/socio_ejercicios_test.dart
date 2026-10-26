import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrack/screens/socio/ejercicios/socio_ejercicios_screen.dart';
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

  testWidgets('SocioEjerciciosScreen renders metrics, filters, and list of exercises', (WidgetTester tester) async {
    configureMobileViewport(tester);
    await tester.pumpWidget(createWidgetForTesting(child: const SocioEjerciciosScreen()));
    await tester.pumpAndSettle();

    // Verify Title & Metrics
    expect(find.text('Biblioteca de Ejercicios'), findsOneWidget);
    expect(find.text('TOTAL'), findsOneWidget);
    expect(find.text('DEL GIMNASIO'), findsOneWidget);
    expect(find.text('MIS EJERCICIOS'), findsOneWidget);

    // Verify Search & Origin Filters
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Buscar ejercicio por nombre...'), findsOneWidget);
    expect(find.textContaining('Todos ('), findsOneWidget);
    expect(find.textContaining('Gimnasio ('), findsOneWidget);
    expect(find.textContaining('Mis Ejercicios ('), findsOneWidget);

    // Verify Floating Action Button to create custom exercise
    expect(find.text('Crear Ejercicio'), findsOneWidget);

    // Tap on FAB to open creation modal
    await tester.tap(find.text('Crear Ejercicio'));
    await tester.pumpAndSettle();

    // Verify modal elements
    expect(find.text('Nuevo Ejercicio Propio'), findsOneWidget);
    expect(find.text('NOMBRE DEL EJERCICIO *'), findsOneWidget);
    expect(find.text('GRUPO MUSCULAR'), findsOneWidget);
    expect(find.text('DIFICULTAD'), findsOneWidget);
    expect(find.text('DESCRIPCIÓN / NOTAS (OPCIONAL)'), findsOneWidget);
    expect(find.text('Guardar'), findsOneWidget);

    // Tap Cancel
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Nuevo Ejercicio Propio'), findsNothing);
  });
}
