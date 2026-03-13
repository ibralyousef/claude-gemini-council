#!/usr/bin/env bash
# compile-round.sh — Concatenate individual position files into round-N.md
# Usage: compile-round.sh <session-dir> <round-number> <topic> <"N of M">
# Contract: Assembles chair + participant positions into one round file,
#           deletes source files ONLY after verifying output integrity.

SESSION_DIR="$1"
ROUND="$2"
TOPIC="$3"
ROUND_OF="$4"
CHAIR_FILE="${SESSION_DIR}/chair-round-${ROUND}.md"
OUTPUT="${SESSION_DIR}/round-${ROUND}.md"

# Verify chair position file exists and is readable
if [[ ! -f "$CHAIR_FILE" ]] || [[ ! -r "$CHAIR_FILE" ]]; then
  echo "Error: Chair position file not found or unreadable: $CHAIR_FILE" >&2
  exit 1
fi

# Collect participant files (exclude chair)
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

# Verify all source files are readable before starting
for f in "${POSITION_FILES[@]}"; do
  if [[ ! -r "$f" ]]; then
    echo "Error: Position file not readable: $f" >&2
    exit 1
  fi
done

# Build output file piece by piece with explicit error checks
: > "$OUTPUT"  # truncate/create

echo "# Round ${ROUND}" >> "$OUTPUT"
echo "**Topic**: ${TOPIC}" >> "$OUTPUT"
echo "**Round**: ${ROUND_OF}" >> "$OUTPUT"
echo "" >> "$OUTPUT"

echo "## CHAIR'S POSITION" >> "$OUTPUT"
if ! cat "$CHAIR_FILE" >> "$OUTPUT"; then
  echo "Error: Failed to read $CHAIR_FILE" >&2
  rm -f "$OUTPUT"
  exit 1
fi
echo "" >> "$OUTPUT"

for f in "${POSITION_FILES[@]}"; do
  basename_f="$(basename "$f")"
  persona="${basename_f%-round-${ROUND}.md}"
  persona_upper="$(echo "$persona" | tr '[:lower:]' '[:upper:]')"
  echo "## ${persona_upper}'S POSITION" >> "$OUTPUT"
  if ! cat "$f" >> "$OUTPUT"; then
    echo "Error: Failed to read $f — source files preserved" >&2
    rm -f "$OUTPUT"
    exit 1
  fi
  echo "" >> "$OUTPUT"
done

echo "## ROUND ${ROUND} SYNTHESIS" >> "$OUTPUT"

# Final sanity check
if [[ ! -s "$OUTPUT" ]]; then
  echo "Error: Output file is empty" >&2
  exit 1
fi

# Clean up source files
rm -f "${POSITION_FILES[@]}" "$CHAIR_FILE"

echo "Compiled ${#POSITION_FILES[@]} positions into round-${ROUND}.md"
