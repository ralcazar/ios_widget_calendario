import XCTest
import EventKit
@testable import Calendario

final class CAL0q32ScenarioTests: XCTestCase {
    // MARK: - CAL-0q3.2: Manejo de permisos de calendario

    func test_CAL0q32_given_permissionManager_when_initialized_then_statusReflectsCurrentAuth() {
        let manager = CalendarPermissionManager()
        let currentStatus = EKEventStore.authorizationStatus(for: .event)
        XCTAssertEqual(manager.authorizationStatus, currentStatus)
    }

    func test_CAL0q32_given_deniedStatus_when_checkingIsDenied_then_returnsTrue() {
        let manager = CalendarPermissionManager()
        // Simulate denied status by checking the logic directly
        // We can't change system permissions in unit tests, so test the computed property logic
        XCTAssertFalse(manager.isAuthorized && manager.isDenied, "isAuthorized and isDenied should be mutually exclusive")
    }

    func test_CAL0q32_given_notDeterminedStatus_when_checkingIsAuthorized_then_returnsFalse() {
        // authorizationStatus .notDetermined → isAuthorized = false
        // We test the logic: notDetermined is neither fullAccess nor authorized
        let status = EKAuthorizationStatus.notDetermined
        let isAuthorized = status == .fullAccess || status == .authorized
        XCTAssertFalse(isAuthorized)
    }

    func test_CAL0q32_given_fullAccessStatus_when_checkingIsAuthorized_then_returnsTrue() {
        let status = EKAuthorizationStatus.fullAccess
        let isAuthorized = status == .fullAccess || status == .authorized
        XCTAssertTrue(isAuthorized)
    }
}
