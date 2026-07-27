# Finanzas App Mobile

Aplicación Flutter para la gestión de finanzas personales desde una interfaz móvil moderna, modular y centrada en la experiencia de usuario.

> Estado del proyecto: desarrollo activo.

## Descripción del proyecto

Finanzas App Mobile resuelve la necesidad de registrar, consultar y organizar información financiera personal desde una app Flutter.

La aplicación permite administrar ingresos, gastos, estadísticas, perfil de usuario y preferencias visuales, con sincronización contra un backend externo PHP/MySQL.

## Funcionalidades verificadas

- Registro e inicio de sesión.
- Persistencia de sesión con `SharedPreferences`.
- Validación y limpieza automática de sesiones locales incompletas.
- Recordar credenciales de acceso.
- Dashboard financiero con resumen general.
- Gestión de ingresos.
- Gestión de gastos.
- Clasificación de gastos entre necesarios y gustos.
- Creación, edición y eliminación de movimientos.
- Búsqueda y filtros rápidos en movimientos.
- Estadísticas con gráficas mensuales.
- Perfil de usuario.
- Edición de perfil.
- Cambio de contraseña.
- Selector de tema claro, oscuro y del sistema.
- Persistencia de la preferencia de tema.
- Módulo centralizado de configuración de la aplicación.
- Personalización del contenido visible en Inicio.
- Persistencia de las preferencias de Inicio después de reiniciar o cerrar sesión.
- Accesos rápidos horizontales a recordatorios, metas y presupuestos.
- Cierre de sesión.
- Recordatorios locales diarios, semanales, quincenales y mensuales.
- Notificaciones locales programadas para pagos, gastos fijos y metas.
- Restauración de recordatorios programados después de reiniciar Android.
- Resumen financiero inteligente e insights generados localmente.
- Sugerencias automáticas de categorías según la descripción del movimiento.
- Recomendaciones locales de ahorro.
- Metas financieras con seguimiento de progreso.
- Presupuestos mensuales por categoría.
- Búsqueda avanzada y filtros persistentes de movimientos.
- Exportación de ingresos y gastos filtrados a CSV.
- Compartir archivos CSV mediante el selector nativo del dispositivo.
- Generación y uso compartido de reportes financieros PDF por período.
- Panel de notificaciones internas con indicador de elementos no leídos.
- Persistencia local por usuario del estado leído de las notificaciones internas.

> Los recordatorios, metas, presupuestos y filtros se almacenan localmente en
> el dispositivo, separados por el usuario activo. Actualmente no se
> sincronizan con el backend.

## Capturas de pantalla

Sección reservada para futuras capturas del proyecto.

Las imágenes se agregarán más adelante cuando se consolide la documentación visual.

## Tecnologías utilizadas

### Cliente móvil

- Flutter
- Dart
- Material Design
- `flutter_localizations`

### Gestión de estado

- `provider`
- `ChangeNotifier`

### Persistencia local

- `shared_preferences`
- `path_provider`

### Notificaciones y programación

- `flutter_local_notifications`
- `flutter_timezone`
- `timezone`

### Comunicación HTTP

- `http`

### Gráficas y análisis visual

- `fl_chart`

### Formato y utilidades

- `intl`
- `cupertino_icons`
- `share_plus`
- `pdf`

### Backend externo

- PHP
- MySQL

> El backend PHP/MySQL no hace parte de este repositorio. La app consume endpoints externos para autenticación, dashboard, movimientos, perfil y estadísticas.

## Arquitectura y estructura

El proyecto utiliza una estructura modular orientada por funcionalidades. No está planteado como una Clean Architecture completa.

La lógica principal se divide así:

- `lib/core/`: constantes, red y tema global.
- `lib/data/models/`: modelos de preferencias y funciones financieras locales.
- `lib/data/services/`: consumo HTTP hacia el backend.
- `lib/providers/`: estado compartido con `Provider`.
- `lib/presentation/screens/`: pantallas principales de la aplicación.
- `lib/presentation/widgets/`: componentes reutilizables de UI.

`lib/main.dart` inicializa la app, registra providers, configura el tema y decide si abrir sesión o mostrar autenticación.

## Estructura resumida de carpetas

```text
Finanzas-App-Mobile/
├── android/
├── ios/
├── lib/
│   ├── core/
│   ├── data/
│   ├── presentation/
│   └── providers/
├── linux/
├── macos/
├── test/
├── web/
└── windows/
```

```text
lib/
├── core/
│   ├── constants/
│   ├── network/
│   └── theme.dart
├── data/
│   └── services/
├── presentation/
│   ├── screens/
│   └── widgets/
├── providers/
└── main.dart
```

