---
description: "AI Council session that continues until consensus is reached (max 10 rounds)"
allowed-tools: ["Bash", "Read", "Write", "Glob", "Grep"]
argument-hint: "[level] <topic requiring consensus>"
---

# AI Council Consensus Session

You are starting an AI Council session that will continue until you and Gemini reach consensus on the topic. Maximum 10 rounds to prevent infinite loops.

## Arguments
Parse arguments in this order:
1. **Stance/Level** (optional): cooperative | balanced | critical | adversarial (default: balanced)
2. **Topic** (required): Everything else is the topic

**Input received:** $ARGUMENTS

**Examples:**
- `/council-consensus adversarial Should we use microservices?` → adversarial stance
- `/council-consensus critical Authentication architecture` → critical stance
- `/council-consensus Database migration strategy` → balanced (default)

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

1. **Parse arguments**: Determine stance and topic from the input
   - Check if first word is a stance level (cooperative/balanced/critical/adversarial)
   - Everything else is the topic
   - Default: balanced stance

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

5. **Launch terminal viewer**: Open a separate terminal window to show the session:
   ```bash
   ~/.claude/council/scripts/council-terminal.sh "council/sessions/current.md" "[topic]" "[stance]" "10"
   ```
   This opens a tmux split pane (if in tmux) or new Terminal window (on macOS) that shows the session log in real-time with colorized output.

6. **Announce the session**:
   ```
   === AI COUNCIL CONSENSUS SESSION ===
   Topic: [topic]
   Stance: [stance level]
   Mode: Continue until consensus (max 10 rounds)
   ```

7. **For each round** (up to 10):

   **State tracking**: Maintain a `consecutive_deadlock_count` variable, starting at 0.

   a. **Claude's turn**: State your position
      - In early rounds: Present your perspective clearly
      - In later rounds: Look for common ground, propose compromises
      - After round 7: Actively push for compromise
      - Always include your confidence level (0.0-1.0)
      - Match your argumentative intensity to the stance level

   b. **Display your position**:
      ```
      --- ROUND [N]: CLAUDE ---
      [your position]
      ```

   c. **Append to session log**: Use bash to append your position directly:
      ```bash
      echo "### Round [N]

      **CLAUDE:**
      [your position]
      " >> council/sessions/current.md
      ```

   d. **Invoke Gemini** with output file parameter (auto-appends to session log):
      ```bash
      ~/.claude/council/scripts/invoke-gemini.sh "You are Gemini in an AI Council CONSENSUS session with Claude.

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
      We're looking for consensus - be constructive and solution-oriented." "[stance]" "council/sessions/current.md"
      ```
      Note: The 3rd argument auto-appends Gemini's response to the session file.

   e. **Display Gemini's response**:
      ```
      --- ROUND [N]: GEMINI ---
      [response]
      ```
      (The response is already logged to the file by invoke-gemini.sh)

   g. **Parse STATUS field** and decide:
      - If `RESOLVED` → proceed to summary
      - If `CONTINUE` → reset `consecutive_deadlock_count` to 0, proceed to next round
      - If `DEADLOCK`:
        - Increment `consecutive_deadlock_count`
        - If count < 2 → proceed to next round
        - If count >= 2 → trigger escalation (see step h)
      - If `ESCALATE` → trigger escalation (see step h)

   h. **Escalation procedure** (when triggered by ESCALATE status or 2 consecutive deadlocks):
      1. Append `[ESCALATE]` marker to session log:
         ```bash
         echo "[ESCALATE]" >> council/sessions/current.md
         ```
      2. Display to user: "Escalation triggered. Please provide input in the terminal window, then type 'continue' here when done."
      3. **STOP and wait** for user to type "continue" (or similar confirmation) in the main chat
      4. Read `council/sessions/escalation-response.txt` to get user's input
      5. Incorporate user's input into next round, reset `consecutive_deadlock_count` to 0

   i. **If consensus reached**, proceed to summary

   j. **If no consensus**, continue to next round

8. **On consensus OR max rounds**, create summary:
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
   ```

9. **Finalize session log**: Append the summary to `current.md`, then rename it to:
   `council/sessions/[YYYY-MM-DD-HHMMSS].md`

10. **Update decisions log**: Append to:
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
- You are the Chair - maintain neutrality when summarizing
- Preserve Gemini's exact words in the session log - never paraphrase
- The goal is to reach actionable consensus, not to "win"
- Be willing to modify your position based on good arguments
- Match your debate intensity to the stance level
- On ESCALATE status, pause everything and get user input before continuing
