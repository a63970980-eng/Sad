# عدن الرقمية — Aden Digital

منصة رقمية حكومية موحّدة لخدمات وبلاغات محافظة عدن، مبنية بـ **Flutter** وبتصميم عربي أولاً (RTL).

## الحالة الحالية

- واجهات المواطن والخدمات والبلاغات والتتبع والإشعارات موجودة ضمن بنية Clean Architecture.
- Supabase مفعّل كطبقة بيانات إنتاجية تدريجية مع PostgreSQL وRLS وRealtime.
- مرفقات البلاغات محفوظة في Storage خاص ولا تعتمد على روابط عامة.
- لوحة الإدارة تستخدم RPCs محمية بصلاحيات الدور بدل الأرقام التجريبية عند وجود جلسة حكومية.
- مديريات عدن الثماني والخدمات الحكومية والجهات الحكومية الأساسية مزروعة في قاعدة البيانات.
- Firebase/وضع Demo محفوظان كمسار توافق احتياطي أثناء الانتقال، ولا يتم تفعيل Supabase Phone OTP قبل إعداد مزود SMS الإنتاجي.
- GitHub Actions يشغّل `flutter analyze` و`flutter test` على كل تغيير في `main`.

## التشغيل

```bash
flutter pub get
flutter run
```

في الوضع التجريبي، يمكن تسجيل الدخول باستخدام أي رقم وOTP التجريبي `123456`.

## بنية المشروع

```text
lib/
├── core/
│   ├── config/       # Firebase/Supabase + runtime capabilities
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

يتم ضبط عنوان المشروع ومفتاح الـ publishable في إعدادات التطبيق، بينما لا يوضع أي `service_role` key داخل Flutter.

قبل تفعيل Supabase Phone OTP في الإنتاج يجب إعداد مزود SMS والتحقق من تدفق التسجيل والتحقق فعلياً على جهاز Android/iOS.

### Firebase

يبقى Firebase متاحاً كمسار توافق. عند توفير إعدادات Firebase الحقيقية يمكن استخدام Auth/Firestore/Storage/FCM وفق المستودعات الموجودة في المشروع.

## الاختبارات

```bash
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
```

يجب اعتبار نجاح CI شرطاً قبل دمج أي دفعة جديدة في `main`.
