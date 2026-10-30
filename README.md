# 🏋️ GymTrack - Sistema Integral de Gestión para Gimnasios y Socios

GymTrack es una aplicación móvil desarrollada en **Flutter** diseñada para digitalizar, optimizar y dinamizar la relación entre los centros de entrenamiento (dueños/administradores) y sus miembros (socios).

---

## 🎯 Pitch del Proyecto: ¿Qué es GymTrack y para quién está diseñado?

### 💡 El Problema
La mayoría de los gimnasios de barrio e independientes enfrentan tres grandes fricciones:
1. **Pérdida de control y desorganización**: Gestión manual o en planillas de cálculo de pagos, vencimientos y asistencias.
2. **Falta de retención y desconexión con el socio**: Los socios no tienen fácil acceso a sus rutinas, pierden la técnica adecuada de los ejercicios y no ven reflejada la evolución de su peso y medidas.
3. **Poco valor agregado digital**: Procesos lentos de check-in y barreras para consultar membresías disponibles o planes vigentes.

### 🚀 La Solución: GymTrack
GymTrack ofrece una experiencia dual en una única aplicación:
- **Portal del Dueño / Administrador**: Monitoreo de socios, control de estados de membresía, gestión de caja/pagos, check-in mediante código QR y publicación/administración de contenidos (catálogo de videos técnicos y rutinas).
- **Portal del Socio**: Acceso a su credencial digital interactiva, seguimiento antropométrico y gráfico de peso, visualización interactiva de su rutina diaria con checkboxes de progreso, y biblioteca audiovisual de técnica de ejercicios.

---

## 🏛️ Arquitectura del Software (Tema 1: Arquitectura y Capa de Datos)

El proyecto fue estructurado aplicando una **Arquitectura en Capas Limpia (Layered Clean Architecture)** que asegura una estricta separación de responsabilidades (*Separation of Concerns*), eliminando el acoplamiento y sacando toda la lógica de datos de los Widgets visuales.

```
gymtrack/lib/
├── models/             # [CAPA DE DATOS / DOMINIO] Entidades y Modelos de Datos fuertemente tipados
│   ├── user_model.dart             -> Usuario y Gimnasio
│   ├── socio_model.dart            -> Socio administrativo y estados
│   ├── socio_mock_models.dart      -> Perfil, Pagos, Rutinas y Progreso
│   ├── video_model.dart            -> Entidad de Videos técnicos
│   ├── ejercicio_model.dart        -> Entidad de Ejercicios musculares
│   ├── rutina_model.dart           -> Rutinas y series de entrenamiento
│   ├── plan_membresia_model.dart   -> Planes y membresías
│   ├── pago_model.dart             -> Transacciones y comprobantes
│   └── models.dart                 -> Barrel export unificado
│
├── repositories/       # [CAPA DE REPOSITORIOS] Patrón Repository (Single Source of Truth)
│   ├── video_repository.dart       -> IVideoRepository & VideoRepository (CRUD dinámico de videos)
│   ├── progreso_repository.dart    -> IProgresoRepository & ProgresoRepository (Evolución de peso)
│   ├── ejercicio_repository.dart   -> IEjercicioRepository & EjercicioRepository (Catálogo y filtros)
│   ├── socio_repository.dart       -> ISocioRepository & SocioRepository (Socios y métricas)
│   ├── rutina_repository.dart      -> IRutinaRepository & RutinaRepository (Rutina activa)
│   ├── membresia_repository.dart   -> IMembresiaRepository & MembresiaRepository (Membresía/Pagos)
│   └── repositories.dart           -> Barrel export unificado
│
├── data/               # [CAPA DE DATOS CONSOLIDADA] Exportador central de datos para la aplicación
│   └── data.dart
│
├── services/           # [DATA SOURCES REMOTOS] Conexión HTTP REST API hacia el backend
│   ├── api_config.dart
│   ├── auth_service.dart
│   ├── socio_service.dart
│   ├── ejercicio_service.dart
│   └── socio_dashboard_service.dart
│
├── mock/               # [DATA SOURCES LOCALES] In-Memory Dynamic Mocks con persistencia en tiempo de ejecución
│   ├── video_mock_data.dart        -> Simulación reactiva del catálogo de videos
│   └── socio_mock_data.dart        -> Simulación de perfil, progreso, gráfico y rutinas
│
├── screens/            # [CAPA DE PRESENTACIÓN] Pantallas de la aplicación (UI)
│   ├── login_screen.dart           -> Acceso principal (Administrador)
│   ├── register_screen.dart        -> Registro de administrador
│   ├── dueno/                      -> Módulo Dueño/Administrador
│   │   ├── videos/                 -> VideosDuenoScreen, AgregarVideoScreen, EditarVideoScreen
│   │   ├── ejercicios/             -> EjerciciosScreen
│   │   ├── socios_screen.dart      -> Gestión de socios
│   │   └── ...
│   └── socio/                      -> Módulo Socio
│       ├── login_socio_screen.dart -> Acceso con DNI y credenciales
│       ├── socio_main_layout_screen.dart -> Navegación por tabs
│       ├── dashboard_socio_screen.dart   -> Resumen de bienvenida y Check-in QR
│       ├── mi_progreso_screen.dart       -> Estadísticas, gráfico y pesajes
│       ├── registrar_progreso_screen.dart -> Formulario dinámico de pesaje
│       ├── mi_rutina_screen.dart         -> Rutina del día
│       ├── mi_membresia_screen.dart      -> Planes y pagos
│       ├── ejercicios/                   -> SocioEjerciciosScreen
│       └── videos/                       -> VideosSocioScreen, DetalleVideoScreen
│
├── widgets/            # [COMPONENTES VISUALES] Widgets reutilizables y modulares
│   ├── custom_text_field.dart
│   ├── google_button.dart
│   ├── dueno/
│   └── socio/                      -> SocioBadge, SocioWeightChart, QrCheckinDialog
│
└── theme/              # [DISEÑO & ESTILOS] Paleta cromática, tipografías y tema oscuro moderno
    └── app_theme.dart
```

