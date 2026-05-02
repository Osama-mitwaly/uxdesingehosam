// === Global Helpers ===
const $ = s => document.querySelector(s);
const $$ = s => document.querySelectorAll(s);

document.addEventListener('DOMContentLoaded', () => {
    if (document.body.classList.contains('login-page')) initLogin();
    if (document.body.classList.contains('add-product-page')) initAddProduct();
    if (document.body.classList.contains('inventory-page')) initInventory();
});

// === Login Page ===
function initLogin() {
    const form = document.getElementById('loginForm');
    if (!form) return;
    form.addEventListener('submit', e => {
        e.preventDefault();
        const type = document.querySelector('input[name="accountType"]:checked')?.value;
        if (type === 'merchant') window.location.href = 'merchant-dashboard.html';
        else alert('تم اختيار حساب عميل. (سيتم تطوير هذه الواجهة في الجزء الثاني)');
    });
}

// === Add Product Page ===
function initAddProduct() {
    const form = document.getElementById('productForm');
    if (!form) return;
    
    const imgInput = $('#productImage'), nameInput = $('#productName'), priceInput = $('#productPrice');
    const previewImg = $('#previewImg'), previewName = $('#previewName'), previewPrice = $('#previewPrice'), previewCard = $('#previewCard');
    const colorWrap = $('#colorPickerWrapper');
    
    // Color Picker Logic
    let selectedColor = '#ffffff';
    const colors = ['#ffffff','#f8fafc','#e0f2fe','#dcfce7','#fef3c7','#f3e8ff'];
    colorWrap.innerHTML = colors.map(c => `<div class="color-dot ${c===selectedColor?'active':''}" style="background:${c}" data-c="${c}"></div>`).join('') +
    `<input type="color" id="customColorInput" value="${selectedColor}">`;
    
    colorWrap.addEventListener('click', e => {
        const dot = e.target.closest('.color-dot');
        if(dot) { selectedColor = dot.dataset.c; $$('.color-dot').forEach(d => d.classList.remove('active')); dot.classList.add('active'); previewCard.style.backgroundColor = selectedColor; }
    });
    $('#customColorInput').addEventListener('input', e => { selectedColor = e.target.value; previewCard.style.backgroundColor = selectedColor; $$('.color-dot').forEach(d => d.classList.remove('active')); });

    // Live Preview
    imgInput.onchange = e => previewImg.src = e.target.files[0] ? URL.createObjectURL(e.target.files[0]) : "https://placehold.co/400x400/e2e8f0/94a3b8?text=صورة+المنتج";
    nameInput.oninput = () => previewName.textContent = nameInput.value || 'اسم المنتج';
    priceInput.oninput = () => previewPrice.textContent = (parseFloat(priceInput.value)||0).toFixed(2) + ' ر.س';

    // Submit
    form.onsubmit = e => {
        e.preventDefault();
        const t = $('#toast');
        t.classList.remove('hidden'); requestAnimationFrame(()=>t.classList.add('show'));
        setTimeout(()=>{t.classList.remove('show'); setTimeout(()=>t.classList.add('hidden'),400); form.reset(); previewImg.src="https://placehold.co/400x400/e2e8f0/94a3b8?text=صورة+المنتج"; previewName.textContent='اسم المنتج'; previewPrice.textContent='0.00 ر.س'; previewCard.style.backgroundColor='#fff'; }, 2500);
    };
}

