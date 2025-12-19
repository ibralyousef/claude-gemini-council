# COUNCIL_BLUEPRINT
## Session: 2025-12-20-120000 | Topic: Interactive mode skip option | Status: RESOLVED
## Decision: Add "Skip this round" and "Disable prompts for remaining rounds" options to interactive mode
## Action Required: true

> **CHAIR INSTRUCTION**: If Action Required is true, present user with implementation options (plan mode / implement directly / let user write).

## Architecture
| Decision | Pattern | Anti-Pattern |
|----------|---------|--------------|
| State via session log | Implicit state in `current.md` | Bash variables or external state files |
| Distinct log values | `[user skipped]`, `[disabled interactive mode]`, `N/A` | Single `N/A` for all cases |
| Two skip options | Per-round + disable remaining | Only per-round (tedious) |

## Scope
- **Files affected**: `user-level/commands/council.md`
- **Components**: Phase 3g (Interactive mode section)

## Constraints
- Must maintain backward compatibility with existing `-i` flag behavior
- Must work within Claude's single-conversation context model
- Options should appear after derived question options, not before

## Success Criteria
- [ ] "Skip this round" option appears in interactive prompts
- [ ] "Disable prompts for remaining rounds" option appears in interactive prompts
- [ ] Session logs show `[skipped]` when user skips a round
- [ ] Session logs show `[disabled interactive mode]` when user disables prompts
- [ ] Subsequent rounds skip Phase 3g after disable is selected
- [ ] USER_INPUT field uses correct distinct values
