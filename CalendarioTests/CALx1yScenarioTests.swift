import XCTest
@testable import Calendario

final class CALx1yScenarioTests: XCTestCase {

    // MARK: - CAL-x1y: Al pulsar evento abrir app Calendario del sistema centrada en el evento

    func test_CALx1y_given_eventWithStartDate_when_calendarURLGenerated_then_usesCalshowScheme() {
        // Given
        let date = Date(timeIntervalSinceReferenceDate: 700000000)
        // When
        let url = CalendarURL.forDate(date)
        // Then
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.scheme, "calshow")
    }

    func test_CALx1y_given_eventWithStartDate_when_calendarURLGenerated_then_timestampMatchesStartDate() {
        // Given
        let date = Date(timeIntervalSinceReferenceDate: 700000000)
        // When
        let url = CalendarURL.forDate(date)
        // Then
        let expectedTimestamp = Int(date.timeIntervalSinceReferenceDate)
        XCTAssertEqual(url?.absoluteString, "calshow:\(expectedTimestamp)")
    }

    func test_CALx1y_given_allDayEvent_when_calendarURLGenerated_then_urlPointsToCorrectDate() {
        // Given — an all-day event date (start of day)
        let calendar = Calendar.current
        let components = DateComponents(year: 2026, month: 3, day: 27)
        let allDayDate = calendar.date(from: components)!
        // When
        let url = CalendarURL.forDate(allDayDate)
        // Then
        XCTAssertNotNil(url)
        let timestamp = Int(allDayDate.timeIntervalSinceReferenceDate)
        XCTAssertEqual(url?.absoluteString, "calshow:\(timestamp)")
    }

    func test_CALx1y_given_calendarURL_when_generated_then_returnsValidURL() {
        // Given
        let date = Date()
        // When
        let url = CalendarURL.forDate(date)
        // Then
        XCTAssertNotNil(url)
        XCTAssertTrue(url!.absoluteString.hasPrefix("calshow:"))
    }
}
