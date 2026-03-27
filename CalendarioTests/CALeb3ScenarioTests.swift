import XCTest
import EventKit
@testable import Calendario

final class CALeb3ScenarioTests: XCTestCase {

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

    private func makeHighlightRule(pattern: String, colorHex: String = "#FF0000", priority: Int = 0, isEnabled: Bool = true) -> FilterRule {
        FilterRule(id: UUID(), type: .highlight, pattern: pattern, isRegex: false, colorHex: colorHex, priority: priority, isEnabled: isEnabled)
    }

    private func makeHideRule(pattern: String, priority: Int = 0, isEnabled: Bool = true) -> FilterRule {
        FilterRule(id: UUID(), type: .hide, pattern: pattern, isRegex: false, colorHex: "", priority: priority, isEnabled: isEnabled)
    }

    // MARK: - CAL-eb3: Highlight rules add color, non-matching events shown with nil

    func test_CALeb3_given_onlyHighlightRules_when_applyRuleEngine_then_matchingEventsHaveColorAndRestHaveNil() {
        // Given
        let rule = makeHighlightRule(pattern: "trabajo", colorHex: "#00FF00")
        let events = [makeEvent(title: "Reunión de trabajo"), makeEvent(title: "Dentista")]
        // When
        let result = RuleEngine.apply(rules: [rule], to: events)
        // Then
        XCTAssertEqual(result.count, 2)
        let trabajo = result.first { $0.event.title == "Reunión de trabajo" }
        let dentista = result.first { $0.event.title == "Dentista" }
        XCTAssertEqual(trabajo?.matchedColor, "#00FF00")
        XCTAssertNil(dentista?.matchedColor)
    }

    // MARK: - CAL-eb3: Hide rules remove matching events

    func test_CALeb3_given_onlyHideRules_when_applyRuleEngine_then_matchingEventsRemoved() {
        // Given
        let rule = makeHideRule(pattern: "dentista")
        let events = [makeEvent(title: "Reunión"), makeEvent(title: "Dentista"), makeEvent(title: "Almuerzo")]
        // When
        let result = RuleEngine.apply(rules: [rule], to: events)
        // Then — Dentista hidden, rest shown with nil color
        XCTAssertEqual(result.count, 2)
        let titles = result.map(\.event.title)
        XCTAssertFalse(titles.contains("Dentista"))
        XCTAssertTrue(result.allSatisfy { $0.matchedColor == nil })
    }

    // MARK: - CAL-eb3: Hide takes priority over highlight

    func test_CALeb3_given_hideAndHighlightRules_when_eventMatchesBoth_then_hideWins() {
        // Given
        let highlightRule = makeHighlightRule(pattern: "reunion", colorHex: "#0000FF", priority: 0)
        let hideRule = makeHideRule(pattern: "reunion", priority: 1)
        let events = [makeEvent(title: "reunion de equipo"), makeEvent(title: "almuerzo")]
        // When
        let result = RuleEngine.apply(rules: [highlightRule, hideRule], to: events)
        // Then — reunion hidden (hide wins), almuerzo shown with nil
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].event.title, "almuerzo")
        XCTAssertNil(result[0].matchedColor)
    }

    // MARK: - CAL-eb3: Mixed rules — hide removes, highlight colors, rest nil

    func test_CALeb3_given_mixedRules_when_applyRuleEngine_then_correctBehaviorPerType() {
        // Given
        let hideRule = makeHideRule(pattern: "cancelado", priority: 0)
        let highlightRule = makeHighlightRule(pattern: "importante", colorHex: "#FF0000", priority: 1)
        let events = [
            makeEvent(title: "Evento cancelado"),
            makeEvent(title: "Reunión importante"),
            makeEvent(title: "Almuerzo")
        ]
        // When
        let result = RuleEngine.apply(rules: [hideRule, highlightRule], to: events)
        // Then
        XCTAssertEqual(result.count, 2)
        let importante = result.first { $0.event.title == "Reunión importante" }
        let almuerzo = result.first { $0.event.title == "Almuerzo" }
        XCTAssertEqual(importante?.matchedColor, "#FF0000")
        XCTAssertNil(almuerzo?.matchedColor)
        XCTAssertFalse(result.contains { $0.event.title == "Evento cancelado" })
    }

    // MARK: - CAL-eb3: No rules — all events with nil color

    func test_CALeb3_given_noRules_when_applyRuleEngine_then_allEventsWithNilColor() {
        // Given
        let events = [makeEvent(title: "A"), makeEvent(title: "B")]
        // When
        let result = RuleEngine.apply(rules: [], to: events)
        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.allSatisfy { $0.matchedColor == nil })
    }

    // MARK: - CAL-eb3: Backward compatibility — FilterRule without type decodes as .highlight

    func test_CALeb3_given_jsonWithoutTypeField_when_decode_then_typeIsHighlight() throws {
        // Given — JSON from before the type field existed
        let json = """
        {
            "id": "12345678-1234-1234-1234-123456789ABC",
            "pattern": "test",
            "isRegex": false,
            "colorHex": "#FF0000",
            "priority": 0,
            "isEnabled": true
        }
        """.data(using: .utf8)!
        // When
        let rule = try JSONDecoder().decode(FilterRule.self, from: json)
        // Then
        XCTAssertEqual(rule.type, .highlight)
        XCTAssertEqual(rule.pattern, "test")
    }

    func test_CALeb3_given_jsonWithTypeField_when_decode_then_typeIsPreserved() throws {
        // Given
        let json = """
        {
            "id": "12345678-1234-1234-1234-123456789ABC",
            "type": "hide",
            "pattern": "test",
            "isRegex": false,
            "colorHex": "",
            "priority": 0,
            "isEnabled": true
        }
        """.data(using: .utf8)!
        // When
        let rule = try JSONDecoder().decode(FilterRule.self, from: json)
        // Then
        XCTAssertEqual(rule.type, .hide)
    }

    // MARK: - CAL-eb3: Disabled hide rule does not hide events

    func test_CALeb3_given_disabledHideRule_when_applyRuleEngine_then_eventNotHidden() {
        // Given
        let rule = makeHideRule(pattern: "dentista", isEnabled: false)
        let events = [makeEvent(title: "Dentista")]
        // When
        let result = RuleEngine.apply(rules: [rule], to: events)
        // Then
        XCTAssertEqual(result.count, 1)
        XCTAssertNil(result[0].matchedColor)
    }

    // MARK: - CAL-eb3: Hide rule with colorHex empty works correctly

    func test_CALeb3_given_hideRuleType_when_created_then_colorHexIsEmpty() {
        // Given/When
        let rule = FilterRule(id: UUID(), type: .hide, pattern: "test", isRegex: false, colorHex: "", priority: 0, isEnabled: true)
        // Then
        XCTAssertEqual(rule.type, .hide)
        XCTAssertEqual(rule.colorHex, "")
    }
}
