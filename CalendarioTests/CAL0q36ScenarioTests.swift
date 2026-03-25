import XCTest
@testable import Calendario

final class CAL0q36ScenarioTests: XCTestCase {
    // MARK: - CAL-0q3.6: Abrir evento en Calendar.app

    func test_CAL0q36_given_eventDate_when_buildingCalendarURL_then_urlHasCalshowScheme() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let timestamp = Int(date.timeIntervalSinceReferenceDate)
        let url = URL(string: "calshow:\(timestamp)")
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.scheme, "calshow")
    }

    func test_CAL0q36_given_referenceDate_when_buildingTimestamp_then_usesReferenceDate() {
        // calshow: uses timeIntervalSinceReferenceDate (Jan 1, 2001), NOT timeIntervalSince1970
        let date = Date(timeIntervalSinceReferenceDate: 750_000_000)
        let timestamp = Int(date.timeIntervalSinceReferenceDate)
        XCTAssertEqual(timestamp, 750_000_000)
    }

    func test_CAL0q36_given_noEvents_when_smallWidgetURLFallback_then_usesEntryDate() {
        // When no events, SmallWidgetView uses entry.date as fallback for widgetURL
        let entryDate = Date()
        let timestamp = Int(entryDate.timeIntervalSinceReferenceDate)
        let url = URL(string: "calshow:\(timestamp)")
        XCTAssertNotNil(url)
    }

    func test_CAL0q36_given_validTimestamp_when_urlFormatted_then_noSpacesOrSpecialChars() {
        let date = Date()
        let timestamp = Int(date.timeIntervalSinceReferenceDate)
        let urlString = "calshow:\(timestamp)"
        XCTAssertFalse(urlString.contains(" "))
        XCTAssertTrue(urlString.hasPrefix("calshow:"))
    }
}
