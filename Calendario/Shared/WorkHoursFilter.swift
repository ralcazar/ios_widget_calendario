import EventKit
import Foundation

struct WorkHoursFilter {
    static func isWithinWorkHours(event: EKEvent, config: WidgetConfig) -> Bool {
        guard config.workStartOffset >= 0, config.workEndOffset >= 0 else { return true }
        let midnight = Calendar.current.startOfDay(for: event.startDate)
        let workStart = midnight.addingTimeInterval(config.workStartOffset)
        let workEnd   = midnight.addingTimeInterval(config.workEndOffset)
        let eventEnd  = event.endDate ?? event.startDate.addingTimeInterval(3600)
        return event.startDate < workEnd && eventEnd > workStart
    }
}
