import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Configuration"
    static var description = IntentDescription("Choose a calendar configuration to display.")

    @Parameter(title: "Configuration")
    var configuration: WidgetConfigEntity?
}
