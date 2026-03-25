import SwiftUI
import EventKit
import WidgetKit

struct LargeWidgetView: View {
    let entry: CalendarEntry
    private let maxVisible = 8

    private var now: Date { entry.date }
    private var visibleEvents: [EKEvent] { entry.events.prefix(maxVisible).map(\.event) }
    private var extraCount: Int { max(0, entry.events.count - maxVisible) }

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
            if visibleEvents.isEmpty {
                Text(String(localized: "Sin eventos hoy"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .accessibilityIdentifier("noEventsLarge")
            } else {
                ForEach(visibleEvents, id: \.eventIdentifier) { event in
                    EventRowView(event: event, now: now, showColorDot: true)
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
