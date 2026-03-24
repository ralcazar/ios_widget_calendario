import XCTest
@testable import Calendario

final class CAL0q35ScenarioTests: XCTestCase {
    // MARK: - CAL-0q3.5: Selección de configuración en el widget

    override func tearDown() {
        super.tearDown()
        AppGroup.defaults.removeObject(forKey: WidgetConfigStore.key)
    }

    func test_CAL0q35_given_noConfigSelected_when_loadingStore_then_storeIsEmpty() {
        AppGroup.defaults.removeObject(forKey: WidgetConfigStore.key)
        XCTAssertTrue(WidgetConfigStore.loadAll().isEmpty)
    }

    func test_CAL0q35_given_savedConfig_when_loadingStore_then_configAvailable() {
        let config = WidgetConfig.new(name: "Trabajo", calendarIdentifier: "cal-1")
        WidgetConfigStore.saveAll([config])
        let loaded = WidgetConfigStore.loadAll()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded[0].name, "Trabajo")
    }

    func test_CAL0q35_given_widgetConfig_when_editingNameInApp_then_updatedConfigReflectsChanges() {
        // Given
        let original = WidgetConfig.new(name: "Trabajo", calendarIdentifier: "cal-1")
        WidgetConfigStore.saveAll([original])
        // When — simulate editing from companion app
        let updated = WidgetConfig(
            id: original.id, name: "Trabajo Updated",
            calendarIdentifier: "cal-1",
            colorSchemeLight: .system, colorSchemeDark: .system,
            rules: [], showCancelled: false,
            workStartOffset: -1, workEndOffset: -1
        )
        var all = WidgetConfigStore.loadAll()
        if let idx = all.firstIndex(where: { $0.id == original.id }) {
            all[idx] = updated
        }
        WidgetConfigStore.saveAll(all)
        // Then — next widget timeline load will get updated config
        let loaded = WidgetConfigStore.loadAll()
        XCTAssertEqual(loaded[0].name, "Trabajo Updated")
    }
}
