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
