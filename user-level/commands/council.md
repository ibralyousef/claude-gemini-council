---
description: "Start AI Council session with agent team for collaborative planning"
allowed-tools: ["Read", "Write", "Glob", "Grep", "AskUserQuestion", "EnterPlanMode", "TeamCreate", "TeamDelete", "SendMessage", "Task"]
argument-hint: "[--resume <session>] [-q] [-i] [--consensus] [-n N] [critical|adversarial] [rounds] <topic>"
---

# AI Council Session

Collaborative planning session with an agent team. Two modes: Standard (fixed rounds) or Consensus (loop until resolved).

## Arguments
Parse in order:
1. `--resume <session>` (optional): Resume an archived session. Provide path (e.g., `council/sessions/2025-12-18-120000.md`) or session ID (e.g., `2025-12-18-120000`). Topic is inherited; other flags can override stance/mode.
2. `-q` / `--quiet` (optional): Suppress verbose output
3. `-i` / `--interactive` (optional): Prompt user for input after each round
4. `--consensus` (optional): Loop until consensus (max 10 rounds)
5. `-n N` / `--agents N` (optional): Number of participants, 1-5 (default: 2)
6. Stance (optional): `-c`/`critical` | `-a`/`adversarial` (default: critical)
7. Rounds (optional): Number 1-10 (default: 3, ignored if consensus mode)
8. Topic (required unless --resume): Everything else

> **No arguments?** If invoked without a topic (and without `--resume`), the council will display your strategic agenda. Use `/council-agenda add` to queue topics.

**Input:** $ARGUMENTS

**Examples:**
- `/council Should we use Redis?` → critical, 3 rounds, 2 participants
- `/council --consensus -a Auth architecture` → adversarial, consensus mode, 2 participants
- `/council -a 5 Rewrite in Rust?` → adversarial, 5 rounds, 2 participants
- `/council -n 3 Database design` → critical, 3 rounds, 3 participants
- `/council -n 4 -a --consensus API migration` → adversarial, consensus, 4 participants
- `/council -q --consensus Database migration` → quiet, critical, consensus mode
- `/council -i -c 3 Feature prioritization` → critical, 3 rounds, interactive
- `/council --resume 2025-12-18-120000` → resume session, inherit topic
- `/council --resume council/sessions/2025-12-18-120000.md -a` → resume with adversarial stance
- `/council` → (no args) display strategic agenda

## Stances
- **critical** (`-c`): Find flaws, demand evidence (default)
- **adversarial** (`-a`): Devil's advocate, stress-test everything

## Persona System
Each participant gets a distinct analytical lens based on the total number of participants:

| Count | Personas Assigned |
|-------|-------------------|
| 1 | `generalist` |
| 2 | `pragmatist`, `skeptic` |
| 3 | `pragmatist`, `skeptic`, `architect` |
| 4 | `pragmatist`, `skeptic`, `architect`, `user-advocate` |
| 5 | `pragmatist`, `skeptic`, `architect`, `user-advocate`, `devil's-advocate` |

