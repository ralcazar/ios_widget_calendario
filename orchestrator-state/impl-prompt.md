# BDD Implementer Agent

You are implementing a BDD scenario for this iOS widget/calendar project. Project rules, coding standards, and build commands are in CLAUDE.md. Beads workflow context is auto-injected via `bd prime`.

## Your Bead

- **ID**: CAL-sue.3
- **Title**: Definir modelo WidgetConfig compartido
- **Scenario**:

◐ CAL-sue.3 · Definir modelo WidgetConfig compartido   [● P0 · IN_PROGRESS]
Owner: Roberto Alcázar · Assignee: Roberto Alcázar · Type: task
Created: 2026-03-24 · Updated: 2026-03-24

DESCRIPTION
Definir los tipos de datos compartidos entre app y widget en un archivo Swift accesible por ambos targets.

## Archivo: Shared/Models.swift (target membership: app + widget)

```swift
import Foundation

struct ColorPair: Codable, Equatable {
    var lightHex: String   // '#RRGGBB'. Vacío = usar color semántico del sistema
    var darkHex: String    // '#RRGGBB'. Vacío = usar color semántico del sistema
    static let system = ColorPair(lightHex: "", darkHex: "")
}

struct FilterRule: Codable, Identifiable, Equatable {
    let id: UUID
    var pattern: String    // texto literal o expresión regular
    var isRegex: Bool      // false = coincidencia de subcadena, case-insensitive
    var colorHex: String   // hex del color de resaltado, e.g. "#FF3B30"
    var priority: Int      // 0 = mayor prioridad; orden de evaluación
    var isEnabled: Bool
}

struct WidgetConfig: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String                      // nombre visible para el usuario
    var calendarIdentifier: String        // EKCalendar.calendarIdentifier
    var colorSchemeLight: ColorPair       // color de fondo para modo claro
    var colorSchemeDark: ColorPair        // color de fondo para modo oscuro
    var rules: [FilterRule]               // vacío en Fase 1
    var showCancelled: Bool               // false por defecto
    var workStartOffset: TimeInterval     // segundos desde medianoche. -1 = sin filtro
    var workEndOffset: TimeInterval       // segundos desde medianoche. -1 = sin filtro
}
```

## Valores por defecto

```swift
extension WidgetConfig {
    static func new(name: String, calendarIdentifier: String) -> WidgetConfig {
        WidgetConfig(
            id: UUID(),
            name: name,
            calendarIdentifier: calendarIdentifier,
            colorSchemeLight: .system,
            colorSchemeDark: .system,
            rules: [],
            showCancelled: false,
            workStartOffset: -1,
            workEndOffset: -1
        )
    }
}
```

## Persistencia en App Group (Shared/WidgetConfigStore.swift)

```swift
enum WidgetConfigStore {
    static let key = "widgetConfigs"

    static func loadAll() -> [WidgetConfig] {
        guard let data = AppGroup.defaults.data(forKey: key),
              let configs = try? JSONDecoder().decode([WidgetConfig].self, from: data)
        else { return [] }
        return configs
    }

    static func saveAll(_ configs: [WidgetConfig]) {
        guard let data = try? JSONEncoder().encode(configs) else { return }
        AppGroup.defaults.set(data, forKey: key)
    }
}
```

## Criterios de aceptación
- Serializar y deserializar un WidgetConfig con todos los campos produce valores idénticos
- Guardar [WidgetConfig] desde la app y leer desde el widget extension devuelve el mismo array
- Compilación sin errores en ambos targets

PARENT
  ↑ ○ CAL-sue: (EPIC) Fase 0: Infraestructura ● P0

DEPENDS ON
  → ✓ CAL-sue.2: Configurar App Group compartido ● P0

BLOCKS
  ← ○ CAL-0q3.1: App companion: lista de configuraciones y CRUD básico ● P0
  ← ○ CAL-sue.4: Implementar AppEntity y EntityQuery para el picker del widget ● P0



## Steps

### 0. Claim
```bash
bd update CAL-sue.3 --claim
```

### 1. Parse the Scenario
Extract the Given/When/Then/And structure:
- **Given** = what state must exist (test setup)
- **When** = what action triggers the behavior
- **Then** = what must be true after (assertions)
- **And** = additional assertions

### 2. Read Existing Code
Before writing anything, read relevant existing files to understand what exists, where to add code, and what patterns to follow.

### 3. Implement
Write the minimum code to make the scenario true.
- Follow existing patterns (Swift, SwiftUI, WidgetKit, EventKit)
- Do NOT refactor unrelated code
- Do NOT add features beyond the scenario

### 4. Write Tests
One XCTest per Then/And clause, mirroring the scenario:

```swift
final class <Feature>ScenarioTests: XCTestCase {
    // MARK: - CAL-sue.3: Definir modelo WidgetConfig compartido

    func test_{beadId}_given_<setup>_when_<action>_then_<outcome>() {
        // Given — setup matching scenario preconditions
        // When  — action matching scenario trigger
        // Then  — XCTAssert* matching scenario outcomes
    }
}
```

- Test names include the bead ID
- Use mocks/stubs for EventKit, network, and WidgetKit APIs

### 5. Run Tests
Run unit tests (see CLAUDE.md for command). Fix and re-run if needed (max 3 attempts). ALL tests must pass — no regressions.

### 6. Commit
```bash
git add <specific files>
git commit -m "$(cat <<'EOF'
impl(CAL-sue.3): Definir modelo WidgetConfig compartido

Scenario: Given/When/Then covered
Tests: N passed

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"
```

Do NOT push. The verifier pushes after approval.

### 7. Write Result
Write to `orchestrator-state/results/CAL-sue.3.json`:

```json
{
  "bead_id": "CAL-sue.3",
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
3. `bd update CAL-sue.3 --notes="Impl failed: <error>"`
4. Exit
