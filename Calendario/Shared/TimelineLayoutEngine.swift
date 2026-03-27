import Foundation
import EventKit

/// Pure layout calculation engine for the timeline widget view.
/// Stateless — all methods are free of side effects so they can be unit-tested directly.
struct TimelineLayoutEngine {

    let workStart: TimeInterval  // seconds from midnight (-1 → default 8 h)
    let workEnd: TimeInterval    // seconds from midnight (-1 → default 20 h)

    var effectiveStart: TimeInterval { workStart >= 0 ? workStart : 8 * 3600 }
    var effectiveEnd: TimeInterval   { workEnd   >= 0 ? workEnd   : 20 * 3600 }
    var totalDuration: TimeInterval  { effectiveEnd - effectiveStart }

    // MARK: - Y/Height fractions

    /// Returns the fraction [0, 1] within the work-hours window for a given date.
    func yFraction(for date: Date, relativeTo midnight: Date) -> CGFloat {
        let secs = date.timeIntervalSince(midnight)
        let clamped = min(max(secs, effectiveStart), effectiveEnd)
        guard totalDuration > 0 else { return 0 }
        return CGFloat((clamped - effectiveStart) / totalDuration)
    }

    /// Returns the height fraction [0, 1] for an event that spans [startDate, endDate],
    /// clamped to the visible work-hours window.
    func heightFraction(startDate: Date, endDate: Date, relativeTo midnight: Date) -> CGFloat {
        let startSecs = startDate.timeIntervalSince(midnight)
        let endSecs   = endDate.timeIntervalSince(midnight)
        let clampedStart = max(startSecs, effectiveStart)
        let clampedEnd   = min(endSecs,   effectiveEnd)
        guard totalDuration > 0 && clampedEnd > clampedStart else { return 0 }
        return CGFloat((clampedEnd - clampedStart) / totalDuration)
    }

    // MARK: - Column layout

    struct ColumnItem {
        let event: EKEvent
        let matchedColor: String?
        let column: Int
        let totalColumns: Int
    }

    /// Assigns each event to a column using a greedy sweep-line algorithm.
    /// Events that overlap horizontally are placed side-by-side.
    func layoutColumns(
        for events: [(event: EKEvent, matchedColor: String?)]
    ) -> [ColumnItem] {
        // Sort by start date
        let sorted = events.sorted { a, b in
            (a.event.startDate ?? .distantPast) < (b.event.startDate ?? .distantPast)
        }

        // Tracks the end-time of the latest event in each active column
        var columnEnds: [Date] = []
        var assigned: [(item: (event: EKEvent, matchedColor: String?), column: Int)] = []

        for item in sorted {
            let start = item.event.startDate ?? .distantPast
            // Find the first column whose end is <= this event's start
            if let col = columnEnds.enumerated().first(where: { $0.element <= start })?.offset {
                columnEnds[col] = item.event.endDate ?? start
                assigned.append((item, col))
            } else {
                // Open a new column
                let col = columnEnds.count
                columnEnds.append(item.event.endDate ?? start)
                assigned.append((item, col))
            }
        }

        let totalColumns = columnEnds.count

        return assigned.map { pair in
            ColumnItem(
                event: pair.item.event,
                matchedColor: pair.item.matchedColor,
                column: pair.column,
                totalColumns: totalColumns
            )
        }
    }

    // MARK: - Helpers

    /// Integer hour labels that should be drawn within the work-hours window.
    /// `step` controls spacing: 1 for large widget, 2 for compact.
    func hourLabels(step: Int = 1) -> [Int] {
        let firstHour = Int(ceil(effectiveStart / 3600))
        let lastHour  = Int(floor(effectiveEnd  / 3600))
        return stride(from: firstHour, through: lastHour, by: step).map { $0 }
    }
}
