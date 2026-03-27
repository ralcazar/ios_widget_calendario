import SwiftUI
import EventKit

struct TimelineEventBlock: View {
    let event: EKEvent
    let matchedColor: String?
    let compact: Bool

    private var blockColor: Color {
        if let hex = matchedColor, let color = Color(hex: hex) { return color }
        return Color(cgColor: event.calendar.cgColor)
    }

    var body: some View {
        let url = CalendarURL.forDate(event.startDate ?? Date())
        Group {
            if let url = url {
                Link(destination: url) { blockContent }
            } else {
                blockContent
            }
        }
        .opacity(event.status == .canceled ? 0.5 : 1.0)
        .accessibilityIdentifier("timelineBlock_\(event.eventIdentifier ?? "")")
    }

    private var blockContent: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4)
                .fill(blockColor.opacity(0.20))
            HStack(spacing: 0) {
                Rectangle()
                    .fill(blockColor)
                    .frame(width: 3)
                Spacer(minLength: 0)
            }
            .clipShape(RoundedRectangle(cornerRadius: 4))

            Text(event.title ?? "")
                .font(compact ? .system(size: 9, weight: .medium) : .caption2)
                .lineLimit(compact ? 1 : 2)
                .foregroundColor(.primary)
                .padding(.leading, 6)
                .padding(.trailing, 2)
        }
    }
}
