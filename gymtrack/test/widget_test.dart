import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrack/main.dart';

void main() {
  testWidgets('GymTrackApp smoke test - verifies login and navigation to register', (WidgetTester tester) async {
    await tester.pumpWidget(const GymTrackApp());

    // 1. Verifica elementos de login
    expect(find.text('INICIAR SESION'), findsOneWidget);
    expect(find.text('REGISTRARSE'), findsOneWidget);
    expect(find.text('CORREO ELECTRONICO'), findsOneWidget);
    expect(find.text('CONTRASEÑA'), findsOneWidget);

    // 2. Toca "REGISTRARSE" para navegar a la pantalla de registro
    await tester.tap(find.text('REGISTRARSE'));
    await tester.pumpAndSettle();

    // 3. Verifica elementos de la pantalla de registro
    expect(find.text('REPETIR CONTRASEÑA'), findsOneWidget);
    expect(find.text('¿Ya tienes cuenta? Iniciar sesión'), findsOneWidget);
  });
}
