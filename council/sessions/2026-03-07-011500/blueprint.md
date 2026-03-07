# COUNCIL_BLUEPRINT
## Session: 2026-03-07-011500 | Topic: File-based agent communication protocol | Status: RESOLVED
## Decision: Implement file-based position writing by participants with Chair compilation, signal-only messaging, and spawn-time independence
## Action Required: true

> **CHAIR INSTRUCTION**: If Action Required is true, present user with implementation options (plan mode / implement directly / let user write).

## Architecture

| Component | Decision |
|-----------|----------|
| Data plane | Files (`{persona}-round-{N}.md` in session folder) |
| Control plane | SendMessage (signal-only: POSITION_WRITTEN, ROUND_COMPLETE, USER_INPUT_NEEDED, RESOLVED) |
| Round compilation | Chair Read + atomic Write (no separate script) |
| Cleanup | Chair verifies round file via Read-back, then deletes individual files via Bash rm |
| Spawn model | Chair forms R1 position BEFORE spawning; agents begin immediately |
| Write scoping | Convention-based (protocol contract), not tool-enforced |
| Path format | Absolute paths in all signals and protocol instructions |

**Patterns:**
- Files for data, messages for signals — never mix content into messages
- Chair is single authoritative writer of round files (Immutability Mandate preserved)
- One Write call per participant per round (position file only)
- Barrier pattern: Chair waits for all POSITION_WRITTEN pings before compiling

**Anti-patterns:**
- No separate concatenation scripts
- No content in SendMessage payloads
- No relative paths
- No Edit/Bash for participants
- No multi-file writes per round by participants

## Scope

**Files to modify:**
1. `user-level/council/participant-protocol.md`
   - Add Write to allowed tools list
   - Remove Write from "may NOT use" line
   - Add "File Writing Contract" section with absolute path template
   - State: one Write per round, position file only
2. `user-level/commands/council.md`
   - Reorder Phase 3a before agent spawning (Chair forms R1 position first)
   - Update Phase 3d: wait for POSITION_WRITTEN pings instead of content messages
   - Update Phase 3f: Read individual `{persona}-round-{N}.md` files, compose round file, Write atomically
   - Add verification step: Read-back round-N.md before cleanup
   - Add cleanup step: Bash rm of individual position files
   - Add signal vocabulary documentation
   - Update spawn prompt template to include R1 position and File Writing Contract
3. `council/memory/decisions.md`
   - Log session decision with accepted risk documentation

## Constraints
- Write tool is NOT path-scoped — blast radius accepted by user, mitigated by convention
- Edit and Bash remain forbidden for participants
- Round files are immutable after write (existing Immutability Mandate)
- Signal messages must include round number to prevent agent confusion
- Absolute paths required to avoid cwd ambiguity across agent contexts

## Success Criteria
- [ ] participant-protocol.md includes Write in allowed tools and File Writing Contract section
- [ ] council.md Phase 3 reordered: Chair R1 position before spawning
- [ ] council.md Phase 3d-f updated for file-read flow with signal vocabulary
- [ ] council.md includes verification-before-cleanup step
- [ ] Spawn prompt template includes R1 position and file writing instructions
- [ ] decisions.md entry includes accepted risk documentation with mitigation list
- [ ] No new scripts or files created (edits only)
