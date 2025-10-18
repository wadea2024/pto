# 🚀 دليل نشر تطبيق PTO على cPanel

## 📋 المتطلبات الأساسية

- ✅ حساب cPanel يدعم Python 3.8+
- ✅ صلاحيات إنشاء Python Applications
- ✅ مساحة كافية على الاستضافة (100 MB على الأقل)
- ✅ SSL Certificate (موصى به)

---

## 📁 الخطوة 1: رفع الملفات

### أ) باستخدام File Manager في cPanel:

1. **سجل دخول إلى cPanel**
   - اذهب إلى: `https://alorfi.vip/cpanel`

2. **افتح File Manager**
   - ابحث عن "File Manager"
   - اذهب إلى المسار: `public_html/py/` أو حسب ما تريد

3. **ارفع ملفات التطبيق**
   - احذف أي ملفات موجودة في المجلد
   - ارفع **كل** ملفات المشروع:
     ```
     PTO-main/
     ├── backend/
     ├── frontend/
     ├── songs/
     ├── passenger_wsgi.py  ⭐ (مهم جداً)
     ├── .htaccess          ⭐ (مهم جداً)
     ├── requirements.txt
     └── ... (باقي الملفات)
     ```

### ب) باستخدام FTP/SFTP:

```bash
# استخدم FileZilla أو WinSCP
Host: ftp.alorfi.vip
Username: your_cpanel_username
Password: your_cpanel_password
Port: 21 (FTP) or 22 (SFTP)

# ارفع الملفات إلى:
/home/YOUR_USERNAME/public_html/py/
```

---

## 🐍 الخطوة 2: إنشاء Python Application

1. **اذهب إلى "Setup Python App"**
   - في cPanel، ابحث عن "Setup Python App"
   - أو "Python" في قائمة Software

2. **انقر على "Create Application"**

3. **املأ المعلومات التالية:**

   | الحقل | القيمة |
   |-------|--------|
   | **Python version** | 3.9 أو 3.10 أو 3.11 (الأحدث المتاح) |
   | **Application root** | `/home/YOUR_USERNAME/public_html/py` |
   | **Application URL** | `alorfi.vip/py` أو `py.alorfi.vip` |
   | **Application startup file** | `passenger_wsgi.py` |
   | **Application Entry point** | `application` |

4. **انقر "Create"**

---

## 📦 الخطوة 3: تثبيت المكتبات

### الطريقة الأولى: من cPanel Interface

1. بعد إنشاء التطبيق، انقر على **"Configuration Files"**
2. سيظهر لك مسار virtualenv مثل:
   ```
   source /home/YOUR_USERNAME/virtualenv/public_html/py/3.9/bin/activate
   ```
3. انسخ هذا الأمر وسنستخدمه في Terminal

### الطريقة الثانية: من Terminal (الأفضل)

1. **افتح Terminal في cPanel**
   - ابحث عن "Terminal" في cPanel

2. **فعّل البيئة الافتراضية:**
   ```bash
   source /home/YOUR_USERNAME/virtualenv/public_html/py/3.9/bin/activate
   ```

3. **انتقل إلى مجلد التطبيق:**
   ```bash
   cd ~/public_html/py
   ```

4. **ثبّت المكتبات:**
   ```bash
   pip install --upgrade pip
   pip install -r requirements.txt
   ```

5. **تحقق من التثبيت:**
   ```bash
   pip list
   ```
   يجب أن ترى:
   - Flask
   - Flask-SocketIO
   - python-socketio
   - وباقي المكتبات

---

## ⚙️ الخطوة 4: تعديل ملف .htaccess

1. **افتح .htaccess للتعديل**
   ```bash
   nano ~/public_html/py/.htaccess
   ```

2. **عدّل السطور التالية:**

   **قبل:**
   ```apache
   PassengerPython /home/YOUR_USERNAME/virtualenv/PTO-main/3.9/bin/python3.9
   PassengerAppRoot /home/YOUR_USERNAME/alorfi.vip/py
   PassengerRestartDir /home/YOUR_USERNAME/alorfi.vip/py/tmp
   PassengerDebugLogFile /home/YOUR_USERNAME/alorfi.vip/py/passenger.log
   ```

   **بعد (استبدل YOUR_USERNAME باسم المستخدم الحقيقي):**
   ```apache
   PassengerPython /home/alorfi/virtualenv/public_html/py/3.9/bin/python3.9
   PassengerAppRoot /home/alorfi/public_html/py
   PassengerRestartDir /home/alorfi/public_html/py/tmp
   PassengerDebugLogFile /home/alorfi/public_html/py/passenger.log
   ```

