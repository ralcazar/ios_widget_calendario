import SwiftUI
import EventKit
import WidgetKit

struct MediumWidgetView: View {
    let entry: CalendarEntry

    private var now: Date { entry.date }
    private var visibleEvents: [(event: EKEvent, matchedColor: String?)] { Array(entry.events.prefix(4)) }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Header
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
            if visibleEvents.isEmpty {
                Text(String(localized: "Sin eventos hoy"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .accessibilityIdentifier("noEventsMedium")
            } else {
                ForEach(visibleEvents, id: \.event.eventIdentifier) { item in
                    EventRowView(event: item.event, now: now, showColorDot: true, matchedColor: item.matchedColor)
                }
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .accessibilityIdentifier("mediumWidgetView")
    }
}
