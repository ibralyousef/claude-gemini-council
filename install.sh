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

# 1. Create ~/.claude directories if needed
echo "[1/4] Creating directories..."
mkdir -p "$CLAUDE_DIR/commands"
mkdir -p "$CLAUDE_DIR/council"
echo "  Created $CLAUDE_DIR/commands"
echo "  Created $CLAUDE_DIR/council"

# 2. Backup and remove existing command files (preparing for symlinks)
echo ""
echo "[2/4] Backing up existing files..."
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

if [ $BACKUP_COUNT -eq 0 ]; then
    echo "  No existing files to backup"
fi

# 3. Create symlinks for commands (single source of truth = repo)
echo ""
echo "[3/4] Creating symlinks..."

# Create symlinks to repo for command files
ln -sf "$SCRIPT_DIR/user-level/commands/council.md" "$CLAUDE_DIR/commands/council.md"
ln -sf "$SCRIPT_DIR/user-level/commands/council-agenda.md" "$CLAUDE_DIR/commands/council-agenda.md"

echo "  Created symlink: ~/.claude/commands/council.md -> repo"
echo "  Created symlink: ~/.claude/commands/council-agenda.md -> repo"

# Create symlink for participant protocol
ln -sf "$SCRIPT_DIR/user-level/council/participant-protocol.md" "$CLAUDE_DIR/council/participant-protocol.md"

echo "  Created symlink: ~/.claude/council/participant-protocol.md -> repo"

# 4. Verify installation
echo ""
echo "[4/4] Verifying installation..."
echo "  Symlinks created successfully."

echo ""
echo "====================================="
echo "  Installation Complete!"
echo "====================================="
echo ""
echo "Usage:"
echo "  1. Navigate to any project directory"
echo "  2. Run: /council <topic>                    (standard mode)"
echo "     or:  /council -n 3 <topic>              (3 participants)"
echo "     or:  /council --consensus <topic>       (loop until resolved)"
echo "     or:  /council-agenda list               (view agenda)"
echo ""
echo "The first run will create a council/ folder in your project with:"
echo "  - council/memory/         (decisions and patterns)"
echo "  - council/sessions/       (session logs)"
echo ""
echo "Stance options: critical (default) | adversarial"
echo "Example: /council --consensus adversarial Should we rewrite in Rust?"
echo ""
echo "The agent team architecture allows multiple Claude instances to"
echo "collaborate on council sessions with configurable participant counts."
echo ""
echo "For more info, see: $SCRIPT_DIR/README.md"
