# 📝 Render Manual Setup - الإعداد اليدوي

## 🎯 لماذا الإعداد اليدوي؟

أحياناً Render لا يقرأ `render.yaml` بشكل صحيح، أو يحفظ إعدادات قديمة في cache.

**الحل الأفضل**: تحديث الإعدادات مباشرة في Render Dashboard.

---

## 🚀 الخطوات الكاملة

### 1️⃣ اذهب إلى Render Dashboard

افتح: https://dashboard.render.com

### 2️⃣ اختر Web Service

- اضغط على **pto-web** (أو اسم تطبيقك)

### 3️⃣ اذهب إلى Settings

من القائمة الجانبية، اضغط **Settings**

### 4️⃣ حدّث Start Command

ابحث عن قسم **"Build & Deploy"**:

#### Start Command:

**احذف** الأمر القديم:
```bash
gunicorn --worker-class gevent -w 1 --bind 0.0.0.0:$PORT wsgi:app
```

**الصق** الأمر الجديد:
```bash
gunicorn --worker-class geventwebsocket.gunicorn.workers.GeventWebSocketWorker -w 1 --bind 0.0.0.0:$PORT wsgi:app
```

**اضغط "Save Changes"** ✅

---

### 5️⃣ تحقق من Environment Variables

في قسم **Environment**:

| Key | Value |
|-----|-------|
| `FLASK_ENV` | `production` |
| `FLASK_DEBUG` | `0` |

**لا تضف** `PORT` - Render يوفره تلقائياً.

---

### 6️⃣ Manual Deploy (اختياري)

إذا لم يبدأ النشر تلقائياً:

1. اذهب إلى **Manual Deploy** (من القائمة العلوية)
2. اضغط **"Clear build cache & deploy"**
3. انتظر البناء (3-5 دقائق)

---

## ✅ التحقق من النجاح

### في Logs (Render Dashboard → Logs):

```bash
✅ [INFO] Starting gunicorn 21.2.0
✅ [INFO] Using worker: geventwebsocket.gunicorn.workers.GeventWebSocketWorker
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                          هذا السطر مهم جداً!
✅ >> wsgi.py: SocketIO initialized with async_mode=gevent
✅ [INFO] Worker spawned successfully
```

**إذا رأيت:**
```bash
❌ [INFO] Using worker: gevent
```

**معناه**: Start Command لم يتحدث. كرر الخطوات من جديد.

---

## 🖼️ صور توضيحية للخطوات

### الخطوة 1: Settings → Build & Deploy

```
┌─────────────────────────────────────────────┐
│  Build & Deploy                             │
├─────────────────────────────────────────────┤
│                                             │
│  Build Command:                             │
│  ┌─────────────────────────────────────┐   │
│  │ pip install -r requirements.txt     │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  Start Command:                             │
│  ┌─────────────────────────────────────┐   │
│  │ gunicorn --worker-class             │   │
│  │ geventwebsocket.gunicorn.workers.   │   │
│  │ GeventWebSocketWorker -w 1          │   │
│  │ --bind 0.0.0.0:$PORT wsgi:app       │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  [Save Changes]                             │
└─────────────────────────────────────────────┘
```

---

## 🐛 حل المشاكل

### المشكلة: Render يستمر في استخدام `gevent`

**الحل 1**: امسح الحقل تماماً ثم الصق الأمر الجديد:

1. في Start Command، اضغط **Ctrl+A** (تحديد الكل)
2. اضغط **Delete** (حذف)
3. الصق الأمر الجديد:
```bash
gunicorn --worker-class geventwebsocket.gunicorn.workers.GeventWebSocketWorker -w 1 --bind 0.0.0.0:$PORT wsgi:app
```
4. **Save Changes**

**الحل 2**: حذف السيرفس وإعادة إنشائه:

⚠️ **تحذير**: ستفقد الإعدادات والـ disk data.

1. Settings → **Delete Web Service**
2. إنشاء Web Service جديد من GitHub
3. تكوين كل شيء من جديد

---

### المشكلة: Build فشل

**الخطأ:**
```
ModuleNotFoundError: No module named 'geventwebsocket'
```

**الحل:**
تأكد من `requirements.txt` يحتوي على:
```txt
gevent-websocket==0.10.1
```

ثم اعمل **Manual Deploy** → **Clear build cache & deploy**.

---

### المشكلة: WebSocket لا يزال يفشل

**التحقق من Logs:**

إذا رأيت:
```
RuntimeError: The gevent-websocket server is not configured appropriately.
```

**معناه**: لا يزال يستخدم worker خاطئ.

**الحل النهائي**:

1. **احذف render.yaml** من المشروع:
```bash
git rm render.yaml
git commit -m "Remove render.yaml, using Dashboard settings"
git push origin main
```

2. **حدّث Start Command في Dashboard** (كما في الخطوات أعلاه)

3. **Manual Deploy** → **Clear build cache & deploy**

---

## 📋 Checklist النهائي

قبل الاختبار:

- [ ] Start Command يحتوي على `GeventWebSocketWorker` (بالكامل)
- [ ] Environment Variables محددة (`FLASK_ENV=production`)
- [ ] requirements.txt يحتوي على `gevent-websocket==0.10.1`
- [ ] تم عمل Manual Deploy أو Save Changes
- [ ] Logs تظهر `Using worker: geventwebsocket.gunicorn.workers.GeventWebSocketWorker`

---

## 🎉 النتيجة المتوقعة

### في Render Logs:
```bash
[INFO] Starting gunicorn 21.2.0
[INFO] Listening at: http://0.0.0.0:10000
[INFO] Using worker: geventwebsocket.gunicorn.workers.GeventWebSocketWorker ✅
[INFO] Booting worker with pid: 57
>> wsgi.py: SocketIO initialized with async_mode=gevent
>> wsgi.py: Allowed transports: websocket, polling
```

### في المتصفح (https://pto-1.onrender.com):
- Console: `socket.io connected` ✅
- Network → WS: WebSocket connection established ✅
- Status: `101 Switching Protocols` ✅

---

## 📞 إذا لم ينجح

أرسل لي:
1. Screenshot من **Render Dashboard → Settings → Build & Deploy**
2. آخر 50 سطر من **Render Logs**
3. رسالة الخطأ في **Browser Console**

---

**تاريخ الإنشاء**: 2025-10-18
**الحالة**: ✅ الإعداد اليدوي يعمل دائماً
