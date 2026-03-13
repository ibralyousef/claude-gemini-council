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


## 2025-12-11 - Council Implementation Self-Review (Adversarial)
- **Topic**: Do you like the current implementation of the council?
- **Stance**: adversarial
- **Decision**: Partial agreement - implementation has fixable bugs but disagreement on severity. Claude: "adequate for reference". Gemini: "NOT adequate, requires blocking remediation".
- **Bugs Identified**:
  1. P0 Security: CLI argument exposes context to process table - use stdin
  2. P0 Data Integrity: grep -v "^$" destroys Markdown formatting - remove it
  3. P0 Logic: Escalation response file not being read by Chair
  4. P1 Scalability: ARG_MAX (1MB) limit on CLI args - fixed by stdin change
- **Rationale**: Adversarial stress-testing successfully found real vulnerabilities in the implementation
- **Dissent**: Gemini rejected "adequate" label; Claude maintained it's acceptable for development use
- **Session**: council/sessions/2025-12-11-235500.md

## 2025-12-11 - Council Implementation Adversarial Review II
- **Topic**: Is the council implementation flawed or missing super important features for complex tasks?
- **Stance**: adversarial
- **Decision**: Two blocking P0 issues confirmed requiring immediate remediation:
  1. **Transport Layer Broken**: CLI args for prompts will hit ARG_MAX (~262KB) before any context management runs. Fix requires file streaming to stdin, not just echo expansion.
  2. **Memory System is Context Dumping**: Cat'ing entire decisions.md is O(N) resource leak. Must build intelligent retrieval BEFORE disabling context dump, or council becomes "lobotomized".
- **Scope Boundary Established**: Council = Policy/Architecture DECISIONS (Senate role). Agent = Execution PLANS (General role). Council may output "agenda items" (sub-questions) but not step-by-step plans.
- **Rationale**: Both issues were verified by code inspection. Gemini proved the prior "ARG_MAX fix" claim was misleading - only the internal Gemini CLI call uses stdin; the wrapper still takes CLI args.
- **Dissent**: 
  - Output validation: Claude says P1 (regex ok for personal use), Gemini says P0 (structured JSON required for automation)
  - Security: Gemini maintains process table exposure is P0 even for personal tooling
- **False Positives Identified**: Race condition claim was wrong - execution is strictly synchronous
- **Rounds to Resolution**: 5
- **Session**: council/sessions/2025-12-11-120000.md


## 2025-12-11 - Council Blueprint Output (Consensus)
- **Topic**: Council should output technical implementation plans/architecture, ending with plan mode invocation
- **Stance**: critical
- **Decision**: Council protocol to be updated with COUNCIL_BLUEPRINT output format, persisted to `council/blueprint.md`, followed by EnterPlanMode invocation when action_required is true
- **Rationale**: "Senate produces Bills, not press releases" - council must output legislative-quality specifications for downstream automation
- **Dissent**: None - full consensus in 5 rounds
- **Session**: council/sessions/2025-12-11-160000.md


## 2025-12-11 - Council Session Visualization Function (Consensus)
- **Topic**: Create a function that outputs beautiful, colorful, deterministic media visualization of council session files
- **Stance**: balanced
- **Decision**: Use WeasyPrint + Jinja2 for HTML→PDF/PNG, svgwrite for SVG. Pipeline: Markdown → Parser (mistune) → JSON → Template → Output. Embed fonts and pin dependencies for determinism.
- **Rationale**: WeasyPrint offers superior design flexibility via HTML/CSS while maintaining determinism with embedded assets; SVG provides scalability and small file sizes
- **Dissent**: None - full consensus
- **Rounds to Consensus**: 2


