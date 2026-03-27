import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "plus.rectangle.on.rectangle")
                .font(.system(size: 80))
                .foregroundStyle(.tint)

            VStack(spacing: 16) {
                Text(String(localized: "Añade el widget"))
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                Text(String(localized: "Mantén pulsada la pantalla de inicio y busca Calendario en los widgets"))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
            }

            Spacer()

            Button {
                UserDefaults.standard.set(true, forKey: "onboardingCompleted")
                isPresented = false
            } label: {
                Text(String(localized: "Entendido"))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .accessibilityIdentifier("onboarding_done_button")

            Spacer().frame(height: 60)
        }
        .accessibilityIdentifier("onboarding_view")
    }
}
