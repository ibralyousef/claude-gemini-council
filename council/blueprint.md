# COUNCIL_BLUEPRINT
## Session: 2025-12-22-120000 | Topic: EnterPlanMode double prompt fix | Status: RESOLVED
## Decision: Improve option labeling in Phase 5 to clarify the trade-off between rigorous planning (with confirmation) and immediate execution (frictionless)
## Action Required: true

> **CHAIR INSTRUCTION**: If Action Required is true, present user with implementation options (plan mode / implement directly / let user write).

## Architecture
| Component | Decision |
|-----------|----------|
| EnterPlanMode | Keep as-is (system tool, provides value) |
| AskUserQuestion | Update option labels |
| Phase 5 flow | Add explanatory note |

**Patterns:**
- Blueprint = WHAT/WHY (Council), Execution Plan = HOW (EnterPlanMode)
- "Fast Lane" (Option 2) exists for frictionless flow
- Clarity over elimination

**Anti-patterns:**
- Removing EnterPlanMode entirely (loses structured planning capability)
- Accepting double-prompt without explanation (confuses users)

## Scope
**Files affected:**
- `user-level/commands/council.md` (Phase 5 section, lines 147-155)

**Changes:**
1. Rename "Enter plan mode" → "Enter Plan Mode (Generate detailed steps)"
2. Rename "Start implementing" → "Execute Immediately (Skip Plan Mode)"
3. Add inline note after Options block explaining EnterPlanMode's confirmation is intentional

## Constraints
- Cannot modify EnterPlanMode tool behavior (system tool)
- Must preserve all three implementation options
- Changes are documentation/labeling only - no code changes

## Success Criteria
- [ ] Phase 5 options renamed with descriptive labels
- [ ] Explanatory note added clarifying double-prompt is intentional
- [ ] Symlinks updated if ~/.claude/commands/council.md differs from repo
