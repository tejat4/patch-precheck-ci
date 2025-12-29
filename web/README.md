# Patch Pre-Check CI - Web Interface

## Files in this directory

- `server.py` - Flask backend server
- `start.sh` - Launcher script
- `requirements.txt` - Python dependencies
- `templates/index.html` - Frontend interface

## How to start

```bash
./start.sh
```

Or directly:
```bash
python3 server.py
```

## Access

http://your-server-ip:5000

## Features

- Configure OpenAnolis or openEuler
- Run builds with real-time progress
- Execute tests individually
- View logs in popup modals
- Modern responsive UI

## Logs

All logs are automatically mapped from `../logs/` directory.
