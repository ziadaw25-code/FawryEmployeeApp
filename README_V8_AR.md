# Fawry Employee App V8

تم توسيع V7 إلى V8 لتشمل دورة الطلبات والتقارير والإشعارات.

## الجديد
- الموظف يرسل طلب: إجازة / مأمورية / إذن / مشكلة / أخرى.
- المدير يرى كل الطلبات ويوافق أو يرفض ويكتب ملاحظة.
- إنشاء إشعار تلقائي للمدير عند وصول طلب.
- إشعار تلقائي للموظف عند الموافقة/الرفض.
- شاشة إشعارات لكل مستخدم + تحديد الكل كمقروء.
- تقرير شهري للموظف وللمدير.
- تجميع Cards وFawry Yawmy شهريًا تلقائيًا عند إتمام الانصراف بواسطة PostgreSQL trigger.
- Dashboard المدير يعرض إجماليات اليوم ويتحدث تلقائيًا كل 15 ثانية.
- سجل الحضور الشهري.
- Firebase Cloud Messaging service مضاف للمشروع؛ يلزم وضع `google-services.json` الخاص بمشروع Firebase حتى تصبح Push Notifications الخارجية فعالة.

## مهم قبل التشغيل
1. شغّل `SUPABASE_SCHEMA.sql` بالكامل في SQL Editor.
2. تأكد من `AppConfig.kt` أن URL و ANON/PUBLISHABLE KEY صحيحان.
3. انشر Edge Function `create-employee-user` كما في الإصدارات السابقة.
4. لإشعارات Push: أنشئ Firebase Android App بنفس package `com.fawry.employeeapp`، نزّل `google-services.json` وضعه داخل `app/`، ثم أضف Google Services Gradle plugin إذا كان مشروعك يستخدمه.
5. لا تضع Supabase Service Role Key داخل APK.

## ملاحظة
الإشعارات الداخلية والطلبات تعمل عبر Supabase بمجرد توصيل المشروع. FCM في هذه النسخة مجهز على مستوى Android، لكنه يحتاج ملف Firebase الخاص بمشروعك لتفعيل Push الحقيقي على الأجهزة.
