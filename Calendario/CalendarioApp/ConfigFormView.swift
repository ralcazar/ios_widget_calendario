import SwiftUI
import EventKit

enum ConfigFormMode {
    case create
    case edit(WidgetConfig)
}

struct ConfigFormView: View {
    let mode: ConfigFormMode
    let onSave: (WidgetConfig) -> Void

    @State private var name: String = ""
    @State private var selectedCalendarId: String = ""
    @State private var calendars: [EKCalendar] = []
    @State private var rules: [FilterRule] = []
    @State private var useSystemColors: Bool = true
    @State private var lightColor: Color = .white
    @State private var darkColor: Color = .black
    @State private var showCancelled: Bool = false
    @State private var store = EKEventStore()
    @Environment(\.dismiss) private var dismiss

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private var existingConfig: WidgetConfig? {
        if case .edit(let c) = mode { return c }
        return nil
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && !selectedCalendarId.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Calendario") {
                    if calendars.isEmpty {
                        Text("No hay calendarios disponibles")
                            .foregroundColor(.secondary)
                            .accessibilityIdentifier("noCalendarsLabel")
                    } else {
                        ForEach(calendars, id: \.calendarIdentifier) { calendar in
                            HStack {
                                Circle()
                                    .fill(Color(cgColor: calendar.cgColor))
                                    .frame(width: 12, height: 12)
                                Text(calendar.title)
                                Spacer()
                                if selectedCalendarId == calendar.calendarIdentifier {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedCalendarId = calendar.calendarIdentifier
                            }
                            .accessibilityIdentifier("calendarRow_\(calendar.calendarIdentifier)")
                        }
                    }
                }
                Section("General") {
                    TextField("Nombre", text: $name)
                        .accessibilityIdentifier("nameField")
                }
                Section(String(localized: "Reglas")) {
                    NavigationLink {
                        RulesListView(rules: $rules)
                    } label: {
                        HStack {
                            Text(String(localized: "Reglas de filtrado"))
                            Spacer()
                            Text("\(rules.count)")
                                .foregroundColor(.secondary)
                        }
                    }
                    .accessibilityIdentifier("rulesLink")
                    NavigationLink {
                        RulesPreviewView(rules: rules)
                    } label: {
                        Text(String(localized: "Vista previa de reglas →"))
                    }
                    .accessibilityIdentifier("rulesPreviewLink")
                }
                Section(String(localized: "Eventos")) {
                    Toggle(String(localized: "Mostrar cancelados"), isOn: $showCancelled)
                        .accessibilityIdentifier("showCancelledToggle")
                }
                Section(String(localized: "Apariencia")) {
                    Toggle(String(localized: "Usar colores del sistema"), isOn: $useSystemColors)
                        .accessibilityIdentifier("useSystemColorsToggle")
                    if !useSystemColors {
                        ColorPicker(String(localized: "Fondo claro"), selection: $lightColor)
                            .accessibilityIdentifier("lightColorPicker")
                        ColorPicker(String(localized: "Fondo oscuro"), selection: $darkColor)
                            .accessibilityIdentifier("darkColorPicker")
                    }
                }
            }
            .navigationTitle(isEditing ? "Editar configuración" : "Nueva configuración")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "Cancelar")) {
                        dismiss()
                    }
                    .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "Guardar")) {
                        save()
                    }
                    .disabled(!canSave)
                    .accessibilityIdentifier("saveButton")
                }
            }
        }
        .onAppear {
            Task { await setup() }
        }
    }

    @MainActor
    private func setup() async {
        // Load calendars after confirming/requesting authorization
        let status = EKEventStore.authorizationStatus(for: .event)
        if status == .fullAccess || status == .authorized {
            loadCalendars()
        } else if status == .notDetermined {
            do {
                if #available(iOS 17.0, *) {
                    try await store.requestFullAccessToEvents()
                } else {
                    try await store.requestAccess(to: .event)
                }
            } catch {}
            loadCalendars()
        }
        // .denied / .restricted: leave calendars empty

        // Pre-populate for edit mode
        if let config = existingConfig {
            name = config.name
            selectedCalendarId = config.calendarIdentifier
            rules = config.rules
            showCancelled = config.showCancelled
            let isSystem = config.colorSchemeLight == .system && config.colorSchemeDark == .system
            useSystemColors = isSystem
            if !isSystem {
                lightColor = Color(hex: config.colorSchemeLight.lightHex) ?? .white
                darkColor = Color(hex: config.colorSchemeDark.darkHex) ?? .black
            }
        }
    }

    @MainActor
    private func loadCalendars() {
        calendars = store.calendars(for: .event).sorted { $0.title < $1.title }
    }

    private func save() {
        let newColorSchemeLight: ColorPair
        let newColorSchemeDark: ColorPair
        if useSystemColors {
            newColorSchemeLight = .system
            newColorSchemeDark = .system
        } else {
            let lHex = lightColor.hexString
            let dHex = darkColor.hexString
            newColorSchemeLight = ColorPair(lightHex: lHex, darkHex: lHex)
            newColorSchemeDark = ColorPair(lightHex: dHex, darkHex: dHex)
        }

        let config: WidgetConfig
        if let existing = existingConfig {
            config = WidgetConfig(
                id: existing.id,
                name: name.trimmingCharacters(in: .whitespaces),
                calendarIdentifier: selectedCalendarId,
                colorSchemeLight: newColorSchemeLight,
                colorSchemeDark: newColorSchemeDark,
                rules: rules,
                showCancelled: showCancelled,
                workStartOffset: existing.workStartOffset,
                workEndOffset: existing.workEndOffset
            )
        } else {
            let newConfig = WidgetConfig.new(
                name: name.trimmingCharacters(in: .whitespaces),
                calendarIdentifier: selectedCalendarId
            )
            config = WidgetConfig(
                id: newConfig.id,
                name: newConfig.name,
                calendarIdentifier: newConfig.calendarIdentifier,
                colorSchemeLight: newColorSchemeLight,
                colorSchemeDark: newColorSchemeDark,
                rules: rules,
                showCancelled: showCancelled,
                workStartOffset: newConfig.workStartOffset,
                workEndOffset: newConfig.workEndOffset
            )
        }
        onSave(config)
    }
}
