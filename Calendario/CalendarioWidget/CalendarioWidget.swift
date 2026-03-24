import WidgetKit
import SwiftUI
import EventKit

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> CalendarEntry {
        CalendarEntry(date: Date(), events: [], configuration: ConfigurationAppIntent(), widgetConfig: WidgetConfig.new(name: "Placeholder", calendarIdentifier: ""))
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> CalendarEntry {
        let widgetConfig = resolveConfig(from: configuration)
        let events = EventFetcher.fetchEvents(for: widgetConfig)
        return CalendarEntry(date: Date(), events: events, configuration: configuration, widgetConfig: widgetConfig)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<CalendarEntry> {
        let widgetConfig = resolveConfig(from: configuration)
        let events = EventFetcher.fetchEvents(for: widgetConfig)
        let entries = EventFetcher.buildTimelineEntries(events: events, configuration: configuration, config: widgetConfig)
        return Timeline(entries: entries, policy: .atEnd)
    }

    private func resolveConfig(from intent: ConfigurationAppIntent) -> WidgetConfig {
        guard let entityId = intent.configuration?.id,
              let config = WidgetConfigStore.loadAll().first(where: { $0.id == entityId }) else {
            return WidgetConfigStore.loadAll().first ?? WidgetConfig.new(name: "", calendarIdentifier: "")
        }
        return config
    }
}

struct CalendarioWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        Group {
            switch entry.authorizationStatus {
            case .denied, .restricted:
                deniedView
            case .notDetermined:
                notDeterminedView
            default:
                if entry.configuration.configuration == nil {
                    noConfigView
                } else {
                    configView
                }
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
        .accessibilityIdentifier("widgetEntryView")
    }

    private var configView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.widgetConfig.name)
                .font(.caption)
                .foregroundColor(.secondary)
            if entry.events.isEmpty {
                Text(String(localized: "Sin eventos hoy"))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .accessibilityIdentifier("noEventsLabel")
            } else {
                ForEach(entry.events.prefix(3), id: \.eventIdentifier) { event in
                    Text(event.title ?? "")
                        .font(.caption2)
                        .lineLimit(1)
                }
            }
        }
        .accessibilityIdentifier("configView")
    }

    private var deniedView: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.exclamationmark")
            Text(String(localized: "Sin permisos de calendario"))
                .font(.caption)
                .multilineTextAlignment(.center)
            if let url = URL(string: "app-settings:") {
                Link(String(localized: "Abrir Ajustes"), destination: url)
                    .font(.caption2)
                    .accessibilityIdentifier("openSettingsLink")
            }
        }
        .accessibilityIdentifier("deniedView")
    }

    private var notDeterminedView: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar")
            Text(String(localized: "Abre la app para comenzar"))
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .accessibilityIdentifier("notDeterminedView")
    }

    private var noConfigView: some View {
        VStack {
            Image(systemName: "calendar.badge.exclamationmark")
            Text(String(localized: "Selecciona una configuración"))
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .accessibilityIdentifier("noConfigView")
    }
}

struct CalendarioWidget: Widget {
    let kind: String = "CalendarioWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: Provider()
        ) { entry in
            CalendarioWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Calendario")
        .description(String(localized: "Visualiza tus próximos eventos."))
    }
}
