import Foundation

struct DismissedEventsStore {
    private static let key = "dismissedEvents"

    static func dismiss(eventIdentifier: String) {
        var dismissed = load()
        dismissed[eventIdentifier] = Date()
        save(dismissed)
    }

    static func isDismissed(_ eventIdentifier: String) -> Bool {
        let dismissed = load()
        guard let date = dismissed[eventIdentifier] else { return false }
        return Calendar.current.isDateInToday(date)
    }

    static func cleanUpIfNeeded() {
        var dismissed = load()
        let today = Calendar.current.startOfDay(for: Date())
        dismissed = dismissed.filter { _, date in
            Calendar.current.startOfDay(for: date) >= today
        }
        save(dismissed)
    }

    private static func load() -> [String: Date] {
        guard let data = AppGroup.defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([String: Date].self, from: data)
        else { return [:] }
        return decoded
    }

    private static func save(_ dict: [String: Date]) {
        guard let data = try? JSONEncoder().encode(dict) else { return }
        AppGroup.defaults.set(data, forKey: key)
    }
}
