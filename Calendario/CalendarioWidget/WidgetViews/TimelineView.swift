import SwiftUI
import EventKit

struct TimelineView: View {
    let events: [(event: EKEvent, matchedColor: String?)]
    let workStart: TimeInterval   // seconds from midnight, -1 = default
    let workEnd: TimeInterval     // seconds from midnight, -1 = default
    let now: Date
    let compact: Bool

    private var engine: TimelineLayoutEngine {
        TimelineLayoutEngine(workStart: workStart, workEnd: workEnd)
    }
    private var midnight: Date { Calendar.current.startOfDay(for: now) }

    private var allDayEvents: [(event: EKEvent, matchedColor: String?)] {
        events.filter { $0.event.isAllDay }
    }

    private var timedEvents: [(event: EKEvent, matchedColor: String?)] {
        events.filter { item in
            guard !item.event.isAllDay,
                  let start = item.event.startDate,
                  let end = item.event.endDate else { return false }
            let base = midnight
            let startSecs = start.timeIntervalSince(base)
            let endSecs   = end.timeIntervalSince(base)
            return startSecs < engine.effectiveEnd && endSecs > engine.effectiveStart
        }
    }

    private var nowFraction: CGFloat? {
        let nowSecs = now.timeIntervalSince(midnight)
        guard nowSecs >= engine.effectiveStart && nowSecs <= engine.effectiveEnd else { return nil }
        return engine.yFraction(for: now, relativeTo: midnight)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // All-day strip
            if !allDayEvents.isEmpty {
                allDayStrip
            }

            if timedEvents.isEmpty && allDayEvents.isEmpty {
                Text(String(localized: "Sin eventos hoy"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .accessibilityIdentifier("noEventsTimeline")
            } else if !timedEvents.isEmpty {
                timelineCanvas
            }
        }
    }

    // MARK: - All-day strip

    private var allDayStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(allDayEvents, id: \.event.eventIdentifier) { item in
                    Text(item.event.title ?? "")
                        .font(.system(size: 9, weight: .medium))
                        .lineLimit(1)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(
                            (item.matchedColor.flatMap { Color(hex: $0) } ??
                             Color(cgColor: item.event.calendar.cgColor))
                            .opacity(0.25)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                }
            }
        }
        .accessibilityIdentifier("allDayStrip")
    }

    // MARK: - Timeline canvas

    private var timelineCanvas: some View {
        GeometryReader { geo in
            let labelW: CGFloat = compact ? 28 : 34
            let blockAreaW = geo.size.width - labelW
            let totalH = geo.size.height
            let hourStep = compact ? 2 : 1
            let layout = engine.layoutColumns(for: timedEvents)

            ZStack(alignment: .topLeading) {
                // Hour grid lines + labels
                ForEach(engine.hourLabels(step: hourStep), id: \.self) { hour in
                    let fraction = engine.yFraction(
                        for: midnight.addingTimeInterval(TimeInterval(hour) * 3600),
                        relativeTo: midnight
                    )
                    let y = fraction * totalH

                    // Dotted line
                    Path { p in
                        p.move(to: CGPoint(x: labelW, y: y))
                        p.addLine(to: CGPoint(x: geo.size.width, y: y))
                    }
                    .stroke(Color.secondary.opacity(0.25), style: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))

                    // Hour label
                    Text(hourLabel(hour))
                        .font(.system(size: compact ? 8 : 9))
                        .foregroundColor(.secondary)
                        .frame(width: labelW - 2, alignment: .trailing)
                        .offset(y: y - (compact ? 5 : 6))
                }

                // Event blocks
                ForEach(layout, id: \.event.eventIdentifier) { item in
                    let start = item.event.startDate ?? midnight
                    let end   = item.event.endDate ?? start.addingTimeInterval(3600)
                    let yFrac  = engine.yFraction(for: start, relativeTo: midnight)
                    let hFrac  = engine.heightFraction(startDate: start, endDate: end, relativeTo: midnight)
                    let minH: CGFloat = 16
                    let computedH = hFrac * totalH
                    let blockH = max(computedH, minH)
                    let colW = blockAreaW / CGFloat(item.totalColumns)
                    let xOffset = labelW + colW * CGFloat(item.column)

                    TimelineEventBlock(
                        event: item.event,
                        matchedColor: item.matchedColor,
                        compact: compact
                    )
                    .frame(width: colW - 2, height: blockH)
                    .offset(x: xOffset, y: yFrac * totalH)
                }

                // "Now" line
                if let fraction = nowFraction {
                    Path { p in
                        p.move(to: CGPoint(x: labelW, y: fraction * totalH))
                        p.addLine(to: CGPoint(x: geo.size.width, y: fraction * totalH))
                    }
                    .stroke(Color.orange, lineWidth: 1.5)
                    .accessibilityIdentifier("nowLine")

                    Circle()
                        .fill(Color.orange)
                        .frame(width: 5, height: 5)
                        .offset(x: labelW - 3, y: fraction * totalH - 2.5)
                }
            }
        }
    }

    // MARK: - Helpers

    private func hourLabel(_ hour: Int) -> String {
        let h = hour % 12 == 0 ? 12 : hour % 12
        return "\(h)"
    }
}
