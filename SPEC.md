## PROBLEMA

Cuando se tienen muchos eventos en un único calendario profesional, no existe una manera de filtrar o destacar eventos en iOS, ni una visualización clara en días con muchas citas.

---

## SOLUCIÓN

Se desarrollará un conjunto de **widgets de iOS** que permita:

1. Filtrar y resaltar eventos mediante reglas.
2. Optimizar la visualización incluso con muchos eventos.
3. Crear múltiples widgets independientes con sus propias configuraciones.

A continuación se da una *especificación** con **historias en formato Behaviour Driven Development (BDD)** usando **Gherkin**, agrupadas por épicas, con dependencias y lista de ítems no 
representables.


---

## **Épicas**

1. **Lectura y visualización básica de eventos**
2. **Gestión de permisos y estados del widget**
3. **Interacción y personalización básica del widget**
4. **Filtrado y resaltado de eventos mediante reglas**
5. **Optimización de visualización y actualizaciones avanzadas**

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
  Quiero que el widget muestre los eventos en distintos tamaños (S, M, L)
  Para tener una vista adecuada según el espacio disponible

  Scenario Outline: Mostrar eventos según tamaño de widget
    Given que el widget tiene eventos cargados
    When coloco un widget de tamaño <tamaño>
    Then debo ver la lista de eventos adaptada al tamaño <tamaño>

  Examples:
    | tamaño |
    | S      |
    | M      |
    | L      |
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

**Historia 3.2 – Selección de calendario por widget** *(P1)*

*Depende de: Widgets funcionales*

```gherkin
Feature: Selección de calendario
  Como usuario
  Quiero elegir qué calendario muestra cada widget
  Para poder tener widgets con vistas diferentes

  Scenario: Configurar calendario del widget
    Given que he añadido el widget a la pantalla
    When accedo a su configuración y selecciono un calendario
    Then el widget debe mostrar solo los eventos de ese calendario
```

**Historia 3.3 – Personalización simple** *(P1)*

```gherkin
Feature: Personalización visual básica
  Como usuario
  Quiero personalizar el color principal y el fondo del widget
  Para que se adapte a mi estilo visual

  Scenario: Cambiar color y fondo
    Given que el widget está configurado
    When cambio el color principal y el fondo en la configuración
    Then el widget se actualiza con la nueva apariencia
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

---

## **Ítems no representables en Gherkin**

1. **Riesgos técnicos**
    - Limitaciones de WidgetKit para actualización manual
    - Posibles problemas de rendimiento con regex
2. **Camino crítico del MVP**
    - Es un documento de planificación, no un comportamiento observable.
3. **Dependencias técnicas**
    - Uso de EventKit, App Groups o SwiftUI no se expresan como escenarios de comportamiento.
