import Foundation

enum WidgetConfigStore {
    static let key = "widgetConfigs"

    static func loadAll() -> [WidgetConfig] {
        guard let data = AppGroup.defaults.data(forKey: key),
              let configs = try? JSONDecoder().decode([WidgetConfig].self, from: data)
        else { return [] }
        return configs
    }

    static func saveAll(_ configs: [WidgetConfig]) {
        guard let data = try? JSONEncoder().encode(configs) else { return }
        AppGroup.defaults.set(data, forKey: key)
    }
}
