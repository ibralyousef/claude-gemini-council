#!/bin/bash
# uninstall.sh - Remove AI Council installation
# Usage: ./uninstall.sh

CLAUDE_DIR="$HOME/.claude"

echo "====================================="
echo "  AI Council Uninstaller"
echo "====================================="
echo ""

read -p "This will remove AI Council from $CLAUDE_DIR. Continue? [y/N] " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "Removing files..."

# Remove commands
if [ -f "$CLAUDE_DIR/commands/council.md" ] || [ -L "$CLAUDE_DIR/commands/council.md" ]; then
    rm "$CLAUDE_DIR/commands/council.md"
    echo "  Removed: commands/council.md"
fi

if [ -f "$CLAUDE_DIR/commands/council-agenda.md" ] || [ -L "$CLAUDE_DIR/commands/council-agenda.md" ]; then
    rm "$CLAUDE_DIR/commands/council-agenda.md"
    echo "  Removed: commands/council-agenda.md"
fi

# Remove council directory
if [ -d "$CLAUDE_DIR/council" ]; then
    rm -rf "$CLAUDE_DIR/council"
    echo "  Removed: council/ directory"
fi

# Restore backups if they exist
echo ""
echo "Checking for backups..."
RESTORED=0
for backup in "$CLAUDE_DIR/commands/council.md.bak" "$CLAUDE_DIR/commands/council-agenda.md.bak"; do
    if [ -f "$backup" ]; then
        mv "$backup" "${backup%.bak}"
        echo "  Restored: ${backup%.bak}"
        RESTORED=$((RESTORED + 1))
    fi
done
if [ $RESTORED -eq 0 ]; then
    echo "  No backups found"
fi

echo ""
echo "====================================="
echo "  Uninstallation Complete!"
echo "====================================="
echo ""
echo "Note: Project-level council/ directories are NOT removed."
echo "To fully remove council from a project, delete its council/ folder."
