#!/bin/bash
# =================================================================
# سكربت تعبئة الملفات الموجودة مسبقاً بالكود (دون حذف الهيكلية)
# يبحث عن الملفات بالأسماء المتفق عليها ويكتب الكود مباشرة فيها
# =================================================================

echo "🔍 جاري البحث عن الهيكلية الحالية وتعبئة الملفات..."

# التحقق من وجود ملفات المشروع في المجلد الحالي
if [ ! -f "index.html" ] || [ ! -d "css" ] || [ ! -d "js" ]; then
    echo "❌ لم يتم العثور على الملفات الأساسية. يرجى تشغيل هذا السكربت داخل مجلد المشروع (ecommerce-merchant-ui أو ecommerce-merchant-demo)."
    exit 1
fi

# 1️⃣ تعبئة شاشة تسجيل الدخول
cat << 'EOF' > index.html
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>تسجيل الدخول | منصة التجارة</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Tajawal:wght@400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css">
</head>
<body class="login-page">
    <div class="login-container">
        <div class="login-header">
            <i class="bi bi-shop"></i>
            <h1>مرحباً بك</h1>
            <p>سجل الدخول للمتابعة</p>
        </div>
        <form id="loginForm" class="login-form">
            <div class="form-group">
                <label for="emailPhone">البريد الإلكتروني أو رقم الهاتف</label>
                <div class="input-wrapper">
                    <i class="bi bi-person"></i>
                    <input type="text" id="emailPhone" placeholder="example@email.com أو 05xxxxxxxx" required>
                </div>
            </div>
            <div class="form-group">
                <label for="password">كلمة المرور</label>
                <div class="input-wrapper">
                    <i class="bi bi-lock"></i>
                    <input type="password" id="password" placeholder="••••••••" required>
                </div>
            </div>
            <div class="form-group radio-group">
                <label class="radio-label">
                    <input type="radio" name="accountType" value="client" id="clientRadio">
                    <span>حساب عميل</span>
                    <i class="bi bi-person-check"></i>
                </label>
                <label class="radio-label active">
                    <input type="radio" name="accountType" value="merchant" id="merchantRadio" checked>
                    <span>حساب تاجر</span>
                    <i class="bi bi-shop"></i>
                </label>
            </div>
            <button type="submit" class="btn-primary">
                <span>تسجيل الدخول</span>
                <i class="bi bi-arrow-left"></i>
            </button>
        </form>
    </div>
    <script src="js/app.js"></script>
</body>
</html>
EOF

# 2️⃣ تعبئة لوحة التاجر
cat << 'EOF' > merchant-dashboard.html
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>لوحة التاجر | منصة التجارة</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Tajawal:wght@400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css">
</head>
<body class="dashboard-page">
    <header class="top-bar">
        <div class="logo">
            <i class="bi bi-shop"></i>
            <span>متجرك</span>
        </div>
        <button class="btn-logout" onclick="window.location.href='index.html'">
            <i class="bi bi-box-arrow-right"></i> خروج
        </button>
    </header>
    <main class="dashboard-grid">
        <a href="merchant-store-mgmt.html" class="dash-card">
            <i class="bi bi-gear-wide-connected"></i>
            <h2>إدارة المتجر</h2>
            <p>الطلبات، المنتجات، والمخزون</p>
        </a>
        <a href="#" class="dash-card coming-soon" onclick="alert('قيد التطوير للعرض التفاعلي')">
            <i class="bi bi-palette"></i>
            <h2>إدارة الثيم</h2>
            <p>تخصيص مظهر المتجر</p>
        </a>
    </main>
    <script src="js/app.js"></script>
</body>
</html>
EOF

# 3️⃣ تعبئة صفحة إدارة المتجر
cat << 'EOF' > merchant-store-mgmt.html
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>إدارة المتجر | منصة التجارة</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Tajawal:wght@400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css">
</head>
<body class="dashboard-page">
    <header class="top-bar">
        <button class="btn-back" onclick="window.location.href='merchant-dashboard.html'">
            <i class="bi bi-arrow-right"></i> رجوع
        </button>
        <h1>إدارة المتجر</h1>
        <div></div>
    </header>
    <main class="mgmt-grid">
        <div class="mgmt-card" onclick="alert('سيتم توجيهك لصفحة الطلبات')">
            <i class="bi bi-clipboard-check"></i>
            <h3>إدارة الطلبات</h3>
        </div>
        <div class="mgmt-card" onclick="alert('سيتم توجيهك لصفحة إضافة منتج')">
            <i class="bi bi-plus-circle"></i>
            <h3>إضافة منتج</h3>
        </div>
        <div class="mgmt-card" onclick="alert('سيتم توجيهك لصفحة المخزون')">
            <i class="bi bi-box-seam"></i>
            <h3>المخزون</h3>
        </div>
        <div class="mgmt-card" onclick="alert('سيتم توجيهك لصفحة التقارير')">
            <i class="bi bi-bar-chart-line"></i>
            <h3>التقارير</h3>
        </div>
    </main>
    <script src="js/app.js"></script>
</body>
</html>
EOF

# 4️⃣ تعبئة ملف التنسيقات الموحد
cat << 'EOF' > css/style.css
:root {
    --primary: #2563eb;
    --primary-dark: #1d4ed8;
    --bg: #f8fafc;
    --card-bg: #ffffff;
    --text: #0f172a;
    --text-light: #64748b;
    --border: #e2e8f0;
    --radius-lg: 24px;
    --radius-md: 16px;
    --radius-sm: 12px;
    --shadow: 0 4px 6px -1px rgba(0,0,0,0.1), 0 2px 4px -2px rgba(0,0,0,0.1);
    --shadow-hover: 0 10px 15px -3px rgba(0,0,0,0.1), 0 4px 6px -4px rgba(0,0,0,0.1);
}
* { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: 'Tajawal', sans-serif; background: var(--bg); color: var(--text); min-height: 100vh; direction: rtl; }

