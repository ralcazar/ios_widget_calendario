import SwiftUI
import EventKit
import WidgetKit

struct SmallWidgetView: View {
    let entry: CalendarEntry

    private var now: Date { entry.date }
    private var clusters: [[EKEvent]] {
        entry.events.prefix(4).map(\.event).groupedByOverlap()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Header: abbreviated day + day number
            Text(now, format: .dateTime.weekday(.abbreviated))
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(now, format: .dateTime.day())
                .font(.title2)
                .fontWeight(.bold)
            Spacer(minLength: 0)
            if clusters.isEmpty {
                Text(String(localized: "Sin eventos"))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .accessibilityIdentifier("noEventsSmall")
            } else {
                ForEach(Array(clusters.prefix(2).enumerated()), id: \.offset) { _, cluster in
                    if cluster.count > 1 {
                        HStack(spacing: 4) {
                            Text(cluster[0].startDate, style: .time)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("— \(cluster.count) \(String(localized: "eventos"))")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .lineLimit(1)
                        }
                        .accessibilityIdentifier("collapsed_cluster_\(cluster.count)")
                    } else {
                        let event = cluster[0]
                        HStack(spacing: 4) {
                            if event.isAllDay {
                                Text(String(localized: "Todo el día"))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            } else {
                                Text(event.startDate, style: .time)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            Text(event.title ?? "")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .accessibilityIdentifier("smallWidgetView")
        .widgetURL(EventFetcher.calendarURL(for: entry.events.first?.event.startDate ?? entry.date))
    }
}
