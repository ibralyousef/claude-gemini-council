# AI Council

A collaborative planning system between Claude Code and Gemini CLI. Run `/council` from any project to start a multi-round discussion between two AI perspectives.

> **Meta note:** This project was built using itself. The council command was used to debate and refine its own architecture, protocols, and features. It's councils all the way down.

## Why Two AIs?

Better decisions come from diverse perspectives. AI Council leverages two different AI models in a structured debate:

**Claude Code (Chair)**
- Orchestrates the session and maintains the log
- Has full tool access: file editing, plan mode, user questions
- Executes decisions after council approval
- Strengths: Deep integration, implementation capability, structured workflows

**Gemini (Participant)**
- Provides independent perspective on the same problem
- Can read files and verify claims about the codebase
- Challenges assumptions with a different training background
- Strengths: Alternative viewpoint, claim verification, stress-testing ideas

**The Model**: The council deliberates on WHAT to do and WHY. Then the Chair (Claude) implements HOW. Like a senate passing bills that an executive implements.

## Installation

### Prerequisites
- [Claude Code](https://claude.ai/code) CLI installed
- [Gemini CLI](https://github.com/google-gemini/gemini-cli) installed and authenticated

### Install

```bash
git clone https://github.com/ibralyousef/claude-gemini-council.git
cd claude-gemini-council
./install.sh
```

The install script will:
1. Create symlinks for commands in `~/.claude/commands/`
2. Create symlinks for protocol and scripts in `~/.claude/council/`
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
/council --consensus Database migration strategy

# Interactive mode (user input after each round)
/council -i critical API design discussion
```

> **Note**: Run `/council` from your project's root directory. Council files are created in Claude's current working directory.

## Example Session

Here's a condensed council session on "Should we add Redis for caching?"

**Round 1 - Claude** (Confidence: 0.7):
> "Redis offers sub-millisecond reads and built-in expiration. But it adds operational complexity - another service to monitor, deploy, and secure. For a single-server app, in-memory caching might suffice."

**Round 1 - Gemini**:
> "I've checked your codebase - you're already using `node-cache` in 3 places (`api/cache.js`, `services/auth.js`, `utils/config.js`). Adding Redis would fragment your caching strategy. However, if you need cross-instance sharing for horizontal scaling, Redis becomes necessary. What's your scaling timeline?"

```
---COUNCIL_RESPONSE---
STATUS: CONTINUE
AGREEMENT: partial
CONFIDENCE: 0.85
KEY_POINTS:
- Existing node-cache usage creates fragmentation risk
- Redis only justified if horizontal scaling planned
QUESTIONS_FOR_OTHER:
- What is the scaling timeline?
---END_COUNCIL_RESPONSE---
```

**Round 2 - Claude** (Confidence: 0.85):
> "Good catch on the existing caching. Let's consolidate: If scaling within 6 months, migrate to Redis now. If not, standardize on node-cache first, then migrate later. This avoids premature optimization while keeping the path clear."

**Round 2 - Gemini**:
> "Agreed. Standardize first, scale later. The consolidation itself has value regardless of Redis."

```
---COUNCIL_RESPONSE---
STATUS: RESOLVED
AGREEMENT: full
CONFIDENCE: 0.95
KEY_POINTS:
- Consolidate existing caching before adding new infrastructure
- Redis decision deferred until scaling timeline is clear
ACTION_ITEMS:
- [ ] Audit all caching usage and standardize on node-cache
- [ ] Document scaling triggers that would justify Redis
---END_COUNCIL_RESPONSE---
```

**Resulting Blueprint**:
```markdown
# COUNCIL_BLUEPRINT
## Decision: Consolidate caching before considering Redis
## Action Required: true

## Scope:
- `api/cache.js`, `services/auth.js`, `utils/config.js`

## Success Criteria:
- [ ] Single caching abstraction used throughout codebase
- [ ] Scaling triggers documented
```

## Stance Levels

Control how critically Gemini challenges Claude's positions:

| Level | Behavior |
|-------|----------|
| `balanced` | Fair critique, acknowledge good and bad (default) |
| `critical` | Find flaws, question assumptions, demand evidence |
| `adversarial` | Devil's advocate, stress-test everything, relentless scrutiny |

## Commands

### `/council [level] [rounds] <topic>`

Standard council session with fixed number of rounds, or consensus mode.

**Arguments:**
- `-q` / `--quiet` (optional): suppress verbose output
- `-i` / `--interactive` (optional): prompt user for input after each round
- `--consensus` (optional): continues until consensus is reached (max 10 rounds)
- `level` (optional): balanced, critical, or adversarial
- `rounds` (optional): number of discussion rounds (default: 3)
- `topic` (required): what to discuss

**Examples:**
```bash
/council adversarial 5 Should we rewrite in Rust?
/council critical How to handle rate limiting?
/council 3 API design review
/council Should we use Redis?
/council --consensus Database migration strategy
/council -i -c 3 Feature prioritization  # interactive mode
```

## File Structure

### User-level (global) - `~/.claude/`

```
~/.claude/
├── commands/
│   ├── council.md              # Main council command (symlinked)
│   └── council-agenda.md       # Agenda command (symlinked)
└── council/
    ├── protocol.md             # Gemini participant protocol (symlinked)
    ├── claude-participant-protocol.md  # Claude participant protocol (symlinked)
    └── scripts/                # Scripts (symlinked directory)
        ├── invoke-gemini.sh    # Invoke Gemini as participant
        └── invoke-claude.sh    # Invoke Claude as participant
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

```
User runs /council → Claude (Chair) states position → Gemini responds with critique
    ↓                                                           ↓
Rounds repeat until RESOLVED or max rounds reached
    ↓
Summary generated → Blueprint created (if actionable) → Chair implements
```

**Key concepts:**

1. **Protocol Injection**: Each invocation automatically injects context (protocol, project info, memory files) so Gemini has full awareness

2. **Structured Responses**: Gemini returns `COUNCIL_RESPONSE` blocks with STATUS, AGREEMENT, KEY_POINTS, etc. (see example above)

3. **Session Management**: Active session stored in `council/sessions/current.md`, then archived with timestamp

4. **Tool Restrictions**: Chair (Claude) has full tool access; participant (Gemini) has read-only access to verify claims

**STATUS values in COUNCIL_RESPONSE:**
- `CONTINUE` - Discussion should continue
- `RESOLVED` - Consensus reached, session can end
- `DEADLOCK` - Fundamental disagreement (2 consecutive = escalate to user)
- `ESCALATE` - Pause and request user input

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
2. **Use `balanced` for brainstorming** - Fair critique while building on ideas
3. **Use `-i` for complex topics** - Interactive mode lets you steer the discussion after each round
4. **Check session logs** - Full transcripts saved in `./council/sessions/`
5. **Edit GEMINI.md** - Better project context = better Gemini responses
6. **Gemini can read files** - Ask it to verify claims about your codebase

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
