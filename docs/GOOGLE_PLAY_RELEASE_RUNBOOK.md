# Runbook de publicación en Google Play

## Alcance

Este documento prepara el proceso de publicación, pero no crea cuentas, no
genera llaves, no firma artefactos y no envía versiones a Google Play.

## Bloqueadores previos

- Aprovisionar y validar la infraestructura productiva 24/7.
- Publicar la política de privacidad en una URL HTTPS estable.
- Publicar un mecanismo web para solicitar eliminación de cuenta.
- Crear y respaldar la upload key fuera del repositorio.
- Activar Play App Signing.
- Generar el AAB firmado con la URL productiva definitiva.
- Completar pruebas manuales y de actualización en dispositivos reales.

## Preparación de la ficha

1. Revisar los textos de `store_listing/es-CO`.
2. Ejecutar `tools/generate_store_assets.ps1`.
3. Ejecutar `tools/validate_play_store_assets.ps1`.
4. Capturar pantallas reales siguiendo `store_listing/README.md`.
5. Verificar que ningún activo exponga datos personales.

## Artefacto Android

Seguir `docs/ANDROID_RELEASE_SIGNING.md`. El artefacto publicable debe ser un
AAB firmado, construido con un `versionCode` nuevo y con:

```powershell
.\tools\build_android_release.ps1 `
  -ApiBaseUrl https://api.finanzasappsan.com
```

No usar `ALLOW_UNSIGNED_RELEASE` para una publicación real.

## Secuencia en Play Console

1. Crear la aplicación con el ID
   `com.finanzas_app_san.emanuelsantamariabello`.
2. Configurar Play App Signing y registrar la upload key.
3. Completar acceso a la app con una cuenta de prueba controlada.
4. Completar ficha, política de privacidad, Data Safety, eliminación de cuenta
   y clasificación de contenido.
5. Publicar primero en prueba interna.
6. Validar instalación limpia, actualización, login y flujos principales.
7. Abrir una prueba cerrada y registrar estabilidad y feedback.
8. Solicitar producción únicamente al cerrar los bloqueadores.

## Criterio de detención

Detener el lanzamiento ante fallos de autenticación, pérdida o cruce de datos,
errores de actualización, crashes, ANR, indisponibilidad sostenida de API o una
declaración de privacidad que no coincida con el comportamiento real.
