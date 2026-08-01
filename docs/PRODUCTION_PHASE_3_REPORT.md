# Fase 3 — Autorización y endurecimiento de API

Fecha de implementación: 31 de julio de 2026.

Estado: implementada offline y pendiente de despliegue coordinado.

## Resultado

- Flutter adjunta el token global a dashboard, movimientos, estadísticas,
  perfil y notificaciones.
- `user_id` se conserva temporalmente para compatibilidad con el backend
  anterior, pero el backend nuevo lo ignora para autorización.
- El backend deriva siempre el usuario desde la sesión.
- Ingresos y gastos validan propietario al consultar o modificar.
- Un gasto solo puede asociarse a un ingreso del mismo usuario.
- Perfil, dashboard y estadísticas usan exclusivamente al usuario del token.
- Login y registro incorporan rate limiting.
- CORS deja de utilizar el comodín global.
- Los errores internos ya no se exponen directamente al cliente.

## Compatibilidad

El cliente preparado para Beta 9 funciona contra:

- backend anterior, mediante el campo `user_id` conservado;
- backend protegido, mediante el encabezado Bearer.

La Beta 8 no debe utilizarse después de desplegar el backend protegido porque
no adjunta el token global en todos los endpoints.

## Validaciones ejecutadas

Backend aislado:

- todos los archivos PHP pasan validación de sintaxis;
- HTTP 401 para endpoints financieros sin token;
- dos usuarios aislados en ingresos, gastos, dashboard y perfil;
- manipulación de `user_id` sin efecto;
- acceso legítimo del propietario conservado;
- HTTP 429 después de superar el límite de login;
- base y servidor temporales eliminados.

Flutter:

- `flutter analyze --no-pub`: sin diagnósticos;
- `flutter test --no-pub`: 104 pruebas aprobadas;
- prueba adicional para solicitudes sin sesión segura aprobada.

## Despliegue pendiente

No se modificó la API Beta activa para evitar interrumpir la Beta 8 instalada.
Cuando exista conectividad:

1. Incrementar versión y generar APK Beta 9.
2. Instalar Beta 9 todavía contra el backend anterior.
3. Confirmar login y módulos principales.
4. Respaldar API y base de datos.
5. Aplicar la migración de rate limiting.
6. Desplegar el backend protegido.
7. Repetir pruebas funcionales y negativas mediante HTTPS.

No debe iniciarse la Fase 4 hasta completar este despliegue o registrar
explícitamente que las validaciones manuales se acumularán para una jornada de
pruebas posterior.
