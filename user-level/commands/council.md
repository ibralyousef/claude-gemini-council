---
description: "Start AI Council session with Gemini for collaborative planning"
allowed-tools: ["Bash", "Read", "Write", "Glob", "Grep", "AskUserQuestion"]
argument-hint: "[-q] [-c] [-b|-c|-a] [rounds] <topic>"
---

# AI Council Session

Collaborative planning session with Gemini CLI. Two modes: Standard (fixed rounds) or Consensus (loop until resolved).

## Arguments
Parse in order:
1. `-q` / `--quiet` (optional): Suppress verbose output
2. `--consensus` (optional): Loop until consensus (max 10 rounds)
3. Stance (optional): `-b` balanced | `-c` critical | `-a` adversarial (default: balanced)
4. Rounds (optional): Number 1-10 (default: 3, ignored if consensus mode)
5. Topic (required): Everything else

**Input:** $ARGUMENTS

**Examples:**
- `/council Should we use Redis?` → balanced, 3 rounds
- `/council --consensus -a Auth architecture` → adversarial, consensus mode
- `/council -a 5 Rewrite in Rust?` → adversarial, 5 rounds
- `/council -q --consensus Database migration` → quiet, consensus mode
- `/council -c 3 API design` → critical, 3 rounds

## Stances (no cooperative - too soft)
- **-b / balanced**: Fair critique, acknowledge pros/cons (default)
- **-c / critical**: Find flaws, demand evidence
- **-a / adversarial**: Devil's advocate, stress-test everything

## Protocol

### Phase 1: Initialize
1. Read memory files if they exist: `council/memory/decisions.md`, `council/memory/patterns.md`
2. If `council/` doesn't exist, create structure:
   - `council/GEMINI.md` (template: `# Project Context\n## Overview\n[Edit this]`)
   - `council/memory/decisions.md`, `council/memory/patterns.md`
   - `council/sessions/`
3. Check for `council/sessions/current.md`:
   - Exists? Ask: "Resume or start fresh?" (fresh → rename to `orphaned-[timestamp].md`)
   - Create new with header: `# Council Session: [timestamp]\n## Topic: ...\n## Stance: ...\n## Mode: [Standard N rounds | Consensus max 10]`
4. Update status: `~/.claude/council/scripts/council-status.sh "Council: Starting..."`

### Phase 2: Announce
```
=== AI COUNCIL SESSION ===
Topic: [topic]
Stance: [stance]
Mode: [Standard (N rounds) | Consensus (max 10)]
Output: [verbose/quiet]
```

### Phase 3: Round Loop
For each round (up to max_rounds):

**a. Status update**: `council-status.sh "Council: Round N/M"`

**b. Claude's turn**: State position with confidence (0.0-1.0). Match intensity to stance.

**c. Display** (verbose mode): `--- ROUND N: CLAUDE ---\n[position]`

**d. Log**: Append to `council/sessions/current.md`

**e. Invoke Gemini**:
```bash
~/.claude/council/scripts/invoke-gemini.sh "[stance]" "council/sessions/current.md" << 'PROMPT'
TOPIC: [topic]
ROUND: N of M
MODE: [Standard|Consensus]
CLAUDE'S POSITION: [position]
PREVIOUS: [summary]
[Instructions for Gemini...]
PROMPT
```

**f. Display Gemini's response** (verbose mode): `--- ROUND N: GEMINI ---\n[response]`

**g. Parse STATUS** from COUNCIL_RESPONSE block:
- `RESOLVED` → end loop, go to summary
- `CONTINUE` → next round
- `DEADLOCK` → if 2 consecutive, escalate
- `ESCALATE` → use AskUserQuestion to get user input

**Termination**:
- Standard mode: After N rounds
- Consensus mode: On RESOLVED or after 10 rounds

### Phase 4: Summary
Generate and display:
```
=== COUNCIL SUMMARY ===
Topic: [topic] | Stance: [stance] | Rounds: [N]
## Agreement: [shared conclusions]
## Disagreement: [unresolved, if any]
## Recommendation: [synthesized action]
```

If actionable recommendations exist, generate `council/blueprint.md`:
```markdown
# COUNCIL_BLUEPRINT
## Session: [ID] | Topic: [topic] | Status: [RESOLVED|etc]
## Decision: [one-line summary]
## Action Required: true|false
## Architecture: [decisions table, patterns, anti-patterns]
## Scope: [components, files affected]
## Constraints: [technical/business]
## Success Criteria: [verification checklist]
```

### Phase 5: Finalize
1. Status: `council-status.sh "Council: Complete"`
2. Rename `current.md` to `[timestamp].md`
3. Append to `council/memory/decisions.md`
4. Clear status: `council-status.sh clear`
5. **If blueprint has `action_required: true`**:
   - Invoke `EnterPlanMode` tool automatically (no user prompt)
   - In plan mode: read `council/blueprint.md`, design implementation based on scope/constraints/success criteria

## Important Notes
- Preserve Gemini's COUNCIL_RESPONSE block verbatim - never paraphrase
- Use AskUserQuestion for escalation (bypasses auto-accept)
- Match debate intensity to stance level
- Goal: Better decisions through diverse perspectives
- You are Chair - maintain neutrality when summarizing
