"""
Windows Server Runner - without eventlet monkey patching issues
"""
import sys
import os
from pathlib import Path

# Set UTF-8 encoding for Windows console
if sys.platform == 'win32':
    import codecs
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer, 'strict')
    sys.stderr = codecs.getwriter('utf-8')(sys.stderr.buffer, 'strict')

# Add project root to path
sys.path.insert(0, str(Path(__file__).resolve().parent))

# Import without eventlet for Windows
from flask import Flask
from backend.main import create_app
from backend.api.websockets import socketio

if __name__ == "__main__":
    print("\n" + "="*60)
    print("Starting PTO Server...")
    print("Open browser at: http://localhost:5000")
    print("="*60 + "\n")

    app = create_app()

    # Run with SocketIO (threaded mode for Windows)
    socketio.run(
        app,
        host="0.0.0.0",
        port=5000,
        debug=False,  # CRITICAL: debug=True causes severe performance issues
        use_reloader=False,  # Disable reloader to avoid issues
        log_output=False  # Reduce console spam
    )
