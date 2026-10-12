# إعداد Supabase للنسخة السحابية

1. أنشئ مشروع Supabase.
2. افتح SQL Editor وشغّل `SUPABASE_SCHEMA.sql`.
3. أنشئ مستخدم المدير من Authentication > Users.
4. أضف صفًا له في `public.profiles` مع `role='admin'`.
5. افتح `app/src/main/java/com/fawry/employeeapp/AppConfig.kt` وضع:
   - رابط المشروع بدل `YOUR-PROJECT`.
   - الـ publishable/anon key فقط.
6. لا تضع Service Role Key داخل APK.

## إنشاء حسابات الموظفين
لا يتم إنشاء مستخدم Auth جديد من داخل الـAPK باستخدام Service Role. المرحلة التالية ستكون Supabase Edge Function محمية بصلاحية المدير لإنشاء المستخدم وربطه بسجل employee/profile.

## Edge Function
يوجد كود `supabase/functions/create-employee-user/index.ts` لإنشاء حساب موظف + سجل employee + profile من خلال المدير. يتم استخدام Service Role على السيرفر فقط، وليس داخل التطبيق.
