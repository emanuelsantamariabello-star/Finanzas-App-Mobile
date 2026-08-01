# Matriz de calidad y compatibilidad

## Automatizado

| Área | Cobertura |
| --- | --- |
| Análisis | `flutter analyze` y formato en CI |
| Unidad/widget | servicios, providers, auth, almacenamiento, reportes y UI |
| Red | desconexión, HTTP seguro, JSON inválido y configuración |
| Accesibilidad | login a 200% en temas claro y oscuro, pantalla compacta |
| Android release | AAB estructural, HTTPS y símbolos separados |
| Backend | auth, autorización, eliminación, CORS, migraciones y recuperación |

## Matriz manual diferida

Debe ejecutarse sobre emuladores o dispositivos representativos:

| Plataforma | Casos mínimos |
| --- | --- |
| Android 7 / API 24 | arranque, login, CRUD y notificaciones básicas |
| Android 10 / API 29 | permisos, archivos compartidos y reinicio |
| Android 13 / API 33 | permiso de notificaciones y selector de imágenes |
| Android 15 / API 35 | edge-to-edge, navegación y actualización |
| Android 16 / API vigente | compatibilidad final según Play Console |

En cada nivel deben cubrirse tema claro/oscuro/sistema, texto 100/150/200%,
pantalla pequeña, rotación cuando aplique, teclado, gestos y botones digitales.

## Resiliencia manual diferida

- sin red antes de iniciar y durante una solicitud;
- red lenta, pérdida intermitente y timeout;
- backend detenido y respuesta 5xx;
- permiso de notificaciones o fotos denegado;
- poco almacenamiento al exportar PDF/CSV;
- cierre forzado, reinicio y actualización desde Beta;
- sesión expirada, revocada y cambio de contraseña;
- eliminación usando exclusivamente una cuenta desechable.

Los resultados deben registrarse por dispositivo, versión, fecha y commit. Un
caso fallido bloquea promoción hasta quedar resuelto o aceptado explícitamente.
