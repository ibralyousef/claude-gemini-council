# Council Session: 2026-03-07-011500
## Topic: Fine-tune mandate for file-based agent communication protocol — agents write position files independently, chair concatenates into round-N.md, file-based coordination replaces direct message relay
## Stance: Critical
## Mode: Consensus (max 10 rounds)
## Participants: 3 (pragmatist, skeptic, architect)

---

# Round 1
**Topic**: Fine-tune mandate for file-based agent communication protocol
**Round**: 1 of 10

## CHAIR'S POSITION
The user's mandate proposes a significant architectural shift. Key changes: (1) agents receive all context at spawn, (2) agents write their own position files, (3) Chair concatenates via script into round-N.md, (4) script deletes individual files, (5) signal-only pings replace content-bearing messages, (6) agents can demand user input, (7) Chair relays user answers.

Key tensions identified:
- **Write access**: March 7 decision rejected it ("Write not path-scoped → blast radius unacceptable"). User is mandating it anyway.
- **Script dependency**: Adds bash script where Chair currently uses single Write call.
- **File deletion**: Acceptable since data preserved in round file.
- **Spawn-time independence**: Valuable — agents begin immediately.

Chair confidence: 0.7. Seeking participant input on feasibility and risks.

## PARTICIPANT-1'S POSITION (pragmatist)
Cherry-pick the good parts, reject the risky ones. YES to spawn-time independence (embed Chair R1 position in spawn prompt). NO to participant Write access (risk/reward bad, current SendMessage works). NO to concatenation script (single-writer Chair is simpler). The user's goals are achievable within current architecture.

## PARTICIPANT-2'S POSITION (skeptic)
The mandate largely describes what already exists (pointer-based SendMessage, parallel execution, signal-only messages). Write access reversal is high-risk (not path-scoped, blast radius unacceptable). The only genuinely new and valuable idea is spawn-time independence.

## PARTICIPANT-3'S POSITION (architect)
The mandate is architecturally viable but requires careful specification. Write access risk is real but mitigable via convention. Spawn-time independence is clean. Proposes structured ping format (POSITION_WRITTEN, ROUND_READY, etc.) and file naming convention `{persona}-round-{N}.md`.

## ROUND 1 SYNTHESIS
All three participants partially agree. Universal consensus on spawn-time independence. Pragmatist and skeptic reject Write access; architect proposes mitigations. Central question: is Write access a hard requirement?

---

# Round 2
**Topic**: Fine-tune mandate for file-based agent communication protocol
**Round**: 2 of 10

## CHAIR'S POSITION
User confirmed: "Write access is mandatory." March 7 rejection overridden. Debate shifts from WHETHER to HOW. Chair proposes: (1) Write access with naming convention, (2) spawn-time independence, (3) Chair Write call for concatenation (not separate script), (4) signal-only SendMessage, (5) cleanup after compilation.

## PARTICIPANT-1'S POSITION (pragmatist)
Accepts Write per user mandate. Minimal guardrails via 2-line protocol instruction. Chair Read+Write for concatenation, NOT a Bash script. Simple natural language pings. ~25 lines of edits, not a rewrite. YAGNI on timeout engineering.

## PARTICIPANT-2'S POSITION (skeptic)
Accepts Write with conditions. Must use ABSOLUTE paths. Chair Write call superior to script. Verification step before cleanup (read-back round file before deleting sources). Retry logic for missing files. Risk must be logged in decisions.md.

## PARTICIPANT-3'S POSITION (architect)
Full agreement with Chair. Shifts from separate script to Chair Write call. Proposes refined signal vocabulary (POSITION_WRITTEN, ROUND_COMPLETE, USER_INPUT_NEEDED, RESOLVED). Two distinct flows: Round 1 (spawn-time) vs Round N (signal-based). File-based offers genuine advantages: no size limits, inspectable, debuggable.

## ROUND 2 SYNTHESIS
Strong convergence. Universal agreement on Write access, Chair Write call (no script), spawn-time independence, file naming convention. Three minor divergences remaining: signal format, verification before cleanup, absolute paths.

---

# Round 3
**Topic**: Fine-tune mandate for file-based agent communication protocol
**Round**: 3 of 10

## CHAIR'S POSITION
Resolving 3 minor divergences: (1) Adopt architect's signal vocabulary — plain strings, zero cost. (2) Adopt skeptic's verification-before-cleanup — one Read call, cheap insurance. (3) Adopt skeptic's absolute paths — eliminates cwd ambiguity.

