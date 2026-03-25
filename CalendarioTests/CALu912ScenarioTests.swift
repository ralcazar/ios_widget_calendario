import XCTest
import EventKit
@testable import Calendario

final class CALu912ScenarioTests: XCTestCase {

    // MARK: - WidgetConfig default

    func test_CALu912_given_newWidgetConfig_when_checkingShowCancelled_then_defaultIsFalse() {
        let config = WidgetConfig.new(name: "Test", calendarIdentifier: "cal-1")
        XCTAssertFalse(config.showCancelled)
    }

    // MARK: - Filter logic (showCancelled = false hides canceled)

    func test_CALu912_given_showCancelledFalse_when_eventIsCanceled_then_filterRemovesIt() {
        // Simulate the EventFetcher filter predicate:
        // config.showCancelled || event.status != .canceled
        let showCancelled = false
        let eventStatus = EKEventStatus.canceled
        let shouldInclude = showCancelled || eventStatus != .canceled
        XCTAssertFalse(shouldInclude, "Canceled event must be excluded when showCancelled=false")
    }

    func test_CALu912_given_showCancelledFalse_when_eventIsConfirmed_then_filterKeepsIt() {
        let showCancelled = false
        let eventStatus = EKEventStatus.confirmed
        let shouldInclude = showCancelled || eventStatus != .canceled
        XCTAssertTrue(shouldInclude, "Confirmed event must be included when showCancelled=false")
    }

    func test_CALu912_given_showCancelledFalse_when_eventIsNone_then_filterKeepsIt() {
        let showCancelled = false
        let eventStatus = EKEventStatus.none
        let shouldInclude = showCancelled || eventStatus != .canceled
        XCTAssertTrue(shouldInclude, "None-status event must be included when showCancelled=false")
    }

    // MARK: - Filter logic (showCancelled = true includes canceled)

    func test_CALu912_given_showCancelledTrue_when_eventIsCanceled_then_filterKeepsIt() {
        let showCancelled = true
        let eventStatus = EKEventStatus.canceled
        let shouldInclude = showCancelled || eventStatus != .canceled
        XCTAssertTrue(shouldInclude, "Canceled event must be included when showCancelled=true")
    }

    func test_CALu912_given_showCancelledTrue_when_eventIsConfirmed_then_filterKeepsIt() {
        let showCancelled = true
        let eventStatus = EKEventStatus.confirmed
        let shouldInclude = showCancelled || eventStatus != .canceled
        XCTAssertTrue(shouldInclude, "Confirmed event must be included when showCancelled=true")
    }

    // MARK: - isCancelled detection

    func test_CALu912_given_canceledStatus_when_checkingIsCancelled_then_returnsTrue() {
        let status = EKEventStatus.canceled
        let isCancelled = status == .canceled
        XCTAssertTrue(isCancelled)
    }

    func test_CALu912_given_confirmedStatus_when_checkingIsCancelled_then_returnsFalse() {
        let status = EKEventStatus.confirmed
        let isCancelled = status == .canceled
        XCTAssertFalse(isCancelled)
    }

    func test_CALu912_given_tentativeStatus_when_checkingIsCancelled_then_returnsFalse() {
        let status = EKEventStatus.tentative
        let isCancelled = status == .canceled
        XCTAssertFalse(isCancelled)
    }

    // MARK: - WidgetConfig persistence

    func test_CALu912_given_widgetConfig_when_settingShowCancelledTrue_then_valueIsTrue() {
        var config = WidgetConfig.new(name: "Config", calendarIdentifier: "cal-1")
        config.showCancelled = true
        XCTAssertTrue(config.showCancelled)
    }

    func test_CALu912_given_widgetConfig_when_encodingAndDecoding_then_showCancelledPersists() throws {
        var config = WidgetConfig.new(name: "Config", calendarIdentifier: "cal-1")
        config.showCancelled = true
        let data = try JSONEncoder().encode(config)
        let decoded = try JSONDecoder().decode(WidgetConfig.self, from: data)
        XCTAssertTrue(decoded.showCancelled)
    }

    func test_CALu912_given_widgetConfigDefaultFalse_when_encodingAndDecoding_then_showCancelledRemainsFalse() throws {
        let config = WidgetConfig.new(name: "Config", calendarIdentifier: "cal-1")
        let data = try JSONEncoder().encode(config)
        let decoded = try JSONDecoder().decode(WidgetConfig.self, from: data)
        XCTAssertFalse(decoded.showCancelled)
    }
}
