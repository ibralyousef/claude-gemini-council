# AI Council Project

This project enables collaborative planning between Claude Code and Gemini CLI.

## Project Structure
- `.claude/commands/` - Slash commands for council invocation
- `council/sessions/` - Saved session summaries
- `council/memory/` - Persistent memory across sessions
- `council/scripts/` - Helper scripts
- `GEMINI.md` - Shared context provided to Gemini

## Memory Imports
@council/memory/decisions.md
@council/memory/patterns.md

## Council Commands
- `/council [rounds] <topic>` - Start council with N rounds (default 3)
- `/council-consensus <topic>` - Continue until consensus (max 10 rounds)

## Gemini CLI
Path: /Users/fermious/.nvm/versions/node/v22.17.1/bin/gemini
Invoke with: gemini -o text "prompt"

## Session Management
After each council session:
1. Save summary to `council/sessions/YYYY-MM-DD-HHMMSS.md`
2. Log key decisions to `council/memory/decisions.md`
3. Update patterns in `council/memory/patterns.md` if applicable
