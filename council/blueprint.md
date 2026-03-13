# COUNCIL_BLUEPRINT
## Session: 2026-03-07-012000 | Topic: should the compile-round.sh script be kept or replaced with inline Chair logic | Status: RESOLVED
## Decision: Keep compile-round.sh — cat provides byte-faithful verbatim copying that LLM-mediated inline composition cannot guarantee
## Action Required: true

> **CHAIR INSTRUCTION**: If Action Required is true, present user with implementation options (plan mode / implement directly / let user write).

## Architecture
| Component | Decision |
|-----------|----------|
| compile-round.sh | KEEP — cat enforces Immutability Mandate mechanically |
| Script cleanup (rm -f) | REMOVE from script — Chair handles deletion after verification |
| Script responsibility | Pure function: assemble round file only, no side effects |
| decisions.md | AMEND — record user override with rationale |
| council.md Phase 3e | UPDATE — document script contract (inputs, outputs, fidelity guarantee) |

**Patterns:**
- Deterministic tools (cat) for verbatim content; LLM tools (Write) for authored content (synthesis)
- Script as pure function: inputs → output, no cleanup side effects
- Chair retains deletion responsibility after Read-back verification

**Anti-patterns:**
- LLM-mediated composition of verbatim participant positions (hallucination risk)
- Script performing both composition AND cleanup (recovery impossible if output corrupted)

## Scope
- `user-level/scripts/compile-round.sh` — remove rm -f cleanup block, add contract comment
- `user-level/commands/council.md` Phase 3e — document script contract, add explicit Chair deletion step after compile
- `council/memory/decisions.md` — append amendment recording user override

## Constraints
- bash 3.2 compatibility required (macOS ships bash 3.2) — current script already uses tr, no ${^^} syntax
- Script must remain a pure function — no external state mutation

## Success Criteria
- [ ] compile-round.sh no longer deletes source files
- [ ] council.md Phase 3e explicitly states Chair deletes position files after Read-back verification
- [ ] decisions.md records the user override with rationale (verbatim fidelity via cat)
- [ ] Script has a contract comment documenting inputs, outputs, and fidelity guarantee
