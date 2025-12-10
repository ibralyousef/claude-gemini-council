# COUNCIL_BLUEPRINT

## Session
- **ID**: 2025-12-11-160000
- **Topic**: Council protocol updates for plan-oriented output
- **Status**: RESOLVED (Full Consensus)

## Decision Summary
The AI Council protocol must be updated to output structured implementation blueprints and automatically transition to planning mode when action is required.

## Rationale
The current council produces "summaries" (press releases) instead of actionable specifications (Bills). Users need technical implementation plans, not just decision documentation.

## Action Required
**true**

## Architecture

### Decisions
| Key | Choice | Rationale |
|-----|--------|-----------|
| output_format | COUNCIL_BLUEPRINT (structured) | Enables automated handoff to plan mode |
| persistence | council/blueprint.md | Physical file prevents context loss |
| handoff_mechanism | EnterPlanMode (built-in tool) | Native Claude Code capability, no custom command needed |

### Patterns
- Blueprint-driven planning: Council defines WHAT/WHY, Agent defines HOW
- Persistent artifacts: Critical outputs written to files, not just context
- Explicit handoffs: Chair explicitly invokes plan mode, no implicit triggers

### Anti-Patterns
- "Press release" summaries without actionable structure
- Context-dependent handoffs (fragile, can be lost)
- Automatic triggers without user visibility

## Scope

### Components Affected
- `~/.claude/commands/council.md` - User-level council command
- `council/blueprint.md` - New artifact file (template)
- `council/sessions/` - Session logs (format update)

### Files to Modify
- `~/.claude/commands/council.md` - Add blueprint generation and plan mode steps

## Constraints
- Blueprint schema must be Markdown (LLM-readable, human-readable)
- Chair must explicitly invoke EnterPlanMode (no automatic hidden triggers)
- User review step must occur before plan mode (existing AskUserQuestion step)

## Prerequisites
- [ ] Read current council.md to understand existing structure
- [ ] Verify EnterPlanMode tool is available (confirmed)

## Success Criteria
- [ ] Council sessions produce `council/blueprint.md` with structured content
- [ ] After user approves summary, EnterPlanMode is invoked with blueprint context
- [ ] Blueprint schema is documented in council.md
- [ ] Existing council functionality (rounds, Gemini invocation, memory) preserved

## Dissent
None - full consensus reached between Claude and Gemini in 5 rounds.
