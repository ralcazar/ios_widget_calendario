## Tabla de contenidos

| # | Historia | Prioridad | Descripcion |
|---|---|---|---|
| | **Épica 1 — Lectura y visualización** | | |
| 1.1 | Lectura básica de eventos | P0 | Leer eventos del calendario via EventKit |
| 1.2 | Renderizado en distintos tamaños | P0 | Small, Medium, Large, Extra Large (iPad) |
| | **Épica 2 — Permisos y estados** | | |
| 2.1 | Manejo de permisos | P0 | Solicitar acceso desde la app; el widget solo detecta estado |
| 2.2 | Estado sin eventos | P0 | Mensaje cuando la agenda está vacía |
| 2.3 | Modo claro y oscuro | P0 | Adaptación automática a la apariencia del sistema |
| | **Épica 3 — Interacción y personalización** | | |
| 3.1 | Abrir evento | P0 | Pulsar evento abre Calendar.app en la fecha del evento |
| 3.2 | Selección de configuración en el widget | P0 | El widget solo permite elegir qué configuración (creada en la app) usar |
| 3.3 | Widgets interactivos (iOS 17+) | P3 | Descartar eventos desde el widget |
| | **Épica 4 — Filtrado y resaltado** | | |
| 4.1 | Reglas de filtrado | P1 | Filtrar eventos por texto o regex |
| 4.2 | Colores por prioridad de regla | P1 | Color según prioridad de la regla que coincide |
| 4.3 | Vista previa en vivo de reglas | P1 | Probar reglas contra los últimos 50 eventos |
| | **Épica 5 — Optimización y actualizaciones** | | |
| 5.1 | Horario laboral | P3 | Mostrar solo eventos dentro del horario definido |
| 5.2 | Actualización manual | P3 | Forzar refresh desde la app companion |
| 5.3 | Eventos solapados | P2 | Visualizar conflictos de horario |
| 5.4 | Eventos cancelados y rechazados | P0/P2 | Filtrar rechazados por defecto (P0); toggle y cancelados tachados (P2) |
| | **Épica 6 — App companion** | | |
| 6.1 | App companion | P0 | App donde se crea y gestiona toda la configuración de cada widget (calendario, colores, reglas) |
| 6.2 | Onboarding | P2 | Guía inicial y primer widget |

---

## PROBLEMA

Cuando se tienen muchos eventos en un único calendario profesional, no existe una manera de filtrar o destacar eventos en iOS, ni una visualización clara en días con muchas citas.

---

## SOLUCIÓN

Se desarrollará un conjunto de **widgets de iOS** y una **app companion** que permita:

1. Filtrar y resaltar eventos mediante reglas.
2. Optimizar la visualización incluso con muchos eventos.
3. Crear múltiples widgets independientes con sus propias configuraciones.
4. Ofrecer superficies de visualización en Home Screen.

A continuación se da una *especificación* con **historias en formato Behaviour Driven Development (BDD)** usando **Gherkin**, agrupadas por épicas, con dependencias y lista de ítems no representables.

---

## **Épicas**

1. **Lectura y visualización básica de eventos**
2. **Gestión de permisos y estados del widget**
3. **Interacción y personalización básica del widget**
4. **Filtrado y resaltado de eventos mediante reglas**
5. **Optimización de visualización y actualizaciones avanzadas**
6. **App companion y onboarding**

---

## **Decisiones técnicas**

