# AI Council Decisions Log

This file tracks key decisions made during council sessions for long-term memory persistence.
The `invoke-gemini.sh` script automatically injects this content into Gemini's context.

## Format
Each entry follows this structure:
```markdown
## [YYYY-MM-DD] - [Brief Topic]
- **Topic**: [full topic]
- **Decision**: [the agreed outcome]
- **Rationale**: [why this was chosen]
- **Dissent**: [any unresolved disagreements]
- **Session**: [link to session file if available]
```

---

<!-- New decisions will be appended below this line -->

## 2025-12-10 - Council Efficiency Improvements
- **Topic**: Is the current implementation for the council maximizing its efficiency? What is critically missing?
- **Decision**: Implement P0-P4 priority stack: Context Aggregation, Session Persistence, Chair Protocol, Protocol Hardening, Output Standardization, Termination Logic, Failure Recovery, Automated Memory Updates
- **Rationale**: Current implementation had "memory amnesia" (files not being read), no session continuity, and no structured output for automation
- **Dissent**: None - full consensus reached in Round 5
- **Session**: Initial council self-evaluation

## 2025-12-11 - Council Implementation Review (Consensus)
- **Topic**: Is the current implementation good? Investigate escalation handshake issue
- **Stance**: balanced
- **Decision**: Two P0 bugs confirmed: (1) Escalation handshake broken - Claude never reads escalation-response.txt, (2) Session overwrite - current.md blindly created. Critical enhancement needed: synchronization mechanism requiring explicit user confirmation before reading response file.
- **Rationale**: Code inspection verified the broken loop; user feedback in escalation-response.txt confirmed they were asked to act but response was ignored
- **Dissent**: None - full consensus in Round 1
- **Rounds to Consensus**: 1


## 2025-12-12 - Inline vs Terminal Council Architecture (Consensus)
- **Topic**: Would inline council (no terminal) be better than the current terminal-based approach?
- **Stance**: critical
- **Decision**: Hybrid approach - Optional Terminal + Quiet Inline Default. Terminal becomes opt-in; default shows only progress markers and final summary; full debate logged to file.
- **Rationale**: Terminal adds complexity but raw inline causes Context Pollution. Hybrid solves both: users get clean main chat, can opt-in to terminal for real-time viewing.
- **Dissent**: None - full consensus
- **Rounds to Consensus**: 2
- **Action Items**: (1) Make terminal optional with flag, (2) Add inline escalation fallback, (3) Implement quiet mode default

