import XCTest
@testable import Calendario

final class CALbktScenarioTests: XCTestCase {

    private func makeRule(
        pattern: String,
        isRegex: Bool = false,
        colorHex: String = "#FF0000",
        priority: Int = 0,
        isEnabled: Bool = true
    ) -> FilterRule {
        FilterRule(id: UUID(), pattern: pattern, isRegex: isRegex, colorHex: colorHex, priority: priority, isEnabled: isEnabled)
    }

    private func makeConfig(rules: [FilterRule] = []) -> WidgetConfig {
        WidgetConfig(
            id: UUID(),
            name: "Test",
            calendarIdentifier: "cal-id",
            colorSchemeLight: .system,
            colorSchemeDark: .system,
            rules: rules,
            showCancelled: false,
            workStartOffset: -1,
            workEndOffset: -1
        )
    }

    // MARK: - Scenario: Crear regla de texto

    func test_CALbkt_given_emptyConfig_when_addRule_then_rulesArrayContainsRule() {
        // Given
        var config = makeConfig()
        let rule = makeRule(pattern: "Reunión")
        // When
        config.rules.append(rule)
        // Then
        XCTAssertEqual(config.rules.count, 1)
        XCTAssertEqual(config.rules[0].pattern, "Reunión")
    }

    func test_CALbkt_given_configWithRule_when_addSecondRule_then_rulesArrayHasTwoRules() {
        // Given
        let rule1 = makeRule(pattern: "Reunión", priority: 0)
        var config = makeConfig(rules: [rule1])
        let rule2 = makeRule(pattern: "Almuerzo", priority: 1)
        // When
        config.rules.append(rule2)
        // Then
        XCTAssertEqual(config.rules.count, 2)
    }

    // MARK: - Scenario: Regex inválido muestra error

    func test_CALbkt_given_invalidRegexPattern_when_validatePattern_then_errorDetected() {
        // Given
        let invalidPattern = "[invalid"
        // When
        let isValid = (try? Regex(invalidPattern)) != nil
        // Then
        XCTAssertFalse(isValid, "Invalid regex should not compile")
    }

    func test_CALbkt_given_validRegexPattern_when_validatePattern_then_noError() {
        // Given
        let validPattern = "Reunión.*"
        // When
        let isValid = (try? Regex(validPattern)) != nil
        // Then
        XCTAssertTrue(isValid, "Valid regex should compile")
    }

    func test_CALbkt_given_simpleTextPattern_when_validatePattern_then_noError() {
        // Given — plain text (non-regex) never goes through Regex init
        let pattern = "Reunión"
        // When — text rules don't need regex validation
        let isEmpty = pattern.trimmingCharacters(in: .whitespaces).isEmpty
        // Then
        XCTAssertFalse(isEmpty)
    }

    // MARK: - Scenario: Eliminar regla

    func test_CALbkt_given_configWithOneRule_when_deleteRule_then_rulesArrayIsEmpty() {
        // Given
        let rule = makeRule(pattern: "Reunión")
        var config = makeConfig(rules: [rule])
        // When
        config.rules.removeAll { $0.id == rule.id }
        // Then
        XCTAssertTrue(config.rules.isEmpty)
    }

    func test_CALbkt_given_configWithTwoRules_when_deleteFirstRule_then_secondRuleRemains() {
        // Given
        let rule1 = makeRule(pattern: "Reunión", priority: 0)
        let rule2 = makeRule(pattern: "Almuerzo", priority: 1)
        var config = makeConfig(rules: [rule1, rule2])
        // When
        config.rules.removeAll { $0.id == rule1.id }
        // Then
        XCTAssertEqual(config.rules.count, 1)
        XCTAssertEqual(config.rules[0].pattern, "Almuerzo")
    }

    // MARK: - Scenario: Reordenar reglas cambia prioridad

    func test_CALbkt_given_twoRules_when_reorder_then_prioritiesAreUpdated() {
        // Given — rule1 at priority 0, rule2 at priority 1
        let rule1 = makeRule(pattern: "Reunión", priority: 0)
        let rule2 = makeRule(pattern: "Almuerzo", priority: 1)
        var rules = [rule1, rule2]
        // When — move rule2 to position 0 (above rule1)
        rules.move(fromOffsets: IndexSet(integer: 1), toOffset: 0)
        for (index, rule) in rules.enumerated() {
            rules[index] = FilterRule(
                id: rule.id,
                type: rule.type,
                pattern: rule.pattern,
                isRegex: rule.isRegex,
                colorHex: rule.colorHex,
                priority: index,
                isEnabled: rule.isEnabled
            )
        }
        // Then — rule2 now has priority 0, rule1 has priority 1
        let reorderedRule2 = rules.first { $0.pattern == "Almuerzo" }
        let reorderedRule1 = rules.first { $0.pattern == "Reunión" }
        XCTAssertEqual(reorderedRule2?.priority, 0)
        XCTAssertEqual(reorderedRule1?.priority, 1)
    }

    func test_CALbkt_given_threeRules_when_moveLastToFirst_then_prioritiesAreConsecutive() {
        // Given
        let r0 = makeRule(pattern: "A", priority: 0)
        let r1 = makeRule(pattern: "B", priority: 1)
        let r2 = makeRule(pattern: "C", priority: 2)
        var rules = [r0, r1, r2]
        // When — move index 2 to index 0
        rules.move(fromOffsets: IndexSet(integer: 2), toOffset: 0)
        for (index, rule) in rules.enumerated() {
            rules[index] = FilterRule(
                id: rule.id,
                type: rule.type,
                pattern: rule.pattern,
                isRegex: rule.isRegex,
                colorHex: rule.colorHex,
                priority: index,
                isEnabled: rule.isEnabled
            )
        }
        // Then — priorities are 0,1,2 and "C" is first
        XCTAssertEqual(rules[0].pattern, "C")
        XCTAssertEqual(rules[0].priority, 0)
        XCTAssertEqual(rules[1].pattern, "A")
        XCTAssertEqual(rules[1].priority, 1)
        XCTAssertEqual(rules[2].pattern, "B")
        XCTAssertEqual(rules[2].priority, 2)
    }
}
