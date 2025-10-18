# backend/api/websockets.py
from flask_socketio import SocketIO, emit
import json
import os

# Import robusto de helpers (funciona tanto en local como en Render)
try:
    from backend.services.vote_logic import count_votes, save_votes, load_votes
except Exception:
    try:
        from ..services.vote_logic import count_votes, save_votes, load_votes  # type: ignore
    except Exception as e:
        raise

# No importes config aquí; vote_logic ya resuelve rutas y persistencia
# PERFORMANCE: Configure SocketIO with optimizations
# async_mode will be set by wsgi.py (gevent) or run.py (threading)
socketio = SocketIO(
    cors_allowed_origins="*",
    ping_timeout=60,
    ping_interval=25,
    logger=False,  # Disable verbose logging
    engineio_logger=False  # Disable engine.io logging
)

# Estado en memoria (mapa device_id -> song_id)
song_states = load_votes()

@socketio.on("vote")
def handle_vote(data):
    device_id = data.get("deviceId")
    song_id = data.get("songId")
    if not device_id or not song_id:
        return

    prev = song_states.get(device_id)
    if prev == song_id:
        return  # idempotente

    song_states[device_id] = song_id
    save_votes(song_states)

    vote_counts = count_votes(song_states)
    socketio.emit("update", vote_counts)
