import SwiftUI
import EventKit

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0

    var body: some View {
        TabView(selection: $currentPage) {
            OnboardingStep1View(onNext: { currentPage = 1 })
                .tag(0)
            OnboardingStep2View(onNext: { currentPage = 2 }, onSkip: { currentPage = 2 })
                .tag(1)
            OnboardingStep3View(onDone: {
                UserDefaults.standard.set(true, forKey: "onboardingCompleted")
                isPresented = false
            })
                .tag(2)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .accessibilityIdentifier("onboarding_tabview")
    }
}

// MARK: - Step 1: Permissions

struct OnboardingStep1View: View {
    let onNext: () -> Void
    @State private var showDeniedAlert = false
    @State private var isRequesting = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "calendar.badge.checkmark")
                .font(.system(size: 80))
                .foregroundStyle(.tint)

            VStack(spacing: 16) {
                Text(String(localized: "Bienvenido a Calendario"))
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                Text(String(localized: "Necesitamos acceso a tu calendario para mostrar tus eventos."))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
            }

            Spacer()

            Button {
                Task {
                    isRequesting = true
                    let store = EKEventStore()
                    do {
                        if #available(iOS 17.0, *) {
                            try await store.requestFullAccessToEvents()
                        } else {
                            try await store.requestAccess(to: .event)
                        }
                    } catch {
                        // Denied or restricted
                    }
                    isRequesting = false
                    let status = EKEventStore.authorizationStatus(for: .event)
                    if status == .denied || status == .restricted {
                        showDeniedAlert = true
                    } else {
                        onNext()
                    }
                }
            } label: {
                Text(String(localized: "Continuar"))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .disabled(isRequesting)
            .accessibilityIdentifier("onboarding_continue_button")

            Spacer().frame(height: 60)
        }
        .accessibilityIdentifier("onboarding_step1")
        .alert(String(localized: "Acceso denegado"), isPresented: $showDeniedAlert) {
            Button(String(localized: "Ir a Ajustes")) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button(String(localized: "Continuar de todos modos")) {
                onNext()
            }
        } message: {
            Text(String(localized: "Puedes habilitar el acceso en Ajustes > Privacidad > Calendarios."))
        }
    }
}

// MARK: - Step 2: First Configuration

struct OnboardingStep2View: View {
    let onNext: () -> Void
    let onSkip: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 80))
                    .foregroundStyle(.tint)

                VStack(spacing: 16) {
                    Text(String(localized: "Crea tu primera configuración"))
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)

                    Text(String(localized: "Configura qué calendarios y eventos aparecen en tu widget."))
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal)
                }

                Spacer()

                Button {
                    onNext()
                } label: {
                    Text(String(localized: "Guardar y continuar"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                .accessibilityIdentifier("onboarding_save_continue_button")

                Spacer().frame(height: 60)
            }
            .accessibilityIdentifier("onboarding_step2")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "Omitir")) {
                        onSkip()
                    }
                    .accessibilityIdentifier("onboarding_skip_button")
                }
            }
        }
    }
}

// MARK: - Step 3: Widget Instructions

struct OnboardingStep3View: View {
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "rectangle.on.rectangle.angled")
                .font(.system(size: 80))
                .foregroundStyle(.tint)

            VStack(spacing: 16) {
                Text(String(localized: "Añade tu widget"))
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 16) {
                Label {
                    Text(String(localized: "Mantén pulsada la pantalla de inicio hasta que los iconos empiecen a moverse."))
                } icon: {
                    Text("1.").bold().frame(width: 24)
                }

                Label {
                    Text(String(localized: "Pulsa el botón \"+\" en la esquina superior izquierda."))
                } icon: {
                    Text("2.").bold().frame(width: 24)
                }

                Label {
                    Text(String(localized: "Busca \"Calendario\" y selecciona el tamaño de widget que prefieras."))
                } icon: {
                    Text("3.").bold().frame(width: 24)
                }
            }
            .padding(.horizontal)

            Spacer()

            Button {
                onDone()
            } label: {
                Text(String(localized: "Listo"))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .accessibilityIdentifier("onboarding_done_button")

            Spacer().frame(height: 60)
        }
        .accessibilityIdentifier("onboarding_step3")
    }
}
