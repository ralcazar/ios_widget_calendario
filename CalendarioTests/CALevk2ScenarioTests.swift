import XCTest
import SwiftUI
@testable import Calendario

final class CALevk2ScenarioTests: XCTestCase {

    // MARK: - Color(hex:) tests

    func test_CALevk2_given_validHexWithHash_when_initColor_then_returnsNonNil() {
        // Given/When
        let color = Color(hex: "#FF3B30")
        // Then
        XCTAssertNotNil(color)
    }

    func test_CALevk2_given_invalidHex_when_initColor_then_returnsNil() {
        // Given/When
        let color = Color(hex: "ZZZZZZ")
        // Then
        XCTAssertNil(color)
    }

    func test_CALevk2_given_hexWithoutHash_when_initColor_then_returnsNonNil() {
        // Given/When
        let color = Color(hex: "FF3B30")
        // Then
        XCTAssertNotNil(color)
    }

    func test_CALevk2_given_threeCharHex_when_initColor_then_returnsNil() {
        // Given/When
        let color = Color(hex: "#F30")
        // Then
        XCTAssertNil(color)
    }

    func test_CALevk2_given_redHex_when_initColor_then_returnsNonNil() {
        // Given/When
        let colorP0 = Color(hex: "#FF0000")
        let colorP1 = Color(hex: "#0000FF")
        // Then
        XCTAssertNotNil(colorP0, "Priority 0 color must be non-nil")
        XCTAssertNotNil(colorP1, "Priority 1 color must be non-nil")
    }

    func test_CALevk2_given_emptyString_when_initColor_then_returnsNil() {
        // Given/When
        let color = Color(hex: "")
        // Then
        XCTAssertNil(color)
    }

    func test_CALevk2_given_whitespacePaddedHex_when_initColor_then_returnsNonNil() {
        // Given/When
        let color = Color(hex: "  #FF3B30  ")
        // Then
        XCTAssertNotNil(color)
    }
}
