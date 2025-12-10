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

# Convert to absolute path if relative (critical for new terminal windows)
if [[ "$SESSION_LOG" != /* ]] && [[ -n "$SESSION_LOG" ]]; then
    SESSION_LOG="$(pwd)/$SESSION_LOG"
fi

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
            "[ESCALATE]"*|"[ESCALATION]"*)
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

    # Use polling approach instead of tail -f (more reliable with file rewrites)
    local last_lines=0
    local session_complete=0
    while true; do
        if [ -f "$SESSION_LOG" ]; then
            local current_lines=$(wc -l < "$SESSION_LOG")
            if [ "$current_lines" -gt "$last_lines" ]; then
                # Display new lines and check for escalation/completion
                tail -n $((current_lines - last_lines)) "$SESSION_LOG" | while IFS= read -r line; do
                    case "$line" in
                        *"CLAUDE:"*|*"[CLAUDE]"*)
                            echo -e "${GREEN}${line}${NC}"
                            ;;
                        *"GEMINI:"*|*"[GEMINI]"*)
                            echo -e "${BLUE}${line}${NC}"
                            ;;
                        "[ESCALATE]"*|"[ESCALATION]"*)
                            echo -e "${RED}${BOLD}${line}${NC}"
                            # Signal escalation needed
                            touch "${ESCALATION_FILE}.trigger"
                            ;;
                        *"=== COUNCIL SUMMARY ==="*|*"=== CONSENSUS RESULT ==="*)
                            echo -e "${YELLOW}${BOLD}${line}${NC}"
                            # Signal session complete
                            touch "${ESCALATION_FILE}.complete"
                            ;;
                        *"==="*)
                            echo -e "${YELLOW}${BOLD}${line}${NC}"
                            ;;
                        *"---"*"ROUND"*|*"Round"*)
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
                last_lines=$current_lines
            fi

            # Check if escalation was triggered
            if [ -f "${ESCALATION_FILE}.trigger" ]; then
                rm -f "${ESCALATION_FILE}.trigger"
                echo ""
                echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}"
                echo -e "${RED}║${NC}  ${BOLD}ESCALATION - User Input Required${NC}"
                echo -e "${RED}╠════════════════════════════════════════════════════════════╣${NC}"
                echo -e "${RED}║${NC}  The AIs need your input to continue."
                echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}"
                echo ""
                echo -e "${YELLOW}Your response (press Enter when done):${NC}"
                read -r user_response
                echo "$user_response" > "$ESCALATION_FILE"
                echo -e "${GREEN}Response recorded. Session will continue...${NC}"
                echo ""
            fi

            # Check if session is complete
            if [ -f "${ESCALATION_FILE}.complete" ]; then
                rm -f "${ESCALATION_FILE}.complete"
                # Wait a moment for any remaining content to be displayed
                sleep 1
                echo ""
                echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
                echo -e "${GREEN}║${NC}  ${BOLD}SESSION COMPLETE${NC}"
                echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
                echo ""
                echo -e "${CYAN}Press any key to close...${NC}"
                read -n 1 -s
                # Close the Terminal window on macOS
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    osascript -e 'tell application "Terminal" to close front window' &>/dev/null
                fi
                exit 0
            fi
        fi
        sleep 0.5
    done
}

# Function to open in tmux or new terminal
open_terminal() {
    local script_path
    script_path="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

    # Escape arguments for shell embedding
    local escaped_log="${SESSION_LOG//\"/\\\"}"
    local escaped_topic="${TOPIC//\"/\\\"}"
    local escaped_stance="${STANCE//\"/\\\"}"
    local escaped_rounds="${ROUNDS//\"/\\\"}"

    if command -v tmux &> /dev/null && [ -n "$TMUX" ]; then
        # Inside tmux - create split pane on the right (40% width)
        tmux split-window -h -p 40 "COUNCIL_TERMINAL_RUNNING=1 \"$script_path\" \"$escaped_log\" \"$escaped_topic\" \"$escaped_stance\" \"$escaped_rounds\"; echo ''; echo 'Session ended. Press Enter to close...'; read"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - open new Terminal window
        osascript <<EOF
tell application "Terminal"
    activate
    do script "COUNCIL_TERMINAL_RUNNING=1 '$script_path' '$escaped_log' '$escaped_topic' '$escaped_stance' '$escaped_rounds'; echo ''; echo 'Session ended. Press Enter to close...'; read"
end tell
EOF
    elif command -v gnome-terminal &> /dev/null; then
        # Linux with GNOME
        gnome-terminal -- bash -c "COUNCIL_TERMINAL_RUNNING=1 \"$script_path\" \"$escaped_log\" \"$escaped_topic\" \"$escaped_stance\" \"$escaped_rounds\"; echo ''; echo 'Session ended. Press Enter to close...'; read"
    elif command -v xterm &> /dev/null; then
        # Fallback to xterm
        xterm -e "COUNCIL_TERMINAL_RUNNING=1 \"$script_path\" \"$escaped_log\" \"$escaped_topic\" \"$escaped_stance\" \"$escaped_rounds\"; echo ''; echo 'Session ended. Press Enter to close...'; read" &
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
