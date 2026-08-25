// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Aden Digital';

  @override
  String get appTagline => 'Your government services, in one place';

  @override
  String get navHome => 'Home';

  @override
  String get navServices => 'Services';

  @override
  String get navReports => 'Reports';

  @override
  String get navMap => 'Map';

  @override
  String get navProfile => 'Profile';

  @override
  String get loginTitle => 'Welcome to Aden Digital';

  @override
  String get loginSubtitle =>
      'Sign in with your phone number to access government services';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get phoneHint => '7XX XXX XXX';

  @override
  String get continueLabel => 'Continue';

  @override
  String get rememberMe => 'Keep me signed in';

  @override
  String get otpTitle => 'Verification Code';

  @override
  String otpSubtitle(Object phone) {
    return 'Enter the 6-digit code sent to $phone';
  }

  @override
  String get verify => 'Verify';

  @override
  String get resendCode => 'Resend code';

  @override
  String resendIn(Object seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get termsNotice =>
      'By continuing you agree to the Terms of Service and Privacy Policy.';

  @override
  String get loginFailed => 'Sign in failed. Please try again.';

  @override
  String get invalidPhone => 'Please enter a valid phone number.';

  @override
  String get invalidOtp => 'Invalid verification code.';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get quickServices => 'Quick Services';

  @override
  String get viewAll => 'View all';

  @override
  String get recentRequests => 'Recent Requests';

  @override
  String get noRecentRequests => 'You have no recent requests';

  @override
  String get recentNotifications => 'Recent Notifications';

  @override
  String get announcements => 'Announcements';

  @override
  String get reportAProblem => 'Report a problem';

  @override
  String get reportShortcutSubtitle => 'Power, water, roads and more';

  @override
  String get searchServices => 'Search for services...';

  @override
  String get searchNotImplemented => 'Search functionality coming soon';

  @override
  String get report => 'Report';

  @override
  String get totalReports => 'Total Reports';

  @override
  String get pending => 'Pending';

  @override
  String get resolved => 'Resolved';

  @override
  String get servicesTitle => 'Government Services';

  @override
  String get svcNationalId => 'National ID';

  @override
  String get svcPassport => 'Passport';

  @override
  String get svcDrivingLicense => 'Driving License';

  @override
  String get svcVehicle => 'Vehicle Services';

  @override
  String get svcMunicipality => 'Municipality';

  @override
  String get svcUtilities => 'Utilities';

  @override
  String get actApplyId => 'Apply for ID';

  @override
  String get actRenewId => 'Renew ID';

  @override
  String get actTrackId => 'Track application';

  @override
  String get actNewPassport => 'New passport';

  @override
  String get actRenewPassport => 'Passport renewal';

  @override
  String get actTrackPassport => 'Track status';

  @override
  String get actNewLicense => 'New license';

  @override
  String get actRenewLicense => 'Renewal';

  @override
  String get actLicenseStatus => 'Status';

  @override
  String get actVehicleReg => 'Vehicle registration';

  @override
  String get actOwnershipTransfer => 'Ownership transfer';

  @override
  String get actVehicleInfo => 'Vehicle information';

  @override
  String get actBuildingPermit => 'Building permits';

  @override
  String get actCommercialPermit => 'Commercial permits';

  @override
  String get actPropertyServices => 'Property services';

  @override
  String get actElectricity => 'Electricity';

  @override
  String get actWater => 'Water';

  @override
  String get actInternet => 'Internet & telecom';

  @override
  String get applyNow => 'Apply now';

  @override
  String get requestSubmitted => 'Request submitted successfully';

  @override
  String requestSubmittedDesc(Object ref) {
    return 'Your reference number is $ref. You can track its status anytime.';
  }

  @override
  String get fullName => 'Full name';

  @override
  String get nationalNumber => 'National number';

  @override
  String get submit => 'Submit';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get myReports => 'My reports';

  @override
  String get newReport => 'New report';

  @override
  String get noReports => 'No reports yet';

  @override
  String get noReportsDesc => 'Tap the + button to submit your first report';

  @override
  String get reportTitleLabel => 'Title';

  @override
  String get reportTitleHint => 'Brief title of the issue';

  @override
  String get reportDescLabel => 'Description';

  @override
  String get reportDescHint => 'Describe the problem in detail';

  @override
  String get reportCategory => 'Category';

  @override
  String get reportPhotos => 'Photos';

  @override
  String get addPhoto => 'Add photo';

  @override
  String get reportLocation => 'Location';

  @override
  String get useCurrentLocation => 'Use current location';

  @override
  String get locationCaptured => 'Location captured';

  @override
  String get submitReport => 'Submit report';

  @override
  String get reportSubmitted => 'Report submitted';

  @override
  String get reportTimeline => 'Timeline';

  @override
  String get catPowerOutage => 'Power outage';

  @override
  String get catWaterLeak => 'Water leakage';

  @override
  String get catRoadDamage => 'Road damage';

  @override
  String get catGarbage => 'Garbage';

  @override
  String get catCorruption => 'Corruption';

  @override
  String get catStreetLight => 'Broken street light';

  @override
  String get catSewage => 'Sewage problem';

  @override
  String get catPublicSafety => 'Public safety';

  @override
  String get statusSubmitted => 'Submitted';

  @override
  String get statusReviewing => 'Under review';

  @override
  String get statusInProgress => 'In progress';

  @override
  String get statusResolved => 'Resolved';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusPending => 'Pending';

  @override
  String get mapTitle => 'Map';

  @override
  String get mapLegend => 'Legend';

  @override
  String get filterReports => 'Reports';

  @override
  String get filterGovOffices => 'Government offices';

  @override
  String get filterElectricity => 'Electricity offices';

  @override
  String get filterWater => 'Water offices';

  @override
  String get filterPolice => 'Police stations';

  @override
  String get filterHospitals => 'Hospitals';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get all => 'All';

  @override
  String get reports => 'Reports';

  @override
  String get services => 'Services';

  @override
  String get system => 'System';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get regionalAnalysis => 'Regional Analysis';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get resolvedReports => 'Resolved';

  @override
  String get rejectedReports => 'Rejected';

  @override
  String get inProgressReports => 'In Progress';

  @override
  String get totalUsers => 'Total Users';

  @override
  String get activeUsers => 'Active Users';

  @override
  String get totalServices => 'Services';

  @override
  String get totalRequests => 'Total Requests';

  @override
  String get pendingRequests => 'Pending';

  @override
  String get completedRequests => 'Completed';

  @override
  String get newReports => 'New Reports';

  @override
  String get noActivity => 'No recent activity';

  @override
  String get profileTitle => 'Profile';

  @override
  String get personalInfo => 'Personal information';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get notifications => 'Notifications';

  @override
  String get about => 'About';

  @override
  String get logout => 'Sign out';

  @override
  String get logoutConfirm => 'Are you sure you want to sign out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get systemDefault => 'System default';

  @override
  String get lightMode => 'Light';

  @override
  String get appVersion => 'Version';

  @override
  String get aboutDesc =>
      'Aden Digital is the official platform for accessing government services for the citizens of Aden.';

  @override
  String get retry => 'Retry';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get loading => 'Loading...';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get track => 'Track';

  @override
  String get details => 'Details';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Close';

  @override
  String get search => 'Search';

  @override
  String get stepNext => 'Next';

  @override
  String get stepPrevious => 'Previous';

  @override
  String get reviewAndSubmit => 'Review & Submit';

  @override
  String stepProgress(Object current, Object total) {
    return 'Step $current of $total';
  }

  @override
  String get districtLabel => 'District in Aden';

  @override
  String get selectDistrict => 'Select District';

  @override
  String get districtCrater => 'Crater (Seera)';

  @override
  String get districtMaalla => 'Mualla';

  @override
  String get districtTawahi => 'Tawahi';

  @override
  String get districtKhorMaksar => 'Khor Maksar';

  @override
  String get districtMansoura => 'Mansoura';

  @override
  String get districtSheikhOthman => 'Sheikh Othman';

  @override
  String get districtDarSad => 'Dar Saad';

  @override
  String get districtBuraiqeh => 'Buraiqeh';

  @override
  String get reportIdentityType => 'Report Identity';

  @override
  String get reportIdentityNamed => 'Submit under my real name';

  @override
  String get reportIdentityAnonymous => 'Submit anonymously';

  @override
  String get reportIdentityNotice =>
      'Anonymous reports are treated with equal urgency and strict confidentiality';

  @override
  String get stepApplicantDetails => 'Applicant Details';

  @override
  String get stepServiceDetails => 'Service Details';

  @override
  String get stepDocuments => 'Documents & Attachments';

  @override
  String get stepReview => 'Review Information';

  @override
  String get stepCategory => 'Report Category';

  @override
  String get stepLocation => 'Location';

  @override
  String get stepDescription => 'Problem Description';

  @override
  String get stepPhotos => 'Photos & Evidence';

  @override
  String get stepAdditionalInfo => 'Additional Info';

  @override
  String get stepIdentity => 'Report Identity';

  @override
  String get attachDocument => 'Attach Document';

  @override
  String get documentNotice =>
      'Please make sure images are clear and match all official records';

  @override
  String get severityLevel => 'Severity Level';

  @override
  String get severityLow => 'Minor / Not Urgent';

  @override
  String get severityMedium => 'Moderate / Needs Attention';

  @override
  String get severityHigh => 'Critical / Urgent';

  @override
  String get additionalNotes => 'Additional Notes';

  @override
  String get additionalNotesHint =>
      'Enter any additional details to assist field teams...';
}