3. **احفظ الملف** (Ctrl+O, Enter, Ctrl+X)

---

## 🔧 الخطوة 5: إنشاء المجلدات المطلوبة

```bash
cd ~/public_html/py

# مجلد إعادة التشغيل
mkdir -p tmp
mkdir -p backend/core
mkdir -p backend/proposals

# مجلدات البيانات
mkdir -p backend/core/songs/lyrics
mkdir -p backend/core/songs/tabs
mkdir -p backend/core/images/artist
mkdir -p backend/core/images/artist_thumbs

# إنشاء ملفات JSON الأساسية
touch backend/core/votes.json
touch backend/core/song_states.json
touch backend/core/metadata_cache.json
echo "[]" > backend/proposals/proposals.json

# صلاحيات الكتابة
chmod 755 backend/core
chmod 755 backend/proposals
chmod 644 backend/core/*.json
chmod 644 backend/proposals/*.json
```

---

## 🎯 الخطوة 6: اختبار التطبيق

1. **افتح المتصفح واذهب إلى:**
   ```
   https://alorfi.vip/py
   ```

2. **يجب أن ترى صفحة التطبيق**
   - إذا رأيت خطأ، اذهب للخطوة التالية

3. **فحص السجلات (Logs):**
   ```bash
   # سجل Passenger
   tail -f ~/public_html/py/passenger.log

   # سجل الأخطاء
   tail -f ~/logs/error_log
   ```

---

## 🔄 الخطوة 7: إعادة تشغيل التطبيق

### الطريقة 1: من cPanel Interface
1. اذهب إلى "Setup Python App"
2. انقر على **"Restart"** بجانب تطبيقك

### الطريقة 2: من Terminal
```bash
# إعادة تشغيل بإنشاء ملف
touch ~/public_html/py/tmp/restart.txt

# أو باستخدام أمر Passenger
passenger-config restart-app ~/public_html/py
```

---

## 🔐 الخطوة 8: إعداد المتغيرات البيئية (اختياري)

1. **أنشئ ملف `.env`:**
   ```bash
   cd ~/public_html/py
   nano .env
   ```

2. **أضف المتغيرات:**
   ```bash
   FLASK_SECRET_KEY=your-super-secret-key-here-change-this
   PTO_ADMIN_PASS=your-admin-password-here
   FLASK_ENV=production
   ```

3. **احفظ وأغلق** (Ctrl+O, Enter, Ctrl+X)

4. **صلاحيات آمنة:**
   ```bash
   chmod 600 .env
   ```

---

## 🌐 الخطوة 9: إعداد Subdomain (اختياري)

إذا أردت استخدام `py.alorfi.vip` بدلاً من `alorfi.vip/py`:

1. **في cPanel، اذهب إلى "Subdomains"**
2. **أنشئ subdomain جديد:**
   - Subdomain: `py`
   - Domain: `alorfi.vip`
   - Document Root: `/home/YOUR_USERNAME/public_html/py`
3. **انقر "Create"**
4. **عدّل .htaccess:**
   ```apache
   RewriteBase /
   ```

---

## ⚡ الخطوة 10: تحسينات الأداء

### أ) تفعيل OPcache (إن لم يكن مفعلاً):
1. اذهب إلى "MultiPHP INI Editor"
2. فعّل:
   ```ini
   opcache.enable=1
   opcache.memory_consumption=128
   ```

### ب) ضبط إعدادات Passenger في .htaccess:
```apache
# للسيرفرات الضعيفة
PassengerMinInstances 1
PassengerMaxPoolSize 2
PassengerPoolIdleTime 300

# للسيرفرات المتوسطة
PassengerMinInstances 2
PassengerMaxPoolSize 4
PassengerPoolIdleTime 600

# للسيرفرات القوية
PassengerMinInstances 3
PassengerMaxPoolSize 6
PassengerPoolIdleTime 0
```

---

## 🐛 استكشاف الأخطاء

### مشكلة: "Application Error" أو صفحة بيضاء

