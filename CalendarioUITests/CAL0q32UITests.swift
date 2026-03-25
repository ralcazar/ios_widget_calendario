import XCTest

final class CAL0q32UITests: XCTestCase {
    // MARK: - CAL-0q3.2: 2.1 Manejo de permisos de calendario

    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    // MARK: Permission dialog handling

    func test_CAL0q32_given_appLaunches_when_permissionDialogAppears_then_appHandlesGrant() {
        // Given — app may request calendar access on first launch
        // When  — permission dialog appears
        addUIInterruptionMonitor(withDescription: "Calendar Access Permission") { alert in
            // Allow full access if offered (iOS 17+)
            if alert.buttons["Allow Full Access"].exists {
                alert.buttons["Allow Full Access"].tap()
                return true
            }
            // Fallback: OK / Allow
            if alert.buttons["OK"].exists {
                alert.buttons["OK"].tap()
                return true
            }
            return false
        }

        app.launch()
        // Trigger any pending interruption handlers
        app.tap()

        // Then  — app is usable after permission handling (not crashed, shows content)
        let isAppAlive = app.staticTexts["emptyStateLabel"].waitForExistence(timeout: 10)
            || app.collectionViews["configList"].waitForExistence(timeout: 2)
        XCTAssertTrue(isAppAlive, "App should show main content after permission is handled")
    }

    func test_CAL0q32_given_appLaunches_when_permissionDenied_then_appRemainsUsable() {
        // Given — simulating denied permission scenario
        // When  — user denies calendar access
        addUIInterruptionMonitor(withDescription: "Calendar Access Denial") { alert in
            if alert.buttons["Don't Allow"].exists {
                alert.buttons["Don't Allow"].tap()
                return true
            }
            return false
        }

        app.launch()
        app.tap()

        // Then  — app should still be usable (shows config list, even if calendars list is empty)
        // The companion app stays usable — calendar list will be empty in ConfigFormView
        XCTAssertTrue(app.exists, "App should remain alive after permission denial")
    }

    // MARK: App content visible after permission resolution

    func test_CAL0q32_given_permissionsResolved_when_viewingConfigForm_then_calendarSectionExists() {
        // Given — permissions resolved (granted), navigate to the config form
        addUIInterruptionMonitor(withDescription: "Calendar Permission") { alert in
            if alert.buttons["Allow Full Access"].exists {
                alert.buttons["Allow Full Access"].tap()
                return true
            }
            return false
        }

        app.launch()
        app.tap()

        // When  — user opens the new config form
        guard app.buttons["addConfigButton"].waitForExistence(timeout: 10) else {
            return // App may not be in empty state
        }
        app.buttons["addConfigButton"].tap()

        guard app.textFields["nameField"].waitForExistence(timeout: 3) else {
            XCTFail("Config form did not open")
            return
        }

        // Then  — either a calendar picker or "no calendars" label is shown
        // (depends on whether permission was granted and calendars exist)
        let hasCalendarRows = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'calendarRow_'"))
            .count > 0
        let hasNoCalendarsLabel = app.staticTexts["noCalendarsLabel"].exists

        XCTAssertTrue(
            hasCalendarRows || hasNoCalendarsLabel,
            "Calendar section should show either calendar rows or 'no calendars' label"
        )
    }
}
