import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrack/screens/asistencia_screen.dart';
import 'package:gymtrack/screens/socio/dashboard_socio_screen.dart';
import 'package:gymtrack/screens/socio/mi_membresia_screen.dart';
import 'package:gymtrack/screens/socio/planes_disponibles_screen.dart';
import 'package:gymtrack/widgets/dueno/qr_gimnasio_dialog.dart';
import 'package:gymtrack/widgets/socio/qr_checkin_dialog.dart';

void main() {
  group('Socio Membresía & QR Tests', () {
    testWidgets('DashboardSocioScreen displays greeting, membership, and QR Check-in action', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardSocioScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('¡Hola,'), findsOneWidget);
      expect(find.text('Membresía'), findsWidgets);
      expect(find.text('Check-in con QR'), findsOneWidget);
      expect(find.text('Check-in QR'), findsOneWidget);
      expect(find.byIcon(Icons.qr_code_scanner_rounded), findsWidgets);
    });

    testWidgets('DashboardSocioScreen opens QrCheckinDialog when tapping QR Check-in banner', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardSocioScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final qrBanner = find.text('Check-in con QR');
      expect(qrBanner, findsOneWidget);
      await tester.tap(qrBanner);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));


      expect(find.byType(QrCheckinDialog), findsOneWidget);
      expect(find.text('Check-in de Asistencia'), findsOneWidget);
      expect(find.text('Escaneá el código QR del gimnasio'), findsOneWidget);
    });

    testWidgets('MiMembresiaScreen renders membership details and button to view plans', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      await tester.pumpWidget(
        const MaterialApp(
          home: MiMembresiaScreen(showBackButton: true),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mi Membresía'), findsOneWidget);
      expect(find.text('Ver Planes / Renovar Membresía'), findsOneWidget);
      expect(find.text('Historial de pagos'), findsOneWidget);
    });

    testWidgets('MiMembresiaScreen navigates to PlanesDisponiblesScreen', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      await tester.pumpWidget(
        const MaterialApp(
          home: MiMembresiaScreen(showBackButton: true),
        ),
      );
      await tester.pumpAndSettle();

      final verPlanesBtn = find.text('Ver Planes / Renovar Membresía');
      expect(verPlanesBtn, findsOneWidget);
      await tester.tap(verPlanesBtn);
      await tester.pumpAndSettle();

      expect(find.byType(PlanesDisponiblesScreen), findsOneWidget);
      expect(find.text('Planes Disponibles'), findsOneWidget);
      expect(find.text('Plan Básico'), findsOneWidget);
      expect(find.text('Plan Premium'), findsOneWidget);
    });

    testWidgets('PlanesDisponiblesScreen shows plan list and opens payment modal', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      await tester.pumpWidget(
        const MaterialApp(
          home: PlanesDisponiblesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Planes Disponibles'), findsOneWidget);
      expect(find.text('Plan Básico'), findsOneWidget);

      final elegirPlanBtn = find.text('Elegir y Activar Plan').first;
      await tester.tap(elegirPlanBtn);
      await tester.pumpAndSettle();

      expect(find.text('Confirmar Plan y Pago'), findsOneWidget);
      expect(find.text('Mercado Pago / Tarjeta'), findsOneWidget);
      expect(find.text('Efectivo en Mostrador'), findsOneWidget);
      expect(find.text('Confirmar y Activar Membresía'), findsOneWidget);
    });

    testWidgets('QrGimnasioDialog renders gym attendance QR for owner', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QrGimnasioDialog(
              idGimnasio: 1,
              nombreGimnasio: 'GymTrack Fitness Club',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('QR de Asistencia'), findsOneWidget);
      expect(find.text('GymTrack Fitness Club'), findsOneWidget);
      expect(find.text('Copiar'), findsOneWidget);
      expect(find.text('Listo'), findsOneWidget);
    });

    testWidgets('AsistenciaScreen has QR Check-in button to display gym QR', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      await tester.pumpWidget(
        const MaterialApp(
          home: AsistenciaScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Asistencia'), findsOneWidget);
      expect(find.text('QR Check-in'), findsOneWidget);

      await tester.tap(find.text('QR Check-in'));
      await tester.pumpAndSettle();

      expect(find.byType(QrGimnasioDialog), findsOneWidget);
      expect(find.text('QR de Asistencia'), findsOneWidget);
    });
  });
}
