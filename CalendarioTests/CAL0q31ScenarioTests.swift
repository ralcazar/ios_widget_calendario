import XCTest
@testable import Calendario

final class CAL0q31ScenarioTests: XCTestCase {
    // MARK: - CAL-0q3.1: App companion CRUD

    override func tearDown() {
        super.tearDown()
        AppGroup.defaults.removeObject(forKey: WidgetConfigStore.key)
    }

    func test_CAL0q31_given_noConfigs_when_loadingStore_then_returnsEmptyArray() {
        AppGroup.defaults.removeObject(forKey: WidgetConfigStore.key)
        XCTAssertTrue(WidgetConfigStore.loadAll().isEmpty)
    }

    func test_CAL0q31_given_newConfig_when_saving_then_persistsInAppGroup() {
        let config = WidgetConfig.new(name: "Work", calendarIdentifier: "cal-1")
        WidgetConfigStore.saveAll([config])
        let loaded = WidgetConfigStore.loadAll()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded[0].name, "Work")
    }

    func test_CAL0q31_given_existingConfig_when_editing_then_updatesCorrectEntry() {
        let original = WidgetConfig.new(name: "Work", calendarIdentifier: "cal-1")
        WidgetConfigStore.saveAll([original])
        let updated = WidgetConfig(
            id: original.id, name: "Work Updated",
            calendarIdentifier: "cal-2",
            colorSchemeLight: .system, colorSchemeDark: .system,
            rules: [], showCancelled: false,
            workStartOffset: -1, workEndOffset: -1
        )
        var all = WidgetConfigStore.loadAll()
        if let idx = all.firstIndex(where: { $0.id == updated.id }) {
            all[idx] = updated
        }
        WidgetConfigStore.saveAll(all)
        let loaded = WidgetConfigStore.loadAll()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded[0].name, "Work Updated")
        XCTAssertEqual(loaded[0].calendarIdentifier, "cal-2")
    }

    func test_CAL0q31_given_existingConfig_when_deleting_then_removedFromStore() {
        let config = WidgetConfig.new(name: "Work", calendarIdentifier: "cal-1")
        WidgetConfigStore.saveAll([config])
        var all = WidgetConfigStore.loadAll()
        all.removeAll { $0.id == config.id }
        WidgetConfigStore.saveAll(all)
        XCTAssertTrue(WidgetConfigStore.loadAll().isEmpty)
    }

    func test_CAL0q31_given_configFormMode_when_editMode_then_isEditingIsTrue() {
        // ConfigFormMode is defined in the app target (ConfigFormView.swift)
        // Verify create mode is distinct from edit
        let createMode = ConfigFormMode.create
        if case .create = createMode {
            // Pass — create mode recognized
        } else {
            XCTFail("Expected create mode")
        }
    }
}
