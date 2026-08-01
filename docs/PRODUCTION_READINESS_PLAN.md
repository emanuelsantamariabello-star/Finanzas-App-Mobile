# Plan de preparación para producción

Fecha de auditoría: 30 de julio de 2026.

Rama de trabajo: `codex/production-readiness`.

## Objetivo

Convertir Finanzas App Mobile desde una Beta Local estable en una aplicación
Android publicable y operable en producción, sin perder funcionalidad ni
alterar datos existentes.

La Fase 0 es exclusivamente de diagnóstico y planificación. No modifica
autenticación, API, base de datos, infraestructura ni comportamiento de la app.

## Alcance de producción

La primera salida productiva se orientará a:

- Android y Google Play;
- API PHP mediante HTTPS;
- base de datos MySQL o MariaDB privada;
- dominio productivo independiente de la Beta Local;
- despliegue gradual mediante pruebas internas y cerradas.

iOS y otras plataformas requieren una auditoría de publicación separada.

## Veredicto ejecutivo

**Estado actual: NO GO para producción pública.**

La aplicación móvil es una Beta funcional y estable, pero existen bloqueadores
de seguridad, infraestructura, cumplimiento y distribución. No se deben agregar
nuevas funcionalidades hasta cerrar primero los riesgos críticos.

## Línea base validada

### Cliente Flutter

- Flutter `3.41.6` estable y Dart `3.11.4`.
- Versión móvil `1.0.0-beta.7+7`.
- Application ID definitivo:
  `com.finanzas_app_san.emanuelsantamariabello`.
- SDK mínimo Android 24 y Target SDK 36.
- `dart analyze lib test`: sin diagnósticos.
- `flutter test --no-pub`: 100 pruebas aprobadas.
- No hay secretos, keystores, `.env` ni `local.properties` rastreados por Git.
- Producción exige `API_BASE_URL` mediante `--dart-define`; no existe fallback
  silencioso hacia desarrollo o Beta.
- `android:allowBackup="false"` protege los datos locales frente a backups
  automáticos no controlados.
- La fotografía de perfil usa token independiente en almacenamiento seguro.

### Beta e infraestructura actual

- API local: HTTP 200.
- API Beta mediante Cloudflare: HTTP 200 y TLS válido.
- Apache, MariaDB y Cloudflare Tunnel deben permanecer activos en el computador
  anfitrión.
- MySQL no se publica mediante Cloudflare Tunnel.
- La Beta depende de XAMPP, del computador, de la conexión residencial y del
  túnel local; esta arquitectura no es productiva.

## Hallazgos

