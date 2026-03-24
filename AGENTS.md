# Agent Instructions

This project uses **bd** (beads) for issue tracking. Run `bd prime` to get full workflow context.

## Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --claim  # Claim work atomically
bd close <id>         # Complete work
bd dolt push          # Push beads to remote
```

## Non-Interactive Shell Commands

**ALWAYS use non-interactive flags** to avoid hanging on confirmation prompts:

```bash
cp -f source dest     # NOT: cp source dest
mv -f source dest     # NOT: mv source dest
rm -f file            # NOT: rm file
rm -rf directory      # NOT: rm -r directory
```

## BDD Orchestration

This project uses a three-agent model:

```
User Session (interactive)
    ↓
ORCHESTRATOR (main Claude Code session)
    ├── IMPLEMENTER (subagent — fresh context per bead)
    └── VERIFIER (subagent — fresh context per bead)
```

- `/orchestrate` — full loop over all ready beads
- `/orchestrateOne [bead-id]` — single bead with confirmation

## Issue Tracking with bd (beads)

**IMPORTANT**: Use **bd** for ALL task tracking. No markdown TODOs, no TaskCreate.

### Workflow

1. **Check ready work**: `bd ready`
2. **Claim atomically**: `bd update <id> --claim`
3. **Work on it**: implement, test, document
4. **Complete**: `bd close <id>`

### Rules

- ✅ Use bd for ALL task tracking
- ✅ Write tests for every bead (unit tests mandatory; UI tests created post-close)
- ✅ Run ONLY unit tests per bead — NEVER UI tests during individual bead work
- ✅ Test name format: `test_{beadId}_given_<setup>_when_<action>_then_<outcome>()`
- ✅ Verifier pushes — implementer NEVER pushes
- ❌ Do NOT create markdown TODO lists
- ❌ Do NOT use TodoWrite or TaskCreate

## Landing the Plane (Session Completion)

**MANDATORY WORKFLOW before ending any session:**

1. **File issues for remaining work**
2. **Run quality gates** (tests, linters, build)
3. **Update issue status** (close finished work)
4. **PUSH TO REMOTE**:
   ```bash
   git pull --rebase
   bd dolt push
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Verify** — all changes committed AND pushed

**CRITICAL**: Work is NOT complete until `git push` succeeds. NEVER say "ready to push when you are" — YOU must push.
