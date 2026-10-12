# Fawry Employee Manager — V8.2 (فحص أولي)

## تجهيز المشروع على GitHub من الموبايل
1. ارفع ملف ZIP هذا إلى جذر Repository `FawryEmployeeApp`.
2. افتح Codespaces من زر **Code** وأنشئ Codespace للفرع `main`.
3. في الطرفية نفّذ: `unzip -o FawryEmployeeApp_GitHub_Build_v8_2_Checked.zip -d .`
4. نفّذ: `git add -A && git commit -m "Add Fawry Employee Manager project" && git push`.
5. افتح **Actions** ثم **Build Android APK**. إذا بدأ البناء تلقائيًا انتظر النتيجة؛ ويمكنك تشغيله يدويًا عبر **Run workflow**.
6. بعد نجاح البناء، افتح الـworkflow ثم **Artifacts** ونزّل `FawryEmployeeApp-debug`، وبعد فك ضغطه ستجد `app-debug.apk`.

> مهم: هذا الملف يحتوي على ملفات المشروع في جذر ZIP مباشرة، وليس داخل مجلد إضافي.

## وضع التجربة
- المدير: `admin@demo.local` / `admin123`
- الموظف: `employee@demo.local` / `employee123`

بيانات وضع التجربة مؤقتة داخل التطبيق وليست قاعدة بيانات مشتركة بين الأجهزة.

## ربط البيانات الحقيقية
عدّل `app/src/main/java/com/fawry/employeeapp/AppConfig.kt` بقيم مشروع Supabase، ثم نفّذ `SUPABASE_SCHEMA_V8.sql` وانشر Edge Function الموجودة في `supabase/functions/create-employee-user`.
لا تضع Service Role Key داخل التطبيق.

## الإشعارات
خدمة استقبال FCM موجودة في الكود، لكن تفعيل الإشعارات الفعلية يحتاج إعداد مشروع Firebase وملف `google-services.json` الخاص بالمشروع. لا تعتبر الإشعارات الفعلية مفعلة قبل إعداد Firebase واختبارها.
