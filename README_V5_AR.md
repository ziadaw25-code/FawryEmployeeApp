# Fawry Employee Manager — V5

## الجديد في V5
- لوحة المدير أصبحت تحتوي على زر **خريطة المواقع ومسار الحركة**.
- التطبيق يسترجع آخر نقاط GPS من `location_samples` للمدير.
- عرض آخر نقطة لكل موظف على خريطة OpenStreetMap داخل التطبيق.
- الضغط على النقطة يتيح فتح إحداثياتها في Google Maps.
- التتبع نفسه يظل عبر Android Foreground Location Service مع إشعار ظاهر أثناء الوردية.
- لا يوجد Google Maps API key مطلوب لهذه النسخة.

## مهم قبل التشغيل
1. ضع رابط Supabase والمفتاح العام في `app/src/main/java/com/fawry/employeeapp/AppConfig.kt`.
2. نفّذ `SUPABASE_SCHEMA.sql` في مشروع Supabase.
3. نفّذ إعداد Edge Function الموجود في `SUPABASE_SETUP_AR.md` لإنشاء حسابات الموظفين من المدير.
4. افتح المشروع في Android Studio وابنِ APK.

## الخصوصية
التتبع مصمم للعمل أثناء الوردية فقط، مع إشعار Android ظاهر. يجب إبلاغ الموظفين والحصول على الموافقات المطلوبة وفق سياسات جهة العمل والقوانين المحلية.