| Decisión | Valor | Justificación |
|---|---|---|
| Deployment target | iOS 17.0+ | Requerido para `AppIntentConfiguration`, widgets interactivos y Swift Regex |
| Plataforma | Universal (iPhone + iPad) | Extra Large disponible en iPad |
| Persistencia compartida | `UserDefaults(suiteName:)` con App Group | SwiftData tiene riesgo de corrupción con acceso concurrente app/widget. UserDefaults es atómico y suficiente para configuraciones pequeñas (JSON codificable) |
| Configuración del widget | `AppIntentConfiguration` + `AppEntity` | API moderna (iOS 17+). El picker del widget consulta las configuraciones del App Group via `EntityQuery` |
| Estrategia de timeline | Una entrada por transición de evento + entrada a medianoche, política `.atEnd` | Permite que el widget refleje cambios de estado (evento empieza, termina) sin consumir reload budget |
| Lectura de eventos | EventKit (solo `EKEventStore`, sin EventKitUI) | EventKitUI no es necesario: solo leemos eventos, no los editamos |
| Navegación al evento | URL scheme `calshow:<unix_timestamp>` | No existe deep link público a un evento concreto en Calendar.app; solo se puede abrir en la fecha |
| Regex engine | Swift `Regex` (tipo nativo, iOS 16+) | Validación en tiempo de edición en la app companion. En el widget extension (30 MB de RAM), solo se ejecutan regex ya compilados sobre el set filtrado de eventos del día |
| Comunicación app → widget | `WidgetCenter.shared.reloadAllTimelines()` al guardar config | El widget se recarga con la nueva configuración. Sujeto a presupuesto diario (~40-70 reloads), pero cambios de configuración son infrecuentes |

---

## **Roadmap**

### Grafo de dependencias

```
                    ┌──────────────────────────────┐
                    │  Fase 0: Infraestructura     │
                    │  Xcode project, App Group,   │
                    │  modelo WidgetConfig,         │
                    │  AppEntity skeleton           │
                    └──────────┬───────────────────┘
                               │
              ┌────────────────┼────────────────┐
              ▼                ▼                ▼
        ┌──────────┐    ┌──────────┐    ┌──────────┐
        │ 6.1 App  │    │ 1.1 Leer │    │ 2.1 Per- │
        │ companion│    │ eventos  │    │ misos    │
        │ (MVP)    │    │          │    │ (en app) │
        └────┬─────┘    └────┬─────┘    └──────────┘
             │               │
             │          ┌────┴─────┐
             │          │ 1.2 Ren- │
             │          │ derizado │
             │          └────┬─────┘
             │               │
             ▼               ▼
        ┌──────────┐    ┌──────────┐    ┌──────────┐
        │ 3.2 Pick-│    │ 3.1 Abrir│    │ 2.2 Sin  │
        │ er config│    │ evento   │    │ eventos  │
        └──────────┘    └──────────┘    └──────────┘
                                              │
             ┌────────────────────────────────┘
             ▼
     ════════════════════════
      MVP usable (Fase 1)
     ════════════════════════
             │
     ┌───────┼───────┐
     ▼       ▼       ▼
  ┌──────┐┌──────┐┌──────┐
  │ 4.1  ││ 4.2  ││ 4.3  │
  │Reglas││Color ││Prevw.│
  └──────┘└──┬───┘└──┬───┘
             │       │
             ▼       ▼
     ════════════════════════
      Motor de reglas (Fase 2)
     ════════════════════════
             │
     ┌───────┼───────┬───────────┐
     ▼       ▼       ▼           ▼
  ┌──────┐┌──────┐┌──────┐ ┌────────┐
  │ 5.4  ││ 5.3  ││ 6.2  │ │ 2.3    │
  │Cancel││Solap.││Onbrd.│ │Clr/Osc │
  │toggle││      ││      │ │custom  │
  └──────┘└──────┘└──────┘ └────────┘
     │
     ▼
     ════════════════════════
      App Store v1 (Fase 3)
     ════════════════════════
             │
     ┌───────┼───────┐
     ▼       ▼       ▼
  ┌──────┐┌──────┐┌──────┐
  │ 3.3  ││ 5.1  ││ 5.2  │
  │Inter.││Horar.││Refr. │
  └──────┘└──────┘└──────┘
             │
             ▼
     ════════════════════════
      Extras (Fase 4)
     ════════════════════════
```

### Fases detalladas

**Fase 0 — Infraestructura** *(sin historias de usuario — prerequisito técnico)*

