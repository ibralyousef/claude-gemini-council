# Council Session: 2026-03-07-010000
## Topic: Protocol scrutiny — simplify /council command options, make consensus default, remove -q, add new modes, define when Chair should AskUserQuestion, minimize friction
## Stance: Critical
## Mode: Consensus (max 10 rounds)
## Participants: 3 (pragmatist, skeptic, architect)
## Interactive: No

---

# Round 1
**Topic**: Protocol scrutiny — simplify /council command options, make consensus default, remove -q, add new modes, define when Chair should AskUserQuestion, minimize friction
**Round**: 1 of 10

## CHAIR'S POSITION
Confidence: 0.75

1. Remove --consensus flag — make consensus the default (and only) mode. All sessions are consensus (max 10 rounds). If users want fewer rounds, they can set a max with a rounds argument (e.g., /council 3 topic caps at 3 rounds but still exits early on RESOLVED).

2. Remove -q / --quiet. Never used. Dead code. Remove from argument parsing, Phase 2 announce, Phase 3 display conditionals.

3. Remove -i / --interactive — make Chair AskUserQuestion contextual instead. Three triggers: unresolvable disagreement across 2+ rounds, participant QUESTIONS_FOR_OTHER directed at user, ambiguous topic in round 1.

4. New stance modes beyond -c and -a. Consider -e (exploratory) and -d (devil's-advocate). Less confident on this — adding modes adds complexity.

5. Simplified argument syntax: /council [--resume session] [-n N] [-c|-a|-e] [rounds] topic

6. Path bug: ~/.claude/council/participant-protocol.md doesn't exist; actual path is user-level/council/participant-protocol.md.

## PARTICIPANT-1'S POSITION (pragmatist)
Consensus default: agree, but round-cap syntax needs parse clarity. Remove -q: fully agree (6 touchpoints). Remove -i: agree with contextual AskUserQuestion, but need concrete mechanical triggers. New stances: oppose — devil's-advocate overlaps persona, exploratory lacks spec. Path bug confirmed. argument-hint line needs updating.

---COUNCIL_RESPONSE---
STATUS: CONTINUE | AGREEMENT: partial | CONFIDENCE: 0.82
---END_COUNCIL_RESPONSE---

## PARTICIPANT-2'S POSITION (skeptic)
Consensus default: partial agree, proposes --fixed N as opt-in. Remove -q: full agree. Remove -i: agree but criteria too vague, add low-confidence trigger. New stances: disagree — category error. Path bug: prefer relative path fix.

---COUNCIL_RESPONSE---
STATUS: CONTINUE | AGREEMENT: partial | CONFIDENCE: 0.70
---END_COUNCIL_RESPONSE---

## PARTICIPANT-3'S POSITION (architect)
Consensus default: agree, flags behavioral change (early-exit on RESOLVED). Remove -q: strong agree. Remove -i: partial agree, wants mandatory triggers not discretionary. New stances: disagree, defer. Recommends bundling changes.

---COUNCIL_RESPONSE---
STATUS: CONTINUE | AGREEMENT: partial | CONFIDENCE: 0.80
---END_COUNCIL_RESPONSE---

## ROUND 1 SYNTHESIS
Strong convergence on: remove -q (unanimous), reject new stances (3/3), fix path bug (unanimous), simplify syntax (unanimous). Divergence on AskUserQuestion trigger precision and rounds semantics.

---

# Round 2
**Topic**: Protocol scrutiny — simplify /council command options, make consensus default, remove -q, add new modes, define when Chair should AskUserQuestion, minimize friction
**Round**: 2 of 10

## CHAIR'S POSITION
Confidence: 0.85

Accepted behavioral change for consensus-default. Rounds positional after stance. Rejected --fixed. AskUserQuestion triggers now MANDATORY: (a) QUESTIONS_FOR_OTHER, (b) persistent conflict, (c) low confidence. Suppression on user opt-out. New stances dropped.

## PARTICIPANT-1'S POSITION (pragmatist)
Full agreement (0.90). Rounds parsing resolved. Trigger (c) should simplify: drop "user-only" qualifier. Phase 2 announce and init.md template need cleanup.

---COUNCIL_RESPONSE---
STATUS: CONTINUE | AGREEMENT: full | CONFIDENCE: 0.90
---END_COUNCIL_RESPONSE---

## PARTICIPANT-2'S POSITION (skeptic)
Partial agreement (0.85). Dropped --fixed proposal. Trigger (b) needs semantic comparison note. Suppression scope question: all triggers or selective?

---COUNCIL_RESPONSE---
STATUS: CONTINUE | AGREEMENT: partial | CONFIDENCE: 0.85
---END_COUNCIL_RESPONSE---

## PARTICIPANT-3'S POSITION (architect)
Partial agreement (0.88). Trigger (b) refined: AGREEMENT-value comparison between consecutive rounds. 14-edit accounting provided. Single commit, no bundling needed.

---COUNCIL_RESPONSE---
STATUS: CONTINUE | AGREEMENT: partial | CONFIDENCE: 0.88
---END_COUNCIL_RESPONSE---

## ROUND 2 SYNTHESIS
Major convergence. Three refinement items remain: trigger (b) definition, trigger (c) simplification, suppression scope.

---

# Round 3
**Topic**: Protocol scrutiny — simplify /council command options, make consensus default, remove -q, add new modes, define when Chair should AskUserQuestion, minimize friction
**Round**: 3 of 10

## CHAIR'S POSITION
Confidence: 0.92

All three open items resolved: trigger (b) = AGREEMENT-value comparison, trigger (c) = confidence < 0.5 + non-empty MISSING_CONTEXT, suppression = all triggers.

## PARTICIPANT-1'S POSITION (pragmatist)
RESOLVED. Full agreement (0.93). All concerns addressed. Ship it.

---COUNCIL_RESPONSE---
STATUS: RESOLVED | AGREEMENT: full | CONFIDENCE: 0.93
---END_COUNCIL_RESPONSE---

## PARTICIPANT-2'S POSITION (skeptic)
RESOLVED. Full agreement (0.93). Full audit of 14 edit points confirmed. Ship as single commit.

---COUNCIL_RESPONSE---
STATUS: RESOLVED | AGREEMENT: full | CONFIDENCE: 0.93
---END_COUNCIL_RESPONSE---

## PARTICIPANT-3'S POSITION (architect)
RESOLVED. Full agreement (0.93). Proposal reduces complexity without losing capability.

---COUNCIL_RESPONSE---
STATUS: RESOLVED | AGREEMENT: full | CONFIDENCE: 0.93
---END_COUNCIL_RESPONSE---

## ROUND 3 SYNTHESIS
Unanimous RESOLVED. All three participants at 0.93 confidence with full agreement. No remaining disagreements.

---

=== COUNCIL SUMMARY ===
Topic: Protocol scrutiny — simplify /council command options | Stance: Critical | Rounds: 3 | Participants: 3 (pragmatist, skeptic, architect)

## Agreement
- **Make consensus the only mode**: Remove --consensus flag. All sessions are consensus with early-exit on RESOLVED, default max 10 rounds. Rounds arg sets max cap.
- **Remove -q/--quiet**: 6 touchpoints of dead code. Unanimous.
- **Remove -i/--interactive**: Replace with 3 mandatory AskUserQuestion triggers (protocol-driven, not Chair discretion).
- **No new stance modes**: Two stances (-c, -a) are sufficient. Exploratory is a category error, devil's-advocate overlaps persona. Deferred.
- **Simplified syntax**: /council [--resume session] [-n N] [-c|-a] [N] topic
- **Fix path bug**: Line 111 — change ~/.claude/council/ to user-level/council/
- **AskUserQuestion triggers** (all mandatory):
  - (a) Any participant QUESTIONS_FOR_OTHER directed at user
  - (b) Same KEY_POINTS conflict + no AGREEMENT movement across 2 consecutive rounds
  - (c) Any participant confidence < 0.5 + non-empty MISSING_CONTEXT
  - Suppression: user says "stop asking" -> all triggers suppressed for session
- **14 targeted edits** in council.md, CLAUDE.md examples update, no changes to participant-protocol.md

## Disagreement
None — full consensus across all participants.

## Recommendation
Implement the consolidated proposal as a single atomic commit. The change set is well-defined (14 edits in council.md + CLAUDE.md update), reduces protocol surface area by ~60% in flags, and introduces no new complexity.

---

# COUNCIL_BLUEPRINT
## Session: 2026-03-07-010000 | Topic: Protocol simplification | Status: RESOLVED
## Decision: Remove --consensus/-q/-i flags, make consensus default, add mandatory AskUserQuestion triggers
## Action Required: true

## Architecture

### Syntax Change
**Before**: `/council [--resume <session>] [-q] [-i] [--consensus] [-n N] [-c|-a] [rounds] <topic>`
**After**: `/council [--resume <session>] [-n N] [-c|-a] [N] <topic>`

### Mode Change
- All sessions are consensus (early-exit on RESOLVED)
- Rounds arg = max rounds cap (default 10)
- Termination: "On RESOLVED or after max rounds (default 10)"

### AskUserQuestion Triggers (NEW Phase 3h replacement)
Three mandatory triggers:
1. (a) User-directed question: Any participant QUESTIONS_FOR_OTHER directed at user
2. (b) Persistent disagreement: No AGREEMENT movement between consecutive rounds
3. (c) Low confidence: Any participant confidence < 0.5 AND MISSING_CONTEXT non-empty

Suppression: user says "stop asking" -> all triggers suppressed for session.

## Scope
- council.md: 14 targeted edits
- CLAUDE.md: example updates
- participant-protocol.md: no changes

## Success Criteria
- [ ] /council topic starts consensus session (max 10 rounds) with critical stance
- [ ] /council -a 5 topic starts adversarial consensus capped at 5 rounds
- [ ] No references to -q, -i, or --consensus remain
- [ ] Path bug fixed
- [ ] Phase 3h contains trigger spec
- [ ] Termination is single rule
