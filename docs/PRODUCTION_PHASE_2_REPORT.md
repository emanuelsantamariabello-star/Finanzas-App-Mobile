# Fase 2 — Contraseñas y sesiones

Fecha de implementación: 30 de julio de 2026.

Estado: desplegada en Beta y pendiente de validación manual.

## Resultado

- Los cinco usuarios existentes fueron migrados de contraseña legible a hash.
- Los registros nuevos almacenan únicamente hashes.
- El login mantiene compatibilidad con cuentas heredadas y las migra al entrar.
- La API emite tokens globales aleatorios, expirables y revocables.
- El servidor almacena únicamente el hash SHA-256 de cada token.
- Flutter conserva la sesión global mediante `FlutterSecureStorage`.
- Una sesión local incompleta o expirada obliga a iniciar sesión nuevamente.
- Cerrar sesión revoca el token actual y elimina los tokens multimedia.
- Cambiar la contraseña revoca todas las sesiones y regresa al login.

Los endpoints financieros todavía reciben `user_id`. Su autorización mediante
token corresponde exclusivamente a la Fase 3.

## Ramas y commits

Backend:

- rama `codex/production-auth-sessions`;
- commit `3c5b292` — `feat: proteger contraseñas y sesiones`.

Flutter:

- rama `codex/production-auth-sessions`;
- commit `ecc798e` — `feat: integrar sesiones seguras en Flutter`.

## Respaldo previo

```text
C:\Users\Emanuel\BACKUPS\FinanzasApp\production-phase2-20260730-203945
```

El respaldo contiene:

- dump de `finanzas_app` antes de migrar las contraseñas;
- copias de los endpoints reemplazados;
- sumas SHA-256.

La restauración temporal reprodujo 6 tablas y 5 usuarios. La base de
verificación se eliminó al finalizar.

La transformación de una contraseña a hash no puede revertirse. Una reversión
de datos debe restaurar este dump y los endpoints compatibles del respaldo.

## Validaciones automatizadas

Backend aislado:

- login con contraseña heredada;
- migración automática a hash;
- registro con hash;
- emisión de token global;
- logout y revocación;
- cambio de contraseña;
- invalidez de la contraseña anterior;
- limpieza de base y servidor temporales.

Backend Beta:

- sintaxis de los seis archivos PHP desplegados;
- 5 usuarios y 0 contraseñas heredadas después de migrar;
- registro, login, cambio de contraseña, revocación y logout locales;
- registro, login y logout mediante HTTPS;
- cuentas y sesiones temporales eliminadas.

Flutter:

- `flutter analyze --no-pub`: sin diagnósticos;
- `flutter test --no-pub`: 103 pruebas aprobadas;
- pruebas nuevas de almacenamiento seguro, expiración y limpieza de sesión.

## APK Beta 8

```text
build\app\outputs\flutter-apk\Finanzas-App-Mobile-1.0.0-beta.8-build8.apk
```

- Application ID: `com.finanzas_app_san.emanuelsantamariabello`;
- versión: `1.0.0-beta.8+8`;
- Min SDK 24 y Target SDK 36;
- firma APK Signature Scheme v2 válida;
- tamaño: 64.963.403 bytes;
- SHA-256:
  `AFFF3E62E8CEA6C6449ACF95EF7117ABF474A3FC0B266A7DAC7CA0B9EB01D36E`.

El APK permanece ignorado por Git.

## Validación manual requerida

1. Actualizar a la Beta 8.
2. Iniciar sesión con una cuenta existente y su contraseña habitual.
3. Cerrar y volver a abrir la aplicación; la sesión debe conservarse.
4. Cerrar sesión; debe regresar al login.
5. Registrar una cuenta nueva y comprobar que regresa al login.
6. Cambiar la contraseña; debe cerrar la sesión automáticamente.
7. Confirmar que la contraseña anterior falla y la nueva funciona.

No debe iniciarse la Fase 3 hasta aprobar estos casos.
