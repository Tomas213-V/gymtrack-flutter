import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrack/models/video_model.dart';
import 'package:gymtrack/repositories/ejercicio_repository.dart';
import 'package:gymtrack/repositories/progreso_repository.dart';
import 'package:gymtrack/repositories/socio_repository.dart';
import 'package:gymtrack/repositories/video_repository.dart';

void main() {
  group('VideoRepository Tests (Capa de Datos y Mocks Dinámicos)', () {
    final repository = VideoRepository.instance;

    test('getVideos retorna la lista de videos y categorías', () async {
      final videos = await repository.getVideos();
      expect(videos.isNotEmpty, isTrue);

      final categorias = await repository.getCategorias();
      expect(categorias, contains('Pecho'));
      expect(categorias, contains('Piernas'));
    });

    test('getVideos filtra correctamente por categoría', () async {
      final videosPecho = await repository.getVideos(categoria: 'Pecho');
      expect(videosPecho.every((v) => v.categoria.toLowerCase() == 'pecho'), isTrue);
    });

    test('getVideos busca por término de búsqueda (query)', () async {
      final resultados = await repository.getVideos(query: 'Banca');
      expect(resultados.isNotEmpty, isTrue);
      expect(resultados.any((v) => v.titulo.contains('Banca')), isTrue);
    });

    test('addVideo, updateVideo y deleteVideo modifican datos dinámicamente', () async {
      final nuevoVideo = VideoModel(
        id: 'vid-test-repo',
        titulo: 'Video de Prueba Repositorio',
        descripcion: 'Descripción del video de prueba para la arquitectura',
        categoria: 'Hombros',
        duracion: '04:30',
      );

      // 1. Agregar video
      await repository.addVideo(nuevoVideo);
      var videos = await repository.getVideos();
      expect(videos.any((v) => v.id == 'vid-test-repo'), isTrue);

      // 2. Actualizar video
      final videoModificado = nuevoVideo.copyWith(titulo: 'Video de Prueba Modificado');
      await repository.updateVideo(videoModificado);
      final obtenido = await repository.getVideoById('vid-test-repo');
      expect(obtenido?.titulo, 'Video de Prueba Modificado');

      // 3. Eliminar video
      final eliminado = await repository.deleteVideo('vid-test-repo');
      expect(eliminado, isTrue);
      videos = await repository.getVideos();
      expect(videos.any((v) => v.id == 'vid-test-repo'), isFalse);
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

