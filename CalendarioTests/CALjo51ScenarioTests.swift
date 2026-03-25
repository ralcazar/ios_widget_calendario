import XCTest

final class CALjo51ScenarioTests: XCTestCase {
    private let key = "dismissedEvents"
    private var defaults: UserDefaults { AppGroup.defaults }

    override func setUp() {
        super.setUp()
        defaults.removeObject(forKey: key)
    }

    override func tearDown() {
        defaults.removeObject(forKey: key)
        super.tearDown()
    }

    func test_CALjo51_given_event_when_dismissed_then_isDismissed_returns_true() {
        DismissedEventsStore.dismiss(eventIdentifier: "event-1")
        XCTAssertTrue(DismissedEventsStore.isDismissed("event-1"))
    }

    func test_CALjo51_given_unknown_event_when_checked_then_isDismissed_returns_false() {
        XCTAssertFalse(DismissedEventsStore.isDismissed("unknown-event"))
    }

    func test_CALjo51_given_yesterday_dismissed_when_cleanUp_then_entry_removed() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let dict: [String: Date] = ["event-yesterday": yesterday]
        guard let data = try? JSONEncoder().encode(dict) else {
            XCTFail("Failed to encode test data")
            return
        }
        defaults.set(data, forKey: key)

        DismissedEventsStore.cleanUpIfNeeded()

        XCTAssertFalse(DismissedEventsStore.isDismissed("event-yesterday"))
    }

    func test_CALjo51_given_today_dismissed_when_cleanUp_then_entry_kept() {
        DismissedEventsStore.dismiss(eventIdentifier: "event-today")
        DismissedEventsStore.cleanUpIfNeeded()
        XCTAssertTrue(DismissedEventsStore.isDismissed("event-today"))
    }
}
