import XCTest
import SwiftUI
@testable import Calendario

final class CALu911ScenarioTests: XCTestCase {

    // MARK: - ColorPair.system

    func test_CALu911_given_systemColorPair_when_inspectingHex_then_bothHexAreEmpty() {
        let pair = ColorPair.system
        XCTAssertEqual(pair.lightHex, "")
        XCTAssertEqual(pair.darkHex, "")
    }

    // MARK: - backgroundColor logic (hex selection)

    func test_CALu911_given_systemColorPair_when_checkingEmpty_then_signalsSystemBackground() {
        let pair = ColorPair.system
        // Empty lightHex signals "use system background"
        XCTAssertTrue(pair.lightHex.isEmpty)
    }

    func test_CALu911_given_customColorPair_when_lightMode_then_lightHexUsed() {
        let pair = ColorPair(lightHex: "#FFFFFF", darkHex: "#000000")
        // Simulates the light-mode branch of backgroundColor
        let hex = pair.lightHex
        XCTAssertEqual(hex, "#FFFFFF")
        XCTAssertNotNil(Color(hex: hex))
    }

    func test_CALu911_given_customColorPair_when_darkMode_then_darkHexUsed() {
        let pair = ColorPair(lightHex: "#FFFFFF", darkHex: "#000000")
        // Simulates the dark-mode branch of backgroundColor
        let hex = pair.darkHex
        XCTAssertEqual(hex, "#000000")
        XCTAssertNotNil(Color(hex: hex))
    }

    // MARK: - Color.hexString round-trip

    func test_CALu911_given_hexColor_when_convertingToHexString_then_roundTrips() {
        let original = "#FF3B30"
        guard let color = Color(hex: original) else {
            XCTFail("Color(hex:) returned nil for \(original)")
            return
        }
        XCTAssertEqual(color.hexString, original)
    }

    func test_CALu911_given_whiteColor_when_convertingToHexString_then_returnsWhiteHex() {
        let color = Color(red: 1, green: 1, blue: 1)
        XCTAssertEqual(color.hexString, "#FFFFFF")
    }

    func test_CALu911_given_blackColor_when_convertingToHexString_then_returnsBlackHex() {
        let color = Color(red: 0, green: 0, blue: 0)
        XCTAssertEqual(color.hexString, "#000000")
    }

    // MARK: - Color(hex:) edge cases

    func test_CALu911_given_emptyString_when_initializingColorWithHex_then_returnsNil() {
        XCTAssertNil(Color(hex: ""))
    }

    func test_CALu911_given_invalidHex_when_initializingColor_then_returnsNil() {
        XCTAssertNil(Color(hex: "#ZZZZZZ"))
    }

    func test_CALu911_given_validHexWithHash_when_initializingColor_then_succeeds() {
        XCTAssertNotNil(Color(hex: "#FFFFFF"))
    }

    func test_CALu911_given_validHexWithoutHash_when_initializingColor_then_succeeds() {
        XCTAssertNotNil(Color(hex: "FFFFFF"))
    }
}