| ID | Riesgo | Nivel | Evidencia | Criterio de cierre |
| --- | --- | --- | --- | --- |
| PRD-001 | Backend no reproducible desde Git | Crítico | XAMPP tiene 26 modificados, 1 eliminado, 30 no rastreados y 3 staged; el repositorio limpio solo rastrea 10 de los 20 endpoints activos y no tiene remoto | Repositorio canónico limpio, completo, remoto privado y despliegue reproducible |
| PRD-002 | Contraseñas almacenadas en texto legible | Crítico | 5 de 5 usuarios actuales conservan formato heredado; registro guarda el valor directo y login usa `hash_equals` | Migración reversible a `password_hash`/`password_verify`, sin bloquear usuarios |
| PRD-003 | Endpoints financieros sin autenticación real | Crítico | Dashboard, movimientos, estadísticas, perfil y contraseña confían en `user_id` enviado por Flutter | Token de sesión obligatorio y usuario derivado exclusivamente del servidor |
| PRD-004 | Infraestructura dependiente del equipo local | Crítico | XAMPP y Tunnel deben permanecer activos para que la Beta funcione | Servidor 24/7, HTTPS, despliegue repetible, MySQL privado y dominio productivo |
| PRD-005 | Firma release de depuración | Crítico | Gradle asigna `signingConfigs.debug` al build release | Upload key protegida, Play App Signing y AAB firmado |
| PRD-006 | Sin eliminación de cuenta ni política de privacidad | Crítico | La app permite registrarse pero no ofrece eliminación; no hay documento legal público ni Data Safety | Eliminación dentro de la app y vía web, política pública y declaraciones aprobadas |
| PRD-007 | CORS y errores del backend demasiado permisivos | Alto | Varios endpoints usan `Access-Control-Allow-Origin: *`; registro puede devolver el mensaje interno de MySQL | Política de origen definida y respuestas públicas sanitizadas |
| PRD-008 | Sin rate limiting ni sesión global revocable | Alto | Login, registro y cambio de contraseña no limitan intentos; solo multimedia usa token revocable | Límites por IP/cuenta, expiración, revocación y cierre global de sesión |
| PRD-009 | Backend activo sin control de versiones confiable | Alto | La instalación XAMPP mezcla código web, API, archivos temporales y configuración local | Separar código desplegable, configuración, almacenamiento y artefactos |
| PRD-010 | Sin backups automáticos ni prueba de restauración | Alto | Existen esquema y migraciones parciales, pero no una política operativa de backup | Backups cifrados, retención definida y restauración ensayada |
| PRD-011 | Sin observabilidad productiva | Alto | No hay health check, alertas, métricas ni reporte de fallos móviles | Health endpoint, logs sanitizados, monitoreo de disponibilidad y errores |
| PRD-012 | Política de red Android no explícita | Alto | No existe `network_security_config` para impedir tráfico claro en release | Release permite únicamente HTTPS y desarrollo conserva excepción aislada |
| PRD-013 | Runtime del servidor requiere actualización controlada | Alto | XAMPP utiliza PHP 8.2.12 y MariaDB 10.4.32 | Versiones soportadas, parchadas y validadas con regresión |
| PRD-014 | Sin integración continua | Medio | No existe `.github/workflows` | CI ejecuta análisis, pruebas y compilación controlada en cada cambio |
| PRD-015 | Dependencias mayores pendientes | Medio | `fl_chart` y `share_plus` tienen saltos mayores; otras dependencias están bloqueadas por lockfile | Actualización individual con pruebas, sin upgrade masivo |
| PRD-016 | Material de Google Play incompleto | Medio | No existen ficha, política, Data Safety, screenshots ni feature graphic versionados | Activos y declaraciones listos antes de prueba cerrada |
| PRD-017 | Cobertura productiva incompleta | Medio | Hay 100 pruebas locales, pero faltan pruebas integrales de autorización, carga, recuperación y actualización | Matriz de dispositivos, API, seguridad, rendimiento y actualización aprobada |

## Riesgo principal

El riesgo más grave no está en Flutter sino en el backend: cualquier cliente
puede modificar el `user_id` enviado en una petición e intentar consultar o
alterar datos de otra cuenta. La interfaz móvil no constituye un límite de
seguridad. El servidor debe identificar al usuario desde un token válido y
aplicar propiedad sobre cada recurso.

La migración de contraseñas y la autorización de endpoints deben completarse
antes de mover datos reales a infraestructura pública.

## Aspectos positivos que deben conservarse

- Configuración separada para desarrollo, Beta y producción.
- HTTPS operativo en Beta.
- Target API 36.
- Identificador Android definitivo.
- Suite automatizada limpia.
- SharedPreferences sin contraseñas ni token multimedia.
- Flutter Secure Storage para el token multimedia.
- Prepared statements en los endpoints auditados.
- Archivos de foto fuera del repositorio y acceso protegido.
- `.gitignore` cubre firmas, secretos y artefactos generados.

## Plan por fases

### Fase 0 — Auditoría y congelación

Estado: completada.

- Crear matriz de riesgos y criterios de aceptación.
- Congelar nuevas funcionalidades hasta cerrar riesgos críticos.
- Definir Android como primer objetivo productivo.
- No modificar todavía código funcional ni datos.

### Fase 1 — Backend canónico y respaldo

Estado: completada en ramas aisladas.

- Respaldar código XAMPP y base de datos antes de cualquier cambio.
- Separar código fuente, configuración, logs, uploads y temporales.
- Consolidar los 20 endpoints activos en un repositorio limpio.
- Crear remoto privado para el backend.
- Documentar instalación local y despliegue.
- Verificar que el backend canónico reproduce la Beta sin usar archivos
  residuales de XAMPP.

**Puerta de salida:** repositorio limpio, backup verificable y despliegue local
repetible sin pérdida funcional.

### Fase 2 — Contraseñas y sesiones

Estado: implementada y desplegada en Beta; pendiente validación manual.

- Crear migración compatible para contraseñas heredadas.
- Utilizar `password_hash` y `password_verify`.
- Emitir tokens de sesión seguros, expirables y revocables.
- Guardar únicamente hashes de tokens en el servidor.
- Migrar Flutter a almacenamiento seguro sin recordar contraseñas.
- Revocar sesión al cerrar sesión y cambiar contraseña.

**Puerta de salida:** ninguna contraseña legible y pruebas de login, migración,
expiración y revocación aprobadas.

### Fase 3 — Autorización y endurecimiento de API

