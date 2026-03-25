import XCTest
import EventKit
@testable import Calendario

final class CALjo52ScenarioTests: XCTestCase {

    // Helper: create a WidgetConfig with given work offsets
    private func makeConfig(startOffset: TimeInterval, endOffset: TimeInterval) -> WidgetConfig {
        WidgetConfig(
            id: UUID(),
            name: "Test",
            calendarIdentifier: "test",
            colorSchemeLight: .system,
            colorSchemeDark: .system,
            rules: [],
            showCancelled: false,
            workStartOffset: startOffset,
            workEndOffset: endOffset
        )
    }

    // Helper: create an EKEvent with given start/end hour offsets from midnight today
    private func makeEvent(startHour: Double, endHour: Double?) -> EKEvent {
        let store = EKEventStore()
        let event = EKEvent(eventStore: store)
        let midnight = Calendar.current.startOfDay(for: Date())
        event.startDate = midnight.addingTimeInterval(startHour * 3600)
        event.endDate = endHour.map { midnight.addingTimeInterval($0 * 3600) }
        event.title = "Test Event"
        return event
    }

    // Scenario: workStartOffset = -1 → no filter, all events pass
    func test_CALjo52_given_noFilter_when_isWithinWorkHours_then_returnsTrue() {
        let config = makeConfig(startOffset: -1, endOffset: -1)
        let event = makeEvent(startHour: 0, endHour: 23)
        XCTAssertTrue(WorkHoursFilter.isWithinWorkHours(event: event, config: config))
    }

    // Scenario: event 8:00–9:30 overlaps with window 9:00–18:00 → included
    func test_CALjo52_given_eventOverlapsWindowStart_when_isWithinWorkHours_then_included() {
        let config = makeConfig(startOffset: 32400, endOffset: 64800) // 9:00–18:00
        let event = makeEvent(startHour: 8, endHour: 9.5)             // 8:00–9:30
        XCTAssertTrue(WorkHoursFilter.isWithinWorkHours(event: event, config: config))
    }

    // Scenario: event 8:00–8:59 ends before window starts → excluded
    func test_CALjo52_given_eventEndsBeforeWindowStarts_when_isWithinWorkHours_then_excluded() {
        let config = makeConfig(startOffset: 32400, endOffset: 64800)           // 9:00–18:00
        let event = makeEvent(startHour: 8, endHour: 8 + (59.0 / 60.0))        // 8:00–8:59
        XCTAssertFalse(WorkHoursFilter.isWithinWorkHours(event: event, config: config))
    }

    // Event starts exactly at workStart → included
    func test_CALjo52_given_eventStartsAtWindowStart_when_isWithinWorkHours_then_included() {
        let config = makeConfig(startOffset: 32400, endOffset: 64800) // 9:00–18:00
        let event = makeEvent(startHour: 9, endHour: 10)              // 9:00–10:00
        XCTAssertTrue(WorkHoursFilter.isWithinWorkHours(event: event, config: config))
    }

    // Event starts exactly at workEnd → excluded (eventEnd > workStart is true but startDate < workEnd is false)
    func test_CALjo52_given_eventStartsAtWindowEnd_when_isWithinWorkHours_then_excluded() {
        let config = makeConfig(startOffset: 32400, endOffset: 64800) // 9:00–18:00
        let event = makeEvent(startHour: 18, endHour: 19)             // 18:00–19:00
        XCTAssertFalse(WorkHoursFilter.isWithinWorkHours(event: event, config: config))
    }

    // Event with nil endDate uses startDate + 3600
    func test_CALjo52_given_eventWithNilEndDate_when_isWithinWorkHours_then_usesStartPlusOneHour() {
        let config = makeConfig(startOffset: 32400, endOffset: 64800) // 9:00–18:00
        let event = makeEvent(startHour: 9, endHour: nil)             // starts 9:00, endDate = nil → treated as 10:00
        XCTAssertTrue(WorkHoursFilter.isWithinWorkHours(event: event, config: config))
    }
}
