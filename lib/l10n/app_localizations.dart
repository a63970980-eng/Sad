import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Aden Digital'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your government services, in one place'**
  String get appTagline;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get navServices;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Aden Digital'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your phone number to access government services'**
  String get loginSubtitle;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'7XX XXX XXX'**
  String get phoneHint;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Keep me signed in'**
  String get rememberMe;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to {phone}'**
  String otpSubtitle(Object phone);

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendIn(Object seconds);

  /// No description provided for @termsNotice.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to the Terms of Service and Privacy Policy.'**
  String get termsNotice;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed. Please try again.'**
  String get loginFailed;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number.'**
  String get invalidPhone;

  /// No description provided for @invalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code.'**
  String get invalidOtp;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @quickServices.
  ///
  /// In en, this message translates to:
  /// **'Quick Services'**
  String get quickServices;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @recentRequests.
  ///
  /// In en, this message translates to:
  /// **'Recent Requests'**
  String get recentRequests;

  /// No description provided for @noRecentRequests.
  ///
  /// In en, this message translates to:
  /// **'You have no recent requests'**
  String get noRecentRequests;

  /// No description provided for @announcements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announcements;

  /// No description provided for @reportAProblem.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get reportAProblem;

  /// No description provided for @reportShortcutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Power, water, roads and more'**
  String get reportShortcutSubtitle;

  /// No description provided for @servicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Government Services'**
  String get servicesTitle;

  /// No description provided for @svcNationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get svcNationalId;

  /// No description provided for @svcPassport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get svcPassport;

  /// No description provided for @svcDrivingLicense.
  ///
  /// In en, this message translates to:
  /// **'Driving License'**
  String get svcDrivingLicense;

  /// No description provided for @svcVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Services'**
  String get svcVehicle;

  /// No description provided for @svcMunicipality.
  ///
  /// In en, this message translates to:
  /// **'Municipality'**
  String get svcMunicipality;

  /// No description provided for @svcUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get svcUtilities;

  /// No description provided for @actApplyId.
  ///
  /// In en, this message translates to:
  /// **'Apply for ID'**
  String get actApplyId;

  /// No description provided for @actRenewId.
  ///
  /// In en, this message translates to:
  /// **'Renew ID'**
  String get actRenewId;

  /// No description provided for @actTrackId.
  ///
  /// In en, this message translates to:
  /// **'Track application'**
  String get actTrackId;

  /// No description provided for @actNewPassport.
  ///
  /// In en, this message translates to:
  /// **'New passport'**
  String get actNewPassport;

  /// No description provided for @actRenewPassport.
  ///
  /// In en, this message translates to:
  /// **'Passport renewal'**
  String get actRenewPassport;

  /// No description provided for @actTrackPassport.
  ///
  /// In en, this message translates to:
  /// **'Track status'**
  String get actTrackPassport;

  /// No description provided for @actNewLicense.
  ///
  /// In en, this message translates to:
  /// **'New license'**
  String get actNewLicense;

  /// No description provided for @actRenewLicense.
  ///
  /// In en, this message translates to:
  /// **'Renewal'**
  String get actRenewLicense;

  /// No description provided for @actLicenseStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get actLicenseStatus;

  /// No description provided for @actVehicleReg.
  ///
  /// In en, this message translates to:
  /// **'Vehicle registration'**
  String get actVehicleReg;

  /// No description provided for @actOwnershipTransfer.
  ///
  /// In en, this message translates to:
  /// **'Ownership transfer'**
  String get actOwnershipTransfer;

  /// No description provided for @actVehicleInfo.
  ///
  /// In en, this message translates to:
  /// **'Vehicle information'**
  String get actVehicleInfo;

  /// No description provided for @actBuildingPermit.
  ///
  /// In en, this message translates to:
  /// **'Building permits'**
  String get actBuildingPermit;

  /// No description provided for @actCommercialPermit.
  ///
  /// In en, this message translates to:
  /// **'Commercial permits'**
  String get actCommercialPermit;

  /// No description provided for @actPropertyServices.
  ///
  /// In en, this message translates to:
  /// **'Property services'**
  String get actPropertyServices;

  /// No description provided for @actElectricity.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get actElectricity;

  /// No description provided for @actWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get actWater;

  /// No description provided for @actInternet.
  ///
  /// In en, this message translates to:
  /// **'Internet & telecom'**
  String get actInternet;

  /// No description provided for @applyNow.
  ///
  /// In en, this message translates to:
  /// **'Apply now'**
  String get applyNow;

  /// No description provided for @requestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Request submitted successfully'**
  String get requestSubmitted;

  /// No description provided for @requestSubmittedDesc.
  ///
  /// In en, this message translates to:
  /// **'Your reference number is {ref}. You can track its status anytime.'**
  String requestSubmittedDesc(Object ref);

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @nationalNumber.
  ///
  /// In en, this message translates to:
  /// **'National number'**
  String get nationalNumber;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsTitle;

  /// No description provided for @myReports.
  ///
  /// In en, this message translates to:
  /// **'My reports'**
  String get myReports;

  /// No description provided for @newReport.
  ///
  /// In en, this message translates to:
  /// **'New report'**
  String get newReport;

  /// No description provided for @noReports.
  ///
  /// In en, this message translates to:
  /// **'No reports yet'**
  String get noReports;

  /// No description provided for @noReportsDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to submit your first report'**
  String get noReportsDesc;

  /// No description provided for @reportTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get reportTitleLabel;

  /// No description provided for @reportTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Brief title of the issue'**
  String get reportTitleHint;

  /// No description provided for @reportDescLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get reportDescLabel;

  /// No description provided for @reportDescHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the problem in detail'**
  String get reportDescHint;

  /// No description provided for @reportCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get reportCategory;

  /// No description provided for @reportPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get reportPhotos;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addPhoto;

  /// No description provided for @reportLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get reportLocation;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get useCurrentLocation;

  /// No description provided for @locationCaptured.
  ///
  /// In en, this message translates to:
  /// **'Location captured'**
  String get locationCaptured;

  /// No description provided for @submitReport.
  ///
  /// In en, this message translates to:
  /// **'Submit report'**
  String get submitReport;

  /// No description provided for @reportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Report submitted'**
  String get reportSubmitted;

  /// No description provided for @reportTimeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get reportTimeline;

  /// No description provided for @catPowerOutage.
  ///
  /// In en, this message translates to:
  /// **'Power outage'**
  String get catPowerOutage;

  /// No description provided for @catWaterLeak.
  ///
  /// In en, this message translates to:
  /// **'Water leakage'**
  String get catWaterLeak;

  /// No description provided for @catRoadDamage.
  ///
  /// In en, this message translates to:
  /// **'Road damage'**
  String get catRoadDamage;

  /// No description provided for @catGarbage.
  ///
  /// In en, this message translates to:
  /// **'Garbage'**
  String get catGarbage;

  /// No description provided for @catCorruption.
  ///
  /// In en, this message translates to:
  /// **'Corruption'**
  String get catCorruption;

  /// No description provided for @catStreetLight.
  ///
  /// In en, this message translates to:
  /// **'Broken street light'**
  String get catStreetLight;

  /// No description provided for @catSewage.
  ///
  /// In en, this message translates to:
  /// **'Sewage problem'**
  String get catSewage;

  /// No description provided for @catPublicSafety.
  ///
  /// In en, this message translates to:
  /// **'Public safety'**
  String get catPublicSafety;

  /// No description provided for @statusSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get statusSubmitted;

  /// No description provided for @statusReviewing.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get statusReviewing;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get statusInProgress;

  /// No description provided for @statusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get statusResolved;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @mapTitle.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapTitle;

  /// No description provided for @mapLegend.
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get mapLegend;

  /// No description provided for @filterReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get filterReports;

  /// No description provided for @filterGovOffices.
  ///
  /// In en, this message translates to:
  /// **'Government offices'**
  String get filterGovOffices;

  /// No description provided for @filterElectricity.
  ///
  /// In en, this message translates to:
  /// **'Electricity offices'**
  String get filterElectricity;

  /// No description provided for @filterWater.
  ///
  /// In en, this message translates to:
  /// **'Water offices'**
  String get filterWater;

  /// No description provided for @filterPolice.
  ///
  /// In en, this message translates to:
  /// **'Police stations'**
  String get filterPolice;

  /// No description provided for @filterHospitals.
  ///
  /// In en, this message translates to:
  /// **'Hospitals'**
  String get filterHospitals;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get personalInfo;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get logoutConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightMode;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get appVersion;

  /// No description provided for @aboutDesc.
  ///
  /// In en, this message translates to:
  /// **'Aden Digital is the official platform for accessing government services for the citizens of Aden.'**
  String get aboutDesc;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneric;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @track.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get track;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
