"""
Passenger WSGI file for cPanel deployment
This file is required by cPanel's Python application hosting
"""
import sys
import os
from pathlib import Path

# Get the application directory
INTERP = sys.executable
if sys.executable.startswith('/home'):
    # We're in cPanel environment
    # Add the application directory to sys.path
    cwd = os.path.dirname(os.path.abspath(__file__))
    sys.path.insert(0, cwd)

    # Add virtual environment if it exists
    venv_path = os.path.join(cwd, 'virtualenv', 'bin')
    if os.path.exists(venv_path):
        INTERP = os.path.join(venv_path, 'python3')
        if hasattr(sys, 'real_prefix'):
            pass
        else:
            activate_this = os.path.join(venv_path, 'activate_this.py')
            if os.path.exists(activate_this):
                exec(open(activate_this).read(), {'__file__': activate_this})

# Import the Flask application
try:
    from backend.main import create_app
    from backend.api.websockets import socketio

    # Create the application
    app = create_app()

    # Initialize SocketIO with the app
    socketio.init_app(app, cors_allowed_origins="*")

    # This is what Passenger will use
    application = app

except Exception as e:
    import traceback

    def application(environ, start_response):
        status = '500 Internal Server Error'
        output = f"""
        <html>
        <head><title>Application Error</title></head>
        <body>
        <h1>Application Error</h1>
        <pre>{traceback.format_exc()}</pre>
        </body>
        </html>
        """.encode('utf-8')

        response_headers = [
            ('Content-type', 'text/html'),
            ('Content-Length', str(len(output)))
        ]
        start_response(status, response_headers)
        return [output]
