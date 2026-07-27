# Plan de integración de funciones de Finanzas App Web

## Objetivo

Tomar como referencia funcional el proyecto `finanzas_app_web` para incorporar
en Finanzas App Mobile:

1. Clasificación de gastos entre necesarios y gustos.
2. Generación y uso compartido de reportes PDF.
3. Panel interno de notificaciones.

La versión web fue auditada en modo de solo lectura. No se modificará ni se
acoplará directamente su interfaz con Flutter.

## Estado de referencia

### Clasificación de gastos

La versión web:

- usa el campo `reflection_type`;
- admite únicamente `necesario` y `gusto`;
- guarda el valor al crear y editar gastos;
- calcula porcentajes de cada clasificación para el coach financiero;
- incluye la clasificación en el reporte PDF.

La base de datos móvil es independiente de la base web. La tabla `expenses` de
la base móvil todavía no contiene `reflection_type`, aunque existe una migración
de referencia sin aplicar. Los endpoints móviles de creación y actualización
tampoco reciben el campo.

### Reporte PDF

La versión web genera el PDF en el servidor con DomPDF y una sesión PHP. Incluye:

- período;
- totales de ingresos y gastos;
- balance y estado financiero;
- detalle de gastos;
- proporción de necesarios y gustos;
- mensaje del coach financiero;
- fecha y hora de generación.

Ese endpoint no puede reutilizarse directamente desde Flutter porque depende de
la sesión web. La opción recomendada para móvil es generar el PDF en el
dispositivo a partir de los datos ya obtenidos por la aplicación. Esto evita
crear una segunda autenticación de sesión y permite compartir el archivo con el
flujo existente de `share_plus`.

### Notificaciones internas

La versión web combina:

- novedades globales activas desde `system_notifications`;
- un recordatorio financiero calculado con la fecha de ingreso más reciente;
- un badge con cantidad pendiente;
- estado leído guardado localmente por usuario.

La aplicación móvil ya cuenta con recordatorios locales programados, pero no
tiene un panel interno ni consume novedades del servidor. La base móvil tampoco
contiene todavía `system_notifications`.

## Riesgos detectados

### Backend móvil

El backend utilizado por la app está en un repositorio diferente y actualmente
tiene numerosos cambios previos sin consolidar, además de la carpeta `api` sin
seguimiento completo. Antes de modificarlo se debe definir un commit controlado
que no mezcle esos cambios históricos con esta integración.

### Datos

- La base web y la base móvil son diferentes.
- Las migraciones deben ejecutarse únicamente sobre `finanzas_app`.
- Antes de cualquier migración se debe generar un respaldo.
- Los clientes beta anteriores deben seguir creando gastos válidos. Por eso el
  backend debe usar `necesario` como valor compatible cuando el campo no llegue.

### Seguridad

- El panel móvil solo necesita lectura de notificaciones del sistema.
- No se expondrán endpoints administrativos de creación, activación o borrado.
- Los PDF pueden contener datos financieros y deben generarse en almacenamiento
  privado o temporal antes de compartirlos.
- No se imprimirán payloads, credenciales ni contenido financiero en logs.

## Contratos propuestos

### Gasto

Campo adicional:

```text
reflection_type: necesario | gusto
```

Comportamiento:

- valor inicial: `necesario`;
- requerido y validado en la interfaz nueva;
- compatible con clientes anteriores mediante fallback del backend;
- incluido en las respuestas de gastos;
- editable sin alterar los demás campos.

### Notificación interna

Respuesta de lectura propuesta:

```json
{
  "success": true,
  "data": [
    {
      "id": "system-1",
      "title": "Título",
      "message": "Mensaje",
      "type": "info",
      "source": "system",
      "created_at": "2026-07-26 12:00:00"
    }
  ],
  "count": 1
}
```

Tipos permitidos: `info`, `success`, `warning` y `danger`.

El estado leído se guardará localmente por `userId + notificationId`, siguiendo
el comportamiento de la versión web y evitando una tabla adicional en esta
primera entrega.

## Fases de implementación

### Fase 0 — Auditoría y contratos

- Revisar la versión web sin modificarla.
- Comparar bases de datos, endpoints y UI.
- Definir contratos y riesgos.
- Registrar este documento.

### Fase 1 — Clasificación de gastos

- Respaldar la base móvil.
- Aplicar una migración idempotente para `reflection_type`.
- Adaptar exclusivamente los endpoints móviles de crear y actualizar gastos.
- Enviar el campo desde `ExpenseService`.
- Incorporar selector accesible en crear y editar gasto.
- Precargar la clasificación existente al editar.
- Mostrar una identificación discreta en las tarjetas de gastos.
- Validar creación, edición, carga y compatibilidad.

### Fase 2 — Base del reporte PDF

- Incorporar una librería PDF compatible con Flutter.
- Crear un servicio aislado de generación.
- Reutilizar `path_provider` y `share_plus`.
- Generar archivos privados o temporales.
- Añadir pruebas de estructura y contenido básico.

### Fase 3 — Reporte financiero móvil

- Permitir período actual, anterior, personalizado o historial.
- Incluir resumen, balance, movimientos y clasificación de gastos.
- Incorporar el mensaje financiero equivalente al reporte web.
- Integrar PDF en el menú de exportación sin eliminar CSV.
- Validar montos, caracteres UTF-8, apertura y uso compartido.

### Fase 4 — Backend de notificaciones internas

- Respaldar la base móvil.
- Crear `system_notifications` mediante migración idempotente.
- Adaptar el cálculo de recordatorio financiero al esquema móvil.
- Crear un endpoint móvil exclusivamente de lectura.
- Publicarlo dentro de la ruta HTTPS existente.
- Verificar respuestas vacías, activas, vencidas y no válidas.

### Fase 5 — Panel interno móvil

- Crear modelo, servicio y provider de notificaciones internas.
- Añadir campana con badge en Inicio.
- Crear panel responsive con estados de carga, vacío y error.
- Permitir marcar todas como leídas localmente.
- Refrescar al iniciar sesión y mediante acción manual.
- Mantener separados los recordatorios locales ya existentes.

### Fase 6 — Integración beta

- Ejecutar análisis y pruebas automatizadas.
- Validar los tres flujos en dispositivo físico.
- Incrementar versión y build beta.
- Actualizar README y plan de pruebas.
- Generar e inspeccionar una nueva APK.
- Crear commits separados por fase.

## Criterios de aceptación

- Crear y editar un gasto conserva su clasificación.
- Clientes beta anteriores siguen pudiendo registrar gastos.
- CSV continúa funcionando.
- PDF se genera, abre y comparte con datos correctos.
- El panel muestra únicamente notificaciones activas.
- El badge refleja elementos no leídos.
- Marcar como leído persiste para el mismo usuario.
- No se rompe el sistema de recordatorios locales.
- No se modifica Finanzas App Web.
- No se mezclan secretos ni cambios históricos del backend en los commits.
