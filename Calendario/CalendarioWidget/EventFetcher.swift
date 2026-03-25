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
            .filter { event in
                config.showCancelled || event.status != .canceled
            }
            .sorted { $0.startDate < $1.startDate }
    }

    static func calendarURL(for date: Date) -> URL? {
        // calshow: uses timeIntervalSinceReferenceDate (seconds since Jan 1, 2001)
        let timestamp = Int(date.timeIntervalSinceReferenceDate)
        return URL(string: "calshow:\(timestamp)")
    }

    static func buildTimelineEntries(events: [(event: EKEvent, matchedColor: String?)], configuration: ConfigurationAppIntent, config: WidgetConfig) -> [CalendarEntry] {
        let now = Date()
        var transitionDates: [Date] = [now]

        for annotated in events {
            if annotated.event.startDate > now { transitionDates.append(annotated.event.startDate) }
            if annotated.event.endDate > now { transitionDates.append(annotated.event.endDate) }
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
