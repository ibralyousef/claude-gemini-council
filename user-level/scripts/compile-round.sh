#!/usr/bin/env bash
# compile-round.sh — Concatenate individual position files into round-N.md
# Usage: compile-round.sh <session-dir> <round-number> <topic> <"N of M">
set -euo pipefail

SESSION_DIR="$1"
ROUND="$2"
TOPIC="$3"
ROUND_OF="$4"
CHAIR_FILE="${SESSION_DIR}/chair-round-${ROUND}.md"

OUTPUT="${SESSION_DIR}/round-${ROUND}.md"
TMPFILE="${SESSION_DIR}/.round-${ROUND}.tmp"

# Verify chair position file exists
if [[ ! -f "$CHAIR_FILE" ]]; then
  echo "Error: Chair position file not found: $CHAIR_FILE" >&2
  exit 1
fi

# Collect all round-N.md files, split into participant files (exclude chair)
shopt -s nullglob
ALL_FILES=("${SESSION_DIR}"/*-round-"${ROUND}".md)
shopt -u nullglob

POSITION_FILES=()
for f in "${ALL_FILES[@]}"; do
  [[ "$f" != "$CHAIR_FILE" ]] && POSITION_FILES+=("$f")
done

if [[ ${#POSITION_FILES[@]} -eq 0 ]]; then
  echo "Error: No participant position files found matching *-round-${ROUND}.md in ${SESSION_DIR}" >&2
  exit 1
fi

# Assemble content into temp file
{
  echo "# Round ${ROUND}"
  echo "**Topic**: ${TOPIC}"
  echo "**Round**: ${ROUND_OF}"
  echo ""
  echo "## CHAIR'S POSITION"
  cat "$CHAIR_FILE"
  echo ""

  for f in "${POSITION_FILES[@]}"; do
    basename_f="$(basename "$f")"
    # Extract persona: everything before -round-N.md
    persona="${basename_f%-round-${ROUND}.md}"
    persona_upper="$(echo "$persona" | tr '[:lower:]' '[:upper:]')"
    echo "## ${persona_upper}'S POSITION"
    cat "$f"
    echo ""
  done

  echo "## ROUND ${ROUND} SYNTHESIS"
} > "$TMPFILE"

# Atomic move
mv "$TMPFILE" "$OUTPUT"

# Verify output is non-empty
if [[ ! -s "$OUTPUT" ]]; then
  echo "Error: round-${ROUND}.md is empty after compilation" >&2
  exit 1
fi

# Clean up source files
rm -f "${POSITION_FILES[@]}" "$CHAIR_FILE"

echo "Compiled ${#POSITION_FILES[@]} positions into round-${ROUND}.md"
