# Plan de implementación de foto de perfil

## Objetivo

Permitir que cada usuario seleccione, cargue, visualice, reemplace y elimine
una fotografía de perfil desde Finanzas App Mobile, sin alterar la lógica
financiera, la navegación principal ni los providers existentes.

La implementación debe funcionar en la Beta Local mediante HTTPS y quedar
preparada para migrar a producción sin guardar imágenes dentro de
SharedPreferences ni exponer archivos directamente desde Apache.

## Estado actual

- `ProfileScreen` muestra un avatar generado con la inicial del usuario.
- `EditProfileScreen` actualiza nombre, email y ocupación.
- `UserService` solo consume endpoints JSON o formularios simples.
- `SessionStorageService` no administra referencias de imágenes ni tokens
  multimedia.
- La tabla `users` ya contiene la referencia interna y fecha de actualización
  de la fotografía.
- La API ya dispone de endpoints protegidos de carga, lectura, eliminación y
  revocación del token multimedia.
- La versión Web tampoco implementa fotografía de perfil reutilizable.
- PHP mantiene `fileinfo` y `GD` habilitados para validar y normalizar imágenes.
- Cloudflare Tunnel publica únicamente `/finanzas_app/api`.
- Android usa `minSdk 24` y `MainActivity` tiene `launchMode="singleTop"`,
  configuración compatible con el selector oficial de imágenes.
- iOS no contiene todavía las descripciones de privacidad para cámara y
  galería.

## Decisiones de arquitectura

### Almacenamiento

- Guardar archivos en un directorio administrado por el backend.
- Impedir acceso directo al directorio mediante configuración de Apache.
- Entregar la imagen exclusivamente mediante un endpoint PHP.
- Guardar en MySQL únicamente el nombre interno y la fecha de actualización.
- Usar nombres aleatorios criptográficamente seguros.
- Eliminar la imagen anterior únicamente después de confirmar la nueva
  persistencia.
- No almacenar bytes, Base64 ni rutas locales en SharedPreferences.

### Procesamiento

- Aceptar inicialmente JPEG, PNG y WebP.
- Limitar el archivo recibido a 3 MB.
- Validar MIME real mediante `fileinfo`.
- Validar dimensiones con las funciones de imagen de PHP.
- Rechazar imágenes vacías, corruptas o con dimensiones excesivas.
- Habilitar `GD` para redimensionar a un máximo de 1024 píxeles y volver a
  codificar la imagen, eliminando metadatos y contenido adicional.
- Normalizar el resultado a un formato controlado por el servidor.

### Autorización

Los endpoints multimedia no deben confiar únicamente en un `user_id`, porque
eso permitiría consultar o modificar fotografías de otras cuentas.

Se utilizará un token multimedia:

- generado con aleatoriedad criptográfica durante el login;
- almacenado en MySQL únicamente como hash;
- devuelto por HTTPS solo al usuario autenticado;
- guardado mediante almacenamiento seguro de la plataforma;
- enviado mediante `Authorization: Bearer`;
- independiente para cada inicio de sesión y dispositivo;
- válido durante 90 días y revocable explícitamente;
- eliminado del almacenamiento seguro al cerrar sesión.

Esta autorización quedará limitada inicialmente a los endpoints de fotografía
y no reemplazará en esta fase todo el sistema de autenticación existente.

### Base de datos

La migración agrega a `users`:

```sql
profile_photo_filename VARCHAR(255) NULL
profile_photo_updated_at DATETIME NULL
```

Los hashes de tokens se almacenan por separado en
`profile_media_tokens`, permitiendo varias sesiones/dispositivos sin exponer el
token original. La migración es reversible y se ejecutó después de respaldar la
tabla `users`.

### Contrato API

#### Login

`login.php` mantendrá su contrato actual y agregará:

```json
{
  "user": {
    "profile_photo_available": true,
    "profile_photo_updated_at": "2026-07-29T20:00:00-05:00"
  },
  "profile_media_token": "token-solo-visible-en-login"
}
```

No se devolverá una ruta física ni el nombre interno del archivo.

#### Cargar o reemplazar

`POST upload_profile_photo.php`

- Header: `Authorization: Bearer <token>`.
- Content-Type: `multipart/form-data`.
- Campo requerido: `photo`.
- Respuesta: disponibilidad y fecha de actualización.

#### Consultar

`GET profile_photo.php`

- Header: `Authorization: Bearer <token>`.
- Devuelve bytes con MIME controlado, `X-Content-Type-Options: nosniff` y
  política de caché privada.

#### Eliminar

`POST delete_profile_photo.php`

- Header: `Authorization: Bearer <token>`.
- Elimina el archivo y limpia sus columnas en una operación controlada.

#### Revocar sesión multimedia

`POST revoke_profile_media_token.php`

- Header: `Authorization: Bearer <token>`.
- Revoca únicamente el token utilizado en la solicitud.

## Experiencia móvil

- Mantener el avatar con iniciales como fallback permanente.
- Agregar un botón de cámara sobre el avatar en Editar perfil.
- Abrir un bottom sheet con:
  - Elegir de la galería.
  - Tomar una foto.
  - Eliminar foto, únicamente cuando exista.
