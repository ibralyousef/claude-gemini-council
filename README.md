# AI Council

A collaborative planning system between Claude Code and Gemini CLI. Run `/council` from any project to start a multi-round discussion between two AI perspectives.

## Installation

### Prerequisites
- [Claude Code](https://claude.ai/code) CLI installed
- [Gemini CLI](https://github.com/google-gemini/gemini-cli) installed and authenticated

### Install

```bash
git clone https://github.com/user/aicouncil.git
cd aicouncil
./install.sh
```

The install script will:
1. Copy commands to `~/.claude/commands/`
2. Copy protocol and scripts to `~/.claude/council/`
3. Auto-detect your Gemini CLI path (or prompt for it)

### Uninstall

```bash
./uninstall.sh
```

## Quick Start

```bash
# Basic usage (balanced stance, 3 rounds)
/council Should we use Redis or Postgres?

# With stance level
/council critical How should we handle authentication?

# With stance and rounds
/council adversarial 5 Should we rewrite the backend in Rust?

# Consensus mode (continues until agreement, max 10 rounds)
/council-consensus Database migration strategy
```

## Stance Levels

Control how critically Gemini challenges Claude's positions:

| Level | Behavior |
|-------|----------|
| `cooperative` | Build on ideas, seek synthesis, gentle challenges |
| `balanced` | Fair critique, acknowledge good and bad (default) |
| `critical` | Find flaws, question assumptions, demand evidence |
| `adversarial` | Devil's advocate, stress-test everything, relentless scrutiny |

## Commands

### `/council [level] [rounds] <topic>`

Standard council session with fixed number of rounds.

**Arguments:**
- `level` (optional): cooperative, balanced, critical, or adversarial
- `rounds` (optional): number of discussion rounds (default: 3)
- `topic` (required): what to discuss

**Examples:**
```bash
/council adversarial 5 Should we rewrite in Rust?
/council critical How to handle rate limiting?
/council 3 API design review
/council Should we use Redis?
```

### `/council-consensus [level] <topic>`

Continues until consensus is reached (max 10 rounds).

**Arguments:**
- `level` (optional): stance level
- `topic` (required): what to reach consensus on

**Examples:**
```bash
/council-consensus adversarial Microservices vs monolith?
/council-consensus critical Authentication architecture
/council-consensus Database migration strategy
```

## File Structure

### User-level (global) - `~/.claude/`

```
~/.claude/
├── commands/
│   ├── council.md              # Main council command
│   └── council-consensus.md    # Consensus mode command
└── council/
    ├── protocol.md             # Universal Gemini instructions
    └── scripts/
        ├── invoke-gemini.sh    # Gemini wrapper with protocol injection
        └── council-terminal.sh # Interactive terminal UI
```

### Project-level (per-project) - `./council/`

Created automatically on first run in any project:

```
<your-project>/council/
├── GEMINI.md            # Project-specific context for Gemini
├── memory/
│   ├── decisions.md     # Past council decisions
│   └── patterns.md      # Learned patterns
└── sessions/
    ├── current.md       # Active session log
    └── *.md             # Archived sessions
```

## How It Works

1. **Claude as Chair**: Claude orchestrates the discussion and maintains the session log
2. **Gemini as Participant + Investigator**: Gemini responds according to assigned stance, can use tools to verify claims
3. **Protocol Injection**: `invoke-gemini.sh` injects:
   - Universal protocol (`~/.claude/council/protocol.md`)
   - Stance instructions
   - Project context (`./council/GEMINI.md`)
   - Memory files (`./council/memory/*.md`)
4. **Structured Responses**: Gemini returns COUNCIL_RESPONSE blocks for automated processing

## COUNCIL_RESPONSE Format

Gemini ends each response with:

```
---COUNCIL_RESPONSE---
STATUS: CONTINUE | RESOLVED | DEADLOCK | ESCALATE
AGREEMENT: none | partial | full
CONFIDENCE: [0.0-1.0]
MISSING_CONTEXT: [list]
KEY_POINTS:
- [points]
ACTION_ITEMS:
- [ ] [actions]
QUESTIONS_FOR_OTHER:
- [questions]
---END_COUNCIL_RESPONSE---
```

**STATUS values:**
- `CONTINUE` - Discussion should continue
- `RESOLVED` - Consensus reached, session can end
- `DEADLOCK` - Fundamental disagreement (2 consecutive = escalate to user)
- `ESCALATE` - Pause and request user input

## Escalation

When Gemini sets `STATUS: ESCALATE` or 2 consecutive `DEADLOCK`s occur:
1. Session pauses
2. User is prompted for input
3. Both AIs read user response and continue

## Project Context

Edit `./council/GEMINI.md` to give Gemini project-specific context:

```markdown
# Project Context

## Overview
Brief description of this project

## Current Focus
What you're working on

## Key Architecture
Important technical details
```

## Memory System

### decisions.md
Past council decisions are automatically logged:
```markdown
## 2025-12-10 - Authentication Strategy
- **Topic**: How to handle user authentication
- **Stance**: critical
- **Decision**: Use JWT with refresh tokens
- **Rationale**: Stateless, scalable, industry standard
- **Dissent**: Gemini preferred session-based for revocation
```

### patterns.md
Track what works and what doesn't:
```markdown
## Successful Approaches
- Tool-first verification for architecture discussions

## Anti-Patterns
- Accepting claims without code evidence
```

## Configuration

### Gemini CLI Path
If your Gemini CLI is in a different location, update `~/.claude/council/scripts/invoke-gemini.sh`:
```bash
GEMINI_CLI="/path/to/your/gemini"
```

### Retry Settings
In `invoke-gemini.sh`:
```bash
MAX_RETRIES=3
RETRY_DELAY=2
```

## Tips

1. **Use `adversarial` for important decisions** - Stress-test ideas before committing
2. **Use `cooperative` for brainstorming** - Build on ideas without heavy critique
3. **Check session logs** - Full transcripts saved in `./council/sessions/`
4. **Edit GEMINI.md** - Better project context = better Gemini responses
5. **Gemini can read files** - Ask it to verify claims about your codebase

## Troubleshooting

### "Protocol file not found"
Ensure `~/.claude/council/protocol.md` exists. Re-run setup if needed.

### Gemini not responding
Check Gemini CLI is installed and authenticated:
```bash
gemini --version
gemini "test"
```

### Sessions not saving
Ensure `./council/sessions/` directory exists and is writable.
