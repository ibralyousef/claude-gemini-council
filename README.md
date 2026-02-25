# AI Council

A collaborative planning system using Claude Code agent teams. Run `/council` from any project to start a multi-round discussion between multiple AI perspectives.

> **Meta note:** This project was built using itself. The council command was used to debate and refine its own architecture, protocols, and features. It's councils all the way down.

## Why Multiple Agents?

Better decisions come from diverse perspectives. AI Council spawns multiple Claude Code agents, each with a distinct persona, to debate a topic in structured rounds.

**Chair (Claude Code)**
- Orchestrates the session and maintains the log
- Has full tool access: file editing, plan mode, user questions
- Executes decisions after council approval

**Participants (1-5 agents)**
- Each gets a distinct persona (pragmatist, skeptic, architect, etc.)
- Read-only tool access to verify claims about the codebase
- Provide independent perspectives on the same problem

**The Model**: The council deliberates on WHAT to do and WHY. Then the Chair implements HOW. Like a senate passing bills that an executive implements.

## Installation

### Prerequisites
- [Claude Code](https://claude.ai/code) CLI installed

### Install

```bash
git clone https://github.com/ibralyousef/aicouncil.git
cd aicouncil
./install.sh
```

The install script will:
1. Create symlinks for commands in `~/.claude/commands/`
2. Create symlinks for participant protocol in `~/.claude/council/`

### Uninstall

```bash
./uninstall.sh
```

## Quick Start

```bash
# Basic usage (critical stance, 3 rounds, 2 participants)
/council Should we use Redis or Postgres?

# 3 adversarial participants
/council -n 3 -a Database migration strategy

# Single participant for quick questions
/council -n 1 Quick question about caching

# Consensus mode with 4 participants
/council --consensus -n 4 Auth architecture

# Interactive mode (user input after each round)
/council -i critical API design discussion
```

> **Note**: Run `/council` from your project's root directory. Council files are created in Claude's current working directory.

## Persona System

Each participant receives a distinct persona based on the number of agents:

| Agents | Personas |
|--------|----------|
| 1 | generalist |
| 2 | pragmatist, skeptic |
| 3 | pragmatist, skeptic, architect |
| 4 | pragmatist, skeptic, architect, user-advocate |
| 5 | pragmatist, skeptic, architect, user-advocate, devil's-advocate |

## Stance Levels

Control how critically participants challenge positions:

| Level | Behavior |
|-------|----------|
| `critical` | Find flaws, question assumptions, demand evidence (default) |
| `adversarial` | Devil's advocate, stress-test everything, relentless scrutiny |

## Commands

### `/council [options] <topic>`

Standard council session with fixed number of rounds, or consensus mode.

**Arguments:**
- `-n N` (optional): number of participants, 1-5 (default: 2)
- `-c` / `-a` (optional): stance level -- critical or adversarial (default: critical)
- `-q` / `--quiet` (optional): suppress verbose output
- `-i` / `--interactive` (optional): prompt user for input after each round
- `--consensus` (optional): continues until consensus is reached (max 10 rounds)
- `rounds` (optional): number of discussion rounds (default: 3)
- `topic` (required): what to discuss

**Examples:**
```bash
/council -a 5 Should we rewrite in Rust?
/council -n 3 How to handle rate limiting?
/council 3 API design review
/council Should we use Redis?
/council --consensus -n 4 Database migration strategy
/council -i -c 3 Feature prioritization
```

## File Structure

### User-level (global) - `~/.claude/`

```
~/.claude/
├── commands/
│   ├── council.md              # Main council command (symlinked)
│   └── council-agenda.md       # Agenda command (symlinked)
└── council/
    └── participant-protocol.md # Participant protocol (symlinked)
```

### Project-level (per-project) - `./council/`

Created automatically on first run in any project:

```
<project>/council/
├── memory/
│   ├── decisions.md     # Past council decisions
│   └── agenda.md        # Strategic agenda
└── sessions/
    ├── current.md       # Active session log
    └── *.md             # Archived sessions
```

## How It Works

```
User runs /council
    ↓
Chair parses flags, reads memory
    ↓
TeamCreate → spawn N participants (each with persona + protocol)
    ↓
Rounds: Chair states position → SendMessage to each participant → collect responses
    ↓
Repeat until RESOLVED or max rounds reached
    ↓
Summary generated → Blueprint created (if actionable) → Chair implements
```

**Key concepts:**

1. **Agent Teams**: The Chair uses `TeamCreate` and `SendMessage` to orchestrate participants as sub-agents, each running in its own context

2. **Structured Responses**: Participants return `COUNCIL_RESPONSE` blocks with STATUS, AGREEMENT, KEY_POINTS, etc.

3. **Session Management**: Active session stored in `council/sessions/current.md`, then archived with timestamp

4. **Tool Restrictions**: Chair has full tool access; participants have read-only access to verify claims

**STATUS values in COUNCIL_RESPONSE:**
- `CONTINUE` - Discussion should continue
- `RESOLVED` - Consensus reached, session can end

## Memory System

### decisions.md
Past council decisions are automatically logged:
```markdown
## 2025-12-10 - Authentication Strategy
- **Topic**: How to handle user authentication
- **Stance**: critical
- **Decision**: Use JWT with refresh tokens
- **Rationale**: Stateless, scalable, industry standard
- **Dissent**: Participant 2 (skeptic) preferred session-based for revocation
```

## Tips

1. **Use `-n 3` or higher for important decisions** - More perspectives catch more blind spots
2. **Default `-n 2` works for most discussions** - Two agents cover the common case well
3. **Use `-n 1` for quick sanity checks** - Fast feedback without full debate overhead
4. **Use `adversarial` for critical decisions** - Stress-test ideas before committing
5. **Use default `critical` for most discussions** - Rigorous analysis without being hostile
6. **Use `-i` for complex topics** - Interactive mode lets you steer the discussion after each round
7. **Check session logs** - Full transcripts saved in `./council/sessions/`

## Troubleshooting

### "Protocol file not found"
Ensure `~/.claude/council/participant-protocol.md` exists. Re-run `./install.sh` if needed.

### Sessions not saving
Ensure `./council/sessions/` directory exists and is writable.
