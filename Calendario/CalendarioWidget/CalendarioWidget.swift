import WidgetKit
import SwiftUI
import EventKit

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> CalendarEntry {
        CalendarEntry(date: Date(), events: [], configuration: ConfigurationAppIntent(), widgetConfig: WidgetConfig.new(name: "Placeholder", calendarIdentifier: ""))
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> CalendarEntry {
        let widgetConfig = resolveConfig(from: configuration)
        let rawEvents = EventFetcher.fetchEvents(for: widgetConfig)
        let filtered = rawEvents.filter { WorkHoursFilter.isWithinWorkHours(event: $0, config: widgetConfig) }
        let annotatedEvents = RuleEngine.apply(rules: widgetConfig.rules, to: filtered)
        DismissedEventsStore.cleanUpIfNeeded()
        let visibleEvents = annotatedEvents.filter { !DismissedEventsStore.isDismissed($0.event.eventIdentifier ?? "") }
        return CalendarEntry(date: Date(), events: visibleEvents, configuration: configuration, widgetConfig: widgetConfig)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<CalendarEntry> {
        let widgetConfig = resolveConfig(from: configuration)
        let rawEvents = EventFetcher.fetchEvents(for: widgetConfig)
        let filtered = rawEvents.filter { WorkHoursFilter.isWithinWorkHours(event: $0, config: widgetConfig) }
        let annotatedEvents = RuleEngine.apply(rules: widgetConfig.rules, to: filtered)
        DismissedEventsStore.cleanUpIfNeeded()
        let visibleEvents = annotatedEvents.filter { !DismissedEventsStore.isDismissed($0.event.eventIdentifier ?? "") }
        let entries = EventFetcher.buildTimelineEntries(events: visibleEvents, configuration: configuration, config: widgetConfig)
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
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.colorScheme) var colorScheme

    var backgroundColor: Color {
        let pair = colorScheme == .dark
            ? entry.widgetConfig.colorSchemeDark
            : entry.widgetConfig.colorSchemeLight
        guard !pair.lightHex.isEmpty else { return Color(.systemBackground) }
        let hex = colorScheme == .dark ? pair.darkHex : pair.lightHex
        return Color(hex: hex.isEmpty ? pair.lightHex : hex) ?? Color(.systemBackground)
    }

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
                    contentView
                }
            }
        }
        .containerBackground(backgroundColor, for: .widget)
        .accessibilityIdentifier("widgetEntryView")
    }

    @ViewBuilder
    private var contentView: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        case .systemExtraLarge:
            ExtraLargeWidgetView(entry: entry)
        default:
            MediumWidgetView(entry: entry)
        }
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
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}