Estado: implementada y validada de forma aislada; pendiente empaquetado y
despliegue coordinado cuando haya conectividad.

- Proteger todos los endpoints.
- Derivar el usuario desde el token, nunca desde `user_id` del cliente.
- Validar propiedad de ingresos, gastos, perfil, estadísticas y archivos.
- Implementar rate limiting y respuestas de error sanitizadas.
- Homogeneizar método HTTP, JSON UTF-8, timeouts y headers.
- Definir CORS únicamente donde aplique.

**Puerta de salida:** pruebas negativas entre usuarios y contratos API sin
acceso horizontal.

### Fase 4 — Privacidad y ciclo de cuenta

Estado: implementada y validada offline; pendiente publicación legal,
despliegue coordinado y prueba manual.

- Publicar política de privacidad en una URL pública y no editable.
- Mostrar enlace dentro de Configuración.
- Implementar solicitud de eliminación desde la app y desde la web.
- Eliminar o anonimizar datos relacionados de forma transaccional.
- Documentar retención, backups y excepciones legítimas.
- Preparar inventario para Data Safety.

**Puerta de salida:** eliminación integral validada y documentación legal
coherente con el comportamiento real.

### Fase 5 — Infraestructura productiva

- Aprovisionar servidor independiente de XAMPP.
- Configurar `api.finanzasappsan.com` con HTTPS.
- Mantener MySQL en red privada y con usuario de privilegios mínimos.
- Gestionar secretos mediante variables de entorno.
- Automatizar migraciones, backups cifrados y restauración.
- Incorporar health check, logs sanitizados y monitoreo.

**Puerta de salida:** disponibilidad 24/7, restauración ensayada y cero
dependencia del computador personal.

### Fase 6 — Android release

- Crear upload key fuera del repositorio y respaldarla de forma segura.
- Configurar Play App Signing.
- Forzar HTTPS en release mediante Network Security Configuration.
- Definir `API_BASE_URL` productiva.
- Generar AAB release y símbolos de depuración separados.
- Confirmar versionCode, versionName, firma y actualización desde Beta.

**Puerta de salida:** AAB firmado, reproducible y conectado únicamente a
producción.

### Fase 7 — Calidad, seguridad y operación

- Incorporar CI para análisis, pruebas y build.
- Ejecutar pruebas integrales, de autorización, migración y recuperación.
- Validar Android 7 a Android 16, texto ampliado y modos claro/oscuro.
- Probar red lenta, offline, timeouts, reinicio, poco almacenamiento y
  permisos denegados.
- Ejecutar prueba de carga y revisión de seguridad del backend.
- Definir respuesta a incidentes y rollback.

**Puerta de salida:** cero hallazgos críticos o altos abiertos.

### Fase 8 — Google Play y lanzamiento gradual

- Crear o verificar la cuenta de desarrollador.
- Preparar icono, screenshots, feature graphic y descripción.
- Completar privacidad, Data Safety, eliminación de cuenta y clasificación de
  contenido.
- Publicar primero en prueba interna y después en prueba cerrada.
- Supervisar estabilidad y feedback antes de producción.
- Realizar rollout gradual con posibilidad de detener o revertir.

**Puerta de salida:** revisión de Play aprobada y métricas estables en el grupo
cerrado.

## Reglas de ejecución

- Una rama por fase con prefijo `codex/`.
- Commits pequeños y verificables.
- Backup antes de migraciones o cambios de autenticación.
- No mezclar mejoras UX o nuevas funciones con preparación productiva.
- No actualizar dependencias en bloque.
- No fusionar una fase hasta completar pruebas automáticas y manuales.
- No incluir credenciales, dumps, fotos, logs ni firmas en Git.
- Mantener una estrategia reversible para datos y despliegues.

## Referencias oficiales

- Target API de Google Play:
  <https://developer.android.com/google/play/requirements/target-sdk>
- Firma de aplicaciones y Play App Signing:
  <https://developer.android.com/studio/publish/app-signing>
- Network Security Configuration:
  <https://developer.android.com/privacy-and-security/security-config>
- Data Safety:
  <https://support.google.com/googleplay/android-developer/answer/10787469>
- Eliminación de cuentas:
  <https://support.google.com/googleplay/android-developer/answer/13327111>

## Próximo paso recomendado

Cuando regrese la conectividad, empaquetar conjuntamente los clientes de las
Fases 3 y 4, validar los flujos principales contra el backend anterior y después
desplegar de forma coordinada las migraciones y endpoints protegidos. La
eliminación debe probarse únicamente con una cuenta desechable y un respaldo
previo.
