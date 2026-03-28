import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Aura Health'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'QUICK ACTIONS'**
  String get quickActions;

  /// No description provided for @anemiaScan.
  ///
  /// In en, this message translates to:
  /// **'Anemia Scan'**
  String get anemiaScan;

  /// No description provided for @instantCheck.
  ///
  /// In en, this message translates to:
  /// **'Instant Check'**
  String get instantCheck;

  /// No description provided for @tbScreening.
  ///
  /// In en, this message translates to:
  /// **'TB Screening'**
  String get tbScreening;

  /// No description provided for @respiratoryAi.
  ///
  /// In en, this message translates to:
  /// **'Respiratory AI'**
  String get respiratoryAi;

  /// No description provided for @appointment.
  ///
  /// In en, this message translates to:
  /// **'Appointment'**
  String get appointment;

  /// No description provided for @bookVisit.
  ///
  /// In en, this message translates to:
  /// **'Book a visit'**
  String get bookVisit;

  /// No description provided for @abhaId.
  ///
  /// In en, this message translates to:
  /// **'ABHA ID'**
  String get abhaId;

  /// No description provided for @digitalHealth.
  ///
  /// In en, this message translates to:
  /// **'Digital health'**
  String get digitalHealth;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'RECENT ACTIVITY'**
  String get recentActivity;

  /// No description provided for @anemiaScanCompleted.
  ///
  /// In en, this message translates to:
  /// **'Anemia Scan Completed'**
  String get anemiaScanCompleted;

  /// No description provided for @resultHealthyRange.
  ///
  /// In en, this message translates to:
  /// **'Result: Healthy Range'**
  String get resultHealthyRange;

  /// No description provided for @time2hAgo.
  ///
  /// In en, this message translates to:
  /// **'2h ago'**
  String get time2hAgo;

  /// No description provided for @linkedToVillageClinic.
  ///
  /// In en, this message translates to:
  /// **'Linked to Village Clinic'**
  String get linkedToVillageClinic;

  /// No description provided for @dataSyncSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Data Sync Successful'**
  String get dataSyncSuccessful;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @todayTip.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Tip: Eat iron-rich foods like spinach and jaggery daily to prevent anemia.'**
  String get todayTip;

  /// No description provided for @heroTagline.
  ///
  /// In en, this message translates to:
  /// **'Your Village.\nYour Health. Your Data.'**
  String get heroTagline;

  /// No description provided for @scansDone.
  ///
  /// In en, this message translates to:
  /// **'2 Scans Done'**
  String get scansDone;

  /// No description provided for @appointmentsPending.
  ///
  /// In en, this message translates to:
  /// **'1 Appt Pending'**
  String get appointmentsPending;

  /// No description provided for @abhaLinked.
  ///
  /// In en, this message translates to:
  /// **'ABHA ✓ Linked'**
  String get abhaLinked;

  /// No description provided for @scanPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Scan Screen Placeholder'**
  String get scanPlaceholder;

  /// No description provided for @appointmentsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Appointments Placeholder'**
  String get appointmentsPlaceholder;

  /// No description provided for @abhaPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'ABHA ID Placeholder'**
  String get abhaPlaceholder;

  /// No description provided for @profilePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Profile Placeholder'**
  String get profilePlaceholder;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'HOME'**
  String get navHome;

  /// No description provided for @navScan.
  ///
  /// In en, this message translates to:
  /// **'SCAN'**
  String get navScan;

  /// No description provided for @navAppointments.
  ///
  /// In en, this message translates to:
  /// **'APPOINT'**
  String get navAppointments;

  /// No description provided for @navAbha.
  ///
  /// In en, this message translates to:
  /// **'ABHA'**
  String get navAbha;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get navProfile;

  /// No description provided for @languageSwitch.
  ///
  /// In en, this message translates to:
  /// **'EN/HI'**
  String get languageSwitch;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @howAreYouFeeling.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling today?'**
  String get howAreYouFeeling;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @signUpSub.
  ///
  /// In en, this message translates to:
  /// **'Join the Aura community and manage your health seamlessly.'**
  String get signUpSub;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log In'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get dontHaveAccount;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get invalidEmail;

  /// No description provided for @invalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get invalidPassword;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 10-digit phone number'**
  String get invalidPhone;

  /// No description provided for @registering.
  ///
  /// In en, this message translates to:
  /// **'Registering...'**
  String get registering;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a 5-digit code to'**
  String get otpSentTo;

  /// No description provided for @verifyAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Verify & Continue'**
  String get verifyAndContinue;

  /// No description provided for @enterAllOtpDigits.
  ///
  /// In en, this message translates to:
  /// **'Please enter all 5 digits'**
  String get enterAllOtpDigits;

  /// No description provided for @mockOtpHint.
  ///
  /// In en, this message translates to:
  /// **'Use OTP: 12345'**
  String get mockOtpHint;

  /// No description provided for @profileVitalMetrics.
  ///
  /// In en, this message translates to:
  /// **'Vital Metrics / महत्वपूर्ण आँकड़े'**
  String get profileVitalMetrics;

  /// No description provided for @profileScanHistory.
  ///
  /// In en, this message translates to:
  /// **'Scan History / स्कैन इतिहास'**
  String get profileScanHistory;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings / सेटिंग्स'**
  String get profileSettings;

  /// No description provided for @profileInitials.
  ///
  /// In en, this message translates to:
  /// **'RA'**
  String get profileInitials;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Rohan Agarwal'**
  String get profileName;

  /// No description provided for @profileAbhaPrefix.
  ///
  /// In en, this message translates to:
  /// **'ABHA'**
  String get profileAbhaPrefix;

  /// No description provided for @profileAbhaId.
  ///
  /// In en, this message translates to:
  /// **'91-2034-5891-1022'**
  String get profileAbhaId;

  /// No description provided for @profileAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get profileAge;

  /// No description provided for @profileGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get profileGender;

  /// No description provided for @profileGenderValue.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get profileGenderValue;

  /// No description provided for @profileBlood.
  ///
  /// In en, this message translates to:
  /// **'Blood'**
  String get profileBlood;

  /// No description provided for @profileBmiIndex.
  ///
  /// In en, this message translates to:
  /// **'BMI Index'**
  String get profileBmiIndex;

  /// No description provided for @profileHemoglobin.
  ///
  /// In en, this message translates to:
  /// **'Hemoglobin'**
  String get profileHemoglobin;

  /// No description provided for @profileNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get profileNormal;

  /// No description provided for @profileHealthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get profileHealthy;

  /// No description provided for @profileFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Follow-up'**
  String get profileFollowUp;

  /// No description provided for @profileScanDate1.
  ///
  /// In en, this message translates to:
  /// **'Oct 24, 2023'**
  String get profileScanDate1;

  /// No description provided for @profileScanTitle1.
  ///
  /// In en, this message translates to:
  /// **'Digital Chest X-Ray'**
  String get profileScanTitle1;

  /// No description provided for @profileScanSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'St. Jude Medical Center'**
  String get profileScanSubtitle1;

  /// No description provided for @profileScanDate2.
  ///
  /// In en, this message translates to:
  /// **'Sep 12, 2023'**
  String get profileScanDate2;

  /// No description provided for @profileScanTitle2.
  ///
  /// In en, this message translates to:
  /// **'CBC & Lipids'**
  String get profileScanTitle2;

  /// No description provided for @profileScanSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Aura Diagnostic Labs'**
  String get profileScanSubtitle2;

  /// No description provided for @profileScanDate3.
  ///
  /// In en, this message translates to:
  /// **'Aug 05, 2023'**
  String get profileScanDate3;

  /// No description provided for @profileScanTitle3.
  ///
  /// In en, this message translates to:
  /// **'Annual Checkup'**
  String get profileScanTitle3;

  /// No description provided for @profileScanSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'General Wellness Clinic'**
  String get profileScanSubtitle3;

  /// No description provided for @profileEditPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit Personal Info'**
  String get profileEditPersonalInfo;

  /// No description provided for @profileEditPersonalInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Name, DOB, Gender'**
  String get profileEditPersonalInfoSubtitle;

  /// No description provided for @profilePrivacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get profilePrivacySecurity;

  /// No description provided for @profilePrivacySecuritySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Biometric lock, Data sharing'**
  String get profilePrivacySecuritySubtitle;

  /// No description provided for @profileLanguagePreference.
  ///
  /// In en, this message translates to:
  /// **'Language Preference'**
  String get profileLanguagePreference;

  /// No description provided for @profileLanguagePreferenceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'English, Hindi'**
  String get profileLanguagePreferenceSubtitle;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileLogout;

  /// No description provided for @verificationSuccessTitleEn.
  ///
  /// In en, this message translates to:
  /// **'Phone Verified!'**
  String get verificationSuccessTitleEn;

  /// No description provided for @verificationSuccessTitleHi.
  ///
  /// In en, this message translates to:
  /// **'फ़ोन सत्यापित!'**
  String get verificationSuccessTitleHi;

  /// No description provided for @verificationSuccessSubtitleEn.
  ///
  /// In en, this message translates to:
  /// **'Welcome to your health sanctuary. Your profile is almost ready.'**
  String get verificationSuccessSubtitleEn;

  /// No description provided for @verificationSuccessSubtitleHi.
  ///
  /// In en, this message translates to:
  /// **'आपके स्वास्थ्य अभयारण्य में आपका स्वागत है। आपकी प्रोफ़ाइल लगभग तैयार है।'**
  String get verificationSuccessSubtitleHi;

  /// No description provided for @completeProfileEn.
  ///
  /// In en, this message translates to:
  /// **'Complete My Profile'**
  String get completeProfileEn;

  /// No description provided for @completeProfileHi.
  ///
  /// In en, this message translates to:
  /// **'मेरी प्रोफ़ाइल पूरी करें'**
  String get completeProfileHi;

  /// No description provided for @goToDashboardEn.
  ///
  /// In en, this message translates to:
  /// **'Go to Dashboard'**
  String get goToDashboardEn;

  /// No description provided for @goToDashboardHi.
  ///
  /// In en, this message translates to:
  /// **'डैशबोर्ड पर जाएँ'**
  String get goToDashboardHi;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveProfile;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @motherName.
  ///
  /// In en, this message translates to:
  /// **'Mother\'s Name'**
  String get motherName;

  /// No description provided for @fatherName.
  ///
  /// In en, this message translates to:
  /// **'Father\'s Name'**
  String get fatherName;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @inbornDiseasesNotes.
  ///
  /// In en, this message translates to:
  /// **'Inborn Diseases & Notes'**
  String get inbornDiseasesNotes;

  /// No description provided for @maritalStatus.
  ///
  /// In en, this message translates to:
  /// **'Marital Status'**
  String get maritalStatus;

  /// No description provided for @bloodGroup.
  ///
  /// In en, this message translates to:
  /// **'Blood Group'**
  String get bloodGroup;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccess;

  /// No description provided for @mandatoryNameError.
  ///
  /// In en, this message translates to:
  /// **'First name and last name are required'**
  String get mandatoryNameError;

  /// No description provided for @bookAppointment.
  ///
  /// In en, this message translates to:
  /// **'Book Appointment'**
  String get bookAppointment;

  /// No description provided for @bookSlot.
  ///
  /// In en, this message translates to:
  /// **'Book Slot'**
  String get bookSlot;

  /// No description provided for @topRatedSpecialists.
  ///
  /// In en, this message translates to:
  /// **'Top Rated Specialists'**
  String get topRatedSpecialists;

  /// No description provided for @priorityStatus.
  ///
  /// In en, this message translates to:
  /// **'⚡ You have Priority Status'**
  String get priorityStatus;

  /// No description provided for @priorityStatusDesc.
  ///
  /// In en, this message translates to:
  /// **'You\'ll be seen first in the queue.'**
  String get priorityStatusDesc;

  /// No description provided for @priorityStatusHi.
  ///
  /// In en, this message translates to:
  /// **'आपको प्राथमिकता दी जाएगी - आप पहले देखे जाएंगे'**
  String get priorityStatusHi;

  /// No description provided for @allDoctors.
  ///
  /// In en, this message translates to:
  /// **'All Doctors'**
  String get allDoctors;

  /// No description provided for @cardiologist.
  ///
  /// In en, this message translates to:
  /// **'Cardiologist'**
  String get cardiologist;

  /// No description provided for @pediatrician.
  ///
  /// In en, this message translates to:
  /// **'Pediatrician'**
  String get pediatrician;

  /// No description provided for @dermatologist.
  ///
  /// In en, this message translates to:
  /// **'Dermatologist'**
  String get dermatologist;

  /// No description provided for @entSpecialist.
  ///
  /// In en, this message translates to:
  /// **'ENT Specialist'**
  String get entSpecialist;

  /// No description provided for @availableToday.
  ///
  /// In en, this message translates to:
  /// **'Available Today'**
  String get availableToday;

  /// No description provided for @availableTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Next: Tomorrow, 10:00 AM'**
  String get availableTomorrow;

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookNow;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'SELECT DATE'**
  String get selectDate;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'SELECT TIME'**
  String get selectTime;

  /// No description provided for @morningSlots.
  ///
  /// In en, this message translates to:
  /// **'MORNING SLOTS'**
  String get morningSlots;

  /// No description provided for @afternoonSlots.
  ///
  /// In en, this message translates to:
  /// **'AFTERNOON SLOTS'**
  String get afternoonSlots;

  /// No description provided for @reasonForVisit.
  ///
  /// In en, this message translates to:
  /// **'REASON FOR VISIT'**
  String get reasonForVisit;

  /// No description provided for @reasonForVisitHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Regular checkup, Heart checkup...'**
  String get reasonForVisitHint;

  /// No description provided for @additionalNotes.
  ///
  /// In en, this message translates to:
  /// **'ADDITIONAL NOTES (Optional)'**
  String get additionalNotes;

  /// No description provided for @additionalNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Add any additional information...'**
  String get additionalNotesHint;

  /// No description provided for @confirmAppointment.
  ///
  /// In en, this message translates to:
  /// **'Confirm Appointment'**
  String get confirmAppointment;

  /// No description provided for @appointmentConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Appointment Confirmed!'**
  String get appointmentConfirmed;

  /// No description provided for @appointmentConfirmedHi.
  ///
  /// In en, this message translates to:
  /// **'आपका अपॉइंटमेंट पक्का हो गया है!'**
  String get appointmentConfirmedHi;

  /// No description provided for @appointmentDetails.
  ///
  /// In en, this message translates to:
  /// **'APPOINTMENT DETAILS'**
  String get appointmentDetails;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'DATE'**
  String get dateLabel;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'TIME'**
  String get timeLabel;

  /// No description provided for @queueNumber.
  ///
  /// In en, this message translates to:
  /// **'QUEUE'**
  String get queueNumber;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @self.
  ///
  /// In en, this message translates to:
  /// **'Self'**
  String get self;

  /// No description provided for @family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields'**
  String get fillAllFields;

  /// No description provided for @errorLoadingDoctors.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Doctors'**
  String get errorLoadingDoctors;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @noDoctorsFound.
  ///
  /// In en, this message translates to:
  /// **'No doctors found for selected filters'**
  String get noDoctorsFound;
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
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
