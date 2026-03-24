import EventKit
import Foundation

enum EventFetcher {
    static func fetchEvents(for config: WidgetConfig) -> [EKEvent] {
        let store = EKEventStore()
        guard EKEventStore.authorizationStatus(for: .event) == .fullAccess else { return [] }

        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return [] }

        guard let ekCalendar = store.calendar(withIdentifier: config.calendarIdentifier) else { return [] }

        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: [ekCalendar])
        return store.events(matching: predicate)
            .filter { event in
                guard let attendees = event.attendees else { return true }
                let selfAttendee = attendees.first { $0.isCurrentUser }
                return selfAttendee?.participantStatus != .declined
            }
            .sorted { $0.startDate < $1.startDate }
    }

    static func buildTimelineEntries(events: [EKEvent], configuration: ConfigurationAppIntent, config: WidgetConfig) -> [CalendarEntry] {
        let now = Date()
        var transitionDates: [Date] = [now]

        for event in events {
            if event.startDate > now { transitionDates.append(event.startDate) }
            if event.endDate > now { transitionDates.append(event.endDate) }
        }

        let calendar = Calendar.current
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) else {
            return transitionDates.sorted().map {
                CalendarEntry(date: $0, events: events, configuration: configuration, widgetConfig: config)
            }
        }
        transitionDates.append(tomorrow)

        return transitionDates.sorted().map {
            CalendarEntry(date: $0, events: events, configuration: configuration, widgetConfig: config)
        }
    }
}
