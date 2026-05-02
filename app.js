document.addEventListener('DOMContentLoaded', () => {
    const loginForm = document.getElementById('loginForm');
    if (loginForm) {
        loginForm.addEventListener('submit', (e) => {
            e.preventDefault();
            const accountType = document.querySelector('input[name="accountType"]:checked').value;
            // محاكاة الدخول: تجاهل التحقق من البيانات والاعتماد على نوع الحساب
            if (accountType === 'merchant') {
                window.location.href = 'merchant-dashboard.html';
            } else {
                alert('تم اختيار حساب عميل. (سيتم تطوير هذه الواجهة في الجزء الثاني)');
            }
        });
    }
});

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
