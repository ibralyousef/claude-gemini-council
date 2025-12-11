# COUNCIL_BLUEPRINT
## Session: 2025-12-11-140000 | Topic: Bidirectional Council Chairing | Status: RESOLVED
## Decision: Implement Bidirectional Council Chairing via Symmetric Architecture
## Action Required: true

> **CHAIR INSTRUCTION**: If Action Required is true, you MUST invoke `EnterPlanMode` tool now. Do NOT implement directly.

## Architecture

| Component | Description |
|-----------|-------------|
| invoke-claude.sh | Mirror of invoke-gemini.sh using `claude --print --allowedTools "Read,Glob,Grep"` |
| Symmetric Security | Participant = read-only tools, Chair = full tool access |
| Config Storage | Claude: `user-level/commands/`, Gemini: `user-level/gemini-commands/` |

### Tool Access Matrix
| Role | Chair | Participant |
|------|-------|-------------|
| Claude | Full access | Read, Glob, Grep |
| Gemini | Full access | read_file, glob, search_file_content |

## Scope
- `user-level/council/scripts/invoke-claude.sh` - New script for invoking Claude as participant
- `user-level/gemini-commands/council.md` - Gemini's /council command definition
- `install.sh` - Add Gemini command installation logic

## Constraints
- `invoke-claude.sh` MUST use `claude --print --allowedTools "Read,Glob,Grep"` for read-only participant mode
- `invoke-claude.sh` MUST inject memory files (decisions.md, patterns.md) and session context (current.md)
- Session files remain in `council/sessions/` regardless of which AI chairs
- Session header should indicate `Chair: Claude|Gemini` for auditability

## Success Criteria
- [ ] `invoke-claude.sh` returns structured COUNCIL_RESPONSE when called from shell
- [ ] Claude as participant cannot use write tools (verified via allowedTools restriction)
- [ ] Gemini-chaired sessions log to same `council/sessions/` directory
- [ ] Session files include Chair identification metadata
- [ ] `install.sh` successfully installs Gemini commands when Gemini CLI is detected