**الحل:**
```bash
# 1. فحص السجل
tail -50 ~/public_html/py/passenger.log

# 2. فحص الصلاحيات
chmod -R 755 ~/public_html/py
find ~/public_html/py -type f -name "*.py" -exec chmod 644 {} \;

# 3. إعادة التشغيل
touch ~/public_html/py/tmp/restart.txt
```

### مشكلة: "No module named 'backend'"

**الحل:**
```bash
# تأكد من تثبيت المكتبات
source /home/YOUR_USERNAME/virtualenv/public_html/py/3.9/bin/activate
cd ~/public_html/py
pip install -r requirements.txt
touch tmp/restart.txt
```

### مشكلة: "Permission denied" للملفات

**الحل:**
```bash
cd ~/public_html/py
chmod -R 755 backend
chmod 777 backend/core
chmod 777 backend/proposals
chmod 666 backend/core/*.json
chmod 666 backend/proposals/*.json
```

### مشكلة: SocketIO لا يعمل

**ملاحظة:** SocketIO قد لا يعمل بشكل مثالي على cPanel المشترك.

**حلول بديلة:**
1. استخدم Polling بدلاً من WebSockets
2. عدّل `backend/api/websockets.py`:
   ```python
   socketio = SocketIO(
       cors_allowed_origins="*",
       async_mode='threading',
       engineio_logger=False,
       logger=False,
       # إضافة هذا
       allow_upgrades=False,  # فقط polling
       transports=['polling']
   )
   ```

---

## 📊 مراقبة الأداء

```bash
# استهلاك الموارد
top -u YOUR_USERNAME

# حجم التطبيق
du -sh ~/public_html/py

# عدد الملفات
find ~/public_html/py -type f | wc -l

# مشاهدة السجلات مباشرة
tail -f ~/public_html/py/passenger.log
```

---

## 🔒 الأمان

1. **تأكد من صلاحيات الملفات:**
   ```bash
   # ملفات Python: 644
   find ~/public_html/py -type f -name "*.py" -exec chmod 644 {} \;

   # المجلدات: 755
   find ~/public_html/py -type d -exec chmod 755 {} \;

   # .env: 600 (آمن جداً)
   chmod 600 ~/public_html/py/.env
   ```

2. **إخفاء ملفات التكوين:**
   أضف في `.htaccess`:
   ```apache
   <FilesMatch "^\.">
       Order allow,deny
       Deny from all
   </FilesMatch>
   ```

---

## 🚀 تحديث التطبيق

عندما تحتاج لتحديث الكود:

```bash
# 1. ارفع الملفات الجديدة (استبدل القديمة)
# 2. ثبّت أي مكتبات جديدة
source /home/YOUR_USERNAME/virtualenv/public_html/py/3.9/bin/activate
cd ~/public_html/py
pip install -r requirements.txt

# 3. أعد التشغيل
touch tmp/restart.txt

# 4. امسح cache المتصفح
# Ctrl+Shift+Delete
```

---

## ✅ Checklist النشر النهائي

- [ ] ملفات التطبيق مرفوعة بالكامل
- [ ] Python Application منشأة في cPanel
- [ ] المكتبات مثبتة من requirements.txt
- [ ] .htaccess معدّل بالمسارات الصحيحة
- [ ] المجلدات المطلوبة منشأة بالصلاحيات الصحيحة
- [ ] ملفات JSON الأساسية موجودة
- [ ] التطبيق يعمل على https://alorfi.vip/py
- [ ] السجلات (logs) خالية من الأخطاء
- [ ] SocketIO يعمل (أو تم تعطيله إن لم يعمل)

---

## 📞 المساعدة

إذا واجهت مشاكل:

1. **افحص السجلات أولاً:**
   ```bash
   tail -100 ~/public_html/py/passenger.log
   tail -100 ~/logs/error_log
   ```

2. **شارك رسالة الخطأ كاملة** للحصول على المساعدة

3. **تحقق من نسخة Python:**
   ```bash
   python3 --version
   ```

---

## 🎉 النهاية

بعد اتباع هذه الخطوات، يجب أن يكون تطبيق PTO يعمل على:

```
https://alorfi.vip/py
```

**ملاحظة:** أول تحميل قد يأخذ 5-10 ثوان، لكن بعد ذلك سيكون سريعاً جداً بفضل التحسينات التي أجريناها! 🚀

---

**تاريخ الإنشاء:** 2025-10-18
**الإصدار:** 1.0 - cPanel Deployment Guide
