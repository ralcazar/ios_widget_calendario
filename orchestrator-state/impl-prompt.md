# BDD Implementer Agent

You are implementing a BDD scenario for this iOS widget/calendar project. Project rules, coding standards, and build commands are in CLAUDE.md. Beads workflow context is auto-injected via `bd prime`.

## Your Bead

- **ID**: CAL-u91.4
- **Title**: 6.2 Onboarding — guía inicial y primer widget
- **Scenario**:

```gherkin
Feature: Onboarding — guía inicial y primer widget

  Scenario: Primera apertura muestra onboarding
    Given que es la primera vez que el usuario abre la app
    And 'onboardingCompleted' no está en UserDefaults
    When se carga ContentView
    Then aparece el flujo de onboarding (fullScreenCover con 3 pasos)

  Scenario: Conceder permisos avanza al paso 2
    Given que estoy en el paso 1 del onboarding
    When concedo acceso al calendario
    Then avanzo al paso 2 (crear primera configuración)

  Scenario: Saltar configuración avanza al paso 3
    Given que estoy en el paso 2 del onboarding
    When pulso 'Omitir'
    Then avanzo al paso 3 (instrucciones de widget)

  Scenario: Pulsar Listo completa el onboarding
    Given que estoy en el paso 3 del onboarding
    When pulso 'Listo'
    Then 'onboardingCompleted' se guarda como true en UserDefaults
    And el onboarding no vuelve a aparecer

  Scenario: Onboarding no aparece en segundas aperturas
    Given que 'onboardingCompleted' = true en UserDefaults
    When se carga ContentView
    Then no aparece el onboarding
```

## Implementation Details

### OnboardingView.swift (new file in Calendario/CalendarioApp/)
A fullScreenCover view with 3 pages using TabView paged style:

```swift
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
```

### Step 1 — Permissions
- Title: String(localized: "Bienvenido a Calendario")
- Subtitle: String(localized: "Necesitamos acceso a tu calendario para mostrar tus eventos.")
- Button: String(localized: "Continuar") — calls EKEventStore().requestFullAccessToEvents()
- If denied: show alert with link to Settings + "Continuar de todos modos" option
- accessibilityIdentifier: "onboarding_step1", "onboarding_continue_button"

### Step 2 — First Configuration
- Title: String(localized: "Crea tu primera configuración")
- Reuse ConfigFormView inline or simplified form
- Button: String(localized: "Guardar y continuar") → save config, advance
- Skip button in toolbar: String(localized: "Omitir")
- accessibilityIdentifier: "onboarding_step2", "onboarding_skip_button"

### Step 3 — Widget Instructions
- Title: String(localized: "Añade tu widget")
- 3 numbered steps as Text
- SF Symbol: "rectangle.on.rectangle.angled"
- Button: String(localized: "Listo")
- accessibilityIdentifier: "onboarding_step3", "onboarding_done_button"

### ContentView integration
```swift
@State private var showOnboarding = !UserDefaults.standard.bool(forKey: "onboardingCompleted")

var body: some View {
    // existing content
    .fullScreenCover(isPresented: $showOnboarding) {
        OnboardingView(isPresented: $showOnboarding)
    }
}
```

## Steps

### 0. Claim
```bash
bd update CAL-u91.4 --claim
```

### 1. Read Existing Code
Key files:
- Calendario/CalendarioApp/ContentView.swift (add fullScreenCover trigger)
- Calendario/CalendarioApp/ConfigFormView.swift (reuse in step 2)
- CalendarioTests/ (existing test structure)

### 2. Implement
Create OnboardingView.swift with the 3-step flow. Integrate into ContentView.

### 3. Write Tests
Create `CalendarioTests/CALu914ScenarioTests.swift`. Naming: `test_CALu914_given_<setup>_when_<action>_then_<outcome>()`.

Test logic (no SwiftUI view tests):
- onboardingCompleted not set → should show onboarding (bool default false)
- onboardingCompleted = true → should not show onboarding
- Setting onboardingCompleted = true → UserDefaults persists correctly
- Resetting onboardingCompleted (removeObject) → defaults to false again

### 4. Run Tests
```bash
xcodebuild test -project Calendario/Calendario.xcodeproj -scheme CalendarioTests \
  -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -20
```

### 5. Commit
```bash
git add <specific files>
git commit -m "$(cat <<'EOF'
impl(CAL-u91.4): 6.2 Onboarding — guía inicial y primer widget

Scenario: 3-step onboarding shown on first launch, gated by UserDefaults flag
Tests: N passed

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"
```

Do NOT push.

### 6. Write Result
Write to `orchestrator-state/results/CAL-u91.4.json`:

```json
{
  "bead_id": "CAL-u91.4",
  "status": "success|failed",
  "files_created": [],
  "files_modified": [],
  "tests_added": [],
  "tests_passed": 0,
  "tests_failed": 0,
  "commit_hash": "",
  "error": null
}
```

## If You Cannot Implement

1. Write result with `"status": "failed"` and `"error": "<explanation>"`
2. Clean up: `git checkout .`
3. `bd update CAL-u91.4 --notes="Impl failed: <error>"`
4. Exit
