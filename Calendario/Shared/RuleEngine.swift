import EventKit
import Foundation

struct RuleEngine {
    /// Filtra y anota eventos según las reglas activas de la configuración.
    /// Si no hay reglas habilitadas, devuelve todos los eventos sin anotar.
    static func apply(rules: [FilterRule], to events: [EKEvent]) -> [(event: EKEvent, matchedColor: String?)] {
        let activeRules = rules.filter(\.isEnabled).sorted { $0.priority < $1.priority }
        guard !activeRules.isEmpty else {
            return events.map { ($0, nil) }
        }

        let hideRules = activeRules.filter { $0.type == .hide }
        let highlightRules = activeRules.filter { $0.type == .highlight }

        return events.compactMap { event in
            guard let title = event.title else { return (event, nil) }

            // Si coincide con alguna regla de ocultar → excluir
            if hideRules.contains(where: { matches(rule: $0, title: title) }) {
                return nil
            }

            // Si coincide con alguna regla de resaltar → color de la primera que coincida
            if let matched = highlightRules.first(where: { matches(rule: $0, title: title) }) {
                return (event, matched.colorHex)
            }

            // No coincide con nada → mostrar con matchedColor = nil
            return (event, nil)
        }
    }

    private static func matches(rule: FilterRule, title: String) -> Bool {
        matches(pattern: rule.pattern, isRegex: rule.isRegex, title: title)
    }

    static func matches(pattern: String, isRegex: Bool, title: String) -> Bool {
        if isRegex {
            guard pattern.count <= 100 else { return false }
            guard let regex = try? Regex(pattern) else { return false }
            return title.contains(regex)
        } else {
            return title.localizedCaseInsensitiveContains(pattern)
        }
    }
}
