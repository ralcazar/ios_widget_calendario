import SwiftUI
import EventKit
import WidgetKit

struct LargeWidgetView: View {
    let entry: CalendarEntry

    private var now: Date { entry.date }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
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
            TimelineView(
                events: entry.events,
                workStart: entry.widgetConfig.workStartOffset,
                workEnd: entry.widgetConfig.workEndOffset,
                now: now,
                compact: false
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .accessibilityIdentifier("largeWidgetView")
    }
}
