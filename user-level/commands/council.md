---
description: "Start AI Council session with Gemini for collaborative planning"
allowed-tools: ["Bash", "Read", "Write", "Glob", "Grep", "AskUserQuestion"]
argument-hint: "[--quiet] [level] [rounds] <topic to discuss>"
---

# AI Council Session

You are starting an AI Council planning session with Gemini CLI. This is a collaborative discussion to help make better decisions.

## Arguments
Parse arguments in this order:
1. **Mode flag** (optional): `--quiet` to suppress verbose output (default: verbose/watch mode)
2. **Stance/Level** (optional): cooperative | balanced | critical | adversarial (default: balanced)
3. **Rounds** (optional): A number for how many rounds (default: 3)
4. **Topic** (required): Everything else is the topic

**Input received:** $ARGUMENTS

**Examples:**
- `/council adversarial 5 Should we rewrite in Rust?` → verbose, adversarial, 5 rounds
- `/council --quiet critical How to handle auth?` → quiet mode, critical, 3 rounds
- `/council 3 API design review` → verbose, balanced, 3 rounds
- `/council Should we use Redis?` → verbose, balanced, 3 rounds (defaults)

## Mode Behavior
- **Default (verbose/watch)**: Display each round's Claude/Gemini exchange inline
- **--quiet**: Only show progress updates and final summary (full log still written to file)

## Stance Levels
- **cooperative**: Build on ideas, seek synthesis, gentle challenges
- **balanced**: Fair critique, acknowledge good and bad (default)
- **critical**: Find flaws, question assumptions, demand evidence
- **adversarial**: Devil's advocate, stress-test everything, relentless scrutiny

## Chair Protocol

As the Chair of this council session, you MUST follow these rules:

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
   - `STATUS: CONTINUE` → proceed to next round
   - `STATUS: RESOLVED` → end session, generate summary
   - `STATUS: DEADLOCK` → if 2 consecutive deadlocks, escalate to user
   - `STATUS: ESCALATE` → pause and ask user for input

6. **Maximum rounds**: 10 rounds regardless of status (prevents infinite loops)

## Instructions

1. **Parse arguments**: Determine mode, stance, rounds, and topic from the input
   - Check if first word is `--quiet` (sets quiet mode)
   - Check if next word is a stance level (cooperative/balanced/critical/adversarial)
   - Check if next word is a number (rounds)
   - Everything else is the topic
   - Defaults: verbose mode, balanced stance, 3 rounds

2. **Initialize council structure** (if needed):
   - Check if `council/` directory exists in current project
   - If not, create the directory structure and template files
   - Create `council/GEMINI.md` with project context template
   - Create `council/memory/decisions.md` and `council/memory/patterns.md` with templates
   - Create `council/sessions/` directory

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
   # Council Session: [YYYY-MM-DD-HHMMSS]
   ## Topic: [topic]
   ## Stance: [stance level]
   ## Participants: Claude (Chair), Gemini
   ## Max Rounds: [N]

   ---
   ```

5. **Update status-line**: Signal session start:
   ```bash
   ~/.claude/council/scripts/council-status.sh "Council: Starting..."
   ```

6. **Start the council session**: Announce the session with:
   ```
   === AI COUNCIL SESSION ===
   Topic: [topic]
   Stance: [stance level]
   Rounds: [N]
   Mode: [verbose/quiet]
   ```

7. **For each round**, do the following:

   **State tracking**: Maintain a `consecutive_deadlock_count` variable, starting at 0.

   a. **Update status-line**:
      ```bash
      ~/.claude/council/scripts/council-status.sh "Council: Round [N]/[total]"
      ```

   b. **Claude's turn**: State your perspective on the topic
      - Be specific and actionable
      - Consider trade-offs
      - Build on previous discussion if not round 1
      - Include your confidence level (0.0-1.0) on your position
      - Match your argumentative intensity to the stance level

   c. **Display your position** (if verbose mode):
      ```
      --- ROUND [N]: CLAUDE ---
      [your position]
      ```
      In quiet mode, just show: `Round [N]: Claude responded...`

   d. **Append to session log**: Use bash to append your position directly to the session file:
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
      ~/.claude/council/scripts/invoke-gemini.sh "You are Gemini participating in an AI Council session with Claude.

      TOPIC: [the topic]
      ROUND: [current] of [total]

      CLAUDE'S POSITION:
      [what you just said]

      PREVIOUS DISCUSSION:
      [summary of earlier rounds if any]

      Please provide your perspective according to your assigned stance. Be specific and actionable.
      Remember to end with a COUNCIL_RESPONSE block." "[stance]" "council/sessions/current.md"
      ```
      Note: The 3rd argument auto-appends Gemini's response to the session file.

   g. **Display Gemini's response** (if verbose mode):
      ```
      --- ROUND [N]: GEMINI ---
      [gemini's response]
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

   j. **Continue** to the next round

8. **After all rounds or RESOLVED status**, create a summary:
   ```
   === COUNCIL SUMMARY ===

   ## Topic
   [topic]

   ## Stance Used
   [stance level]

   ## Key Points from Claude
   - [bullet points]

   ## Key Points from Gemini
   - [bullet points]

   ## Points of Agreement
   - [shared conclusions]

   ## Points of Disagreement
   - [unresolved differences, if any]

   ## Recommended Action
   [synthesized recommendation combining both perspectives]
   ```

9. **Update status-line**:
   ```bash
   ~/.claude/council/scripts/council-status.sh "Council: Complete"
   ```

10. **Prompt user for review**: Use AskUserQuestion tool to ask:
    - "Council session complete. Review the decision and action items?"
    - This forces the user to see the result even in auto-accept mode

11. **Finalize session log**: Append the summary to `current.md`, then rename it to:
    `council/sessions/[YYYY-MM-DD-HHMMSS].md`

12. **Update decisions log**: If a significant decision was reached, append to:
    `council/memory/decisions.md`

    Using this format:
    ```markdown
    ## [YYYY-MM-DD] - [Brief Topic]
    - **Topic**: [full topic]
    - **Stance**: [stance level used]
    - **Decision**: [agreed outcome]
    - **Rationale**: [why this was chosen]
    - **Dissent**: [any unresolved disagreements]
    ```

13. **Clear status-line**:
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

## Important Notes
- Default mode is verbose (--watch) - shows each exchange inline
- Use --quiet for minimal output (progress + final summary only)
- Session log is always written to file regardless of mode
- Use AskUserQuestion for escalation - this bypasses auto-accept mode
- Use AskUserQuestion at session end - ensures user sees the result
- Keep your positions concise but substantive
- Actively engage with Gemini's counterpoints
- Match your debate intensity to the stance level
- The goal is better decisions through diverse perspectives
- You are the Chair - maintain neutrality when summarizing
- Preserve Gemini's exact words in the session log - never paraphrase