## PARTICIPANT-1'S POSITION (pragmatist)
RESOLVED. Accepts all three refinements. Adds: participants should be limited to one Write call per round (position file only). Confidence: 0.90.

## PARTICIPANT-2'S POSITION (skeptic)
RESOLVED. All concerns addressed. Requests explicit risk documentation language for decisions.md. Confidence: 0.88.

## PARTICIPANT-3'S POSITION (architect)
RESOLVED. Architecture is clean: files = data plane, messages = control plane, Chair = authoritative writer. Confidence: 0.92.

## ROUND 3 SYNTHESIS
Full consensus achieved. All 3 participants RESOLVED with full agreement (confidence range 0.88-0.92).

---

=== COUNCIL SUMMARY ===
Topic: Fine-tune mandate for file-based agent communication protocol | Stance: Critical | Rounds: 3 | Participants: 3 (pragmatist, skeptic, architect)

## Agreement
- Participants write position files directly to `council/sessions/current/{persona}-round-{N}.md` using absolute paths
- Chair reads individual files, compiles `round-N.md` via single atomic Write call (no separate script)
- Chair verifies round file before deleting individual position files
- Spawn-time independence: Chair forms R1 position before spawning agents, embeds in spawn prompt
- Signal-only SendMessage: POSITION_WRITTEN (agent->Chair), ROUND_COMPLETE with path (Chair->agent), USER_INPUT_NEEDED, RESOLVED
- Participants get Write tool access; Edit and Bash remain forbidden
- One Write call per round per participant (position file only)
- Accepted blast-radius risk documented in decisions.md
- File naming convention: `{persona}-round-{N}.md` (lowercase, hyphenated)

## Disagreement
None — full consensus reached in Round 3.

## Recommendation
Implement the file-based agent communication protocol with ~30 lines of edits across `participant-protocol.md` and `council.md`. The architecture separates data (files) from coordination (messages). Chair remains the single authoritative writer of round files. User has explicitly accepted unscoped Write blast-radius risk, mitigated by naming convention, absolute paths, and protocol contract.

---

# COUNCIL_BLUEPRINT
## Session: 2026-03-07-011500 | Topic: File-based agent communication protocol | Status: RESOLVED
## Decision: Implement file-based position writing by participants with Chair compilation, signal-only messaging, and spawn-time independence
## Action Required: true

## Architecture

| Component | Decision |
|-----------|----------|
| Data plane | Files (`{persona}-round-{N}.md` in session folder) |
| Control plane | SendMessage (signal-only: POSITION_WRITTEN, ROUND_COMPLETE, USER_INPUT_NEEDED, RESOLVED) |
| Round compilation | Chair Read + atomic Write (no separate script) |
| Cleanup | Chair verifies round file via Read-back, then deletes individual files via Bash rm |
| Spawn model | Chair forms R1 position BEFORE spawning; agents begin immediately |
| Write scoping | Convention-based (protocol contract), not tool-enforced |
| Path format | Absolute paths in all signals and protocol instructions |

**Patterns:**
- Files for data, messages for signals — never mix content into messages
- Chair is single authoritative writer of round files (Immutability Mandate preserved)
- One Write call per participant per round (position file only)
- Barrier pattern: Chair waits for all POSITION_WRITTEN pings before compiling

**Anti-patterns:**
- No separate concatenation scripts
- No content in SendMessage payloads
- No relative paths
- No Edit/Bash for participants
- No multi-file writes per round by participants

## Scope

**Files to modify:**
1. `user-level/council/participant-protocol.md`
2. `user-level/commands/council.md`
3. `council/memory/decisions.md`

## Constraints
- Write tool is NOT path-scoped — blast radius accepted by user, mitigated by convention
- Edit and Bash remain forbidden for participants
- Round files are immutable after write (existing Immutability Mandate)
- Signal messages must include round number to prevent agent confusion
- Absolute paths required to avoid cwd ambiguity across agent contexts

## Success Criteria
- [ ] participant-protocol.md includes Write in allowed tools and File Writing Contract section
- [ ] council.md Phase 3 reordered: Chair R1 position before spawning
- [ ] council.md Phase 3d-f updated for file-read flow with signal vocabulary
- [ ] council.md includes verification-before-cleanup step
- [ ] Spawn prompt template includes R1 position and file writing instructions
- [ ] decisions.md entry includes accepted risk documentation with mitigation list
- [ ] No new scripts or files created (edits only)
