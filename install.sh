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

if [ -n "$GEMINI_PATH" ]; then
    echo "  Verifying Gemini CLI functionality..."
    if ! "$GEMINI_PATH" --version &> /dev/null; then
        echo "  ERROR: Gemini CLI at '$GEMINI_PATH' is not functional. Please check the path or install it correctly."
        exit 1
    fi
    echo "  Gemini CLI verified."
fi

# 2. Create ~/.claude directories if needed
echo ""
echo "[2/5] Creating directories..."
mkdir -p "$CLAUDE_DIR/commands"
mkdir -p "$CLAUDE_DIR/council/scripts"
echo "  Created $CLAUDE_DIR/commands"
echo "  Created $CLAUDE_DIR/council/scripts"

# 3. Backup and remove existing command files (preparing for symlinks)
echo ""
echo "[3/5] Backing up existing files..."
BACKUP_DIR="$CLAUDE_DIR/commands.backup.$(date +%Y%m%d%H%M%S)"
BACKUP_COUNT=0

# Backup command files if they exist and are not already symlinks
for file in "$CLAUDE_DIR/commands/council.md" "$CLAUDE_DIR/commands/council-agenda.md"; do
    if [ -f "$file" ] && [ ! -L "$file" ]; then
        mkdir -p "$BACKUP_DIR"
        cp "$file" "$BACKUP_DIR/"
        rm "$file"
        echo "  Backed up: $file -> $BACKUP_DIR/"
        BACKUP_COUNT=$((BACKUP_COUNT + 1))
    elif [ -L "$file" ]; then
        rm "$file"
        echo "  Removed existing symlink: $file"
    fi
done

# Backup protocol file
if [ -f "$CLAUDE_DIR/council/protocol.md" ] && [ ! -L "$CLAUDE_DIR/council/protocol.md" ]; then
    mkdir -p "$BACKUP_DIR"
    mv "$CLAUDE_DIR/council/protocol.md" "$BACKUP_DIR/"
    echo "  Backed up: protocol.md -> $BACKUP_DIR/"
    BACKUP_COUNT=$((BACKUP_COUNT + 1))
fi

if [ $BACKUP_COUNT -eq 0 ]; then
    echo "  No existing files to backup"
fi

# 4. Create symlinks for commands (single source of truth = repo)
echo ""
echo "[4/5] Creating symlinks..."

# Create symlinks to repo for command files
ln -sf "$SCRIPT_DIR/user-level/commands/council.md" "$CLAUDE_DIR/commands/council.md"
ln -sf "$SCRIPT_DIR/user-level/commands/council-agenda.md" "$CLAUDE_DIR/commands/council-agenda.md"

echo "  Created symlink: ~/.claude/commands/council.md -> repo"
echo "  Created symlink: ~/.claude/commands/council-agenda.md -> repo"

# Remove existing scripts directory/symlink before creating new symlink
# This prevents nested scripts/scripts/ structure on fresh installs
if [ -e "$CLAUDE_DIR/council/scripts" ]; then
    rm -rf "$CLAUDE_DIR/council/scripts"
fi

# Copy non-command files (these are local config, not synced)
ln -sf "$SCRIPT_DIR/user-level/council/protocol.md" "$CLAUDE_DIR/council/protocol.md"
ln -sf "$SCRIPT_DIR/user-level/council/claude-participant-protocol.md" "$CLAUDE_DIR/council/claude-participant-protocol.md"
ln -sf "$SCRIPT_DIR/user-level/council/scripts" "$CLAUDE_DIR/council/scripts"

echo "  Created symlink: ~/.claude/council/scripts -> repo"
echo "  Created symlink: ~/.claude/council/claude-participant-protocol.md -> repo"

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
echo "Usage (Claude as Chair):"
echo "  1. Navigate to any project directory"
echo "  2. Run: /council <topic>                    (standard mode)"
echo "     or:  /council --consensus <topic>       (loop until resolved)"
echo "     or:  /council-agenda list               (view agenda)"
echo ""
echo "The first run will create a council/ folder in your project with:"
echo "  - council/GEMINI.md       (project context - edit this!)"
echo "  - council/memory/         (decisions and patterns)"
echo "  - council/sessions/       (session logs)"
echo ""
echo "Stance options: balanced | critical | adversarial"
echo "Example: /council --consensus adversarial Should we rewrite in Rust?"
echo ""
echo "====================================="
echo "  Gemini as Chair (Bidirectional Mode)"
echo "====================================="
echo ""
echo "To run council sessions with Gemini as Chair, use invoke-claude.sh:"
echo ""
echo "  From Gemini CLI:"
echo "    echo \"[topic]\" | ~/.claude/council/scripts/invoke-claude.sh [stance] [output_file]"
echo ""
echo "  Example:"
echo "    echo \"Should we refactor the auth module?\" | ~/.claude/council/scripts/invoke-claude.sh balanced council/sessions/current.md"
echo ""
echo "The symmetric architecture allows either AI to chair council sessions."
echo "Session files are stored in the same council/sessions/ directory."
echo ""
echo "For more info, see: $SCRIPT_DIR/README.md"
