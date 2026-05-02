#!/bin/bash
# =================================================================
# سكربت تحديث الجزء الأول: إضافة صفحة إنشاء المنتج + تحسين التنقل
# =================================================================

echo "🔍 التحقق من وجود الملفات الأساسية..."
if [ ! -f "app.js" ] || [ ! -f "style.css" ] || [ ! -f "merchant-store-mgmt.html" ]; then
    echo "❌ يرجى تشغيل هذا السكربت داخل مجلد المشروع حيث توجد ملفات app.js, style.css, merchant-store-mgmt.html"
    exit 1
fi

echo "📝 1. إنشاء صفحة إضافة المنتج (add-product.html)..."
cat << 'HTML_EOF' > add-product.html
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>إضافة منتج | لوحة التاجر</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Tajawal:wght@400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="style.css">
</head>
<body class="add-product-page">
    <header class="top-bar">
        <button class="btn-back" onclick="window.location.href='merchant-store-mgmt.html'">
            <i class="bi bi-arrow-right"></i> رجوع
        </button>
        <h1>إضافة منتج جديد</h1>
        <div></div>
    </header>

    <main class="container">
        <!-- معاينة البطاقة -->
        <section class="preview-section">
            <div class="preview-card" id="previewCard">
                <div class="preview-image-wrapper">
                    <img id="previewImg" src="https://placehold.co/400x400/e2e8f0/94a3b8?text=صورة+المنتج" alt="معاينة المنتج">
                </div>
                <div class="preview-info">
                    <h3 id="previewName">اسم المنتج</h3>
                    <p id="previewPrice">0.00 ر.س</p>
                </div>
            </div>
        </section>

        <!-- نموذج الإدخال -->
        <form id="productForm" class="product-form">
            <div class="form-group">
                <label for="productImage">صورة المنتج</label>
                <div class="file-upload-wrapper">
                    <input type="file" id="productImage" accept="image/*">
                    <label for="productImage" class="upload-label"><i class="bi bi-cloud-arrow-up"></i> اختيار صورة</label>
                </div>
            </div>

            <div class="form-group">
                <label for="productName">اسم المنتج</label>
                <input type="text" id="productName" placeholder="مثال: سماعات لاسلكية" required>
            </div>

            <div class="form-group">
                <label for="productPrice">السعر (ر.س)</label>
                <input type="number" id="productPrice" placeholder="0.00" step="0.01" min="0" required>
            </div>

            <div class="form-row">
                <div class="form-group half">
                    <label for="productColor">لون البطاقة</label>
                    <input type="color" id="productColor" value="#ffffff">
                </div>
                <div class="form-group half">
                    <label for="productCategory">التصنيف</label>
                    <select id="productCategory">
                        <option value="">اختر التصنيف</option>
                        <option value="electronics">إلكترونيات</option>
                        <option value="clothing">ملابس</option>
                        <option value="home">أدوات منزلية</option>
                        <option value="personal">عناية شخصية</option>
                        <option value="food">مواد غذائية</option>
                        <option value="other">أخرى</option>
                    </select>
                </div>
            </div>

            <div class="form-group">
                <label for="productStock">الكمية المتاحة في المخزن</label>
                <input type="number" id="productStock" placeholder="مثال: 50" min="0" required>
            </div>

            <button type="submit" class="btn-primary full-width">
                <i class="bi bi-plus-lg"></i> أضف المنتج
            </button>
        </form>
    </main>

    <!-- إشعار النجاح -->
    <div id="toast" class="toast hidden">
        <i class="bi bi-check-circle-fill"></i>
        <span>تم إضافة المنتج بنجاح!</span>
    </div>

    <script src="app.js"></script>
</body>
</html>
HTML_EOF

echo "🔗 2. تحديث رابط إضافة المنتج في لوحة التحكم..."
# استبدال onclick برابط href مع الحفاظ على باقي الملف
perl -pi -e 's|onclick="alert\(.*?إضافة منتج.*?\)"|href="add-product.html"|g' merchant-store-mgmt.html 2>/dev/null || \
sed -i.bak 's|onclick="alert(.*إضافة منتج.*)"|href="add-product.html"|g' merchant-store-mgmt.html

echo "🎨 3. إلحاق تنسيقات Mobile-First و Toast..."
cat << 'CSS_EOF' >> style.css

