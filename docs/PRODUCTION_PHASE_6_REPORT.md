# Fase 6 — Android release

Fecha de preparación: 31 de julio de 2026.

Estado: configuración y AAB estructural validados; firma definitiva, Play App
Signing y prueba de actualización pendientes.

## Implementado

- identidad Android definitiva conservada;
- versión candidata `1.0.0-rc.1+9`;
- firma release separada de debug mediante `key.properties` ignorado;
- bloqueo explícito de release sin firma, salvo modo estructural controlado;
- cleartext deshabilitado en main/release;
- HTTP local permitido únicamente en debug y profile;
- certificados limitados al almacén del sistema en release;
- script reproducible con HTTPS, entorno production, ofuscación y símbolos.

## Validación automática

Se generó correctamente un AAB estructural no publicable:

- tamaño aproximado: 44.8 MB;
- arquitecturas con símbolos: ARM, ARM64 y x64;
- URL compilada: `https://api.finanzasappsan.com`;
- build number: 9.

El artefacto se conserva solo en `build/`, que está excluido de Git. No se creó
ni se expuso una upload key.

## Pendientes manuales

- generar y respaldar upload key;
- activar Play App Signing;
- generar el AAB firmado;
- validar certificado y actualización desde Beta;
- instalar desde prueba interna y ejecutar la matriz funcional.
