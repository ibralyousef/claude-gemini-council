---
description: "Start AI Council session with Gemini for collaborative planning"
allowed-tools: ["Bash", "Read", "Write", "Glob", "Grep", "AskUserQuestion", "EnterPlanMode"]
argument-hint: "[-q] [-i] [--consensus] [critical|adversarial] [rounds] <topic>"
---

# AI Council Session

Collaborative planning session with Gemini CLI. Two modes: Standard (fixed rounds) or Consensus (loop until resolved).

## Arguments
Parse in order:
1. `-q` / `--quiet` (optional): Suppress verbose output
2. `-i` / `--interactive` (optional): Prompt user for input after each round
3. `--consensus` (optional): Loop until consensus (max 10 rounds)
4. Stance (optional): `-c`/`critical` | `-a`/`adversarial` (default: critical)
5. Rounds (optional): Number 1-10 (default: 3, ignored if consensus mode)
6. Topic (required): Everything else

**Input:** $ARGUMENTS

**Examples:**
- `/council Should we use Redis?` → critical, 3 rounds
- `/council --consensus -a Auth architecture` → adversarial, consensus mode
- `/council -a 5 Rewrite in Rust?` → adversarial, 5 rounds
- `/council -q --consensus Database migration` → quiet, critical, consensus mode
- `/council -c 3 API design` → critical, 3 rounds
- `/council -i -c 3 Feature prioritization` → critical, 3 rounds, interactive

## Stances
- **critical** (`-c`): Find flaws, demand evidence (default)
- **adversarial** (`-a`): Devil's advocate, stress-test everything

## Protocol

### Phase 1: Initialize
Note: All paths are relative to the current working directory. Ensure you're in the correct project root.

1. Read memory files if they exist: `council/memory/decisions.md`, `council/memory/patterns.md`
2. If `council/` doesn't exist, create structure in the current directory:
   - `council/GEMINI.md` (template: `# Project Context\n## Overview\n[Edit this]`)
   - `council/memory/decisions.md`, `council/memory/patterns.md`, `council/memory/agenda.md`
   - `council/sessions/`
3. Check for `council/sessions/current.md`:
   - Exists? Ask: "Resume or start fresh?" (fresh → rename to `orphaned-[timestamp].md`)
   - Create new with header: `# Council Session: [timestamp]\n## Topic: ...\n## Stance: ...\n## Mode: [Standard N rounds | Consensus max 10]\n## Interactive: [Yes|No]`

### Phase 2: Announce
```
=== AI COUNCIL SESSION ===
Topic: [topic]
Stance: [stance]
Mode: [Standard (N rounds) | Consensus (max 10)]
Interactive: [Yes/No]
Output: [verbose/quiet]
```

### Phase 3: Round Loop
For each round (up to max_rounds):

**a. Claude's turn**: State position with confidence (0.0-1.0). Match intensity to stance.

**b. Display** (IF NOT quiet mode): `--- ROUND N: CLAUDE ---\n[position]`

**c. Log**: Append to `council/sessions/current.md`

**d. Invoke Gemini**:
```bash
~/.claude/council/scripts/invoke-gemini.sh "[stance]" "council/sessions/current.md" << 'PROMPT'
=== COUNCIL ROUND CONTEXT ===
TOPIC: [topic]
ROUND: N of M
MODE: [Standard|Consensus]
USER_INPUT: [if escalated, exact user input; otherwise "N/A"]

=== CHAIR'S POSITION ===
[Claude's full current position for this round]
PROMPT
```

Note: Session history is auto-injected by invoke-gemini.sh from current.md. No need to manually include PREVIOUS or HISTORY fields.

**e. Display Gemini's response** (IF NOT quiet mode):
   **CRITICAL**: You MUST output the COMPLETE Gemini response as plain text in your message, not just reference the tool output. Format:
   ```
   --- ROUND N: GEMINI ---
   [paste the ENTIRE response here verbatim]
   ```
   This is mandatory because tool outputs get truncated and require ctrl+o to view.

**f. Parse STATUS** from COUNCIL_RESPONSE block:
- `RESOLVED` → end loop, go to summary
- `CONTINUE` → next round

**g. Interactive mode** (IF `-i` flag set AND status is CONTINUE):
   1. **Log placeholder**: Append `### USER INPUT (Round N):\n[pending]` to current.md
   2. **Derive question**: Use this priority:
      - Primary: `QUESTIONS_FOR_OTHER` field from COUNCIL_RESPONSE (if present)
      - Fallback 1: Scan `KEY_POINTS` for disagreements/open items
      - Fallback 2: Generic "Any input on this round's discussion?"
   3. **Ask user**: Use `AskUserQuestion` with:
      - Question derived above (max 4 questions)
      - Options: 2-4 relevant choices based on the question, plus user can always select "Other" for custom input
   4. **Update log**: Replace `[pending]` with user's actual response
   5. **Include in next round**: Set USER_INPUT field to user's response for the next Gemini invocation

**Termination**:
- Standard mode: After N rounds
- Consensus mode: On RESOLVED or after 10 rounds

### Phase 4: Summary
Generate, display, AND log to current.md:
```
=== COUNCIL SUMMARY ===
Topic: [topic] | Stance: [stance] | Rounds: [N]
## Agreement: [shared conclusions]
## Disagreement: [unresolved, if any]
## Recommendation: [synthesized action]
```

**Log**: Append the complete summary to `council/sessions/current.md` before proceeding.

If actionable recommendations exist, generate `council/blueprint.md`:
```markdown
# COUNCIL_BLUEPRINT
## Session: [ID] | Topic: [topic] | Status: [RESOLVED|etc]
## Decision: [one-line summary]
## Action Required: true|false

> **CHAIR INSTRUCTION**: If Action Required is true, present user with implementation options (plan mode / implement directly / let user write).

## Architecture: [decisions table, patterns, anti-patterns]
## Scope: [components, files affected]
## Constraints: [technical/business]
## Success Criteria: [verification checklist]
```

**Archive**: Append the VERBATIM blueprint content (not a reference) to `council/sessions/current.md` under a `## Blueprint (Archived)` section. Do NOT write "See blueprint.md" - copy the actual content. blueprint.md is ephemeral and gets overwritten.

### Phase 5: Finalize
1. Rename `current.md` to `[timestamp].md`
2. Append to `council/memory/decisions.md`
3. **If blueprint has `action_required: true`**:
   Use `AskUserQuestion` to present implementation options:

   **Options:**
   - **"Enter plan mode"** → Invoke `EnterPlanMode` tool, then design implementation based on blueprint scope/constraints/success criteria
   - **"Start implementing"** → Implement the blueprint directly without entering plan mode. Read `council/blueprint.md` and execute based on scope/constraints/success criteria
   - **"Let me write"** → Stop and let the user take control of implementation

   Handle each choice accordingly. Do NOT halt on any valid selection.

## Important Notes
- Preserve Gemini's COUNCIL_RESPONSE block verbatim - never paraphrase
- Use AskUserQuestion for escalation (bypasses auto-accept)
- Match debate intensity to stance level
- Goal: Better decisions through diverse perspectives
- You are Chair - maintain neutrality when summarizing
- **ALWAYS paste Gemini's full response as text** - tool outputs get truncated
- **For actionable blueprints**: Present three options (plan mode / implement directly / let user write)