/* === Add Product Page & Preview Card === */
.add-product-page .container { padding: 1.5rem 1rem; max-width: 600px; margin: 0 auto; }
.preview-section { margin-bottom: 2rem; text-align: center; }
.preview-card { width: 100%; max-width: 280px; margin: 0 auto; background: #ffffff; border-radius: var(--radius-lg); box-shadow: var(--shadow); overflow: hidden; transition: background-color 0.3s ease, box-shadow 0.3s ease; border: 1px solid var(--border); }
.preview-image-wrapper { width: 100%; aspect-ratio: 1/1; overflow: hidden; background: #f1f5f9; display: flex; align-items: center; justify-content: center; }
.preview-image-wrapper img { width: 100%; height: 100%; object-fit: cover; display: block; }
.preview-info { padding: 1rem; text-align: right; }
.preview-info h3 { font-size: 1.05rem; margin: 0 0 0.4rem 0; color: var(--text); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; font-weight: 600; }
.preview-info p { font-size: 1.15rem; font-weight: 700; color: var(--primary); margin: 0; }

.product-form { display: flex; flex-direction: column; gap: 1.2rem; background: var(--card-bg); padding: 1.5rem; border-radius: var(--radius-lg); box-shadow: var(--shadow); }
.form-row { display: flex; flex-direction: column; gap: 1.2rem; }
@media (min-width: 640px) { .form-row { flex-direction: row; } }
.half { flex: 1; }

.file-upload-wrapper { position: relative; }
.file-upload-wrapper input[type="file"] { position: absolute; opacity: 0; width: 100%; height: 100%; cursor: pointer; }
.upload-label { display: flex; align-items: center; justify-content: center; gap: 0.5rem; padding: 1rem; border: 2px dashed var(--border); border-radius: var(--radius-md); background: #f8fafc; cursor: pointer; transition: all 0.2s; font-weight: 500; color: var(--text-light); user-select: none; }
.file-upload-wrapper:hover .upload-label, .file-upload-wrapper input:focus + .upload-label { border-color: var(--primary); background: #eff6ff; color: var(--primary); }

input[type="color"] { width: 100%; height: 48px; padding: 4px; border: 1px solid var(--border); border-radius: var(--radius-sm); cursor: pointer; background: white; }
select, input[type="text"], input[type="number"] { width: 100%; padding: 0.9rem; border: 1px solid var(--border); border-radius: var(--radius-md); font-family: inherit; font-size: 1rem; background: white; transition: all 0.2s; -webkit-appearance: none; appearance: none; }
select:focus, input:focus { outline: none; border-color: var(--primary); box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.15); }

/* Toast Notification */
.toast { position: fixed; bottom: 2rem; left: 50%; transform: translateX(-50%) translateY(120%); background: #10b981; color: white; padding: 0.85rem 1.5rem; border-radius: var(--radius-md); box-shadow: var(--shadow-hover); display: flex; align-items: center; gap: 0.6rem; font-weight: 500; z-index: 1000; transition: transform 0.4s cubic-bezier(0.34, 1.56, 0.64, 1), opacity 0.3s; opacity: 0; pointer-events: none; }
.toast.show { transform: translateX(-50%) translateY(0); opacity: 1; }
.toast.hidden { display: none; }
.toast i { font-size: 1.25rem; }
CSS_EOF

echo "⚙️ 4. إلحاق منطق المعاينة الحية و Toast..."
cat << 'JS_EOF' >> app.js

// === Add Product Page Logic ===
document.addEventListener('DOMContentLoaded', () => {
    const form = document.getElementById('productForm');
    if (form) {
        const imgInput = document.getElementById('productImage');
        const nameInput = document.getElementById('productName');
        const priceInput = document.getElementById('productPrice');
        const colorInput = document.getElementById('productColor');
        const previewImg = document.getElementById('previewImg');
        const previewName = document.getElementById('previewName');
        const previewPrice = document.getElementById('previewPrice');
        const previewCard = document.getElementById('previewCard');
        const toast = document.getElementById('toast');

        // معاينة الصورة فور الاختيار
        imgInput.addEventListener('change', (e) => {
            const file = e.target.files[0];
            if (file) {
                previewImg.src = URL.createObjectURL(file);
            } else {
                previewImg.src = "https://placehold.co/400x400/e2e8f0/94a3b8?text=صورة+المنتج";
            }
        });

        // تحديث لحظي للاسم والسعر واللون
        nameInput.addEventListener('input', () => previewName.textContent = nameInput.value.trim() || 'اسم المنتج');
        priceInput.addEventListener('input', () => {
            const val = parseFloat(priceInput.value);
            previewPrice.textContent = (!isNaN(val) ? val.toFixed(2) : '0.00') + ' ر.س';
        });
        colorInput.addEventListener('input', () => previewCard.style.backgroundColor = colorInput.value);

        // معالجة الإرسال
        form.addEventListener('submit', (e) => {
            e.preventDefault();
            
            // إظهار Toast
            toast.classList.remove('hidden');
            // تأخير بسيط لتفعيل Transition
            requestAnimationFrame(() => toast.classList.add('show'));
            
            setTimeout(() => {
                toast.classList.remove('show');
                setTimeout(() => toast.classList.add('hidden'), 400);
            }, 3000);

            // تفريغ الحقول وإعادة المعاينة للوضع الافتراضي
            form.reset();
            previewImg.src = "https://placehold.co/400x400/e2e8f0/94a3b8?text=صورة+المنتج";
            previewName.textContent = 'اسم المنتج';
            previewPrice.textContent = '0.00 ر.س';
            previewCard.style.backgroundColor = '#ffffff';
        });
    }
});
JS_EOF

# تنظيف ملفات النسخ الاحتياطي التي قد ينشئها sed
rm -f merchant-store-mgmt.html.bak 2>/dev/null

echo "✅ اكتمل التحديث بنجاح!"
echo "📂 الملفات المحدثة:"
echo "   ├── add-product.html       ← صفحة جديدة"
echo "   ├── merchant-store-mgmt.html ← تم ربط زر الإضافة"
echo "   ├── style.css              ← تمت إضافة تنسيقات الموبايل و Toast"
echo "   └── app.js                 ← تمت إضافة منطق المعاينة الحية"
echo ""
echo "💡 افتح index.html أو merchant-store-mgmt.html في المتصفح للتجربة."
