import SwiftUI

struct NotificationSettingsView: View {
    // Use local @State to track toggle states, synced with NotificationManager
    @State private var toggleStates: [String: Bool] = [:]

    var body: some View {
        List {
            Section {
                ForEach(NotificationManager.NotificationKey.allCases, id: \.rawValue) { key in
                    Toggle(key.displayName, isOn: Binding(
                        get: { toggleStates[key.rawValue] ?? NotificationManager.shared.isEnabled(key) },
                        set: { newValue in
                            toggleStates[key.rawValue] = newValue
                            NotificationManager.shared.toggle(key, enabled: newValue)
                        }
                    ))
                    .tint(Color.primaryGreen)
                }
            } header: {
                Text("Daily Reminders")
            } footer: {
                Text("Notifications repeat daily at the scheduled time.")
                    .font(.caption)
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            for key in NotificationManager.NotificationKey.allCases {
                toggleStates[key.rawValue] = NotificationManager.shared.isEnabled(key)
            }
        }
    }
}

#Preview {
    NavigationStack {
        NotificationSettingsView()
    }
}
