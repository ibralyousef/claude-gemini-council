---
description: "AI Council session that continues until consensus is reached (max 10 rounds)"
allowed-tools: ["Bash", "Read", "Write", "Glob", "Grep", "AskUserQuestion"]
argument-hint: "[--quiet] [level] <topic requiring consensus>"
---

# AI Council Consensus Session

You are starting an AI Council session that will continue until you and Gemini reach consensus on the topic. Maximum 10 rounds to prevent infinite loops.

## Arguments
Parse arguments in this order:
1. **Mode flag** (optional): `--quiet` to suppress verbose output (default: verbose/watch mode)
2. **Stance/Level** (optional): cooperative | balanced | critical | adversarial (default: balanced)
3. **Topic** (required): Everything else is the topic

**Input received:** $ARGUMENTS

**Examples:**
- `/council-consensus adversarial Should we use microservices?` → verbose, adversarial
- `/council-consensus --quiet critical Authentication architecture` → quiet mode, critical
- `/council-consensus Database migration strategy` → verbose, balanced (default)

## Mode Behavior
- **Default (verbose/watch)**: Display each round's Claude/Gemini exchange inline
- **--quiet**: Only show progress updates and final summary (full log still written to file)

## Stance Levels
- **cooperative**: Build on ideas, seek synthesis, gentle challenges
- **balanced**: Fair critique, acknowledge good and bad (default)
- **critical**: Find flaws, question assumptions, demand evidence
- **adversarial**: Devil's advocate, stress-test everything, relentless scrutiny

## Chair Protocol

As the Chair of this consensus session, you MUST follow these rules:

1. **Before starting**: Read memory files for context (if they exist):
   - `council/memory/decisions.md` (in current project)
   - `council/memory/patterns.md` (in current project)

2. **Initialize project structure**: If `council/` directory doesn't exist in the current project, create it:
   ```
   council/
   ├── GEMINI.md        # Project context (create from template)
   ├── memory/
   │   ├── decisions.md # Decision log
   │   └── patterns.md  # Learned patterns
   └── sessions/
       └── current.md   # Active session log
   ```

3. **Session persistence**: Maintain a running session log at:
   `council/sessions/current.md`

4. **Immutability rule**: Never paraphrase or modify Gemini's COUNCIL_RESPONSE block - preserve it exactly as received.

5. **Termination logic**: Parse the STATUS field from Gemini's response:
   - `STATUS: RESOLVED` → end session, generate summary
   - `STATUS: DEADLOCK` → if 2 consecutive deadlocks, escalate to user
   - `STATUS: ESCALATE` → pause and ask user for input
   - `STATUS: CONTINUE` → proceed to next round

6. **Maximum rounds**: 10 rounds regardless of status (prevents infinite loops)

## Instructions

1. **Parse arguments**: Determine mode, stance, and topic from the input
   - Check if first word is `--quiet` (sets quiet mode)
   - Check if next word is a stance level (cooperative/balanced/critical/adversarial)
   - Everything else is the topic
   - Defaults: verbose mode, balanced stance

2. **Initialize council structure** (if needed):
   - Check if `council/` directory exists in current project
   - If not, create the directory structure and template files

3. **Read memory files**: Before the first round, read:
   - `council/memory/decisions.md`
   - `council/memory/patterns.md`
   Use this context to inform your positions.

4. **Initialize session log**:
   - Check if `council/sessions/current.md` already exists
   - If exists: Ask user "An active session exists. Resume it or start fresh?"
     - Resume: Continue from existing file
     - Fresh: Rename existing to `council/sessions/orphaned-[timestamp].md`, then create new
   - If not exists: Create new session file at `council/sessions/current.md`

   With this header:
   ```markdown
   # Council Consensus Session: [YYYY-MM-DD-HHMMSS]
   ## Topic: [topic]
   ## Stance: [stance level]
   ## Participants: Claude (Chair), Gemini
   ## Mode: Consensus (max 10 rounds)

   ---
   ```

5. **Update status-line**: Signal session start:
   ```bash
   ~/.claude/council/scripts/council-status.sh "Council: Starting..."
   ```

6. **Announce the session**:
   ```
   === AI COUNCIL CONSENSUS SESSION ===
   Topic: [topic]
   Stance: [stance level]
   Mode: Continue until consensus (max 10 rounds)
   Output: [verbose/quiet]
   ```

