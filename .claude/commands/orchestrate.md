# BDD Orchestration Loop

You are the BDD orchestrator. Process Gherkin scenarios (beads) by launching subagents, while remaining interactive for the user.

## Setup

1. Create tmux session:
```bash
tmux has-session -t bdd 2>/dev/null || tmux new-session -d -s bdd -n status
tmux new-window -t bdd -n impl 2>/dev/null || true
tmux new-window -t bdd -n verify 2>/dev/null || true
```
2. Start status monitor in tmux:
```bash
tmux send-keys -t bdd:status "watch -n 3 'cat orchestrator-state/state.json 2>/dev/null | python3 -m json.tool 2>/dev/null || echo Waiting...'" Enter
```
3. Tell user: "Tmux 'bdd' ready. Run `tmux attach -t bdd` to monitor."

## Loop

Repeat until no ready beads or user says "stop":

### 1. Pick Bead
`bd ready` → pick first. `bd show <id>` for details. If none → idle, stop.

### 2. Claim
`bd update <id> --claim`. Update state.json: `status: busy, current_bead, stage: implementation`.

### 3. Launch Implementer
1. Read `.claude/agents/implementer.md`, replace `{BEAD_ID}`, `{BEAD_TITLE}`, `{BEAD_DESCRIPTION}` with bead data
2. Write composed prompt to `orchestrator-state/impl-prompt.md`
3. Launch in background (`run_in_background: true`):
```bash
claude -p "$(cat orchestrator-state/impl-prompt.md)" --dangerously-skip-permissions 2>&1 | tee orchestrator-state/impl.log
```
4. Tail log in tmux: `tmux send-keys -t bdd:impl "tail -f orchestrator-state/impl.log" Enter`
5. Inform user: "Implementer working on <id>. You can keep working here."

### 4. Remain Interactive
User can: ask questions, create beads, check progress, manage queue. Background task notifies on completion.

### 5. Implementer Result
Read `orchestrator-state/results/<id>.json`:
- **failed** → `bd update <id> --notes="Impl failed: <error>"`, add to `failed`, continue loop
- **success** → stage: verification, proceed

### 6. Launch Verifier
Same as step 3 but with `.claude/agents/verifier.md`. Log to `orchestrator-state/verify.log`, tail in `bdd:verify`.

### 7. Verifier Result
Read `orchestrator-state/results/<id>-verify.json`:
- **approve** →
  1. `bd close <id>`, add to `completed`
  2. `bd update <id> --add-label ui-test-pending`
  3. `bd dolt push`
  4. Inform user: "Bead <id> completed. UI tests pending — run `/ui-test-createPending` when ready."
- **reject** → Ask user what to do: (a) revert commit and requeue, (b) leave for manual fix, (c) skip. Update bead accordingly.

### 8. Clean Up
`rm -f orchestrator-state/*-prompt.md`. Go to step 1.

## UI Test Reminder

At the start of the loop and after every 3 beads completed:
1. Run `bd list --label ui-test-pending --all` — if any results, remind: "N beads pending UI tests. Run `/ui-test-listPending` to see, `/ui-test-createPending` to create them."
2. Check `orchestrator-state/state.json` field `last_ui_test_run` — if `null` or older than `ui_test_stale_days` (from config.json): remind "UI tests haven't run since <date>. Run `/ui-test-runAll`."
- Do NOT block work for reminders — informational only.

## Rules

- ONE bead at a time
- Update state.json before/after each stage
- Remain responsive to user between steps
- "stop"/"pause" → finish current bead, then stop
- "skip" → abandon current, move to next
- NEVER implement code yourself — delegate to subagents
- Subagents run unit tests ONLY — NEVER UI tests
