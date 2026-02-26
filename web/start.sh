#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-only
#
# Pre-PR CI - web/start.sh
# Web server startup script — launch the Flask server with the correct environment
#
# Copyright (C) 2025 Advanced Micro Devices, Inc.
# Author: Hemanth Selam <Hemanth.Selam@amd.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3.
#

WEB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$WEB_DIR")"

echo "╔═════════════════════════════════╗"
echo "║  Starting Pre-PR CI Web Server  ║"
echo "╚═════════════════════════════════╝"
echo ""
echo "Web Directory: $WEB_DIR"
echo "Project Root: $PROJECT_ROOT"
echo ""

# Change to project root
cd "$PROJECT_ROOT"

# Start server
echo "Starting web server..."
echo "Access at: http://$(hostname -I | awk '{print $1}'):5000"
echo ""
echo "Press Ctrl+C to stop"
echo ""

python3 "$WEB_DIR/server.py"
