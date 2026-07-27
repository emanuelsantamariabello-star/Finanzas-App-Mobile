# Informe de Integración Beta 1.0.0-beta.4

## Alcance

La validación integra las funciones incorporadas desde Finanzas App Web sin
acoplar ambos proyectos:

- clasificación de gastos entre necesarios y gustos;
- generación y uso compartido de reportes financieros PDF;
- panel móvil de notificaciones internas.

## Validación automatizada

- `flutter analyze --no-pub`: sin diagnósticos.
- `flutter test --no-pub`: 66 pruebas aprobadas.
- `flutter build apk --release --dart-define=APP_ENV=beta`: completado.
- Application ID inspeccionado: `com.finanzas_app_san.emanuelsantamariabello`.
- Versión inspeccionada: `1.0.0-beta.4`.
- Build inspeccionado: `4`.
- SDK mínimo: Android 7.0, API 24.
- Target SDK: API 36.
- Firma del APK: esquema v2 válido para distribución beta privada.

## APK generado

```text
build\app\outputs\flutter-apk\app-release.apk
```

- Tamaño: `64.307.975` bytes.
- SHA-256:
  `A048D8C708C806F7324ECB25ABD2796D37409D1ACA40E38804C65A412FA67CA0`.

El APK es un artefacto generado y permanece excluido del repositorio.

## Integración HTTPS

URL utilizada:

```text
https://beta-api.finanzasappsan.com/finanzas_app/api
```

Se verificaron mediante HTTPS:

- `dashboard.php`;
- `incomes.php`;
- `expenses.php`;
- `statistics_monthly.php`;
- `notifications.php`.

Todos respondieron correctamente para un usuario de prueba existente. El
contrato de gastos incluyó `reflection_type` con valores válidos, y el endpoint
de notificaciones devolvió una lista cuyo `count` coincidió con sus elementos.
También se comprobó el rechazo seguro de usuarios inexistentes y el `404`
intencional en la raíz restringida del subdominio.

## Seguridad

- No se registraron credenciales, contraseñas ni contenido financiero.
- MySQL no se publica a través del túnel.
- Solo la ruta de la API queda expuesta por HTTPS.
- El reporte PDF se genera en almacenamiento privado o temporal del dispositivo.
- El estado leído de notificaciones se separa localmente por usuario.

## Validación manual completada

El 26 de julio de 2026 se confirmó en un dispositivo físico:

1. Creación y edición de gastos con ambas clasificaciones.
2. Generación, apertura y uso compartido de reportes PDF.
3. Apertura, actualización y lectura del panel de notificaciones.
4. Persistencia correcta del estado validado en la aplicación.
5. Funcionamiento correcto de los flujos integrados de la fase.

## Riesgos pendientes

- La beta depende de XAMPP, del computador anfitrión y de Cloudflare Tunnel.
- La firma actual es válida para pruebas privadas, no es la firma definitiva de
  producción.
- Algunos endpoints históricos responden `application/json` sin declarar
  explícitamente `charset=utf-8`; el cliente procesa JSON como UTF-8, pero se
  recomienda homogeneizar esos encabezados en una fase exclusiva del backend.
- Las pruebas de apertura y uso compartido dependen de aplicaciones instaladas
  en el dispositivo y no pueden cerrarse únicamente con pruebas de widgets.
