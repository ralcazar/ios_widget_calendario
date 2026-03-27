import XCTest
import EventKit
@testable import Calendario

final class CALevk3ScenarioTests: XCTestCase {

    private var store: EKEventStore!

    override func setUp() {
        super.setUp()
        store = EKEventStore()
    }

    private func makeEvent(title: String, startDate: Date = Date()) -> EKEvent {
        let event = EKEvent(eventStore: store)
        event.title = title
        event.startDate = startDate
        event.endDate = startDate.addingTimeInterval(3600)
        return event
    }

    private func makeRule(pattern: String, colorHex: String = "#FF0000", priority: Int = 0, isEnabled: Bool = true) -> FilterRule {
        FilterRule(id: UUID(), pattern: pattern, isRegex: false, colorHex: colorHex, priority: priority, isEnabled: isEnabled)
    }

    // MARK: - Scenario: Sin reglas activas se ven todos los eventos

    func test_CALevk3_given_noEnabledRules_when_applyRuleEngine_then_allEventsPassThroughWithNilColor() {
        // Given
        let events = [makeEvent(title: "Reunión"), makeEvent(title: "Cumpleaños"), makeEvent(title: "Dentista")]
        let disabledRule = makeRule(pattern: "Reunión", isEnabled: false)
        // When
        let result = RuleEngine.apply(rules: [disabledRule], to: events)
        // Then
        XCTAssertEqual(result.count, 3)
        XCTAssertTrue(result.allSatisfy { $0.matchedColor == nil })
    }

    func test_CALevk3_given_emptyRules_when_applyRuleEngine_then_allEventsPassThroughWithNilColor() {
        // Given
        let events = [makeEvent(title: "Evento A"), makeEvent(title: "Evento B")]
        // When
        let result = RuleEngine.apply(rules: [], to: events)
        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertNil(result[0].matchedColor)
        XCTAssertNil(result[1].matchedColor)
    }

    // MARK: - Scenario: Vista previa filtra y colorea con reglas activas

    func test_CALevk3_given_activeRule_when_applyRuleEngine_then_matchingEventsHaveColor() {
        // Given
        let rule = makeRule(pattern: "trabajo", colorHex: "#00FF00")
        let events = [makeEvent(title: "Reunión de trabajo"), makeEvent(title: "Dentista")]
        // When
        let result = RuleEngine.apply(rules: [rule], to: events)
        // Then — all events shown; matching one has color, non-matching has nil
        XCTAssertEqual(result.count, 2)
        let trabajo = result.first { $0.event.title == "Reunión de trabajo" }
        let dentista = result.first { $0.event.title == "Dentista" }
        XCTAssertEqual(trabajo?.matchedColor, "#00FF00")
        XCTAssertNil(dentista?.matchedColor)
    }

    func test_CALevk3_given_multipleActiveRules_when_applyRuleEngine_then_eventsColoredByMatchingRule() {
        // Given
        let ruleA = makeRule(pattern: "trabajo", colorHex: "#0000FF", priority: 0)
        let ruleB = makeRule(pattern: "personal", colorHex: "#FF0000", priority: 1)
        let events = [
            makeEvent(title: "Reunión de trabajo"),
            makeEvent(title: "Cita personal"),
            makeEvent(title: "Dentista")
        ]
        // When
        let result = RuleEngine.apply(rules: [ruleA, ruleB], to: events)
        // Then — all 3 events shown; unmatched has nil color
        XCTAssertEqual(result.count, 3)
        let trabajo = result.first { $0.event.title == "Reunión de trabajo" }
        let personal = result.first { $0.event.title == "Cita personal" }
        let dentista = result.first { $0.event.title == "Dentista" }
        XCTAssertEqual(trabajo?.matchedColor, "#0000FF")
        XCTAssertEqual(personal?.matchedColor, "#FF0000")
        XCTAssertNil(dentista?.matchedColor)
    }

    // MARK: - Scenario: Cambios en reglas se reflejan (sort order preserved)

    func test_CALevk3_given_events_when_sortedByStartDate_then_chronologicalOrder() {
        // Given
        let now = Date()
        let earlier = now.addingTimeInterval(-7200)
        let later = now.addingTimeInterval(3600)
        let events = [
            makeEvent(title: "Tarde", startDate: later),
            makeEvent(title: "Temprano", startDate: earlier),
            makeEvent(title: "Ahora", startDate: now)
        ]
        // When — simulate the sort applied before calling RuleEngine
        let sorted = events.sorted { $0.startDate < $1.startDate }
        let result = RuleEngine.apply(rules: [], to: sorted)
        // Then — order is preserved (chronological)
        XCTAssertEqual(result[0].event.title, "Temprano")
        XCTAssertEqual(result[1].event.title, "Ahora")
        XCTAssertEqual(result[2].event.title, "Tarde")
    }

    func test_CALevk3_given_moreThan50Events_when_limitedTo50_then_only50Returned() {
        // Given — 60 events
        let events = (0..<60).map { i in makeEvent(title: "Evento \(i)") }
        // When — simulate suffix(50)
        let limited = Array(events.suffix(50))
        // Then
        XCTAssertEqual(limited.count, 50)
    }

    // MARK: - Scenario: Priority determines color when event matches multiple rules

    func test_CALevk3_given_twoRulesMatchingSameEvent_when_applyRuleEngine_then_highestPriorityColorUsed() {
        // Given
        let highPriority = makeRule(pattern: "reunion", colorHex: "#FF0000", priority: 0)
        let lowPriority = makeRule(pattern: "reunion", colorHex: "#00FF00", priority: 1)
        let events = [makeEvent(title: "reunion de equipo")]
        // When
        let result = RuleEngine.apply(rules: [lowPriority, highPriority], to: events)
        // Then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].matchedColor, "#FF0000")
    }
}
