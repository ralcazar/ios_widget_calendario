import XCTest
@testable import Calendario

final class CAL7i7ScenarioTests: XCTestCase {

    // MARK: - RuleEngine.matches(pattern:isRegex:title:)

    func test_CAL7i7_given_plainPatternMatchingTitle_when_matches_then_returnsTrue() {
        // Given
        let pattern = "trabajo"
        let title = "Reunión de trabajo"
        // When
        let result = RuleEngine.matches(pattern: pattern, isRegex: false, title: title)
        // Then
        XCTAssertTrue(result)
    }

    func test_CAL7i7_given_plainPatternNotMatchingTitle_when_matches_then_returnsFalse() {
        // Given
        let pattern = "trabajo"
        let title = "Dentista"
        // When
        let result = RuleEngine.matches(pattern: pattern, isRegex: false, title: title)
        // Then
        XCTAssertFalse(result)
    }

    func test_CAL7i7_given_plainPatternCaseInsensitive_when_matches_then_returnsTrue() {
        // Given
        let pattern = "TRABAJO"
        let title = "reunión de trabajo"
        // When
        let result = RuleEngine.matches(pattern: pattern, isRegex: false, title: title)
        // Then
        XCTAssertTrue(result)
    }

    func test_CAL7i7_given_validRegexMatchingTitle_when_matches_then_returnsTrue() {
        // Given
        let pattern = "^Reunión"
        let title = "Reunión de equipo"
        // When
        let result = RuleEngine.matches(pattern: pattern, isRegex: true, title: title)
        // Then
        XCTAssertTrue(result)
    }

    func test_CAL7i7_given_validRegexNotMatchingTitle_when_matches_then_returnsFalse() {
        // Given
        let pattern = "^Reunión"
        let title = "Mi Reunión de equipo"
        // When
        let result = RuleEngine.matches(pattern: pattern, isRegex: true, title: title)
        // Then
        XCTAssertFalse(result)
    }

    func test_CAL7i7_given_invalidRegex_when_matches_then_returnsFalse() {
        // Given — invalid regex pattern
        let pattern = "[invalid"
        let title = "Reunión"
        // When
        let result = RuleEngine.matches(pattern: pattern, isRegex: true, title: title)
        // Then
        XCTAssertFalse(result)
    }

    func test_CAL7i7_given_regexPatternOver100Chars_when_matches_then_returnsFalse() {
        // Given — pattern > 100 chars
        let pattern = String(repeating: "a", count: 101)
        let title = String(repeating: "a", count: 101)
        // When
        let result = RuleEngine.matches(pattern: pattern, isRegex: true, title: title)
        // Then
        XCTAssertFalse(result)
    }

    func test_CAL7i7_given_emptyTitle_when_plainPatternMatch_then_returnsFalse() {
        // Given
        let pattern = "trabajo"
        let title = ""
        // When
        let result = RuleEngine.matches(pattern: pattern, isRegex: false, title: title)
        // Then
        XCTAssertFalse(result)
    }
}