- Mostrar una vista previa circular antes o durante la carga.
- Bloquear cargas duplicadas mientras exista una operación activa.
- Mostrar progreso, éxito y errores mediante los componentes actuales.
- Refrescar `ProfileScreen` al regresar sin reiniciar otros módulos.
- Aplicar `BoxFit.cover`, temas claro/oscuro, semántica y áreas táctiles
  accesibles.
- Recuperar selecciones interrumpidas por Android mediante `retrieveLostData`.

## Dependencias y plataformas

- Usar el plugin oficial `image_picker`.
- Usar `flutter_secure_storage` exclusivamente para el token multimedia.
- No solicitar acceso general al almacenamiento en Android.
- Mantener `launchMode="singleTop"`.
- Agregar en iOS:
  - `NSPhotoLibraryUsageDescription`.
  - `NSCameraUsageDescription`.
- No agregar un paquete de caché o recorte durante la primera entrega.
- El recorte manual y filtros de imagen quedan fuera del alcance inicial.

## Fases

### Fase 0 — Contrato y seguridad

- Documentar arquitectura, límites, endpoints y riesgos.
- Definir migración reversible y política de archivos.
- Separar el trabajo móvil del backend mediante ramas controladas.
- No modificar todavía base de datos ni comportamiento.

### Fase 1 — Backend y persistencia

- Completada el 29 de julio de 2026.
- Se respaldó `users` antes de aplicar la migración reversible.
- Se habilitó y validó `GD` en PHP CLI y Apache.
- Se creó almacenamiento protegido fuera del árbol público de la API.
- Se implementaron tokens multimedia con hash, expiración y soporte
  multidispositivo.
- Se implementaron carga, lectura, eliminación y revocación.
- Se validó por Apache local y por
  `https://beta-api.finanzasappsan.com/finanzas_app/api`.
- Las pruebas cubrieron login, autorización, archivo inválido, normalización,
  redimensionado, borrado y revocación sin dejar imágenes de prueba.

### Fase 2 — Cliente y sesión

- Completada el 29 de julio de 2026.
- Se agregaron `image_picker` y `flutter_secure_storage`.
- El token y su vencimiento se guardan exclusivamente en almacenamiento
  seguro; SharedPreferences conserva solo disponibilidad y fecha de la foto.
- `ApiClient` soporta cabeceras autenticadas, respuestas binarias y cargas
  multipart sin cambiar los contratos existentes.
- `UserService` integra carga, consulta, eliminación y revocación.
- El login procesa los nuevos campos manteniendo compatibilidad con respuestas
  y sesiones sin fotografía.
- Android deshabilita Auto Backup para evitar restaurar material cifrado sin
  su clave y Apple incluye permisos de cámara, galería y Keychain.

### Fase 3 — Interfaz de perfil

- Adaptar avatar de Perfil y Editar perfil.
- Agregar bottom sheet de cámara, galería y eliminación.
- Mantener estados de carga, fallback y feedback visual.
- Refrescar el perfil al completar una operación.

### Fase 4 — Ciclo de vida y accesibilidad

- Recuperar datos perdidos del selector en Android.
- Validar cancelación, permisos denegados y proceso interrumpido.
- Revisar texto ampliado, pantallas pequeñas y temas.
- Controlar caché y reemplazo inmediato de fotografía.

### Fase 5 — Seguridad y pruebas

- Probar MIME falso, archivos grandes y archivos corruptos.
- Probar tokens ausentes, vencidos o correspondientes a otro usuario.
- Probar carga, reemplazo, consulta y eliminación.
- Ejecutar pruebas unitarias, de widgets y contratos HTTPS.
- Confirmar que ningún secreto, token o fotografía aparezca en logs.
- Confirmar que el token no se almacene en SharedPreferences.

### Fase 6 — Beta y cierre

- Incrementar versión y build Beta.
- Generar APK release con `APP_ENV=beta`.
- Verificar firma, hash, instalación y arranque.
- Ejecutar validación manual en dispositivo físico.
- Fusionar y publicar únicamente después de aprobación.
- Eliminar las ramas finalizadas.

## Estrategia de repositorios

- Flutter se trabajará en `codex/profile-photo`.
- El backend debe trabajarse en una rama o worktree limpio y separado.
- La instalación actual de XAMPP contiene cambios previos no relacionados; no
  se deben incluir en commits de esta función.
- Cada fase debe terminar con un commit pequeño y verificable.
- Los archivos subidos y credenciales nunca se incluirán en Git.

## Criterios de aceptación

- Un usuario puede seleccionar cámara o galería y cargar una imagen válida.
- La foto aparece en Perfil y Editar perfil sin reiniciar la aplicación.
- La imagen se mantiene al cerrar y volver a abrir la app.
- La imagen se restaura después de cerrar sesión e iniciar nuevamente.
- Reemplazar o eliminar la foto actualiza la interfaz inmediatamente.
- Un usuario no puede leer, modificar ni eliminar la imagen de otra cuenta.
- Archivos inválidos o demasiado grandes se rechazan con mensajes claros.
- La app sigue mostrando iniciales si no existe imagen o falla la red.
- No se agregan permisos amplios de almacenamiento.
- Análisis, pruebas y compilación Beta permanecen limpios.

## Fuera de alcance

- Recorte manual avanzado.
- Filtros o edición fotográfica.
- Sincronización con Gravatar o redes sociales.
- Almacenamiento en servicios cloud externos.
- Migración completa de todos los endpoints a autenticación por token.