Crear el proyecto Xcode con dos targets (app + widget extension), configurar App Group compartido, definir el modelo `WidgetConfig` (Codable), y el skeleton de `AppEntity` + `EntityQuery` para el picker del widget. Sin esta base, nada es implementable.

**Fase 1 — MVP vertical** *(primera versión usable end-to-end)*

| Orden | Historia | Justificación del orden |
|---|---|---|
| 1 | 6.1 App companion (versión mínima) | Crea configuraciones que el widget consumirá. Sin app no hay configuraciones. |
| 2 | 2.1 Permisos | La app solicita acceso al calendario; sin esto no hay eventos que leer. |
| 3 | 1.1 Lectura de eventos | EventKit lee el calendario seleccionado en la config. |
| 4 | 1.2 Renderizado (Medium primero) | Mostrar eventos en el widget. Empezar por Medium (el más útil); luego Small, Large, XL. |
| 5 | 3.2 Picker de configuración | El widget expone el picker para elegir qué config usar. |
| 6 | 3.1 Abrir evento (calshow:) | Tap en evento abre Calendar.app. |
| 7 | 2.2 Estado sin eventos | Mensaje cuando no hay eventos — estado edge imprescindible. |
| 8 | 5.4 Cancelados/rechazados (solo filtrado por defecto) | Filtrar eventos rechazados en el predicado de EventKit. Sin esto, el widget muestra ruido desde el día uno. No requiere UI, es una línea en el query. |

> **Resultado**: un usuario puede instalar la app, conceder permisos, crear una configuración, añadir un widget, y ver sus eventos de hoy filtrados (sin rechazados) en la Home Screen.

**Fase 2 — Motor de reglas** *(core del valor de negocio)*

| Orden | Historia | Justificación |
|---|---|---|
| 1 | 4.1 Reglas de filtrado | UI en app companion para crear reglas texto/regex. Funcionalidad diferencial de la app. |
| 2 | 4.2 Colores por prioridad | Depende de 4.1. Completa la propuesta de valor visual. |
| 3 | 4.3 Vista previa en vivo | Depende de 4.1. Permite al usuario ajustar reglas antes de aplicarlas. |

> **Resultado**: la funcionalidad diferencial de la app — filtrar y resaltar eventos por reglas. Con esto, la app ya se diferencia del widget de Calendario nativo. Beta testable via TestFlight.

**Fase 3 — Pulido para App Store**

| Historia | Justificación |
|---|---|
| 2.3 Modo claro/oscuro (colores custom) | El soporte básico es gratis (SwiftUI), pero los colores custom de la config necesitan par claro+oscuro. |
| 5.4 Cancelados/rechazados (toggle + tachado) | La UI en la app companion para el toggle, y el estilo visual de eventos cancelados. |
| 5.3 Eventos solapados | Visualización de conflictos — el core del problema declarado. |
| 6.2 Onboarding | Guía para la primera apertura. Necesaria para App Store review. |

> **Resultado**: app publicable en App Store con experiencia completa.

**Fase 4 — Extras**

| Historia | Justificación |
|---|---|
| 3.3 Widgets interactivos | Descartar eventos desde el widget. |
| 5.1 Horario laboral | Filtro por horario en la config. |
| 5.2 Actualización manual | Botón en app companion. Valor limitado si el timeline está bien diseñado. |

---

## **Historias Gherkin por épica**

### **Épica 1: Lectura y visualización básica de eventos**

**Historia 1.1 – Lectura básica de eventos** *(P0 — Fase 1)*

*Depende de: EventKit, 2.1 (permisos concedidos)*

```gherkin
Feature: Lectura básica de eventos
  Como usuario
  Quiero que el widget lea los eventos de mi calendario
  Para poder ver mis citas directamente en la pantalla de inicio

  Scenario: Widget obtiene eventos del calendario
    Given que he concedido acceso al calendario
    When el widget se actualiza
    Then debe mostrar la lista de eventos del día actual
```

**Historia 1.2 – Renderizado del widget en distintos tamaños** *(P0 — Fase 1)*

