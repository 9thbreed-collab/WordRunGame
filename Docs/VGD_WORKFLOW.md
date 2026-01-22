# WordRun VGD Workflow

## Source of Truth
- This repository is the only source of truth.
- Ignore archived repos, folders, and prior implementations.
- If it is not in this repo, it does not exist.
- Prefer minimal, verifiable steps.

## Session Versioning
Each session is tracked with an incremental version number:
- Format: `v0.0.XX` during foundation phase
- Increment XX with each new session
- Current version tracked in session summary and README
- Version history maintained in session summaries

## Session Workflow
1. **Session Start**: Review previous session summary and open questions
2. **Work Phase**: Document decisions as they are made
3. **Session Close**: Run closure agent to capture state, update docs, commit locally
4. **Continuity**: Next session reads current version and continues from documented state

## Documentation Structure
- `README.md` - Project overview, current status, version
- `docs/sessions/YYYY-MM-DD-session-summary.md` - Per-session record with version
- `docs/VGD_WORKFLOW.md` - This file, workflow and process rules
- `docs/DECISIONS.md` - Append-only log of decisions with dates
- `docs/PROMPTS.md` - Reusable prompts and AI agent instructions
- `CLAUDE.md` - AI context file (root level)

## Git Operations
- Commit locally at end of each session
- Push only when explicitly requested
- No force pushes to main/master
- Clean, descriptive commit messages with version and decisions

## Anti-Drift Measures
- Session summaries capture drift triggers observed
- Document "what" not "why we might"
- No speculative architecture or scaling decisions
- Explicit confirmation before major changes
- Minimal file creation; prefer editing existing files

## Build Theory
(To be updated - the model behind this workflow)
