# Informe de seguridad de foto de perfil

Fecha de validación: 29 de julio de 2026.

## Alcance

Se validó el flujo de fotografía de perfil del cliente Flutter y la API Beta
publicada en:

`https://beta-api.finanzasappsan.com/finanzas_app/api`

Las pruebas utilizaron dos usuarios y tres tokens temporales. Todos los datos
de prueba fueron eliminados al terminar.

## Contratos HTTPS

| Prueba | Resultado |
| --- | --- |
| Solicitud sin token | HTTP 401 |
| Token malformado | HTTP 401 |
| Token vencido | HTTP 401 |
| MIME falso con extensión JPEG | HTTP 422 |
| JPEG corrupto | HTTP 422 |
| Archivo mayor a 3 MB | HTTP 422 |
| Carga de JPEG válido | HTTP 200 |
| Consulta de foto propia | HTTP 200, `image/jpeg` |
| Consulta desde otro usuario | HTTP 404 |
| Reemplazo de foto | HTTP 200 |
| Eliminación de foto | HTTP 200 |
| Consulta después de eliminar | HTTP 404 |
| Revocación de token | HTTP 200 |
| Uso del token revocado | HTTP 401 |

La API desplegada en XAMPP coincide con los archivos versionados en la rama
del backend. La prueba de reemplazo eliminó el archivo anterior y la
eliminación final no dejó fotografías temporales.

## Privacidad

- El backend almacena únicamente el hash SHA-256 del token multimedia.
- El cliente guarda el token y su vencimiento en Flutter Secure Storage.
- `FlutterSharedPreferences.xml` no contiene la clave del token.
- SharedPreferences conserva únicamente metadatos no sensibles de la foto.
- Los logs de Apache no contienen tokens ni identificadores temporales usados
  durante las pruebas.
- No se registran cuerpos completos, cabeceras de autorización ni fotografías.

## Validaciones automatizadas

- `dart analyze lib test`: sin diagnósticos.
- `flutter test`: 100 pruebas superadas.
- `php -l`: sin errores en el helper, login y los cuatro endpoints multimedia.

## Pendiente para Fase 6

La persistencia visual después de instalar, reiniciar y volver a autenticar se
confirmará manualmente en un dispositivo físico con el APK Beta release.
