import SwiftUI

enum RuleEditMode {
    case create
    case edit(FilterRule)
}

struct RuleEditView: View {
    let mode: RuleEditMode
    let onSave: (FilterRule) -> Void

    @State private var ruleType: RuleType = .highlight
    @State private var pattern: String = ""
    @State private var isRegex: Bool = false
    @State private var isEnabled: Bool = true
    @State private var selectedColor: Color = .red
    @Environment(\.dismiss) private var dismiss

    private var existingRule: FilterRule? {
        if case .edit(let r) = mode { return r }
        return nil
    }

    private var isEditing: Bool { existingRule != nil }

    private var regexError: String? {
        guard isRegex, !pattern.isEmpty else { return nil }
        if (try? Regex(pattern)) == nil {
            return String(localized: "Patrón de regex inválido")
        }
        return nil
    }

    private var canSave: Bool {
        !pattern.trimmingCharacters(in: .whitespaces).isEmpty && regexError == nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "Tipo de regla")) {
                    Picker(String(localized: "Tipo"), selection: $ruleType) {
                        Text(String(localized: "Resaltar")).tag(RuleType.highlight)
                        Text(String(localized: "Ocultar")).tag(RuleType.hide)
                    }
                    .pickerStyle(.segmented)
                    .disabled(isEditing)
                    .accessibilityIdentifier("ruleTypePicker")
                }
                Section(String(localized: "Patrón")) {
                    TextField(String(localized: "Texto o regex"), text: $pattern)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .accessibilityIdentifier("patternField")
                    Toggle(String(localized: "Usar regex"), isOn: $isRegex)
                        .accessibilityIdentifier("isRegexToggle")
                    if let error = regexError {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        .accessibilityIdentifier("regexErrorLabel")
                    }
                }
                if ruleType == .highlight {
                    Section(String(localized: "Color")) {
                        ColorPicker(String(localized: "Color del evento"), selection: $selectedColor, supportsOpacity: false)
                            .accessibilityIdentifier("colorPicker")
                    }
                }
                Section {
                    NavigationLink {
                        RulePreviewView(pattern: pattern, isRegex: isRegex, ruleType: ruleType)
                    } label: {
                        Label(String(localized: "Vista previa"), systemImage: "eye")
                    }
                    .disabled(pattern.trimmingCharacters(in: .whitespaces).isEmpty || regexError != nil)
                    .accessibilityIdentifier("rulePreviewLink")
                }
                Section {
                    Toggle(String(localized: "Habilitada"), isOn: $isEnabled)
                        .accessibilityIdentifier("isEnabledToggle")
                }
            }
            .navigationTitle(isEditing ? String(localized: "Editar regla") : String(localized: "Nueva regla"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "Cancelar")) {
                        dismiss()
                    }
                    .accessibilityIdentifier("cancelRuleButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "Guardar")) {
                        save()
                    }
                    .disabled(!canSave)
                    .accessibilityIdentifier("saveRuleButton")
                }
            }
        }
        .onAppear(perform: setup)
    }

    private func setup() {
        guard let rule = existingRule else { return }
        ruleType = rule.type
        pattern = rule.pattern
        isRegex = rule.isRegex
        isEnabled = rule.isEnabled
        selectedColor = Color(hex: rule.colorHex) ?? .red
    }

    private func save() {
        let colorHex = ruleType == .highlight ? (selectedColor.toHex() ?? "#FF0000") : ""
        let rule: FilterRule
        if let existing = existingRule {
            rule = FilterRule(
                id: existing.id,
                type: ruleType,
                pattern: pattern.trimmingCharacters(in: .whitespaces),
                isRegex: isRegex,
                colorHex: colorHex,
                priority: existing.priority,
                isEnabled: isEnabled
            )
        } else {
            rule = FilterRule(
                id: UUID(),
                type: ruleType,
                pattern: pattern.trimmingCharacters(in: .whitespaces),
                isRegex: isRegex,
                colorHex: colorHex,
                priority: 0,
                isEnabled: isEnabled
            )
        }
        onSave(rule)
        dismiss()
    }
}

extension Color {
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components,
              components.count >= 3 else { return nil }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
