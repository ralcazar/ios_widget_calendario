# BDD Verifier Agent

You are verifying a BDD scenario implementation for this iOS widget/calendar project. All project rules, coding standards, and build commands are in CLAUDE.md (auto-loaded in your context).

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

## Implementation Result (from implementer)

Files created:
- Calendario/CalendarioApp/OnboardingView.swift
- CalendarioTests/CALu914ScenarioTests.swift

Files modified:
- Calendario/CalendarioApp/ContentView.swift (fullScreenCover trigger)
- Calendario/Calendario.xcodeproj/project.pbxproj

Tests: 4 added, 4 passed. Commit: 65f0a07

## Steps

### 1. Parse the Scenario

### 2. Review the Implementation
```bash
git diff HEAD~1
```

### 3. Validate Scenario Compliance
For EACH clause, verify code AND test exist. ALL must be YES to approve.

### 4. Re-run Tests
```bash
xcodebuild test -project Calendario/Calendario.xcodeproj -scheme CalendarioTests \
  -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -20
```

### 5. Check Quality
- [ ] TabView paged style for 3 steps
- [ ] fullScreenCover gated by !UserDefaults.standard.bool(forKey: "onboardingCompleted")
- [ ] "Listo" button sets onboardingCompleted = true
- [ ] accessibilityIdentifier on: onboarding_tabview, onboarding_step1/2/3, onboarding_done_button, onboarding_skip_button, onboarding_continue_button
- [ ] All user-facing strings use String(localized:)
- [ ] No force unwraps

### 6. Decision

**APPROVE** if all checks pass:
```bash
git push
bd update CAL-u91.4 --notes="Verified and pushed. Tests: N passed."
```

**REJECT** if any check fails. Do NOT revert, do NOT push.

### 7. Write Result
Write to `orchestrator-state/results/CAL-u91.4-verify.json`:

```json
{
  "bead_id": "CAL-u91.4",
  "decision": "approve|reject",
  "scenario_compliance": {
    "given_covered": true,
    "when_implemented": true,
    "then_tested": true,
    "and_tested": true
  },
  "tests_passed": 0,
  "tests_failed": 0,
  "quality_issues": [],
  "pushed": false,
  "rejection_reasons": []
}
```
