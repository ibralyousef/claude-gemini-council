# AI Council Project

Collaborative planning using Claude Code agent teams.

## Commands
- `/council <topic>` - Standard session (3 rounds, 2 participants)
- `/council --consensus <topic>` - Loop until consensus
- `/council -a 5 <topic>` - Adversarial, 5 rounds
- `/council -n 3 <topic>` - 3 participants
- `/council -n 4 -a --consensus <topic>` - 4 adversarial participants, consensus
- `/council-agenda list` - View strategic agenda

## Stances
`-c` critical (default) | `-a` adversarial

## Agents Flag
`-n N` (1-5 participants, default 2). Each gets a distinct persona.

## Project Structure
- `user-level/commands/` - Slash command definitions (symlinked to ~/.claude/commands/)
- `user-level/council/` - Participant protocol
- `council/sessions/` - Session logs
- `council/memory/` - decisions.md, agenda.md
