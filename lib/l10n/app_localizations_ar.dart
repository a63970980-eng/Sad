// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'عدن الرقمية';

  @override
  String get appTagline => 'خدماتك الحكومية في مكان واحد';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navServices => 'الخدمات';

  @override
  String get navReports => 'البلاغات';

  @override
  String get navMap => 'الخريطة';

  @override
  String get navProfile => 'حسابي';

  @override
  String get loginTitle => 'مرحباً بك في عدن الرقمية';

  @override
  String get loginSubtitle =>
      'سجّل الدخول برقم هاتفك للوصول إلى الخدمات الحكومية';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get phoneHint => '7XX XXX XXX';

  @override
  String get continueLabel => 'متابعة';

  @override
  String get rememberMe => 'إبقائي مسجلاً للدخول';

  @override
  String get otpTitle => 'رمز التحقق';

  @override
  String otpSubtitle(Object phone) {
    return 'أدخل الرمز المكوّن من 6 أرقام المرسل إلى $phone';
  }

  @override
  String get verify => 'تحقق';

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String resendIn(Object seconds) {
    return 'إعادة الإرسال خلال $seconds ثانية';
  }

  @override
  String get termsNotice =>
      'بالمتابعة فإنك توافق على شروط الخدمة وسياسة الخصوصية.';

  @override
  String get loginFailed => 'فشل تسجيل الدخول. حاول مرة أخرى.';

  @override
  String get invalidPhone => 'الرجاء إدخال رقم هاتف صحيح.';

  @override
  String get invalidOtp => 'رمز التحقق غير صحيح.';

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodAfternoon => 'مساء الخير';

  @override
  String get goodEvening => 'مساء الخير';

  @override
  String get quickServices => 'خدمات سريعة';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get recentRequests => 'طلباتي الأخيرة';

  @override
  String get noRecentRequests => 'لا توجد طلبات حديثة';

  @override
  String get recentNotifications => 'إشعارات حديثة';

  @override
  String get announcements => 'إعلانات حكومية';

  @override
  String get reportAProblem => 'أبلغ عن مشكلة';

  @override
  String get reportShortcutSubtitle => 'الكهرباء، المياه، الطرق والمزيد';

  @override
  String get searchServices => 'ابحث عن الخدمات...';

  @override
  String get searchNotImplemented => 'خاصية البحث قريباً';

  @override
  String get report => 'بلاغ';

  @override
  String get totalReports => 'إجمالي البلاغات';

  @override
  String get pending => 'معلّق';

  @override
  String get resolved => 'تم حله';

  @override
  String get servicesTitle => 'الخدمات الحكومية';

  @override
  String get svcNationalId => 'البطاقة الشخصية';

  @override
  String get svcPassport => 'جواز السفر';

  @override
  String get svcDrivingLicense => 'رخصة القيادة';

  @override
  String get svcVehicle => 'خدمات المركبات';

  @override
  String get svcMunicipality => 'خدمات البلدية';

  @override
  String get svcUtilities => 'الخدمات العامة';

  @override
  String get actApplyId => 'إصدار بطاقة';

  @override
  String get actRenewId => 'تجديد البطاقة';

  @override
  String get actTrackId => 'تتبع الطلب';

  @override
  String get actNewPassport => 'جواز جديد';

  @override
  String get actRenewPassport => 'تجديد الجواز';

  @override
  String get actTrackPassport => 'تتبع الحالة';

  @override
  String get actNewLicense => 'رخصة جديدة';

  @override
  String get actRenewLicense => 'تجديد';

  @override
  String get actLicenseStatus => 'الحالة';

  @override
  String get actVehicleReg => 'تسجيل مركبة';

  @override
  String get actOwnershipTransfer => 'نقل ملكية';

  @override
  String get actVehicleInfo => 'معلومات المركبة';

  @override
  String get actBuildingPermit => 'تصاريح البناء';

  @override
  String get actCommercialPermit => 'تصاريح تجارية';

  @override
  String get actPropertyServices => 'خدمات العقارات';

  @override
  String get actElectricity => 'الكهرباء';

  @override
  String get actWater => 'المياه';

  @override
  String get actInternet => 'الإنترنت والاتصالات';

  @override
  String get applyNow => 'تقديم الطلب';

  @override
  String get requestSubmitted => 'تم تقديم الطلب بنجاح';

  @override
  String requestSubmittedDesc(Object ref) {
    return 'رقمك المرجعي هو $ref. يمكنك تتبع حالته في أي وقت.';
  }

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get nationalNumber => 'الرقم الوطني';

  @override
  String get submit => 'إرسال';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب';

  @override
  String get reportsTitle => 'البلاغات';

  @override
  String get myReports => 'بلاغاتي';

  @override
  String get newReport => 'بلاغ جديد';

  @override
  String get noReports => 'لا توجد بلاغات بعد';

  @override
  String get noReportsDesc => 'اضغط على زر + لتقديم أول بلاغ لك';

  @override
  String get reportTitleLabel => 'العنوان';

  @override
  String get reportTitleHint => 'عنوان مختصر للمشكلة';

  @override
  String get reportDescLabel => 'الوصف';

  @override
  String get reportDescHint => 'صف المشكلة بالتفصيل';

  @override
  String get reportCategory => 'التصنيف';

  @override
  String get reportPhotos => 'الصور';

  @override
  String get addPhoto => 'إضافة صورة';

  @override
  String get reportLocation => 'الموقع';

  @override
  String get useCurrentLocation => 'استخدام الموقع الحالي';

  @override
  String get locationCaptured => 'تم تحديد الموقع';

  @override
  String get submitReport => 'إرسال البلاغ';

  @override
  String get reportSubmitted => 'تم إرسال البلاغ';

  @override
  String get reportTimeline => 'مسار البلاغ';

  @override
  String get catPowerOutage => 'انقطاع الكهرباء';

  @override
  String get catWaterLeak => 'تسرب المياه';

  @override
  String get catRoadDamage => 'تلف الطرق';

  @override
  String get catGarbage => 'تراكم النفايات';

  @override
  String get catCorruption => 'فساد';

  @override
  String get catStreetLight => 'عطل إنارة الشوارع';

  @override
  String get catSewage => 'مشكلة الصرف الصحي';

  @override
  String get catPublicSafety => 'السلامة العامة';

  @override
  String get statusSubmitted => 'تم الإرسال';

  @override
  String get statusReviewing => 'قيد المراجعة';

  @override
  String get statusInProgress => 'قيد المعالجة';

  @override
  String get statusResolved => 'تم الحل';

  @override
  String get statusRejected => 'مرفوض';

  @override
  String get statusPending => 'معلّق';

  @override
  String get mapTitle => 'الخريطة';

  @override
  String get mapLegend => 'الدليل';

  @override
  String get filterReports => 'البلاغات';

  @override
  String get filterGovOffices => 'المكاتب الحكومية';

  @override
  String get filterElectricity => 'مكاتب الكهرباء';

  @override
  String get filterWater => 'مكاتب المياه';

  @override
  String get filterPolice => 'مراكز الشرطة';

  @override
  String get filterHospitals => 'المستشفيات';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get noNotifications => 'لا توجد إشعارات';

  @override
  String get markAllRead => 'تحديد الكل كمقروء';

  @override
  String get all => 'الكل';

  @override
  String get reports => 'البلاغات';

  @override
  String get services => 'الخدمات';

  @override
  String get system => 'النظام';

  @override
  String get adminDashboard => 'لوحة الإدارة';

  @override
  String get regionalAnalysis => 'التحليل الإقليمي';

  @override
  String get recentActivity => 'الأنشطة الحديثة';

  @override
  String get resolvedReports => 'محلول';

  @override
  String get rejectedReports => 'مرفوض';

  @override
  String get inProgressReports => 'قيد المعالجة';

  @override
  String get totalUsers => 'إجمالي المستخدمين';

  @override
  String get activeUsers => 'المستخدمون النشطون';

  @override
  String get totalServices => 'الخدمات';

  @override
  String get totalRequests => 'إجمالي الطلبات';

  @override
  String get pendingRequests => 'معلّق';

  @override
  String get completedRequests => 'مكتمل';

  @override
  String get newReports => 'بلاغات جديدة';

  @override
  String get noActivity => 'لا توجد أنشطة حديثة';

  @override
  String get profileTitle => 'حسابي';

  @override
  String get personalInfo => 'المعلومات الشخصية';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get darkMode => 'الوضع الليلي';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get about => 'حول التطبيق';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirm => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get systemDefault => 'حسب النظام';

  @override
  String get lightMode => 'فاتح';

  @override
  String get appVersion => 'الإصدار';

  @override
  String get aboutDesc =>
      'عدن الرقمية هي المنصة الرسمية للوصول إلى الخدمات الحكومية لمواطني عدن.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get errorGeneric => 'حدث خطأ ما';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get comingSoon => 'قريباً';

  @override
  String get track => 'تتبع';

  @override
  String get details => 'التفاصيل';

  @override
  String get ok => 'حسناً';

  @override
  String get close => 'إغلاق';

  @override
  String get search => 'بحث';
}
