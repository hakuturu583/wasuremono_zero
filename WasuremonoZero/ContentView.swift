import SwiftUI

struct ContentView: View {
    @State private var settings: AppSettings
    private let settingsStore: SettingsStore

    init(settingsStore: SettingsStore = SettingsStore()) {
        self.settingsStore = settingsStore
        _settings = State(initialValue: settingsStore.load())
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("対象項目") {
                    ForEach(CheckItem.allCases, id: \.rawValue) { item in
                        Toggle(item.label, isOn: binding(for: item))
                    }
                }

                Section("通知のしきい値") {
                    Stepper(
                        "最短通知間隔: \(settings.minimumIntervalMinutes) 分",
                        value: $settings.minimumIntervalMinutes,
                        in: 5...240,
                        step: 5
                    )

                    Stepper(
                        "最小移動距離: \(Int(settings.minimumDistanceMeters)) m",
                        value: $settings.minimumDistanceMeters,
                        in: 50...1000,
                        step: 50
                    )
                }
            }
            .navigationTitle("持ち物チェック")
        }
        .onChange(of: settings) { updatedSettings in
            settingsStore.save(updatedSettings)
        }
    }

    private func binding(for item: CheckItem) -> Binding<Bool> {
        Binding(
            get: { settings.enabledItems.contains(item) },
            set: { isEnabled in
                if isEnabled {
                    settings.enabledItems.insert(item)
                } else {
                    settings.enabledItems.remove(item)
                }
            }
        )
    }
}

#Preview {
    ContentView()
}
