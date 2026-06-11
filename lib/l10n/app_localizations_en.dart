// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Siyyarte';

  @override
  String get tagline => 'Your car, taken care of.';

  @override
  String get onboardTrackTitle => 'Track';

  @override
  String get onboardTrackBody =>
      'Add your car once. We build its full maintenance schedule automatically.';

  @override
  String get onboardRemindTitle => 'Remind';

  @override
  String get onboardRemindBody =>
      'Smart reminders by mileage and time — including insurance and Mécanique.';

  @override
  String get onboardBudgetTitle => 'Budget';

  @override
  String get onboardBudgetBody =>
      'Estimate service costs in USD and LBP. Works even offline.';

  @override
  String get getStarted => 'Get started';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get login => 'Log in';

  @override
  String get signUp => 'Sign up';

  @override
  String get logout => 'Log out';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone number';

  @override
  String get password => 'Password';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get continueWithPhone => 'Continue with phone';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get fullName => 'Full name';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get vehicles => 'Vehicles';

  @override
  String get history => 'History';

  @override
  String get costs => 'Costs';

  @override
  String get settings => 'Settings';

  @override
  String get addVehicle => 'Add vehicle';

  @override
  String get noVehicles => 'No vehicles yet';

  @override
  String get noVehiclesBody =>
      'Add your first car to see its maintenance schedule.';

  @override
  String get make => 'Make';

  @override
  String get model => 'Model';

  @override
  String get year => 'Year';

  @override
  String get trim => 'Trim';

  @override
  String get engineType => 'Engine type';

  @override
  String get fuelType => 'Fuel type';

  @override
  String get transmission => 'Transmission';

  @override
  String get odometer => 'Odometer';

  @override
  String get plateNumber => 'Plate number';

  @override
  String get insuranceExpiry => 'Insurance expiry';

  @override
  String get inspectionExpiry => 'Mécanique inspection expiry';

  @override
  String get optional => 'optional';

  @override
  String get nextService => 'Next service';

  @override
  String get upcomingReminders => 'Upcoming reminders';

  @override
  String get estimatedCosts => 'Estimated upcoming costs';

  @override
  String get vehicleHealth => 'Vehicle health';

  @override
  String get healthGood => 'Good';

  @override
  String get healthUpcoming => 'Upcoming';

  @override
  String get healthOverdue => 'Overdue';

  @override
  String dueInKm(int km) {
    return 'Due in $km km';
  }

  @override
  String overdueByKm(int km) {
    return 'Overdue by $km km';
  }

  @override
  String dueOn(String date) {
    return 'Due $date';
  }

  @override
  String get markDone => 'Mark as done';

  @override
  String get serviceDate => 'Service date';

  @override
  String get garageName => 'Garage name';

  @override
  String get cost => 'Cost';

  @override
  String get notes => 'Notes';

  @override
  String get attachInvoice => 'Attach invoice photo';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get exportPdf => 'Export as PDF';

  @override
  String get costDisclaimer =>
      'All prices are estimates and may vary by location, garage, exchange rate, and vehicle type.';

  @override
  String get currency => 'Currency';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get city => 'City';

  @override
  String get profile => 'Profile';

  @override
  String get savedOffline => 'Saved locally · will sync';

  @override
  String get serviceOilChange => 'Oil change';

  @override
  String get serviceOilFilter => 'Oil filter';

  @override
  String get serviceAirFilter => 'Air filter';

  @override
  String get serviceSparkPlugs => 'Spark plugs';

  @override
  String get serviceBrakePads => 'Brake pads';

  @override
  String get serviceTires => 'Tires';

  @override
  String get serviceBattery => 'Battery';

  @override
  String get serviceCoolant => 'Coolant';

  @override
  String get serviceTransmissionFluid => 'Transmission fluid';

  @override
  String get serviceTimingBelt => 'Timing belt / chain';

  @override
  String get serviceSuspension => 'Suspension check';

  @override
  String get serviceInspection => 'General inspection';

  @override
  String get maintenanceSchedule => 'Maintenance schedule';

  @override
  String get factoryBased => 'Factory schedule';

  @override
  String get estimateBasis => 'Estimate (wear-based)';

  @override
  String get regulatoryBasis => 'Legal requirement';

  @override
  String get updateOdometer => 'Update odometer';

  @override
  String get serviceHistory => 'Service history';

  @override
  String get lastDone => 'Last done';

  @override
  String get editVehicle => 'Edit vehicle';

  @override
  String get deleteVehicle => 'Delete vehicle';

  @override
  String get never => 'Never recorded';

  @override
  String get noHistory => 'No service records yet';

  @override
  String get addReminder => 'Add reminder';

  @override
  String get reminders => 'Reminders';

  @override
  String get insuranceReminder => 'Insurance renewal';

  @override
  String get inspectionReminder => 'Mécanique inspection';

  @override
  String get costCenter => 'Cost center';

  @override
  String get estimatedTotal => 'Estimated total';

  @override
  String get labor => 'Mechanic labor';

  @override
  String get registrationFees => 'Registration fees';

  @override
  String get insuranceCost => 'Insurance';

  @override
  String get inspectionFees => 'Inspection fees';

  @override
  String get parkingOther => 'Parking / other';

  @override
  String get factoryNote =>
      'Intervals follow manufacturer factory schedules, set to Lebanon\'s severe-conditions schedule. Exact figures vary by model and owner\'s manual.';

  @override
  String get delete => 'Delete';

  @override
  String get undo => 'Undo';

  @override
  String get operatingCosts => 'Operating costs';

  @override
  String get operatingCostsBody =>
      'What you\'ve actually spent per car, from your service records.';

  @override
  String get totalSpent => 'Total spent';

  @override
  String get noCostsYet =>
      'No costs recorded yet. Add a cost when you mark a service done.';

  @override
  String get perThousandKm => 'per 1,000 km';

  @override
  String get allVehicles => 'All vehicles';

  @override
  String servicesLogged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count services',
      one: '1 service',
    );
    return '$_temp0';
  }

  @override
  String get serviceInsurance => 'Insurance';

  @override
  String get serviceRegistration => 'Registration';

  @override
  String get serviceFuel => 'Fuel';

  @override
  String get serviceParking => 'Parking';

  @override
  String get serviceOther => 'Other';

  @override
  String get logCost => 'Log a cost';

  @override
  String get category => 'Category';

  @override
  String get vehiclePassport => 'Vehicle passport (PDF)';

  @override
  String get scanInvoice => 'Scan invoice';

  @override
  String get scanOdometer => 'Scan odometer';

  @override
  String get scanning => 'Reading…';

  @override
  String get scanFailed =>
      'Couldn\'t read the photo. Enter the details manually.';

  @override
  String get siyyartePlus => 'Siyyarte Plus';

  @override
  String get plusTagline => 'Ad-free, with premium tools';

  @override
  String get premiumActive => 'Active';

  @override
  String get premiumFree => 'Free plan';

  @override
  String get premiumRequired => 'Vehicle Passport is a Siyyarte Plus feature.';

  @override
  String get plusBenefitNoAds => 'No ads';

  @override
  String get plusBenefitPassport => 'Vehicle Passport export (PDF)';

  @override
  String get plusBenefitUnlimited => 'Unlimited vehicles';

  @override
  String get plusBenefitPriority => 'Priority reminders & support';

  @override
  String get plusPrice => '\$2.99 / month';

  @override
  String get subscribe => 'Subscribe';

  @override
  String get restorePurchase => 'Restore purchase';

  @override
  String get manageSubscription => 'Manage subscription';

  @override
  String get billingComingSoon => 'Subscriptions open at launch. Stay tuned!';

  @override
  String get activateTest => 'Activate for testing';

  @override
  String get deactivateTest => 'Deactivate (testing)';

  @override
  String get purchaseFailed => 'Purchase didn\'t complete.';

  @override
  String get chooseLanguage => 'Choose your language';

  @override
  String get profileSetup => 'Set up your profile';

  @override
  String get profileSetupBody =>
      'Tell us a bit about you so we can tailor reminders and prices.';

  @override
  String get selectCity => 'Select your city';

  @override
  String get preferredCurrency => 'Preferred currency';

  @override
  String get finish => 'Finish';

  @override
  String get phoneTitle => 'Sign in with phone';

  @override
  String get phoneBody => 'We\'ll text you a 6-digit verification code.';

  @override
  String get phoneHint => '+961 70 123 456';

  @override
  String get sendCode => 'Send code';

  @override
  String get otpTitle => 'Enter the code';

  @override
  String otpBody(String phone) {
    return 'Enter the 6-digit code we sent to $phone.';
  }

  @override
  String get verify => 'Verify';

  @override
  String get resendCode => 'Resend code';

  @override
  String get invalidPhone => 'Please enter a valid phone number';

  @override
  String get account => 'Account';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get exportData => 'Export my data';

  @override
  String get exportDataBody =>
      'Download a PDF of your profile, vehicles and full service history.';

  @override
  String get deleteAccountTitle => 'Delete account';

  @override
  String get deleteAccountWarning =>
      'This permanently deletes your account, vehicles and service history. This cannot be undone.';

  @override
  String get deleteAccountConfirm => 'Yes, delete everything';

  @override
  String get myData => 'My data';
}
