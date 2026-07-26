# Guía de Beta Local

## Objetivo

Esta beta permite instalar Finanzas App Mobile en dispositivos Android reales y
conectarla por HTTPS con la API alojada temporalmente en XAMPP. No corresponde a
una publicación en Google Play ni a una infraestructura de producción.

## Identificación de la beta

- Versión: `1.0.0-beta.1`
- Build: `1`
- Application ID: `com.finanzas_app_san.emanuelsantamariabello`
- Entorno: `beta`
- API: `https://beta-api.finanzasappsan.com/finanzas_app/api`
- Fecha de preparación: `2026-07-26`
- Commit estable de origen: `407da89`

## Requisitos

- Windows con XAMPP, Apache y MariaDB operativos.
- `cloudflared` autenticado para `finanzasappsan.com`.
- Túnel `finanzas-beta` y sus credenciales locales.
- Flutter y Android SDK instalados.
- Computador conectado a Internet durante toda la prueba.

Las credenciales de Cloudflare permanecen en
`%USERPROFILE%\.cloudflared` y nunca deben copiarse al repositorio.

## Configuración local del túnel

El archivo local `%USERPROFILE%\.cloudflared\config.yml` usa el túnel
`029c0c89-1bab-4881-9c61-b5c6b3801294`, la credencial JSON local y estas reglas:

```yaml
ingress:
  - hostname: beta-api.finanzasappsan.com
    path: ^/finanzas_app/api(?:/.*)?$
    service: http://localhost:80
  - hostname: beta-api.finanzasappsan.com
    service: http_status:404
  - service: http_status:404
```

No se publica el puerto de MySQL. El túnel dirige exclusivamente las rutas de
`/finanzas_app/api` hacia Apache en el puerto detectado `80`. Cualquier otra
ruta del subdominio devuelve `404` para no exponer el dashboard de XAMPP ni
otros proyectos ubicados en `htdocs`.

## Iniciar el backend

1. Iniciar Apache y MySQL desde el panel de XAMPP.
2. Comprobar localmente:

```powershell
curl.exe -I http://localhost/
curl.exe http://localhost/finanzas_app/api/login.php
```

3. Iniciar el túnel:

```powershell
cloudflared tunnel run finanzas-beta
```

4. Mantener esa terminal abierta durante las pruebas.
5. Comprobar la API pública:

```powershell
curl.exe https://beta-api.finanzasappsan.com/finanzas_app/api/login.php
```

Una respuesta JSON indicando campos obligatorios confirma que el endpoint está
accesible; no representa un fallo de conectividad.

### Ejecución en segundo plano

El túnel puede ejecutarse como proceso oculto durante una sesión de Windows. La
instalación como servicio del sistema requiere abrir PowerShell como
administrador y ejecutar:

```powershell
cloudflared service install
```

La instalación automática del servicio no debe asumirse hasta confirmar que la
cuenta del servicio puede leer una copia protegida de `config.yml` y del JSON de
credenciales. Nunca relajar los permisos de esos archivos para resolverlo.

## Detener el túnel

- En primer plano: presionar `Ctrl+C`.
- En segundo plano:

```powershell
Get-Process cloudflared | Stop-Process
```

Detener el túnel no apaga Apache ni MySQL. Al detener Apache, MySQL, el
computador o la conexión a Internet, la API beta deja de estar disponible.

## Compilar el APK beta

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --release --dart-define=APP_ENV=beta
```

La URL beta se selecciona mediante `APP_ENV=beta`. `API_BASE_URL` sigue
disponible para una sobrescritura controlada:

```powershell
flutter build apk --release --dart-define=APP_ENV=beta --dart-define=API_BASE_URL=https://beta-api.finanzasappsan.com/finanzas_app/api
```

El APK se genera en:

```text
build\app\outputs\flutter-apk\app-release.apk
```

## Instalar y actualizar

Con un dispositivo autorizado por ADB:

```powershell
adb install build\app\outputs\flutter-apk\app-release.apk
```

Para actualizar una beta con el mismo Application ID y la misma firma:

```powershell
adb install -r build\app\outputs\flutter-apk\app-release.apk
```

También puede compartirse el APK por un canal privado. Android solicitará
autorizar temporalmente la instalación desde la aplicación usada para abrir el
archivo. No se recomienda publicarlo mediante enlaces abiertos.

Para desinstalar:

```powershell
adb uninstall com.finanzas_app_san.emanuelsantamariabello
```

Desinstalar borra las preferencias locales de la aplicación. Para volver a una
beta anterior, primero se debe disponer de su APK y tener en cuenta que Android
normalmente impide instalar un build con número inferior sin desinstalar.

## Riesgos de la beta

- La disponibilidad depende del computador, XAMPP y Cloudflare Tunnel.
- Los datos creados se almacenan en la base de datos local conectada a XAMPP.
- El subdominio es público mientras el túnel está activo.
- La firma release actual es de depuración y no debe usarse en Google Play.
- La URL raíz del subdominio devuelve `404` de forma intencional. Solo
  `/finanzas_app/api` está publicado.
- No existe todavía una URL aprobada para producción. Ese entorno exige
  `API_BASE_URL` y no reutiliza silenciosamente la URL local o beta.

## Checklist previo a distribución

- [x] `flutter analyze` limpio.
- [x] Pruebas automatizadas aprobadas.
- [x] APK release generado.
- [x] API HTTPS accesible.
- [x] XAMPP y túnel iniciados.
- [x] No hay secretos ni credenciales en Git.
- [x] Versión y build verificados.
- [x] Icono y splash presentes.
- [x] Permisos Android revisados.
- [ ] Login y cierre de sesión probados en dispositivo físico.
- [ ] CRUD de ingresos y gastos probado.
- [ ] Dashboard, movimientos, estadísticas y perfil probados.
- [ ] Errores de red probados.
- [x] APK confirmado como no versionado.
- [x] Rama registrada; el commit se informa al finalizar esta preparación.
