# Fawry Employee Manager — Android

دي أول قاعدة لمشروع التطبيق الحقيقي بدل ملف HTML.

## الموجود حاليا
- Android Native Kotlin.
- شاشة دخول أولية.
- زر حضور وانصراف.
- Foreground Location Service بإشعار ظاهر أثناء الوردية.
- صلاحيات GPS والإشعارات المطلوبة.
- ملف HTML القديم محفوظ داخل `app/src/main/assets/legacy_manager.html` كمرجع للواجهات والوظائف الحالية.

## المرحلة التالية
1. ربط Supabase Auth.
2. حسابات المديرين والموظفين وصلاحياتهم.
3. جداول employees / attendance / location_samples / monthly_performance / requests.
4. رفع الموقع للسيرفر أثناء الوردية.
5. إدخال Cards وFawry Yawmy عند الانصراف.
6. لوحة المدير ومتابعة الموظفين لحظيا.
7. إنشاء حساب موظف من المدير بدون كشف مفاتيح Supabase الحساسة داخل التطبيق.

## مهم
لا يتم وضع Supabase Service Role Key داخل APK. التطبيق سيستخدم publishable/anon key مع RLS، وإنشاء الحسابات الإدارية سيتم عبر Edge Function آمنة.

افتح المجلد في Android Studio ثم Sync Project with Gradle Files وبعدها Build APK.
