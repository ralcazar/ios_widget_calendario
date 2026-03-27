import SwiftUI
import EventKit

struct RulePreviewView: View {
    let pattern: String
    let isRegex: Bool
    let ruleType: RuleType

    @State private var events: [EKEvent] = []
    @State private var isLoading = true
    @State private var accessDenied = false

    private let store = EKEventStore()

    var body: some View {
        Group {
            if accessDenied {
                ContentUnavailableView {
                    Label(String(localized: "Acceso denegado"), systemImage: "calendar.badge.exclamationmark")
                } description: {
                    Text(String(localized: "Acceso al calendario denegado"))
                } actions: {
                    Button(String(localized: "Ir a Ajustes")) {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .accessibilityIdentifier("openSettingsButton")
                }
                .accessibilityIdentifier("accessDeniedView")
            } else if isLoading {
                ProgressView()
                    .accessibilityIdentifier("loadingView")
            } else if events.isEmpty {
                ContentUnavailableView(
                    String(localized: "Sin eventos"),
                    systemImage: "calendar",
                    description: Text(String(localized: "No se encontraron eventos en los próximos 30 días"))
                )
                .accessibilityIdentifier("emptyEventsView")
            } else {
                eventList
            }
        }
        .navigationTitle(String(localized: "Vista previa: \(pattern)"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await fetchEvents()
        }
    }

    private var eventList: some View {
        List(events.indices, id: \.self) { index in
            let event = events[index]
            let matched = RuleEngine.matches(pattern: pattern, isRegex: isRegex, title: event.title ?? "")
            Button {
                if let url = CalendarURL.forDate(event.startDate) {
                    UIApplication.shared.open(url)
                }
            } label: {
                RulePreviewRow(event: event, matched: matched, ruleType: ruleType)
            }
            .accessibilityIdentifier(matched ? "previewMatchRow_\(index)" : "previewNoMatchRow_\(index)")
        }
        .accessibilityIdentifier("rulePreviewEventsList")
    }

    private func fetchEvents() async {
        isLoading = true

        let status = EKEventStore.authorizationStatus(for: .event)
        if status == .denied || status == .restricted {
            accessDenied = true
            isLoading = false
            return
        }

        if status == .notDetermined {
            do {
                let granted = try await store.requestFullAccessToEvents()
                if !granted {
                    accessDenied = true
                    isLoading = false
                    return
                }
            } catch {
                accessDenied = true
                isLoading = false
                return
            }
        }

        let calendar = Calendar.current
        let start = calendar.date(byAdding: .day, value: -30, to: Date())!
        let end = calendar.date(byAdding: .day, value: 30, to: Date())!
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
        let fetched = store.events(matching: predicate)
            .sorted { $0.startDate < $1.startDate }

        events = fetched
        isLoading = false
    }
}

private struct RulePreviewRow: View {
    let event: EKEvent
    let matched: Bool
    let ruleType: RuleType

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: matched ? "checkmark.circle.fill" : "xmark.circle")
                .foregroundColor(matched ? .green : .gray)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title ?? String(localized: "Sin título"))
                    .font(.body)
                    .lineLimit(1)
                Text(event.startDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
        .opacity(matched ? 1.0 : 0.5)
    }
}