/* Login Page */
.login-page { display: flex; align-items: center; justify-content: center; padding: 2rem; }
.login-container { background: var(--card-bg); padding: 2.5rem; border-radius: var(--radius-lg); box-shadow: var(--shadow); width: 100%; max-width: 420px; }
.login-header { text-align: center; margin-bottom: 2rem; }
.login-header i { font-size: 2.5rem; color: var(--primary); margin-bottom: 0.5rem; }
.login-header h1 { font-size: 1.8rem; margin-bottom: 0.3rem; }
.login-header p { color: var(--text-light); }
.form-group { margin-bottom: 1.2rem; }
.form-group label { display: block; margin-bottom: 0.4rem; font-weight: 500; }
.input-wrapper { position: relative; }
.input-wrapper i { position: absolute; top: 50%; right: 12px; transform: translateY(-50%); color: var(--text-light); }
.input-wrapper input { width: 100%; padding: 0.8rem 2.8rem 0.8rem 1rem; border: 1px solid var(--border); border-radius: var(--radius-md); font-family: inherit; font-size: 1rem; transition: all 0.2s; }
.input-wrapper input:focus { outline: none; border-color: var(--primary); box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.15); }
.radio-group { display: flex; gap: 1rem; margin-bottom: 1.5rem; }
.radio-label { flex: 1; display: flex; align-items: center; justify-content: center; gap: 0.5rem; padding: 0.9rem; border: 2px solid var(--border); border-radius: var(--radius-md); cursor: pointer; transition: all 0.2s; background: var(--card-bg); font-weight: 500; }
.radio-label input { display: none; }
.radio-label:has(input:checked) { border-color: var(--primary); background: #eff6ff; color: var(--primary); box-shadow: 0 0 0 2px rgba(37, 99, 235, 0.2); }
.radio-label i { font-size: 1.2rem; }
.btn-primary { width: 100%; padding: 0.9rem; border: none; border-radius: var(--radius-md); background: var(--primary); color: white; font-family: inherit; font-size: 1.1rem; font-weight: 600; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 0.5rem; transition: all 0.2s; }
.btn-primary:hover { background: var(--primary-dark); transform: translateY(-1px); }

/* Dashboard Pages */
.top-bar { display: flex; align-items: center; justify-content: space-between; padding: 1.5rem 2rem; background: var(--card-bg); box-shadow: 0 1px 3px rgba(0,0,0,0.05); }
.logo { display: flex; align-items: center; gap: 0.5rem; font-size: 1.3rem; font-weight: 700; color: var(--primary); }
.btn-logout, .btn-back { padding: 0.5rem 1rem; border: 1px solid var(--border); border-radius: var(--radius-sm); background: transparent; cursor: pointer; display: flex; align-items: center; gap: 0.4rem; font-family: inherit; transition: all 0.2s; }
.btn-logout:hover, .btn-back:hover { background: #f1f5f9; border-color: var(--primary); color: var(--primary); }

.dashboard-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 1.5rem; padding: 2rem; max-width: 1200px; margin: 0 auto; }
.dash-card { background: var(--card-bg); padding: 2.5rem; border-radius: var(--radius-lg); box-shadow: var(--shadow); text-align: center; text-decoration: none; color: var(--text); transition: all 0.3s; display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 220px; }
.dash-card:hover { transform: translateY(-5px); box-shadow: var(--shadow-hover); border: 2px solid var(--primary); }
.dash-card i { font-size: 3rem; color: var(--primary); margin-bottom: 1rem; }
.dash-card h2 { font-size: 1.5rem; margin-bottom: 0.5rem; }
.dash-card p { color: var(--text-light); font-size: 0.95rem; }
.dash-card.coming-soon { opacity: 0.7; border: 2px dashed var(--border); }

.mgmt-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem; padding: 2rem; max-width: 1000px; margin: 0 auto; }
.mgmt-card { background: var(--card-bg); padding: 2rem; border-radius: var(--radius-lg); box-shadow: var(--shadow); text-align: center; cursor: pointer; transition: all 0.3s; aspect-ratio: 1 / 1; display: flex; flex-direction: column; align-items: center; justify-content: center; }
.mgmt-card:hover { transform: translateY(-5px) scale(1.02); box-shadow: var(--shadow-hover); background: #f8fafc; }
.mgmt-card i { font-size: 2.8rem; color: var(--primary); margin-bottom: 1rem; }
.mgmt-card h3 { font-size: 1.2rem; font-weight: 600; }

@media (max-width: 640px) {
    .login-container { padding: 1.5rem; }
    .dashboard-grid, .mgmt-grid { grid-template-columns: 1fr; padding: 1rem; }
    .top-bar { padding: 1rem; flex-wrap: wrap; gap: 0.5rem; }
}
EOF

# 5️⃣ تعبئة ملف الجافاسكريبت (التنقل والمحاكاة)
cat << 'EOF' > js/app.js
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
EOF

echo "✅ تم تعبئة الملفات الموجودة بنجاح!"
echo "📂 الملفات المحدثة:"
echo "   ├── index.html"
echo "   ├── merchant-dashboard.html"
echo "   ├── merchant-store-mgmt.html"
echo "   ├── css/style.css"
echo "   └── js/app.js"
echo ""
echo "💡 افتح ملف index.html مباشرة في المتصفح لعرض الواجهة التفاعلية."
