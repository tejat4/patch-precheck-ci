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

# Check and configure firewall
if command -v firewall-cmd &> /dev/null; then
    echo "Checking firewall configuration..."

    # Check if port 5000 is open
    if ! sudo firewall-cmd --list-ports 2>/dev/null | grep -q "5000/tcp"; then
        echo "Port 5000 not open in firewall. Opening..."

        if sudo firewall-cmd --add-port=5000/tcp --permanent 2>/dev/null; then
            sudo firewall-cmd --reload 2>/dev/null
            echo "✓ Port 5000 opened in firewall"
        else
            echo "⚠ Could not open port 5000 automatically"
            echo "  Please run manually: sudo firewall-cmd --add-port=5000/tcp --permanent"
            echo "                       sudo firewall-cmd --reload"
        fi
    else
        echo "✓ Port 5000 is already open in firewall"
    fi
    echo ""
fi

# Change to project root
cd "$PROJECT_ROOT"

# Check dependencies
echo "Checking Python dependencies..."
if ! python3 -c "import flask" 2>/dev/null; then
    echo "Installing dependencies..."
    pip3 install -r "$WEB_DIR/requirements.txt" --user
    echo "✓ Dependencies installed"
else
    echo "✓ Dependencies already installed"
fi
echo ""

# Start server
echo "Starting web server..."
echo "Access at: http://$(hostname -I | awk '{print $1}'):5000"
echo ""
echo "Press Ctrl+C to stop"
echo ""

python3 "$WEB_DIR/server.py"
