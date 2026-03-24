import XCTest
@testable import Calendario

final class CALsue3ScenarioTests: XCTestCase {
    // MARK: - CAL-sue.3: Definir modelo WidgetConfig compartido

    func test_CALsue3_given_widgetConfig_when_serializing_then_roundtripProducesIdenticalValues() {
        // Given
        let original = WidgetConfig.new(name: "Work", calendarIdentifier: "cal-123")
        // When
        let data = try! JSONEncoder().encode(original)
        let decoded = try! JSONDecoder().decode(WidgetConfig.self, from: data)
        // Then
        XCTAssertEqual(original, decoded)
    }

    func test_CALsue3_given_widgetConfigArray_when_savingAndLoading_then_arrayIsIdentical() {
        // Given
        let configs = [WidgetConfig.new(name: "Work", calendarIdentifier: "cal-1")]
        let testKey = "testWidgetConfigs_\(UUID().uuidString)"
        // When - save directly (bypassing WidgetConfigStore.key to avoid state pollution)
        let data = try! JSONEncoder().encode(configs)
        AppGroup.defaults.set(data, forKey: testKey)
        let loaded = AppGroup.defaults.data(forKey: testKey).flatMap {
            try? JSONDecoder().decode([WidgetConfig].self, from: $0)
        } ?? []
        // Then
        XCTAssertEqual(configs, loaded)
        // Cleanup
        AppGroup.defaults.removeObject(forKey: testKey)
    }

    func test_CALsue3_given_colorPair_when_usingSystemDefault_then_hexStringsAreEmpty() {
        // Then
        XCTAssertEqual(ColorPair.system.lightHex, "")
        XCTAssertEqual(ColorPair.system.darkHex, "")
    }

    func test_CALsue3_given_newWidgetConfig_when_checkingDefaults_then_defaultValuesAreCorrect() {
        // Given
        let config = WidgetConfig.new(name: "Test", calendarIdentifier: "cal-456")
        // Then
        XCTAssertFalse(config.showCancelled)
        XCTAssertEqual(config.workStartOffset, -1)
        XCTAssertEqual(config.workEndOffset, -1)
        XCTAssertTrue(config.rules.isEmpty)
        XCTAssertEqual(config.colorSchemeLight, .system)
        XCTAssertEqual(config.colorSchemeDark, .system)
    }
}
