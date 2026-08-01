# Inventario preliminar de Data Safety

Fecha: 31 de julio de 2026.

Este inventario prepara la declaración de Google Play. Debe contrastarse con la
infraestructura productiva final y con el formulario vigente de Play Console.

| Categoría | Ejemplos | Origen | Finalidad | Eliminación |
| --- | --- | --- | --- | --- |
| Información personal | nombre, correo, ocupación | usuario | cuenta y perfil | desde la app |
| Credenciales | contraseña con hash, tokens con hash | usuario/sistema | autenticación y seguridad | desde la app o expiración |
| Información financiera | ingresos, gastos, notas, fechas | usuario | funciones principales y análisis | desde la app |
| Fotos | foto de perfil opcional | usuario | personalización | individual o con la cuenta |
| Actividad local | recordatorios, metas, presupuestos, filtros | usuario | funciones locales | con la cuenta en el dispositivo |
| Diagnóstico de seguridad | IP transformada en hash y conteo temporal | sistema | prevención de abuso | expiración operativa pendiente |

## Transferencia y terceros

- La Beta Local utiliza Cloudflare Tunnel para publicar Apache mediante HTTPS.
- No se ha identificado SDK publicitario ni de analítica de terceros.
- Las bibliotecas de notificación y selección de imágenes operan bajo solicitud
  del usuario.

## Pendientes previos a Play Console

- confirmar la infraestructura productiva y sus encargados de tratamiento;
- aprobar periodos de retención de backups y rate limiting;
- publicar política de privacidad;
- verificar la declaración contra el comportamiento de la compilación release;
- proporcionar un mecanismo web público de eliminación de cuenta.
