# Prueba cerrada y despliegue gradual

## Prueba interna

- Instalar desde Google Play en lugar de distribuir el APK manualmente.
- Probar instalación limpia y actualización desde la Beta anterior.
- Cubrir registro, login, cierre y revocación de sesión.
- Cubrir movimientos, dashboard, estadísticas, perfil y eliminación.
- Probar temas, permisos, cámara, galería, archivos y notificaciones.
- Registrar modelo, versión Android, versión de app y evidencia del resultado.

## Prueba cerrada

- Usar cuentas y datos ficticios.
- Incluir dispositivos desde Android 7 hasta la versión objetivo disponible.
- Observar crashes, ANR, errores de API, tiempos de respuesta y feedback.
- Mantener un canal de reporte con plantilla reproducible.
- No avanzar con hallazgos críticos o altos abiertos.

## Producción gradual

Propuesta sujeta a aprobación y métricas reales:

1. 5 %: vigilar estabilidad y autenticación.
2. 20 %: validar carga del backend y soporte.
3. 50 %: confirmar ausencia de regresiones y pérdida de datos.
4. 100 %: completar únicamente con métricas estables.

Cada aumento requiere una ventana de observación definida por el responsable
operativo. Play Console puede detener el rollout; el backend debe conservar un
procedimiento de rollback independiente.

## Señales de rollback

- Crash o ANR repetido en un flujo principal.
- Error de login o sesión generalizado.
- Acceso horizontal o exposición de información.
- Pérdida, duplicación o corrupción de movimientos.
- API fuera de disponibilidad o degradada de forma sostenida.
- Fallo de actualización que impida abrir la aplicación.
