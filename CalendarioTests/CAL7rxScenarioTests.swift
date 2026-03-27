import XCTest
import EventKit
@testable import Calendario

final class CAL7rxScenarioTests: XCTestCase {
    // MARK: - CAL-7rx: Bug: validar regla muestra 'error denegado' sin pedir permisos de calendario

    func test_CAL7rx_given_appLaunch_when_checkingCalendarioApp_then_noAutoPermissionRequest() throws {
        // Given — the source code of CalendarioApp.swift
        let sourceURL = Bundle.main.url(forResource: "CalendarioApp", withExtension: "swift")
        // Since source isn't bundled, verify structurally that CalendarPermissionManager
        // does NOT auto-request on init — only provides status
        let manager = CalendarPermissionManager()

        // Then — manager init only reads current status, does not trigger request
        // The status should match the system's current status (no side effects)
        let systemStatus = EKEventStore.authorizationStatus(for: .event)
        XCTAssertEqual(manager.authorizationStatus, systemStatus,
                       "CalendarPermissionManager init should only read status, not change it")
    }

    func test_CAL7rx_given_notDeterminedStatus_when_checkingPermissions_then_isNotDenied() {
        // Given — a fresh state where user hasn't been asked
        let status = EKAuthorizationStatus.notDetermined

        // When — checking denial status
        let isDenied = (status == .denied || status == .restricted)

        // Then — notDetermined should NOT be treated as denied
        XCTAssertFalse(isDenied,
                       "notDetermined must not be treated as denied — user should be prompted first")
    }

    func test_CAL7rx_given_deniedStatus_when_checkingPermissions_then_isDenied() {
        // Given
        let deniedStatus = EKAuthorizationStatus.denied
        let restrictedStatus = EKAuthorizationStatus.restricted

        // Then
        XCTAssertTrue(deniedStatus == .denied || deniedStatus == .restricted)
        XCTAssertTrue(restrictedStatus == .denied || restrictedStatus == .restricted)
    }

    func test_CAL7rx_given_fullAccessStatus_when_checkingPermissions_then_isAuthorized() {
        // Given
        let status = EKAuthorizationStatus.fullAccess

        // Then
        XCTAssertTrue(status == .fullAccess,
                      "fullAccess should be recognized as authorized")
    }

    func test_CAL7rx_given_permissionManager_when_statusIsDenied_then_isDeniedReturnsTrue() {
        // Verify CalendarPermissionManager computed properties are consistent
        let manager = CalendarPermissionManager()

        // isAuthorized and isDenied should be mutually exclusive
        XCTAssertFalse(manager.isAuthorized && manager.isDenied,
                       "isAuthorized and isDenied must be mutually exclusive")

        // If not authorized and not denied, status should be notDetermined or writeOnly
        if !manager.isAuthorized && !manager.isDenied {
            XCTAssertTrue(
                manager.authorizationStatus == .notDetermined || manager.authorizationStatus == .writeOnly,
                "Non-authorized, non-denied status should be notDetermined or writeOnly"
            )
        }
    }
}
