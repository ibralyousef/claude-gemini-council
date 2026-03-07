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
