import SwiftUI
import EventKit
import WidgetKit

struct ExtraLargeWidgetView: View {
    let entry: CalendarEntry
    private let maxVisible = 12

    private var now: Date { entry.date }
    private var visibleEvents: [EKEvent] { Array(entry.events.prefix(maxVisible)) }
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
            }
            Divider()
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 4) {
                ForEach(visibleEvents, id: \.eventIdentifier) { event in
                    EventRowView(event: event, now: now, showColorDot: true)
                }
            }
            if extraCount > 0 {
                Text(String(localized: "+ \(extraCount) más"))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .accessibilityIdentifier("extraLargeWidgetView")
    }
}
