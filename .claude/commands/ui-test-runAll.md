# Run All UI Tests

Run the full XCUITest suite and update tracking state. Slow operation (15-20 min).

## When to Run

- After `/ui-test-createPending` to validate new UI tests
- Before creating a PR or cutting a release
- When the orchestrator reminds you that UI tests are stale
- Periodically as regression check

## Steps

1. Inform user: "Running full UI test suite. This takes 15-20 minutes."
2. Run UI tests (see CLAUDE.md Build section for the UI test command)
3. Parse results: count passed/failed
4. Update `orchestrator-state/state.json`:
   - `last_ui_test_run` → current ISO timestamp
   - `last_ui_test_result` → `"passed"` or `"failed"`
   - `last_ui_test_summary` → e.g. "42 passed, 0 failed"
5. Report results to user

## If Tests Fail

Show failing tests and ask user how to proceed:
- Fix now (investigate and fix in this session)
- Create beads for failures (defer to orchestration)
- Acknowledge and defer
