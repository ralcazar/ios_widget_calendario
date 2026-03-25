# Create UI Tests for Pending Beads

Create XCUITest tests for all closed beads that don't have UI tests yet.

## Steps

1. Run `bd list --label ui-test-pending --all`
2. If no results: "No beads pending UI tests." Stop.
3. For each pending bead:
   a. `bd show <id>` to get the full Gherkin scenario
   b. Determine if the scenario involves UI flows (views, navigation, user interaction)
   c. If yes: write XCUITest test in `CodeReviewAppUITests/` following the Given/When/Then structure
   d. If no (pure logic/service): skip
   e. Update bead: `bd update <id> --remove-label ui-test-pending --add-label ui-test-created`
4. Commit all new UI tests:
```bash
git add CodeReviewAppUITests/
git commit -m "test(ui): create XCUITests for pending beads

Beads covered: <list of bead IDs>

Co-Authored-By: Claude <noreply@anthropic.com>"
```
5. Report summary: how many tests created, which beads covered, which skipped

## XCUITest Structure

```swift
final class <Feature>UITests: XCTestCase {
    // MARK: - <bead-id>: <title>

    func test_<beadId>_<scenario>() {
        let app = XCUIApplication()
        app.launch()

        // Given — navigate to precondition state
        // When  — perform user action
        // Then  — assert UI state
    }
}
```

- Use `accessibilityIdentifier` for element locators (see existing tests for patterns)
- Use `BaseUITest` as base class if shared setup needed
- Do NOT run the tests — that's `/ui-test-runAll`

## Note

This command creates tests but does NOT run them. Run `/ui-test-runAll` after to validate.
