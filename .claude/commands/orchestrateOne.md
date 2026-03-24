# Orchestrate One Bead

Process a single bead (non-loop mode). Useful for manual/incremental work.

## Steps

1. Run `bd ready` to show available beads
2. Show the list to the user and ask which one to work on (or auto-pick first if user says "just go")
3. Run `bd show <id>` to display the full Gherkin scenario
4. Confirm with user before proceeding
5. Follow the same implement → verify flow as `/orchestrate` (Steps 2-7) but for this single bead only. On approve: `bd update <id> --add-label ui-test-pending`
6. After completion (success or failure), stop and report result to user
7. Run `bd list --label ui-test-pending --all` and check `last_ui_test_run` staleness. Remind if needed.

## Differences from /orchestrate

- Does NOT auto-loop to next bead
- Shows bead details and asks for confirmation before starting
- Reports final result and stops
- Does NOT require tmux setup (but will use it if session exists)

## Usage

- `/orchestrateOne` → pick first ready bead, ask for confirmation
- `/orchestrateOne beads-abc123` → work on specific bead
