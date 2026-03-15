# AI Council Project

Collaborative planning using Claude Code agent teams.

## Commands
- `/council <topic>` - Consensus session (max 10 rounds, 2 participants)
- `/council -a 5 <topic>` - Adversarial, max 5 rounds
- `/council -n 3 <topic>` - 3 participants
- `/council -n 4 -a <topic>` - 4 adversarial participants
- `/council -i <topic>` - Interactive mode (user input after each round)
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
