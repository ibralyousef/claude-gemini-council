---
description: "Start AI Council session with Gemini for collaborative planning"
allowed-tools: ["Bash", "Read", "Write", "Glob", "Grep"]
argument-hint: "[level] [rounds] <topic to discuss>"
---

# AI Council Session

You are starting an AI Council planning session with Gemini CLI. This is a collaborative discussion to help make better decisions.

## Arguments
Parse arguments in this order:
1. **Stance/Level** (optional): cooperative | balanced | critical | adversarial (default: balanced)
2. **Rounds** (optional): A number for how many rounds (default: 3)
3. **Topic** (required): Everything else is the topic

**Input received:** $ARGUMENTS

**Examples:**
- `/council adversarial 5 Should we rewrite in Rust?` → adversarial, 5 rounds
- `/council critical How to handle auth?` → critical, 3 rounds (default)
- `/council 3 API design review` → balanced (default), 3 rounds
- `/council Should we use Redis?` → balanced, 3 rounds (defaults)

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

1. **Parse arguments**: Determine stance, rounds, and topic from the input
   - Check if first word is a stance level (cooperative/balanced/critical/adversarial)
   - Check if next word is a number (rounds)
   - Everything else is the topic
   - Defaults: balanced stance, 3 rounds

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

4. **Initialize session log**: Create session file at:
   `council/sessions/current.md`

   With this header:
   ```markdown
   # Council Session: [YYYY-MM-DD-HHMMSS]
   ## Topic: [topic]
   ## Stance: [stance level]
   ## Participants: Claude (Chair), Gemini
   ## Max Rounds: [N]

   ---
   ```

5. **Launch terminal viewer**: Open a separate terminal window to show the session:
   ```bash
   ~/.claude/council/scripts/council-terminal.sh "council/sessions/current.md" "[topic]" "[stance]" "[rounds]"
   ```
   This opens a tmux split pane (if in tmux) or new Terminal window (on macOS) that shows the session log in real-time with colorized output.

6. **Start the council session**: Announce the session with:
   ```
   === AI COUNCIL SESSION ===
   Topic: [topic]
   Stance: [stance level]
   Rounds: [N]
   ```

7. **For each round**, do the following:

   a. **Claude's turn**: State your perspective on the topic
      - Be specific and actionable
      - Consider trade-offs
      - Build on previous discussion if not round 1
      - Include your confidence level (0.0-1.0) on your position
      - Match your argumentative intensity to the stance level

   b. **Display your position** to the user with header:
      ```
      --- ROUND [N]: CLAUDE ---
      [your position]
      ```

   c. **Append to session log**: Write your position to `current.md`:
      ```markdown
      ### Round [N]
      **CLAUDE:**
      [your position]
      ```

   d. **Invoke Gemini** using the invoke-gemini.sh script which handles protocol injection:
      ```bash
      ~/.claude/council/scripts/invoke-gemini.sh "You are Gemini participating in an AI Council session with Claude.

      TOPIC: [the topic]
      ROUND: [current] of [total]

      CLAUDE'S POSITION:
      [what you just said]

      PREVIOUS DISCUSSION:
      [summary of earlier rounds if any]

      Please provide your perspective according to your assigned stance. Be specific and actionable.
      Remember to end with a COUNCIL_RESPONSE block." "[stance]"
      ```

   e. **Display Gemini's response** with header:
      ```
      --- ROUND [N]: GEMINI ---
      [gemini's response]
      ```

   f. **Append Gemini's response verbatim to session log**:
      ```markdown
      **GEMINI:**
      [exact response including COUNCIL_RESPONSE block]
      ```

   g. **Parse STATUS field** and decide:
      - If `RESOLVED` → proceed to summary
      - If `ESCALATE` → write `[ESCALATE]` to log, ask user for input, then continue
      - If `DEADLOCK` (2nd consecutive) → ask user for guidance
      - If `CONTINUE` or first `DEADLOCK` → next round

   h. **Continue** to the next round

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

9. **Finalize session log**: Append the summary to `current.md`, then rename it to:
   `council/sessions/[YYYY-MM-DD-HHMMSS].md`

10. **Update decisions log**: If a significant decision was reached, append to:
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
- Stream each exchange in real-time so the user sees the conversation as it happens
- Keep your positions concise but substantive
- Actively engage with Gemini's counterpoints
- Match your debate intensity to the stance level
- The goal is better decisions through diverse perspectives
- You are the Chair - maintain neutrality when summarizing
- Preserve Gemini's exact words in the session log - never paraphrase
- On ESCALATE status, pause everything and get user input before continuing
