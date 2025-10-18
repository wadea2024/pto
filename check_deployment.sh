#!/bin/bash
# ════════════════════════════════════════════════════════════
# سكريبت التحقق من النشر على cPanel
# ════════════════════════════════════════════════════════════

echo "════════════════════════════════════════════════════════════"
echo "   فحص نشر تطبيق PTO على cPanel"
echo "════════════════════════════════════════════════════════════"
echo ""

# الألوان
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# عدادات
ERRORS=0
WARNINGS=0
SUCCESS=0

# دالة للتحقق
check() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
        ((SUCCESS++))
    else
        echo -e "${RED}✗${NC} $2"
        ((ERRORS++))
    fi
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

info() {
    echo -e "ℹ $1"
}

echo "1️⃣  التحقق من ملفات النشر الأساسية"
echo "─────────────────────────────────────"

# التحقق من passenger_wsgi.py
if [ -f "passenger_wsgi.py" ]; then
    check 0 "passenger_wsgi.py موجود"
else
    check 1 "passenger_wsgi.py غير موجود"
fi

# التحقق من .htaccess
if [ -f ".htaccess" ]; then
    check 0 ".htaccess موجود"
else
    check 1 ".htaccess غير موجود"
fi

# التحقق من requirements.txt
if [ -f "requirements.txt" ]; then
    check 0 "requirements.txt موجود"
else
    check 1 "requirements.txt غير موجود"
fi

echo ""
echo "2️⃣  التحقق من هيكل المجلدات"
echo "──────────────────────────────"

# التحقق من المجلدات الرئيسية
[ -d "backend" ] && check 0 "مجلد backend موجود" || check 1 "مجلد backend غير موجود"
[ -d "frontend" ] && check 0 "مجلد frontend موجود" || check 1 "مجلد frontend غير موجود"
[ -d "backend/core" ] && check 0 "مجلد backend/core موجود" || warn "مجلد backend/core غير موجود - سيتم إنشاؤه تلقائياً"
[ -d "tmp" ] && check 0 "مجلد tmp موجود" || warn "مجلد tmp غير موجود - يجب إنشاؤه"

echo ""
echo "3️⃣  التحقق من Python"
echo "───────────────────────"

# التحقق من Python
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1)
    check 0 "Python مثبت: $PYTHON_VERSION"
else
    check 1 "Python غير مثبت"
fi

# التحقق من pip
if command -v pip3 &> /dev/null; then
    check 0 "pip مثبت"
else
    check 1 "pip غير مثبت"
fi

echo ""
echo "4️⃣  التحقق من المكتبات المطلوبة"
echo "──────────────────────────────────"

# قراءة requirements.txt
if [ -f "requirements.txt" ]; then
    info "قراءة requirements.txt..."
    while IFS= read -r line || [ -n "$line" ]; do
        # تجاهل السطور الفارغة والتعليقات
        if [[ ! -z "$line" ]] && [[ ! "$line" =~ ^# ]]; then
            # استخراج اسم الحزمة
            PACKAGE=$(echo "$line" | cut -d'=' -f1 | cut -d'>' -f1 | cut -d'<' -f1)
            if python3 -c "import $PACKAGE" 2>/dev/null; then
                check 0 "$PACKAGE مثبت"
            else
                warn "$PACKAGE غير مثبت"
            fi
        fi
    done < requirements.txt
else
    warn "requirements.txt غير موجود"
fi

echo ""
echo "5️⃣  التحقق من ملفات JSON"
echo "──────────────────────────"

# ملفات JSON المطلوبة
JSON_FILES=(
    "backend/core/votes.json"
    "backend/core/song_states.json"
    "backend/core/metadata_cache.json"
    "backend/proposals/proposals.json"
)

for file in "${JSON_FILES[@]}"; do
    if [ -f "$file" ]; then
        check 0 "$file موجود"
    else
        warn "$file غير موجود - سيتم إنشاؤه عند أول تشغيل"
    fi
done

echo ""
echo "6️⃣  التحقق من الصلاحيات"
echo "──────────────────────────"

# التحقق من الصلاحيات
if [ -w "backend/core" ]; then
    check 0 "backend/core قابل للكتابة"
else
    warn "backend/core غير قابل للكتابة - قد تحتاج chmod 755"
fi

if [ -f "passenger_wsgi.py" ]; then
    if [ -r "passenger_wsgi.py" ]; then
        check 0 "passenger_wsgi.py قابل للقراءة"
    else
        check 1 "passenger_wsgi.py غير قابل للقراءة"
    fi
fi

echo ""
echo "7️⃣  فحص .htaccess"
echo "─────────────────"

if [ -f ".htaccess" ]; then
    # التحقق من وجود YOUR_USERNAME
    if grep -q "YOUR_USERNAME" .htaccess; then
        check 1 ".htaccess يحتوي على YOUR_USERNAME - يجب استبداله!"
    else
        check 0 ".htaccess معدّل بشكل صحيح"
    fi

    # التحقق من PassengerPython
    if grep -q "PassengerPython" .htaccess; then
        check 0 ".htaccess يحتوي على PassengerPython"
    else
        warn ".htaccess لا يحتوي على PassengerPython"
    fi
fi

echo ""
echo "════════════════════════════════════════════════════════════"
echo "   النتيجة النهائية"
echo "════════════════════════════════════════════════════════════"
echo ""
echo -e "${GREEN}✓ نجح: $SUCCESS${NC}"
echo -e "${YELLOW}⚠ تحذيرات: $WARNINGS${NC}"
echo -e "${RED}✗ أخطاء: $ERRORS${NC}"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  ✅ التطبيق جاهز للنشر على cPanel!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "الخطوات التالية:"
    echo "1. ارفع الملفات إلى cPanel"
    echo "2. أنشئ Python Application"
    echo "3. ثبّت المكتبات: pip install -r requirements.txt"
    echo "4. عدّل .htaccess إذا لزم الأمر"
    echo ""
    exit 0
else
    echo -e "${RED}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${RED}  ⚠️  يوجد $ERRORS خطأ يجب إصلاحه!${NC}"
    echo -e "${RED}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "راجع الأخطاء أعلاه وأصلحها قبل النشر."
    echo ""
    exit 1
fi
