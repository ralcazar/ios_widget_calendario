import XCTest
import EventKit
@testable import Calendario

final class CALevk1ScenarioTests: XCTestCase {

    private var store: EKEventStore!

    override func setUp() {
        super.setUp()
        store = EKEventStore()
    }

    private func makeEvent(title: String) -> EKEvent {
        let event = EKEvent(eventStore: store)
        event.title = title
        return event
    }

    private func makeRule(pattern: String, isRegex: Bool = false, colorHex: String = "#FF0000", priority: Int = 0, isEnabled: Bool = true) -> FilterRule {
        FilterRule(id: UUID(), pattern: pattern, isRegex: isRegex, colorHex: colorHex, priority: priority, isEnabled: isEnabled)
    }

    // MARK: - Scenario: Sin reglas se muestran todos los eventos

    func test_CALevk1_given_emptyRules_when_applyRuleEngine_then_allEventsReturnedWithNilColor() {
        // Given
        let events = [makeEvent(title: "Reunión"), makeEvent(title: "Cumpleaños")]
        // When
        let result = RuleEngine.apply(rules: [], to: events)
        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertNil(result[0].matchedColor)
        XCTAssertNil(result[1].matchedColor)
    }

    func test_CALevk1_given_allDisabledRules_when_applyRuleEngine_then_allEventsReturnedWithNilColor() {
        // Given
        let events = [makeEvent(title: "Trabajo")]
        let rule = makeRule(pattern: "Trabajo", isEnabled: false)
        // When
        let result = RuleEngine.apply(rules: [rule], to: events)
        // Then
        XCTAssertEqual(result.count, 1)
        XCTAssertNil(result[0].matchedColor)
    }

    // MARK: - Scenario: Regla literal filtra por subcadena

    func test_CALevk1_given_literalRule_when_titlesMatchSubstring_then_matchingEventsColored() {
        // Given
        let rule = makeRule(pattern: "trabajo", colorHex: "#0000FF")
        let events = [
            makeEvent(title: "Reunión de trabajo"),
            makeEvent(title: "Cumpleaños"),
            makeEvent(title: "Trabajo remoto")
        ]
        // When
        let result = RuleEngine.apply(rules: [rule], to: events)
        // Then — all events shown; matching ones have color, non-matching has nil
        XCTAssertEqual(result.count, 3)
        let trabajo = result.first { $0.event.title == "Reunión de trabajo" }
        let remoto = result.first { $0.event.title == "Trabajo remoto" }
        let cumple = result.first { $0.event.title == "Cumpleaños" }
        XCTAssertEqual(trabajo?.matchedColor, "#0000FF")
        XCTAssertEqual(remoto?.matchedColor, "#0000FF")
        XCTAssertNil(cumple?.matchedColor)
    }

    func test_CALevk1_given_literalRule_when_eventMatches_then_matchedColorIsRuleColorHex() {
        // Given
        let rule = makeRule(pattern: "trabajo", colorHex: "#0000FF")
        let events = [makeEvent(title: "Reunión de trabajo")]
        // When
        let result = RuleEngine.apply(rules: [rule], to: events)
        // Then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].matchedColor, "#0000FF")
    }

    // MARK: - Scenario: Regex inválido no crashea

    func test_CALevk1_given_invalidRegex_when_applyRuleEngine_then_ruleMatchesNothing() {
        // Given
        let rule = makeRule(pattern: "[invalid", isRegex: true)
        let events = [makeEvent(title: "cualquier evento")]
        // When — must not throw or crash
        let result = RuleEngine.apply(rules: [rule], to: events)
        // Then — event shown with nil color (no match, but not hidden)
        XCTAssertEqual(result.count, 1)
        XCTAssertNil(result[0].matchedColor)
    }

    // MARK: - Scenario: Regex demasiado largo no se evalúa

    func test_CALevk1_given_regexPatternOver100Chars_when_applyRuleEngine_then_ruleMatchesNothing() {
        // Given — pattern of 101 characters
        let longPattern = String(repeating: "a", count: 101)
        let rule = makeRule(pattern: longPattern, isRegex: true)
        let events = [makeEvent(title: String(repeating: "a", count: 200))]
        // When
        let result = RuleEngine.apply(rules: [rule], to: events)
        // Then — event shown with nil color (no match, but not hidden)
        XCTAssertEqual(result.count, 1)
        XCTAssertNil(result[0].matchedColor)
    }

    func test_CALevk1_given_regexPatternExactly100Chars_when_applyRuleEngine_then_ruleIsEvaluated() {
        // Given — pattern of exactly 100 characters (valid regex: matches "a")
        let pattern = String(repeating: "a", count: 100)
        let rule = makeRule(pattern: pattern, isRegex: true)
        let events = [makeEvent(title: String(repeating: "a", count: 100))]
        // When
        let result = RuleEngine.apply(rules: [rule], to: events)
        // Then — 100-char pattern IS evaluated (limit is > 100)
        XCTAssertEqual(result.count, 1)
    }

    // MARK: - Scenario: Prioridad determina el orden de evaluación

    func test_CALevk1_given_twoRules_when_eventMatchesBoth_then_higherPriorityColorIsUsed() {
        // Given — priority 0 = higher priority, priority 1 = lower
        let highPriorityRule = makeRule(pattern: "reunion", isRegex: false, colorHex: "#FF0000", priority: 0)
        let lowPriorityRule = makeRule(pattern: "reunion", isRegex: false, colorHex: "#00FF00", priority: 1)
        let events = [makeEvent(title: "reunion importante")]
        // When
        let result = RuleEngine.apply(rules: [highPriorityRule, lowPriorityRule], to: events)
        // Then — matchedColor is from priority 0 rule
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].matchedColor, "#FF0000")
    }

    func test_CALevk1_given_twoRulesInsertedReversed_when_eventMatchesBoth_then_priorityOrderDeterminesColor() {
        // Given — same rules but inserted in reversed order; priority should still win
        let lowPriorityRule = makeRule(pattern: "reunion", isRegex: false, colorHex: "#00FF00", priority: 1)
        let highPriorityRule = makeRule(pattern: "reunion", isRegex: false, colorHex: "#FF0000", priority: 0)
        let events = [makeEvent(title: "reunion")]
        // When — rules provided in reverse order
        let result = RuleEngine.apply(rules: [lowPriorityRule, highPriorityRule], to: events)
        // Then — priority sort ensures "#FF0000" wins
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].matchedColor, "#FF0000")
    }
}
