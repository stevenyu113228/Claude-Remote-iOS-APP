import SwiftUI

struct MainView: View {
    @Environment(AppState.self) private var appState
    @State private var showSettings = false
    @State private var showProfileEdit = false
    @State private var editingProfile: DeviceProfile?

    var body: some View {
        VStack(spacing: 0) {
            // Top bar: device tabs + settings gear
            HStack(spacing: 0) {
                DeviceTabBar(
                    onAdd: { editingProfile = nil; showProfileEdit = true },
                    onEdit: { profile in editingProfile = profile; showProfileEdit = true }
                )

                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gear")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                }
                .background(Color(red: 0.08, green: 0.08, blue: 0.08))
            }

            // Session or empty state
            if let profile = appState.selectedProfile {
                let connection = appState.connectionFor(profile: profile)
                DeviceSessionView(profile: profile, connection: connection)
                    .id(profile.id)
            } else {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "desktopcomputer")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("No Devices")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Button {
                        editingProfile = nil
                        showProfileEdit = true
                    } label: {
                        Label("Add Device", systemImage: "plus")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(RoundedRectangle(cornerRadius: 10).fill(.blue))
                    }
                }
                Spacer()
            }
        }
        .background(Color(red: 0.1, green: 0.1, blue: 0.1))
        .onAppear {
            appState.migrateIfNeeded()
            // Auto-select first profile if none selected
            if appState.selectedProfileID == nil, let first = appState.profiles.first {
                appState.selectedProfileID = first.id
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showProfileEdit) {
            ProfileEditView(editingProfile: editingProfile)
        }
    }
}
