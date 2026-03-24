import EventKit
import WidgetKit

struct CalendarEntry: TimelineEntry {
    let date: Date
    let events: [EKEvent]
    let configuration: ConfigurationAppIntent
    let widgetConfig: WidgetConfig
    let authorizationStatus: EKAuthorizationStatus

    init(date: Date, events: [EKEvent], configuration: ConfigurationAppIntent, widgetConfig: WidgetConfig) {
        self.date = date
        self.events = events
        self.configuration = configuration
        self.widgetConfig = widgetConfig
        self.authorizationStatus = EKEventStore.authorizationStatus(for: .event)
    }
}
