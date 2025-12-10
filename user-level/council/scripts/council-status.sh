#!/bin/bash
# council-status.sh - Update status-line with council session state
# Usage: council-status.sh "Round 3/10" or council-status.sh clear
#
# Writes council state to .council-state file in current directory.
# The user's status-line config reads this file to display council events.

STATE_FILE="$PWD/.council-state"

if [ "$1" = "clear" ]; then
    rm -f "$STATE_FILE"
else
    echo "$1" > "$STATE_FILE"
fi