7. **For each round** (up to 10):

   **State tracking**: Maintain a `consecutive_deadlock_count` variable, starting at 0.

   a. **Update status-line**:
      ```bash
      ~/.claude/council/scripts/council-status.sh "Council: Round [N]/10"
      ```

   b. **Claude's turn**: State your position
      - In early rounds: Present your perspective clearly
      - In later rounds: Look for common ground, propose compromises
      - After round 7: Actively push for compromise
      - Always include your confidence level (0.0-1.0)
      - Match your argumentative intensity to the stance level

   c. **Display your position** (if verbose mode):
      ```
      --- ROUND [N]: CLAUDE ---
      [your position]
      ```
      In quiet mode, just show: `Round [N]: Claude responded...`

   d. **Append to session log**: Use bash to append your position directly:
      ```bash
      echo "### Round [N]

      **CLAUDE:**
      [your position]
      " >> council/sessions/current.md
      ```

   e. **Update status-line for Gemini**:
      ```bash
      ~/.claude/council/scripts/council-status.sh "Council: Waiting for Gemini..."
      ```

   f. **Invoke Gemini** with output file parameter (auto-appends to session log):
      ```bash
      ~/.claude/council/scripts/invoke-gemini.sh "[stance]" "council/sessions/current.md" << 'GEMINI_PROMPT'
You are Gemini in an AI Council CONSENSUS session with Claude.

TOPIC: [topic]
ROUND: [N] of max 10
MODE: We continue until we reach consensus

CLAUDE'S CURRENT POSITION:
[your position]

FULL DISCUSSION SO FAR:
[summary of all previous exchanges]

YOUR TASK:
1. Respond to Claude's position according to your assigned stance
2. Identify areas of agreement
3. If you agree with Claude's overall approach, set STATUS: RESOLVED
4. If not, explain your concerns and suggest modifications

Remember to end with a COUNCIL_RESPONSE block.
We're looking for consensus - be constructive and solution-oriented.
GEMINI_PROMPT
      ```
      Note: Prompt is passed via heredoc to stdin (avoids ARG_MAX limits). The 2nd argument specifies the output file.

   g. **Display Gemini's response** (if verbose mode):
      ```
      --- ROUND [N]: GEMINI ---
      [response]
      ```
      In quiet mode, just show: `Round [N]: Gemini responded...`

   h. **Parse STATUS field** and decide:
      - If `RESOLVED` → proceed to summary
      - If `CONTINUE` → reset `consecutive_deadlock_count` to 0, proceed to next round
      - If `DEADLOCK`:
        - Increment `consecutive_deadlock_count`
        - If count < 2 → proceed to next round
        - If count >= 2 → trigger escalation (see step i)
      - If `ESCALATE` → trigger escalation (see step i)

   i. **Escalation procedure** (when triggered by ESCALATE status or 2 consecutive deadlocks):
      1. Update status-line:
         ```bash
         ~/.claude/council/scripts/council-status.sh "Council: ESCALATION - Input needed"
         ```
      2. Append escalation marker to session log:
         ```bash
         echo "
[ESCALATION TRIGGERED]
" >> council/sessions/current.md
         ```
      3. **Use AskUserQuestion tool** to prompt the user directly:
         - This forces a prompt even in auto-accept mode
         - Ask: "The council needs your input to continue. What guidance do you want to provide?"
      4. Append user's response to session log
      5. Incorporate user's input into next round, reset `consecutive_deadlock_count` to 0

   j. **If consensus reached**, proceed to summary

   k. **If no consensus**, continue to next round

8. **Determine if action is required**:
   - Based on the consensus, determine if the session resulted in actionable recommendations
   - Set `action_required: true` if implementation work is needed
   - Set `action_required: false` for purely informational/research sessions

9. **Generate COUNCIL_BLUEPRINT** (if action_required is true):
   Write `council/blueprint.md` using the schema at the end of this document. The blueprint should:
   - Reference relevant decisions from `council/memory/decisions.md` (by ID or summary)
   - Reference applicable patterns from `council/memory/patterns.md`
   - NOT duplicate content from those files - synthesize and link instead

10. **Create summary** and display to user:
   ```
   === CONSENSUS RESULT ===

   Consensus Reached: [Yes/No]
   Rounds: [N]
   Stance Used: [stance level]

   ## Agreed Position
   [the consensus position, or best synthesis if no full consensus]

   ## Key Compromises Made
   - [what each side conceded]

   ## Remaining Open Questions
   - [any unresolved items]

   ## Action Items
   [specific next steps based on consensus]

   ## Blueprint
   [If action_required: "A detailed implementation blueprint has been saved to council/blueprint.md"]
   [If not: "No implementation blueprint generated (informational session)"]
   ```

11. **Update status-line**:
    ```bash
    ~/.claude/council/scripts/council-status.sh "Council: Complete"
    ```

