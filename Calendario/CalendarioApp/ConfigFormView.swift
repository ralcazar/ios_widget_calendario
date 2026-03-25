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
        .onAppear(perform: setup)
    }

    private func setup() {
        // Load calendars
        let store = EKEventStore()
        calendars = store.calendars(for: .event).sorted { $0.title < $1.title }

        // Pre-populate for edit mode
        if let config = existingConfig {
            name = config.name
            selectedCalendarId = config.calendarIdentifier
            rules = config.rules
        }
    }

    private func save() {
        let config: WidgetConfig
        if let existing = existingConfig {
            config = WidgetConfig(
                id: existing.id,
                name: name.trimmingCharacters(in: .whitespaces),
                calendarIdentifier: selectedCalendarId,
                colorSchemeLight: existing.colorSchemeLight,
                colorSchemeDark: existing.colorSchemeDark,
                rules: rules,
                showCancelled: existing.showCancelled,
                workStartOffset: existing.workStartOffset,
                workEndOffset: existing.workEndOffset
            )
        } else {
            var newConfig = WidgetConfig.new(
                name: name.trimmingCharacters(in: .whitespaces),
                calendarIdentifier: selectedCalendarId
            )
            newConfig = WidgetConfig(
                id: newConfig.id,
                name: newConfig.name,
                calendarIdentifier: newConfig.calendarIdentifier,
                colorSchemeLight: newConfig.colorSchemeLight,
                colorSchemeDark: newConfig.colorSchemeDark,
                rules: rules,
                showCancelled: newConfig.showCancelled,
                workStartOffset: newConfig.workStartOffset,
                workEndOffset: newConfig.workEndOffset
            )
            config = newConfig
        }
        onSave(config)
    }
}