*Depende de: 1.1*

```gherkin
Feature: Renderizado de widget
  Como usuario
  Quiero que el widget muestre los eventos en distintos tamaños
  Para tener una vista adecuada según el espacio disponible

  Scenario Outline: Mostrar eventos según tamaño de widget
    Given que el widget tiene eventos cargados
    When coloco un widget de tamaño <tamaño> en la pantalla de inicio
    Then debo ver la lista de eventos adaptada al tamaño <tamaño>

  Examples:
    | tamaño      |
    | Small       |
    | Medium      |
    | Large       |
    | Extra Large |
```

> **Nota técnica**: Extra Large solo está disponible en iPad. Los tamaños determinan cuántos eventos caben: Small ~1-2, Medium ~3-4, Large ~6-8, Extra Large ~10-12.

---

### **Épica 2: Gestión de permisos y estados del widget**

**Historia 2.1 – Manejo de permisos** *(P0 — Fase 1)*

*Depende de: EventKit, 6.1 (app companion)*

```gherkin
Feature: Manejo de permisos
  Como usuario
  Quiero que el widget solicite acceso al calendario cuando sea necesario
  Para que pueda mostrar mis eventos correctamente

  Scenario: Solicitud inicial de permisos
    Given que nunca he concedido acceso al calendario
    When abro la app companion por primera vez
    Then la app solicita permiso de acceso al calendario

  Scenario: Widget sin permisos concedidos
    Given que no he concedido acceso al calendario
    When el widget intenta actualizarse
    Then debo ver un mensaje indicando que abra la app para conceder permisos

  Scenario: Permisos denegados
    Given que he denegado el acceso al calendario
    When el widget intenta actualizarse
    Then debo ver un mensaje indicando que no hay permisos
    And un enlace a Ajustes para modificarlos
```

> **Nota técnica**: Las widget extensions **no pueden mostrar el diálogo de permisos del sistema** (`EKEventStore.requestAccess`). Solo el proceso de la app companion puede solicitarlos. El widget solo puede consultar `EKEventStore.authorizationStatus(for:)` y mostrar un estado informativo.

**Historia 2.2 – Estado sin eventos** *(P0 — Fase 1)*

*Depende de: 1.2*

```gherkin
Feature: Estado sin eventos
  Como usuario
  Quiero que el widget muestre un mensaje claro cuando no haya eventos
  Para saber que mi agenda está vacía

  Scenario: Día sin eventos
    Given que el calendario está vacío para hoy
    When el widget se actualiza
    Then debo ver un mensaje indicando que no hay eventos
```

**Historia 2.3 – Adaptación a modo claro y oscuro** *(P0/P2 — Fase 1 base, Fase 3 colores custom)*

*Depende de: 1.2*

```gherkin
Feature: Modo claro y oscuro
  Como usuario
  Quiero que el widget se adapte automáticamente al modo de apariencia del sistema
  Para que sea legible en cualquier configuración

  Scenario: Widget en modo oscuro
    Given que el sistema está en modo oscuro
    When el widget se renderiza
    Then los colores de fondo, texto y acentos deben usar la paleta de modo oscuro

  Scenario: Widget en modo claro
    Given que el sistema está en modo claro
    When el widget se renderiza
    Then los colores de fondo, texto y acentos deben usar la paleta de modo claro
```

> **Nota técnica**: SwiftUI en WidgetKit maneja el cambio claro/oscuro automáticamente via `@Environment(\.colorScheme)` — no requiere lógica de actualización explícita. El soporte básico (colores semánticos del sistema) es gratis y entra en Fase 1. La gestión de colores custom (par claro+oscuro por configuración) entra en Fase 3 junto con la UI de personalización en la app companion.

---

### **Épica 3: Interacción y personalización básica del widget**

**Historia 3.1 – Interacción básica: abrir evento** *(P0 — Fase 1)*

*Depende de: 1.2*

