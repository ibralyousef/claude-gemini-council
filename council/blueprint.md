# COUNCIL_BLUEPRINT
## Session: 2025-12-16-160000 | Topic: Interactive mode (-i) | Status: RESOLVED
## Decision: Add interactive mode using AskUserQuestion for per-round user input
## Action Required: true

> **CHAIR INSTRUCTION**: If Action Required is true, present user with implementation options (plan mode / implement directly / let user write).

## Architecture:
| Component | Decision | Rationale |
|-----------|----------|-----------|
| Input mechanism | AskUserQuestion only | Single path eliminates precedence ambiguity |
| Question source | QUESTIONS_FOR_OTHER (primary) | Gemini drives user interaction via existing field |
| Fallback 1 | KEY_POINTS disagreements | Scan for decision signals |
| Fallback 2 | Generic "proceed?" | Graceful degradation |
| Logging | "### USER INPUT (Round N)" | Consistent format in session log |

## Scope:
- `user-level/commands/council.md`: Add `-i` flag parsing and interactive logic in Phase 3

## Constraints:
- Must use existing AskUserQuestion tool (1-4 questions, 2-4 options each)
- Must log to current.md before asking
- Must include response in next round's USER_INPUT field

## Success Criteria:
- [ ] `-i` flag is parsed in argument list
- [ ] After each Gemini response, AskUserQuestion is invoked (in -i mode)
- [ ] Questions derived from QUESTIONS_FOR_OTHER when available
- [ ] User response logged to current.md
- [ ] Next round receives user input in context
- [ ] Works with --consensus and other flags
