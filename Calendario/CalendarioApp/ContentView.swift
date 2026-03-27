import SwiftUI

struct ContentView: View {
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "onboardingCompleted")
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        if horizontalSizeClass == .regular {
            NavigationSplitView {
                ConfigListView()
            } detail: {
                Text(String(localized: "Selecciona una configuración"))
                    .foregroundStyle(.secondary)
            }
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView(isPresented: $showOnboarding)
            }
        } else {
            NavigationStack {
                ConfigListView()
            }
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView(isPresented: $showOnboarding)
            }
        }
    }
}

#Preview {
    ContentView()
}
