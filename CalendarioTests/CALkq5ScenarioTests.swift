import XCTest
@testable import Calendario

final class CALkq5ScenarioTests: XCTestCase {

    // MARK: - CAL-kq5: Rules count text pluralization

    func test_CALkq5_given_zeroRules_when_rulesCountText_then_sinReglas() {
        // Given
        let count = 0
        // When
        let text = rulesCountText(count)
        // Then
        XCTAssertEqual(text, "Sin reglas")
    }

    func test_CALkq5_given_oneRule_when_rulesCountText_then_singularRegla() {
        // Given
        let count = 1
        // When
        let text = rulesCountText(count)
        // Then
        XCTAssertEqual(text, "1 regla")
    }

    func test_CALkq5_given_multipleRules_when_rulesCountText_then_pluralReglas() {
        // Given
        let count = 5
        // When
        let text = rulesCountText(count)
        // Then
        XCTAssertEqual(text, "5 reglas")
    }

    // MARK: - CAL-kq5: Calendar display name resolution

    func test_CALkq5_given_knownCalendar_when_resolveDisplayName_then_returnsTitle() {
        // Given
        let names = ["abc-123": "Trabajo", "def-456": "Personal"]
        // When
        let result = resolveCalendarDisplayName(for: "abc-123", in: names)
        // Then
        XCTAssertEqual(result, "Trabajo")
    }

    func test_CALkq5_given_unknownCalendar_when_resolveDisplayName_then_returnsIdentifier() {
        // Given
        let names = ["abc-123": "Trabajo"]
        let unknownId = "xyz-789"
        // When
        let result = resolveCalendarDisplayName(for: unknownId, in: names)
        // Then
        XCTAssertEqual(result, unknownId)
    }

    func test_CALkq5_given_emptyNamesDict_when_resolveDisplayName_then_returnsIdentifier() {
        // Given
        let names: [String: String] = [:]
        let identifier = "some-calendar-id"
        // When
        let result = resolveCalendarDisplayName(for: identifier, in: names)
        // Then
        XCTAssertEqual(result, identifier)
    }
}