## Requisitos previos

- Flutter instalado y compatible con el SDK declarado en `pubspec.yaml` (`sdk: ^3.11.4`).
- Dart compatible con la versión de Flutter instalada.
- Git.
- Un backend PHP/MySQL accesible.
- Un dispositivo físico o emulador Android/iOS configurado.

Para verificar la versión local de Flutter:

```bash
flutter --version
```

## Instalación

1. Clonar el repositorio:

```bash
git clone https://github.com/emanuelsantamariabello-star/Finanzas-App-Mobile.git
```

2. Entrar al directorio del proyecto:

```bash
cd Finanzas-App-Mobile
```

3. Obtener dependencias:

```bash
flutter pub get
```

4. Verificar dispositivos disponibles:

```bash
flutter devices
```

5. Ejecutar la aplicación:

```bash
flutter run
```

## Configuración de la API

La URL base de la API se centraliza en la configuración del proyecto:

- `lib/core/constants/app_config.dart`
- `lib/core/constants/api_constants.dart`

La aplicación soporta el uso de `--dart-define` para sobrescribir la URL base:

```bash
flutter run --dart-define=APP_ENV=dev --dart-define=API_BASE_URL=http://HOST/finanzas_app/api
```

Notas importantes:

- `AppConfig` es la única fuente de configuración utilizada por el cliente HTTP.
- El cliente normaliza las barras de la URL para evitar rutas duplicadas.
- Los errores de conexión, timeout, HTTP y respuesta JSON inválida se
  clasifican y presentan mediante mensajes seguros.
- En el emulador Android, `localhost` de la computadora normalmente se representa como `10.0.2.2`.
- En un dispositivo físico debe usarse una dirección accesible desde la red del dispositivo.
- El backend debe estar iniciado y disponible antes de abrir la app.
- No conviene dejar una IP local personal como requisito permanente en la documentación.

## Ejecución y validación

Comandos útiles para desarrollo local:

```bash
flutter analyze
flutter test
flutter build apk --debug
flutter run
```

Recomendación operativa:

- Ejecutar `flutter analyze` para revisar advertencias y errores estáticos.
- Ejecutar `flutter test` para validar sesión inicial, temas, categorización,
  análisis financiero y persistencia local.
- Ejecutar `flutter build apk --debug` después de modificar plugins o
  configuración nativa.
- Ejecutar `flutter run` para validar el comportamiento de la app en un dispositivo o emulador.

La validación manual debe incluir:

- creación, edición y eliminación de ingresos y gastos;
- actualización del dashboard y las estadísticas;
- programación y cancelación de recordatorios;
- creación de metas y presupuestos;
- restauración de filtros al volver a Movimientos;
- exportación y uso de la acción `Compartir CSV`;
- persistencia del contenido configurado al cerrar y volver a abrir la app;
- conservación de Tema y preferencias de Inicio después de cerrar sesión;
- cambio entre los temas claro, oscuro y del sistema.

## Estado actual

Validación técnica realizada el 25 de julio de 2026:

- `flutter analyze`: sin diagnósticos.
- `flutter test`: 28 pruebas aprobadas.
- `flutter build apk --debug`: compilación correcta.
- Navegación, temas, configuración, accesos rápidos y persistencia local
  cubiertos por pruebas automatizadas.
- Ramas de implementación integradas en `main` y eliminadas después de la
  fusión.

El proyecto está funcional y estable para continuar su desarrollo, pero aún no
debe considerarse listo para producción.

### Estabilización completada

La codificación residual, el aislamiento de datos locales por usuario, el
ciclo de sesión, la configuración del cliente API y Android para desarrollo
ya fueron estabilizados. La evaluación controlada de dependencias también
quedó completada sin aplicar migraciones mayores.

Dependencias actualizadas de forma compatible:

- `flutter_local_notifications` 22.2.0;
- `flutter_local_notifications_platform_interface` 12.1.0;
- `equatable` 2.1.0;
- `path_provider_linux` 2.2.2;
- `path_provider_platform_interface` 2.1.3;
- `vm_service` 15.2.0.

Las migraciones mayores de `fl_chart` y `share_plus` quedan aplazadas para
ramas independientes con validación visual de gráficas y validación funcional
de exportación.

### Refinamiento UX global

La etapa de UX global inició el 26 de julio de 2026 desde una línea base con
análisis estático limpio, 40 pruebas aprobadas y compilación APK debug
correcta.

La auditoría inicial identificó estos frentes de trabajo:

