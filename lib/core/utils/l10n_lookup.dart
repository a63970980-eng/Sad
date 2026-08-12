import '../../l10n/app_localizations.dart';

/// Resolves a localization key (used by static catalogs) to its string.
String tr(AppLocalizations l, String key) {
  switch (key) {
    // Services
    case 'svcNationalId':
      return l.svcNationalId;
    case 'svcPassport':
      return l.svcPassport;
    case 'svcDrivingLicense':
      return l.svcDrivingLicense;
    case 'svcVehicle':
      return l.svcVehicle;
    case 'svcMunicipality':
      return l.svcMunicipality;
    case 'svcUtilities':
      return l.svcUtilities;
    // Actions
    case 'actApplyId':
      return l.actApplyId;
    case 'actRenewId':
      return l.actRenewId;
    case 'actTrackId':
      return l.actTrackId;
    case 'actNewPassport':
      return l.actNewPassport;
    case 'actRenewPassport':
      return l.actRenewPassport;
    case 'actTrackPassport':
      return l.actTrackPassport;
    case 'actNewLicense':
      return l.actNewLicense;
    case 'actRenewLicense':
      return l.actRenewLicense;
    case 'actLicenseStatus':
      return l.actLicenseStatus;
    case 'actVehicleReg':
      return l.actVehicleReg;
    case 'actOwnershipTransfer':
      return l.actOwnershipTransfer;
    case 'actVehicleInfo':
      return l.actVehicleInfo;
    case 'actBuildingPermit':
      return l.actBuildingPermit;
    case 'actCommercialPermit':
      return l.actCommercialPermit;
    case 'actPropertyServices':
      return l.actPropertyServices;
    case 'actElectricity':
      return l.actElectricity;
    case 'actWater':
      return l.actWater;
    case 'actInternet':
      return l.actInternet;
    // Report categories
    case 'catPowerOutage':
      return l.catPowerOutage;
    case 'catWaterLeak':
      return l.catWaterLeak;
    case 'catRoadDamage':
      return l.catRoadDamage;
    case 'catGarbage':
      return l.catGarbage;
    case 'catCorruption':
      return l.catCorruption;
    case 'catStreetLight':
      return l.catStreetLight;
    case 'catSewage':
      return l.catSewage;
    case 'catPublicSafety':
      return l.catPublicSafety;
    // Report statuses
    case 'statusSubmitted':
      return l.statusSubmitted;
    case 'statusReviewing':
      return l.statusReviewing;
    case 'statusInProgress':
      return l.statusInProgress;
    case 'statusResolved':
      return l.statusResolved;
    case 'statusRejected':
      return l.statusRejected;
    default:
      return key;
  }
}
