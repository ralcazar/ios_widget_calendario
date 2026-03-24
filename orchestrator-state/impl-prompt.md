# BDD Implementer Agent

You are implementing a BDD scenario for this iOS widget/calendar project. Project rules, coding standards, and build commands are in CLAUDE.md. Beads workflow context is auto-injected via `bd prime`.

## Your Bead

- **ID**: CAL-sue.1
- **Title**: Crear proyecto Xcode con targets + configurar App Group
- **Scenario**:

◐ CAL-sue.1 · Crear proyecto Xcode con targets + configurar App Group   [● P0 · IN_PROGRESS]
Owner: Roberto Alcázar · Assignee: Roberto Alcázar · Type: task
Created: 2026-03-24 · Updated: 2026-03-24

DESCRIPTION
Crear el proyecto Xcode con dos targets (app companion + widget extension) y configurar el App Group capability en ambos targets para compartir datos via UserDefaults(suiteName:).

## Especificaciones del proyecto
- **Nombre de la app**: Calendario
- **Bundle ID app**: com.ralcazar.calendario
- **Bundle ID widget**: com.ralcazar.calendario.widget
- **App Group ID**: group.com.ralcazar.calendario
- **Deployment target**: iOS 17.0 (mínimo para widgets interactivos)
- **Lenguaje**: Swift, SwiftUI
- **Scheme**: Calendario

## Pasos
1. Crear proyecto Xcode: File → New → Project → App, nombre 'Calendario', bundle ID com.ralcazar.calendario, SwiftUI, Swift
2. Añadir Widget Extension target: File → New → Target → Widget Extension, nombre 'CalendarioWidget', bundle ID com.ralcazar.calendario.widget. Desmarcar 'Include Live Activity' y 'Include Configuration App Intent' (se añade manualmente más adelante)
3. Activar App Groups en ambos targets: Signing & Capabilities → + Capability → App Groups → añadir 'group.com.ralcazar.calendario'
4. Crear SharedConstants.swift accesible por ambos targets con:
   ```swift
   enum AppGroup {
       static let identifier = "group.com.ralcazar.calendario"
       static var defaults: UserDefaults { UserDefaults(suiteName: identifier)! }
   }
   ```
5. Verificar que ambos targets tienen el mismo App Group identifier

## Criterios de aceptación
- El proyecto compila sin errores en simulador iPhone
- Ambos targets (app + widget) tienen App Groups activado con 'group.com.ralcazar.calendario'
- Se puede escribir y leer un valor de prueba: AppGroup.defaults.set('test', forKey: 'ping') desde app, leer desde widget

PARENT
  ↑ ○ CAL-sue: (EPIC) Fase 0: Infraestructura ● P0

BLOCKS
  ← ✓ CAL-sue.2: Configurar App Group compartido ● P0



## Steps

### 0. Claim
```bash
bd update CAL-sue.1 --claim
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
    // MARK: - CAL-sue.1: Crear proyecto Xcode con targets + configurar App Group

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
impl(CAL-sue.1): Crear proyecto Xcode con targets + configurar App Group

Scenario: Given/When/Then covered
Tests: N passed

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"
```

Do NOT push. The verifier pushes after approval.

### 7. Write Result
Write to `orchestrator-state/results/CAL-sue.1.json`:

```json
{
  "bead_id": "CAL-sue.1",
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
3. `bd update CAL-sue.1 --notes="Impl failed: <error>"`
4. Exit
