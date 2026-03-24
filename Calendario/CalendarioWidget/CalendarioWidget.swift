import WidgetKit
import SwiftUI
import EventKit

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), authorizationStatus: .notDetermined)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration, authorizationStatus: EKEventStore.authorizationStatus(for: .event))
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let status = EKEventStore.authorizationStatus(for: .event)
        let entry = SimpleEntry(date: Date(), configuration: configuration, authorizationStatus: status)
        return Timeline(entries: [entry], policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let authorizationStatus: EKAuthorizationStatus
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
                if let configEntity = entry.configuration.configuration {
                    configView(configEntity)
                } else {
                    noConfigView
                }
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
        .accessibilityIdentifier("widgetEntryView")
    }

    private var deniedView: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.exclamationmark")
            Text(String(localized: "Sin permisos de calendario"))
                .font(.caption)
                .multilineTextAlignment(.center)
            Link(String(localized: "Abrir Ajustes"), destination: URL(string: "app-settings:")!)
                .font(.caption2)
                .accessibilityIdentifier("openSettingsLink")
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

    private func configView(_ entity: WidgetConfigEntity) -> some View {
        VStack {
            Image(systemName: "calendar")
            Text(entity.name)
                .font(.headline)
        }
        .accessibilityIdentifier("configView")
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
