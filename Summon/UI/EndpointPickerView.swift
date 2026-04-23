import SwiftUI

struct EndpointPickerView: View {
    @Bindable var endpointManager: EndpointManager
    @Bindable var settingsStore: SettingsStore

    var body: some View {
        HStack(spacing: 12) {
            Picker("Endpoint", selection: Binding(
                get: { settingsStore.currentEndpointID },
                set: { id in
                    settingsStore.setCurrentEndpointID(id)
                    endpointManager.selectEndpoint(id: id)
                }
            )) {
                ForEach(endpointManager.endpoints) { endpoint in
                    Text(endpoint.name).tag(endpoint.id)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()

            if let selected = endpointManager.selectedEndpoint {
                Text(selected.model)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}
