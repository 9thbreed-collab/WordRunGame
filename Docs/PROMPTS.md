# WordRun VGD Reusable Prompts

This file contains reusable prompts and agent instructions for WordRun development.

---

## When to Use Gemini CLI

Use `gemini -p` when:
- Analyzing entire codebases or large directories
- Comparing multiple large files
- Need to understand project-wide patterns or architecture
- Current context window is insufficient for the task
- Working with files totaling more than 100KB
- Verifying if specific features, patterns, or security measures are implemented
- Checking for the presence of certain coding patterns across the entire codebase

**Important Notes:**
- Paths in @ syntax are relative to your current working directory when invoking gemini
- The CLI will include file contents directly in the context
- No need for -yolo flag for read-only analysis
- Gemini's context window can handle entire codebases that would overflow Claude's context
- When checking implementations, be specific about what you're looking for to get accurate results

---

## Session Closure Prompt

(Session closure agent instructions are maintained separately in the session closer agent configuration)

---

## Foundation Phase Guidelines

When working during the foundation phase:
- Document first, code second
- Confirm architecture decisions explicitly before implementing
- Keep dependencies minimal
- Prefer standard, well-supported libraries over novel solutions
- Establish clear project structure before feature development
