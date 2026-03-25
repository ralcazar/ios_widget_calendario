import AppIntents
import WidgetKit

struct DismissEventIntent: AppIntent {
    static var title: LocalizedStringResource = "Descartar evento"

    @Parameter(title: "Event ID")
    var eventIdentifier: String

    init() {
        self.eventIdentifier = ""
    }

    init(eventIdentifier: String) {
        self.eventIdentifier = eventIdentifier
    }

    func perform() async throws -> some IntentResult {
        DismissedEventsStore.dismiss(eventIdentifier: eventIdentifier)
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
