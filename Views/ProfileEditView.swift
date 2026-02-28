import SwiftUI

struct ProfileEditView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    var editingProfile: DeviceProfile?

    @State private var name = ""
    @State private var ip = ""
    @State private var ttydPort = "7681"
    @State private var apiPort = "8080"
    @State private var tmuxSession = "claude"
    @State private var testResult = ""
    @State private var isTesting = false

    private var isEditing: Bool { editingProfile != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Device") {
                    HStack {
                        Text("Name")
                            .foregroundStyle(.secondary)
                        TextField("MacBook Pro", text: $name)
                            .multilineTextAlignment(.trailing)
                            .autocorrectionDisabled()
                    }
                }

                Section("Connection") {
                    HStack {
                        Text("Tailscale IP")
                            .foregroundStyle(.secondary)
                        TextField("100.x.y.z", text: $ip)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                    HStack {
                        Text("ttyd Port")
                            .foregroundStyle(.secondary)
                        TextField("7681", text: $ttydPort)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                    }
                    HStack {
                        Text("API Port")
                            .foregroundStyle(.secondary)
                        TextField("8080", text: $apiPort)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                    }
                    HStack {
                        Text("tmux Session")
                            .foregroundStyle(.secondary)
                        TextField("claude", text: $tmuxSession)
                            .multilineTextAlignment(.trailing)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                }

                Section("Test") {
                    Button {
                        testConnection()
                    } label: {
                        HStack {
                            Text("Test Connection")
                            Spacer()
                            if isTesting {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(ip.isEmpty || isTesting)

                    if !testResult.isEmpty {
                        Text(testResult)
                            .font(.caption)
                            .foregroundStyle(testResult.contains("Success") ? .green : .red)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Device" : "Add Device")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .disabled(name.isEmpty || ip.isEmpty)
                }
            }
            .onAppear { loadProfile() }
            .preferredColorScheme(.dark)
        }
    }

    private func loadProfile() {
        guard let profile = editingProfile else { return }
        name = profile.name
        ip = profile.tailscaleIP
        ttydPort = String(profile.ttydPort)
        apiPort = String(profile.apiPort)
        tmuxSession = profile.tmuxSession
    }

    private func save() {
        if var profile = editingProfile {
            profile.name = name
            profile.tailscaleIP = ip
            profile.ttydPort = Int(ttydPort) ?? 7681
            profile.apiPort = Int(apiPort) ?? 8080
            profile.tmuxSession = tmuxSession
            appState.updateProfile(profile)
        } else {
            let profile = DeviceProfile(
                name: name,
                tailscaleIP: ip,
                ttydPort: Int(ttydPort) ?? 7681,
                apiPort: Int(apiPort) ?? 8080,
                tmuxSession: tmuxSession
            )
            appState.addProfile(profile)
        }
        dismiss()
    }

    private func testConnection() {
        isTesting = true
        testResult = ""

        Task {
            do {
                let port = Int(ttydPort) ?? 7681
                let url = URL(string: "http://\(ip):\(port)/token")!
                let (_, response) = try await URLSession.shared.data(from: url)
                if let http = response as? HTTPURLResponse, http.statusCode == 200 {
                    testResult = "Success: ttyd reachable"
                } else {
                    testResult = "Error: unexpected response"
                }
            } catch {
                testResult = "Error: \(error.localizedDescription)"
            }
            isTesting = false
        }
    }
}