---

## 📦 Flujos Dinámicos Implementados

### 1. Flujo Completo de Videos (Dueño + Socio)
- **Dueño (`VideosDuenoScreen`)**: Consume `VideoRepository`. Permite ver la lista dinámica, agregar nuevos videos (`AgregarVideoScreen`), editar videos existentes (`EditarVideoScreen`) y eliminarlos con confirmación modal.
- **Socio (`VideosSocioScreen`)**: Consume `VideoRepository`. Permite filtrar dinámicamente mediante chips de categoría (*Pecho, Espalda, Piernas, etc.*), realizar búsquedas por texto en tiempo real y abrir el reproductor/detalle del video (`DetalleVideoScreen`).

### 2. Flujo Completo de Progreso del Socio (`MiProgresoScreen` + `RegistrarProgresoScreen`)
- Consume `ProgresoRepository`.
- Visualiza tarjetas con métricas calculadas (*Peso Actual, Peso Inicial, Cambio Total*).
- Renderiza el gráfico interactivo de curvas de peso (`SocioWeightChart`).
- Al presionar **Registrar Progreso**, el socio introduce su peso y notas; el repositorio inserta el nuevo registro en memoria, recalcula las métricas automáticamente y la pantalla se actualiza de forma reactiva con `setState()`.

### 3. Flujo de Biblioteca de Ejercicios (`SocioEjerciciosScreen`)
- Consume `EjercicioRepository`.
- Filtra por origen (*Gimnasio* vs *Mis Ejercicios propios*) y por grupo muscular.
- Permite crear nuevos ejercicios propios que se reflejan de inmediato en la biblioteca.

---

## 🧪 Pruebas Automatizadas (Unit & Widget Tests)

El proyecto cuenta con **37 pruebas automatizadas** que garantizan la integridad de la arquitectura y la interfaz:

```bash
flutter test
```

---

## 🚀 Cómo ejecutar la aplicación

```bash
cd gymtrack
flutter pub get
flutter test
flutter run
```

