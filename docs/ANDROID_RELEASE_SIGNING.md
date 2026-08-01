# Android release y firma

Fecha de preparación: 31 de julio de 2026.

## Identidad

- `applicationId`: `com.finanzas_app_san.emanuelsantamariabello`
- versión candidata: `1.0.0-rc.1+9`
- entorno: `production`
- API: recibida obligatoriamente mediante `API_BASE_URL` HTTPS.

## Upload key

La upload key no fue creada automáticamente. Debe generarse en un equipo
confiable, respaldarse cifrada en al menos dos ubicaciones controladas y nunca
incluirse en Git. Después se copia `android/key.properties.example` como
`android/key.properties` y se completan sus cuatro valores.

La configuración Gradle ya no utiliza la clave debug para release. Sin
`key.properties`, una compilación normal falla deliberadamente. El modo
`-AllowUnsigned` existe exclusivamente para validar estructura en CI o de forma
local y su AAB no puede publicarse.

Google Play App Signing debe activarse al crear la aplicación. La upload key se
usa para subir nuevas versiones; Google administra la app signing key final.

## Generación

```powershell
.\tools\build_android_release.ps1 `
  -ApiBaseUrl https://api.finanzasappsan.com
```

El script rechaza HTTP y el subdominio Beta, activa ofuscación y guarda los
símbolos separados en `build/symbols/android`. El AAB y los símbolos son
artefactos privados de release, no archivos del repositorio.

## Validación pendiente con firma

1. Verificar el certificado de la upload key y su vigencia.
2. Generar AAB firmado sin `-AllowUnsigned`.
3. Guardar hash SHA-256, símbolos y mapeos junto al registro del release.
4. Subir a prueba interna y confirmar `versionCode=9`.
5. Instalar desde Google Play y verificar actualización desde Beta.
6. Confirmar que todo el tráfico usa `https://api.finanzasappsan.com`.
