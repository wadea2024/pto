# 🔧 Iframe Auto-Resize Fix

## المشكلة (Problem)

عندما يتم تحديث التصنيف (ranking) في iframe، كان الحجم لا يتحدث تلقائياً:
- **أول تحديث**: يعمل بشكل جيد ✅
- **التحديثات التالية**: iframe يبقى بنفس الحجم القديم، مما يسبب عدم ظهور المحتوى بالكامل ❌

## السبب (Root Cause)

في [index.html:940-949](frontend/public/index.html#L940-949):
```javascript
// ❌ المشكلة القديمة
function resizeRankingFrame() {
    const iframe = document.getElementById('ranking-frame');
    if (iframe && iframe.contentWindow && iframe.contentWindow.document.body) {
        iframe.style.height = iframe.contentWindow.document.body.scrollHeight + "px";
    }
}

const iframe = document.getElementById('ranking-frame');
iframe.addEventListener("load", resizeRankingFrame);
// setInterval تم إزالته لتحسين الأداء ← هنا المشكلة!
```

**المشكلة**:
- `load` event يعمل فقط مرة واحدة عند تحميل iframe
- تم إزالة `setInterval` لتحسين الأداء
- لا يوجد trigger عند تحديث المحتوى داخل iframe

## الحل (Solution)

### 1. في [ran.html](frontend/public/ran.html#L328-357)

أضفنا نظام إشعار تلقائي للصفحة الرئيسية عند تغيير المحتوى:

```javascript
// ✅ إشعار الصفحة الرئيسية عند تغيير الحجم
function notifyParentResize() {
    if (parent && parent !== window) {
        try {
            const height = document.body.scrollHeight;
            parent.postMessage({ type: 'resize', height: height }, '*');
        } catch (e) {
            // Silent fail if parent is not accessible
        }
    }
}

// مراقبة أي تغييرات في المحتوى
const resizeObserver = new MutationObserver(() => {
    requestAnimationFrame(notifyParentResize);
});

resizeObserver.observe(document.body, {
    childList: true,  // مراقبة إضافة/حذف العناصر
    subtree: true,    // مراقبة جميع العناصر الفرعية
    attributes: true  // مراقبة تغيير الخصائص
});

// تحديث عند التحميل
window.addEventListener('load', () => {
    setTimeout(notifyParentResize, 100);
});

window.notifyParentResize = notifyParentResize;
```

### 2. في [ran.html:240-268](frontend/public/ran.html#L240-268)

إشعار الصفحة الرئيسية فوراً بعد تحديث عرض التصنيف:

```javascript
function updateRankingDisplay(rankedIds, counts) {
    const top3 = rankedIds.slice(0, 3);
    const rest = rankedIds.slice(3);

    const top3Container = document.getElementById("ranking-top3");
    const restContainer = document.getElementById("ranking-rest");
    top3Container.innerHTML = "";
    restContainer.innerHTML = "";

    for (let i = 0; i < top3.length; i++) {
        const id = top3[i];
        const li = createSongLi(id, counts[id], "top" + (i + 1));
        top3Container.appendChild(li);
    }

    for (const id of rest) {
        const li = createSongLi(id, counts[id]);
        restContainer.appendChild(li);
    }

    markAll();

    // ✅ إشعار الصفحة الرئيسية بعد اكتمال تحديث DOM
    requestAnimationFrame(() => {
        if (typeof notifyParentResize === 'function') {
            notifyParentResize();
        }
    });
}
```

### 3. في [ran.html:300-319](frontend/public/ran.html#L300-319)

إشعار عند استقبال تحديث من Socket:

```javascript
socket.on("update", data => {
    const byDevice = data.byDevice || {};
    currentVotes = {};
    for (const [device, songId] of Object.entries(byDevice)) {
        if (!currentVotes[songId]) currentVotes[songId] = [];
        currentVotes[songId].push(device);
    }

    const states = data.states || {};
    for (const id in states) {
        if (songCatalog[id]) songCatalog[id].state = states[id];
    }

    const counts = data.counts || {};
    const ranked = Object.entries(counts).sort((a, b) => b[1] - a[1]).map(([id]) => id);
    updateRankingDisplay(ranked, counts);

    // ✅ إشعار الصفحة الرئيسية بتغيير المحتوى
    setTimeout(notifyParentResize, 50);
});
```

### 4. في [index.html:950-958](frontend/public/index.html#L950-958)

استقبال رسائل تغيير الحجم من iframe:

```javascript
// ✅ استماع لرسائل تغيير الحجم من iframe
window.addEventListener('message', (event) => {
    if (event.data && event.data.type === 'resize') {
        const iframe = document.getElementById('ranking-frame');
        if (iframe && event.data.height) {
            iframe.style.height = event.data.height + 'px';
        }
    }
});
```

## كيف يعمل النظام (How It Works)

```
┌─────────────────────────────────────────────────────┐
│                   ran.html (iframe)                 │
│                                                     │
│  1. MutationObserver يراقب تغييرات DOM            │
│       ↓                                             │
│  2. عند أي تغيير → notifyParentResize()           │
│       ↓                                             │
│  3. postMessage({ type: 'resize', height })        │
│       ↓                                             │
└─────────────────────────────────────────────────────┘
                      ↓
                      ↓ window.postMessage
                      ↓
┌─────────────────────────────────────────────────────┐
│                 index.html (parent)                 │
│                                                     │
│  4. window.addEventListener('message')              │
│       ↓                                             │
│  5. if (event.data.type === 'resize')              │
│       ↓                                             │
│  6. iframe.style.height = event.data.height        │
│       ↓                                             │
│  ✅ iframe يتحدث تلقائياً!                         │
└─────────────────────────────────────────────────────┘
```

## مزايا الحل (Benefits)

1. **أداء عالي** ⚡
   - استخدام `requestAnimationFrame` لتحديث سلس
   - لا توجد polling أو setInterval
   - التحديث يحدث فقط عند الحاجة

2. **دقة عالية** 🎯
   - `MutationObserver` يكتشف جميع تغييرات DOM
   - التحديث فوري بعد كل تغيير
   - لا توجد فترات تأخير

3. **آمن** 🔒
   - استخدام `postMessage` API القياسي
   - try/catch لتجنب الأخطاء
   - fallback behavior إذا لم يتوفر parent

4. **لا يؤثر على الأداء** 🚀
   - لا استخدام لـ setInterval
   - التحديث فقط عند الحاجة
   - استخدام `requestAnimationFrame` للتحديثات المنظمة

## النتيجة (Result)

الآن iframe يتحدث تلقائياً في جميع الحالات:

| الحالة | قبل | بعد |
|--------|-----|-----|
| **تحميل أولي** | ✅ يعمل | ✅ يعمل |
| **تحديث Socket** | ❌ لا يعمل | ✅ يعمل |
| **تغيير التصنيف** | ❌ لا يعمل | ✅ يعمل |
| **إضافة/حذف عناصر** | ❌ لا يعمل | ✅ يعمل |

## ملاحظات تقنية (Technical Notes)

### لماذا MutationObserver؟

```javascript
// ❌ الطريقة القديمة - استهلاك كبير للموارد
setInterval(resizeRankingFrame, 1000);

// ✅ الطريقة الجديدة - تحديث فقط عند التغيير
const observer = new MutationObserver(notifyParentResize);
observer.observe(document.body, {
    childList: true,
    subtree: true
});
```

### لماذا postMessage؟

```javascript
// ❌ لا يعمل - CORS وأمان المتصفح
parent.getElementById('ranking-frame').style.height = ...

// ✅ يعمل - API قياسي وآمن
parent.postMessage({ type: 'resize', height: 500 }, '*');
```

### لماذا requestAnimationFrame؟

```javascript
// ❌ قد يسبب تحديثات متعددة في نفس الإطار
notifyParentResize();

// ✅ تحديث مرة واحدة في الإطار التالي
requestAnimationFrame(notifyParentResize);
```

## الملفات المعدلة (Modified Files)

1. **[frontend/public/ran.html](frontend/public/ran.html)**
   - إضافة `notifyParentResize()` function
   - إضافة `MutationObserver`
   - تحديث `updateRankingDisplay()`
   - تحديث `socket.on("update")`

2. **[frontend/public/index.html](frontend/public/index.html)**
   - إضافة `window.addEventListener('message')`
   - معالجة رسائل تغيير الحجم

---

**التاريخ**: 2025-10-18
**الحالة**: ✅ تم الإصلاح بنجاح
