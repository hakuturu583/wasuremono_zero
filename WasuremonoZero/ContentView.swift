import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checklist")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("持ち物チェック")
                .font(.title2)
            Text("け / さ / キ / め を確認しましょう")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
