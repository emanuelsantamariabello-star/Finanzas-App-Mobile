# Fase 5 — Infraestructura productiva

Fecha de preparación: 31 de julio de 2026.

Estado: automatización y plantillas completadas offline; aprovisionamiento y
validación real pendientes.

## Preparado

- arquitectura independiente de XAMPP para `api.finanzasappsan.com`;
- VirtualHost HTTPS y configuración PHP endurecida;
- MySQL privado con cuentas separadas para API, migración y backup;
- secretos y fotografías fuera del directorio público;
- runner de migraciones con manifiesto, checksums y baseline confirmado;
- backup diario, retención controlada, checksum y restauración protegida;
- health check de base y almacenamiento con request ID;
- timers de backup y monitoreo local;
- runbooks de despliegue, rollback, recuperación e incidentes.

## Conservado en Flutter

`AppConfig` continúa exigiendo `API_BASE_URL` mediante `--dart-define` cuando
`APP_ENV=production`. No se fijó una URL productiva dentro del binario ni se
generó un release en esta fase.

## Validación offline

- sintaxis PHP;
- creación y baseline de historial de migraciones;
- aplicación de una migración futura simulada;
- health check contra una base temporal;
- sintaxis de scripts Bash;
- pruebas acumuladas de autenticación, autorización y eliminación.

## Pendiente con infraestructura e Internet

1. Aprovisionar el servidor definitivo y la red privada de MySQL.
2. Crear DNS y certificado de `api.finanzasappsan.com`.
3. Configurar almacenamiento externo cifrado para backups.
4. Ejecutar un simulacro real de restauración.
5. Activar monitor externo y alertas.
6. Desplegar las Fases 3–5 en una ventana coordinada.

No se modificaron el túnel, la API Beta activa ni la base real.
