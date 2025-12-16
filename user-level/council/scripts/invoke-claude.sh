#!/bin/bash
# =============================================================================
# EXPERIMENTAL: This script is not currently functional.
# Preserved for potential future use when Gemini CLI gains required tools.
# The current council protocol requires Claude-specific tools (EnterPlanMode,
# AskUserQuestion) that are not available when Claude acts as participant.
# See: council/memory/decisions.md (2025-12-16 - Claude-Only Chair)
# =============================================================================
#
# invoke-claude.sh - Wrapper for Claude CLI invocation with protocol injection
# Usage: echo "prompt" | ./invoke-claude.sh [stance] [output_file]
#        ./invoke-claude.sh [stance] [output_file] < prompt.txt
#
# Prompt is read from STDIN (not CLI argument) to avoid ARG_MAX limits and
# process table exposure of sensitive session content.
#
# Arguments:
#   stance - Optional: balanced|critical|adversarial (default: balanced)
#   output_file - Optional: File to append output to (in addition to stdout)
#
# Context injection order:
# 1. ~/.claude/council/claude-participant-protocol.md - Universal instructions (always)
# 2. Stance instructions based on criticism level
# 3. $PWD/council/CLAUDE.md - Project context (if exists)
# 4. $PWD/council/memory/decisions.md - Past decisions (if exists)
# 5. $PWD/council/memory/patterns.md - Learned patterns (if exists)
# 6. $PWD/council/sessions/current.md - Session history (if exists and >10 lines)
# 7. User prompt

# Claude CLI path - can be overridden by CLAUDE_CLI env var
# Auto-detect if not set
if [ -z "$CLAUDE_CLI" ]; then
    # Try common locations
    if command -v claude &> /dev/null; then
        CLAUDE_CLI="$(command -v claude)"
    elif [ -f "/usr/local/bin/claude" ]; then
        CLAUDE_CLI="/usr/local/bin/claude"
    elif [ -f "$HOME/.local/bin/claude" ]; then
        CLAUDE_CLI="$HOME/.local/bin/claude"
    else
        echo "[invoke-claude.sh] ERROR: Claude CLI not found. Set CLAUDE_CLI env var or install claude." >&2
        exit 1
    fi
fi

USER_COUNCIL_DIR="$HOME/.claude/council"
PROJECT_COUNCIL_DIR="$PWD/council"
MAX_RETRIES=3
RETRY_DELAY=2

# Read prompt from stdin (avoids ARG_MAX and process table exposure)
PROMPT=$(cat)
STANCE="${1:-balanced}"
OUTPUT_FILE="$2"

# Validate input
if [ -z "$PROMPT" ]; then
    echo "[invoke-claude.sh] ERROR: No prompt received on stdin" >&2
    exit 1
fi

# Define stance instructions
get_stance_instructions() {
    case "$1" in
        balanced)
            echo "STANCE: Balanced
- Fair critique of strengths and weaknesses
- Acknowledge good points explicitly
- Challenge weak arguments respectfully
- Aim for well-rounded evaluation
- Balance support with constructive criticism"
            ;;
        critical)
            echo "STANCE: Critical
- Actively look for flaws and gaps
- Question assumptions and evidence
- Push back on weak justifications
- Demand rigorous reasoning
- Don't accept claims without evidence
- Be thorough in your analysis"
            ;;
        adversarial)
            echo "STANCE: Adversarial (Devil's Advocate)
- Challenge EVERYTHING, even good ideas
- Find counterarguments to every point
- Stress-test ideas to breaking point
- Assume the worst-case scenario
- Your job is to find weaknesses, not agreement
- Only accept ideas that survive intense scrutiny
- Be relentless but professional"
            ;;
        *)
            echo "STANCE: Balanced (default)"
            ;;
    esac
}

# Build context by concatenating files in order
FULL_CONTEXT=""

# 1. Protocol (universal - required)
PROTOCOL_FILE="$USER_COUNCIL_DIR/claude-participant-protocol.md"
if [ -f "$PROTOCOL_FILE" ]; then
    FULL_CONTEXT="=== COUNCIL PROTOCOL ===
$(cat "$PROTOCOL_FILE")"
else
    echo "[invoke-claude.sh] WARNING: Protocol file not found at $PROTOCOL_FILE" >&2
