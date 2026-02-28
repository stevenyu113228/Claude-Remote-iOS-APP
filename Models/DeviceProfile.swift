import Foundation

struct DeviceProfile: Codable, Identifiable, Equatable {
    var id = UUID()
    var name: String
    var tailscaleIP: String
    var ttydPort: Int = 7681
    var apiPort: Int = 8080
    var tmuxSession: String = "claude"

    var apiBaseURL: String { "http://\(tailscaleIP):\(apiPort)" }
}
