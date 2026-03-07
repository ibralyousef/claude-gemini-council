# COUNCIL_BLUEPRINT
## Session: 2026-03-07-010000 | Topic: Protocol simplification | Status: RESOLVED
## Decision: Remove --consensus/-q/-i flags, make consensus default, add mandatory AskUserQuestion triggers
## Action Required: true

> **CHAIR INSTRUCTION**: If Action Required is true, present user with implementation options (plan mode / implement directly / let user write).

## Architecture

### Syntax Change
**Before**: `/council [--resume <session>] [-q] [-i] [--consensus] [-n N] [-c|-a] [rounds] <topic>`
**After**: `/council [--resume <session>] [-n N] [-c|-a] [N] <topic>`

### Mode Change
- All sessions are consensus (early-exit on RESOLVED)
- Rounds arg = max rounds cap (default 10)
- Termination: "On RESOLVED or after max rounds (default 10)"

### AskUserQuestion Triggers (NEW Phase 3h replacement)
Three mandatory triggers — Chair MUST AskUserQuestion when any fires:
1. **(a) User-directed question**: Any participant QUESTIONS_FOR_OTHER contains a question directed at the user
2. **(b) Persistent disagreement**: Participants with contradicting KEY_POINTS show no change in AGREEMENT values between round N-1 and round N
3. **(c) Low confidence**: Any participant confidence < 0.5 AND MISSING_CONTEXT is non-empty

**Suppression**: If user responds "stop asking" or equivalent, Chair logs `[user declined further input]` and suppresses ALL triggers for remainder of session. Deadlock under suppression -> session reaches max rounds, summary reflects unresolved disagreement.

### Anti-patterns
- Do NOT add new stance modes (exploratory, devil's-advocate as stance) — stances are intensity dials, not session purposes
- Do NOT add --fixed flag — consensus exit is just an exit condition, not a participant incentive

## Scope

### council.md (14 edits)
1. Line 4: Update argument-hint to `[--resume <session>] [-n N] [-c|-a] [N] <topic>`
2. Lines 9-10: Remove "Two modes" framing, describe consensus-only
3. Lines 14-16: Remove -q, -i, --consensus argument definitions
4. Line 19: Change rounds description to "max rounds" semantics
5. Lines 32-33: Remove -q and -i examples
6. Line 87: Remove `## Interactive: [Yes|No]` from init.md template
7. Line 111: Fix path bug: `~/.claude/council/participant-protocol.md` -> `user-level/council/participant-protocol.md`
8. Lines 164-173: Phase 2 announce — remove `Interactive:` and `Output:` lines
9. Line 180: Remove quiet-mode conditional on Chair display
10. Lines 196, 210: Remove quiet-mode conditionals on participant display
11. Lines 247-261: Delete entire Phase 3h (interactive mode block)
12. Add new Phase 3h: Mandatory AskUserQuestion trigger spec (see Architecture above)
13. Lines 265-266: Collapse termination to single rule: "On RESOLVED or after max rounds (default 10)"
14. Update examples section to reflect new syntax

### CLAUDE.md
- Remove `--consensus` from examples
- Update session description from "Standard session (3 rounds)" to "Consensus session (max 10 rounds)"
- Remove `--consensus` from combined flag examples

### participant-protocol.md
- No changes needed

## Constraints
- Single atomic commit — no bundling/phasing needed for markdown protocol
- Preserve all existing functionality that isn't explicitly removed
- Do not modify session file format, round file format, or Phase 5 finalization

## Success Criteria
- [ ] `/council topic` starts a consensus session (max 10 rounds) with critical stance
- [ ] `/council -a 5 topic` starts adversarial consensus session capped at 5 rounds
- [ ] No references to -q, -i, or --consensus remain in council.md or CLAUDE.md
- [ ] Path in Phase 1 step 5 points to user-level/council/participant-protocol.md
- [ ] Phase 2 announce block has no Interactive or Output lines
- [ ] Phase 3h contains mandatory AskUserQuestion trigger spec, not interactive mode logic
- [ ] Termination section describes single rule, not two modes
- [ ] argument-hint line matches new syntax
