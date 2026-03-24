# Project Instructions for AI Agents

This file provides instructions and context for AI coding agents working on this project.

<!-- BEGIN BEADS INTEGRATION v:1 profile:minimal hash:b9766037 -->
## Beads Issue Tracker

This project uses **bd (beads)** for issue tracking. Run `bd prime` to see full workflow context and commands.

### Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --claim  # Claim work
bd close <id>         # Complete work
```

### Rules

- Use `bd` for ALL task tracking — do NOT use TodoWrite, TaskCreate, or markdown TODO lists
- Run `bd prime` for detailed command reference and session close protocol
- Use `bd remember` for persistent knowledge — do NOT use MEMORY.md files

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd dolt push
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds
<!-- END BEADS INTEGRATION -->


## Build & Test

_Fill in once the Xcode project is created. Commands will follow this pattern:_

```bash
# Unit tests only (per bead):
# xcodebuild test -project <App>.xcodeproj -scheme <AppTests> \
#   -destination 'platform=iOS Simulator,name=iPhone 16'

# UI tests (at epic close):
# xcodebuild test -project <App>.xcodeproj -scheme <App> \
#   -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Architecture Overview

iOS widget + companion app for calendar filtering and visualization.

- **Tech stack**: Swift, SwiftUI, WidgetKit, EventKit
- **iOS target**: iOS 17+
- **Key frameworks**: WidgetKit (widget extension), EventKit (calendar access), AppIntents (widget config)
- **Data flow**: Companion app manages configurations → shared via App Group → widget reads and renders

## BDD Orchestration

This project uses a multi-agent BDD workflow for implementation:

- `/orchestrate` — loop through all ready beads (implementer + verifier per bead)
- `/orchestrateOne` — process a single bead with confirmation

Agents are defined in `.claude/agents/`. State is tracked in `orchestrator-state/`.

**Rules**:
- Unit tests ONLY during per-bead work (NEVER UI tests during `xcodebuild test -scheme <AppTests>`)
- UI tests created after bead close, run at epic close
- Verifier pushes — implementer never pushes

## Conventions & Patterns

- Swift idioms: `@Observable`, `async/await`, `guard`, value types, `@AppStorage`
- No force unwraps in production code
- `accessibilityIdentifier` required for all interactive UI elements
- Localization: all user-facing strings via `String(localized:)`
- Test naming: `test_{beadId}_given_<setup>_when_<action>_then_<outcome>()`
