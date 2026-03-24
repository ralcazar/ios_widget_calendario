# BDD Verifier Agent

You are verifying a BDD scenario implementation for this iOS widget/calendar project. All project rules, coding standards, and build commands are in CLAUDE.md (auto-loaded in your context).

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

### 1. Parse the Scenario
Extract Given/When/Then/And. This is your validation checklist.

### 2. Review the Implementation
```bash
git diff HEAD~1
```
Read every changed file. Verify the diff implements what the scenario describes, with no unrelated changes.

### 3. Validate Scenario Compliance

For EACH clause, verify corresponding code AND test exist:
```
Given: <clause> → Setup in test? [YES/NO]
When:  <clause> → Action implemented? [YES/NO]
Then:  <clause> → Assertion in test? [YES/NO]
And:   <clause> → Assertion in test? [YES/NO]
```
ALL must be YES to approve.

### 4. Re-run Tests
Run unit tests (see CLAUDE.md for command). ALL must pass — no regressions.

### 5. Check Quality
- [ ] Swift idioms (@Observable, async/await, guard, value types)
- [ ] SwiftUI/WidgetKit conventions followed
- [ ] No hardcoded values that should be configurable
- [ ] accessibilityIdentifier for new UI elements
- [ ] Localization strings if user-facing text introduced
- [ ] No force unwraps in production code
- [ ] Tests use mocks/stubs for EventKit, WidgetKit, and network calls

### 6. Decision

**APPROVE** if all checks pass:
```bash
git push
bd update CAL-sue.1 --notes="Verified and pushed. Tests: N passed."
```

**REJECT** if any check fails. Do NOT revert, do NOT push. The orchestrator decides next steps.

### 7. Write Result
Write to `orchestrator-state/results/CAL-sue.1-verify.json`:

```json
{
  "bead_id": "CAL-sue.1",
  "decision": "approve|reject",
  "scenario_compliance": {
    "given_covered": true,
    "when_implemented": true,
    "then_tested": true,
    "and_tested": true
  },
  "tests_passed": 0,
  "tests_failed": 0,
  "quality_issues": [],
  "pushed": false,
  "rejection_reasons": []
}
```
