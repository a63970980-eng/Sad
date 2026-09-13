# عدن الرقمية — Aden Digital

منصة رقمية حكومية موحّدة لخدمات وبلاغات محافظة عدن، مبنية بـ **Flutter** وبتصميم عربي أولاً (RTL).

## الحالة الحالية

- واجهات المواطن والخدمات والبلاغات والتتبع والإشعارات موجودة ضمن بنية منظمة قابلة للتوسع.
- **Supabase هو backend الإنتاجي الوحيد** للهوية والبيانات والتخزين وقاعدة PostgreSQL.
- RLS مفعّل على جداول التطبيق المكشوفة، مع صلاحيات مقيّدة حسب ملكية المواطن والدور الحكومي.
- مرفقات البلاغات محفوظة في Storage خاص ولا تعتمد على روابط عامة.
- لوحة الإدارة والعمليات الحكومية الحساسة تستخدم RPCs محمية بصلاحيات الدور.
- مديريات عدن الثماني والخدمات الحكومية والجهات الحكومية الأساسية موجودة في قاعدة البيانات.
- لا يعتمد الإصدار الإنتاجي على Firebase ولا يحتوي على fallback صامت إلى Firebase أو بيانات تجريبية.
- الوضع التجريبي منفصل ويُفعّل صراحةً فقط عند بناء نسخة Demo.
- GitHub Actions يشغّل التحليل والاختبارات وبناء Android App Bundle على تغييرات `main`.

## التشغيل

```bash
flutter pub get
flutter run
```

للتطوير التجريبي فقط يمكن تفعيل Demo Mode عبر `ADEN_DIGITAL_DEMO_MODE`.

## بنية المشروع

```text
lib/
├── core/
│   ├── config/       # Supabase + runtime configuration
│   ├── router/       # GoRouter + auth redirects
│   ├── storage/      # Secure storage + preferences
│   ├── theme/        # Material 3 design system
│   └── widgets/      # Shared UI components
├── l10n/              # Arabic + English localization
└── features/
    ├── auth/          # Phone/OTP authentication and profile
    ├── home/          # Citizen dashboard
    ├── services/      # Government services and requests
    ├── reports/       # Reports, GPS, photos and timelines
    ├── map/           # Aden map and government locations
    ├── notifications/ # Citizen notifications + Realtime
    ├── profile/       # Profile and settings
    ├── admin/         # Government dashboard and protected operations
    └── shell/         # Application navigation
```

## الإنتاج

### Supabase

يتم ضبط عنوان المشروع ومفتاح الـ **publishable** داخل التطبيق. لا يجب وضع أي `service_role` أو secret key داخل تطبيق Flutter.

قبل الإطلاق الفعلي يجب:

1. تفعيل Phone Provider في Supabase.
2. إعداد مزود SMS يدعم إرسال الرسائل إلى أرقام اليمن.
3. اختبار إرسال OTP والتحقق منه على جهاز حقيقي.
4. مراجعة CAPTCHA/rate limits الخاصة بالـOTP.
5. إدخال بيانات الجهات والأقسام والموظفين الحكوميين الفعلية.

### الخرائط والإشعارات

يجب توفير مفتاح Google Maps للإصدار الإنتاجي وفق إعدادات المنصة، وعدم تضمين الأسرار في المستودع. كما يجب اختبار قناة الإشعارات على أجهزة حقيقية قبل الإطلاق النهائي.

## الاختبارات

```bash
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
```

يجب اعتبار نجاح CI شرطاً قبل اعتماد أي دفعة جديدة في `main`.
