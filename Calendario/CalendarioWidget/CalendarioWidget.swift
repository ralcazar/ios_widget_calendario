import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        return Timeline(entries: [entry], policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct CalendarioWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        Group {
            if let configEntity = entry.configuration.configuration {
                VStack {
                    Image(systemName: "calendar")
                    Text(configEntity.name)
                        .font(.headline)
                }
            } else {
                VStack {
                    Image(systemName: "calendar.badge.exclamationmark")
                    Text(String(localized: "Selecciona una configuración"))
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
        .accessibilityIdentifier("widgetEntryView")
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
