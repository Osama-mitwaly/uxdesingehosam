#!/bin/bash
# =================================================================
# هيكلية المشروع: عرض تفاعلي لمنصة تجارة إلكترونية - الجزء الأول (التاجر)
# التقنية: HTML / CSS / JavaScript خالص
# =================================================================

PROJECT_NAME="ecommerce-merchant-demo"

echo "🚀 جاري إنشاء هيكلية المشروع: $PROJECT_NAME ..."

# إنشاء المجلدات الرئيسية والفرعية
mkdir -p "$PROJECT_NAME"/{css,js,assets/{images,icons}}

cd "$PROJECT_NAME" || exit

# ملفات الواجهات (HTML)
touch index.html
touch merchant-dashboard.html
touch merchant-store-mgmt.html
touch merchant-theme-mgmt.html

# ملفات التنسيقات (CSS)
touch css/reset.css
touch css/variables.css
touch css/layout.css
touch css/components.css
touch css/login.css
touch css/dashboard.css

# ملفات المنطق والتنقل (JavaScript)
touch js/app.js
touch js/login.js
touch js/navigation.js

# مجلدات الأصول (فارغة للعرض التفاعلي)
touch assets/images/.gitkeep
touch assets/icons/.gitkeep

echo "✅ تم إنشاء الهيكلية بنجاح!"
echo "📂 المسار الحالي: $(pwd)"
echo ""
echo "📋 خريطة الملفات التي تم إنشاؤها:"
echo "├── index.html                  ← شاشة تسجيل الدخول"
echo "├── merchant-dashboard.html     ← لوحة التاجر (إدارة المتجر + إدارة الثيم)"
echo "├── merchant-store-mgmt.html    ← إدارة المتجر (طلبات، منتج، مخزن، تقارير)"
echo "├── merchant-theme-mgmt.html    ← إدارة الثيم (مستقبلية)"
echo "├── css/                        ← تنسيقات مقسمة منطقياً"
echo "├── js/                         ← تنقل ومحاكاة الدخول"
echo "└── assets/                     ← صور وأيقونات العرض"
echo ""
echo "👉 الخطوة التالية: سأقوم بملء index.html + css/login.css + js/login.js لبناء واجهة الدخول"
echo "   مع محاكاة التوجيه إلى merchant-dashboard.html عند اختيار (حساب التاجر)."
