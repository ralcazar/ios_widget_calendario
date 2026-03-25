import SwiftUI
import EventKit
import WidgetKit

struct LargeWidgetView: View {
    let entry: CalendarEntry
    private let maxVisible = 8

    private var now: Date { entry.date }
    private var visibleItems: [(event: EKEvent, matchedColor: String?)] { Array(entry.events.prefix(maxVisible)) }
    private var extraCount: Int { max(0, entry.events.count - maxVisible) }
    private var clusters: [[EKEvent]] {
        visibleItems.map(\.event).groupedByOverlap()
    }
    private func matchedColor(for event: EKEvent) -> String? {
        visibleItems.first { $0.event.eventIdentifier == event.eventIdentifier }?.matchedColor
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(String(localized: "HOY"))
                    .font(.caption)
                    .fontWeight(.semibold)
                Text(now, format: .dateTime.day().month())
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(entry.widgetConfig.name)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            Divider()
            if clusters.isEmpty {
                Text(String(localized: "Sin eventos hoy"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .accessibilityIdentifier("noEventsLarge")
            } else {
                ForEach(Array(clusters.enumerated()), id: \.offset) { _, cluster in
                    if cluster.count > 1 {
                        VStack(spacing: 0) {
                            ForEach(cluster, id: \.eventIdentifier) { event in
                                EventRowView(event: event, now: now, showColorDot: true, matchedColor: matchedColor(for: event))
                                    .padding(.leading, 12)
                                    .overlay(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color.orange.opacity(0.6))
                                            .frame(width: 2)
                                            .accessibilityIdentifier("overlap_indicator")
                                    }
                            }
                        }
                    } else {
                        EventRowView(event: cluster[0], now: now, showColorDot: true, matchedColor: matchedColor(for: cluster[0]))
                    }
                }
                if extraCount > 0 {
                    Text(String(localized: "+ \(extraCount) más"))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .accessibilityIdentifier("extraEventsLabel")
                }
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .accessibilityIdentifier("largeWidgetView")
    }
}
