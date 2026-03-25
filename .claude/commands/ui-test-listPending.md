# List Beads Pending UI Tests

Show all closed beads that don't have UI tests yet.

## Steps

1. Run `bd list --label ui-test-pending --all`
2. Show results as a list: bead ID, title
3. Show count: "N beads pending UI tests"
4. If no results: "All beads have UI tests."
5. Suggest: "Run `/ui-test-createPending` to create UI tests for all pending beads."
