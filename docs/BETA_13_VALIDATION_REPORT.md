# Informe de validación Beta 13

Fecha de cierre: 1 de agosto de 2026.

## Identificación del artefacto

- Versión: `1.0.0-rc.5+13`.
- Rama validada: `codex/production-google-play`.
- Commit funcional: `12f4a67`.
- Archivo: `Finanzas-App-Beta-13.apk`.
- SHA-256: `0f27a1bfdf2d20bd08750b762e08c0df47014a96363d7c4e627ea588c05f1e34`.
- API Beta: `https://beta-api.finanzasappsan.com/finanzas_app/api`.

## Validación manual aprobada

- Instalación y actualización de la APK en un dispositivo Android físico.
- Registro, inicio de sesión, persistencia de sesión, cierre de sesión y eliminación de una cuenta descartable.
- Creación, edición, eliminación, búsqueda, filtrado y exportación de movimientos.
- Actualización de Inicio, Estadísticas y Perfil, incluida la foto de perfil.
- Temas claro, oscuro y del sistema.
- Recordatorios y tratamiento del permiso de notificaciones denegado.
- Selección de cámara y galería mediante los selectores seguros del sistema.
- Exportación y apertura de archivos CSV y PDF.
- Cambio entre Wi-Fi y datos móviles, pérdida de conexión y recuperación.
- Indisponibilidad controlada del túnel y recuperación posterior del servicio.
- Modales, teclado, reapertura, rotación y texto ampliado.
- Icono oficial FA con zona segura en el lanzador de Android.
- Gráficas adaptadas a texto ampliado sin superposiciones ni recortes.

## Validación automatizada

- `flutter analyze`: sin diagnósticos.
- `flutter test --no-pub`: 115 pruebas aprobadas.
- `flutter build apk --debug --dart-define=APP_ENV=beta`: compilación correcta.
- Validaciones de autorización, eliminación de cuenta, recuperación y resiliencia del backend aprobadas.
- Estado HTTPS de la API Beta: disponible mediante Cloudflare Tunnel.

## Alcance de la evidencia

La validación manual se completó en un dispositivo Android físico. El modelo y
la versión exacta de Android no quedaron registrados, por lo que la matriz
amplia de dispositivos y versiones debe completarse durante las pruebas
internas y cerradas de Google Play.

## Pendientes antes de producción

- Migrar la API Beta Local a infraestructura productiva disponible 24/7.
- Configurar la firma release definitiva y Play App Signing.
- Publicar las URLs definitivas de política de privacidad y eliminación de cuenta.
- Completar la ficha Data Safety y demás formularios de Play Console.
- Ejecutar pruebas internas y cerradas en una matriz más amplia de dispositivos.

La Beta 13 queda validada como candidata estable para continuar el proceso de
publicación, pero no representa todavía una versión productiva.
