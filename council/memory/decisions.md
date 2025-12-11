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
