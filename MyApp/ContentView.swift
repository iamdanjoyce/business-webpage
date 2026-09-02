import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "swift")
                .font(.system(size: 56))
                .foregroundStyle(.tint)
            Text("Hello, MyApp")
                .font(.title2.weight(.semibold))
            Text("Edit ContentView.swift to get started.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
