import XCTest
@testable import Calendario

final class CALyw8ScenarioTests: XCTestCase {

    // MARK: - CAL-yw8: Liquid UI / multi-device layout

    // Layout changes (NavigationSplitView on iPad, maxWidth on emptyState, minHeight on EventRow)
    // are structural SwiftUI changes verified visually in UI tests.
    // Unit tests cover any pure-logic aspects.

    func test_CALyw8_given_emptyConfigs_when_rulesCountText_then_sinReglas() {
        // Validates rulesCountText used in ConfigListView still works after layout changes
        XCTAssertEqual(rulesCountText(0), "Sin reglas")
    }

    func test_CALyw8_given_calendarIdentifier_when_resolveDisplayName_then_fallsBackToIdentifier() {
        // Validates calendar display name resolution still works after layout changes
        let id = "test-calendar-id"
        let result = resolveCalendarDisplayName(for: id, in: [:])
        XCTAssertEqual(result, id)
    }
}
