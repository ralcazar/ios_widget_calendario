import SwiftUI
import EventKit

struct EventRowView: View {
    let event: EKEvent
    let now: Date
    let showColorDot: Bool
    var matchedColor: String? = nil

    private var isAllDay: Bool { event.isAllDay }
    private var isInProgress: Bool { event.startDate <= now && now < event.endDate }
    private var isCancelled: Bool { event.status == .canceled }

    private var timeText: String {
        if isAllDay { return String(localized: "Todo el día") }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return "\(formatter.string(from: event.startDate)) – \(formatter.string(from: event.endDate))"
    }

    var body: some View {
        let url = EventFetcher.calendarURL(for: event.startDate)
        Group {
            if let url = url {
                Link(destination: url) {
                    rowContent
                }
            } else {
                rowContent
            }
        }
    }

    private var rowContent: some View {
        HStack(spacing: 6) {
            if let hex = matchedColor, let color = Color(hex: hex) {
                Rectangle()
                    .fill(color)
                    .frame(width: 3)
                    .clipShape(Capsule())
                    .accessibilityIdentifier("accentBar_\(event.eventIdentifier ?? "")")
            } else {
                Spacer().frame(width: 3)
            }
            if showColorDot {
                Circle()
                    .fill(Color(cgColor: event.calendar.cgColor))
                    .frame(width: 6, height: 6)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(timeText)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .fontWeight(isInProgress ? .bold : .regular)
                Text(event.title ?? "")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .strikethrough(isCancelled)
            }
        }
        .frame(height: 32, alignment: .leading)
        .opacity(isCancelled ? 0.5 : 1.0)
        .accessibilityIdentifier("eventRow_\(event.eventIdentifier ?? "")")
    }
}