- unificar inputs, botones, tarjetas y contenedores repetidos;
- estandarizar estados de carga, error y contenido vacío;
- mejorar formularios, teclado y prevención de acciones duplicadas;
- reforzar feedback, accesibilidad y adaptación a pantallas pequeñas;
- eliminar inconsistencias residuales entre los temas claro y oscuro;
- cerrar con regresión visual y funcional de todos los módulos.

Avance actual:

- componentes reutilizables para inputs, superficies y botones principales;
- formularios unificados en Login, Registro, Editar Perfil, Cambiar
  Contraseña, Ingresos y Gastos;
- estados de carga integrados en el botón principal para evitar acciones
  repetidas;
- estados reutilizables de carga, error y contenido vacío con acciones claras
  de reintento o creación;
- estados unificados en Inicio, Movimientos, Estadísticas, Perfil,
  Recordatorios, Presupuestos y Metas financieras;
- formularios desplazables con cierre de teclado mediante toque exterior o
  gesto de desplazamiento;
- acciones de teclado, autocompletado y capitalización ajustadas según el tipo
  de campo en autenticación, perfil y movimientos;
- confirmaciones destructivas unificadas para movimientos, recordatorios,
  presupuestos, metas y cierre de sesión;
- feedback de carga y prevención de envíos repetidos en Login y Registro;
- formularios centrados y con ancho controlado en pantallas amplias;
- soporte reforzado para texto ampliado, lectores de pantalla y controles
  adaptables en accesos rápidos, filtros y componentes de estado;
- superficies, textos secundarios, acciones y snackbars alineados con
  `ThemeData` en modo claro y oscuro;
- colores verde, azul y rojo centralizados como identidad visual corporativa.

Estado de cierre de la etapa:

- siete fases de refinamiento UX completadas en la rama
  `codex/global-ux-refinement`;
- análisis estático sin diagnósticos;
- 55 pruebas automatizadas aprobadas;
- compilación APK debug completada correctamente;
- pendiente únicamente la validación manual antes de fusionar con `main`.

Antes de un despliegue productivo todavía conviene reforzar:

- migrar la API a HTTPS y definir entornos de desarrollo y producción;
- reemplazar el identificador Android de ejemplo y configurar firma release;
- migrar la sesión a un mecanismo seguro basado en tokens antes de producción;
- ampliar la cobertura con pruebas de integración contra un backend controlado;
- revisar las actualizaciones mayores pendientes de dependencias de forma
  aislada y con pruebas de regresión.

## Hoja de ruta

- Mejorar la gestión de sesión.
- Incorporar manejo de errores más estructurado.
- Separar progresivamente servicios y repositorios.
- Ampliar pruebas automatizadas e incorporar pruebas de integración.
- Preparar configuraciones por entorno.
- Migrar el backend a HTTPS antes de producción.

## Contribución

Este proyecto está en desarrollo.

Flujo sugerido:

1. Crear una rama para el cambio.
2. Implementar un ajuste pequeño y bien delimitado.
3. Validar localmente el comportamiento.
4. Abrir un Pull Request para revisión.

## Autor

Emanuel Santamaría Bello  
[Perfil de GitHub](https://github.com/emanuelsantamariabello-star)

## Licencia

Este proyecto aún no tiene una licencia definida.

## Infraestructura Beta Local

La beta Android usa el entorno `beta` y consume la API por HTTPS mediante:

```text
https://beta-api.finanzasappsan.com/finanzas_app/api
```

La infraestructura se compone de Apache y MariaDB en XAMPP, publicados de forma
temporal mediante el túnel de Cloudflare `finanzas-beta`. Solo Apache se conecta
al túnel; MySQL no se publica mediante Cloudflare Tunnel.

Requisitos para una sesión de prueba:

1. Iniciar Apache y MySQL en XAMPP.
2. Ejecutar `cloudflared tunnel run finanzas-beta`.
3. Mantener el computador y el túnel conectados.
4. Compilar con:

```powershell
flutter build apk --release --dart-define=APP_ENV=beta
```

Para detener el túnel iniciado en terminal, usar `Ctrl+C`. La configuración y
credenciales locales de Cloudflare se almacenan fuera del repositorio en
`%USERPROFILE%\.cloudflared` y nunca deben versionarse.

La guía de instalación, riesgos y validación se encuentra en:

- `docs/BETA_LOCAL_GUIDE.md`
- `docs/BETA_TEST_PLAN.md`
- `docs/BETA_ISSUE_TEMPLATE.md`
- `docs/BETA_INTEGRATION_REPORT.md`
