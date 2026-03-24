import XCTest
@testable import Calendario

final class CALsue1ScenarioTests: XCTestCase {

    // MARK: - CAL-sue.1: Crear proyecto Xcode con targets + configurar App Group

    func test_CALsue1_given_appGroupIdentifier_when_accessingDefaults_then_userDefaultsIsNotNil() {
        // Given
        let suiteName = AppGroup.identifier

        // When
        let defaults = UserDefaults(suiteName: suiteName)

        // Then
        XCTAssertNotNil(defaults, "UserDefaults with App Group suite name must not be nil")
    }

    func test_CALsue1_given_appGroupDefaults_when_writingAndReadingValue_then_valueRoundtrips() {
        // Given
        let key = "ping"
        let value = "test"

        // When
        AppGroup.defaults.set(value, forKey: key)
        AppGroup.defaults.synchronize()
        let result = AppGroup.defaults.string(forKey: key)

        // Then
        XCTAssertEqual(result, value, "Value written to AppGroup.defaults must be readable back")

        // Cleanup
        AppGroup.defaults.removeObject(forKey: key)
    }

    func test_CALsue1_given_appGroupIdentifier_when_checkingFormat_then_matchesExpected() {
        // Given / When / Then
        XCTAssertEqual(
            AppGroup.identifier,
            "group.com.ralcazar.calendario",
            "App Group identifier must be 'group.com.ralcazar.calendario'"
        )
    }

    func test_CALsue1_given_appGroupDefaults_when_settingMultipleValues_then_allValuesReadable() {
        // Given
        let testData: [String: String] = [
            "key1": "value1",
            "key2": "value2",
            "key3": "value3"
        ]

        // When
        testData.forEach { AppGroup.defaults.set($0.value, forKey: $0.key) }
        AppGroup.defaults.synchronize()

        // Then
        testData.forEach { pair in
            XCTAssertEqual(
                AppGroup.defaults.string(forKey: pair.key),
                pair.value,
                "Key '\(pair.key)' must return '\(pair.value)'"
            )
        }

        // Cleanup
        testData.keys.forEach { AppGroup.defaults.removeObject(forKey: $0) }
    }
}
