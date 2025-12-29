#!/bin/bash
# Launcher for Patch Pre-Check CI Web Server

WEB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$WEB_DIR")"

echo "╔════════════════════════════════════════════════╗"
echo "║   Starting Patch Pre-Check CI Web Server      ║"
echo "╚════════════════════════════════════════════════╝"
echo ""
echo "Web Directory: $WEB_DIR"
echo "Project Root: $PROJECT_ROOT"
echo ""

# Change to project root
cd "$PROJECT_ROOT"

# Check dependencies
if ! python3 -c "import flask" 2>/dev/null; then
    echo "Installing dependencies..."
    pip3 install -r "$WEB_DIR/requirements.txt" --user
fi

# Start server
python3 "$WEB_DIR/server.py"
