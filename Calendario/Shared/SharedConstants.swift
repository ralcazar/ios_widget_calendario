// SharedConstants.swift
// Shared between Calendario app and CalendarioWidget extension

import Foundation

enum AppGroup {
    static let identifier = "group.com.ralcazar.calendario"
    static var defaults: UserDefaults { UserDefaults(suiteName: identifier)! }
}
