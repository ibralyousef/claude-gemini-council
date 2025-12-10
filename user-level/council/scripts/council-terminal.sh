#!/bin/bash
# council-terminal.sh - Interactive terminal for AI Council sessions
# Usage: ./council-terminal.sh <session_log_path> [topic] [stance] [rounds]
#
# Features:
# - Opens tmux split pane (or new terminal if no tmux)
# - Tails session log in real-time
# - Handles user escalation when [ESCALATE] marker detected
# - Press Enter to close when session ends

SESSION_LOG="$1"
TOPIC="${2:-Council Session}"
STANCE="${3:-balanced}"
ROUNDS="${4:-3}"
ESCALATION_FILE="${SESSION_LOG%/*}/escalation-response.txt"

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Print header
print_header() {
    clear
    echo -e "${BOLD}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║${NC}  ${CYAN}AI COUNCIL${NC} - ${TOPIC:0:45}"
    echo -e "${BOLD}║${NC}  Mode: ${YELLOW}${STANCE}${NC} | Max Rounds: ${ROUNDS}"
    echo -e "${BOLD}╠════════════════════════════════════════════════════════════╣${NC}"
    echo ""
}

# Format and colorize log output
format_output() {
    while IFS= read -r line; do
        case "$line" in
            *"CLAUDE:"*|*"[CLAUDE]"*)
                echo -e "${GREEN}${line}${NC}"
                ;;
            *"GEMINI:"*|*"[GEMINI]"*)
                echo -e "${BLUE}${line}${NC}"
                ;;
            *"[ESCALATE]"*|*"[ESCALATION]"*)
                echo -e "${RED}${BOLD}${line}${NC}"
                handle_escalation "$line"
                ;;
            *"==="*)
                echo -e "${YELLOW}${BOLD}${line}${NC}"
                ;;
            *"---"*"ROUND"*)
                echo -e "${CYAN}${line}${NC}"
                ;;
            *"SESSION COMPLETE"*|*"RESOLVED"*)
                echo -e "${GREEN}${BOLD}${line}${NC}"
                ;;
            *)
                echo "$line"
                ;;
        esac
    done
}

# Handle escalation - prompt user for input
handle_escalation() {
    local escalation_line="$1"
    echo ""
    echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║${NC}  ${BOLD}ESCALATION - User Input Required${NC}"
    echo -e "${RED}╠════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${RED}║${NC}  The AIs need your input to continue."
    echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Your response (press Enter when done):${NC}"
    read -r user_response

    # Write response to file for AIs to read
    echo "$user_response" > "$ESCALATION_FILE"
    echo -e "${GREEN}Response recorded. Session will continue...${NC}"
    echo ""
}

# Main function to run the terminal UI
run_terminal() {
    print_header

    # Wait for session log to be created
    echo "Waiting for session to start..."
    while [ ! -f "$SESSION_LOG" ]; do
        sleep 0.5
    done

    echo "Session started. Streaming conversation..."
    echo -e "${BOLD}────────────────────────────────────────────────────────────${NC}"
    echo ""

    # Tail the log file and format output
    tail -f "$SESSION_LOG" 2>/dev/null | format_output
}

# Function to open in tmux or new terminal
open_terminal() {
    local script_path="$0"
    local args="\"$SESSION_LOG\" \"$TOPIC\" \"$STANCE\" \"$ROUNDS\""

    if command -v tmux &> /dev/null && [ -n "$TMUX" ]; then
        # Inside tmux - create split pane on the right (40% width)
        tmux split-window -h -p 40 "$script_path $args; echo ''; echo -e '${GREEN}Session ended. Press Enter to close...${NC}'; read"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - open new Terminal window
        osascript -e "tell app \"Terminal\" to do script \"$script_path $args; echo ''; echo 'Session ended. Press Enter to close...'; read\""
    elif command -v gnome-terminal &> /dev/null; then
        # Linux with GNOME
        gnome-terminal -- bash -c "$script_path $args; echo ''; echo 'Session ended. Press Enter to close...'; read"
    elif command -v xterm &> /dev/null; then
        # Fallback to xterm
        xterm -e "$script_path $args; echo ''; echo 'Session ended. Press Enter to close...'; read" &
    else
        # No GUI terminal available - run inline
        echo "No separate terminal available. Running inline..."
        run_terminal
    fi
}

# Check if we're being called to run the terminal or to open a new one
if [ "$COUNCIL_TERMINAL_RUNNING" = "1" ]; then
    # We're inside the terminal pane - run the UI
    run_terminal
else
    # We're being called to open a terminal - export flag and open
    export COUNCIL_TERMINAL_RUNNING=1

    if [ -z "$SESSION_LOG" ]; then
        echo "Usage: $0 <session_log_path> [topic] [stance] [rounds]"
        exit 1
    fi

    open_terminal
fi