// === Inventory Page ===
function initInventory() {
    const DB_KEY = 'ecommerce_inventory_v1';
    let db = JSON.parse(localStorage.getItem(DB_KEY)) || null;
    if (!db) {
        db = { categories: [{id:'c1',name:'إلكترونيات'},{id:'c2',name:'ملابس'}], products: [
            {id:'p1',code:'EL-001',name:'سماعات',price:250,catId:'c1',stock:50,min:10,sold:15,active:true,color:'#fff',image:''},
            {id:'p2',code:'CL-002',name:'قميص',price:89,catId:'c2',stock:5,min:15,sold:40,active:true,color:'#e0f2fe',image:''}
        ]};
        localStorage.setItem(DB_KEY, JSON.stringify(db));
    }
    
    let state = { activeCat: 'all', selected: new Set(), editingId: null };
    
    // Helpers
    const save = () => localStorage.setItem(DB_KEY, JSON.stringify(db));
    const toast = (m, t='success') => {
        let c = $('#toastContainer'); if(!c){ c=document.createElement('div'); c.id='toastContainer'; document.body.appendChild(c); }
        const el = document.createElement('div'); el.className=`toast ${t}`;
        el.innerHTML = `<i class="bi bi-${t==='success'?'check-circle':t==='warning'?'exclamation-triangle':'info-circle'}"></i> ${m}`;
        c.appendChild(el); setTimeout(()=>el.remove(), 3200);
    };
    const openModal = id => $(`#${id}`)?.classList.add('active');
    const closeModal = id => $(`#${id}`)?.classList.remove('active');
    $$(`.modal`).forEach(m => m.onclick = e => { if(e.target===m) m.classList.remove('active'); });

    // Render Functions
    function renderTable() {
        const tbody = $('#inventoryBody'); if(!tbody) return;
        const filtered = state.activeCat==='all' ? db.products : db.products.filter(p=>p.catId===state.activeCat);
        tbody.innerHTML = filtered.map(p => {
            const cls = p.stock===0?'stock-red':p.stock<=p.min?'stock-orange':'stock-green';
            const chk = state.selected.has(p.id)?'checked':'';
            return `<tr style="${p.active?'':'opacity:0.5'}">
                <td class="mobile-only"><input type="checkbox" class="prod-select" data-id="${p.id}" ${chk}></td>
                <td data-label="الاسم">${p.name}</td>
                <td data-label="الكود" class="desktop-only"><code>${p.code}</code></td>
                <td data-label="مباع">${p.sold}</td>
                <td data-label="الحد" class="desktop-only"><span class="stock-val ${cls}">${p.stock}/${p.min}</span></td>
                <td data-label="تفعيل" class="desktop-only"><label class="toggle-switch"><input type="checkbox" ${p.active?'checked':''} onchange="toggleProduct('${p.id}')"><span class="slider"></span></label></td>
                <td class="actions-col" data-label="إجراءات">
                    <button class="btn-icon" onclick="showReport('${p.id}')" title="تقرير"><i class="bi bi-bar-chart-line"></i></button>
                    <button class="btn-icon" onclick="openEdit('${p.id}')" title="تعديل"><i class="bi bi-pencil"></i></button>
                    <button class="btn-icon" onclick="deleteSingle('${p.id}')" title="حذف" style="color:var(--red)"><i class="bi bi-trash"></i></button>
                </td>
            </tr>`;
        }).join('');
        
        // Selection Logic
        $$('.prod-select').forEach(cb => cb.onchange = e => { e.target.checked?state.selected.add(cb.dataset.id):state.selected.delete(cb.dataset.id); updateBar(); });
        const all = $('#selectAll');
        if(all) all.onchange = e => { $$('.prod-select').forEach(cb => { cb.checked=e.target.checked; e.target.checked?state.selected.add(cb.dataset.id):state.selected.delete(cb.dataset.id); }); updateBar(); };
    }

    function renderCats() {
        const bar = $('#categoryBar'); if(!bar) return;
        bar.innerHTML = `<button class="cat-chip ${state.activeCat==='all'?'active':''}" data-cat="all">الكل</button>` + db.categories.map(c=>`<button class="cat-chip ${state.activeCat===c.id?'active':''}" data-cat="${c.id}">${c.name}</button>`).join('');
        bar.querySelectorAll('.cat-chip').forEach(b => b.onclick = () => { state.activeCat=b.dataset.cat; renderCats(); renderTable(); clearSelection(); });
    }

    function updateBar() {
        const bar = $('#floatingAction'); if(!bar) return;
        bar.classList.toggle('show', state.selected.size>0);
        $('#selectedCount').textContent = `${state.selected.size} عناصر محددة`;
    }
    window.clearSelection = () => { state.selected.clear(); $$('.prod-select').forEach(cb=>cb.checked=false); $('#selectAll').checked=false; updateBar(); };

    // Actions
    window.openEdit = id => {
        const p = db.products.find(x=>x.id===id); if(!p) return;
        state.editingId = id; $('#productModalTitle').textContent='تعديل منتج';
        $('#prodId').value=p.id; $('#prodName').value=p.name; $('#prodCode').value=p.code; $('#prodPrice').value=p.price; $('#prodStock').value=p.stock; $('#prodMin').value=p.min;
        $('#prodCat').innerHTML = db.categories.map(c=>`<option value="${c.id}" ${c.id===p.catId?'selected':''}>${c.name}</option>`).join('');
        openModal('productModal');
    };

    $('#productForm')?.addEventListener('submit', e => {
        e.preventDefault();
        const data = { id: state.editingId||'p'+Date.now(), name:$('#prodName').value, code:$('#prodCode').value, price:parseFloat($('#prodPrice').value), stock:parseInt($('#prodStock').value), min:parseInt($('#prodMin').value), catId:$('#prodCat').value, color:'#fff', sold:state.editingId?db.products.find(p=>p.id===state.editingId).sold:0, active:true, image:'' };
        if(state.editingId) { const i=db.products.findIndex(p=>p.id===state.editingId); db.products[i]=data; } else db.products.push(data);
        save(); closeModal('productModal'); toast('تم حفظ المنتج'); renderTable(); state.editingId=null; $('#productForm').reset();
    });

    window.toggleProduct = id => { const p=db.products.find(x=>x.id===id); p.active=!p.active; save(); renderTable(); toast(p.active?'تم التفعيل':'تم الإلغاء','warning'); };
    window.showReport = id => { const p=db.products.find(x=>x.id===id); if(!p) return; $('#reportContent').innerHTML=`<div class="report-grid">${Object.entries({اسم:p.name,كود:p.code,سعر:p.price+' ر.س',متبقي:p.stock,مباع:p.sold,إجمالي:(p.sold*p.price).toFixed(2)+' ر.س'}).map(([k,v])=>`<div class="report-item"><span class="report-label">${k}</span><span class="report-value">${v}</span></div>`).join('')}</div>`; openModal('reportModal'); };
    window.deleteSingle = id => { if(confirm('حذف نهائي؟')) { db.products=db.products.filter(p=>p.id!==id); save(); renderTable(); toast('تم الحذف','warning'); } };
    
    // Category & Multi Delete
    $('#categoryForm')?.addEventListener('submit', e => { e.preventDefault(); db.categories.push({id:'c'+Date.now(),name:$('#catName').value}); save(); renderCats(); closeModal('categoryModal'); toast('تم الإضافة'); });
    window.confirmDeleteCat = id => { openModal('deleteCatModal'); /* logic simplified for demo */ };
    $('#deleteCatForm')?.addEventListener('submit', e => { e.preventDefault(); closeModal('deleteCatModal'); toast('تم الحذف'); renderCats(); });
    window.confirmMultiDelete = () => { $('#delCount').textContent=state.selected.size; openModal('multiDeleteModal'); };
    window.executeMultiDelete = () => { db.products=db.products.filter(p=>!state.selected.has(p.id)); save(); clearSelection(); closeModal('multiDeleteModal'); toast('تم حذف المحدد'); renderTable(); };

    // Init
    renderCats(); renderTable();
}
