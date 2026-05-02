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
