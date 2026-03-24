import Foundation

struct ColorPair: Codable, Equatable {
    var lightHex: String   // '#RRGGBB'. Vacío = usar color semántico del sistema
    var darkHex: String    // '#RRGGBB'. Vacío = usar color semántico del sistema
    static let system = ColorPair(lightHex: "", darkHex: "")
}

struct FilterRule: Codable, Identifiable, Equatable {
    let id: UUID
    var pattern: String
    var isRegex: Bool
    var colorHex: String
    var priority: Int
    var isEnabled: Bool
}

struct WidgetConfig: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var calendarIdentifier: String
    var colorSchemeLight: ColorPair
    var colorSchemeDark: ColorPair
    var rules: [FilterRule]
    var showCancelled: Bool
    var workStartOffset: TimeInterval
    var workEndOffset: TimeInterval
}

extension WidgetConfig {
    static func new(name: String, calendarIdentifier: String) -> WidgetConfig {
        WidgetConfig(
            id: UUID(),
            name: name,
            calendarIdentifier: calendarIdentifier,
            colorSchemeLight: .system,
            colorSchemeDark: .system,
            rules: [],
            showCancelled: false,
            workStartOffset: -1,
            workEndOffset: -1
        )
    }
}
