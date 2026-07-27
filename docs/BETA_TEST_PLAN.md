# Plan de Pruebas de Beta

## Datos de ejecución

| Campo | Valor |
| --- | --- |
| Versión | `1.0.0-beta.4` |
| Build | `4` |
| Commit | Completar después del commit de preparación |
| Dispositivo |  |
| Android |  |
| Red |  |
| Fecha |  |
| Probador |  |

## Registro de resultados

Para cada caso registrar: `Aprobado`, `Fallido` o `Bloqueado`, evidencia y
severidad (`Crítica`, `Alta`, `Media` o `Baja`).

| ID | Funcionalidad | Pasos resumidos | Resultado esperado |
| --- | --- | --- | --- |
| AUTH-01 | Registro | Instalar limpio, abrir Registro y crear una cuenta válida. | La cuenta se crea y la app vuelve al login sin reutilizar otra sesión. |
| AUTH-02 | Login | Ingresar credenciales válidas. | Abre la navegación principal y carga el dashboard. |
| AUTH-03 | Error de login | Ingresar credenciales inválidas. | Muestra un mensaje comprensible y permanece en login. |
| AUTH-04 | Persistencia | Iniciar sesión, cerrar y reabrir la app. | La sesión se restaura según el comportamiento vigente. |
| AUTH-05 | Cierre de sesión | Cerrar sesión desde Perfil. | Vuelve al login y no permite regresar a la sesión cerrada. |
| HOME-01 | Dashboard | Abrir Inicio con movimientos existentes. | Muestra balance, resúmenes y accesos sin errores. |
| INC-01 | Ingresos | Crear, editar y eliminar un ingreso de prueba. | Cada operación se refleja en listas y dashboard. |
| EXP-01 | Gastos | Crear, editar y eliminar un gasto de prueba. | Cada operación se refleja en listas y dashboard. |
| EXP-02 | Clasificación | Crear y editar gastos como necesario y gusto. | La clasificación seleccionada se conserva y aparece en la lista. |
| MOV-01 | Movimientos | Alternar entre Ingresos y Gastos. | Las pestañas conservan datos y acciones correctas. |
| MOV-02 | Búsqueda | Buscar por nota, tipo o monto. | Solo aparecen coincidencias válidas. |
| MOV-03 | Filtros | Aplicar filtros de fecha y limpiarlos. | El rango y la lista se actualizan correctamente. |
| MOV-04 | Exportación | Exportar y compartir CSV. | Se genera un archivo que puede abrirse o compartirse. |
| MOV-05 | Reporte PDF | Generar períodos actual, anterior, personalizado e historial. | El PDF abre, contiene el período correcto y puede compartirse. |
| MOV-06 | Contenido PDF | Revisar resumen, movimientos y clasificación. | Los montos, tildes, necesarios y gustos se muestran correctamente. |
| STAT-01 | Estadísticas | Abrir Estadísticas después de crear movimientos. | Las gráficas reflejan ingresos, gastos y evolución mensual. |
| PROF-01 | Perfil | Editar nombre, email y ocupación. | Los cambios se guardan y se actualizan en Perfil. |
| PROF-02 | Contraseña | Cambiar contraseña y volver a iniciar sesión. | La nueva contraseña funciona y la anterior deja de hacerlo. |
| NOTIF-01 | Panel interno | Abrir la campana desde Inicio. | Muestra solo notificaciones internas activas sin afectar recordatorios locales. |
| NOTIF-02 | Badge | Recibir notificaciones pendientes. | El badge coincide con la cantidad de elementos no leídos. |
| NOTIF-03 | Estado leído | Marcar todas como leídas y reabrir la app. | El estado permanece para el mismo usuario y no se comparte con otros. |
| NOTIF-04 | Actualización | Actualizar manualmente el panel. | Consulta nuevamente la API y conserva un estado visual válido. |
| NET-01 | Wi-Fi/datos | Cambiar de Wi-Fi a datos móviles con la app abierta. | Las operaciones posteriores continúan por HTTPS. |
| NET-02 | Internet lento | Limitar la red e intentar cargar datos. | Muestra carga y un error comprensible si vence el timeout. |
| NET-03 | Sin conexión | Activar modo avión durante una carga. | No se bloquea y permite reintentar al recuperar red. |
| NET-04 | API caída | Detener el túnel e intentar iniciar sesión. | Muestra error de conexión sin exponer detalles internos. |
| LIFE-01 | Reapertura | Forzar cierre y reabrir. | La app inicia sin pantalla roja ni estado inconsistente. |
| UI-01 | Rotación | Rotar en pantallas permitidas. | No hay desbordamientos ni pérdida de datos del formulario. |
| UI-02 | Tamaños | Probar teléfono pequeño y grande. | Contenido legible, desplazable y sin superposiciones. |
| INST-01 | Instalación limpia | Instalar en un equipo sin versión anterior. | La app abre y solicita únicamente permisos necesarios. |
| INST-02 | Actualización | Instalar un build superior sobre la beta anterior. | Conserva preferencias y abre correctamente. |

## Evidencia por caso

Copiar este bloque para cada ejecución:

```text
ID:
Resultado:
Dispositivo:
Android:
Red:
Evidencia:
Severidad:
Observaciones:
```

No usar cuentas ni movimientos financieros reales durante capturas o videos que
se vayan a compartir.