**Persona definitions** (injected into each participant's prompt):
- **generalist**: "You analyze problems holistically, balancing feasibility, cost, and long-term maintainability. No single dimension dominates your thinking."
- **pragmatist**: "You prioritize what can be shipped quickly and reliably. You favor proven solutions over novel ones, and always ask: what's the simplest thing that works?"
- **skeptic**: "You question assumptions and look for hidden risks. You ask what can go wrong, what's being overlooked, and whether the evidence actually supports the claims."
- **architect**: "You think in systems. You focus on scalability, separation of concerns, extensibility, and long-term technical debt. You evaluate how decisions compose."
- **user-advocate**: "You represent the end-user perspective. You focus on usability, developer experience, error messages, documentation, and whether the solution actually solves the user's problem."
- **devil's-advocate**: "You deliberately argue the opposite position, even if you privately agree. Your job is to stress-test ideas by finding the strongest counterarguments."

## Protocol

### Phase 1: Initialize
Note: All paths are relative to the current working directory. Ensure you're in the correct project root.

0. **If no arguments provided** (no topic, no --resume):
   - Check if `council/memory/agenda.md` exists
   - If yes: Read and display agenda items (same format as `/council-agenda list`)
   - Display: "Select a topic from your agenda or run `/council <topic>` directly"
   - Exit (do not proceed to session creation)
   - If no agenda exists: Show help message with usage examples and exit

1. Read memory files if they exist: `council/memory/decisions.md`
2. If `council/` doesn't exist, create structure in the current directory:
   - `council/memory/decisions.md`, `council/memory/agenda.md`
   - `council/sessions/`
3. Check for `council/sessions/current.md`:
   - Exists? Ask: "Resume or start fresh?" (fresh → rename to `orphaned-[timestamp].md`)
   - Create new with header: `# Council Session: [timestamp]\n## Topic: ...\n## Stance: ...\n## Mode: [Standard N rounds | Consensus max 10]\n## Participants: N\n## Interactive: [Yes|No]`

4. **If `--resume` flag present**:
   - Locate session file: resolve path or session ID to `council/sessions/[ID].md`
   - If not found: Display error "Session not found: [path]" and exit
   - Read session file, extract Topic/Stance/Mode from headers
   - Copy session content to `council/sessions/current.md`
   - Append to current.md:
     ```
     ---

     ## RESUMED
     **Original Session**: [session ID]
     **Resumed At**: [timestamp]
     **Reason**: Continuing discussion
     ```
   - Lock topic from session (cannot be overridden)
   - Allow flag overrides for stance/mode/rounds/agents
   - Skip normal "Resume or start fresh?" prompt (step 3)

5. **Create agent team**:
   - Use `TeamCreate` with name `"council-session"`
   - Read `~/.claude/council/participant-protocol.md` for the base protocol
   - Read `council/memory/decisions.md` if it has content (entries matching `^## [0-9]`)
   - For each participant (1 through N), spawn using `Task` tool:
     - `name`: `"participant-{i}"` (e.g., `participant-1`, `participant-2`)
     - `team_name`: `"council-session"`
     - `subagent_type`: `"general-purpose"`
     - The prompt MUST include ALL of the following, concatenated:
       ```
       === COUNCIL PROTOCOL ===
       [contents of participant-protocol.md]

       === YOUR PERSONA ===
       Persona: [persona name]
       [persona definition from the table above]

       === YOUR STANCE FOR THIS SESSION ===
       [stance instructions — see Stance Definitions below]

       === PAST COUNCIL DECISIONS ===
       [contents of decisions.md, if any]

       === INSTRUCTIONS ===
       You are participant-{i} in a council session about: [topic]
       Mode: [Standard N rounds | Consensus max 10]
       Participants: [N total]

       Wait for round context messages from the Chair via SendMessage.
       For each round, form your position, then respond via SendMessage to the team lead.
       Include your full analysis AND a COUNCIL_RESPONSE block in every response.
       ```

### Stance Definitions (injected into participant prompts)
```
STANCE: Critical
- Actively look for flaws and gaps
- Question assumptions and evidence
- Push back on weak justifications
- Demand rigorous reasoning
- Don't accept claims without evidence
- Be thorough in your analysis
```

```
STANCE: Adversarial (Devil's Advocate)
- Challenge EVERYTHING, even good ideas
- Find counterarguments to every point
- Stress-test ideas to breaking point
- Assume the worst-case scenario
- Your job is to find weaknesses, not agreement
- Only accept ideas that survive intense scrutiny
- Be relentless but professional
```

### Phase 2: Announce
```
=== AI COUNCIL SESSION ===
Topic: [topic]
Stance: [stance]
Mode: [Standard (N rounds) | Consensus (max 10)]
Participants: [N] ([persona-1], [persona-2], ...)
Interactive: [Yes/No]
Output: [verbose/quiet]
```

### Phase 3: Round Loop
For each round (up to max_rounds):

**a. Chair's turn**: State position with confidence (0.0-1.0). Match intensity to stance.

**b. Display** (IF NOT quiet mode): `--- ROUND N: CHAIR ---\n[position]`

**c. Log**: Append to `council/sessions/current.md`

**d. Invoke participants sequentially**:
For each participant-{i} (1 through N):

Send a message via `SendMessage`:
```
type: "message"
recipient: "participant-{i}"
content: |
  === COUNCIL ROUND CONTEXT ===
  TOPIC: [topic]
  ROUND: N of M
  MODE: [Standard|Consensus]
  USER_INPUT: [if provided via interactive mode, exact user input; otherwise "N/A"]

  === CHAIR'S POSITION ===
  [Chair's full current position for this round]

  === OTHER PARTICIPANTS THIS ROUND ===
  [For participant-2+: include all prior participants' positions from THIS round]
  [For participant-1: "You are first to respond this round."]
summary: "Round N context for participant-{i}"
```

Wait for the participant's response (auto-delivered via message).

**e. Display each participant's response** (IF NOT quiet mode):
**CRITICAL**: You MUST output the COMPLETE participant response as plain text in your message, not just reference the tool output. Format:
```
--- ROUND N: PARTICIPANT-{i} ([persona]) ---
[paste the ENTIRE response here verbatim]
```
This is mandatory because tool outputs get truncated and require ctrl+o to view.

**f. Log**: Append each participant's response to `council/sessions/current.md` as:
```
### PARTICIPANT-{i}'S POSITION ([persona])
[verbatim response]
```

**g. Parse STATUS from ALL COUNCIL_RESPONSE blocks**:
- **Consensus detection**:
  - If N ≤ 2: `RESOLVED` only when ALL participants say `RESOLVED`
  - If N ≥ 3: `RESOLVED` when >50% of participants say `RESOLVED`
- `RESOLVED` → end loop, go to summary
- Otherwise → `CONTINUE` to next round

**h. Interactive mode** (IF `-i` flag set AND status is CONTINUE AND no previous `[disabled interactive mode]` in session log):
   1. **Log placeholder**: Append `### USER INPUT (Round N):\n[pending]` to current.md
   2. **Derive question**: Use this priority:
      - Primary: `QUESTIONS_FOR_OTHER` fields from any participant's COUNCIL_RESPONSE
      - Fallback 1: Scan `KEY_POINTS` for disagreements/open items
      - Fallback 2: Generic "Any input on this round's discussion?"
   3. **Ask user**: Use `AskUserQuestion` with:
      - Question derived above (max 4 questions)
      - Options: 2-4 relevant choices based on the question + "Skip this round" + "Disable prompts for remaining rounds"
      - (User can always select "Other" for custom input)
   4. **Handle response**:
      - If "Skip this round": Update log with `[skipped]`, set USER_INPUT to `[user skipped]`
      - If "Disable prompts for remaining rounds": Update log with `[disabled interactive mode]`, skip Phase 3h for all subsequent rounds
      - Otherwise: Update log with user's actual response, set USER_INPUT to response
   5. **Include in next round**: Set USER_INPUT field accordingly for the next round's context messages

**Termination**:
- Standard mode: After N rounds
- Consensus mode: On RESOLVED or after 10 rounds

### Phase 4: Summary
Generate, display, AND log to current.md:
```
=== COUNCIL SUMMARY ===
Topic: [topic] | Stance: [stance] | Rounds: [N] | Participants: [count]
## Agreement: [shared conclusions across all participants]
## Disagreement: [unresolved points — attribute to specific participants by persona]
## Recommendation: [synthesized action from Chair + all participant positions]
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
1. **Shutdown team**:
   - Send `shutdown_request` via `SendMessage` to each participant
   - After all participants confirm shutdown, call `TeamDelete`
2. Rename `current.md` to `[timestamp].md`
3. Append to `council/memory/decisions.md`:
   - **If resumed session**: Use Amendment format:
     ```markdown
     ## [YYYY-MM-DD] - Amendment to [Original Topic from Session Header]
     - **Resumed From**: [original session ID]
     - **Topic**: [topic]
     - **Decision**: [summary]
     ...
     ```
   - **If new session**: Use standard format
4. **If blueprint has `action_required: true`**:
   Use `AskUserQuestion` to present implementation options:

   **Options:**
   - **"Enter Plan Mode (Generate detailed steps)"** → Invoke `EnterPlanMode` tool, then design implementation based on blueprint scope/constraints/success criteria
   - **"Execute Immediately (Skip Plan Mode)"** → Implement the blueprint directly without entering plan mode. Read `council/blueprint.md` and execute based on scope/constraints/success criteria
   - **"Let me write"** → Stop and let the user take control of implementation

   > **Note:** "Enter Plan Mode" invokes the `EnterPlanMode` tool, which has its own confirmation prompt. This is intentional - the tool provides structured step-by-step planning beyond the council blueprint. Users who want a frictionless path should select "Execute Immediately".

   Handle each choice accordingly. Do NOT halt on any valid selection.

## Important Notes
- Preserve each participant's COUNCIL_RESPONSE block verbatim - never paraphrase
- Use AskUserQuestion for escalation (bypasses auto-accept)
- Match debate intensity to stance level
- Goal: Better decisions through diverse perspectives
- You are Chair - maintain neutrality when summarizing
- **ALWAYS paste each participant's full response as text** - tool outputs get truncated
- **For actionable blueprints**: Present three options (plan mode / implement directly / let user write)
- **Participants are spawned ONCE** at session start and messaged each round — do NOT re-spawn per round
- **Sequential within a round**: participant-1 responds first, then participant-2 sees participant-1's response, etc.

## Immutability Mandate
**CRITICAL**: The Chair MUST NEVER delete, overwrite, or destructively summarize the session log (`current.md`) during an active session. All summaries must be APPENDED, never substituted for source material.

**Context Limits**: If `current.md` exceeds safe token limits, the Chair MUST rotate the file (rename current → `archive-[timestamp].md`) and start a fresh `current.md`. DATA LOSS IS ACCEPTABLE ONLY VIA ARCHIVAL ROTATION, NEVER IN-PLACE REPLACEMENT.
