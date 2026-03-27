import SwiftUI
import EventKit

struct RulesPreviewView: View {
    let rules: [FilterRule]

    @State private var annotatedEvents: [(event: EKEvent, matchedColor: String?)] = []
    @State private var accessDenied = false
    @State private var isLoading = true

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
            } else if annotatedEvents.isEmpty {
                ContentUnavailableView(
                    String(localized: "Sin eventos"),
                    systemImage: "calendar",
                    description: Text(String(localized: "No se encontraron eventos en los últimos 30 días"))
                )
                .accessibilityIdentifier("emptyEventsView")
            } else {
                List(annotatedEvents.indices, id: \.self) { index in
                    let item = annotatedEvents[index]
                    EventPreviewRow(event: item.event, colorHex: item.matchedColor)
                        .accessibilityIdentifier("previewRow_\(index)")
                }
                .accessibilityIdentifier("previewEventsList")
            }
        }
        .navigationTitle(String(localized: "Vista previa de reglas"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await fetchAndApply()
        }
        .onChange(of: rules) {
            Task { await fetchAndApply() }
        }
    }

    private func fetchAndApply() async {
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
        let end = calendar.date(byAdding: .day, value: 7, to: Date())!
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
        let fetched = store.events(matching: predicate)
            .sorted { $0.startDate < $1.startDate }
            .suffix(50)

        let result = RuleEngine.apply(rules: rules, to: Array(fetched))
        annotatedEvents = result
        isLoading = false
    }
}

private struct EventPreviewRow: View {
    let event: EKEvent
    let colorHex: String?

    private var accentColor: Color {
        if let hex = colorHex, let color = Color(hex: hex) {
            return color
        }
        return Color(cgColor: event.calendar.cgColor)
    }

    var body: some View {
        HStack(spacing: 10) {
            Rectangle()
                .fill(accentColor)
                .frame(width: 4)
                .cornerRadius(2)
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
    }
}
