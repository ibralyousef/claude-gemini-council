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
Implement the consolidated proposal as a single atomic commit. The change set is well-defined (14 edits in council.md + CLAUDE.md update), reduces protocol surface area by ~60% in flags, and introduces no new complexity. The mandatory AskUserQuestion triggers replace the blunt -i flag with a more intelligent, protocol-driven mechanism.
