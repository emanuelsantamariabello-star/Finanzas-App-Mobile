# Fase 4 — Privacidad y ciclo de cuenta

Fecha de implementación: 31 de julio de 2026.

Estado: implementación offline terminada; pendiente publicación, despliegue y
validación manual coordinada.

## Implementación

- Nueva sección `Privacidad y datos` dentro de Configuración.
- Inventario visible de los datos usados por la aplicación.
- Eliminación protegida por contraseña, texto de confirmación y diálogo final.
- Llamada autenticada a `delete_account.php`.
- Limpieza local de recordatorios, metas, presupuestos, filtros, avisos leídos,
  sesiones seguras y correo recordado.
- Cancelación de recordatorios locales programados.
- Conservación de preferencias generales del dispositivo, como el tema.
- Backend transaccional con eliminación de movimientos, perfil, sesiones,
  tokens multimedia y foto física.

## Validaciones automáticas

- Prueba backend aislada de contraseña incorrecta, cascadas, aislamiento,
  revocación y foto.
- Pruebas Flutter de limpieza selectiva y navegación de privacidad.
- `flutter analyze` sin diagnósticos.

## Pendientes con conectividad

1. Publicar la política aprobada en una URL HTTPS estable.
2. Preparar el mecanismo web público exigido por Google Play.
3. Empaquetar el cliente compatible con Fases 3 y 4.
4. Respaldar y migrar la Beta.
5. Desplegar de forma coordinada el backend protegido.
6. Validar eliminación desde un dispositivo real con una cuenta desechable.

No se modificó la API Beta activa ni la base de datos real durante esta fase.
