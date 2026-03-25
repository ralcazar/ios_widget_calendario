import XCTest
@testable import Calendario

final class CALu914ScenarioTests: XCTestCase {

    private let key = "onboardingCompleted"

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: key)
    }

    override func tearDown() {
        super.tearDown()
        UserDefaults.standard.removeObject(forKey: key)
    }

    // MARK: - Scenarios

    func test_CALu914_given_onboardingCompletedNotSet_when_checkingFlag_then_defaultsToFalse() {
        // Given: key not in UserDefaults
        // When: reading the bool value
        let shouldShowOnboarding = !UserDefaults.standard.bool(forKey: key)
        // Then: onboarding should show (bool defaults to false → !false = true)
        XCTAssertTrue(shouldShowOnboarding, "Onboarding should appear when flag is not set")
    }

    func test_CALu914_given_onboardingCompletedIsTrue_when_checkingFlag_then_onboardingDoesNotShow() {
        // Given: onboardingCompleted = true
        UserDefaults.standard.set(true, forKey: key)
        // When: checking whether to show onboarding
        let shouldShowOnboarding = !UserDefaults.standard.bool(forKey: key)
        // Then: onboarding should NOT show
        XCTAssertFalse(shouldShowOnboarding, "Onboarding should not appear when flag is true")
    }

    func test_CALu914_given_onboardingCompleted_when_settingTrueInUserDefaults_then_persistsCorrectly() {
        // Given: onboarding was just completed
        // When: saving the flag
        UserDefaults.standard.set(true, forKey: key)
        // Then: value persists
        XCTAssertTrue(UserDefaults.standard.bool(forKey: key), "onboardingCompleted should be persisted as true")
    }

    func test_CALu914_given_onboardingCompletedTrue_when_removingObject_then_defaultsToFalseAgain() {
        // Given: flag was set
        UserDefaults.standard.set(true, forKey: key)
        XCTAssertTrue(UserDefaults.standard.bool(forKey: key))
        // When: removing the key
        UserDefaults.standard.removeObject(forKey: key)
        // Then: defaults back to false → onboarding would show again
        XCTAssertFalse(UserDefaults.standard.bool(forKey: key), "After removing key, bool should default to false")
        let shouldShowOnboarding = !UserDefaults.standard.bool(forKey: key)
        XCTAssertTrue(shouldShowOnboarding, "Onboarding should show again after key removal")
    }
}
