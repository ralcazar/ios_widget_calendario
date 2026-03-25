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
        return events.compactMap { event in
            guard let title = event.title else { return nil }
            if let matched = activeRules.first(where: { rule in matches(rule: rule, title: title) }) {
                return (event, matched.colorHex)
            }
            return nil  // evento no coincide con ninguna regla → se oculta
        }
    }

    private static func matches(rule: FilterRule, title: String) -> Bool {
        if rule.isRegex {
            // Limitar complejidad: rechazar patrones con más de 100 caracteres
            guard rule.pattern.count <= 100 else { return false }
            guard let regex = try? Regex(rule.pattern) else { return false }
            return title.contains(regex)
        } else {
            return title.localizedCaseInsensitiveContains(rule.pattern)
        }
    }
}
