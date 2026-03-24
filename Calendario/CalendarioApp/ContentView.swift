import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "calendar")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Calendario")
        }
        .padding()
        .accessibilityIdentifier("contentView")
    }
}

#Preview {
    ContentView()
}
