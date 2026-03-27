// SharedConstants.swift
// Shared between Calendario app and CalendarioWidget extension

import Foundation

enum AppGroup {
    static let identifier = "group.com.ralcazar.calendario"
    static var defaults: UserDefaults { UserDefaults(suiteName: identifier)! }
}

enum CalendarURL {
    /// Generates a `calshow:` URL that opens the iOS Calendar app centered on the given date/time.
    static func forDate(_ date: Date) -> URL? {
        let timestamp = Int(date.timeIntervalSinceReferenceDate)
        return URL(string: "calshow:\(timestamp)")
    }
}
