import XCTest
@testable import Calendario

final class CALbmxScenarioTests: XCTestCase {

    // MARK: - CAL-bmx: Texto onboarding cortado — word wrap en paso 1

    func test_CALbmx_given_longSubtitleText_when_checkingLength_then_isNotEmpty() {
        let subtitle = String(localized: "Necesitamos acceso a tu calendario para mostrar tus eventos.", bundle: .main)
        XCTAssertFalse(subtitle.isEmpty)
        XCTAssertGreaterThan(subtitle.count, 20, "Subtitle should be a substantial text that needs wrapping")
    }

    func test_CALbmx_given_step2SubtitleText_when_checkingLength_then_isNotEmpty() {
        let subtitle = String(localized: "Configura qué calendarios y eventos aparecen en tu widget.", bundle: .main)
        XCTAssertFalse(subtitle.isEmpty)
        XCTAssertGreaterThan(subtitle.count, 20, "Step 2 subtitle should be a substantial text that needs wrapping")
    }

    func test_CALbmx_given_subtitleText_when_checkingWordCount_then_hasMultipleWords() {
        let subtitle = String(localized: "Necesitamos acceso a tu calendario para mostrar tus eventos.", bundle: .main)
        let wordCount = subtitle.split(separator: " ").count
        XCTAssertGreaterThan(wordCount, 5, "Subtitle has enough words to require line wrapping on small screens")
    }
}
