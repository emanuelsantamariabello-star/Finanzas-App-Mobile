# Política de privacidad — Borrador operativo

Fecha del borrador: 31 de julio de 2026.

Este documento describe el comportamiento implementado, pero todavía no es la
versión pública definitiva. Debe revisarse legalmente y publicarse en una URL
estable antes de distribuir la aplicación en Google Play.

## Datos utilizados

Finanzas App trata los datos que el usuario proporciona para crear y usar su
cuenta:

- nombre, correo, ocupación y contraseña protegida mediante hash;
- foto de perfil opcional;
- ingresos, gastos, fechas, notas y clasificaciones financieras;
- recordatorios, metas, presupuestos, filtros y preferencias almacenados en el
  dispositivo;
- tokens técnicos de sesión y datos mínimos de seguridad para limitar intentos
  abusivos.

## Finalidades

Los datos se usan para autenticar al usuario, mostrar su información financiera,
generar resúmenes y reportes, programar recordatorios solicitados y proteger el
acceso a la API. Finanzas App no incorpora publicidad ni venta de datos.

## Almacenamiento y seguridad

Los datos financieros y de perfil se almacenan en la base del servicio. Los
tokens del dispositivo usan almacenamiento seguro y el servidor conserva solo
sus hashes. Las comunicaciones Beta y futuras comunicaciones productivas deben
usar HTTPS. MySQL no debe publicarse en Internet.

## Eliminación de cuenta

Desde `Perfil > Configuración de la app > Privacidad y datos`, el usuario puede
solicitar la eliminación definitiva confirmando su contraseña. Se eliminan la
cuenta, movimientos, sesiones, foto y datos locales asociados. La operación no
puede deshacerse.

Los respaldos técnicos no se modifican directamente por esta solicitud. Antes
de producción debe aprobarse y automatizarse un periodo limitado de retención,
tras el cual los respaldos expiran. No deben restaurarse datos eliminados al
sistema activo salvo una obligación legítima documentada.

## Permisos del dispositivo

- Notificaciones: para recordatorios activados por el usuario.
- Fotos o cámara: únicamente cuando el usuario decide cambiar su foto de
  perfil, según las opciones disponibles en el dispositivo.

## Contacto y publicación pendientes

Antes del lanzamiento deben definirse el responsable, un correo de privacidad,
la jurisdicción aplicable, la fecha de vigencia y la URL pública estable.
