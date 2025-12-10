#!/bin/bash
# install.sh - Install AI Council for Claude Code
# Usage: ./install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "====================================="
echo "  AI Council Installer"
echo "====================================="
echo ""

# 1. Check for Gemini CLI
echo "[1/5] Checking for Gemini CLI..."
GEMINI_PATH=""

if command -v gemini &> /dev/null; then
    GEMINI_PATH="$(command -v gemini)"
    echo "  Found: $GEMINI_PATH"
elif [ -f "$HOME/.nvm/versions/node/$(node -v 2>/dev/null)/bin/gemini" ]; then
    GEMINI_PATH="$HOME/.nvm/versions/node/$(node -v)/bin/gemini"
    echo "  Found via nvm: $GEMINI_PATH"
else
    echo "  WARNING: Gemini CLI not found in PATH."
    echo ""
    read -p "  Enter path to gemini CLI (or press Enter to skip): " GEMINI_PATH

    if [ -n "$GEMINI_PATH" ] && [ ! -f "$GEMINI_PATH" ]; then
        echo "  ERROR: File not found: $GEMINI_PATH"
        exit 1
    fi
fi

# 2. Create ~/.claude directories if needed
echo ""
echo "[2/5] Creating directories..."
mkdir -p "$CLAUDE_DIR/commands"
mkdir -p "$CLAUDE_DIR/council/scripts"
echo "  Created $CLAUDE_DIR/commands"
echo "  Created $CLAUDE_DIR/council/scripts"

# 3. Backup existing council files
echo ""
echo "[3/5] Backing up existing files..."
BACKUP_COUNT=0
for file in "$CLAUDE_DIR/commands/council.md" "$CLAUDE_DIR/commands/council-consensus.md" "$CLAUDE_DIR/council/protocol.md"; do
    if [ -f "$file" ]; then
        mv "$file" "$file.bak"
        echo "  Backed up: $file -> $file.bak"
        BACKUP_COUNT=$((BACKUP_COUNT + 1))
    fi
done
if [ $BACKUP_COUNT -eq 0 ]; then
    echo "  No existing files to backup"
fi

# 4. Copy files
echo ""
echo "[4/5] Installing files..."
cp "$SCRIPT_DIR/user-level/commands/council.md" "$CLAUDE_DIR/commands/"
cp "$SCRIPT_DIR/user-level/commands/council-consensus.md" "$CLAUDE_DIR/commands/"
cp "$SCRIPT_DIR/user-level/council/protocol.md" "$CLAUDE_DIR/council/"
cp "$SCRIPT_DIR/user-level/council/scripts/invoke-gemini.sh" "$CLAUDE_DIR/council/scripts/"
cp "$SCRIPT_DIR/user-level/council/scripts/council-terminal.sh" "$CLAUDE_DIR/council/scripts/"

# Make scripts executable
chmod +x "$CLAUDE_DIR/council/scripts/"*.sh

echo "  Installed commands:"
echo "    - council.md"
echo "    - council-consensus.md"
echo "  Installed council files:"
echo "    - protocol.md"
echo "    - scripts/invoke-gemini.sh"
echo "    - scripts/council-terminal.sh"

# 5. Configure Gemini path if provided
echo ""
echo "[5/5] Configuring..."
if [ -n "$GEMINI_PATH" ]; then
    echo "  Setting GEMINI_CLI=$GEMINI_PATH"
    echo ""
    echo "  Add this to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
    echo "    export GEMINI_CLI=\"$GEMINI_PATH\""
fi

echo ""
echo "====================================="
echo "  Installation Complete!"
echo "====================================="
echo ""
echo "Usage:"
echo "  1. Navigate to any project directory"
echo "  2. Run: /council <topic>"
echo "     or: /council-consensus <topic>"
echo ""
echo "The first run will create a council/ folder in your project with:"
echo "  - council/GEMINI.md       (project context - edit this!)"
echo "  - council/memory/         (decisions and patterns)"
echo "  - council/sessions/       (session logs)"
echo ""
echo "Stance options: cooperative | balanced | critical | adversarial"
echo "Example: /council adversarial 5 Should we rewrite in Rust?"
echo ""
echo "For more info, see: $SCRIPT_DIR/README.md"
