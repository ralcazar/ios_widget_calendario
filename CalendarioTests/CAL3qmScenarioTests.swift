import XCTest
import EventKit
@testable import Calendario

final class CAL3qmScenarioTests: XCTestCase {

    // MARK: - Helpers

    private func makeEngine(startH: Double = 8, endH: Double = 20) -> TimelineLayoutEngine {
        TimelineLayoutEngine(workStart: startH * 3600, workEnd: endH * 3600)
    }

    private func midnight(year: Int = 2026, month: Int = 3, day: Int = 27) -> Date {
        var comps = DateComponents()
        comps.year = year; comps.month = month; comps.day = day
        comps.hour = 0; comps.minute = 0; comps.second = 0
        return Calendar.current.date(from: comps)!
    }

    private func dateAt(hour: Double, base: Date) -> Date {
        base.addingTimeInterval(hour * 3600)
    }

    // MARK: - yFraction

    func test_CAL3qm_given_eventAtWorkStart_when_yFraction_then_zero() {
        let engine = makeEngine()
        let base = midnight()
        let date = dateAt(hour: 8, base: base)
        XCTAssertEqual(engine.yFraction(for: date, relativeTo: base), 0.0, accuracy: 0.001)
    }

    func test_CAL3qm_given_eventAtWorkEnd_when_yFraction_then_one() {
        let engine = makeEngine()
        let base = midnight()
        let date = dateAt(hour: 20, base: base)
        XCTAssertEqual(engine.yFraction(for: date, relativeTo: base), 1.0, accuracy: 0.001)
    }

    func test_CAL3qm_given_eventAtMidday_when_yFraction_then_oneThird() {
        // 8–20 window → 12 h total. 12:00 is 4 h in → 4/12 = 1/3
        let engine = makeEngine()
        let base = midnight()
        let date = dateAt(hour: 12, base: base)
        XCTAssertEqual(engine.yFraction(for: date, relativeTo: base), 1.0/3.0, accuracy: 0.001)
    }

    func test_CAL3qm_given_eventBeforeWorkStart_when_yFraction_then_clampsToZero() {
        let engine = makeEngine()
        let base = midnight()
        let date = dateAt(hour: 6, base: base)
        XCTAssertEqual(engine.yFraction(for: date, relativeTo: base), 0.0, accuracy: 0.001)
    }

    func test_CAL3qm_given_eventAfterWorkEnd_when_yFraction_then_clampsToOne() {
        let engine = makeEngine()
        let base = midnight()
        let date = dateAt(hour: 22, base: base)
        XCTAssertEqual(engine.yFraction(for: date, relativeTo: base), 1.0, accuracy: 0.001)
    }

    // MARK: - Default work hours fallback

    func test_CAL3qm_given_minusOneOffsets_when_effectiveHours_then_defaults8to20() {
        let engine = TimelineLayoutEngine(workStart: -1, workEnd: -1)
        XCTAssertEqual(engine.effectiveStart, 8 * 3600, accuracy: 0.001)
        XCTAssertEqual(engine.effectiveEnd,  20 * 3600, accuracy: 0.001)
    }

    func test_CAL3qm_given_customOffsets_when_effectiveHours_then_usesCustom() {
        let engine = TimelineLayoutEngine(workStart: 9 * 3600, workEnd: 18 * 3600)
        XCTAssertEqual(engine.effectiveStart, 9  * 3600, accuracy: 0.001)
        XCTAssertEqual(engine.effectiveEnd,   18 * 3600, accuracy: 0.001)
    }

    // MARK: - heightFraction

    func test_CAL3qm_given_oneHourEvent_when_heightFraction_then_onetwelfth() {
        // In 8–20 (12 h total) a 1-hour event occupies 1/12
        let engine = makeEngine()
        let base = midnight()
        let start = dateAt(hour: 10, base: base)
        let end   = dateAt(hour: 11, base: base)
        XCTAssertEqual(engine.heightFraction(startDate: start, endDate: end, relativeTo: base), 1.0/12.0, accuracy: 0.001)
    }

    func test_CAL3qm_given_twoHourEvent_when_heightFraction_then_onesixth() {
        let engine = makeEngine()
        let base = midnight()
        let start = dateAt(hour: 9, base: base)
        let end   = dateAt(hour: 11, base: base)
        XCTAssertEqual(engine.heightFraction(startDate: start, endDate: end, relativeTo: base), 2.0/12.0, accuracy: 0.001)
    }

