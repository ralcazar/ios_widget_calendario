# BDD Implementer Agent

You are implementing a BDD scenario for this iOS widget/calendar project. Project rules, coding standards, and build commands are in CLAUDE.md. Beads workflow context is auto-injected via `bd prime`.

## Your Bead

- **ID**: CAL-3qm
- **Title**: Vista timeline visual en widgets mediano y grande
- **Scenario**:

**Description**: Reemplazar la lista de texto actual en los widgets mediano y grande por una vista de timeline visual similar al widget de Calendario de iOS. Los eventos se muestran como bloques de color posicionados en su franja horaria, con los solapamientos representados gráficamente (eventos lado a lado). El eje de tiempo va desde la hora de inicio hasta la hora de fin de la jornada laboral configurada. Las reglas de filtrado se aplican.

**Design**:
## Contexto actual
- MediumWidgetView y LargeWidgetView muestran listas de texto (EventRowView)
- `Array+OverlapGrouping.swift` agrupa eventos por solapamiento
- `WorkHoursFilter.swift` filtra eventos fuera de jornada laboral
- `WidgetConfig` tiene `workStartOffset` / `workEndOffset` (segundos desde medianoche, -1 si deshabilitado)
- Los datos ya llegan filtrados por RuleEngine (ocultos eliminados, resaltados con color)
- `CalendarURL.forDate()` en Shared/SharedConstants.swift para deep links

## Diseño visual
```
┌─────────────────────────────┐
│ HOY  27 mar       Config ▸  │  ← Header (mantener)
│ [Todo el día: Festivo     ] │  ← Sección all-day (si hay eventos all-day)
├─────────────────────────────┤
│ 9:00 ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄ │
│      ┌────────┐┌──────────┐ │  ← Bloques solapados lado a lado
│      │Reunión ││Standup   │ │
│10:00 └────────┘└──────────┘ │
│      ┌──────────────────┐   │
│      │   Code review    │   │
│12:00 └──────────────────┘   │
│18:00 ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄ │
└─────────────────────────────┘
```

## Archivos a crear

### 1. TimelineView.swift (CalendarioWidget/WidgetViews/)
Uses GeometryReader. Parameters:
- `events: [(event: EKEvent, matchedColor: String?)]`
- `workStart: TimeInterval` (seconds from midnight, -1 = use 8*3600 default)
- `workEnd: TimeInterval` (seconds from midnight, -1 = use 20*3600 default)
- `now: Date`
- `compact: Bool` (true = medium, false = large)

Implementation approach:
```swift
struct TimelineView: View {
    // ...parameters...

    private var effectiveStart: TimeInterval { workStart >= 0 ? workStart : 8 * 3600 }
    private var effectiveEnd: TimeInterval { workEnd >= 0 ? workEnd : 20 * 3600 }
    private var totalDuration: TimeInterval { effectiveEnd - effectiveStart }

    // Separate all-day events from timed events
    private var allDayEvents: [EKEvent] { events.map(\.event).filter(\.isAllDay) }
    private var timedEvents: [(event: EKEvent, matchedColor: String?)] { events.filter { !$0.event.isAllDay } }

    // Filter timed events to those within the work hours window
    private var visibleTimedEvents: [(event: EKEvent, matchedColor: String?)] {
        timedEvents.filter { item in
            let midnight = Calendar.current.startOfDay(for: item.event.startDate)
            let startSecs = item.event.startDate.timeIntervalSince(midnight)
            let endSecs = item.event.endDate.timeIntervalSince(midnight)
            return startSecs < effectiveEnd && endSecs > effectiveStart
        }
    }

    var body: some View {
        GeometryReader { geo in
            let timeLabelsWidth: CGFloat = compact ? 28 : 32
            let blockAreaWidth = geo.size.width - timeLabelsWidth

            ZStack(alignment: .topLeading) {
                // Hour marks (lines + labels)
                // Event blocks positioned by time
            }
        }
    }

    // Column layout algorithm for overlapping events
    private func layoutColumns(for events: [(event: EKEvent, matchedColor: String?)])
        -> [(item: (event: EKEvent, matchedColor: String?), column: Int, totalColumns: Int)] {
        // Greedy column assignment
    }

    // Y position and height for an event
    private func yFraction(for date: Date) -> CGFloat { ... }
    private func heightFraction(startDate: Date, endDate: Date) -> CGFloat { ... }
}
```