```gherkin
Feature: Apertura de evento desde el widget
  Como usuario
  Quiero poder pulsar un evento en el widget
  Para abrirlo directamente en la app de Calendario

  Scenario: Pulsar evento
    Given que el widget muestra un evento
    When pulso sobre el evento
    Then se abre Calendar.app en la fecha del evento
```

> **Nota técnica**: No existe URL scheme pública para abrir un evento específico en Calendar.app. `calshow:<unix_timestamp>` abre Calendar.app en la fecha indicada, que es lo máximo posible. Cada evento en el widget usa un `Link` con URL `calshow:<timestamp_del_evento>`. En widget Small, que solo soporta un `widgetURL` global, se usa el timestamp del próximo evento.

**Historia 3.2 – Selección de configuración en el widget** *(P0 — Fase 1)*

*Depende de: 6.1 (app companion)*

```gherkin
Feature: Selección de configuración en el widget
  Como usuario
  Quiero elegir qué configuración (creada en la app) usa cada widget
  Para poder tener múltiples widgets con vistas diferentes

  Scenario: Seleccionar configuración al añadir widget
    Given que he creado al menos una configuración en la app companion
    When añado un widget y accedo a su configuración
    Then debo ver un picker con las configuraciones disponibles
    And al seleccionar una, el widget muestra los eventos según esa configuración

  Scenario: Widget sin configuración seleccionada
    Given que he añadido un widget
    And no he seleccionado ninguna configuración
    Then el widget debe mostrar un mensaje invitando a seleccionar una configuración

  Scenario: Configuración actualizada desde la app
    Given que un widget usa la configuración "Trabajo"
    When edito "Trabajo" en la app companion
    Then el widget se actualiza reflejando los cambios en la próxima actualización
```

> **Nota técnica**: Implementado con `AppIntentConfiguration`. Las configuraciones se modelan como `AppEntity` con un `EntityQuery` que lee del App Group (`UserDefaults(suiteName:)`). Cuando la app guarda un cambio, llama a `WidgetCenter.shared.reloadAllTimelines()` para que el widget recoja la configuración actualizada. El `EntityQuery` se ejecuta en el proceso del widget, no en el de la app.

**Historia 3.3 – Widgets interactivos (iOS 17+)** *(P3 — Fase 4)*

*Depende de: 1.2*

```gherkin
Feature: Widgets interactivos
  Como usuario
  Quiero poder descartar eventos irrelevantes directamente desde el widget
  Para limpiar mi vista sin abrir la app

  Scenario: Descartar evento del widget
    Given que el widget muestra un evento irrelevante
    When pulso el botón de descartar
    Then el evento desaparece del widget hasta el día siguiente
```

> **Nota técnica**: Los widgets interactivos (iOS 17+) solo admiten `Button` y `Toggle`. El estado de "descartado" se almacena en App Group (set de `eventIdentifier` + fecha) y se limpia diariamente. No se sincroniza con Calendar — es estado local de la app.

---

### **Épica 4: Filtrado y resaltado de eventos mediante reglas**

**Historia 4.1 – Creación de reglas de filtrado** *(P1 — Fase 2)*

*Depende de: 6.1 (app companion para UI de reglas), 1.1 (eventos que filtrar)*

```gherkin
Feature: Reglas de filtrado
  Como usuario
  Quiero crear reglas basadas en texto o regex
  Para mostrar solo los eventos relevantes

  Scenario: Filtrar eventos por texto
    Given que el widget muestra eventos
    When creo una regla de filtrado con la palabra "Reunión"
    Then solo deben mostrarse los eventos que contengan "Reunión"
```

> **Nota técnica**: La validación del regex se hace en la app companion en tiempo de edición (feedback inmediato si el patrón es inválido). En el widget extension, los regex ya compilados se aplican sobre los eventos del día. La widget extension tiene un **límite de 30 MB de RAM** — con un calendario denso (~50-100 eventos/día) y regex simples, esto no es problema, pero regex con backtracking excesivo podrían causar un crash. Mitigación: usar `Swift Regex` con timeout implícito y limitar la complejidad del patrón en la UI de la app.

