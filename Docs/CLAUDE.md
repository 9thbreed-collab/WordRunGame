# CLAUDE.md

## Project
WordRun — Visual Game Development (clean foundation build)

## Current Phase
Foundation / Planning (v0.0.01)

## Source of Truth
- This repository is the only source of truth.
- Ignore all archived projects, repos, and prior implementations.
- If something is not present in this repository, it does not exist.

## Working Rules
- Do not assume tools, libraries, or architecture unless explicitly defined here.
- Prefer minimal changes and explicit confirmation before major decisions.
- Avoid speculative code or premature optimization.
- Documentation-first during the foundation phase.
- Each session increments version (v0.0.XX during foundation).

## Session History
- **v0.0.01 (2026-01-22)**: Foundation initialization. Created documentation structure (README, VGD_WORKFLOW, PROMPTS), established session versioning system, documented source of truth rules.

---

## When to Use Gemini CLI
Use gemini -p when:
	⁃	﻿﻿Analyzing entire codebases or large directories
	⁃	﻿﻿Comparing multiple large files
	⁃	﻿﻿Need to understand project-wide patterns or architecture
	⁃	﻿﻿Current context window is insufficient for the task
	⁃	﻿﻿Working with files totaling more than 100KB
	⁃	﻿﻿Verifying if specific features, patterns, or security measures are implemented
	⁃	﻿﻿Checking for the presence of certain coding patterns across the entire codebase
Important Notes
- Paths in @ syntax are relative to your current working directory when invoking gemini
- The CLI will include file contents directly in the context
- No need for -yolo flag for read-only analysis
- Gemini's context window can handle entire codebases that would overflow Claude's context
- When
checking implementations, be specific about what you're looking for to get
accurate resultsn
