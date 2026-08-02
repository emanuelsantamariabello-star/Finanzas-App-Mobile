# Seguimiento del lanzamiento productivo

Fecha de inicio: 1 de agosto de 2026.

Rama de trabajo móvil: `codex/production-launch`.

## Objetivo

Conducir Finanzas App Mobile desde la Beta 13 validada hasta una publicación
controlada en Google Play, sin mezclar cambios funcionales con tareas de
infraestructura, cumplimiento o distribución.

## Línea base

- Versión móvil: `1.0.0-rc.5+13`.
- Commit base: `2c66e13`.
- `applicationId`: `com.finanzas_app_san.emanuelsantamariabello`.
- Android: `minSdkVersion 24` y `targetSdkVersion 36` en la Beta validada.
- Calidad: análisis estático limpio y 115 pruebas automatizadas aprobadas.
- API Beta: disponible por HTTPS en `beta-api.finanzasappsan.com`.
- API productiva: aún no aprovisionada.
- Firma productiva: pendiente.
- Publicación en Play Console: pendiente.

## Reglas de ejecución

- Una sola fase activa a la vez.
- Cambios pequeños, verificables y registrados mediante commits.
- No usar la base ni el código de Finanzas App Web.
- No versionar llaves, credenciales, dumps, fotos, logs ni configuraciones locales.
- No generar un AAB publicable hasta disponer de API productiva y upload key.
- No avanzar a producción con hallazgos críticos o altos abiertos.

## Fases

| Fase | Alcance | Estado | Puerta de salida |
| --- | --- | --- | --- |
| 1 | Rama y línea base de lanzamiento | Completada | Repositorios aislados y alcance documentado |
| 2 | Repositorio privado del backend | Completada | Backend respaldado en un remoto privado |
| 3 | Infraestructura productiva | En curso | Servidor 24/7, DNS, HTTPS y almacenamiento preparados |
| 4 | Despliegue y operación | Pendiente | API, migraciones, backups, monitoreo y restauración validados |
| 5 | Privacidad y eliminación web | Pendiente | URLs públicas y retenciones aprobadas |
| 6 | Firma y AAB productivo | Pendiente | Upload key respaldada y AAB firmado verificable |
| 7 | Configuración de Play Console | Pendiente | Ficha, Data Safety, contenido y acceso completados |
| 8 | Prueba interna | Pendiente | Instalación y regresión desde Google Play aprobadas |
| 9 | Prueba cerrada | Pendiente | Requisitos de testers y estabilidad completados |
| 10 | Lanzamiento gradual | Pendiente | Producción aprobada, monitoreada y con rollback disponible |

## Dependencias externas

- Proveedor de infraestructura productiva.
- Acceso administrativo a DNS y Cloudflare.
- Repositorio privado para el backend.
- Cuenta de desarrollador verificada en Google Play Console.
- Datos legales, contacto de privacidad y política de retención aprobados.
- Almacenamiento cifrado para upload key, respaldos y símbolos.

## Bloqueadores activos

1. `api.finanzasappsan.com` todavía no resuelve en DNS.
2. La producción depende aún de infraestructura por aprovisionar.
3. No existe upload key ni AAB productivo firmado.
4. Faltan política de privacidad y eliminación de cuenta mediante web pública.
5. Faltan capturas reales y configuración definitiva de Play Console.

## Estado de la Fase 3

La configuración reproducible del backend y el preflight del host están
preparados en el repositorio privado. La fase permanece abierta porque todavía
no existe un servidor 24/7 aprovisionado y `api.finanzasappsan.com` no resuelve
en DNS. No se modificó la Beta local ni la base `finanzas_app_web`.

Este documento debe actualizarse al cerrar cada fase sin sustituir los informes
técnicos específicos de móvil y backend.
