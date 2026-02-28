import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var fontSize: Double = 14

    var body: some View {
        NavigationStack {
            Form {
                Section("Terminal") {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Font Size")
                            Spacer()
                            Text("\(Int(fontSize))pt")
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $fontSize, in: 10...24, step: 1)
                    }
                }

                Section("About") {
                    HStack {
                        Text("App")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("Claude Code Remote")
                    }
                    HStack {
                        Text("Terminal")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("SwiftTerm")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                }
            }
            .onAppear {
                fontSize = Double(appState.fontSize)
            }
            .preferredColorScheme(.dark)
        }
    }

    private func save() {
        appState.fontSize = CGFloat(fontSize)
        dismiss()
    }
}
