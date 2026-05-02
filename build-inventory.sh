#!/bin/bash
# =================================================================
# سكربت بناء نظام المخزون المتقدم (Mobile-First + LocalStorage + UI كامل)
# =================================================================

echo "📦 جاري بناء نظام المخزون وتحديث الواجهات..."

if [ ! -f "app.js" ] || [ ! -f "style.css" ] || [ ! -f "merchant-store-mgmt.html" ]; then
    echo "❌ يرجى تشغيل هذا السكربت داخل مجلد المشروع الرئيسي."
    exit 1
fi

# 1️⃣ صفحة المخزون الرئيسية
cat << 'EOF' > inventory.html
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>إدارة المخزون | منصة التجارة</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Tajawal:wght@400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="style.css">
</head>
<body class="inventory-page">
    <header class="top-bar">
        <button class="btn-back" onclick="window.location.href='merchant-store-mgmt.html'"><i class="bi bi-arrow-right"></i> رجوع</button>
        <h1>إدارة المخزون</h1>
        <div></div>
    </header>

    <main class="container">
        <div class="top-actions">
            <button class="btn-action" onclick="openModal('categoryModal')"><i class="bi bi-plus-lg"></i> إضافة صنف</button>
            <button class="btn-action" onclick="openModal('productModal')"><i class="bi bi-box-seam"></i> إضافة منتج</button>
        </div>

        <!-- شريط الأصناف المثبت -->
        <div class="category-scroll-wrapper sticky-header">
            <div id="categoryBar" class="category-bar">
                <button class="cat-chip active" data-cat="all">الكل</button>
                <!-- سيتم ملؤها ديناميكياً -->
            </div>
        </div>

        <!-- جدول المخزون -->
        <div class="table-wrapper">
            <table id="inventoryTable">
                <thead>
                    <tr>
                        <th class="mobile-hide desktop-show"><input type="checkbox" id="selectAll"></th>
                        <th>اسم المنتج</th>
                        <th class="desktop-only">الكود</th>
                        <th>الكمية المباعة</th>
                        <th class="desktop-only">الحد الأدنى</th>
                        <th class="desktop-only">إلغاء التفعيل</th>
                        <th>إجراءات</th>
                    </tr>
                </thead>
                <tbody id="inventoryBody">
                    <!-- سيتم ملؤه ديناميكياً -->
                </tbody>
            </table>
        </div>
    </main>

    <!-- شريط الحذف المتعدد العائم -->
    <div id="floatingAction" class="floating-bar hidden">
        <span id="selectedCount">0 عناصر محددة</span>
        <button class="btn-danger" onclick="confirmMultiDelete()"><i class="bi bi-trash3"></i> حذف المحدد</button>
        <button class="btn-secondary" onclick="clearSelection()"><i class="bi bi-x-lg"></i> إلغاء</button>
    </div>

    <!-- ===== المودالات ===== -->
    <!-- مودال إضافة/تعديل تصنيف -->
    <div id="categoryModal" class="modal">
        <div class="modal-content">
            <div class="modal-header"><h2>إضافة صنف جديد</h2><button class="modal-close" onclick="closeModal('categoryModal')"><i class="bi bi-x"></i></button></div>
            <form id="categoryForm" class="modal-form">
                <input type="text" id="catName" placeholder="اسم الصنف" required>
                <button type="submit" class="btn-primary full-width">حفظ الصنف</button>
            </form>
        </div>
    </div>

    <!-- مودال إضافة/تعديل منتج -->
    <div id="productModal" class="modal">
        <div class="modal-content modal-lg">
            <div class="modal-header"><h2 id="productModalTitle">إضافة منتج</h2><button class="modal-close" onclick="closeModal('productModal')"><i class="bi bi-x"></i></button></div>
            <form id="productForm" class="modal-form">
                <input type="hidden" id="prodId">
                <div class="form-group"><label>صورة المنتج</label><div class="file-upload-wrapper"><input type="file" id="prodImage" accept="image/*"><label for="prodImage" class="upload-label"><i class="bi bi-cloud-arrow-up"></i> اختيار صورة</label></div><img id="prodImgPreview" class="img-thumb hidden"></div>
                <div class="form-row"><div class="form-group half"><label>اسم المنتج</label><input type="text" id="prodName" required></div><div class="form-group half"><label>الكود</label><input type="text" id="prodCode" required></div></div>
                <div class="form-row"><div class="form-group half"><label>السعر</label><input type="number" id="prodPrice" step="0.01" required></div><div class="form-group half"><label>التصنيف</label><select id="prodCat" required></select></div></div>
                <div class="form-row"><div class="form-group half"><label>الكمية</label><input type="number" id="prodStock" required></div><div class="form-group half"><label>الحد الأدنى</label><input type="number" id="prodMin" required></div></div>
                <div class="form-group"><label>لون البطاقة</label><div id="colorPickerWrapper" class="color-picker-modern"></div></div>
                <button type="submit" class="btn-primary full-width">حفظ المنتج</button>
            </form>
        </div>
    </div>

    <!-- مودال تقرير سريع -->
    <div id="reportModal" class="modal">
        <div class="modal-content">
            <div class="modal-header"><h2>تقرير سريع</h2><button class="modal-close" onclick="closeModal('reportModal')"><i class="bi bi-x"></i></button></div>
            <div id="reportContent" class="report-grid"></div>
        </div>
    </div>

    <!-- مودال حذف التصنيف (3 خيارات) -->
    <div id="deleteCatModal" class="modal">
        <div class="modal-content">
            <div class="modal-header"><h2>حذف التصنيف</h2><button class="modal-close" onclick="closeModal('deleteCatModal')"><i class="bi bi-x"></i></button></div>
            <form id="deleteCatForm" class="modal-form">
                <p>كيف تريد التعامل مع المنتجات التابعة؟</p>
                <label class="radio-opt"><input type="radio" name="catAction" value="delete" checked> حذف التصنيف ومنتجاته نهائياً</label>
                <label class="radio-opt"><input type="radio" name="catAction" value="uncategorized"> إنشاء "غير مصنف" ونقلها</label>
                <label class="radio-opt"><input type="radio" name="catAction" value="transfer"> نقل إلى تصنيف آخر موجود</label>
                <div class="form-group hidden" id="transferCatGroup"><label>اختر التصنيف الجديد</label><select id="transferCatTarget"></select></div>
                <button type="submit" class="btn-danger full-width">تأكيد الحذف</button>
            </form>
        </div>
    </div>

    <!-- مودال تأكيد الحذف المتعدد -->
    <div id="multiDeleteModal" class="modal">
        <div class="modal-content">
            <div class="modal-header"><h2>تأكيد الحذف</h2><button class="modal-close" onclick="closeModal('multiDeleteModal')"><i class="bi bi-x"></i></button></div>
            <p>هل أنت متأكد من حذف <span id="delCount" class="fw-bold">0</span> منتجات؟ لا يمكن التراجع.</p>
            <div class="modal-actions">
                <button class="btn-secondary full-width" onclick="closeModal('multiDeleteModal')">إلغاء</button>
                <button class="btn-danger full-width" onclick="executeMultiDelete()">نعم، احذف</button>
            </div>
        </div>
    </div>

    <div id="toastContainer"></div>
    <script src="app.js"></script>
