## Tabla de contenidos

| # | Historia | Prioridad | Descripcion |
|---|---|---|---|
| | **Épica 1 — Lectura y visualización** | | |
| 1.1 | Lectura básica de eventos | P0 | Leer eventos del calendario via EventKit |
| 1.2 | Renderizado en distintos tamaños | P0 | Small, Medium, Large, Extra Large |
| | **Épica 2 — Permisos y estados** | | |
| 2.1 | Manejo de permisos | P0 | Solicitar y gestionar acceso al calendario |
| 2.2 | Estado sin eventos | P0 | Mensaje cuando la agenda está vacía |
| 2.3 | Modo claro y oscuro | P0 | Adaptación automática a la apariencia del sistema |
| | **Épica 3 — Interacción y personalización** | | |
| 3.1 | Abrir evento | P0 | Pulsar evento abre la app Calendario |
| 3.2 | Selección de configuración en el widget | P0 | El widget solo permite elegir qué configuración (creada en la app) usar |
| 3.4 | Widgets interactivos (iOS 17+) | P3 | Acciones rápidas desde el widget |
| | **Épica 4 — Filtrado y resaltado** | | |
| 4.1 | Reglas de filtrado | P2 | Filtrar eventos por texto o regex |
| 4.2 | Colores por prioridad de regla | P2 | Color según prioridad de la regla que coincide |
| 4.3 | Vista previa en vivo de reglas | P2 | Probar reglas contra los últimos 50 eventos |
| | **Épica 5 — Optimización y actualizaciones** | | |
| 5.1 | Horario laboral | P3 | Mostrar solo eventos dentro del horario definido |
| 5.2 | Actualización manual | P3 | Forzar refresh del widget |
| 5.3 | Eventos solapados | P1 | Visualizar conflictos de horario |
| 5.4 | Eventos cancelados y rechazados | P1 | Ocultar o mostrar tachados |
| | **Épica 6 — App companion** | | |
| 6.1 | App companion | P0 | App donde se crea y gestiona toda la configuración de cada widget (calendario, colores, reglas) |
| 6.2 | Onboarding | P1 | Guía inicial y primer widget |

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

## **Historias Gherkin por épica**

### **Épica 1: Lectura y visualización básica de eventos**

**Historia 1.1 – Lectura básica de eventos** *(P0)*

*Depende de: EventKit*

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

**Historia 1.2 – Renderizado del widget en distintos tamaños** *(P0)*

*Depende de: Lectura básica de eventos*

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

---

### **Épica 2: Gestión de permisos y estados del widget**

**Historia 2.1 – Manejo de permisos** *(P0)*

*Depende de: EventKit*

```gherkin
Feature: Manejo de permisos
  Como usuario
  Quiero que el widget solicite acceso al calendario cuando sea necesario
  Para que pueda mostrar mis eventos correctamente

  Scenario: Solicitud inicial de permisos
    Given que nunca he concedido acceso al calendario
    When agrego el widget
    Then debo ver un mensaje solicitando permisos

  Scenario: Mostrar mensaje de error en caso de denegación
    Given que he denegado el acceso al calendario
    When el widget intenta actualizarse
    Then debo ver un mensaje indicando que no hay permisos
```

**Historia 2.2 – Estado sin eventos** *(P0)*

*Depende de: Renderizado del widget*

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

**Historia 2.3 – Adaptación a modo claro y oscuro** *(P0)*

*Depende de: Renderizado del widget*

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

  Scenario: Cambio dinámico de apariencia
    Given que el widget está visible
    When el sistema cambia de modo claro a oscuro (o viceversa)
    Then el widget debe actualizarse reflejando el nuevo modo
```

---

### **Épica 3: Interacción y personalización básica del widget**

**Historia 3.1 – Interacción básica: abrir evento** *(P0)*

*Depende de: Renderizado del widget*

```gherkin
Feature: Apertura de evento desde el widget
  Como usuario
  Quiero poder pulsar un evento en el widget
  Para abrirlo directamente en la app de Calendario

  Scenario: Pulsar evento
    Given que el widget muestra un evento
    When pulso sobre el evento
    Then se abre la ficha del evento en la app Calendario
