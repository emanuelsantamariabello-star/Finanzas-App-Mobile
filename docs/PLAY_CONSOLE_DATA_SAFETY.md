# Borrador de Data Safety

Este inventario ayuda a completar Play Console. No es una declaración final:
debe contrastarse con la infraestructura productiva, proveedores y versión
firmada que se publicará.

| Grupo | Datos | Uso actual | Tratamiento esperado |
| --- | --- | --- | --- |
| Información personal | Nombre, correo y ocupación | Cuenta y perfil | Servidor, asociados al usuario |
| Información financiera | Ingresos, gastos, notas, categorías y balances | Función principal | Servidor, privados por usuario |
| Fotos | Foto de perfil opcional | Personalización | Servidor, acceso autenticado |
| Actividad de la app | Metas, presupuestos, recordatorios y preferencias | Funciones locales | Dispositivo, separados por usuario |
| Seguridad | Dirección IP transformada para límites | Prevención de abuso | Logs o almacenamiento temporal del servidor |

## Declaraciones que deben verificarse

- La producción debe cifrar los datos en tránsito mediante HTTPS.
- La app no integra anuncios ni analítica de terceros en el estado auditado.
- No se venden datos personales.
- La eliminación dentro de la app existe, pero la URL web pública exigida por
  Google Play sigue pendiente.
- Deben declararse los plazos reales de retención de backups y logs.
- Cloudflare participa en el tránsito de la Beta; el proveedor productivo aún
  debe confirmarse antes de declarar terceros y finalidades.
- Los recordatorios y preferencias locales pueden permanecer en backups si la
  configuración de plataforma cambia; Android actualmente tiene backups
  deshabilitados para la app.

## Evidencia requerida antes de enviar

- URL pública de política de privacidad.
- URL pública de eliminación de cuenta.
- Diagrama definitivo de infraestructura y subencargados.
- Política de retención y eliminación de backups.
- Prueba de que todas las rutas productivas usan HTTPS.
- Revisión de dependencias del AAB final en Play SDK Index.
