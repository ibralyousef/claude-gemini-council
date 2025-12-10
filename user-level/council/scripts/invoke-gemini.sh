#!/bin/bash
# invoke-gemini.sh - Wrapper for Gemini CLI invocation with protocol injection
# Usage: ./invoke-gemini.sh "prompt" [stance]
#
# Arguments:
#   prompt - The prompt to send to Gemini
#   stance - Optional: cooperative|balanced|critical|adversarial (default: balanced)
#
# Context injection order:
# 1. ~/.claude/council/protocol.md - Universal instructions (always)
# 2. Stance instructions based on criticism level
# 3. $PWD/council/GEMINI.md - Project context (if exists)
# 4. $PWD/council/memory/decisions.md - Past decisions (if exists)
# 5. $PWD/council/memory/patterns.md - Learned patterns (if exists)
# 6. User prompt

# Gemini CLI path - can be overridden by GEMINI_CLI env var or install script
# Auto-detect if not set
if [ -z "$GEMINI_CLI" ]; then
    # Try common locations
    if command -v gemini &> /dev/null; then
        GEMINI_CLI="$(command -v gemini)"
    elif [ -f "$HOME/.nvm/versions/node/$(node -v 2>/dev/null)/bin/gemini" ]; then
        GEMINI_CLI="$HOME/.nvm/versions/node/$(node -v)/bin/gemini"
    elif [ -f "/usr/local/bin/gemini" ]; then
        GEMINI_CLI="/usr/local/bin/gemini"
    else
        echo "[invoke-gemini.sh] ERROR: Gemini CLI not found. Set GEMINI_CLI env var or install gemini." >&2
        exit 1
    fi
fi

USER_COUNCIL_DIR="$HOME/.claude/council"
PROJECT_COUNCIL_DIR="$PWD/council"
MAX_RETRIES=3
RETRY_DELAY=2

# Get arguments
PROMPT="$1"
STANCE="${2:-balanced}"

# Define stance instructions
get_stance_instructions() {
    case "$1" in
        cooperative)
            echo "STANCE: Cooperative
- Build on Claude's ideas constructively
- Look for synthesis opportunities
- Gentle challenges only when necessary
- Focus on improving ideas, not defeating them
- Seek common ground and mutual understanding"
            ;;
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
PROTOCOL_FILE="$USER_COUNCIL_DIR/protocol.md"
if [ -f "$PROTOCOL_FILE" ]; then
    FULL_CONTEXT="=== COUNCIL PROTOCOL ===
$(cat "$PROTOCOL_FILE")"
else
    echo "[invoke-gemini.sh] WARNING: Protocol file not found at $PROTOCOL_FILE" >&2
fi

# 2. Stance instructions
STANCE_INSTRUCTIONS=$(get_stance_instructions "$STANCE")
FULL_CONTEXT="$FULL_CONTEXT

=== YOUR STANCE FOR THIS SESSION ===
$STANCE_INSTRUCTIONS"

# 3. Project context (optional)
PROJECT_CONTEXT_FILE="$PROJECT_COUNCIL_DIR/GEMINI.md"
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

# Build full prompt
if [ -n "$FULL_CONTEXT" ]; then
    FULL_PROMPT="$FULL_CONTEXT

---

$PROMPT"
else
    FULL_PROMPT="$PROMPT"
fi

# Invoke Gemini with retry logic
# -y enables yolo mode so Gemini can use tools (read files, etc.)
attempt=1
while [ $attempt -le $MAX_RETRIES ]; do
    # Run Gemini with -y (yolo mode for tool access), stderr filtered
    OUTPUT=$($GEMINI_CLI -y -o text "$FULL_PROMPT" 2>&1 | grep -v "YOLO mode is enabled" | grep -v "Loaded cached credentials")
    EXIT_CODE=$?

    if [ $EXIT_CODE -eq 0 ] && [ -n "$OUTPUT" ]; then
        # Success - output the result (filter empty lines only)
        echo "$OUTPUT" | grep -v "^$"
        exit 0
    fi

    # Log failure
    echo "[invoke-gemini.sh] Attempt $attempt/$MAX_RETRIES failed (exit code: $EXIT_CODE)" >&2

    if [ $attempt -lt $MAX_RETRIES ]; then
        echo "[invoke-gemini.sh] Retrying in ${RETRY_DELAY}s..." >&2
        sleep $RETRY_DELAY
    fi

    attempt=$((attempt + 1))
done

# All retries exhausted
echo "[invoke-gemini.sh] ERROR: All $MAX_RETRIES attempts failed" >&2
exit 1
