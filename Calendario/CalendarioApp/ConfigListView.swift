import SwiftUI
import WidgetKit

struct ConfigListView: View {
    @State private var configs: [WidgetConfig] = []
    @State private var showCreateSheet = false
    @State private var editingConfig: WidgetConfig? = nil
    @State private var deletingConfig: WidgetConfig? = nil
    @State private var showDeleteAlert = false

    var body: some View {
        Group {
            if configs.isEmpty {
                emptyStateView
            } else {
                configList
            }
        }
        .navigationTitle("Configuraciones")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(String(localized: "Actualizar widgets")) {
                    WidgetCenter.shared.reloadAllTimelines()
                }
                .accessibilityIdentifier("refresh_widgets_button")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showCreateSheet = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityIdentifier("addConfigButton")
            }
        }
        .sheet(isPresented: $showCreateSheet, onDismiss: loadConfigs) {
            ConfigFormView(mode: .create, onSave: { newConfig in
                var all = WidgetConfigStore.loadAll()
                all.append(newConfig)
                WidgetConfigStore.saveAll(all)
                WidgetCenter.shared.reloadAllTimelines()
                showCreateSheet = false
            })
        }
        .sheet(item: $editingConfig, onDismiss: loadConfigs) { config in
            ConfigFormView(mode: .edit(config), onSave: { updated in
                var all = WidgetConfigStore.loadAll()
                if let idx = all.firstIndex(where: { $0.id == updated.id }) {
                    all[idx] = updated
                }
                WidgetConfigStore.saveAll(all)
                WidgetCenter.shared.reloadAllTimelines()
                editingConfig = nil
            })
        }
        .alert("Eliminar configuración", isPresented: $showDeleteAlert, presenting: deletingConfig) { config in
            Button("Eliminar", role: .destructive) {
                deleteConfig(config)
            }
            Button("Cancelar", role: .cancel) {}
        } message: { config in
            Text("¿Eliminar '\(config.name)'?")
        }
        .onAppear(perform: loadConfigs)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Text("Sin configuraciones")
                .font(.headline)
                .foregroundColor(.secondary)
                .accessibilityIdentifier("emptyStateLabel")
            Button("Crear primera configuración") {
                showCreateSheet = true
            }
            .accessibilityIdentifier("createFirstConfigButton")
        }
    }

    private var configList: some View {
        List {
            ForEach(configs) { config in
                Button {
                    editingConfig = config
                } label: {
                    VStack(alignment: .leading) {
                        Text(config.name)
                            .foregroundColor(.primary)
                        Text(config.calendarIdentifier)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .accessibilityIdentifier("configRow_\(config.id)")
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        deletingConfig = config
                        showDeleteAlert = true
                    } label: {
                        Label("Eliminar", systemImage: "trash")
                    }
                    .accessibilityIdentifier("deleteButton_\(config.id)")
                }
            }
        }
        .accessibilityIdentifier("configList")
    }

    private func loadConfigs() {
        configs = WidgetConfigStore.loadAll()
    }

    private func deleteConfig(_ config: WidgetConfig) {
        var all = WidgetConfigStore.loadAll()
        all.removeAll { $0.id == config.id }
        WidgetConfigStore.saveAll(all)
        WidgetCenter.shared.reloadAllTimelines()
        loadConfigs()
    }
}
