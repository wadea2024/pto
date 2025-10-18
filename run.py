"""
ملف لتشغيل التطبيق على Windows
"""
import sys
import os
from pathlib import Path

# إضافة المسار الجذري للمشروع
sys.path.insert(0, str(Path(__file__).resolve().parent))

# استيراد التطبيق
from backend.main import create_app
from backend.api.websockets import socketio

if __name__ == "__main__":
    app = create_app()

    # قراءة PORT من البيئة (Render) أو استخدام 5000 افتراضياً
    port = int(os.environ.get("PORT", 5000))
    debug = os.environ.get("FLASK_DEBUG", "0") == "1"

    # تشغيل الخادم مع SocketIO
    print("\n" + "="*60)
    print("🚀 الخادم يعمل الآن!")
    print(f"📍 افتح المتصفح على: http://localhost:{port}")
    print(f"🔧 وضع Debug: {'مفعّل' if debug else 'معطّل'}")
    print("="*60 + "\n")

    socketio.run(app, host="0.0.0.0", port=port, debug=debug, log_output=False)
