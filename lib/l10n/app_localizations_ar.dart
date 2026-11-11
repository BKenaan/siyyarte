// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'سيّارتي';

  @override
  String get tagline => 'سيّارتك بأمان.';

  @override
  String get onboardTrackTitle => 'تتبّع';

  @override
  String get onboardTrackBody =>
      'أضِف سيّارتك مرّة واحدة، ونحن نُنشئ جدول صيانتها كاملاً تلقائياً.';

  @override
  String get onboardRemindTitle => 'تذكير';

  @override
  String get onboardRemindBody =>
      'تذكيرات ذكية حسب المسافة والوقت — بما في ذلك التأمين والميكانيك.';

  @override
  String get onboardBudgetTitle => 'ميزانية';

  @override
  String get onboardBudgetBody =>
      'قدّر تكاليف الصيانة بالدولار والليرة. يعمل حتى دون إنترنت.';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get skip => 'تخطّي';

  @override
  String get next => 'التالي';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get phone => 'رقم الهاتف';

  @override
  String get password => 'كلمة المرور';

  @override
  String get continueWithGoogle => 'المتابعة عبر Google';

  @override
  String get continueWithApple => 'المتابعة عبر Apple';

  @override
  String get continueWithPhone => 'المتابعة عبر الهاتف';

  @override
  String get noAccount => 'ليس لديك حساب؟';

  @override
  String get haveAccount => 'لديك حساب بالفعل؟';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get dashboard => 'الرئيسية';

  @override
  String get vehicles => 'السيّارات';

  @override
  String get history => 'السجلّ';

  @override
  String get costs => 'التكاليف';

  @override
  String get settings => 'الإعدادات';

  @override
  String get addVehicle => 'إضافة سيّارة';

  @override
  String get noVehicles => 'لا توجد سيّارات بعد';

  @override
  String get noVehiclesBody => 'أضِف سيّارتك الأولى لرؤية جدول صيانتها.';

  @override
  String get make => 'الماركة';

  @override
  String get model => 'الموديل';

  @override
  String get year => 'السنة';

  @override
  String get trim => 'الفئة';

  @override
  String get engineType => 'نوع المحرّك';

  @override
  String get fuelType => 'نوع الوقود';

  @override
  String get transmission => 'ناقل الحركة';

  @override
  String get odometer => 'عدّاد المسافة';

  @override
  String get plateNumber => 'رقم اللوحة';

  @override
  String get insuranceExpiry => 'انتهاء التأمين';

  @override
  String get inspectionExpiry => 'انتهاء فحص الميكانيك';

  @override
  String get optional => 'اختياري';

  @override
  String get nextService => 'الصيانة القادمة';

  @override
  String get upcomingReminders => 'التذكيرات القادمة';

  @override
  String get estimatedCosts => 'التكاليف المتوقّعة';

  @override
  String get vehicleHealth => 'حالة السيّارة';

  @override
  String get healthGood => 'جيّدة';

  @override
  String get healthUpcoming => 'قريباً';

  @override
  String get healthOverdue => 'متأخّرة';

  @override
  String dueInKm(int km) {
    return 'مستحقّة بعد $km كم';
  }

  @override
  String overdueByKm(int km) {
    return 'متأخّرة بمقدار $km كم';
  }

  @override
  String dueOn(String date) {
    return 'مستحقّة في $date';
  }

  @override
  String get markDone => 'تحديد كمنجزة';

  @override
  String get serviceDate => 'تاريخ الصيانة';

  @override
  String get garageName => 'اسم الكراج';

  @override
  String get cost => 'التكلفة';

  @override
  String get notes => 'ملاحظات';

  @override
  String get attachInvoice => 'إرفاق صورة الفاتورة';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get exportPdf => 'تصدير PDF';

  @override
  String get costDisclaimer =>
      'جميع الأسعار تقديرية وقد تختلف حسب المنطقة والكراج وسعر الصرف ونوع السيّارة.';

  @override
  String get currency => 'العملة';

  @override
  String get language => 'اللغة';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get city => 'المدينة';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get savedOffline => 'محفوظ محلياً · سيُزامن';

  @override
  String get serviceOilChange => 'تغيير الزيت';

  @override
  String get serviceOilFilter => 'فلتر الزيت';

  @override
  String get serviceAirFilter => 'فلتر الهواء';

  @override
  String get serviceSparkPlugs => 'شمعات الإشعال';

  @override
  String get serviceBrakePads => 'تيل الفرامل';

  @override
  String get serviceTires => 'الإطارات';

  @override
  String get serviceBattery => 'البطارية';

  @override
  String get serviceCoolant => 'سائل التبريد';

  @override
  String get serviceTransmissionFluid => 'زيت الغير';

  @override
  String get serviceTimingBelt => 'سير/سلسلة التايمنغ';

  @override
  String get serviceSuspension => 'فحص نظام التعليق';

  @override
  String get serviceInspection => 'فحص عام';

  @override
  String get maintenanceSchedule => 'جدول الصيانة';

  @override
  String get factoryBased => 'جدول المصنّع';

  @override
  String get estimateBasis => 'تقديري (حسب التآكل)';

  @override
  String get regulatoryBasis => 'إلزامي قانونياً';

  @override
  String get updateOdometer => 'تحديث العدّاد';

  @override
  String get serviceHistory => 'سجلّ الصيانة';

  @override
  String get lastDone => 'آخر مرة';

  @override
  String get editVehicle => 'تعديل السيّارة';

  @override
  String get deleteVehicle => 'حذف السيّارة';

  @override
  String get never => 'لم تُسجّل';

  @override
  String get noHistory => 'لا توجد سجلّات صيانة بعد';

  @override
  String get addReminder => 'إضافة تذكير';

  @override
  String get reminders => 'التذكيرات';

  @override
  String get insuranceReminder => 'تجديد التأمين';

  @override
  String get inspectionReminder => 'فحص الميكانيك';

  @override
  String get costCenter => 'مركز التكاليف';

  @override
  String get estimatedTotal => 'الإجمالي التقديري';

  @override
  String get labor => 'أجرة الميكانيكي';

  @override
  String get registrationFees => 'رسوم التسجيل';

  @override
  String get insuranceCost => 'التأمين';

  @override
  String get inspectionFees => 'رسوم الفحص';

  @override
  String get parkingOther => 'موقف/أخرى';

  @override
  String get factoryNote =>
      'تتبع الفترات جداول المصنّع، مضبوطة على جدول الظروف القاسية في لبنان. تختلف الأرقام الدقيقة حسب الموديل ودليل المالك.';

  @override
  String get delete => 'حذف';

  @override
  String get undo => 'تراجع';

  @override
  String get operatingCosts => 'تكاليف التشغيل';

  @override
  String get operatingCostsBody =>
      'ما أنفقته فعلياً على كل سيّارة، من سجلّ الصيانة.';

  @override
  String get totalSpent => 'إجمالي المصروف';

  @override
  String get noCostsYet =>
      'لا توجد تكاليف مسجّلة بعد. أضِف التكلفة عند تحديد صيانة كمنجزة.';

  @override
  String get perThousandKm => 'لكل ١٠٠٠ كم';

  @override
  String get allVehicles => 'كل السيّارات';

  @override
  String servicesLogged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عمليات صيانة',
      one: 'عملية صيانة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get serviceInsurance => 'التأمين';

  @override
  String get serviceRegistration => 'التسجيل (الميكانيك)';

  @override
  String get serviceFuel => 'الوقود';

  @override
  String get serviceParking => 'موقف السيّارة';

  @override
  String get serviceOther => 'أخرى';

  @override
  String get logCost => 'تسجيل تكلفة';

  @override
  String get category => 'الفئة';

  @override
  String get vehiclePassport => 'جواز السيّارة (PDF)';

  @override
  String get scanInvoice => 'مسح الفاتورة';

  @override
  String get scanOdometer => 'مسح العدّاد';

  @override
  String get scanning => 'جارٍ القراءة…';

  @override
  String get scanFailed => 'تعذّرت قراءة الصورة. أدخل التفاصيل يدوياً.';

  @override
  String get siyyartePlus => 'سيّارتي بلَس';

  @override
  String get plusTagline => 'بدون إعلانات، مع أدوات مميّزة';

  @override
  String get premiumActive => 'مُفعّل';

  @override
  String get premiumFree => 'الخطة المجانية';

  @override
  String get premiumRequired => 'جواز السيّارة ميزة ضمن سيّارتي بلَس.';

  @override
  String get plusBenefitNoAds => 'بدون إعلانات';

  @override
  String get plusBenefitPassport => 'تصدير جواز السيّارة (PDF)';

  @override
  String get plusBenefitUnlimited =>
      'سيّارات غير محدودة (الخطة المجانية: سيّارتان)';

  @override
  String get plusBenefitPriority => 'تنبيهات على كل أجهزتك';

  @override
  String get plusPrice => '٢٫٩٩ \$ / شهرياً';

  @override
  String get subscribe => 'اشترك';

  @override
  String get restorePurchase => 'استعادة الشراء';

  @override
  String get manageSubscription => 'إدارة الاشتراك';

  @override
  String get billingComingSoon => 'الاشتراكات ستتوفّر عند الإطلاق. ترقّبوا!';

  @override
  String get activateTest => 'تفعيل للتجربة';

  @override
  String get deactivateTest => 'إلغاء التفعيل (تجربة)';

  @override
  String get purchaseFailed => 'لم تكتمل عملية الشراء.';

  @override
  String get chooseLanguage => 'اختر لغتك';

  @override
  String get profileSetup => 'إعداد ملفك الشخصي';

  @override
  String get profileSetupBody =>
      'أخبرنا قليلاً عنك لنخصّص لك التذكيرات والأسعار.';

  @override
  String get selectCity => 'اختر مدينتك';

  @override
  String get preferredCurrency => 'العملة المفضّلة';

  @override
  String get finish => 'إنهاء';

  @override
  String get phoneTitle => 'الدخول عبر الهاتف';

  @override
  String get phoneBody => 'سنرسل لك رمز تحقّق من ٦ أرقام.';

  @override
  String get phoneHint => '+961 70 123 456';

  @override
  String get sendCode => 'إرسال الرمز';

  @override
  String get otpTitle => 'أدخل الرمز';

  @override
  String otpBody(String phone) {
    return 'أدخل الرمز المؤلّف من ٦ أرقام الذي أرسلناه إلى $phone.';
  }

  @override
  String get verify => 'تحقّق';

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String get invalidPhone => 'الرجاء إدخال رقم هاتف صحيح';

  @override
  String get account => 'الحساب';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get exportData => 'تصدير بياناتي';

  @override
  String get exportDataBody =>
      'نزّل ملف PDF يحتوي على ملفك الشخصي وسيّاراتك وكامل سجلّ الصيانة.';

  @override
  String get deleteAccountTitle => 'حذف الحساب';

  @override
  String get deleteAccountWarning =>
      'سيؤدي هذا إلى حذف حسابك وسيّاراتك وسجلّ الصيانة نهائياً. لا يمكن التراجع عن ذلك.';

  @override
  String get deleteAccountConfirm => 'نعم، احذف كل شيء';

  @override
  String get myData => 'بياناتي';
}
