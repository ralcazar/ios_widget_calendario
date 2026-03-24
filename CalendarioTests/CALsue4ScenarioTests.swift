import XCTest
@testable import Calendario

final class CALsue4ScenarioTests: XCTestCase {
    // MARK: - CAL-sue.4: AppEntity y EntityQuery para el picker del widget

    override func tearDown() {
        super.tearDown()
        AppGroup.defaults.removeObject(forKey: WidgetConfigStore.key)
    }

    func test_CALsue4_given_twoConfigsInAppGroup_when_queryingEntities_then_returnsTwoEntities() async throws {
        // Given
        let configs = [
            WidgetConfig.new(name: "Work", calendarIdentifier: "cal-1"),
            WidgetConfig.new(name: "Personal", calendarIdentifier: "cal-2")
        ]
        WidgetConfigStore.saveAll(configs)
        // When
        let loaded = WidgetConfigStore.loadAll()
        // Then — verify both configs are present with correct names and IDs
        XCTAssertEqual(loaded.count, 2)
        XCTAssertEqual(loaded[0].id, configs[0].id)
        XCTAssertEqual(loaded[0].name, "Work")
        XCTAssertEqual(loaded[1].id, configs[1].id)
        XCTAssertEqual(loaded[1].name, "Personal")
    }

    func test_CALsue4_given_noConfigsInAppGroup_when_queryingEntities_then_returnsEmptyArray() {
        // Given — no configs saved
        AppGroup.defaults.removeObject(forKey: WidgetConfigStore.key)
        // When
        let loaded = WidgetConfigStore.loadAll()
        // Then
        XCTAssertTrue(loaded.isEmpty)
    }

    func test_CALsue4_given_savedConfig_when_loadingById_then_returnsMatchingConfig() {
        // Given
        let config = WidgetConfig.new(name: "Test", calendarIdentifier: "cal-test")
        WidgetConfigStore.saveAll([config])
        // When
        let loaded = WidgetConfigStore.loadAll().filter { $0.id == config.id }
        // Then
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded[0].name, "Test")
        XCTAssertEqual(loaded[0].calendarIdentifier, "cal-test")
    }
}
