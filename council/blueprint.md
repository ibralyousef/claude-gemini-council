# COUNCIL_BLUEPRINT
## Session: 2025-12-22-130000 | Topic: Missing low-effort improvements | Status: RESOLVED
## Decision: Implement Resume and Agenda Bridge features
## Action Required: true

> **CHAIR INSTRUCTION**: If Action Required is true, present user with implementation options (plan mode / implement directly / let user write).

## Architecture
- **Resume Feature**:
  - Modify `council.md` to accept `--resume <session_file>` flag.
  - Logic: Copy `<session_file>` content to `current.md`. Append `## RESUMED` header. Set topic from file.
  - Constraint: Must handle file paths or session IDs.
- **Agenda Bridge**:
  - Modify `council.md` argument parsing.
  - Logic: If `$TOPIC` is empty, check `agenda.md`.
  - If agenda exists, invoke `/council-agenda list`.
  - If no agenda, show help.

## Scope
`user-level/commands/council.md`

## Constraints
Preserve existing flag handling.

## Success Criteria
- [ ] `/council --resume council/sessions/2025-12-18-*.md` restores that session context
- [ ] `/council` (no args) displays the agenda list instead of generic help