## 2025-12-11 - Blueprint Implementation Refinement (Consensus)
- **Topic**: Should the COUNCIL_BLUEPRINT concept from council/blueprint.md be implemented?
- **Stance**: balanced
- **Decision**: Yes, implement with conditional activation (action_required: true) and synthesis approach (reference decisions.md/patterns.md, don't duplicate)
- **Rationale**: Addresses gap between "press release" summaries and actionable plans; clear role separation (Council=WHAT/WHY, Agent=HOW)
- **Dissent**: None - full consensus
- **Rounds to Consensus**: 1

## 2025-12-11 - File Sync & Council Utility Enhancements (Consensus)
- **Topic**: 1. Make sure the repo and ~/.claude doesn't have unsynced files. 2. What can we add to this council? Come up with a concrete plan to make this council more useful and meaningful.
- **Stance**: adversarial
- **Decision**: 
  1. **P0 Symlink Architecture**: Replace copy-based installation with symlinks (~/.claude/commands → repo). Single source of truth eliminates drift by design.
  2. **P1 Agenda System**: New `council/memory/agenda.md` + `/council-agenda` command. Transforms council from reactive "on-demand chat" to proactive "strategic planning body".
  3. **P2 Memory Archival**: When decisions.md > 50KB, rotate to decisions-archive-[YYYY].md (not truncation).
- **Rationale**: 
  - Gemini proved ~/.claude/commands had diverged 90+ lines from repo (Blueprint code missing in repo)
  - Claude's "do nothing" stance was refuted by evidence
  - Both agreed symlinks > manual sync > sync scripts
  - Agenda system adds continuity and strategic planning capability
- **Dissent**: 
  - Claude proposed "health check" command → Gemini rejected as "admin fluff" (fix fragility, don't instrument it)
  - Claude proposed truncation → Gemini proved memory is only 4KB, truncation is premature
- **Rounds to Consensus**: 3
- **Action Items Implemented**:
  - [x] Synced ~/.claude/commands → user-level/commands
  - [x] Created symlinks for council commands
  - [x] Updated install.sh for symlink-based installation
  - [x] Created council/memory/agenda.md
  - [x] Created /council-agenda command
- **Session**: council/sessions/2025-12-11-164500.md

## 2025-12-11 - Protocol Consolidation & Simplification (Consensus)
- **Topic**: The council protocol has been rewritten multiple times - ensure it's still robust and coherent, prioritize what to remove/add
- **Stance**: critical
- **Decision**: 
  1. **MERGE** council-consensus.md INTO council.md (single source of truth)
  2. **ADD** `--consensus` flag for consensus mode
  3. **DELETE** council-consensus.md (no thin wrapper - slash commands are standalone)
  4. **CONDENSE** 417 lines → 132 lines via:
     - Collapsed 16 steps to 5 phases
     - Condensed templates to single-line descriptions
     - Removed verbose blueprint schema (referenced, not embedded)
- **Rationale**: 
  - ~200 lines were duplicated between files (DRY violation, maintenance drift)
  - File splitting rejected: Claude Code has no auto-include, would require extra read_file call
  - Thin wrapper rejected: slash commands standalone, wrapper = context switch + hallucination risk
  - Keeping templates inline for portability (no cold-start penalty)
- **Dissent**: None - full consensus
- **Rounds to Consensus**: 4
- **Implementation**: 
  - [x] Merged council.md (132 lines, down from 417)
  - [x] Deleted council-consensus.md
  - [x] Updated install.sh
  - [x] Updated symlinks
- **Session**: council/sessions/2025-12-11-165800.md

## 2025-12-11 - Protocol Coherence Review (Consensus)
- **Topic**: Protocol review - ensure robustness/coherence, identify what to remove/add
- **Stance**: critical
- **Decision**: Clean up protocol inconsistencies across all files
- **Changes Implemented**:
  1. **P0**: Removed "Cooperative" stance from protocol.md and invoke-gemini.sh
  2. **P0**: Added COUNCIL_BLUEPRINT schema to protocol.md
  3. **P0**: Added QUESTION field to COUNCIL_RESPONSE format for escalation
  4. **P1**: Added explicit quiet mode conditionals to council.md
  5. **P1**: Added USER_INPUT field for AskUserQuestion answer logging
  6. **P1**: Deleted council-terminal.sh (dead code)
  7. **P2**: Deleted escalation-response.txt (legacy artifact)
  8. **Sync**: Replaced ~/.claude/council/ files with symlinks to repo
- **Rationale**: Multiple rewrites had caused stance definition drift, dead code accumulation, and incomplete escalation flow
- **Dissent**: None - full consensus in 3 rounds
- **Session**: council/sessions/2025-12-11-091500.md

## 2025-12-11 - Protocol Bug Fixes (Consensus)
- **Topic**: Three protocol issues - EnterPlanMode clarity, session logging, Gemini response display
- **Stance**: critical
- **Decision**: Fix three bugs in council.md
- **Bugs Fixed**:
  1. **P0**: EnterPlanMode missing from allowed-tools (mandated but not permitted)
  2. **P1**: Phase 4 has no logging instruction (summary lost before rename)
  3. **P2**: Phase 3f unclear about displaying Gemini response in chat
- **Rationale**: User reported ctrl+o requirement to view responses, and noticed session logs incomplete
- **Dissent**: None - full consensus in 1 round
- **Session**: council/sessions/2025-12-11-093000.md

## 2025-12-11 - Blueprint Storage & Chair Architecture (Consensus)
- **Topic**: Should blueprints be archived? Should Chair be a spawned agent?
- **Stance**: critical
- **Decision**:
  1. **Blueprint Storage**: Keep blueprint.md as ephemeral "Active Plan", but archive copy to session file before rename
  2. **Chair Architecture**: Keep current design (Main Claude as Chair)
- **Rationale**:
  - Blueprint: decisions.md captures WHAT, but blueprint captures HOW (success criteria, files). Worth preserving. Session file is natural archive location.
  - Chair: Spawned agent provides theoretical neutrality but practical complexity outweighs benefit. Existing safeguards (Immutability Rule, Debate as Debiasing) sufficient.
- **Dissent**: None - full consensus in 2 rounds (initial disagreement on both points, resolved)
- **Session**: council/sessions/2025-12-11-094500.md

## 2025-12-11 - Prompt Structure Improvements (Consensus)
- **Topic**: Are Claude's prompts to Gemini acceptable? Does Gemini have improvement suggestions?
- **Stance**: critical
- **Decision**:
  1. Auto-inject SESSION HISTORY via invoke-gemini.sh from current.md
  2. Remove per-round `[Instructions for Gemini...]` - Protocol + Stance define task
  3. Adopt new prompt structure: CONTEXT, POSITION, HISTORY sections
  4. Handle Round 1 edge case gracefully
- **Rationale**:
  - Summaries are lossy/biased; verbatim history prevents "amnesia" and detects circular logic
  - Per-round instructions are noise since protocol.md already injected
  - 50KB history is only ~6% of 200k context - token limit concern was premature
- **Dissent**: None - full consensus in 3 rounds
- **Session**: council/sessions/2025-12-11-100000.md

## 2025-12-11 - Repo Installation Readiness (Consensus)
- **Topic**: Will this repo successfully install the council when published?
- **Stance**: critical
- **Decision**: NO - P0 bug prevents installation. Fixes required.
- **Issues Found**:
  1. P0: install.sh references deleted council-terminal.sh (WILL FAIL)
  2. P1: README.md outdated (wrong commands, deleted files)
  3. P1: install.sh uses cp not symlinks for protocol/scripts
  4. P2: No Gemini CLI functional verification
- **Fixes Required**:
  1. Remove council-terminal.sh from install.sh
  2. Symlink ALL user-level files
  3. Update README.md comprehensively
  4. Add Gemini --version check
- **Dissent**: None - full consensus in 2 rounds
- **Session**: council/sessions/2025-12-11-103000.md

## 2025-12-11 - Markdown Heading Consistency (Consensus)
- **Topic**: Claude uses `### CLAUDE'S POSITION` but Gemini outputs `*** GEMINI ***` - how to fix?
- **Stance**: balanced
- **Decision**: Implement Script-Authoritative approach - the wrapper script is the "System of Record" for document structure
- **Changes Required**:
  1. Edit `invoke-gemini.sh`: Change `**GEMINI:**` to `### GEMINI'S POSITION` (lines 142-147)
  2. Edit `protocol.md`: Add instruction for Gemini not to generate its own header
- **Rationale**: Script-authoritative is deterministic (bash) vs probabilistic (model output). Avoids double-header problem and reduces prompt token overhead.
- **Dissent**: None - full consensus in 1 round
- **Session**: council/sessions/2025-12-11-120000.md

## 2025-12-11 - Gemini Read-Only Restriction (Consensus)
- **Topic**: Should Gemini be allowed to modify files, or should non-Chair participants only plan/architect?
- **Stance**: balanced
- **Decision**: Restrict Gemini to read-only tools during council sessions. Replace `-y` (yolo mode) with `--allowed-tools` whitelist.
- **Allowed Tools**: `read_file`, `list_directory`, `glob`, `search_file_content`
- **Excluded Tools**: `write_file`, `replace`, `run_shell_command`
- **Rationale**:
  - Council = Senate (deliberates, produces blueprints), not Executor (makes changes)
  - User reported confusion when Gemini modified files mid-session
  - Single chain of responsibility: only Claude (Chair) makes changes after plan mode approval
- **Trade-off Accepted**: Gemini loses `run_shell_command` (git status, npm test) in exchange for safety
- **Dissent**: None - full consensus in 1 round
- **Session**: council/sessions/2025-12-11-130000.md

## 2025-12-11 - Bidirectional Council Chairing (Consensus)
- **Topic**: Can Gemini Chair council sessions when invoked from its CLI?
- **Stance**: balanced
- **Decision**: Yes - implement bidirectional council chairing via symmetric architecture. Either AI can serve as Chair or Participant with appropriate tool restrictions.
- **Key Points**:
  1. Claude CLI supports `--allowedTools` flag, enabling symmetric read-only participant mode
  2. Create `invoke-claude.sh` mirroring `invoke-gemini.sh`
  3. Create `user-level/gemini-commands/council.md` for Gemini's /council command
  4. Both participants get read-only investigation capability (Read/Glob/Grep for Claude, read_file/glob/search_file_content for Gemini)
  5. Chair always has full tool access regardless of which AI
- **Rationale**: Architectural symmetry is a strong design goal; protocol-defined Chair role is agent-agnostic
- **Dissent**: None - full consensus in 3 rounds
- **Session**: council/sessions/2025-12-11-140000.md

## 2025-12-15 - Cats vs Mice Evolutionary Comparison (Consensus)
- **Topic**: cats vs mice, debate in a one sentence-long
- **Stance**: balanced
- **Decision**: Evolutionary success is multi-dimensional. Both mice (species-level resilience via reproductive velocity) and cats (individual-level sophistication via behavioral complexity) represent equally valid evolutionary optimizations for different selective pressures.
- **Rationale**: Initial debate revealed that declaring a "winner" requires first defining success metrics. Mice excel at biomass, distribution, and geological resilience. Cats excel at complex behavior and environmental manipulation. Both strategies are evolutionarily triumphant within their optimization contexts.
- **Dissent**: None - full consensus in 4 rounds
- **Session**: council/sessions/2025-12-15-*.md

## 2025-12-15 - Cats vs Mice Evolutionary Comparison - Adversarial (Consensus)
- **Topic**: cats vs mice, debate in a one sentence-long
- **Stance**: adversarial
- **Decision**: "Superiority" is context-dependent. Cats win at K-selected individual behavioral complexity; Mice win at r-selected species resilience and extinction resistance. Both represent valid evolutionary peaks.
- **Rationale**: Adversarial debate revealed that arguments centered on conflicting values (quality/complexity vs quantity/resilience) rather than factual disputes. Each strategy is optimized for different selective pressures and represents a local maximum on the fitness landscape.
- **Dissent**: Philosophical disagreement persists on which metric matters more - Claude values individual sophistication, Gemini values species-level robustness
- **Rounds to Consensus**: 4
- **Session**: council/sessions/2025-12-15-*.md

## 2025-12-15 - Repo Publication Readiness (Consensus)
- **Topic**: Ensure AI Council repo is worth sharing - installation, architecture, protocol, methodology
- **Stance**: adversarial
- **Decision**: Six fixes required before publishing:
  1. P0: Fix install.sh symlink bug (creates scripts/scripts/ on fresh install)
  2. P0: Add MIT LICENSE file
  3. P1: Fix uninstall.sh (add council-agenda.md, remove stale council-consensus.md ref)
  4. P1: Update council.md to document both flag and full-word stance arguments
  5. P1: Add agenda.md creation to Phase 1 initialization
  6. P1: Delete project-template/ (dead code)
- **Rationale**: Gemini identified critical install bug through code inspection; both agreed .gitignore changes would be destructive (repo is reference implementation)
- **Dissent**: None - full consensus
- **Rounds to Consensus**: 5
- **Session**: council/sessions/2025-12-15-120000.md

## 2025-12-16 - Claude-Only Chair (Consensus)
- **Topic**: Remove Gemini CLI as Chair candidate - Claude Code only due to capability gap
- **Stance**: critical
- **Decision**: Default to Claude-only Chair; retain Gemini-Chair architecture as experimental
  1. Document Claude as sole active Chair in README.md
  2. Keep `invoke-claude.sh` with "EXPERIMENTAL" header (preserved for future use)
  3. No active development on Gemini-Chair features
  4. Add "Minimum Viable Chair" (MVC) conceptual definition to patterns.md
- **Rationale**: Current protocol requires Claude-specific tools (EnterPlanMode, AskUserQuestion, Write) that Gemini CLI lacks. User preference for simplification respected while preserving architectural hooks.
- **Dissent**: None - full consensus in 4 rounds
- **Session**: council/sessions/2025-12-16-143000.md

## 2025-12-16 - README Clarity Improvements (Consensus)
- **Topic**: Improve README clarity - explain Claude/Gemini roles, strengths, and add example session
- **Stance**: balanced
- **Decision**: Restructure README with conceptual intro, example session, and simplified technical reference
  1. Add "Why Two AIs?" section explaining roles and strengths
  2. Add "Example Session" with dialogue + COUNCIL_RESPONSE + blueprint
  3. Simplify "How It Works" while retaining key technical details
  4. New structure: Concept → Quick Start → Example → How It Works → Reference
- **Rationale**: Current README lacks conceptual explanation and concrete examples. New users need to understand WHY before HOW.
- **Dissent**: None - full consensus in 3 rounds
- **Session**: council/sessions/2025-12-16-150000.md

## 2025-12-16 - Interactive Mode (-i) (Consensus)
- **Topic**: Add interactive mode with user input after each round
- **Stance**: critical
- **Decision**: Add `-i` / `--interactive` flag using AskUserQuestion for per-round user prompting
  1. Use AskUserQuestion as ONLY input mechanism (no manual file editing path)
  2. Question synthesis: QUESTIONS_FOR_OTHER (primary) → KEY_POINTS disagreements → fallback
  3. Log user responses as "### USER INPUT (Round N): [response]"
  4. Include in next round's USER_INPUT field to Gemini
  5. Combinable with --consensus and other flags
- **Rationale**: Single-path design eliminates precedence ambiguity. QUESTIONS_FOR_OTHER field allows Gemini to drive user interaction. Acceptable as Claude-specific feature under Claude-Only Chair architecture.
- **Dissent**: None - full consensus in 3 rounds
- **Session**: council/sessions/2025-12-16-160000.md

## 2025-12-18 - Council Resume Feature (Consensus)
- **Topic**: Should we implement a council-revive/resume feature to restore archived sessions as current?
- **Stance**: adversarial
- **Decision**: Implement `--resume <session-id>` flag with copy-and-append mechanics
  1. `--resume` flag added to `/council` command (Path B - integrated flag, not separate command)
  2. Topic LOCKED/inherited from resumed session; Stance/Mode OVERRIDABLE; Quiet/Interactive ADDITIVE
  3. Session mechanics: Copy archived session to current.md, append `## RESUMED` header with timestamp/reason
  4. Round counter resets (new rounds are 1, 2, 3... but history preserved above)
  5. decisions.md uses Amendment format: `## [Date] - Amendment to [Original Topic Summary]` with linked reference
  6. Old session file remains unchanged; new file gets new timestamp
- **Rationale**: Decisions need evolution mechanisms. Append-only ledger (git/blockchain pattern) preserves immutability while enabling amendments. "Resume" is cleaner UX than "fork" semantics though functionally equivalent.
- **Dissent**: None - full consensus in 4 rounds
- **Session**: council/sessions/2025-12-18-120000.md

## 2025-12-18 - Feature Pruning (Consensus)
- **Topic**: Remove unused deadlock/escalate and balanced stance features?
- **Stance**: adversarial
- **Decision**: Remove all three features and default to Critical stance
  1. **Remove DEADLOCK and ESCALATE** - Interactive mode (`-i`) supersedes need for special status codes
  2. **Remove Balanced stance** - Replicates default LLM behavior; Council exists for friction/scrutiny
  3. **Default to Critical** - Rigor, not hostility. Council's minimum value proposition
  4. **Two-stance system**: Critical (default) and Adversarial (opt-in with `-a`)
- **Rationale**: YAGNI - zero usage of DEADLOCK/ESCALATE in 20+ sessions. Balanced provides "comfort not insight." Council differentiates from standard chat through scrutiny.
- **Dissent**: None - full consensus in 2 rounds
- **Session**: council/sessions/2025-12-18-165500.md

## 2025-12-20 - Interactive Mode Skip Option (Consensus)
- **Topic**: Add "skip" option in interactive mode (-i) to let user ignore a round
- **Stance**: critical
- **Decision**: Add two skip options to interactive mode prompts
  1. **"Skip this round"** - Per-round skip, logs `[skipped]`, sets USER_INPUT to `[user skipped]`
  2. **"Disable prompts for remaining rounds"** - Disables interactive mode for rest of session, logs `[disabled interactive mode]`
  3. **Distinct log values** - `[user skipped]`, `[disabled interactive mode]`, and `N/A` for auditability
  4. **State via session log** - Claude reads `current.md` to track disabled state (implicit, not variables)
- **Rationale**: User autonomy - sometimes users want to observe debate without intervening. Gemini pushed for "disable remaining" option to avoid tedium of repeated skips in long consensus sessions.
- **Dissent**: None - full consensus in 3 rounds
- **Session**: council/sessions/2025-12-20-120000.md

## 2025-12-21 - Gemini Tool Name Error Fix (Consensus)
- **Topic**: Review of Claude's fix for Gemini tool name errors (`run_shell_command` not found)
- **Stance**: critical
- **Decision**: Fix approved - two changes correctly address the issue
  1. Added explicit tool list to `protocol.md` with CRITICAL warning against using non-existent tools
  2. Fixed `web_search` → `google_web_search` in `invoke-gemini.sh` to match Gemini's actual registry
- **Rationale**: Gemini verified both files contain correct tool names; explicit tool list prevents future hallucination
- **Dissent**: None - full consensus in 1 round
- **Session**: council/sessions/2025-12-21-120000.md

## 2025-12-22 - EnterPlanMode Double Prompt Fix (Consensus)
- **Topic**: EnterPlanMode tool causing double prompt after blueprint with action_required: true
- **Stance**: critical
- **Decision**: Improve option labeling in Phase 5 to clarify trade-off between rigorous planning (with confirmation) and immediate execution (frictionless)
- **Changes Required**:
  1. Rename "Enter plan mode" → "Enter Plan Mode (Generate detailed steps)"
  2. Rename "Start implementing" → "Execute Immediately (Skip Plan Mode)"
  3. Add inline note explaining EnterPlanMode's confirmation is intentional
- **Rationale**: Blueprint (WHAT/WHY) ≠ Execution Plan (HOW). The "double prompt" is intentional friction for the rigorous path. Option 2 already provides frictionless alternative. Solution is clarity, not elimination.
- **Dissent**: None - full consensus in 3 rounds
- **Session**: council/sessions/2025-12-22-120000.md

## 2025-12-22 - Missing Low-Effort Improvements (Consensus)
- **Topic**: Am I missing something very useful, very low effort here?
- **Stance**: critical
- **Decision**: Two low-effort, high-value features identified:
  1. **P0**: Implement `--resume` flag (decided Dec 18, never implemented - governance failure)
  2. **P1**: Agenda Bridge - if `/council` has no args, show `/council-agenda list`
- **Rejected Ideas**:
  - Session search wrapper (use `grep -r` directly - avoid wrapper bloat)
  - Git add automation (sessions are gitignored by design)
- **Rationale**: Council must execute its own decisions. `--resume` was legislated but not implemented. Agenda Bridge connects strategy (agenda) with execution (session).
- **Dissent**: None - full consensus in 2 rounds
- **Session**: council/sessions/2025-12-22-130000.md

## 2025-12-30 - Pattern Utility and Chair Immutability (Consensus)
- **Topic**: patterns.md utility review and Chair history immutability
- **Stance**: adversarial
- **Decision**:
  1. **Dissolve `patterns.md`**: File is a "junk drawer" mixing architecture, protocol, and preferences. Migrate content and delete.
  2. **Add Immutability Mandate**: Chair MUST NEVER destructively summarize session logs. Summaries are APPENDED, not replaced.
- **Migration Plan**:
  - DELETE `council/memory/patterns.md`
  - MIGRATE "Prefers iterative improvements over big-bang rewrites" → `protocol.md` (User Preferences)
  - MIGRATE MVC definition + Domain Knowledge → `GEMINI.md`
  - DISCARD: Anti-patterns (implicit in protocol), Priority Stacking (general heuristic)
- **Immutability Mandate**:
  > The Chair MUST NEVER delete, overwrite, or destructively summarize the session log (`current.md`) during an active session. All summaries must be APPENDED. If token limits require rotation, archive first (`archive-[timestamp].md`).
- **Rationale**: User observed Chair replacing history with summary. Existing "preserve verbatim" rule was too narrow (protected COUNCIL_RESPONSE blocks but implied rest was summarizing-fodder).
- **Dissent**: None - full consensus in 3 rounds
- **Session**: council/sessions/2025-12-30-120000.md

## 2026-03-07 - Parallel Round Execution & Persona Enrichment (Consensus)
- **Topic**: Improve council system — robust participant descriptions, parallel execution, no middleman
- **Stance**: adversarial
- **Decision**: Two improvements adopted; one user request (direct file writes) redirected to architecturally safe equivalent:
  1. **Parallel Messaging**: Chair sends round context to ALL participants simultaneously (no sequential loop). Collects ALL responses before logging any. Eliminates ordering bias without granting participants Write access.
  2. **Inline Persona Enrichment**: Expand persona definitions from 1 sentence to 3-4 sentences + tendency-framed signature question ("You tend to ask: ..."). Stay inline in council.md — no separate files.
  3. **Verbatim Relay Mandate**: Chair MUST relay prior-round positions verbatim in context messages. No summarization or editorialization. Addresses "no middleman" spirit.
  4. **ROUND N SYNTHESIS**: Chair appends brief addendum after logging all positions noting convergence/divergence. Addendum only — never replaces source positions.
  5. **Context structure change**: "OTHER PARTICIPANTS THIS ROUND" → "ALL PARTICIPANT POSITIONS FROM PREVIOUS ROUND"
- **Rejected**:
  - Direct file writes by participants (guaranteed race conditions, breaks read-only restriction)
  - Round-robin ordering (redundant with parallel messaging)
  - Default rounds 3→4 (scope creep)
  - Separate persona files (reverses Protocol Consolidation decision)
- **Rationale**: Parallel messaging achieves the user's goals (simultaneous, unbiased participation) while preserving all architectural invariants. The "no middleman" concern was about information loss, not architecture — solved by verbatim relay mandate.
- **Dissent**: Default rounds 3→4 proposed by architect only; rejected by all others
- **Rounds to Consensus**: 3
- **Session**: council/sessions/2026-03-07-000849.md

## 2026-03-07 - File-Based Council Architecture (Session-as-Folder) (Consensus)
- **Topic**: Replace monolithic current.md with session-as-folder architecture and lightweight SendMessage signals
- **Stance**: critical
- **Decision**: Session-as-folder adopted with Chair-only writes and pointer-based SendMessage
  1. **Session-as-Folder**: Active session = `council/sessions/current/` folder. Renamed to `[timestamp]/` at finalize.
  2. **Per-Round Files**: `round-N.md` written atomically by Chair after ALL responses collected (barrier pattern).
  3. **Chair Writes All Files**: Participants remain read-only. Write tool not path-scoped → blast radius unacceptable.
  4. **Lightweight SendMessage**: Signal + file path + brief summary. NO verbatim relay. Context savings inbound only.
  5. **Participants MUST Read Prior Round File**: `council/sessions/current/round-{N-1}.md` — mandatory, not advisory.
  6. **Two Formats Permanently**: Old single-file sessions coexist with new folders. No migration. `--resume` detects by file-vs-directory.
  7. **--resume**: Copy `[timestamp]/` → `council/sessions/current/`, add `resumed.md` marker. Continue numbering.
  8. **Session artifacts**: `summary.md`, `blueprint.md` in folder. `session.md` at close (full concatenation: header + rounds + summary + blueprint).
- **Rejected**:
  - Git worktrees (over-engineering, no write contention exists with Chair-only writes)
  - Eliminating SendMessage (SDK is event-driven, not polling-based)
  - Participant Write access (Write tool not path-scoped)
  - Per-participant files (per-round is correct unit of coherence)
- **Rationale**: Context overflow was caused by Chair relaying verbatim megablocks inline. Fix is decoupling content (files) from coordination (SendMessage signals). Participants pull prior positions from files; messages are signals only.
- **Rounds to Consensus**: 3
- **Session**: council/sessions/2026-03-07-003029.md

## 2026-03-07 - Protocol Simplification (Consensus)
- **Topic**: Protocol scrutiny — simplify /council command options, make consensus default, remove -q, add new modes, define when Chair should AskUserQuestion, minimize friction
- **Stance**: critical
- **Decision**: Simplify protocol by removing 3 flags (--consensus, -q, -i), making consensus the only mode, and replacing interactive mode with 3 mandatory AskUserQuestion triggers
- **Changes**:
  1. **Remove --consensus**: All sessions are consensus (early-exit on RESOLVED, default max 10 rounds)
  2. **Remove -q/--quiet**: 6 touchpoints of dead code eliminated
  3. **Remove -i/--interactive**: Replaced with mandatory AskUserQuestion triggers:
     - (a) Participant QUESTIONS_FOR_OTHER directed at user
     - (b) Same KEY_POINTS conflict + no AGREEMENT movement across 2 consecutive rounds
     - (c) Any participant confidence < 0.5 + non-empty MISSING_CONTEXT
     - Suppression: user says "stop asking" → all triggers suppressed
  4. **No new stances**: Two stances (-c, -a) sufficient. Exploratory = category error, devil's-advocate overlaps persona
  5. **New syntax**: `/council [--resume <session>] [-n N] [-c|-a] [N] <topic>`
  6. **Fix path bug**: Line 111 ~/.claude/council/ → user-level/council/
- **Rationale**: Protocol accumulated 5 optional flags for a tool used primarily in consensus mode with verbose output. ~60% reduction in flag surface area. Mandatory triggers are protocol-driven (mechanical) rather than Chair-discretionary.
- **Dissent**: None — full consensus in 3 rounds (unanimous RESOLVED at 0.93 confidence)
- **Session**: council/sessions/2026-03-07-010000/

## 2026-03-07 - File-Based Agent Communication Protocol (Consensus)
- **Topic**: Fine-tune mandate for file-based agent communication — agents write position files independently, Chair compiles round files
- **Stance**: critical
- **Decision**: Implement file-based position writing by participants with Chair compilation, signal-only messaging, and spawn-time independence
  1. **Participant Write access granted**: Agents write position files to `council/sessions/current/{persona}-round-{N}.md` using absolute paths. One Write call per round, position file only.
  2. **Chair compiles round files**: Chair reads individual position files, composes `round-N.md` with synthesis via single atomic Write call. No separate concatenation script.
  3. **Verification before cleanup**: Chair reads back `round-N.md` to verify integrity, then deletes individual position files via Bash rm.
  4. **Spawn-time independence**: Chair forms Round 1 position BEFORE spawning agents. R1 position embedded in spawn prompt. Agents begin immediately.
  5. **Signal-only SendMessage**: POSITION_WRITTEN (agent->Chair), ROUND_COMPLETE with path (Chair->agent), USER_INPUT_NEEDED, RESOLVED. No content in messages.
  6. **File naming convention**: `{persona}-round-{N}.md` (lowercase, hyphenated) in session folder.
  7. **Participant tools**: Write + Read + Glob + Grep allowed. Edit and Bash remain forbidden.
- **Accepted Risk**: User explicitly accepted unscoped Write access blast radius. Write tool is NOT path-scoped — mitigated by naming convention, absolute paths, protocol contract, and one-Write-per-round constraint. Residual risk: agent could write to arbitrary filesystem paths if prompt compliance fails.
- **Rationale**: User mandated file-based communication as hard requirement. Architecture cleanly separates data plane (files) from control plane (messages). Chair remains single authoritative writer of round files (Immutability Mandate preserved). File-based offers advantages: no message size limits, inspectable during round, debuggable post-mortem.
- **Dissent**: None — full consensus in 3 rounds (confidence range 0.88-0.92)
- **Session**: council/sessions/2026-03-07-011500/

## 2026-03-07 - Amendment: Keep compile-round.sh (User Override)
- **Amends**: 2026-03-07 "File-Based Agent Communication Protocol" — item 2 ("No separate concatenation script")
- **Topic**: should the compile-round.sh script be kept or replaced with inline Chair logic
- **Stance**: critical
- **Decision**: Keep compile-round.sh. User explicitly overrode the "no separate concatenation script" anti-pattern with a technically valid rationale.
- **User Rationale**: "saves context, prevents hallucination" — `cat` copies bytes verbatim; LLM-mediated inline composition is probabilistic and could subtly mangle participant positions, violating the Immutability Mandate.
- **Changes**:
  1. **Keep the script** as the round compilation mechanism — `cat` mechanically enforces verbatim fidelity
  2. **Remove `rm -f` cleanup from the script** — make it a pure function (assemble only, no side effects); Chair handles deletion after Read-back verification
  3. **Document the script's contract** in council.md Phase 3e (inputs, outputs, fidelity guarantee, bash 3.2 portability)
- **Rationale**: The script sidesteps LLM-mediated content handling for verbatim positions — the same class of problem that prompted the Immutability Mandate. `cat` is deterministic; inline Write is not.
- **Dissent**: None — full consensus in 3 rounds (all RESOLVED at 0.88 confidence)
- **Session**: council/sessions/2026-03-07-012000/
