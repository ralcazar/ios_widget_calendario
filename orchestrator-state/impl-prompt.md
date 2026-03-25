# BDD Implementer Agent

You are implementing a BDD scenario for this iOS widget/calendar project. Project rules, coding standards, and build commands are in CLAUDE.md. Beads workflow context is auto-injected via `bd prime`.

## Your Bead

- **ID**: CAL-evk.1
- **Title**: Motor de reglas: modelo, filtrado y persistencia
- **Scenario**:

Implementar el modelo FilterRule y el motor de filtrado aplicado en el widget extension antes de renderizar eventos.

## FilterRule ya está definido en Shared/Models.swift (CAL-sue.3):
```swift
struct FilterRule: Codable, Identifiable, Equatable {
    let id: UUID
    var pattern: String    // subcadena literal o regex
    var isRegex: Bool
    var colorHex: String   // hex para resaltado visual, e.g. '#FF3B30'
    var priority: Int      // 0 = mayor prioridad
    var isEnabled: Bool
}
```
WidgetConfig.rules ya incluye [FilterRule] (vacío en Fase 1, poblado aquí).

## Motor de filtrado: RuleEngine.swift (target: widget + app)

```swift
struct RuleEngine {
    /// Filtra y anota eventos según las reglas activas de la configuración.
    /// Si no hay reglas habilitadas, devuelve todos los eventos sin anotar.
    static func apply(rules: [FilterRule], to events: [EKEvent]) -> [(event: EKEvent, matchedColor: String?)] {
        let activeRules = rules.filter(\.isEnabled).sorted { $0.priority < $1.priority }
        guard !activeRules.isEmpty else {
            return events.map { ($0, nil) }
        }
        return events.compactMap { event in
            guard let title = event.title else { return nil }
            if let matched = activeRules.first(where: { rule in matches(rule: rule, title: title) }) {
                return (event, matched.colorHex)
            }
            return nil  // evento no coincide con ninguna regla → se oculta
        }
    }

    private static func matches(rule: FilterRule, title: String) -> Bool {
        if rule.isRegex {
            // Limitar complejidad: rechazar patrones con más de 100 caracteres o con backtracking catastrófico conocido
            guard rule.pattern.count <= 100 else { return false }
            guard let regex = try? Regex(rule.pattern) else { return false }
            return title.contains(regex)
        } else {
            return title.localizedCaseInsensitiveContains(rule.pattern)
        }
    }
}
```

## Integración en el TimelineProvider (CalendarioWidget)
En getTimeline, después de fetchEvents y antes de construir las entries:
```swift
let annotatedEvents = RuleEngine.apply(rules: config.rules, to: rawEvents)
// Pasar annotatedEvents a CalendarEntry en lugar de rawEvents
```
Actualizar CalendarEntry:
```swift
struct CalendarEntry: TimelineEntry {
    let date: Date
    let events: [(event: EKEvent, matchedColor: String?)]
    let configuration: WidgetConfig
}
```

## Criterios de aceptación (BDD Scenarios)

```gherkin
Feature: Motor de reglas de filtrado

  Scenario: Sin reglas se muestran todos los eventos
    Given que WidgetConfig.rules está vacío
    When se llama a RuleEngine.apply(rules: [], to: events)
    Then se devuelven todos los eventos con matchedColor = nil

  Scenario: Regla literal filtra por subcadena
    Given una regla literal con pattern "trabajo" habilitada
    And eventos con títulos ["Reunión de trabajo", "Cumpleaños", "Trabajo remoto"]
    When se aplica RuleEngine
    Then solo se devuelven los eventos que contienen "trabajo" (case-insensitive)
    And matchedColor es el colorHex de la regla

  Scenario: Regex inválido no crashea
    Given una regla con isRegex=true y pattern "[invalid" habilitada
    When se aplica RuleEngine a cualquier evento
    Then la regla no coincide con nada (no exception)

  Scenario: Regex demasiado largo no se evalúa
    Given una regla con isRegex=true y pattern de 101 caracteres
    When se aplica RuleEngine
    Then la regla no coincide con nada

  Scenario: Prioridad determina el orden de evaluación
    Given dos reglas: prioridad 0 con color "#FF0000" y prioridad 1 con color "#00FF00"
    And un evento cuyo título coincide con ambas
    When se aplica RuleEngine
    Then el matchedColor es "#FF0000" (prioridad mayor = número menor)
```

## Steps

### 0. Claim
```bash
bd update CAL-evk.1 --claim
```

### 1. Parse the Scenario
Extract the Given/When/Then/And structure:
- **Given** = what state must exist (test setup)
- **When** = what action triggers the behavior
- **Then** = what must be true after (assertions)
- **And** = additional assertions

### 2. Read Existing Code
Before writing anything, read relevant existing files to understand what exists, where to add code, and what patterns to follow.

Key files to read:
- Calendario/Shared/Models.swift (FilterRule, WidgetConfig already defined)
- Calendario/CalendarioWidget/EventFetcher.swift (fetchEvents)
- Calendario/CalendarioWidget/CalendarioWidgetBundle.swift or main widget file (TimelineProvider, CalendarEntry)
- Calendario/CalendarioWidget/WidgetViews/ (view files to see how events are rendered)
- CalendarioTests/ (existing test structure)

### 3. Implement
Write the minimum code to make the scenario true.
- Follow existing patterns (Swift, SwiftUI, WidgetKit, EventKit)
- Do NOT refactor unrelated code
- Do NOT add features beyond the scenario

Implementation plan:
1. Create `Calendario/Shared/RuleEngine.swift` with the RuleEngine struct as specified above
2. Update `CalendarEntry` to use `[(event: EKEvent, matchedColor: String?)]` instead of `[EKEvent]`
3. Integrate `RuleEngine.apply` in TimelineProvider's `getTimeline`
4. Update view files that consume `entry.events` to handle the tuple type

### 4. Write Tests
One XCTest per Then/And clause, mirroring the scenario. Create `CalendarioTests/CALevk1ScenarioTests.swift`.

Test naming: `test_CALevk1_given_<setup>_when_<action>_then_<outcome>()`

- Use mocks/stubs for EventKit (EKEvent with mock store)
- Test each BDD scenario above

### 5. Run Tests
```bash
xcodebuild test -project Calendario/Calendario.xcodeproj -scheme CalendarioTests \
  -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -20
```
Fix and re-run if needed (max 3 attempts). ALL tests must pass — no regressions.

### 6. Commit
```bash
git add <specific files>
git commit -m "$(cat <<'EOF'
impl(CAL-evk.1): Motor de reglas: modelo, filtrado y persistencia

Scenario: RuleEngine filters events by rules with priority ordering
Tests: N passed

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"
```

Do NOT push. The verifier pushes after approval.

### 7. Write Result
Write to `orchestrator-state/results/CAL-evk.1.json`:

```json
{
  "bead_id": "CAL-evk.1",
  "status": "success|failed",
  "files_created": [],
  "files_modified": [],
  "tests_added": [],
  "tests_passed": 0,
  "tests_failed": 0,
  "commit_hash": "",
  "error": null
}
```

## If You Cannot Implement

1. Write result with `"status": "failed"` and `"error": "<explanation>"`
2. Clean up: `git checkout .`
3. `bd update CAL-evk.1 --notes="Impl failed: <error>"`
4. Exit
