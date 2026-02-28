import SwiftUI

struct DeviceSessionView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.scenePhase) private var scenePhase
    let profile: DeviceProfile
    let connection: DeviceConnection

    var body: some View {
        VStack(spacing: 0) {
            // Connection status bar
            connectionBar

            // tmux tab bar
            if connection.connectionStatus == .connected {
                TmuxTabBar(apiClient: connection.apiClient, tmuxSession: profile.tmuxSession)
            }

            // Terminal
            TerminalContainerView(bridge: connection.bridge)
                .ignoresSafeArea(.keyboard)

            // Quick keys
            if connection.connectionStatus == .connected {
                QuickKeysView(client: connection.ttydClient)
            }

            // Input bar
            InputBarView(client: connection.ttydClient, apiClient: connection.apiClient)
        }
        .onAppear { connectIfNeeded() }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                if connection.connectionStatus == .disconnected {
                    connection.connect()
                }
            case .background:
                connection.disconnect()
            default:
                break
            }
        }
    }

    private var connectionBar: some View {
        HStack {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            Text(connection.connectionStatus.rawValue.capitalized)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Text(profile.tailscaleIP)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(red: 0.15, green: 0.15, blue: 0.15))
    }

    private var statusColor: Color {
        switch connection.connectionStatus {
        case .connected: .green
        case .connecting: .orange
        case .disconnected: .red
        }
    }

    private func connectIfNeeded() {
        if connection.connectionStatus == .disconnected {
            connection.connect()
        }
    }
}
