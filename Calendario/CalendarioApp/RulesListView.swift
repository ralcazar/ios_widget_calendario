import SwiftUI

struct RulesListView: View {
    @Binding var rules: [FilterRule]
    @State private var showAddRule = false
    @State private var editingRule: FilterRule? = nil

    var body: some View {
        List {
            ForEach(rules.sorted { $0.priority < $1.priority }) { rule in
                Button {
                    editingRule = rule
                } label: {
                    RuleRowView(rule: rule)
                }
                .accessibilityIdentifier("ruleRow_\(rule.id)")
            }
            .onDelete(perform: deleteRules)
            .onMove(perform: moveRules)
        }
        .navigationTitle(String(localized: "Reglas"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
                    .accessibilityIdentifier("editRulesButton")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddRule = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityIdentifier("addRuleButton")
            }
        }
        .sheet(isPresented: $showAddRule) {
            RuleEditView(mode: .create) { newRule in
                var updated = newRule
                updated = FilterRule(
                    id: newRule.id,
                    type: newRule.type,
                    pattern: newRule.pattern,
                    isRegex: newRule.isRegex,
                    colorHex: newRule.colorHex,
                    priority: rules.count,
                    isEnabled: newRule.isEnabled
                )
                rules.append(updated)
            }
        }
        .sheet(item: $editingRule) { rule in
            RuleEditView(mode: .edit(rule)) { updated in
                if let idx = rules.firstIndex(where: { $0.id == updated.id }) {
                    rules[idx] = updated
                }
                editingRule = nil
            }
        }
    }

    private func deleteRules(at offsets: IndexSet) {
        let sorted = rules.sorted { $0.priority < $1.priority }
        let idsToRemove = offsets.map { sorted[$0].id }
        rules.removeAll { idsToRemove.contains($0.id) }
        reindexPriorities()
    }

    private func moveRules(from source: IndexSet, to destination: Int) {
        var sorted = rules.sorted { $0.priority < $1.priority }
        sorted.move(fromOffsets: source, toOffset: destination)
        for (index, rule) in sorted.enumerated() {
            if let i = rules.firstIndex(where: { $0.id == rule.id }) {
                rules[i] = FilterRule(
                    id: rule.id,
                    type: rule.type,
                    pattern: rule.pattern,
                    isRegex: rule.isRegex,
                    colorHex: rule.colorHex,
                    priority: index,
                    isEnabled: rule.isEnabled
                )
            }
        }
    }

    private func reindexPriorities() {
        let sorted = rules.sorted { $0.priority < $1.priority }
        for (index, rule) in sorted.enumerated() {
            if let i = rules.firstIndex(where: { $0.id == rule.id }) {
                rules[i] = FilterRule(
                    id: rule.id,
                    type: rule.type,
                    pattern: rule.pattern,
                    isRegex: rule.isRegex,
                    colorHex: rule.colorHex,
                    priority: index,
                    isEnabled: rule.isEnabled
                )
            }
        }
    }
}

private struct RuleRowView: View {
    let rule: FilterRule

    var body: some View {
        HStack(spacing: 12) {
            if rule.type == .highlight {
                Circle()
                    .fill(Color(hex: rule.colorHex) ?? .accentColor)
                    .frame(width: 12, height: 12)
            } else {
                Image(systemName: "eye.slash")
                    .foregroundColor(.secondary)
                    .frame(width: 12, height: 12)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(rule.pattern)
                    .foregroundColor(.primary)
                HStack(spacing: 4) {
                    if rule.isRegex {
                        Text("Regex")
                            .font(.caption2)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.secondary.opacity(0.2))
                            .cornerRadius(4)
                    }
                    Text(String(localized: "Prioridad \(rule.priority + 1)"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            if !rule.isEnabled {
                Image(systemName: "eye.slash")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
    }
}
