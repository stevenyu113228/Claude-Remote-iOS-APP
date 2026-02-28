import Foundation

@Observable
class DeviceConnection {
    let profile: DeviceProfile
    var connectionStatus: ConnectionStatus = .disconnected
    let ttydClient = TtydClient()
    let apiClient = APIClient()
    let bridge: TerminalBridge

    init(profile: DeviceProfile) {
        self.profile = profile
        self.bridge = TerminalBridge(client: ttydClient)
        self.apiClient.baseURL = profile.apiBaseURL
        self.ttydClient.onDisconnect = { [weak self] in
            self?.connectionStatus = .disconnected
        }
    }

    func connect() {
        guard !profile.tailscaleIP.isEmpty else { return }
        connectionStatus = .connecting
        Task {
            do {
                try await ttydClient.connect(
                    host: profile.tailscaleIP,
                    port: profile.ttydPort
                )
                await MainActor.run { self.connectionStatus = .connected }
            } catch {
                await MainActor.run { self.connectionStatus = .disconnected }
            }
        }
    }

    func disconnect() {
        ttydClient.disconnect()
        connectionStatus = .disconnected
    }
}