fi

# 2. Stance instructions
STANCE_INSTRUCTIONS=$(get_stance_instructions "$STANCE")
FULL_CONTEXT="$FULL_CONTEXT

=== YOUR STANCE FOR THIS SESSION ===
$STANCE_INSTRUCTIONS"

# 3. Project context (optional)
PROJECT_CONTEXT_FILE="$PROJECT_COUNCIL_DIR/CLAUDE.md"
if [ -f "$PROJECT_CONTEXT_FILE" ]; then
    FULL_CONTEXT="$FULL_CONTEXT

=== PROJECT CONTEXT ===
$(cat "$PROJECT_CONTEXT_FILE")"
fi

# 4. Past decisions (optional, if has content)
DECISIONS_FILE="$PROJECT_COUNCIL_DIR/memory/decisions.md"
if [ -f "$DECISIONS_FILE" ]; then
    DECISIONS=$(cat "$DECISIONS_FILE")
    # Check if there's actual content (not just template)
    if echo "$DECISIONS" | grep -q "^## [0-9]"; then
        FULL_CONTEXT="$FULL_CONTEXT

=== PAST COUNCIL DECISIONS ===
$DECISIONS"
    fi
fi

# 5. Learned patterns (optional, if has content)
PATTERNS_FILE="$PROJECT_COUNCIL_DIR/memory/patterns.md"
if [ -f "$PATTERNS_FILE" ]; then
    PATTERNS=$(cat "$PATTERNS_FILE")
    # Check if there's actual content in any section
    if echo "$PATTERNS" | grep -qE "^- .+"; then
        FULL_CONTEXT="$FULL_CONTEXT

=== LEARNED PATTERNS ===
$PATTERNS"
    fi
fi

# 6. Session history (from current.md - for context continuity)
SESSION_FILE="$PROJECT_COUNCIL_DIR/sessions/current.md"
if [ -f "$SESSION_FILE" ]; then
    SESSION_CONTENT=$(cat "$SESSION_FILE")
    # Only inject if there's meaningful content (more than just header)
    LINE_COUNT=$(echo "$SESSION_CONTENT" | wc -l)
    if [ "$LINE_COUNT" -gt 10 ]; then
        FULL_CONTEXT="$FULL_CONTEXT

=== SESSION HISTORY ===
$SESSION_CONTENT"
    fi
fi

# Build full prompt
if [ -n "$FULL_CONTEXT" ]; then
    FULL_PROMPT="$FULL_CONTEXT

---

$PROMPT"
else
    FULL_PROMPT="$PROMPT"
fi

# Invoke Claude with retry logic
# Use --allowedTools whitelist for read-only access (Council = Senate, not Executor)
# Claude can read/search but NOT modify files or run shell commands
ALLOWED_TOOLS="Read,Glob,Grep"
attempt=1
while [ $attempt -le $MAX_RETRIES ]; do
    # Run Claude with read-only tool whitelist, stdin for prompt (avoids ARG_MAX + process table exposure)
    OUTPUT=$(echo "$FULL_PROMPT" | $CLAUDE_CLI --print --allowedTools "$ALLOWED_TOOLS" 2>&1)
    EXIT_CODE=$?

    if [ $EXIT_CODE -eq 0 ] && [ -n "$OUTPUT" ]; then
        # Success - output the result (preserve blank lines for Markdown formatting)
        echo "$OUTPUT"
        # Also write to output file if specified (with CLAUDE: header)
        if [ -n "$OUTPUT_FILE" ]; then
            echo "
### CLAUDE'S POSITION
$OUTPUT
" >> "$OUTPUT_FILE"
        fi
        exit 0
    fi

    # Log failure
    echo "[invoke-claude.sh] Attempt $attempt/$MAX_RETRIES failed (exit code: $EXIT_CODE)" >&2

    if [ $attempt -lt $MAX_RETRIES ]; then
        echo "[invoke-claude.sh] Retrying in ${RETRY_DELAY}s..." >&2
        sleep $RETRY_DELAY
    fi

    attempt=$((attempt + 1))
done

# All retries exhausted
echo "[invoke-claude.sh] ERROR: All $MAX_RETRIES attempts failed" >&2
exit 1