    func test_CAL3qm_given_eventPartiallyBeforeWindow_when_heightFraction_then_clampsCorrectly() {
        // Event from 6:00 to 10:00, window 8:00-20:00 → visible 8:00-10:00 = 2h out of 12h
        let engine = makeEngine()
        let base = midnight()
        let start = dateAt(hour: 6, base: base)
        let end   = dateAt(hour: 10, base: base)
        XCTAssertEqual(engine.heightFraction(startDate: start, endDate: end, relativeTo: base), 2.0/12.0, accuracy: 0.001)
    }

    func test_CAL3qm_given_eventOutsideWindow_when_heightFraction_then_zero() {
        let engine = makeEngine()
        let base = midnight()
        let start = dateAt(hour: 21, base: base)
        let end   = dateAt(hour: 22, base: base)
        XCTAssertEqual(engine.heightFraction(startDate: start, endDate: end, relativeTo: base), 0.0, accuracy: 0.001)
    }

    // MARK: - Column layout

    func test_CAL3qm_given_nonOverlappingEvents_when_layoutColumns_then_singleColumn() {
        let engine = makeEngine()
        let base = midnight()
        let e1 = makeEvent(start: dateAt(hour: 9, base: base), end: dateAt(hour: 10, base: base))
        let e2 = makeEvent(start: dateAt(hour: 11, base: base), end: dateAt(hour: 12, base: base))
        let items: [(event: EKEvent, matchedColor: String?)] = [(e1, nil), (e2, nil)]
        let result = engine.layoutColumns(for: items)
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].column, 0)
        XCTAssertEqual(result[0].totalColumns, 1)
        XCTAssertEqual(result[1].column, 0)
        XCTAssertEqual(result[1].totalColumns, 1)
    }

    func test_CAL3qm_given_twoOverlappingEvents_when_layoutColumns_then_twoColumns() {
        let engine = makeEngine()
        let base = midnight()
        let e1 = makeEvent(start: dateAt(hour: 9,  base: base), end: dateAt(hour: 11, base: base))
        let e2 = makeEvent(start: dateAt(hour: 10, base: base), end: dateAt(hour: 12, base: base))
        let items: [(event: EKEvent, matchedColor: String?)] = [(e1, nil), (e2, nil)]
        let result = engine.layoutColumns(for: items)
        XCTAssertEqual(result.count, 2)
        let columns = Set(result.map(\.column))
        XCTAssertEqual(columns, [0, 1])
        XCTAssertTrue(result.allSatisfy { $0.totalColumns == 2 })
    }

    func test_CAL3qm_given_threeOverlappingEvents_when_layoutColumns_then_threeColumns() {
        let engine = makeEngine()
        let base = midnight()
        let e1 = makeEvent(start: dateAt(hour: 9,  base: base), end: dateAt(hour: 11, base: base))
        let e2 = makeEvent(start: dateAt(hour: 9,  base: base), end: dateAt(hour: 11, base: base))
        let e3 = makeEvent(start: dateAt(hour: 9,  base: base), end: dateAt(hour: 11, base: base))
        let items: [(event: EKEvent, matchedColor: String?)] = [(e1, nil), (e2, nil), (e3, nil)]
        let result = engine.layoutColumns(for: items)
        XCTAssertEqual(result.count, 3)
        let columns = Set(result.map(\.column))
        XCTAssertEqual(columns, [0, 1, 2])
        XCTAssertTrue(result.allSatisfy { $0.totalColumns == 3 })
    }

    func test_CAL3qm_given_emptyEvents_when_layoutColumns_then_emptyResult() {
        let engine = makeEngine()
        let items: [(event: EKEvent, matchedColor: String?)] = []
        let result = engine.layoutColumns(for: items)
        XCTAssertTrue(result.isEmpty)
    }

    // MARK: - Hour labels

    func test_CAL3qm_given_8to20window_when_hourLabelsStep1_then_containsAllHours() {
        let engine = makeEngine()
        let labels = engine.hourLabels(step: 1)
        XCTAssertTrue(labels.contains(8))
        XCTAssertTrue(labels.contains(12))
        XCTAssertTrue(labels.contains(20))
    }

    func test_CAL3qm_given_8to20window_when_hourLabelsStep2_then_evenHoursOnly() {
        let engine = makeEngine()
        let labels = engine.hourLabels(step: 2)
        XCTAssertTrue(labels.contains(8))
        XCTAssertTrue(labels.contains(10))
        XCTAssertFalse(labels.contains(9))
    }

    // MARK: - Fake EKEvent helper

    private func makeEvent(start: Date, end: Date) -> EKEvent {
        let store = EKEventStore()
        let event = EKEvent(eventStore: store)
        event.startDate = start
        event.endDate = end
        event.title = "Test Event"
        return event
    }
}
