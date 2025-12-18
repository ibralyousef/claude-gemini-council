# COUNCIL_BLUEPRINT
## Session: 2025-12-18T165500 | Topic: Feature Pruning | Status: RESOLVED
## Decision: Remove unused Council features (DEADLOCK, ESCALATE, Balanced) and default to Critical stance
## Action Required: true

> **CHAIR INSTRUCTION**: If Action Required is true, you MUST invoke `EnterPlanMode` tool now. Do NOT implement directly.

## Architecture
| Component | Change |
|-----------|--------|
| Status Codes | Remove DEADLOCK, ESCALATE. Keep: RESOLVED, CONTINUE |
| Stances | Remove Balanced. Keep: Critical (default), Adversarial |
| Default | Critical (was: Balanced) |

## Patterns
- YAGNI: Features with zero usage over 20+ sessions are dead code
- Interactive mode supersedes special status codes

## Anti-Patterns
- Keeping "safety valves" that never trigger
- Providing "balanced" option that replicates default LLM behavior

## Scope
| File | Changes |
|------|---------|
| `user-level/council/protocol.md` | Remove Balanced stance, remove DEADLOCK/ESCALATE from STATUS values, remove QUESTION field |
| `user-level/commands/council.md` | Update default to critical, remove balanced from stances, update examples, remove deadlock/escalate logic from Phase 3f |
| `user-level/council/scripts/invoke-gemini.sh` | Change default STANCE to "critical", remove balanced case from instruction function |

## Constraints
- None identified

## Success Criteria
- [ ] DEADLOCK and ESCALATE removed from protocol STATUS values
- [ ] Balanced stance removed from all files
- [ ] Default stance is Critical in all files
- [ ] invoke-gemini.sh defaults to critical instructions
- [ ] Examples in council.md reflect new defaults
- [ ] No references to removed features remain
