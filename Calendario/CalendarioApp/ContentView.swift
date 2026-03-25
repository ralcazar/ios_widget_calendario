import SwiftUI

struct ContentView: View {
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "onboardingCompleted")

    var body: some View {
        NavigationStack {
            ConfigListView()
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView(isPresented: $showOnboarding)
        }
    }
}

#Preview {
    ContentView()
}
