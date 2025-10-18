"""
WSGI entry point for production deployment (Render, Heroku, etc.)
"""
import sys
import os
from pathlib import Path

# إضافة المسار الجذري للمشروع
sys.path.insert(0, str(Path(__file__).resolve().parent))

# استيراد التطبيق
from backend.main import create_app
from backend.api.websockets import socketio

print(">> wsgi.py: Starting application setup...")

# إنشاء التطبيق
app = create_app()

# تهيئة SocketIO مع التطبيق
socketio.init_app(app,
    cors_allowed_origins="*",
    async_mode='gevent',  # استخدام gevent للأداء الأفضل
    ping_timeout=60,
    ping_interval=25,
    logger=False,
    engineio_logger=False,
    # إعدادات مهمة لـ WebSocket على Render
    allow_upgrades=True,  # السماح بـ WebSocket upgrade
    transports=['websocket', 'polling']  # WebSocket أولاً، ثم polling
)

print(f">> wsgi.py: SocketIO initialized with async_mode=gevent")
print(f">> wsgi.py: Allowed transports: websocket, polling")

# ⚠️ مهم: عند استخدام gunicorn مع gevent، نحتاج app مباشرة
# SocketIO middleware مدمج تلقائياً عبر socketio.init_app()
application = app

print(">> wsgi.py: Application ready for gunicorn")

if __name__ == "__main__":
    # للاختبار المحلي فقط
    port = int(os.environ.get("PORT", 5000))
    print(f">> wsgi.py: Running on port {port}")
    socketio.run(app, host="0.0.0.0", port=port, debug=False)