12. **Prompt user for next step**: Use AskUserQuestion tool to ask:
    - Question: "Council session complete. How would you like to proceed?"
    - Options (if action_required is true):
      1. "Enter planning mode" - Create implementation plan based on blueprint (Recommended)
      2. "Review session first" - Review session log before proceeding
      3. "Skip planning" - End session without planning
    - Options (if action_required is false):
      1. "Review session" - Review the full session log
      2. "Done" - End session
    - This forces the user to see the result even in auto-accept mode

13. **Invoke Plan Mode (if user chose planning)**:
    - If user selected "Enter planning mode":
      1. Invoke `EnterPlanMode` tool
      2. In plan mode, read `council/blueprint.md` for context
      3. Design implementation approach based on blueprint's scope, constraints, and success criteria
    - If user selected "Review session first":
      1. Show them the session log location: `council/sessions/current.md`
      2. After review, ask again if they want to proceed to planning

14. **Finalize session log**: Append the summary to `current.md`, then rename it to:
    `council/sessions/[YYYY-MM-DD-HHMMSS].md`

15. **Update decisions log**: Append to:
    `council/memory/decisions.md`

    Using this format:
    ```markdown
    ## [YYYY-MM-DD] - [Brief Topic] (Consensus)
    - **Topic**: [full topic]
    - **Stance**: [stance level used]
    - **Decision**: [agreed outcome]
    - **Rationale**: [why this was chosen]
    - **Dissent**: [any unresolved disagreements]
    - **Rounds to Consensus**: [N]
    ```

16. **Clear status-line**:
    ```bash
    ~/.claude/council/scripts/council-status.sh clear
    ```

## Template Files (for initialization)

### council/GEMINI.md template:
```markdown
# Project Context

## Overview
[Brief description of this project - please edit this]

## Current Focus
[What you're currently working on]

## Key Architecture
[Important technical details Gemini should know]
```

### council/memory/decisions.md template:
```markdown
# Council Decisions Log

This file tracks key decisions made during council sessions.

---

<!-- New decisions will be appended below -->
```

### council/memory/patterns.md template:
```markdown
# Learned Patterns

## User Preferences
<!-- Observed preferences from council discussions -->

## Successful Approaches
<!-- Patterns that led to good outcomes -->

## Anti-Patterns
<!-- Approaches to avoid -->

---

<!-- New patterns will be appended below -->
```

## Consensus Detection Guidelines
- Look for `STATUS: RESOLVED` in Gemini's COUNCIL_RESPONSE block
- Also look for explicit agreement phrases: "I agree", "that works", "let's go with that"
- Minor implementation details don't block consensus
- If both support the same core approach, that's consensus
- After round 7, actively push for compromise
- If stuck at DEADLOCK for 2 rounds, escalate to user

## Important Notes
- Default mode is verbose (--watch) - shows each exchange inline
- Use --quiet for minimal output (progress + final summary only)
- Session log is always written to file regardless of mode
- Use AskUserQuestion for escalation - this bypasses auto-accept mode
- Use AskUserQuestion at session end - ensures user sees the result
- You are the Chair - maintain neutrality when summarizing
- Preserve Gemini's exact words in the session log - never paraphrase
- The goal is to reach actionable consensus, not to "win"
- Be willing to modify your position based on good arguments
- Match your debate intensity to the stance level

## COUNCIL_BLUEPRINT Schema

When `action_required` is true, generate `council/blueprint.md` using this format:

```markdown
# COUNCIL_BLUEPRINT

## Session
- **ID**: [YYYY-MM-DD-HHMMSS]
- **Topic**: [topic]
- **Status**: [RESOLVED|DEADLOCK|MAX_ROUNDS]

## Decision Summary
[One-line summary of the agreed decision]

## Rationale
[Why this decision was reached]

## Action Required
**true**

## Related Context
<!-- Reference, don't duplicate -->
- **Relevant Decisions**: [List IDs from decisions.md that informed this blueprint]
- **Applicable Patterns**: [List patterns from patterns.md to follow]

## Architecture

### Decisions
| Key | Choice | Rationale |
|-----|--------|-----------|
| [decision_key] | [chosen_option] | [why] |

### Patterns to Follow
- [Recommended patterns]

### Anti-Patterns to Avoid
- [Patterns to avoid]

## Scope

### Components Affected
- [List of components/modules to modify]

### Files to Modify
- [List of file paths]

## Constraints
- [Technical constraints]
- [Business constraints]

## Prerequisites
- [ ] [Investigation or verification needed before implementation]

## Success Criteria
- [ ] [How to verify implementation is complete]

## Dissent
[Any unresolved disagreements, or "None"]
```
