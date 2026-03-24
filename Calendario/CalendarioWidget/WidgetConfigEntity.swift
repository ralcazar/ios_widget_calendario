import AppIntents
import Foundation

// AppEntity representing a single widget configuration selection
struct WidgetConfigEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Widget Configuration")
    static var defaultQuery = WidgetConfigQuery()

    var id: UUID
    var name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }

    init(id: UUID, name: String) {
        self.id = id
        self.name = name
    }

    init(from config: WidgetConfig) {
        self.id = config.id
        self.name = config.name
    }
}

// EntityQuery reads configurations from the shared App Group storage
struct WidgetConfigQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [WidgetConfigEntity] {
        WidgetConfigStore.loadAll()
            .filter { identifiers.contains($0.id) }
            .map { WidgetConfigEntity(from: $0) }
    }

    func suggestedEntities() async throws -> [WidgetConfigEntity] {
        WidgetConfigStore.loadAll().map { WidgetConfigEntity(from: $0) }
    }
}
