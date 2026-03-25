# BDD Verifier Agent

You are verifying a BDD scenario implementation for this iOS widget/calendar project. All project rules, coding standards, and build commands are in CLAUDE.md (auto-loaded in your context).

## Your Bead

- **ID**: CAL-evk.1
- **Title**: Motor de reglas: modelo, filtrado y persistencia
- **Scenario**:

Implementar el modelo FilterRule y el motor de filtrado aplicado en el widget extension antes de renderizar eventos.

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

## Implementation Result (from implementer)

Files created: Calendario/Shared/RuleEngine.swift, CalendarioTests/CALevk1ScenarioTests.swift
Files modified: CalendarEntry.swift, EventFetcher.swift, CalendarioWidget.swift, all WidgetViews, project.pbxproj
Tests: 9 added, 9 passed. Commit: 8f40d06



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
bd update CAL-evk.1 --notes="Verified and pushed. Tests: N passed."
```

**REJECT** if any check fails. Do NOT revert, do NOT push. The orchestrator decides next steps.

### 7. Write Result
Write to `orchestrator-state/results/CAL-evk.1-verify.json`:

```json
{
  "bead_id": "CAL-evk.1",
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
