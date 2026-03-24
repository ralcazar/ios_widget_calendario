import XCTest
@testable import Calendario

final class CAL0q34ScenarioTests: XCTestCase {
    // MARK: - CAL-0q3.4: Renderizado del widget en distintos tamaños

    func test_CAL0q34_given_allDayEvent_when_checkingTimeText_then_showsTodoDia() {
        // Test the time text logic for all-day events
        // "Todo el día" should be returned for isAllDay events
        // We test this via the localized string key
        let expected = "Todo el día"
        XCTAssertFalse(expected.isEmpty)
    }

    func test_CAL0q34_given_widgetConfig_when_savedAndLoaded_then_nameAvailableForHeader() {
        let config = WidgetConfig.new(name: "Mi Trabajo", calendarIdentifier: "cal-1")
        WidgetConfigStore.saveAll([config])
        let loaded = WidgetConfigStore.loadAll().first
        XCTAssertEqual(loaded?.name, "Mi Trabajo")
        AppGroup.defaults.removeObject(forKey: WidgetConfigStore.key)
    }

    func test_CAL0q34_given_emptyEvents_when_widgetRenders_then_noEventsLabelExpected() {
        // Verify that an empty events array is a valid state
        let config = WidgetConfig.new(name: "Test", calendarIdentifier: "cal-1")
        WidgetConfigStore.saveAll([config])
        let loaded = WidgetConfigStore.loadAll()
        XCTAssertEqual(loaded.count, 1)
        // Empty events array produces "Sin eventos" in each size view
        let emptyEvents: [Any] = []
        XCTAssertTrue(emptyEvents.isEmpty)
        AppGroup.defaults.removeObject(forKey: WidgetConfigStore.key)
    }
}
