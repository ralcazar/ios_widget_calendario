import SwiftUI
import EventKit
import WidgetKit

struct SmallWidgetView: View {
    let entry: CalendarEntry

    private var now: Date { entry.date }
    private var upcomingEvents: [EKEvent] {
        entry.events.prefix(2).map(\.event)
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
            if upcomingEvents.isEmpty {
                Text(String(localized: "Sin eventos"))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .accessibilityIdentifier("noEventsSmall")
            } else {
                ForEach(upcomingEvents, id: \.eventIdentifier) { event in
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .accessibilityIdentifier("smallWidgetView")
        .widgetURL(EventFetcher.calendarURL(for: entry.events.first?.event.startDate ?? entry.date))
    }
}
