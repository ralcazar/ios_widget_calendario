import Foundation

struct ColorPair: Codable, Equatable {
    var lightHex: String   // '#RRGGBB'. Vacío = usar color semántico del sistema
    var darkHex: String    // '#RRGGBB'. Vacío = usar color semántico del sistema
    static let system = ColorPair(lightHex: "", darkHex: "")
}

enum RuleType: String, Codable, CaseIterable {
    case highlight  // resaltar: patrón + color
    case hide       // ocultar: solo patrón
}

struct FilterRule: Codable, Identifiable, Equatable {
    let id: UUID
    var type: RuleType
    var pattern: String
    var isRegex: Bool
    var colorHex: String    // vacío para .hide
    var priority: Int
    var isEnabled: Bool

    init(id: UUID, type: RuleType = .highlight, pattern: String, isRegex: Bool, colorHex: String, priority: Int, isEnabled: Bool) {
        self.id = id
        self.type = type
        self.pattern = pattern
        self.isRegex = isRegex
        self.colorHex = colorHex
        self.priority = priority
        self.isEnabled = isEnabled
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decodeIfPresent(RuleType.self, forKey: .type) ?? .highlight
        pattern = try container.decode(String.self, forKey: .pattern)
        isRegex = try container.decode(Bool.self, forKey: .isRegex)
        colorHex = try container.decode(String.self, forKey: .colorHex)
        priority = try container.decode(Int.self, forKey: .priority)
        isEnabled = try container.decode(Bool.self, forKey: .isEnabled)
    }
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
