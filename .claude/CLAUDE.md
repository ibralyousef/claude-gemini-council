# AI Council Project

Collaborative planning between Claude Code and Gemini CLI.

## Commands
- `/council <topic>` - Standard session (3 rounds)
- `/council --consensus <topic>` - Loop until consensus
- `/council -a 5 <topic>` - Adversarial, 5 rounds
- `/council-agenda list` - View strategic agenda

## Stances
`-c` critical (default) | `-a` adversarial

## Project Structure
- `user-level/commands/` - Slash command definitions (symlinked to ~/.claude/commands/)
- `council/sessions/` - Session logs
- `council/memory/` - decisions.md, patterns.md, agenda.md
