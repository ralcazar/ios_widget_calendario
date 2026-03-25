import SwiftUI
import EventKit
import WidgetKit

struct MediumWidgetView: View {
    let entry: CalendarEntry

    private var now: Date { entry.date }
    private var visibleEvents: [EKEvent] { entry.events.prefix(4).map(\.event) }

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
                ForEach(visibleEvents, id: \.eventIdentifier) { event in
                    EventRowView(event: event, now: now, showColorDot: true)
                }
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .accessibilityIdentifier("mediumWidgetView")
    }
}