**Historia 4.2 – Aplicar colores según prioridad de regla** *(P1 — Fase 2)*

*Depende de: 4.1*

```gherkin
Feature: Colores por prioridad de regla
  Como usuario
  Quiero que los eventos filtrados por reglas tengan colores según prioridad
  Para identificarlos visualmente de un vistazo

  Scenario: Evento resaltado por regla
    Given que existe una regla de alta prioridad para "Reunión"
    When el widget muestra un evento que coincide
    Then el evento debe aparecer con el color asignado a la prioridad
```

**Historia 4.3 – Vista previa en vivo de reglas** *(P1 — Fase 2)*

*Depende de: 4.1, 6.1 (app companion para la pantalla de vista previa)*

```gherkin
Feature: Vista previa en vivo de reglas
  Como usuario
  Quiero ver cómo se aplican las reglas sobre los últimos 50 eventos
  Para ajustar los filtros antes de aplicarlos al widget

  Scenario: Vista previa de reglas activas
    Given que he creado varias reglas
    When abro la vista previa
    Then debo ver los últimos 50 eventos filtrados y coloreados según las reglas
```

> **Nota técnica**: La vista previa se ejecuta en la app companion (sin restricción de 30 MB). `EKEventStore.events(matching:)` con un predicado de rango de fechas devuelve los eventos. Hay que calcular cuántos días hacia atrás consultar para obtener ~50 eventos — depende de la densidad del calendario del usuario.

---

### **Épica 5: Optimización de visualización y actualizaciones avanzadas**

**Historia 5.1 – Configuración de horario laboral** *(P3 — Fase 4)*

*Depende de: 6.1 (app companion para UI de horario)*

```gherkin
Feature: Horario laboral en widget
  Como usuario
  Quiero definir mi horario laboral
  Para optimizar la visualización de eventos y evitar saturación

  Scenario: Mostrar solo eventos en horario laboral
    Given que he definido mi horario laboral de 9:00 a 18:00
    When el widget se actualiza
    Then solo deben mostrarse eventos dentro de ese horario
```

**Historia 5.2 – Actualización manual del widget** *(P3 — Fase 4)*

*Depende de: 6.1 (app companion para el botón)*

```gherkin
Feature: Actualización manual del widget
  Como usuario
  Quiero poder forzar una actualización del widget
  Para ver cambios recientes sin esperar la actualización automática

  Scenario: Usuario actualiza manualmente el widget
    Given que el widget está mostrando eventos
    When pulso "Actualizar widgets" en la app companion
    Then los widgets se actualizan con los datos más recientes
```

> **Nota técnica**: La actualización se dispara desde la app companion via `WidgetCenter.shared.reloadAllTimelines()`, no desde un botón en el widget. El sistema impone un **presupuesto diario de ~40-70 reloads**; si se agota, el sistema ignora las solicitudes silenciosamente. Con la estrategia de timeline basada en transiciones de eventos, la necesidad de reloads manuales debería ser mínima.

**Historia 5.3 – Visualización de eventos solapados** *(P2 — Fase 3)*

*Depende de: 1.2*

```gherkin
Feature: Eventos solapados
  Como usuario
  Quiero ver claramente cuando tengo eventos que se solapan en el tiempo
  Para ser consciente de conflictos en mi agenda

  Scenario: Dos eventos a la misma hora
    Given que hay dos eventos programados a las 10:00
    When el widget se actualiza
    Then ambos eventos deben ser visibles
    And debe haber un indicador visual de solapamiento (ej: badge con "2 eventos")

  Scenario: Evento parcialmente solapado
    Given que un evento va de 10:00 a 11:00 y otro de 10:30 a 11:30
    When el widget se actualiza
    Then ambos eventos deben mostrarse
    And el solapamiento debe ser visualmente evidente

  Scenario: Muchos eventos a la misma hora en widget Small
    Given que hay 4 eventos a las 10:00
    And el widget es de tamaño Small
    When el widget se actualiza
    Then debe mostrarse un resumen (ej: "10:00 — 4 eventos")
    And al pulsar se abre la app con el detalle
```

