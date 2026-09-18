import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrack/mock/video_mock_data.dart';
import 'package:gymtrack/models/video_model.dart';
import 'package:gymtrack/screens/dueno/videos/agregar_video_screen.dart';
import 'package:gymtrack/screens/dueno/videos/editar_video_screen.dart';
import 'package:gymtrack/screens/dueno/videos/videos_dueno_screen.dart';
import 'package:gymtrack/screens/socio/videos/detalle_video_screen.dart';
import 'package:gymtrack/screens/socio/videos/videos_socio_screen.dart';
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

  group('Videos - DUEÑO Tests', () {
    testWidgets('VideosDuenoScreen renders list, management buttons, and FAB', (WidgetTester tester) async {
      configureMobileViewport(tester);
      await tester.pumpWidget(createWidgetForTesting(child: const VideosDuenoScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Videos'), findsOneWidget);
      expect(find.text('Administrá el contenido para tus socios'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Verify management buttons exist for Dueño
      expect(find.text('Editar'), findsWidgets);
      expect(find.text('Eliminar'), findsWidgets);
      expect(find.text('Técnica de Press de Banca'), findsOneWidget);
    });

    testWidgets('Dueño can add a new video via AgregarVideoScreen', (WidgetTester tester) async {
      configureMobileViewport(tester);
      await tester.pumpWidget(createWidgetForTesting(child: const VideosDuenoScreen()));
      await tester.pumpAndSettle();

      // Tap on FAB '+'
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(AgregarVideoScreen), findsOneWidget);
      expect(find.text('Agregar Video'), findsOneWidget);
      expect(find.text('Título del video *'), findsOneWidget);
      expect(find.text('Categoría *'), findsOneWidget);
      expect(find.text('Duración (mm:ss) *'), findsOneWidget);
      expect(find.text('Publicar video'), findsOneWidget);

      // Fill in title
      final titleField = find.widgetWithText(TextFormField, 'Ej: Técnica de Press de Banca');
      await tester.enterText(titleField, 'Video Test Nuevo');

      // Submit
      final submitBtn = find.text('Publicar video');
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Returned to VideosDuenoScreen with newly added video
      expect(find.byType(VideosDuenoScreen), findsOneWidget);
      expect(find.text('Video Test Nuevo'), findsOneWidget);
    });

    testWidgets('Dueño can edit an existing video via EditarVideoScreen', (WidgetTester tester) async {
      configureMobileViewport(tester);
      await tester.pumpWidget(createWidgetForTesting(child: const VideosDuenoScreen()));
      await tester.pumpAndSettle();

      // Tap first edit button
      final editButtons = find.text('Editar');
      expect(editButtons, findsWidgets);
      await tester.tap(editButtons.first);
      await tester.pumpAndSettle();

      expect(find.byType(EditarVideoScreen), findsOneWidget);
      expect(find.text('Editar Video'), findsOneWidget);
      expect(find.text('Guardar cambios'), findsOneWidget);

      // Submit changes
      await tester.tap(find.text('Guardar cambios'));
      await tester.pumpAndSettle();

      expect(find.byType(VideosDuenoScreen), findsOneWidget);
    });

    testWidgets('Dueño can delete a video with confirmation dialog', (WidgetTester tester) async {
      configureMobileViewport(tester);

      // Add a dedicated temporary video to test deletion
      VideoMockData().addVideo(
        VideoModel(
          id: 'vid-temp-delete',
          titulo: 'Video Para Borrar',
          categoria: 'General',
          duracion: '02:00',
          descripcion: 'Temporal',
        ),
      );

      await tester.pumpWidget(createWidgetForTesting(child: const VideosDuenoScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Video Para Borrar'), findsOneWidget);

      // Find the delete button for this video
      final deleteButtons = find.text('Eliminar');
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      // Confirm dialog appeared
      expect(find.text('¿Eliminar video?'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);

      // Tap 'Eliminar' in dialog
      final confirmDelete = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Eliminar'),
      );
      await tester.tap(confirmDelete);
      await tester.pumpAndSettle();

      expect(find.text('Video eliminado correctamente'), findsOneWidget);
      expect(find.text('Video Para Borrar'), findsNothing);
    });
  });

  group('Videos - SOCIO Tests', () {
    testWidgets('VideosSocioScreen shows read-only video list and NO admin buttons', (WidgetTester tester) async {
      configureMobileViewport(tester);
      await tester.pumpWidget(createWidgetForTesting(child: const VideosSocioScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Videos'), findsOneWidget);
      expect(find.text('Aprendé y mejorá tu técnica'), findsOneWidget);

      // Verify search and category filter chips
      expect(find.widgetWithText(ChoiceChip, 'Todos'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Pecho'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Piernas'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Espalda'), findsOneWidget);

      // STRICT PERMISSION CHECK: Socio must NOT have admin buttons
      expect(find.text('Editar'), findsNothing);
      expect(find.text('Eliminar'), findsNothing);
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('Socio can filter videos by category', (WidgetTester tester) async {
      configureMobileViewport(tester);
      await tester.pumpWidget(createWidgetForTesting(child: const VideosSocioScreen()));
      await tester.pumpAndSettle();

      // Initially shows Press de banca (Pecho)
      expect(find.text('Técnica de Press de Banca'), findsOneWidget);

      // Tap on Piernas category chip specifically
      final piernasChip = find.widgetWithText(ChoiceChip, 'Piernas');
      await tester.tap(piernasChip);
      await tester.pumpAndSettle();

      // Should show Sentadilla (Piernas) and not Press de banca
      expect(find.text('Cómo realizar una Sentadilla correctamente'), findsOneWidget);
      expect(find.text('Técnica de Press de Banca'), findsNothing);
    });

    testWidgets('Socio can view DetalleVideoScreen and simulate playback', (WidgetTester tester) async {
      configureMobileViewport(tester);
      await tester.pumpWidget(createWidgetForTesting(child: const VideosSocioScreen()));
      await tester.pumpAndSettle();

      // Tap on first video
      await tester.tap(find.text('Técnica de Press de Banca'));
      await tester.pumpAndSettle();

      expect(find.byType(DetalleVideoScreen), findsOneWidget);
      expect(find.text('Detalle del video'), findsOneWidget);
      expect(find.text('Técnica de Press de Banca'), findsOneWidget);
      expect(find.text('DESCRIPCIÓN'), findsOneWidget);
      expect(find.text('INFORMACIÓN DEL EJERCICIO'), findsOneWidget);
      expect(find.text('Reproducir video'), findsOneWidget);

      // Tap Reproducir video
      await tester.tap(find.text('Reproducir video'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Reproduciendo'), findsOneWidget);
    });
  });
}
