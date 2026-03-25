import XCTest
import EventKit
@testable import Calendario

final class CALu913ScenarioTests: XCTestCase {

    private let store = EKEventStore()

    private func makeEvent(start: Date, end: Date) -> EKEvent {
        let event = EKEvent(eventStore: store)
        event.startDate = start
        event.endDate = end
        return event
    }

    private func date(hour: Int, minute: Int = 0) -> Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 3
        components.day = 25
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components)!
    }

    // MARK: - Cluster detection

    func test_CALu913_given_twoOverlappingEvents_when_groupedByOverlap_then_oneClusterOfTwo() {
        let e1 = makeEvent(start: date(hour: 10), end: date(hour: 11))
        let e2 = makeEvent(start: date(hour: 10, minute: 30), end: date(hour: 11, minute: 30))
        let clusters = [e1, e2].groupedByOverlap()
        XCTAssertEqual(clusters.count, 1)
        XCTAssertEqual(clusters[0].count, 2)
    }

    func test_CALu913_given_twoNonOverlappingEvents_when_groupedByOverlap_then_twoClustersOfOne() {
        let e1 = makeEvent(start: date(hour: 10), end: date(hour: 11))
        let e2 = makeEvent(start: date(hour: 12), end: date(hour: 13))
        let clusters = [e1, e2].groupedByOverlap()
        XCTAssertEqual(clusters.count, 2)
        XCTAssertEqual(clusters[0].count, 1)
        XCTAssertEqual(clusters[1].count, 1)
    }

    func test_CALu913_given_threeEventsWhere1And2And2And3Overlap_when_groupedByOverlap_then_oneClusterOfThree() {
        // e1: 10:00-11:00, e2: 10:30-11:30, e3: 11:00-12:00
        // e1 and e2 overlap; e2 and e3 overlap (e3.start == e1.end but < e2.end)
        let e1 = makeEvent(start: date(hour: 10), end: date(hour: 11))
        let e2 = makeEvent(start: date(hour: 10, minute: 30), end: date(hour: 11, minute: 30))
        let e3 = makeEvent(start: date(hour: 11), end: date(hour: 12))
        let clusters = [e1, e2, e3].groupedByOverlap()
        XCTAssertEqual(clusters.count, 1)
        XCTAssertEqual(clusters[0].count, 3)
    }

    func test_CALu913_given_emptyArray_when_groupedByOverlap_then_emptyClusters() {
        let clusters = [EKEvent]().groupedByOverlap()
        XCTAssertTrue(clusters.isEmpty)
    }

    func test_CALu913_given_singleEvent_when_groupedByOverlap_then_oneClusterOfOne() {
        let e1 = makeEvent(start: date(hour: 10), end: date(hour: 11))
        let clusters = [e1].groupedByOverlap()
        XCTAssertEqual(clusters.count, 1)
        XCTAssertEqual(clusters[0].count, 1)
    }

    func test_CALu913_given_threeEventsWithFirstTwoOverlapping_when_groupedByOverlap_then_twoCluster() {
        // e1: 10:00-11:00, e2: 10:30-11:30, e3: 12:00-13:00
        let e1 = makeEvent(start: date(hour: 10), end: date(hour: 11))
        let e2 = makeEvent(start: date(hour: 10, minute: 30), end: date(hour: 11, minute: 30))
        let e3 = makeEvent(start: date(hour: 12), end: date(hour: 13))
        let clusters = [e1, e2, e3].groupedByOverlap()
        XCTAssertEqual(clusters.count, 2)
        XCTAssertEqual(clusters[0].count, 2, "First cluster should have 2 events (10:00 and 10:30)")
        XCTAssertEqual(clusters[1].count, 1, "Second cluster should have 1 event (12:00)")
    }

    func test_CALu913_given_eventWithNilEndDate_when_groupedByOverlap_then_treatedAsZeroDuration() {
        // All-day events have nil endDate — treated as zero-duration (endDate = startDate)
        let e1 = makeEvent(start: date(hour: 10), end: date(hour: 10))
        e1.endDate = nil
        let e2 = makeEvent(start: date(hour: 10, minute: 30), end: date(hour: 11, minute: 30))
        let clusters = [e1, e2].groupedByOverlap()
        // e1 has zero duration so it doesn't overlap with e2 (e2.start >= e1.end == e1.start)
        XCTAssertEqual(clusters.count, 2, "Zero-duration event should not overlap future events")
    }
}