```

**Historia 3.2 – Selección de configuración en el widget** *(P0)*

*Depende de: App companion (6.1)*

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

**Historia 3.4 – Widgets interactivos (iOS 17+)** *(P3)*

*Depende de: Renderizado del widget*

```gherkin
Feature: Widgets interactivos
  Como usuario
  Quiero poder realizar acciones rápidas directamente desde el widget
  Para gestionar mi agenda sin abrir la app

  Scenario: Marcar evento como completado
    Given que el widget muestra un evento que ya ha pasado
    When pulso el botón de completar en el widget
    Then el evento se marca visualmente como completado

  Scenario: Descartar evento del widget
    Given que el widget muestra un evento irrelevante
    When pulso el botón de descartar
    Then el evento desaparece del widget hasta la próxima actualización
```

---

### **Épica 4: Filtrado y resaltado de eventos mediante reglas**

**Historia 4.1 – Creación de reglas de filtrado** *(P2)*

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

**Historia 4.2 – Aplicar colores según prioridad de regla** *(P2)*

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

**Historia 4.3 – Vista previa en vivo de reglas** *(P2)*

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

---

### **Épica 5: Optimización de visualización y actualizaciones avanzadas**

**Historia 5.1 – Configuración de horario laboral** *(P3)*

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

**Historia 5.2 – Actualización manual del widget** *(P3)*

```gherkin
Feature: Actualización manual del widget
  Como usuario
  Quiero poder forzar una actualización del widget
  Para ver cambios recientes sin esperar la actualización automática

  Scenario: Usuario actualiza manualmente el widget
    Given que el widget está mostrando eventos
    When toco el botón de actualizar
    Then el widget se actualiza respetando las limitaciones de WidgetKit
```

**Historia 5.3 – Visualización de eventos solapados** *(P1)*

*Depende de: Renderizado del widget*

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

**Historia 5.4 – Eventos cancelados y rechazados** *(P1)*

*Depende de: Lectura básica de eventos*

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

---

### **Épica 6: App companion y onboarding**

**Historia 6.1 – App companion para configuración** *(P0)*

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

**Historia 6.2 – Onboarding** *(P1)*

*Depende de: App companion, Manejo de permisos*

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

1. **Riesgos técnicos**
    - Limitaciones de WidgetKit para actualización manual (presupuesto de reloads limitado por el sistema).
    - Posibles problemas de rendimiento con regex sobre muchos eventos.
    - Los widgets interactivos (iOS 17+) solo admiten `Button` y `Toggle`; no permiten navegación ni inputs complejos.
    - EventKit puede devolver eventos de calendarios suscritos (CalDAV, Exchange) con latencia variable.
2. **Arquitectura y dependencias técnicas**
    - **App Groups**: obligatorio para compartir datos (configuraciones, caché de eventos) entre la app companion y la widget extension.
    - **App Intents / WidgetConfigurationIntent**: necesario para exponer las opciones de configuración en el selector de widgets del sistema.
    - **EventKit + EventKitUI**: lectura de calendarios y eventos.
    - **SwiftUI + WidgetKit**: framework de renderizado.
    - **SwiftData / UserDefaults (suite)**: persistencia de configuraciones y reglas en App Group.
3. **Camino crítico del MVP**
    - Es un documento de planificación, no un comportamiento observable. El orden sugerido es:
      1. P0: Épicas 1 (1.1, 1.2), 2 (2.1, 2.2, 2.3), 3 (3.1, 3.2) y 6 (6.1).
      2. P1: Épicas 5 (5.3, 5.4) y 6 (6.2).
      3. P2: Épica 4.
      4. P3: Historias 3.4, 5.1, 5.2.
4. **Requisitos de App Store**
    - La app companion debe tener funcionalidad mínima propia (no puede ser solo un lanzador de widget).
    - Política de privacidad requerida si se acceden datos de calendario.