### 2. TimelineEventBlock.swift (CalendarioWidget/WidgetViews/)
```swift
struct TimelineEventBlock: View {
    let event: EKEvent
    let matchedColor: String?
    let compact: Bool

    private var blockColor: Color {
        if let hex = matchedColor, let color = Color(hex: hex) { return color }
        return Color(cgColor: event.calendar.cgColor)
    }

    var body: some View {
        // Link wrapping content (calshow: URL)
        // ZStack:
        //   - background: blockColor.opacity(0.25) + cornerRadius(4)
        //   - leading border: Rectangle 3pt wide, blockColor full opacity
        //   - VStack: title text (caption2/caption) lineLimit 1-2
        // .opacity(event.status == .canceled ? 0.5 : 1.0)
        // .accessibilityIdentifier("timelineBlock_\(event.eventIdentifier ?? "")")
    }
}
```

## Archivos a modificar

### 3. MediumWidgetView.swift
Replace the body (keep header). Replace event list with:
```swift
VStack(alignment: .leading, spacing: 2) {
    // Keep existing header
    // Keep Divider
    TimelineView(
        events: entry.events,
        workStart: entry.widgetConfig.workStartOffset,
        workEnd: entry.widgetConfig.workEndOffset,
        now: now,
        compact: true
    )
}
```

### 4. LargeWidgetView.swift
Same but `compact: false`.

### 5. Array+OverlapGrouping.swift (posiblemente)
May need to add a column-layout function, or implement it inline in TimelineView.

## Implementation Notes
- Use `GeometryReader` — this is valid in WidgetKit for layout calculation
- Minimum block height: max(computed height, 16pt) to ensure readability
- Hour marks: only show hours that fit (every 1h for large, every 2h for compact)
- Line for current time (now) if it falls within the work hours range: thin red/orange horizontal line
- All-day events: compact strip at top if any exist (just title, no time positioning)
- Empty state (no events): keep existing "Sin eventos hoy" text
- Do NOT use EventRowView in these views anymore (replaced by TimelineEventBlock)

## Criterios de aceptación
- [ ] MediumWidgetView muestra timeline visual (no lista de texto)
- [ ] LargeWidgetView muestra timeline visual (no lista de texto)
- [ ] El eje de tiempo refleja las horas de jornada laboral configuradas (o 8:00-20:00 por defecto)
- [ ] Eventos solapados se muestran lado a lado (columnas)
- [ ] Cada bloque usa color de regla resaltar o color del calendario del SO
- [ ] All-day events en sección separada arriba
- [ ] Bloques son pulsables (abren app Calendario)
- [ ] Línea de 'ahora' visible si la hora actual está en el rango
- [ ] Eventos cancelados con opacidad reducida
- [ ] accessibilityIdentifiers en bloques

## Steps

### 0. Claim
```bash
bd update CAL-3qm --claim
```

### 1. Read Existing Code First
```
Calendario/CalendarioWidget/WidgetViews/MediumWidgetView.swift
Calendario/CalendarioWidget/WidgetViews/LargeWidgetView.swift
Calendario/CalendarioWidget/WidgetViews/EventRowView.swift
Calendario/CalendarioWidget/CalendarEntry.swift
Calendario/Shared/Array+OverlapGrouping.swift
Calendario/Shared/SharedConstants.swift
```

### 2. Implement
Create TimelineView.swift and TimelineEventBlock.swift. Modify MediumWidgetView and LargeWidgetView.
- FilterRule has `type: RuleType` field — remember this when creating test FilterRules
- CalendarURL.forDate() is in Shared/SharedConstants.swift

### 3. Write Tests
Test the pure logic (layout algorithm, Y/height fraction calculations):

```swift
final class CAL3qmScenarioTests: XCTestCase {
    func test_CAL3qm_given_<setup>_when_<action>_then_<outcome>() { }
}
```

Focus on testing:
- `yFraction(for:)` — correct proportion within work hours range
- `heightFraction(startDate:endDate:)` — correct height proportion
- Column layout algorithm — correct column assignment for overlapping events
- Default work hours fallback (8:00-20:00 when offset is -1)

### 4. Run Tests
```bash
xcodebuild test \
  -project Calendario/Calendario.xcodeproj \
  -scheme Calendario \
  -destination 'platform=iOS Simulator,id=498EB01B-D438-4EEA-BED5-C6C7F62E1C85' \
  -only-testing:CalendarioTests
```
ALL must pass.

### 5. Commit
```bash
git add <specific files>
git commit -m "$(cat <<'EOF'
impl(CAL-3qm): Vista timeline visual en widgets mediano y grande

Scenario: Given/When/Then covered
Tests: N passed

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"
```

Do NOT push.

### 6. Write Result
Write to `orchestrator-state/results/CAL-3qm.json`:
```json
{
  "bead_id": "CAL-3qm",
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
2. `git checkout .`
3. `bd update CAL-3qm --notes="Impl failed: <error>"`
4. Exit