</body>
</html>
EOF

# 2️⃣ تنسيقات CSS الكاملة
cat << 'EOF' > style.css
:root {
    --primary: #2563eb; --primary-dark: #1d4ed8; --bg: #f8fafc; --card: #ffffff;
    --text: #0f172a; --text-light: #64748b; --border: #e2e8f0;
    --radius-lg: 20px; --radius-md: 14px; --radius-sm: 10px;
    --shadow: 0 4px 12px rgba(0,0,0,0.08); --green: #10b981; --orange: #f59e0b; --red: #ef4444;
}
* { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: 'Tajawal', sans-serif; background: var(--bg); color: var(--text); min-height: 100vh; direction: rtl; }
.container { padding: 1rem; max-width: 1000px; margin: 0 auto; padding-bottom: 80px; }
.top-bar { display: flex; align-items: center; justify-content: space-between; padding: 1rem; background: var(--card); box-shadow: 0 2px 8px rgba(0,0,0,0.05); position: sticky; top: 0; z-index: 50; }
.btn-back, .btn-action { padding: 0.6rem 1rem; border: 1px solid var(--border); border-radius: var(--radius-sm); background: transparent; cursor: pointer; display: flex; align-items: center; gap: 0.4rem; font-family: inherit; transition: 0.2s; }
.btn-back:hover, .btn-action:hover { background: #f1f5f9; border-color: var(--primary); color: var(--primary); }
.top-actions { display: flex; gap: 0.8rem; margin: 1rem 0; flex-wrap: wrap; }

/* شريط الأصناف المثبت */
.category-scroll-wrapper { position: sticky; top: 65px; z-index: 40; background: var(--bg); padding: 0.5rem 0; border-bottom: 1px solid var(--border); }
.category-bar { display: flex; gap: 0.8rem; overflow-x: auto; padding: 0.5rem 1rem; scrollbar-width: none; -ms-overflow-style: none; }
.category-bar::-webkit-scrollbar { display: none; }
.cat-chip { flex: 0 0 auto; padding: 0.5rem 1.2rem; border-radius: 50px; border: 1px solid var(--border); background: var(--card); cursor: pointer; font-weight: 500; transition: 0.2s; }
.cat-chip.active { background: var(--primary); color: white; border-color: var(--primary); }

/* الجدول المتجاوب */
.table-wrapper { background: var(--card); border-radius: var(--radius-md); box-shadow: var(--shadow); overflow-x: auto; }
table { width: 100%; border-collapse: collapse; min-width: 500px; }
th, td { padding: 0.9rem 0.6rem; text-align: right; border-bottom: 1px solid var(--border); font-size: 0.95rem; }
th { background: #f8fafc; font-weight: 600; color: var(--text-light); position: sticky; top: 0; }
.mobile-hide { display: none; } .desktop-only { display: none; }
@media (min-width: 768px) { .mobile-hide { display: table-cell; } .desktop-only { display: table-cell; } }

/* حالة المخزون */
.stock-val { padding: 0.3rem 0.6rem; border-radius: var(--radius-sm); display: inline-block; font-weight: 600; }
.stock-green { background: rgba(16,185,129,0.15); color: var(--green); border: 1px solid var(--green); }
.stock-orange { background: rgba(245,158,11,0.15); color: var(--orange); border: 1px solid var(--orange); }
.stock-red { background: rgba(239,68,68,0.15); color: var(--red); border: 1px solid var(--red); }

/* أزرار وإجراءات */
.btn-icon { background: transparent; border: none; cursor: pointer; font-size: 1.2rem; color: var(--text-light); padding: 0.4rem; }
.btn-icon:hover { color: var(--primary); }
.toggle-switch { position: relative; width: 44px; height: 24px; display: inline-block; }
.toggle-switch input { opacity: 0; width: 0; height: 0; }
.slider { position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0; background: #cbd5e1; border-radius: 24px; transition: 0.3s; }
.slider:before { position: absolute; content: ""; height: 18px; width: 18px; left: 3px; bottom: 3px; background: white; border-radius: 50%; transition: 0.3s; }
input:checked + .slider { background: var(--primary); }
input:checked + .slider:before { transform: translateX(20px); }

/* شريط الحذف العائم */
.floating-bar { position: fixed; bottom: 0; left: 0; right: 0; background: rgba(255,255,255,0.95); backdrop-filter: blur(8px); padding: 1rem; display: flex; align-items: center; justify-content: space-between; box-shadow: 0 -4px 12px rgba(0,0,0,0.1); transform: translateY(110%); transition: 0.4s cubic-bezier(0.34,1.56,0.64,1); z-index: 100; border-top: 1px solid var(--border); }
.floating-bar.show { transform: translateY(0); }
.btn-danger { background: var(--red); color: white; padding: 0.7rem 1.2rem; border: none; border-radius: var(--radius-sm); cursor: pointer; font-family: inherit; display: flex; align-items: center; gap: 0.4rem; }
.btn-secondary { background: #e2e8f0; color: var(--text); padding: 0.7rem 1.2rem; border: none; border-radius: var(--radius-sm); cursor: pointer; font-family: inherit; display: flex; align-items: center; gap: 0.4rem; }
.hidden { display: none !important; }

/* مودالات */
.modal { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(15,23,42,0.4); backdrop-filter: blur(4px); display: flex; align-items: center; justify-content: center; opacity: 0; pointer-events: none; transition: 0.2s; z-index: 200; padding: 1rem; }
.modal.active { opacity: 1; pointer-events: auto; }
.modal-content { background: var(--card); padding: 1.5rem; border-radius: var(--radius-lg); width: 100%; max-width: 500px; max-height: 90vh; overflow-y: auto; transform: scale(0.95); transition: 0.3s; }
.modal.active .modal-content { transform: scale(1); }
.modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; }
.modal-close { background: transparent; border: none; font-size: 1.5rem; cursor: pointer; }
.modal-form { display: flex; flex-direction: column; gap: 1rem; }
.form-row { display: flex; flex-direction: column; gap: 1rem; }
@media (min-width: 640px) { .form-row { flex-direction: row; } }
.half { flex: 1; }
input, select { width: 100%; padding: 0.9rem; border: 1px solid var(--border); border-radius: var(--radius-sm); font-family: inherit; font-size: 1rem; background: white; }
input:focus, select:focus { outline: none; border-color: var(--primary); box-shadow: 0 0 0 3px rgba(37,99,235,0.15); }
.upload-label { display: flex; align-items: center; justify-content: center; gap: 0.5rem; padding: 0.8rem; border: 2px dashed var(--border); border-radius: var(--radius-sm); background: #f8fafc; cursor: pointer; color: var(--text-light); }
.file-upload-wrapper input { position: absolute; opacity: 0; width: 100%; height: 100%; cursor: pointer; }
.img-thumb { width: 100%; height: 120px; object-fit: cover; border-radius: var(--radius-sm); margin-top: 0.5rem; }

/* منتقي الألوان الحديث */
.color-picker-modern { display: flex; gap: 0.8rem; align-items: center; flex-wrap: wrap; }
.color-dot { width: 36px; height: 36px; border-radius: 50%; border: 3px solid transparent; cursor: pointer; transition: 0.2s; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
.color-dot:hover, .color-dot.active { transform: scale(1.15); border-color: var(--primary); box-shadow: 0 0 0 2px white, 0 0 0 4px var(--primary); }
#customColorInput { width: 40px; height: 40px; padding: 0; border: none; border-radius: 50%; cursor: pointer; opacity: 0.8; }
#customColorInput::-webkit-color-swatch-wrapper { padding: 0; }
#customColorInput::-webkit-color-swatch { border: none; border-radius: 50%; border: 2px solid var(--border); }

/* تقرير سريع */
.report-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 0.8rem; margin-top: 0.5rem; }
.report-item { background: #f8fafc; padding: 0.8rem; border-radius: var(--radius-sm); }
.report-label { font-size: 0.85rem; color: var(--text-light); display: block; margin-bottom: 0.2rem; }
.report-value { font-weight: 600; font-size: 1.05rem; }

/* Toast */
#toastContainer { position: fixed; bottom: 1.5rem; left: 50%; transform: translateX(-50%); z-index: 300; display: flex; flex-direction: column; gap: 0.5rem; align-items: center; }
.toast { background: white; padding: 0.9rem 1.4rem; border-radius: var(--radius-md); box-shadow: var(--shadow); display: flex; align-items: center; gap: 0.6rem; font-weight: 500; animation: slideUp 0.3s ease, fadeOut 0.4s ease 2.8s forwards; border-left: 4px solid var(--primary); }
.toast.success { border-color: var(--green); } .toast.warning { border-color: var(--orange); } .toast.error { border-color: var(--red); }
@keyframes slideUp { from { transform: translateY(20px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
@keyframes fadeOut { to { opacity: 0; transform: translateY(10px); } }
EOF

# 3️⃣ منطق JavaScript الكامل
cat << 'EOF' > app.js
// === قاعدة البيانات الوهمية (LocalStorage) ===
const DB_KEY = 'ecommerce_inventory_v1';
let db = JSON.parse(localStorage.getItem(DB_KEY)) || null;

function seedData() {
    db = {
        categories: [
            { id: 'c1', name: 'إلكترونيات' },
            { id: 'c2', name: 'ملابس' },
            { id: 'c3', name: 'أدوات منزلية' }
        ],
        products: [
            { id: 'p1', code: 'EL-001', name: 'سماعات لاسلكية', price: 250, catId: 'c1', stock: 50, min: 10, sold: 15, active: true, color: '#ffffff', image: '' },
            { id: 'p2', code: 'CL-002', name: 'قميص قطني', price: 89, catId: 'c2', stock: 5, min: 15, sold: 40, active: true, color: '#e0f2fe', image: '' },
            { id: 'p3', code: 'HM-003', name: 'محمصة خبز', price: 199, catId: 'c3', stock: 0, min: 5, sold: 20, active: false, color: '#fef3c7', image: '' }
        ]
    };
    localStorage.setItem(DB_KEY, JSON.stringify(db));
}

if (!db) seedData();
let state = { activeCat: 'all', selected: new Set(), editingProdId: null, deletingCatId: null };

// === دوال مساعدة ===
const $ = sel => document.querySelector(sel);
const $$ = sel => document.querySelectorAll(sel);
const save = () => localStorage.setItem(DB_KEY, JSON.stringify(db));
const toast = (msg, type = 'success') => {
    const t = document.createElement('div');
    t.className = `toast ${type}`;
    t.innerHTML = `<i class="bi bi-${type === 'success' ? 'check-circle' : type === 'warning' ? 'exclamation-triangle' : 'info-circle'}"></i> ${msg}`;
    $('#toastContainer').appendChild(t);
    setTimeout(() => t.remove(), 3200);
};
const openModal = id => $(`#${id}`).classList.add('active');
const closeModal = id => $(`#${id}`).classList.remove('active');

// === منتقي الألوان الحديث ===
const presetColors = ['#ffffff', '#f8fafc', '#e0f2fe', '#dcfce7', '#fef3c7', '#f3e8ff'];
let selectedColor = '#ffffff';

function initColorPicker() {
    const wrap = $('#colorPickerWrapper');
    if(!wrap) return;
    wrap.innerHTML = presetColors.map(c => `<div class="color-dot ${c === selectedColor ? 'active' : ''}" style="background:${c}" data-c="${c}"></div>`).join('') + 
    `<input type="color" id="customColorInput" value="${selectedColor}" title="لون مخصص">`;
    wrap.addEventListener('click', e => {
        const dot = e.target.closest('.color-dot');
        if(dot) { selectedColor = dot.dataset.c; $$('.color-dot').forEach(d => d.classList.remove('active')); dot.classList.add('active'); }
    });
    $('#customColorInput')?.addEventListener('input', e => { selectedColor = e.target.value; $$('.color-dot').forEach(d => d.classList.remove('active')); });
}

// === عرض الجدول ===
function renderTable() {
    const tbody = $('#inventoryBody');
    if(!tbody) return;
    const filtered = state.activeCat === 'all' ? db.products : db.products.filter(p => p.catId === state.activeCat);
    
    tbody.innerHTML = filtered.map(p => {
        const statusClass = p.stock === 0 ? 'stock-red' : (p.stock <= p.min ? 'stock-orange' : 'stock-green');
        const checked = state.selected.has(p.id) ? 'checked' : '';
        const op = p.active ? '' : 'opacity:0.5;';
        return `<tr style="${op}">
            <td class="mobile-hide"><input type="checkbox" class="prod-select" data-id="${p.id}" ${checked}></td>
            <td>${p.name}</td>
            <td class="desktop-only"><code>${p.code}</code></td>
            <td>${p.sold}</td>
            <td class="desktop-only"><span class="stock-val ${statusClass}">${p.stock} / ${p.min}</span></td>
            <td class="desktop-only"><label class="toggle-switch"><input type="checkbox" ${p.active?'checked':''} onchange="toggleProduct('${p.id}')"><span class="slider"></span></label></td>
            <td class="mobile-hide">
                <button class="btn-icon" onclick="showReport('${p.id}')" title="تقرير"><i class="bi bi-bar-chart-line"></i></button>
                <button class="btn-icon" onclick="openEdit('${p.id}')" title="تعديل"><i class="bi bi-pencil"></i></button>
                <button class="btn-icon" onclick="deleteSingle('${p.id}')" title="حذف" style="color:var(--red)"><i class="bi bi-trash"></i></button>
            </td>
            <td class="desktop-only" style="display:none;">
                <!-- Mobile Menu -->
                <div class="mobile-actions">
                    <button class="btn-icon" onclick="showReport('${p.id}')"><i class="bi bi-three-dots-vertical"></i></button>
                </div>
            </td>
        </tr>`;
    }).join('');
    
    // Mobile menu popup logic handled separately or simplified for demo
    $('#selectAll').onchange = e => {
        document.querySelectorAll('.prod-select').forEach(cb => {
            cb.checked = e.target.checked;
            state.selected.add(cb.dataset.id);
        });
        if(!e.target.checked) state.selected.clear();
        updateFloatingBar();
    };
    
    $$(`.prod-select`).forEach(cb => {
        cb.onchange = e => {
            e.target.checked ? state.selected.add(cb.dataset.id) : state.selected.delete(cb.dataset.id);
            updateFloatingBar();
        };
    });
}

// === شريط الأصناف ===
function renderCategories() {
    const bar = $('#categoryBar');
    bar.innerHTML = `<button class="cat-chip ${state.activeCat==='all'?'active':''}" data-cat="all">الكل</button>` +
        db.categories.map(c => `<button class="cat-chip ${state.activeCat===c.id?'active':''}" data-cat="${c.id}">${c.name}</button>`).join('');
    bar.querySelectorAll('.cat-chip').forEach(btn => btn.onclick = () => { state.activeCat = btn.dataset.cat; renderCategories(); renderTable(); clearSelection(); });
}

// === إدارة المنتجات ===
window.openEdit = id => {
    const p = db.products.find(x => x.id === id);
    state.editingProdId = id;
    $('#productModalTitle').textContent = 'تعديل منتج';
    $('#prodId').value = p.id; $('#prodName').value = p.name; $('#prodCode').value = p.code; $('#prodPrice').value = p.price; $('#prodStock').value = p.stock; $('#prodMin').value = p.min;
    const catSel = $('#prodCat'); catSel.innerHTML = db.categories.map(c => `<option value="${c.id}" ${c.id===p.catId?'selected':''}>${c.name}</option>`).join('');
    if(p.image) { $('#prodImgPreview').src = p.image; $('#prodImgPreview').classList.remove('hidden'); }
    selectedColor = p.color || '#ffffff'; initColorPicker(); openModal('productModal');
};

$('#productForm').onsubmit = e => {
    e.preventDefault();
    const file = $('#prodImage').files[0];
    const handleSave = imgBase64 => {
        const newProd = {
            id: state.editingProdId || 'p' + Date.now(),
            name: $('#prodName').value, code: $('#prodCode').value, price: parseFloat($('#prodPrice').value),
            stock: parseInt($('#prodStock').value), min: parseInt($('#prodMin').value),
            catId: $('#prodCat').value, color: selectedColor, sold: state.editingProdId ? db.products.find(p=>p.id===state.editingProdId).sold : 0,
            active: true, image: imgBase64 || (state.editingProdId ? db.products.find(p=>p.id===state.editingProdId).image : '')
        };
        if(state.editingProdId) { const idx = db.products.findIndex(p=>p.id===state.editingProdId); db.products[idx] = newProd; } else db.products.push(newProd);
        save(); closeModal('productModal'); toast('تم حفظ المنتج بنجاح'); renderTable(); state.editingProdId = null; $('#productForm').reset(); $('#prodImgPreview').classList.add('hidden');
    };
    if(file) { const reader = new FileReader(); reader.onload = e => handleSave(e.target.result); reader.readAsDataURL(file); }
    else handleSave(null);
};

window.toggleProduct = id => { const p = db.products.find(x=>x.id===id); p.active = !p.active; save(); renderTable(); toast(p.active ? 'تم تفعيل المنتج' : 'تم إلغاء التفعيل', 'warning'); };

// === إدارة التصنيفات ===
$('#categoryForm').onsubmit = e => { e.preventDefault(); db.categories.push({ id: 'c'+Date.now(), name: $('#catName').value }); save(); renderCategories(); closeModal('categoryModal'); toast('تم إضافة الصنف'); };

$('#deleteCatActionBtn')?.addEventListener('click', () => openModal('deleteCatModal'));
window.confirmDeleteCat = id => { state.deletingCatId = id; $('#transferCatTarget').innerHTML = db.categories.filter(c=>c.id!==id).map(c=>`<option value="${c.id}">${c.name}</option>`).join(''); openModal('deleteCatModal'); };
$('#deleteCatForm').onsubmit = e => {
    e.preventDefault(); const action = document.querySelector('input[name="catAction"]:checked').value;
    const catId = state.deletingCatId;
    const related = db.products.filter(p=>p.catId===catId);
    if(action==='delete') db.products = db.products.filter(p=>p.catId!==catId);
    else if(action==='transfer') { const newCat = $('#transferCatTarget').value; related.forEach(p=>p.catId=newCat); }
    else if(action==='uncategorized') { if(!db.categories.find(c=>c.id==='uncat')) db.categories.push({id:'uncat',name:'غير مصنف'}); related.forEach(p=>p.catId='uncat'); }
    db.categories = db.categories.filter(c=>c.id!==catId); save(); closeModal('deleteCatModal'); toast('تم حذف التصنيف'); renderTable(); renderCategories();
};
$('#transferCatGroup').style.display = 'none';
document.querySelectorAll('input[name="catAction"]').forEach(r => r.onchange = e => $('#transferCatGroup').style.display = e.target.value==='transfer'?'block':'none');

// === تقارير وحذف ===
window.showReport = id => {
    const p = db.products.find(x=>x.id===id); const left = Math.max(0, p.stock - p.min);
    $('#reportContent').innerHTML = `
        <div class="report-item"><span class="report-label">اسم المنتج</span><span class="report-value">${p.name}</span></div>
        <div class="report-item"><span class="report-label">الكود</span><span class="report-value">${p.code}</span></div>
        <div class="report-item"><span class="report-label">سعر الوحدة</span><span class="report-value">${p.price} ر.س</span></div>
        <div class="report-item"><span class="report-label">الكمية الحالية</span><span class="report-value">${p.stock}</span></div>
        <div class="report-item"><span class="report-label">الكمية المباعة</span><span class="report-value">${p.sold}</span></div>
        <div class="report-item"><span class="report-label">الكمية المتبقية</span><span class="report-value">${p.stock}</span></div>
        <div class="report-item"><span class="report-label">إجمالي المبيعات</span><span class="report-value">${(p.sold*p.price).toFixed(2)} ر.س</span></div>
        <div class="report-item"><span class="report-label">الباقي للحد الأدنى</span><span class="report-value">${left >= 0 ? left + ' (آمن)' : left + ' ⚠️'}</span></div>`;
    openModal('reportModal');
};

window.confirmMultiDelete = () => { $('#delCount').textContent = state.selected.size; openModal('multiDeleteModal'); };
window.executeMultiDelete = () => { db.products = db.products.filter(p => !state.selected.has(p.id)); save(); clearSelection(); closeModal('multiDeleteModal'); toast('تم حذف العناصر المحددة', 'success'); renderTable(); };
window.clearSelection = () => { state.selected.clear(); $$(`.prod-select`).forEach(cb => cb.checked = false); $('#selectAll').checked = false; updateFloatingBar(); };
function updateFloatingBar() {
    const bar = $('#floatingAction'); const count = state.selected.size;
    $('#selectedCount').textContent = `${count} عناصر محددة`;
    bar.classList.toggle('show', count > 0);
}

// === تهيئة ===
document.addEventListener('DOMContentLoaded', () => {
    renderCategories(); renderTable(); initColorPicker();
    // ربط زر المخزون في صفحة الإدارة
    const storeBtn = document.querySelector('[data-nav="inventory"]');
    if(storeBtn) storeBtn.onclick = () => window.location.href='inventory.html';
});
EOF

# 4️⃣ تحديث صفحة إضافة المنتج (منتقي الألوان الحديث)
cat << 'EOF' > add-product.html
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
        <button class="btn-back" onclick="window.location.href='merchant-store-mgmt.html'"><i class="bi bi-arrow-right"></i> رجوع</button>
        <h1>إضافة منتج جديد</h1><div></div>
    </header>
    <main class="container">
        <section class="preview-section">
            <div class="preview-card" id="previewCard" style="background:#fff;">
                <div class="preview-image-wrapper"><img id="previewImg" src="https://placehold.co/400x400/e2e8f0/94a3b8?text=صورة+المنتج"></div>
                <div class="preview-info"><h3 id="previewName">اسم المنتج</h3><p id="previewPrice">0.00 ر.س</p></div>
            </div>
        </section>
        <form id="productForm" class="product-form">
            <div class="form-group"><label>صورة المنتج</label><div class="file-upload-wrapper"><input type="file" id="productImage" accept="image/*"><label for="productImage" class="upload-label"><i class="bi bi-cloud-arrow-up"></i> اختيار صورة</label></div></div>
            <div class="form-group"><label>اسم المنتج</label><input type="text" id="productName" placeholder="مثال: سماعات لاسلكية" required></div>
            <div class="form-group"><label>السعر (ر.س)</label><input type="number" id="productPrice" placeholder="0.00" step="0.01" min="0" required></div>
            <div class="form-row">
                <div class="form-group half"><label>لون البطاقة</label><div id="colorPickerWrapper" class="color-picker-modern"></div></div>
                <div class="form-group half"><label>التصنيف</label><select id="productCategory"><option value="">اختر التصنيف</option><option value="electronics">إلكترونيات</option><option value="clothing">ملابس</option><option value="home">أدوات منزلية</option><option value="personal">عناية شخصية</option><option value="food">مواد غذائية</option><option value="other">أخرى</option></select></div>
            </div>
            <div class="form-row">
                <div class="form-group half"><label>الكمية المتاحة</label><input type="number" id="productStock" placeholder="50" min="0" required></div>
                <div class="form-group half"><label>الحد الأدنى للمخزون</label><input type="number" id="productMin" placeholder="10" min="0" required></div>
            </div>
            <button type="submit" class="btn-primary full-width"><i class="bi bi-plus-lg"></i> أضف المنتج</button>
        </form>
    </main>
    <div id="toast" class="toast hidden"><i class="bi bi-check-circle-fill"></i><span>تم إضافة المنتج بنجاح!</span></div>
    <script src="app.js"></script>
    <script>
    // إضافة منطق المعاينة للصفحة الحالية فقط
    document.addEventListener('DOMContentLoaded', () => {
        const form = document.getElementById('productForm');
        if(!form) return;
        const imgInput = document.getElementById('productImage'), nameInput = document.getElementById('productName'), priceInput = document.getElementById('productPrice');
        const previewImg = document.getElementById('previewImg'), previewName = document.getElementById('previewName'), previewPrice = document.getElementById('previewPrice'), previewCard = document.getElementById('previewCard');
        imgInput.onchange = e => previewImg.src = e.target.files[0] ? URL.createObjectURL(e.target.files[0]) : "https://placehold.co/400x400/e2e8f0/94a3b8?text=صورة+المنتج";
        nameInput.oninput = () => previewName.textContent = nameInput.value || 'اسم المنتج';
        priceInput.oninput = () => previewPrice.textContent = (parseFloat(priceInput.value)||0).toFixed(2) + ' ر.س';
        form.onsubmit = e => { e.preventDefault(); const t = document.getElementById('toast'); t.classList.remove('hidden'); requestAnimationFrame(()=>t.classList.add('show')); setTimeout(()=>{t.classList.remove('show'); setTimeout(()=>t.classList.add('hidden'),400); form.reset(); previewImg.src="https://placehold.co/400x400/e2e8f0/94a3b8?text=صورة+المنتج"; previewName.textContent='اسم المنتج'; previewPrice.textContent='0.00 ر.س'; }, 2500); };
    });
    </script>
</body>
</html>
EOF

# 5️⃣ إصلاح رابط المخزون في لوحة التحكم
cat << 'EOF' > merchant-store-mgmt.html
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>إدارة المتجر | منصة التجارة</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Tajawal:wght@400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="style.css">
</head>
<body class="dashboard-page">
    <header class="top-bar"><button class="btn-back" onclick="window.location.href='merchant-dashboard.html'"><i class="bi bi-arrow-right"></i> رجوع</button><h1>إدارة المتجر</h1><div></div></header>
    <main class="mgmt-grid">
        <div class="mgmt-card" onclick="alert('صفحة الطلبات قيد التطوير')"><i class="bi bi-clipboard-check"></i><h3>إدارة الطلبات</h3></div>
        <div class="mgmt-card" onclick="window.location.href='add-product.html'"><i class="bi bi-plus-circle"></i><h3>إضافة منتج</h3></div>
        <div class="mgmt-card" onclick="window.location.href='inventory.html'"><i class="bi bi-box-seam"></i><h3>المخزون</h3></div>
        <div class="mgmt-card" onclick="alert('صفحة التقارير قيد التطوير')"><i class="bi bi-bar-chart-line"></i><h3>التقارير</h3></div>
    </main>
    <script src="app.js"></script>
</body>
</html>
EOF

echo "✅ اكتمل البناء بنجاح!"
echo "📂 الملفات التي تم إنشاؤها/تحديثها:"
echo "   ├── inventory.html       ← نظام المخزون المتقدم"
echo "   ├── add-product.html     ← نموذج الإضافة مع اللون الحديث"
echo "   ├── merchant-store-mgmt.html ← روابط محدثة"
echo "   ├── style.css            ← تنسيقات Mobile-First + Toast + Modals"
echo "   └── app.js               ← محرك LocalStorage + الحذف المتعدد + المنطق الكامل"
echo ""
echo "💡 افتح index.html أو merchant-store-mgmt.html في المتصفح للتجربة الكاملة."
