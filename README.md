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
- Cierre de sesión.

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

### Comunicación HTTP

- `http`

### Gráficas y análisis visual

- `fl_chart`

### Formato y utilidades

- `intl`
- `cupertino_icons`

### Backend externo

- PHP
- MySQL

> El backend PHP/MySQL no hace parte de este repositorio. La app consume endpoints externos para autenticación, dashboard, movimientos, perfil y estadísticas.

## Arquitectura y estructura

El proyecto utiliza una estructura modular orientada por funcionalidades. No está planteado como una Clean Architecture completa.

La lógica principal se divide así:

- `lib/core/`: constantes, red y tema global.
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
flutter run
```

Recomendación operativa:

- Ejecutar `flutter analyze` para revisar advertencias y errores estáticos.
- Ejecutar `flutter test` cuando existan pruebas suficientes.
- Ejecutar `flutter run` para validar el comportamiento de la app en un dispositivo o emulador.

## Estado actual

El proyecto está en desarrollo activo y no debe considerarse listo para producción.

Antes de un despliegue productivo todavía conviene reforzar:

- la limpieza de advertencias del analizador,
- la gestión estructurada de errores,
- la comunicación HTTP,
- y la configuración de publicación/release.

## Hoja de ruta

- Reducir advertencias de `flutter analyze`.
- Mejorar la gestión de sesión.
- Incorporar manejo de errores más estructurado.
- Separar progresivamente servicios y repositorios.
- Añadir pruebas automatizadas.
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
