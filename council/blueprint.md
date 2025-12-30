# COUNCIL_BLUEPRINT
## Session: 2025-12-30-120000 | Topic: Pattern utility review and Chair history immutability | Status: RESOLVED
## Decision: Dissolve patterns.md and add Immutability Mandate to prevent Chair from destructively summarizing session logs
## Action Required: true

> **CHAIR INSTRUCTION**: If Action Required is true, present user with implementation options (plan mode / implement directly / let user write).

## Architecture
| Component | Change | Rationale |
|-----------|--------|-----------|
| `council/memory/patterns.md` | DELETE | Mixed-concern "junk drawer" - content migrated elsewhere |
| `user-level/council/protocol.md` | ADD User Preferences section | Migrate "iterative improvements" preference |
| `council/GEMINI.md` | ADD MVC + Domain Knowledge | Architectural reference belongs in context injection file |
| `user-level/commands/council.md` | ADD Immutability Mandate | Prevent Chair from replacing history with summaries |

## Scope
- Files affected: 4
  - `council/memory/patterns.md` (delete)
  - `user-level/council/protocol.md` (edit)
  - `council/GEMINI.md` (edit)
  - `user-level/commands/council.md` (edit)

## Constraints
- Immutability Mandate must be prominent (not buried in notes)
- Token limit handling: archival rotation permitted, destructive summarization prohibited
- MVC definition is architectural reference, not operational rule

## Success Criteria
- [ ] `patterns.md` deleted
- [ ] "Prefers iterative improvements over big-bang rewrites" appears in protocol.md User Preferences
- [ ] MVC definition and Domain Knowledge appear in GEMINI.md
- [ ] Immutability Mandate appears prominently in council.md Important Notes section
- [ ] No duplicate content across files
