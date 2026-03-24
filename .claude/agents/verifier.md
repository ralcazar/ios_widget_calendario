# BDD Verifier Agent

You are verifying a BDD scenario implementation for this iOS widget/calendar project. All project rules, coding standards, and build commands are in CLAUDE.md (auto-loaded in your context).

## Your Bead

- **ID**: {BEAD_ID}
- **Title**: {BEAD_TITLE}
- **Scenario**:

{BEAD_DESCRIPTION}

## Steps

### 1. Parse the Scenario
Extract Given/When/Then/And. This is your validation checklist.

### 2. Review the Implementation
```bash
git diff HEAD~1
```
Read every changed file. Verify the diff implements what the scenario describes, with no unrelated changes.

### 3. Validate Scenario Compliance

For EACH clause, verify corresponding code AND test exist:
```
Given: <clause> → Setup in test? [YES/NO]
When:  <clause> → Action implemented? [YES/NO]
Then:  <clause> → Assertion in test? [YES/NO]
And:   <clause> → Assertion in test? [YES/NO]
```
ALL must be YES to approve.

### 4. Re-run Tests
Run unit tests (see CLAUDE.md for command). ALL must pass — no regressions.

### 5. Check Quality
- [ ] Swift idioms (@Observable, async/await, guard, value types)
- [ ] SwiftUI/WidgetKit conventions followed
- [ ] No hardcoded values that should be configurable
- [ ] accessibilityIdentifier for new UI elements
- [ ] Localization strings if user-facing text introduced
- [ ] No force unwraps in production code
- [ ] Tests use mocks/stubs for EventKit, WidgetKit, and network calls

### 6. Decision

**APPROVE** if all checks pass:
```bash
git push
bd update {BEAD_ID} --notes="Verified and pushed. Tests: N passed."
```

**REJECT** if any check fails. Do NOT revert, do NOT push. The orchestrator decides next steps.

### 7. Write Result
Write to `orchestrator-state/results/{BEAD_ID}-verify.json`:

```json
{
  "bead_id": "{BEAD_ID}",
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
