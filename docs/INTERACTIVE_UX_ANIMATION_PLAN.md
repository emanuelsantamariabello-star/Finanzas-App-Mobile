# Plan de UX Interactiva y Animaciones

## Objetivo

Hacer que Finanzas App Mobile se perciba más viva, fluida y moderna mediante
animaciones breves y funcionales, sin modificar la arquitectura, navegación,
providers, contratos de API ni lógica financiera.

Las animaciones deben ayudar a comprender cambios de estado y acciones. No se
usarán como decoración constante ni deben retrasar una operación.

## Estado actual

La auditoría inicial encontró:

- 17 pantallas y 5 widgets reutilizables en la capa de presentación;
- navegación principal basada en `IndexedStack`, que conserva correctamente el
  estado, pero cambia de módulo de forma instantánea;
- rutas secundarias con la transición predeterminada de `MaterialPageRoute`;
- transiciones puntuales mediante `AnimatedPadding`, `AnimatedContainer`,
  `AnimatedSwitcher` y `AnimatedOpacity`;
- gráficas de `fl_chart` sin una política de movimiento definida por la app;
- ausencia de constantes globales para duración y curvas;
- ausencia de adaptación a `MediaQuery.disableAnimations`;
- mayor concentración de elementos interactivos en Inicio, Movimientos,
  Estadísticas y formularios financieros.

No se requiere una dependencia externa de animaciones para la primera entrega.
Las APIs implícitas de Flutter son suficientes y reducen el riesgo.

## Principios de movimiento

- Duraciones habituales entre 160 y 300 milisegundos.
- Curvas suaves como `easeOutCubic` para entradas y `easeInCubic` para salidas.
- Una sola intención visual por interacción.
- Conservación del estado de cada módulo principal.
- Sin animar nuevamente listas completas en cada actualización reactiva.
- Sin bloquear botones, navegación, formularios ni respuestas de la API.
- Respeto por tema claro, oscuro y del sistema.
- Reducción o eliminación del movimiento cuando el sistema lo solicite.
- Pruebas de widgets con animaciones asentadas mediante `pumpAndSettle`.

## Fases

### Fase 0 — Auditoría y contrato visual

- Inventariar transiciones actuales y puntos interactivos.
- Definir duraciones, curvas, accesibilidad y límites de uso.
- Registrar el plan sin modificar todavía el comportamiento visual.

### Fase 1 — Base de movimiento

- Crear constantes reutilizables de duración y curvas.
- Crear utilidades pequeñas para resolver movimiento reducido.
- Evitar controladores manuales cuando un widget implícito sea suficiente.
- Añadir pruebas unitarias de la configuración de movimiento.

### Fase 2 — Navegación principal

- Suavizar el cambio entre Inicio, Movimientos, Estadísticas y Perfil.
- Mantener los cuatro módulos montados y conservar su estado actual.
- Animar discretamente el icono y la selección inferior.
- Impedir interacción con módulos que no estén visibles.
- Validar cambios rápidos y navegación con lector de pantalla.

### Fase 3 — Estados de pantalla

- Unificar transiciones entre carga, contenido, vacío y error.
- Aplicar `AnimatedSwitcher` únicamente en contenedores de estado.
- Evitar parpadeos durante refresh reactivo.
- Mantener intactos reintentos, providers y mensajes actuales.

### Fase 4 — Microinteracciones

- Añadir respuesta táctil sutil a accesos rápidos, tarjetas y acciones
  principales.
- Refinar selección de filtros, pestañas y clasificación necesario/gusto.
- Animar estados de guardado sin cambiar validaciones ni tiempos de red.
- Evitar escalas excesivas o efectos que alteren el layout.

### Fase 5 — Datos financieros y gráficas

- Suavizar cambios visibles en balance, totales y métricas.
- Revisar animaciones de barras y líneas al actualizar datos.
- Mantener precisión, formato monetario y escalas existentes.
- Evitar animar desde cero ante cada rebuild que no cambie los datos.

### Fase 6 — Rutas, modales y paneles

- Estandarizar entradas de pantallas secundarias.
- Refinar apertura y cierre de bottom sheets y diálogos.
- Mantener `SafeArea`, teclado, botones del sistema y resultados de navegación.
- Aplicar el mismo lenguaje de movimiento al panel de notificaciones.

### Fase 7 — Accesibilidad y estabilización

- Respetar la preferencia del sistema para reducir animaciones.
- Probar texto ampliado, pantallas pequeñas y cambios rápidos de módulo.
- Ejecutar análisis, pruebas automatizadas y validación en dispositivo físico.
- Revisar fluidez, reconstrucciones y ausencia de desbordamientos.
- Documentar el resultado y generar una nueva beta solo después de aprobación.

## Orden de prioridad

1. Base y accesibilidad.
2. Navegación principal.
3. Estados de pantalla.
4. Microinteracciones.
5. Métricas y gráficas.
6. Rutas y modales.
7. Estabilización integral.

## Criterios de aceptación

- La navegación se percibe fluida y conserva el estado de cada módulo.
- Las animaciones no modifican resultados financieros ni flujos CRUD.
- No aparecen retrasos perceptibles en acciones frecuentes.
- Los refresh no reinician animaciones innecesariamente.
- Los componentes siguen funcionando en temas claro y oscuro.
- La app reduce el movimiento cuando Android lo solicita.
- No se agregan dependencias sin una necesidad técnica demostrada.
- `flutter analyze` y las pruebas permanecen limpios.

## Estado de ejecución

- Fase 0: auditoría y contrato visual completados.
- Fase 1: base global de duraciones, curvas y movimiento reducido completada.
- Fase 2: navegación principal animada con conservación de estado completada.
- Fase 3: transiciones entre carga, error, vacío y contenido completadas.
- Fase 4: microinteracciones táctiles y estados de guardado completados.
- Fase 5: métricas financieras y gráficas animadas completadas.
- Fase 6: rutas, modales, diálogos y paneles estandarizados.
- Fase 7: accesibilidad y estabilización automatizada completadas.
- La base usa únicamente APIs nativas de Flutter.
- Los módulos inactivos bloquean interacción, foco, semántica y animaciones.
- Los refresh de contenido no reinician la transición visual.
- Las transiciones respetan la preferencia del sistema para reducir movimiento.
- Se cubren cambios rápidos de módulo, texto ampliado y pantallas pequeñas.
- La validación final en dispositivo físico queda sujeta a aprobación manual.
- Pruebas automatizadas: 86 aprobadas.
- Análisis estático: sin diagnósticos.
