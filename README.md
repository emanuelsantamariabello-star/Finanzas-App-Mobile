# Finanzas App Mobile

Aplicación Flutter para la gestión de finanzas personales desde una interfaz móvil moderna, modular y centrada en la experiencia de usuario.

> Estado del proyecto: desarrollo activo.

## Descripción del proyecto

Finanzas App Mobile resuelve la necesidad de registrar, consultar y organizar información financiera personal desde una app Flutter.

La aplicación permite administrar ingresos, gastos, estadísticas, perfil de usuario y preferencias visuales, con sincronización contra un backend externo PHP/MySQL.

## Funcionalidades verificadas

- Registro e inicio de sesión.
- Persistencia de sesión con `SharedPreferences`.
- Recordar credenciales de acceso.
- Dashboard financiero con resumen general.
- Gestión de ingresos.
- Gestión de gastos.
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
- Resumen financiero inteligente e insights generados localmente.
- Sugerencias automáticas de categorías según la descripción del movimiento.
- Recomendaciones locales de ahorro.
- Metas financieras con seguimiento de progreso.
- Presupuestos mensuales por categoría.
- Búsqueda avanzada y filtros persistentes de movimientos.
- Exportación de ingresos y gastos filtrados a CSV.
- Compartir archivos CSV mediante el selector nativo del dispositivo.

> Los recordatorios, metas, presupuestos y filtros se almacenan localmente en
> el dispositivo. Actualmente no se sincronizan con el backend.

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
flutter run --dart-define=API_BASE_URL=http://HOST/finanzas_app/api
```

Notas importantes:

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

### Estabilización activa

La rama `codex/stability-hardening` parte de una línea base limpia y trabajará
de forma secuencial la codificación residual, el aislamiento de datos locales
por usuario, el ciclo de sesión, la configuración de API, la configuración
Android de desarrollo y la evaluación controlada de dependencias.

Antes de un despliegue productivo todavía conviene reforzar:

- migrar la API a HTTPS y definir entornos de desarrollo y producción;
- reemplazar el identificador Android de ejemplo y configurar firma release;
- reforzar el manejo de sesión y el almacenamiento de información sensible;
- separar por usuario los recordatorios, metas, presupuestos y filtros locales;
- corregir cadenas residuales con codificación dañada;
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