> **Nota técnica**: La detección de solapamiento es un algoritmo de intervalos (ordenar por start, comparar con end del anterior). La dificultad está en la **visualización en espacio limitado**: en Medium/Large se pueden mostrar eventos apilados con indentación; en Small solo cabe un resumen colapsado. El widget no puede hacer scroll, así que el layout debe decidir estáticamente cuántos eventos mostrar y cuándo colapsar.

**Historia 5.4 – Eventos cancelados y rechazados** *(P0 filtrado / P2 toggle+UI — Fase 1 + Fase 3)*

*Depende de: 1.1; para toggle y UI: 6.1 (app companion)*

```gherkin
Feature: Eventos cancelados y rechazados
  Como usuario
  Quiero controlar si veo los eventos que he rechazado o que se han cancelado
  Para no tener ruido innecesario en mi widget

  Scenario: Ocultar eventos rechazados por defecto
    Given que he rechazado una invitación a un evento
    When el widget se actualiza
    Then el evento rechazado no debe aparecer en la lista

  Scenario: Evento cancelado se muestra tachado (si está habilitado)
    Given que el organizador ha cancelado un evento
    And la opción "Mostrar cancelados" está activada
    When el widget se actualiza
    Then el evento debe mostrarse con estilo tachado y opacidad reducida

  Scenario: Ocultar eventos cancelados
    Given que el organizador ha cancelado un evento
    And la opción "Mostrar cancelados" está desactivada
    When el widget se actualiza
    Then el evento cancelado no debe aparecer en la lista
```

> **Nota técnica**: El primer escenario (filtrar rechazados por defecto) es una línea en el predicado de EventKit y entra en Fase 1 sin necesidad de UI. Los escenarios de cancelados (toggle + estilo tachado) requieren UI en la app companion y entran en Fase 3.
>
> EventKit expone `EKParticipant.participantStatus` (`.declined`, `.accepted`, etc.) y `EKEvent.status` (`.canceled`). Para eventos rechazados, se filtra por `participantStatus == .declined` del participante que corresponde al usuario actual (`EKEventStore.sources`). Esto funciona para calendarios con soporte de invitaciones (Exchange, Google via CalDAV); en calendarios locales sin invitaciones, estos campos no aplican.

---

### **Épica 6: App companion y onboarding**

**Historia 6.1 – App companion para configuración** *(P0 — Fase 1)*

*Depende de: App Groups para compartir datos entre app y widget*

```gherkin
Feature: App companion
  Como usuario
  Quiero una app donde pueda crear y gestionar configuraciones de widgets
  Para definir calendario, apariencia, reglas y opciones de cada widget desde un solo lugar

  Scenario: Ver lista de configuraciones
    Given que he abierto la app
    Then debo ver la lista de configuraciones creadas
    Or un estado vacío invitándome a crear la primera

  Scenario: Crear nueva configuración
    Given que estoy en la app companion
    When creo una nueva configuración
    Then puedo definir nombre, calendario, color principal, fondo, reglas de filtrado y opciones de visualización
    And la configuración queda disponible para seleccionar desde cualquier widget

  Scenario: Editar configuración existente
    Given que tengo una configuración creada
    When la edito desde la app
    Then los cambios se reflejan en todos los widgets que usen esa configuración

  Scenario: Eliminar configuración
    Given que tengo una configuración que ya no uso
    When la elimino desde la app
    Then los widgets que la usaban muestran un mensaje invitando a seleccionar otra
```

**Historia 6.2 – Onboarding** *(P2 — Fase 3)*

*Depende de: 6.1, 2.1*

