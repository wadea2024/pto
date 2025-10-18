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

# إنشاء التطبيق
app = create_app()

# تهيئة SocketIO مع التطبيق
socketio.init_app(app,
    cors_allowed_origins="*",
    async_mode='gevent',  # استخدام gevent للأداء الأفضل
    logger=False,
    engineio_logger=False
)

# هذا هو التطبيق الذي سيستخدمه gunicorn
application = app

if __name__ == "__main__":
    # للاختبار المحلي فقط
    port = int(os.environ.get("PORT", 5000))
    socketio.run(app, host="0.0.0.0", port=port, debug=False)
