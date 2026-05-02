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
