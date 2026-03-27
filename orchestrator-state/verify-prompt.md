# BDD Verifier Agent

You are verifying a BDD scenario implementation for this iOS widget/calendar project. All project rules, coding standards, and build commands are in CLAUDE.md (auto-loaded in your context).

## Your Bead

- **ID**: CAL-3qm
- **Title**: Vista timeline visual en widgets mediano y grande
- **Scenario**:

**Description**: Reemplazar la lista de texto en widgets mediano y grande por una timeline visual con bloques de eventos posicionados proporcionalmente en su franja horaria. Solapamientos lado a lado. Eje de tiempo = jornada laboral configurada.

**Criterios de aceptación**:
- [ ] MediumWidgetView muestra timeline visual (no lista de texto)
- [ ] LargeWidgetView muestra timeline visual (no lista de texto)
- [ ] El eje de tiempo refleja las horas de jornada laboral (o 8:00-20:00 por defecto)
- [ ] Eventos solapados se muestran lado a lado (columnas)
- [ ] Cada bloque usa color de regla resaltar o color del calendario del SO
- [ ] All-day events en sección separada arriba
- [ ] Bloques son pulsables (abren app Calendario)
- [ ] Línea de 'ahora' visible si la hora actual está en el rango
- [ ] Eventos cancelados con opacidad reducida
- [ ] accessibilityIdentifiers en bloques

## Implementation Result
- Commit: de16add
- Files created: TimelineLayoutEngine.swift (Shared), TimelineView.swift, TimelineEventBlock.swift, CAL3qmScenarioTests.swift
- Files modified: MediumWidgetView.swift, LargeWidgetView.swift, project.pbxproj
- Tests: 17 passed (yFraction, heightFraction, column layout, hour labels, defaults)

## Steps

### 1. Review the Implementation
```bash
git diff HEAD~1
```
Read every changed and created file.

### 2. Validate Scenario Compliance
For EACH criterion, verify corresponding code exists.

### 3. Re-run Tests
```bash
xcodebuild test \
  -project Calendario/Calendario.xcodeproj \
  -scheme Calendario \
  -destination 'platform=iOS Simulator,id=498EB01B-D438-4EEA-BED5-C6C7F62E1C85' \
  -only-testing:CalendarioTests
```
ALL must pass — no regressions.

### 4. Check Quality
- [ ] TimelineLayoutEngine is in Shared/ (testable from CalendarioTests)
- [ ] TimelineView and TimelineEventBlock are in CalendarioWidget/WidgetViews/
- [ ] MediumWidgetView and LargeWidgetView no longer use EventRowView for timed events
- [ ] Default work hours: 8:00-20:00 when workStartOffset/workEndOffset == -1
- [ ] GeometryReader used for proportional positioning
- [ ] No force unwraps in production code
- [ ] CalendarURL.forDate() used for deep links (not hardcoded calshow: logic)
- [ ] event.calendar.cgColor used as color fallback when matchedColor is nil
- [ ] accessibilityIdentifier on TimelineEventBlock

### 5. Decision

**APPROVE** if all checks pass:
```bash
git push
bd update CAL-3qm --notes="Verified and pushed. Tests: N passed."
```

**REJECT** if any check fails. Do NOT revert, do NOT push.

### 6. Write Result
Write to `orchestrator-state/results/CAL-3qm-verify.json`:

```json
{
  "bead_id": "CAL-3qm",
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
