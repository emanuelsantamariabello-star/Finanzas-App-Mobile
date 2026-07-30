# Informe Beta de foto de perfil

Fecha de generación: 29 de julio de 2026.

## Identificación

- Versión: `1.0.0-beta.7`.
- Build: `7`.
- Application ID: `com.finanzas_app_san.emanuelsantamariabello`.
- SDK mínimo: Android API 24.
- Target SDK: Android API 36.
- Entorno compilado: `APP_ENV=beta`.

## Artefacto

```text
build\app\outputs\flutter-apk\Finanzas-App-Mobile-1.0.0-beta.7-build7.apk
```

- Tamaño: `64.963.403` bytes.
- SHA-256:
  `42445321EB2BDF3DC8F81D3280A8A59CF861C577CB5DF5123FFF5B383395D0D7`.
- Firma: APK Signature Scheme v2.
- Certificado actual: Android Debug, válido únicamente para distribución Beta
  privada y no para publicación en producción.

El APK y los demás artefactos generados permanecen excluidos del repositorio.

## Validación automatizada

- La compilación release finalizó correctamente.
- `adb install -r` instaló la Beta 7 como actualización.
- Android confirmó `versionCode=7` y `versionName=1.0.0-beta.7`.
- `MainActivity` quedó como actividad reanudada y el proceso permaneció activo.
- Logcat no presentó excepciones fatales de la aplicación después del arranque.
- La API Beta respondió HTTP 200 mediante HTTPS con verificación TLS correcta.

## Validación manual completada

El 29 de julio de 2026 se confirmó exitosamente en un dispositivo físico:

1. Instalación de la Beta 7 sobre la versión existente.
2. Inicio de sesión y apertura de Perfil.
3. Selección desde galería y cámara.
4. Persistencia de la foto al reiniciar la aplicación.
5. Persistencia después de cerrar sesión e iniciar nuevamente.
6. Reemplazo y eliminación de la fotografía.

La aprobación manual permite cerrar la rama `codex/profile-photo` y publicar
la integración.