```gherkin
Feature: Onboarding
  Como usuario nuevo
  Quiero una guía inicial que me oriente
  Para configurar mi primer widget rápidamente

  Scenario: Primera apertura de la app
    Given que es la primera vez que abro la app
    When se completa la carga inicial
    Then debo ver un flujo guiado que me pida permisos de calendario
    And me muestre cómo añadir mi primer widget

  Scenario: Completar onboarding
    Given que estoy en el flujo de onboarding
    When concedo permisos y configuro mi primer widget
    Then debo ver la pantalla principal con mi configuración creada
    And unas instrucciones para agregar el widget a la pantalla de inicio
```

---

## **Casos de uso del usuario cubiertos**

| Caso de uso | Historias |
|---|---|
| Ver rápidamente qué reuniones tengo hoy | 1.1, 1.2 |
| Saber que no tengo más reuniones hoy | 2.2 |
| Identificar rápidamente conflictos de horario | 5.3 |
| Filtrar solo reuniones de un tipo (1:1, standup, etc.) | 4.1 |
| Ignorar eventos cancelados o rechazados | 5.4 |
| Configurar widgets sin complicaciones | 6.1, 6.2 |

---

## **Ítems no representables en Gherkin**

1. **Restricciones de plataforma**
    - **Deployment target**: iOS 17.0+. Requerido para `AppIntentConfiguration`, widgets interactivos y `Swift Regex`.
    - **Widget extension**: límite de 30 MB de RAM. Afecta la complejidad de regex y la cantidad de eventos procesables en un solo ciclo.
    - **Presupuesto de reloads**: WidgetKit limita a ~40-70 `reloadAllTimelines()` por día. El timeline basado en transiciones de eventos minimiza la necesidad de reloads explícitos.
    - **Widgets interactivos (iOS 17+)**: solo admiten `Button` y `Toggle`; no permiten navegación, text input ni gestos complejos.
    - **Widget Small**: solo admite un `widgetURL` global (no `Link` individuales por evento).
    - **Extra Large**: solo disponible en iPad.
2. **Arquitectura y dependencias técnicas**
    - **App Groups**: obligatorio para compartir datos entre la app companion y la widget extension. Contenedor compartido via `UserDefaults(suiteName:)`.
    - **AppIntentConfiguration + AppEntity**: el widget expone un picker de configuraciones. El `EntityQuery` lee del App Group y se ejecuta en el proceso del widget.
    - **EventKit** (`EKEventStore`): lectura de calendarios y eventos. No se usa EventKitUI.
    - **SwiftUI + WidgetKit**: framework de renderizado.
    - **UserDefaults (App Group suite)**: persistencia de configuraciones y reglas. Se descarta SwiftData por riesgo de corrupción con acceso concurrente app/widget.
    - **`calshow:` URL scheme**: navegación a Calendar.app por fecha (no por evento). No documentada oficialmente por Apple pero ampliamente usada y estable.
    - **Sin dependencias de terceros**: todo el stack es frameworks de Apple.
3. **Estrategia de timeline**
    - El `TimelineProvider` genera una entrada por cada transición relevante del día: inicio de evento, fin de evento, y una entrada a medianoche.
    - Política de reload: `.atEnd` (el sistema recarga al agotar las entradas).
    - Esto permite que el widget refleje "evento en curso" vs "entre eventos" sin consumir reload budget.
4. **Modelo de datos compartido**
    - Una configuración se serializa como `Codable` en `UserDefaults`:
      ```
      WidgetConfig {
        id: UUID
        name: String
        calendarIdentifier: String
        colorSchemeLight: ColorPair  // acento + fondo
        colorSchemeDark: ColorPair
        rules: [FilterRule]          // P2
        showCancelled: Bool
        workingHours: DateInterval?  // P3
      }
      ```
    - El widget lee el array `[WidgetConfig]` del App Group y filtra por el `id` seleccionado en el `AppIntent`.
5. **Requisitos de App Store**
    - La app companion debe tener funcionalidad mínima propia (no puede ser solo un lanzador de widget).
    - Política de privacidad requerida (acceso a datos de calendario).
    - Descripción de uso de calendario requerida en `Info.plist` (`NSCalendarsUsageDescription`).
