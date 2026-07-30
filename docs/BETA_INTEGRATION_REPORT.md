# Informe de Integración Beta 1.0.0-beta.6

## Alcance

La validación integra las funciones incorporadas desde Finanzas App Web sin
acoplar ambos proyectos:

- clasificación de gastos entre necesarios y gustos;
- generación y uso compartido de reportes financieros PDF;
- panel móvil de notificaciones internas.

## Validación automatizada

- `flutter analyze --no-pub`: sin diagnósticos.
- `flutter test --no-pub`: 88 pruebas aprobadas.
- `flutter build apk --release --dart-define=APP_ENV=beta`: completado.
- Application ID inspeccionado: `com.finanzas_app_san.emanuelsantamariabello`.
- Versión inspeccionada: `1.0.0-beta.6`.
- Build inspeccionado: `6`.
- SDK mínimo: Android 7.0, API 24.
- Target SDK: API 36.
- Firma del APK: esquema v2 válido para distribución beta privada.

## APK generado

```text
build\app\outputs\flutter-apk\app-release.apk
```

- Tamaño: `64.340.743` bytes.
- SHA-256:
  `6A11D573849FA8E3903600620837722170B15AE7DB2B290057900E8A331B55D8`.

El APK es un artefacto generado y permanece excluido del repositorio.

## Validación de actualización y arranque

- Se incrementó la identificación desde `1.0.0-beta.4+4` hasta
  `1.0.0-beta.5+5` para que Android reconozca el instalador como una
  actualización posterior.
- La instalación con `adb install -r` finalizó correctamente.
- La actividad `MainActivity` permaneció activa después del arranque.
- El registro de Android no presentó excepciones fatales de la aplicación.
- La API HTTPS respondió `HTTP 200` después de iniciar el túnel
  `finanzas-beta`.

El APK que permanecía en `build` correspondía a la Beta 4 generada el 26 de
julio y no incluía las mejoras integradas posteriormente. Además, Cloudflare
devolvía el código `1033` mientras el túnel local estaba detenido. El primer
hallazgo impedía distribuir una actualización real; el segundo impedía usar
login y servicios remotos, pero no era un fallo de arranque de Flutter.

## Persistencia de la ocupación

- `update_profile.php` conserva la ocupación correctamente en MySQL.
- `login.php` devuelve ahora el campo `occupation` dentro del usuario.
- Flutter restaura ese valor en SharedPreferences al iniciar sesión.
- La actualización local mantiene las claves compatibles `occupation` y
  `userOccupation`.
- El contrato se validó mediante HTTP local y HTTPS Beta usando un usuario con
  ocupación registrada, sin registrar sus datos en logs.

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
