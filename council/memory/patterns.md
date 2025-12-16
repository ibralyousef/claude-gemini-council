# AI Council Learned Patterns

This file tracks patterns, preferences, and lessons learned from council sessions.
The `invoke-gemini.sh` script automatically injects this content into Gemini's context.

## User Preferences
<!-- Observed preferences from council discussions -->
- Prefers practical, implementable solutions
- Values clarity and conciseness
- Appreciates explicit trade-off statements
- Prefers iterative improvements over big-bang rewrites

## Successful Approaches
<!-- Patterns that led to good outcomes -->
- Tool-first verification: Verify codebase state before forming opinions
- Structured output: Use parseable response blocks for automation
- Priority stacking: Organize improvements into P0/P1/P2/etc tiers
- Consensus seeking: Look for agreement on core approach, don't block on minor details

## Anti-Patterns
<!-- Approaches to avoid based on past experience -->
- Context dumping: Raw file injection doesn't scale; use summarization/retrieval
- One-shot opinions: Forming opinions without investigating codebase state
- Infinite discussion: Always set maximum rounds (10) to prevent loops
- Paraphrasing: Never paraphrase the other AI's position; preserve verbatim

## Domain Knowledge
<!-- Project-specific knowledge gathered from sessions -->
- Claude serves as "Chair" (orchestrator) in council sessions
- Gemini serves as "Participant + Investigator" (equal voice, plus tool access)
- Memory files (decisions.md, patterns.md) are injected via invoke-gemini.sh
- Session logs are maintained at council/sessions/current.md during active sessions

## Minimum Viable Chair (MVC) - Conceptual Reference
<!-- Defined 2025-12-16 to preserve architectural symmetry for future bidirectional chairing -->
Core Chair responsibilities that any AI must be able to perform:
1. **Moderate**: Control turn-taking, enforce round limits, announce session state
2. **Log**: Write session progress to `council/sessions/current.md`
3. **Escalate**: Detect ESCALATE/DEADLOCK status and prompt user for input
4. **Invoke**: Call the participant AI with proper context injection
5. **Summarize**: Generate COUNCIL_SUMMARY at session end
6. **Persist**: Append to decisions.md, rename session file

Current Claude-specific extensions (not required for MVC):
- `EnterPlanMode`: Transition to implementation planning
- `AskUserQuestion`: Structured user prompts with options
- `TodoWrite`: Task tracking during implementation

This distinction exists to enable future Gemini-as-Chair capability when its toolset expands.

---

<!-- New patterns will be appended below this line -->
