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
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Siyyarte'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Your car, taken care of.'**
  String get tagline;

  /// No description provided for @onboardTrackTitle.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get onboardTrackTitle;

  /// No description provided for @onboardTrackBody.
  ///
  /// In en, this message translates to:
  /// **'Add your car once. We build its full maintenance schedule automatically.'**
  String get onboardTrackBody;

  /// No description provided for @onboardRemindTitle.
  ///
  /// In en, this message translates to:
  /// **'Remind'**
  String get onboardRemindTitle;

  /// No description provided for @onboardRemindBody.
  ///
  /// In en, this message translates to:
  /// **'Smart reminders by mileage and time — including insurance and Mécanique.'**
  String get onboardRemindBody;

  /// No description provided for @onboardBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get onboardBudgetTitle;

  /// No description provided for @onboardBudgetBody.
  ///
  /// In en, this message translates to:
  /// **'Estimate service costs in USD and LBP. Works even offline.'**
  String get onboardBudgetBody;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phone;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @continueWithPhone.
  ///
  /// In en, this message translates to:
  /// **'Continue with phone'**
  String get continueWithPhone;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @vehicles.
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get vehicles;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @costs.
  ///
  /// In en, this message translates to:
  /// **'Costs'**
  String get costs;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @addVehicle.
  ///
  /// In en, this message translates to:
  /// **'Add vehicle'**
  String get addVehicle;

  /// No description provided for @noVehicles.
  ///
  /// In en, this message translates to:
  /// **'No vehicles yet'**
  String get noVehicles;

  /// No description provided for @noVehiclesBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first car to see its maintenance schedule.'**
  String get noVehiclesBody;

  /// No description provided for @make.
  ///
  /// In en, this message translates to:
  /// **'Make'**
  String get make;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @trim.
  ///
  /// In en, this message translates to:
  /// **'Trim'**
  String get trim;

  /// No description provided for @engineType.
  ///
  /// In en, this message translates to:
  /// **'Engine type'**
  String get engineType;

  /// No description provided for @fuelType.
  ///
  /// In en, this message translates to:
  /// **'Fuel type'**
  String get fuelType;

  /// No description provided for @transmission.
  ///
  /// In en, this message translates to:
  /// **'Transmission'**
  String get transmission;

  /// No description provided for @odometer.
  ///
  /// In en, this message translates to:
  /// **'Odometer'**
  String get odometer;

  /// No description provided for @plateNumber.
  ///
  /// In en, this message translates to:
  /// **'Plate number'**
  String get plateNumber;

  /// No description provided for @insuranceExpiry.
  ///
  /// In en, this message translates to:
  /// **'Insurance expiry'**
  String get insuranceExpiry;

  /// No description provided for @inspectionExpiry.
  ///
  /// In en, this message translates to:
  /// **'Mécanique inspection expiry'**
  String get inspectionExpiry;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get optional;

  /// No description provided for @nextService.
  ///
  /// In en, this message translates to:
  /// **'Next service'**
  String get nextService;

  /// No description provided for @upcomingReminders.
  ///
  /// In en, this message translates to:
  /// **'Upcoming reminders'**
  String get upcomingReminders;

  /// No description provided for @estimatedCosts.
  ///
  /// In en, this message translates to:
  /// **'Estimated upcoming costs'**
  String get estimatedCosts;

  /// No description provided for @vehicleHealth.
  ///
  /// In en, this message translates to:
  /// **'Vehicle health'**
  String get vehicleHealth;

  /// No description provided for @healthGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get healthGood;

  /// No description provided for @healthUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get healthUpcoming;

  /// No description provided for @healthOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get healthOverdue;

  /// No description provided for @dueInKm.
  ///
  /// In en, this message translates to:
  /// **'Due in {km} km'**
  String dueInKm(int km);

  /// No description provided for @overdueByKm.
  ///
  /// In en, this message translates to:
  /// **'Overdue by {km} km'**
  String overdueByKm(int km);

  /// No description provided for @dueOn.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String dueOn(String date);

  /// No description provided for @markDone.
  ///
  /// In en, this message translates to:
  /// **'Mark as done'**
  String get markDone;

  /// No description provided for @serviceDate.
  ///
  /// In en, this message translates to:
  /// **'Service date'**
  String get serviceDate;

  /// No description provided for @garageName.
  ///
  /// In en, this message translates to:
  /// **'Garage name'**
  String get garageName;

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get cost;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @attachInvoice.
  ///
  /// In en, this message translates to:
  /// **'Attach invoice photo'**
  String get attachInvoice;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export as PDF'**
  String get exportPdf;

  /// No description provided for @costDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'All prices are estimates and may vary by location, garage, exchange rate, and vehicle type.'**
  String get costDisclaimer;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @savedOffline.
  ///
  /// In en, this message translates to:
  /// **'Saved locally · will sync'**
  String get savedOffline;

  /// No description provided for @serviceOilChange.
  ///
  /// In en, this message translates to:
  /// **'Oil change'**
  String get serviceOilChange;

  /// No description provided for @serviceOilFilter.
  ///
  /// In en, this message translates to:
  /// **'Oil filter'**
  String get serviceOilFilter;

  /// No description provided for @serviceAirFilter.
  ///
  /// In en, this message translates to:
  /// **'Air filter'**
  String get serviceAirFilter;

  /// No description provided for @serviceSparkPlugs.
  ///
  /// In en, this message translates to:
  /// **'Spark plugs'**
  String get serviceSparkPlugs;

  /// No description provided for @serviceBrakePads.
  ///
  /// In en, this message translates to:
  /// **'Brake pads'**
  String get serviceBrakePads;

  /// No description provided for @serviceTires.
  ///
  /// In en, this message translates to:
  /// **'Tires'**
  String get serviceTires;

  /// No description provided for @serviceBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get serviceBattery;

  /// No description provided for @serviceCoolant.
  ///
  /// In en, this message translates to:
  /// **'Coolant'**
  String get serviceCoolant;

  /// No description provided for @serviceTransmissionFluid.
  ///
  /// In en, this message translates to:
  /// **'Transmission fluid'**
  String get serviceTransmissionFluid;

  /// No description provided for @serviceTimingBelt.
  ///
  /// In en, this message translates to:
  /// **'Timing belt / chain'**
  String get serviceTimingBelt;

  /// No description provided for @serviceSuspension.
  ///
  /// In en, this message translates to:
  /// **'Suspension check'**
  String get serviceSuspension;

  /// No description provided for @serviceInspection.
  ///
  /// In en, this message translates to:
  /// **'General inspection'**
  String get serviceInspection;

  /// No description provided for @maintenanceSchedule.
  ///
  /// In en, this message translates to:
  /// **'Maintenance schedule'**
  String get maintenanceSchedule;

  /// No description provided for @factoryBased.
  ///
  /// In en, this message translates to:
  /// **'Factory schedule'**
  String get factoryBased;

  /// No description provided for @estimateBasis.
  ///
  /// In en, this message translates to:
  /// **'Estimate (wear-based)'**
  String get estimateBasis;

  /// No description provided for @regulatoryBasis.
  ///
  /// In en, this message translates to:
  /// **'Legal requirement'**
  String get regulatoryBasis;

  /// No description provided for @updateOdometer.
  ///
  /// In en, this message translates to:
  /// **'Update odometer'**
  String get updateOdometer;

  /// No description provided for @serviceHistory.
  ///
  /// In en, this message translates to:
  /// **'Service history'**
  String get serviceHistory;

  /// No description provided for @lastDone.
  ///
  /// In en, this message translates to:
  /// **'Last done'**
  String get lastDone;

  /// No description provided for @editVehicle.
  ///
  /// In en, this message translates to:
  /// **'Edit vehicle'**
  String get editVehicle;

  /// No description provided for @deleteVehicle.
  ///
  /// In en, this message translates to:
  /// **'Delete vehicle'**
  String get deleteVehicle;

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never recorded'**
  String get never;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No service records yet'**
  String get noHistory;

  /// No description provided for @addReminder.
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get addReminder;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @insuranceReminder.
  ///
  /// In en, this message translates to:
  /// **'Insurance renewal'**
  String get insuranceReminder;

  /// No description provided for @inspectionReminder.
  ///
  /// In en, this message translates to:
  /// **'Mécanique inspection'**
  String get inspectionReminder;

  /// No description provided for @costCenter.
  ///
  /// In en, this message translates to:
  /// **'Cost center'**
  String get costCenter;

  /// No description provided for @estimatedTotal.
  ///
  /// In en, this message translates to:
  /// **'Estimated total'**
  String get estimatedTotal;

  /// No description provided for @labor.
  ///
  /// In en, this message translates to:
  /// **'Mechanic labor'**
  String get labor;

  /// No description provided for @registrationFees.
  ///
  /// In en, this message translates to:
  /// **'Registration fees'**
  String get registrationFees;

  /// No description provided for @insuranceCost.
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get insuranceCost;

  /// No description provided for @inspectionFees.
  ///
  /// In en, this message translates to:
  /// **'Inspection fees'**
  String get inspectionFees;

  /// No description provided for @parkingOther.
  ///
  /// In en, this message translates to:
  /// **'Parking / other'**
  String get parkingOther;

  /// No description provided for @factoryNote.
  ///
  /// In en, this message translates to:
  /// **'Intervals follow manufacturer factory schedules, set to Lebanon\'s severe-conditions schedule. Exact figures vary by model and owner\'s manual.'**
  String get factoryNote;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @operatingCosts.
  ///
  /// In en, this message translates to:
  /// **'Operating costs'**
  String get operatingCosts;

  /// No description provided for @operatingCostsBody.
  ///
  /// In en, this message translates to:
  /// **'What you\'ve actually spent per car, from your service records.'**
  String get operatingCostsBody;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total spent'**
  String get totalSpent;

  /// No description provided for @noCostsYet.
  ///
  /// In en, this message translates to:
  /// **'No costs recorded yet. Add a cost when you mark a service done.'**
  String get noCostsYet;

  /// No description provided for @perThousandKm.
  ///
  /// In en, this message translates to:
  /// **'per 1,000 km'**
  String get perThousandKm;

  /// No description provided for @allVehicles.
  ///
  /// In en, this message translates to:
  /// **'All vehicles'**
  String get allVehicles;

  /// No description provided for @servicesLogged.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 service} other{{count} services}}'**
  String servicesLogged(int count);

  /// No description provided for @serviceInsurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get serviceInsurance;

  /// No description provided for @serviceRegistration.
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get serviceRegistration;

  /// No description provided for @serviceFuel.
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get serviceFuel;

  /// No description provided for @serviceParking.
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get serviceParking;

  /// No description provided for @serviceOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get serviceOther;

  /// No description provided for @logCost.
  ///
  /// In en, this message translates to:
  /// **'Log a cost'**
  String get logCost;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @vehiclePassport.
  ///
  /// In en, this message translates to:
  /// **'Service booklet (PDF)'**
  String get vehiclePassport;

  /// No description provided for @scanInvoice.
  ///
  /// In en, this message translates to:
  /// **'Scan invoice'**
  String get scanInvoice;

  /// No description provided for @scanOdometer.
  ///
  /// In en, this message translates to:
  /// **'Scan odometer'**
  String get scanOdometer;

  /// No description provided for @scanning.
  ///
  /// In en, this message translates to:
  /// **'Reading…'**
  String get scanning;

  /// No description provided for @scanFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read the photo. Enter the details manually.'**
  String get scanFailed;

  /// No description provided for @siyyartePlus.
  ///
  /// In en, this message translates to:
  /// **'Siyyarte Plus'**
  String get siyyartePlus;

  /// No description provided for @plusTagline.
  ///
  /// In en, this message translates to:
  /// **'Ad-free, with premium tools'**
  String get plusTagline;

  /// No description provided for @premiumActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get premiumActive;

  /// No description provided for @premiumFree.
  ///
  /// In en, this message translates to:
  /// **'Free plan'**
  String get premiumFree;

  /// No description provided for @premiumRequired.
  ///
  /// In en, this message translates to:
  /// **'The Service Booklet is a Siyyarte Plus feature.'**
  String get premiumRequired;

  /// No description provided for @plusBenefitNoAds.
  ///
  /// In en, this message translates to:
  /// **'No ads'**
  String get plusBenefitNoAds;

  /// No description provided for @plusBenefitPassport.
  ///
  /// In en, this message translates to:
  /// **'Service Booklet export (PDF)'**
  String get plusBenefitPassport;

  /// No description provided for @plusBenefitUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited cars (free plan: 2)'**
  String get plusBenefitUnlimited;

  /// No description provided for @plusBenefitPriority.
  ///
  /// In en, this message translates to:
  /// **'Cross-device push reminders'**
  String get plusBenefitPriority;

  /// No description provided for @plusPrice.
  ///
  /// In en, this message translates to:
  /// **'\$2.99 / month'**
  String get plusPrice;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @restorePurchase.
  ///
  /// In en, this message translates to:
  /// **'Restore purchase'**
  String get restorePurchase;

  /// No description provided for @manageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get manageSubscription;

  /// No description provided for @billingComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions open at launch. Stay tuned!'**
  String get billingComingSoon;

  /// No description provided for @activateTest.
  ///
  /// In en, this message translates to:
  /// **'Activate for testing'**
  String get activateTest;

  /// No description provided for @deactivateTest.
  ///
  /// In en, this message translates to:
  /// **'Deactivate (testing)'**
  String get deactivateTest;

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase didn\'t complete.'**
  String get purchaseFailed;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseLanguage;

  /// No description provided for @profileSetup.
  ///
  /// In en, this message translates to:
  /// **'Set up your profile'**
  String get profileSetup;

  /// No description provided for @profileSetupBody.
  ///
  /// In en, this message translates to:
  /// **'Tell us a bit about you so we can tailor reminders and prices.'**
  String get profileSetupBody;

  /// No description provided for @selectCity.
  ///
  /// In en, this message translates to:
  /// **'Select your city'**
  String get selectCity;

  /// No description provided for @preferredCurrency.
  ///
  /// In en, this message translates to:
  /// **'Preferred currency'**
  String get preferredCurrency;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @phoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with phone'**
  String get phoneTitle;

  /// No description provided for @phoneBody.
  ///
  /// In en, this message translates to:
  /// **'We\'ll text you a 6-digit verification code.'**
  String get phoneBody;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'+961 70 123 456'**
  String get phoneHint;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get otpTitle;

  /// No description provided for @otpBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code we sent to {phone}.'**
  String otpBody(String phone);

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

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get invalidPhone;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export my data'**
  String get exportData;

  /// No description provided for @exportDataBody.
  ///
  /// In en, this message translates to:
  /// **'Download a PDF of your profile, vehicles and full service history.'**
  String get exportDataBody;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account, vehicles and service history. This cannot be undone.'**
  String get deleteAccountWarning;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Yes, delete everything'**
  String get deleteAccountConfirm;

  /// No description provided for @myData.
  ///
  /// In en, this message translates to:
  /// **'My data'**
  String get myData;
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
    'that was used.',
  );
}
