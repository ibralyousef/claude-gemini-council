# Project Context

## Overview
AI Council project - a collaborative planning system between Claude Code and Gemini CLI. This is the reference implementation for testing and developing the council system.

## Current Focus
Making the council commands globally available (user-level) while keeping memory/context per-project.

## Key Architecture
- Commands are now at user-level (`~/.claude/commands/`)
- Protocol instructions are at user-level (`~/.claude/council/protocol.md`)
- Memory and sessions are per-project (`./council/memory/`, `./council/sessions/`)
- `invoke-gemini.sh` injects protocol + project context + memory into Gemini prompts

## Domain Knowledge
- Claude serves as "Chair" (orchestrator) in council sessions
- Gemini serves as "Participant + Investigator" (equal voice, plus tool access)
- Memory files (decisions.md) are injected via invoke-gemini.sh
- Session logs are maintained at council/sessions/current.md during active sessions

## Minimum Viable Chair (MVC) - Architectural Reference
Core Chair responsibilities that any AI must be able to perform:
1. **Moderate**: Control turn-taking, enforce round limits, announce session state
2. **Log**: Write session progress to `council/sessions/current.md`
3. **Handle User Input**: Use interactive mode (`-i`) for user input during sessions
4. **Invoke**: Call the participant AI with proper context injection
5. **Summarize**: Generate COUNCIL_SUMMARY at session end
6. **Persist**: Append to decisions.md, rename session file

Current Claude-specific extensions (not required for MVC):
- `EnterPlanMode`: Transition to implementation planning
- `AskUserQuestion`: Structured user prompts with options
- `TodoWrite`: Task tracking during implementation

This distinction exists to enable future Gemini-as-Chair capability when its toolset expands.
