import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_af.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_zu.dart';

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
    Locale('af'),
    Locale('en'),
    Locale('es'),
    Locale('pt'),
    Locale('zu')
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Journey Forward'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// No description provided for @navToolkit.
  ///
  /// In en, this message translates to:
  /// **'Toolkit'**
  String get navToolkit;

  /// No description provided for @navJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get navJournal;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get commonRestore;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @commonCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get commonCopied;

  /// No description provided for @commonDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String commonDays(int count);

  /// No description provided for @commonMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes'**
  String commonMinutes(int count);

  /// No description provided for @commonMin.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String commonMin(int count);

  /// No description provided for @lockAppName.
  ///
  /// In en, this message translates to:
  /// **'Journey Forward'**
  String get lockAppName;

  /// No description provided for @lockAuthenticateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to continue'**
  String get lockAuthenticateSubtitle;

  /// No description provided for @lockTapToAuthenticate.
  ///
  /// In en, this message translates to:
  /// **'Tap to authenticate'**
  String get lockTapToAuthenticate;

  /// No description provided for @lockEnterYourPin.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get lockEnterYourPin;

  /// No description provided for @lockUsePinInstead.
  ///
  /// In en, this message translates to:
  /// **'Use PIN instead'**
  String get lockUsePinInstead;

  /// No description provided for @lockIncorrectPin.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN. Try again.'**
  String get lockIncorrectPin;

  /// No description provided for @lockBiometricsNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Biometrics not available on this device.'**
  String get lockBiometricsNotAvailable;

  /// No description provided for @lockAuthCancelled.
  ///
  /// In en, this message translates to:
  /// **'Authentication cancelled.'**
  String get lockAuthCancelled;

  /// No description provided for @lockUnlockReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock Journey Forward'**
  String get lockUnlockReason;

  /// No description provided for @lockTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again later.'**
  String get lockTooManyAttempts;

  /// No description provided for @lockPermanentlyLockedOut.
  ///
  /// In en, this message translates to:
  /// **'Biometrics locked. Restart your device.'**
  String get lockPermanentlyLockedOut;

  /// No description provided for @lockBiometricsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Biometrics unavailable.'**
  String get lockBiometricsUnavailable;

  /// No description provided for @lockAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed.'**
  String get lockAuthFailed;

  /// No description provided for @lockNotEnrolled.
  ///
  /// In en, this message translates to:
  /// **'No biometrics enrolled. Use your device PIN.'**
  String get lockNotEnrolled;

  /// No description provided for @onbStepIndicator.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String onbStepIndicator(int step, int total);

  /// No description provided for @onbContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onbContinue;

  /// No description provided for @onbBeginMyJourney.
  ///
  /// In en, this message translates to:
  /// **'Begin my journey'**
  String get onbBeginMyJourney;

  /// No description provided for @onbLetsBegin.
  ///
  /// In en, this message translates to:
  /// **'Let\'s begin'**
  String get onbLetsBegin;

  /// No description provided for @onbWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'A new chapter\nbegins.'**
  String get onbWelcomeTitle;

  /// No description provided for @onbWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Journey Forward is your private, on-device companion for building a sober life — one day at a time.'**
  String get onbWelcomeBody;

  /// No description provided for @onbPrivacy100OnDevice.
  ///
  /// In en, this message translates to:
  /// **'100% on-device'**
  String get onbPrivacy100OnDevice;

  /// No description provided for @onbPrivacy100OnDeviceSub.
  ///
  /// In en, this message translates to:
  /// **'Your data stays on this phone unless you choose to export it'**
  String get onbPrivacy100OnDeviceSub;

  /// No description provided for @onbPrivacyNoAccount.
  ///
  /// In en, this message translates to:
  /// **'No account needed'**
  String get onbPrivacyNoAccount;

  /// No description provided for @onbPrivacyNoAccountSub.
  ///
  /// In en, this message translates to:
  /// **'No email, no sign-up, no cloud'**
  String get onbPrivacyNoAccountSub;

  /// No description provided for @onbPrivacyZeroTracking.
  ///
  /// In en, this message translates to:
  /// **'Zero tracking'**
  String get onbPrivacyZeroTracking;

  /// No description provided for @onbPrivacyZeroTrackingSub.
  ///
  /// In en, this message translates to:
  /// **'No analytics, no ads, no data collection'**
  String get onbPrivacyZeroTrackingSub;

  /// No description provided for @onbNameHeadline.
  ///
  /// In en, this message translates to:
  /// **'What should\nwe call you?'**
  String get onbNameHeadline;

  /// No description provided for @onbNameSub.
  ///
  /// In en, this message translates to:
  /// **'Your name stays private — only shown within this app.'**
  String get onbNameSub;

  /// No description provided for @onbNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get onbNameHint;

  /// No description provided for @onbJourneyTitle.
  ///
  /// In en, this message translates to:
  /// **'What are you stepping away from?'**
  String get onbJourneyTitle;

  /// No description provided for @onbJourneySub.
  ///
  /// In en, this message translates to:
  /// **'This helps Journey Forward speak to your journey — your healing timeline, your milestones. You can skip it or change it any time in Settings.'**
  String get onbJourneySub;

  /// No description provided for @onbJourneyPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Like everything in this app, your answer never leaves your phone.'**
  String get onbJourneyPrivacyNote;

  /// No description provided for @homeBackupNudge.
  ///
  /// In en, this message translates to:
  /// **'Beautiful milestone — a 2-minute backup keeps it safe forever.'**
  String get homeBackupNudge;

  /// No description provided for @homeBackupNudgeAction.
  ///
  /// In en, this message translates to:
  /// **'Back up'**
  String get homeBackupNudgeAction;

  /// No description provided for @onbNameError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name.'**
  String get onbNameError;

  /// No description provided for @onbDateHeadline.
  ///
  /// In en, this message translates to:
  /// **'When did your\njourney begin?'**
  String get onbDateHeadline;

  /// No description provided for @onbDateSub.
  ///
  /// In en, this message translates to:
  /// **'Already started? Pick that day. Planning ahead? Choose a future date and we\'ll count down to it. You can change this anytime.'**
  String get onbDateSub;

  /// No description provided for @onbDatePickerHelp.
  ///
  /// In en, this message translates to:
  /// **'Choose your start date'**
  String get onbDatePickerHelp;

  /// No description provided for @onbSoberSince.
  ///
  /// In en, this message translates to:
  /// **'Sober since'**
  String get onbSoberSince;

  /// No description provided for @onbDaysOfCourage.
  ///
  /// In en, this message translates to:
  /// **'{count} days of courage'**
  String onbDaysOfCourage(int count);

  /// No description provided for @onbDaysOfCourageLabel.
  ///
  /// In en, this message translates to:
  /// **'days of courage'**
  String get onbDaysOfCourageLabel;

  /// No description provided for @onbSpendHeadline.
  ///
  /// In en, this message translates to:
  /// **'What did\nalcohol cost you?'**
  String get onbSpendHeadline;

  /// No description provided for @onbSpendSub.
  ///
  /// In en, this message translates to:
  /// **'Your daily spend lets us show how much you\'re reclaiming. Leave it at 0 to skip — this calculation stays on your device.'**
  String get onbSpendSub;

  /// No description provided for @onbSpendAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Amount per day'**
  String get onbSpendAmountHint;

  /// No description provided for @onbSpendSavingsPreview.
  ///
  /// In en, this message translates to:
  /// **'In 30 days you\'d save {currency}{amount}'**
  String onbSpendSavingsPreview(String currency, String amount);

  /// No description provided for @onbSpendSkipNote.
  ///
  /// In en, this message translates to:
  /// **'You can always add this later in your profile settings.'**
  String get onbSpendSkipNote;

  /// No description provided for @onbSecurityHeadline.
  ///
  /// In en, this message translates to:
  /// **'Protect\nyour space.'**
  String get onbSecurityHeadline;

  /// No description provided for @onbSecuritySub.
  ///
  /// In en, this message translates to:
  /// **'Lock methods run 100% on-device — your PIN never touches a server.'**
  String get onbSecuritySub;

  /// No description provided for @onbSecurityNoLockLabel.
  ///
  /// In en, this message translates to:
  /// **'No lock'**
  String get onbSecurityNoLockLabel;

  /// No description provided for @onbSecurityNoLockSub.
  ///
  /// In en, this message translates to:
  /// **'Open straight to your journey'**
  String get onbSecurityNoLockSub;

  /// No description provided for @onbSecurityBiometricLabel.
  ///
  /// In en, this message translates to:
  /// **'Biometric'**
  String get onbSecurityBiometricLabel;

  /// No description provided for @onbSecurityBiometricSub.
  ///
  /// In en, this message translates to:
  /// **'Face ID or fingerprint — fastest and most private'**
  String get onbSecurityBiometricSub;

  /// No description provided for @onbSecurityPinLabel.
  ///
  /// In en, this message translates to:
  /// **'4-digit PIN'**
  String get onbSecurityPinLabel;

  /// No description provided for @onbSecurityPinSub.
  ///
  /// In en, this message translates to:
  /// **'Your PIN is salted, hashed, and stored in your device\'s encrypted storage'**
  String get onbSecurityPinSub;

  /// No description provided for @onbPinCreateHeadline.
  ///
  /// In en, this message translates to:
  /// **'Create\nyour PIN.'**
  String get onbPinCreateHeadline;

  /// No description provided for @onbPinConfirmHeadline.
  ///
  /// In en, this message translates to:
  /// **'Confirm\nyour PIN.'**
  String get onbPinConfirmHeadline;

  /// No description provided for @onbPinCreateSub.
  ///
  /// In en, this message translates to:
  /// **'Your PIN is salted and hashed, then stored in your device\'s encrypted storage — never in plaintext, never in the cloud.'**
  String get onbPinCreateSub;

  /// No description provided for @onbPinConfirmSub.
  ///
  /// In en, this message translates to:
  /// **'Enter the same 4 digits to confirm.'**
  String get onbPinConfirmSub;

  /// No description provided for @onbPinConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get onbPinConfirmButton;

  /// No description provided for @onbPinDigitsError.
  ///
  /// In en, this message translates to:
  /// **'Enter all 4 digits.'**
  String get onbPinDigitsError;

  /// No description provided for @onbPinMismatchError.
  ///
  /// In en, this message translates to:
  /// **'PINs don\'t match. Try again.'**
  String get onbPinMismatchError;

  /// No description provided for @onbNotifHeadline.
  ///
  /// In en, this message translates to:
  /// **'Daily\nsupport.'**
  String get onbNotifHeadline;

  /// No description provided for @onbNotifSub.
  ///
  /// In en, this message translates to:
  /// **'All notifications are local — your phone generates them, no server involved.'**
  String get onbNotifSub;

  /// No description provided for @onbNotifPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Notifications fire from your device. No push servers. No data leaves your phone.'**
  String get onbNotifPrivacyNote;

  /// No description provided for @onbNotifMorningLabel.
  ///
  /// In en, this message translates to:
  /// **'Morning motivation'**
  String get onbNotifMorningLabel;

  /// No description provided for @onbNotifMorningSub.
  ///
  /// In en, this message translates to:
  /// **'A daily affirmation to start strong'**
  String get onbNotifMorningSub;

  /// No description provided for @onbNotifEveningLabel.
  ///
  /// In en, this message translates to:
  /// **'Evening check-in'**
  String get onbNotifEveningLabel;

  /// No description provided for @onbNotifEveningSub.
  ///
  /// In en, this message translates to:
  /// **'An evening reminder to reflect'**
  String get onbNotifEveningSub;

  /// No description provided for @onbNotifMilestonesLabel.
  ///
  /// In en, this message translates to:
  /// **'Milestone alerts'**
  String get onbNotifMilestonesLabel;

  /// No description provided for @onbNotifMilestonesSub.
  ///
  /// In en, this message translates to:
  /// **'Celebrate 1 day, 1 week, 30 days…'**
  String get onbNotifMilestonesSub;

  /// No description provided for @onbNotifMorningTime.
  ///
  /// In en, this message translates to:
  /// **'Morning time'**
  String get onbNotifMorningTime;

  /// No description provided for @onbNotifEveningTime.
  ///
  /// In en, this message translates to:
  /// **'Evening time'**
  String get onbNotifEveningTime;

  /// No description provided for @onbNotifChangeAnytime.
  ///
  /// In en, this message translates to:
  /// **'You can change these anytime in Settings.'**
  String get onbNotifChangeAnytime;

  /// No description provided for @onbFinishReadyWithName.
  ///
  /// In en, this message translates to:
  /// **'You\'re ready, {name}! 🌿'**
  String onbFinishReadyWithName(String name);

  /// No description provided for @onbFinishReady.
  ///
  /// In en, this message translates to:
  /// **'You\'re ready! 🌿'**
  String get onbFinishReady;

  /// No description provided for @onbFinishBodyDays.
  ///
  /// In en, this message translates to:
  /// **'You\'ve already been on this journey for {days, plural, =1{1 day} other{{days} days}}. Every single one matters.'**
  String onbFinishBodyDays(int days);

  /// No description provided for @onbFinishBodyToday.
  ///
  /// In en, this message translates to:
  /// **'Your journey starts right now. You\'ve got this.'**
  String get onbFinishBodyToday;

  /// No description provided for @onbFinishPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Your journey lives only on this device — private, secure, and completely yours.'**
  String get onbFinishPrivacyNote;

  /// No description provided for @homeFriendFallback.
  ///
  /// In en, this message translates to:
  /// **'friend'**
  String get homeFriendFallback;

  /// No description provided for @homeGreetingFirst.
  ///
  /// In en, this message translates to:
  /// **'Hi {name},'**
  String homeGreetingFirst(String name);

  /// No description provided for @homeGreetingReturning.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}.'**
  String homeGreetingReturning(String name);

  /// No description provided for @homeTagline.
  ///
  /// In en, this message translates to:
  /// **'Every day forward is a win.'**
  String get homeTagline;

  /// No description provided for @homeErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String homeErrorPrefix(String message);

  /// No description provided for @homeDaysSober.
  ///
  /// In en, this message translates to:
  /// **'DAYS SOBER'**
  String get homeDaysSober;

  /// No description provided for @homeDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get homeDaysLabel;

  /// No description provided for @homeSerenityTagline.
  ///
  /// In en, this message translates to:
  /// **'A clearer mind.\nA stronger you.'**
  String get homeSerenityTagline;

  /// No description provided for @homeMoneyReclaimed.
  ///
  /// In en, this message translates to:
  /// **'MONEY\nRECLAIMED'**
  String get homeMoneyReclaimed;

  /// No description provided for @homeMoneyAllTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get homeMoneyAllTime;

  /// No description provided for @homeMoneyInvesting.
  ///
  /// In en, this message translates to:
  /// **'You\'re investing in\nyour future self.'**
  String get homeMoneyInvesting;

  /// No description provided for @homeMoneyGoalSavedOf.
  ///
  /// In en, this message translates to:
  /// **'{saved} saved of {goal} goal'**
  String homeMoneyGoalSavedOf(String saved, String goal);

  /// No description provided for @homeMoneyGoalPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String homeMoneyGoalPercent(int percent);

  /// No description provided for @homeMoneyGoalClear.
  ///
  /// In en, this message translates to:
  /// **'Clear goal'**
  String get homeMoneyGoalClear;

  /// No description provided for @homeMyReasonTitle.
  ///
  /// In en, this message translates to:
  /// **'My Reason'**
  String get homeMyReasonTitle;

  /// No description provided for @homeMyReasonRotates.
  ///
  /// In en, this message translates to:
  /// **'rotates daily'**
  String get homeMyReasonRotates;

  /// No description provided for @homeMyReasonAddPrompt.
  ///
  /// In en, this message translates to:
  /// **'Add your reasons\nin Profile'**
  String get homeMyReasonAddPrompt;

  /// No description provided for @homeYourJourney.
  ///
  /// In en, this message translates to:
  /// **'YOUR JOURNEY'**
  String get homeYourJourney;

  /// No description provided for @homeJourneySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Milestones are ahead. Keep going.'**
  String get homeJourneySubtitle;

  /// No description provided for @homeMilestoneNode0Label.
  ///
  /// In en, this message translates to:
  /// **'First hours'**
  String get homeMilestoneNode0Label;

  /// No description provided for @homeMilestoneNode1Label.
  ///
  /// In en, this message translates to:
  /// **'Clear morning'**
  String get homeMilestoneNode1Label;

  /// No description provided for @homeMilestoneNode2Label.
  ///
  /// In en, this message translates to:
  /// **'Energy returns'**
  String get homeMilestoneNode2Label;

  /// No description provided for @homeMilestoneNode3Label.
  ///
  /// In en, this message translates to:
  /// **'Mind healing'**
  String get homeMilestoneNode3Label;

  /// No description provided for @homeMilestoneNode4Label.
  ///
  /// In en, this message translates to:
  /// **'A new chapter'**
  String get homeMilestoneNode4Label;

  /// No description provided for @homeMilestoneTimingDone.
  ///
  /// In en, this message translates to:
  /// **'done'**
  String get homeMilestoneTimingDone;

  /// No description provided for @homeDailyPledge.
  ///
  /// In en, this message translates to:
  /// **'DAILY PLEDGE'**
  String get homeDailyPledge;

  /// No description provided for @homePledgeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Today I choose clarity.'**
  String get homePledgeHint;

  /// No description provided for @homePledgeCalmDays.
  ///
  /// In en, this message translates to:
  /// **'{count} calm days kept'**
  String homePledgeCalmDays(int count);

  /// No description provided for @homeDailyGratitude.
  ///
  /// In en, this message translates to:
  /// **'DAILY GRATITUDE'**
  String get homeDailyGratitude;

  /// No description provided for @homeGratitudeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., I\'m grateful for\nanother fresh start.'**
  String get homeGratitudeHint;

  /// No description provided for @homeGratitudeLoggedToday.
  ///
  /// In en, this message translates to:
  /// **'Logged today'**
  String get homeGratitudeLoggedToday;

  /// No description provided for @homeWeeklyGoals.
  ///
  /// In en, this message translates to:
  /// **'Weekly Goals'**
  String get homeWeeklyGoals;

  /// No description provided for @homeDailyMissions.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S STEPS'**
  String get homeDailyMissions;

  /// No description provided for @homeMissionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Small acts of care for today.'**
  String get homeMissionsSubtitle;

  /// No description provided for @homeMissionsProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} complete'**
  String homeMissionsProgress(int done, int total);

  /// No description provided for @homeDailyCheckIn.
  ///
  /// In en, this message translates to:
  /// **'DAILY CHECK-IN'**
  String get homeDailyCheckIn;

  /// No description provided for @homeCheckInCraving.
  ///
  /// In en, this message translates to:
  /// **'Craving'**
  String get homeCheckInCraving;

  /// No description provided for @homeCheckInThought.
  ///
  /// In en, this message translates to:
  /// **'Thought'**
  String get homeCheckInThought;

  /// No description provided for @homeCheckInActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get homeCheckInActivity;

  /// No description provided for @homeCheckInSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get homeCheckInSleep;

  /// No description provided for @homeQuittingTimeline.
  ///
  /// In en, this message translates to:
  /// **'QUITTING TIMELINE'**
  String get homeQuittingTimeline;

  /// No description provided for @homeRecoveryBannerSub0.
  ///
  /// In en, this message translates to:
  /// **'See what\'s happening in your body'**
  String get homeRecoveryBannerSub0;

  /// No description provided for @homeRecoveryBannerSub1.
  ///
  /// In en, this message translates to:
  /// **'Your body is already healing'**
  String get homeRecoveryBannerSub1;

  /// No description provided for @homeRecoveryBannerSub2.
  ///
  /// In en, this message translates to:
  /// **'Your brain chemistry is shifting'**
  String get homeRecoveryBannerSub2;

  /// No description provided for @homeRecoveryBannerSub3.
  ///
  /// In en, this message translates to:
  /// **'Your body has had a real break from the load'**
  String get homeRecoveryBannerSub3;

  /// No description provided for @homeRecoveryBannerSub4.
  ///
  /// In en, this message translates to:
  /// **'You are building real momentum'**
  String get homeRecoveryBannerSub4;

  /// No description provided for @homeEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get homeEditProfile;

  /// No description provided for @homeProfileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get homeProfileNameLabel;

  /// No description provided for @homeProfileNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get homeProfileNameHint;

  /// No description provided for @homeSoberSince.
  ///
  /// In en, this message translates to:
  /// **'Sober since'**
  String get homeSoberSince;

  /// No description provided for @homeProfileDailySpend.
  ///
  /// In en, this message translates to:
  /// **'Daily spend'**
  String get homeProfileDailySpend;

  /// No description provided for @homeProfileSpendHint.
  ///
  /// In en, this message translates to:
  /// **'0'**
  String get homeProfileSpendHint;

  /// No description provided for @homeCravingSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Log a craving'**
  String get homeCravingSheetTitle;

  /// No description provided for @homeCravingSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Noticing the shape of a craving helps you understand the pattern without obeying it.'**
  String get homeCravingSheetSubtitle;

  /// No description provided for @homeCravingStrengthQuestion.
  ///
  /// In en, this message translates to:
  /// **'How strong was the craving?'**
  String get homeCravingStrengthQuestion;

  /// No description provided for @homeCravingIntensityLabel.
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get homeCravingIntensityLabel;

  /// No description provided for @homeCravingIntensityValue.
  ///
  /// In en, this message translates to:
  /// **'{value} / 10'**
  String homeCravingIntensityValue(int value);

  /// No description provided for @homeCravingTriggerQuestion.
  ///
  /// In en, this message translates to:
  /// **'What triggered it?'**
  String get homeCravingTriggerQuestion;

  /// No description provided for @homeCravingDurationQuestion.
  ///
  /// In en, this message translates to:
  /// **'How long did it last?'**
  String get homeCravingDurationQuestion;

  /// No description provided for @homeCravingDurationValue.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes'**
  String homeCravingDurationValue(int minutes);

  /// No description provided for @homeCravingNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional) - e.g., passed a bar on the way home.'**
  String get homeCravingNotesHint;

  /// No description provided for @homeSaveCraving.
  ///
  /// In en, this message translates to:
  /// **'Save craving'**
  String get homeSaveCraving;

  /// No description provided for @homeThoughtSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Log a thought'**
  String get homeThoughtSheetTitle;

  /// No description provided for @homeThoughtSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Noticing thoughts about alcohol is normal. Logging them helps reveal the pattern.'**
  String get homeThoughtSheetSubtitle;

  /// No description provided for @homeThoughtWhatQuestion.
  ///
  /// In en, this message translates to:
  /// **'What was the thought?'**
  String get homeThoughtWhatQuestion;

  /// No description provided for @homeThoughtWriteHint.
  ///
  /// In en, this message translates to:
  /// **'Write the thought in your own words.'**
  String get homeThoughtWriteHint;

  /// No description provided for @homeThoughtStrengthQuestion.
  ///
  /// In en, this message translates to:
  /// **'How strong was the thought?'**
  String get homeThoughtStrengthQuestion;

  /// No description provided for @homeThoughtTriggerQuestion.
  ///
  /// In en, this message translates to:
  /// **'What triggered the thought?'**
  String get homeThoughtTriggerQuestion;

  /// No description provided for @homeThoughtDurationQuestion.
  ///
  /// In en, this message translates to:
  /// **'How long did it last?'**
  String get homeThoughtDurationQuestion;

  /// No description provided for @homeThoughtToneLabel.
  ///
  /// In en, this message translates to:
  /// **'Tone'**
  String get homeThoughtToneLabel;

  /// No description provided for @homeThoughtNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional) - e.g., saw an ad and noticed the thought arrive.'**
  String get homeThoughtNotesHint;

  /// No description provided for @homeSaveThought.
  ///
  /// In en, this message translates to:
  /// **'Save thought'**
  String get homeSaveThought;

  /// No description provided for @homeActivitySheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Log activity'**
  String get homeActivitySheetTitle;

  /// No description provided for @homeActivitySheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Movement can shift the nervous system. Capture enough detail to see what truly helps.'**
  String get homeActivitySheetSubtitle;

  /// No description provided for @homeActivityTypeQuestion.
  ///
  /// In en, this message translates to:
  /// **'What did you do?'**
  String get homeActivityTypeQuestion;

  /// No description provided for @homeActivityTypeWalk.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get homeActivityTypeWalk;

  /// No description provided for @homeActivityTypeExercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get homeActivityTypeExercise;

  /// No description provided for @homeActivityTypeYoga.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get homeActivityTypeYoga;

  /// No description provided for @homeActivityTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get homeActivityTypeOther;

  /// No description provided for @homeActivityEffortQuestion.
  ///
  /// In en, this message translates to:
  /// **'How much effort did it take?'**
  String get homeActivityEffortQuestion;

  /// No description provided for @homeActivityOutcomeQuestion.
  ///
  /// In en, this message translates to:
  /// **'How did you feel after?'**
  String get homeActivityOutcomeQuestion;

  /// No description provided for @homeActivityDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get homeActivityDurationLabel;

  /// No description provided for @homeActivityDurationValue.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String homeActivityDurationValue(int minutes);

  /// No description provided for @homeActivityNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional) - e.g., walked after dinner and felt steadier.'**
  String get homeActivityNotesHint;

  /// No description provided for @homeSaveActivity.
  ///
  /// In en, this message translates to:
  /// **'Save activity'**
  String get homeSaveActivity;

  /// No description provided for @homeSleepSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Log sleep'**
  String get homeSleepSheetTitle;

  /// No description provided for @homeSleepSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sleep is one of the clearest signals in recovery. Small details help reveal the trend.'**
  String get homeSleepSheetSubtitle;

  /// No description provided for @homeSleepHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Hours slept'**
  String get homeSleepHoursLabel;

  /// No description provided for @homeSleepHoursValue.
  ///
  /// In en, this message translates to:
  /// **'{hours} hrs'**
  String homeSleepHoursValue(String hours);

  /// No description provided for @homeSleepQualityLabel.
  ///
  /// In en, this message translates to:
  /// **'Sleep quality'**
  String get homeSleepQualityLabel;

  /// No description provided for @homeSleepFactorsQuestion.
  ///
  /// In en, this message translates to:
  /// **'What affected your sleep?'**
  String get homeSleepFactorsQuestion;

  /// No description provided for @homeSleepNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional) - e.g., woke at 3am with cravings, fell back asleep.'**
  String get homeSleepNotesHint;

  /// No description provided for @homeSaveSleep.
  ///
  /// In en, this message translates to:
  /// **'Save sleep'**
  String get homeSaveSleep;

  /// No description provided for @homeSeverityBrief.
  ///
  /// In en, this message translates to:
  /// **'Brief'**
  String get homeSeverityBrief;

  /// No description provided for @homeSeverityMild.
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get homeSeverityMild;

  /// No description provided for @homeSeverityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get homeSeverityModerate;

  /// No description provided for @homeSeverityStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get homeSeverityStrong;

  /// No description provided for @homeSeverityConsuming.
  ///
  /// In en, this message translates to:
  /// **'Consuming'**
  String get homeSeverityConsuming;

  /// No description provided for @homeTriggerStress.
  ///
  /// In en, this message translates to:
  /// **'Stress'**
  String get homeTriggerStress;

  /// No description provided for @homeTriggerSocial.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get homeTriggerSocial;

  /// No description provided for @homeTriggerBoredom.
  ///
  /// In en, this message translates to:
  /// **'Boredom'**
  String get homeTriggerBoredom;

  /// No description provided for @homeTriggerTimeOfDay.
  ///
  /// In en, this message translates to:
  /// **'Time of day'**
  String get homeTriggerTimeOfDay;

  /// No description provided for @homeTriggerCelebration.
  ///
  /// In en, this message translates to:
  /// **'Celebration'**
  String get homeTriggerCelebration;

  /// No description provided for @homeTriggerSadness.
  ///
  /// In en, this message translates to:
  /// **'Sadness'**
  String get homeTriggerSadness;

  /// No description provided for @homeTriggerLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get homeTriggerLocation;

  /// No description provided for @homeTriggerMemory.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get homeTriggerMemory;

  /// No description provided for @homeTriggerHungry.
  ///
  /// In en, this message translates to:
  /// **'Hungry'**
  String get homeTriggerHungry;

  /// No description provided for @homeTriggerAngry.
  ///
  /// In en, this message translates to:
  /// **'Angry'**
  String get homeTriggerAngry;

  /// No description provided for @homeTriggerTired.
  ///
  /// In en, this message translates to:
  /// **'Tired'**
  String get homeTriggerTired;

  /// No description provided for @homeEffortGentle.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get homeEffortGentle;

  /// No description provided for @homeEffortModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get homeEffortModerate;

  /// No description provided for @homeEffortStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get homeEffortStrong;

  /// No description provided for @homeOutcomeCalmer.
  ///
  /// In en, this message translates to:
  /// **'Calmer'**
  String get homeOutcomeCalmer;

  /// No description provided for @homeOutcomeClearer.
  ///
  /// In en, this message translates to:
  /// **'Clearer'**
  String get homeOutcomeClearer;

  /// No description provided for @homeOutcomeEnergized.
  ///
  /// In en, this message translates to:
  /// **'Energized'**
  String get homeOutcomeEnergized;

  /// No description provided for @homeOutcomeSame.
  ///
  /// In en, this message translates to:
  /// **'Same'**
  String get homeOutcomeSame;

  /// No description provided for @homeSleepQualityPoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get homeSleepQualityPoor;

  /// No description provided for @homeSleepQualityFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get homeSleepQualityFair;

  /// No description provided for @homeSleepQualityOK.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get homeSleepQualityOK;

  /// No description provided for @homeSleepQualityGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get homeSleepQualityGood;

  /// No description provided for @homeSleepQualityGreat.
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get homeSleepQualityGreat;

  /// No description provided for @homeSleepFactorRestless.
  ///
  /// In en, this message translates to:
  /// **'Restless'**
  String get homeSleepFactorRestless;

  /// No description provided for @homeSleepFactorWokeOften.
  ///
  /// In en, this message translates to:
  /// **'Woke often'**
  String get homeSleepFactorWokeOften;

  /// No description provided for @homeSleepFactorDreams.
  ///
  /// In en, this message translates to:
  /// **'Dreams'**
  String get homeSleepFactorDreams;

  /// No description provided for @homeSleepFactorStress.
  ///
  /// In en, this message translates to:
  /// **'Stress'**
  String get homeSleepFactorStress;

  /// No description provided for @homeSleepFactorCravings.
  ///
  /// In en, this message translates to:
  /// **'Cravings'**
  String get homeSleepFactorCravings;

  /// No description provided for @homeSleepFactorLateCaffeine.
  ///
  /// In en, this message translates to:
  /// **'Late caffeine'**
  String get homeSleepFactorLateCaffeine;

  /// No description provided for @homeToneNegative.
  ///
  /// In en, this message translates to:
  /// **'Negative'**
  String get homeToneNegative;

  /// No description provided for @homeToneNeutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get homeToneNeutral;

  /// No description provided for @homeTonePositive.
  ///
  /// In en, this message translates to:
  /// **'Positive'**
  String get homeTonePositive;

  /// No description provided for @homeQuote0.
  ///
  /// In en, this message translates to:
  /// **'Every sober day is an act of love for your future self.'**
  String get homeQuote0;

  /// No description provided for @homeQuote1.
  ///
  /// In en, this message translates to:
  /// **'You do not have to feel ready. You only have to begin.'**
  String get homeQuote1;

  /// No description provided for @homeQuote2.
  ///
  /// In en, this message translates to:
  /// **'Healing is allowed to be quiet.'**
  String get homeQuote2;

  /// No description provided for @homeQuote3.
  ///
  /// In en, this message translates to:
  /// **'One calm choice can change the shape of a day.'**
  String get homeQuote3;

  /// No description provided for @homeQuote4.
  ///
  /// In en, this message translates to:
  /// **'You are not starting over. You are starting wiser.'**
  String get homeQuote4;

  /// No description provided for @homeQuote5.
  ///
  /// In en, this message translates to:
  /// **'Recovery is not linear, but it is still real.'**
  String get homeQuote5;

  /// No description provided for @homeQuote6.
  ///
  /// In en, this message translates to:
  /// **'Even a difficult sober day is proof that you are choosing yourself.'**
  String get homeQuote6;

  /// No description provided for @homeQuote7.
  ///
  /// In en, this message translates to:
  /// **'The version of you that kept going is still here.'**
  String get homeQuote7;

  /// No description provided for @homeQuote8.
  ///
  /// In en, this message translates to:
  /// **'Strength can look like softness.'**
  String get homeQuote8;

  /// No description provided for @homeQuote9.
  ///
  /// In en, this message translates to:
  /// **'Clarity is built one honest moment at a time.'**
  String get homeQuote9;

  /// No description provided for @homeQuote10.
  ///
  /// In en, this message translates to:
  /// **'You have survived hard days before. Today is another step forward.'**
  String get homeQuote10;

  /// No description provided for @homeQuote11.
  ///
  /// In en, this message translates to:
  /// **'Cravings are temporary. Your progress is still here.'**
  String get homeQuote11;

  /// No description provided for @homeQuote12.
  ///
  /// In en, this message translates to:
  /// **'Each morning is another chance to care for yourself.'**
  String get homeQuote12;

  /// No description provided for @homeQuote13.
  ///
  /// In en, this message translates to:
  /// **'Progress does not need to be perfect to be meaningful.'**
  String get homeQuote13;

  /// No description provided for @homeQuote14.
  ///
  /// In en, this message translates to:
  /// **'You are becoming someone you can trust.'**
  String get homeQuote14;

  /// No description provided for @homeQuote15.
  ///
  /// In en, this message translates to:
  /// **'Small choices become a safer life.'**
  String get homeQuote15;

  /// No description provided for @homeQuote16.
  ///
  /// In en, this message translates to:
  /// **'Peace is not rushed. It is practised.'**
  String get homeQuote16;

  /// No description provided for @homeQuote17.
  ///
  /// In en, this message translates to:
  /// **'You are allowed to outgrow what once numbed you.'**
  String get homeQuote17;

  /// No description provided for @homeQuote18.
  ///
  /// In en, this message translates to:
  /// **'The urge will pass. Your dignity can remain.'**
  String get homeQuote18;

  /// No description provided for @homeQuote19.
  ///
  /// In en, this message translates to:
  /// **'Recovery is a return to yourself.'**
  String get homeQuote19;

  /// No description provided for @homeQuote20.
  ///
  /// In en, this message translates to:
  /// **'You are not behind. You are healing at human speed.'**
  String get homeQuote20;

  /// No description provided for @homeQuote21.
  ///
  /// In en, this message translates to:
  /// **'A softer life is still a strong life.'**
  String get homeQuote21;

  /// No description provided for @homeQuote22.
  ///
  /// In en, this message translates to:
  /// **'Your future self is being protected by today\'s choices.'**
  String get homeQuote22;

  /// No description provided for @homeQuote23.
  ///
  /// In en, this message translates to:
  /// **'You can pause. You can breathe. You can choose again.'**
  String get homeQuote23;

  /// No description provided for @homeQuote24.
  ///
  /// In en, this message translates to:
  /// **'Every honest day is part of the way forward.'**
  String get homeQuote24;

  /// No description provided for @homeQuote25.
  ///
  /// In en, this message translates to:
  /// **'You do not need to punish yourself to change.'**
  String get homeQuote25;

  /// No description provided for @homeQuote26.
  ///
  /// In en, this message translates to:
  /// **'The quiet work counts.'**
  String get homeQuote26;

  /// No description provided for @homeQuote27.
  ///
  /// In en, this message translates to:
  /// **'Your nervous system is learning safety again.'**
  String get homeQuote27;

  /// No description provided for @homeQuote28.
  ///
  /// In en, this message translates to:
  /// **'You are worthy of care before you feel strong.'**
  String get homeQuote28;

  /// No description provided for @homeQuote29.
  ///
  /// In en, this message translates to:
  /// **'Let today be simple. Let today be enough.'**
  String get homeQuote29;

  /// No description provided for @homeQuote30.
  ///
  /// In en, this message translates to:
  /// **'One breath can become one minute. One minute can become one day.'**
  String get homeQuote30;

  /// No description provided for @homeQuote31.
  ///
  /// In en, this message translates to:
  /// **'You are not your craving. You are the one witnessing it.'**
  String get homeQuote31;

  /// No description provided for @homeQuote32.
  ///
  /// In en, this message translates to:
  /// **'You can build a life that no longer asks you to escape it.'**
  String get homeQuote32;

  /// No description provided for @homeQuote33.
  ///
  /// In en, this message translates to:
  /// **'There is strength in staying.'**
  String get homeQuote33;

  /// No description provided for @homeQuote34.
  ///
  /// In en, this message translates to:
  /// **'Healing begins where shame loses its voice.'**
  String get homeQuote34;

  /// No description provided for @homeQuote35.
  ///
  /// In en, this message translates to:
  /// **'You are allowed to need support.'**
  String get homeQuote35;

  /// No description provided for @homeQuote36.
  ///
  /// In en, this message translates to:
  /// **'The path forward is yours — one step at a time.'**
  String get homeQuote36;

  /// No description provided for @homeQuote37.
  ///
  /// In en, this message translates to:
  /// **'Your progress is not erased by a hard moment.'**
  String get homeQuote37;

  /// No description provided for @homeQuote38.
  ///
  /// In en, this message translates to:
  /// **'Choose the next right thing, not the perfect thing.'**
  String get homeQuote38;

  /// No description provided for @homeQuote39.
  ///
  /// In en, this message translates to:
  /// **'Sobriety is not a punishment. It is protection.'**
  String get homeQuote39;

  /// No description provided for @homeQuote40.
  ///
  /// In en, this message translates to:
  /// **'You are learning how to come home to yourself.'**
  String get homeQuote40;

  /// No description provided for @homeQuote41.
  ///
  /// In en, this message translates to:
  /// **'The life you want is built in ordinary moments.'**
  String get homeQuote41;

  /// No description provided for @homeQuote42.
  ///
  /// In en, this message translates to:
  /// **'You can be proud without being finished.'**
  String get homeQuote42;

  /// No description provided for @homeQuote43.
  ///
  /// In en, this message translates to:
  /// **'Nothing about healing needs to be loud to be real.'**
  String get homeQuote43;

  /// No description provided for @homeQuote44.
  ///
  /// In en, this message translates to:
  /// **'Your peace is worth protecting.'**
  String get homeQuote44;

  /// No description provided for @homeQuote45.
  ///
  /// In en, this message translates to:
  /// **'A craving is a wave, not a command.'**
  String get homeQuote45;

  /// No description provided for @homeQuote46.
  ///
  /// In en, this message translates to:
  /// **'You are building evidence that you can trust yourself.'**
  String get homeQuote46;

  /// No description provided for @homeQuote47.
  ///
  /// In en, this message translates to:
  /// **'Today does not need to be conquered. It only needs to be lived.'**
  String get homeQuote47;

  /// No description provided for @homeQuote48.
  ///
  /// In en, this message translates to:
  /// **'There is still time to become someone new.'**
  String get homeQuote48;

  /// No description provided for @homeQuote49.
  ///
  /// In en, this message translates to:
  /// **'Keep going. Every step still counts.'**
  String get homeQuote49;

  /// No description provided for @homeMission0.
  ///
  /// In en, this message translates to:
  /// **'Drink a full glass of water slowly.'**
  String get homeMission0;

  /// No description provided for @homeMission1.
  ///
  /// In en, this message translates to:
  /// **'Take a 10-minute walk outside.'**
  String get homeMission1;

  /// No description provided for @homeMission2.
  ///
  /// In en, this message translates to:
  /// **'Write down three things you are grateful for.'**
  String get homeMission2;

  /// No description provided for @homeMission3.
  ///
  /// In en, this message translates to:
  /// **'Send a kind message to someone you trust.'**
  String get homeMission3;

  /// No description provided for @homeMission4.
  ///
  /// In en, this message translates to:
  /// **'Do five minutes of slow breathing.'**
  String get homeMission4;

  /// No description provided for @homeMission5.
  ///
  /// In en, this message translates to:
  /// **'Read a few pages of something calming.'**
  String get homeMission5;

  /// No description provided for @homeMission6.
  ///
  /// In en, this message translates to:
  /// **'Eat one nourishing meal without distractions.'**
  String get homeMission6;

  /// No description provided for @homeMission7.
  ///
  /// In en, this message translates to:
  /// **'Prepare for an earlier, softer night.'**
  String get homeMission7;

  /// No description provided for @homeMission8.
  ///
  /// In en, this message translates to:
  /// **'Do one kind thing for yourself today.'**
  String get homeMission8;

  /// No description provided for @homeMission9.
  ///
  /// In en, this message translates to:
  /// **'Sit in silence for three minutes.'**
  String get homeMission9;

  /// No description provided for @homeMission10.
  ///
  /// In en, this message translates to:
  /// **'Write one honest sentence in your journal.'**
  String get homeMission10;

  /// No description provided for @homeMission11.
  ///
  /// In en, this message translates to:
  /// **'Put your phone away for one quiet hour.'**
  String get homeMission11;

  /// No description provided for @homeMission12.
  ///
  /// In en, this message translates to:
  /// **'Stretch your shoulders, neck, and back.'**
  String get homeMission12;

  /// No description provided for @homeMission13.
  ///
  /// In en, this message translates to:
  /// **'Listen to music that steadies you.'**
  String get homeMission13;

  /// No description provided for @homeMission14.
  ///
  /// In en, this message translates to:
  /// **'Tidy one small area of your space.'**
  String get homeMission14;

  /// No description provided for @homeMission15.
  ///
  /// In en, this message translates to:
  /// **'Step outside and notice the sky.'**
  String get homeMission15;

  /// No description provided for @homeMission16.
  ///
  /// In en, this message translates to:
  /// **'Say \"I am allowed to heal\" three times.'**
  String get homeMission16;

  /// No description provided for @homeMission17.
  ///
  /// In en, this message translates to:
  /// **'Make yourself something warm to drink.'**
  String get homeMission17;

  /// No description provided for @homeMission18.
  ///
  /// In en, this message translates to:
  /// **'Reach out to your support network.'**
  String get homeMission18;

  /// No description provided for @homeMission19.
  ///
  /// In en, this message translates to:
  /// **'Honour the progress you have made today.'**
  String get homeMission19;

  /// No description provided for @homeMission20.
  ///
  /// In en, this message translates to:
  /// **'Take five slow breaths before your next decision.'**
  String get homeMission20;

  /// No description provided for @homeMission21.
  ///
  /// In en, this message translates to:
  /// **'Write down one trigger you noticed today.'**
  String get homeMission21;

  /// No description provided for @homeMission22.
  ///
  /// In en, this message translates to:
  /// **'Write down one thing that helped you today.'**
  String get homeMission22;

  /// No description provided for @homeMission23.
  ///
  /// In en, this message translates to:
  /// **'Place one comforting item near your bed.'**
  String get homeMission23;

  /// No description provided for @homeMission24.
  ///
  /// In en, this message translates to:
  /// **'Wash your face slowly and mindfully.'**
  String get homeMission24;

  /// No description provided for @homeMission25.
  ///
  /// In en, this message translates to:
  /// **'Spend 10 minutes away from screens.'**
  String get homeMission25;

  /// No description provided for @homeMission26.
  ///
  /// In en, this message translates to:
  /// **'Prepare tomorrow\'s first small task.'**
  String get homeMission26;

  /// No description provided for @homeMission27.
  ///
  /// In en, this message translates to:
  /// **'Let one room feel a little lighter.'**
  String get homeMission27;

  /// No description provided for @homeMission28.
  ///
  /// In en, this message translates to:
  /// **'Notice one thing your body needs.'**
  String get homeMission28;

  /// No description provided for @homeMission29.
  ///
  /// In en, this message translates to:
  /// **'Choose a meal that supports your energy.'**
  String get homeMission29;

  /// No description provided for @homeMission30.
  ///
  /// In en, this message translates to:
  /// **'Read one recovery note or affirmation.'**
  String get homeMission30;

  /// No description provided for @homeMission31.
  ///
  /// In en, this message translates to:
  /// **'Save one emergency support number somewhere visible.'**
  String get homeMission31;

  /// No description provided for @homeMission32.
  ///
  /// In en, this message translates to:
  /// **'Write a short note to your future self.'**
  String get homeMission32;

  /// No description provided for @homeMission33.
  ///
  /// In en, this message translates to:
  /// **'Take a warm shower or bath.'**
  String get homeMission33;

  /// No description provided for @homeMission34.
  ///
  /// In en, this message translates to:
  /// **'Breathe through a craving without judging it.'**
  String get homeMission34;

  /// No description provided for @homeMission35.
  ///
  /// In en, this message translates to:
  /// **'Name the emotion underneath the urge.'**
  String get homeMission35;

  /// No description provided for @homeMission36.
  ///
  /// In en, this message translates to:
  /// **'Do one thing slowly on purpose.'**
  String get homeMission36;

  /// No description provided for @homeMission37.
  ///
  /// In en, this message translates to:
  /// **'Put clean water beside your bed.'**
  String get homeMission37;

  /// No description provided for @homeMission38.
  ///
  /// In en, this message translates to:
  /// **'Open a window and take three deep breaths.'**
  String get homeMission38;

  /// No description provided for @homeMission39.
  ///
  /// In en, this message translates to:
  /// **'Write down one reason you are continuing.'**
  String get homeMission39;

  /// No description provided for @homeMission40.
  ///
  /// In en, this message translates to:
  /// **'Spend five minutes in natural light.'**
  String get homeMission40;

  /// No description provided for @homeMission41.
  ///
  /// In en, this message translates to:
  /// **'Make your bed with care.'**
  String get homeMission41;

  /// No description provided for @homeMission42.
  ///
  /// In en, this message translates to:
  /// **'Delete or mute one digital trigger.'**
  String get homeMission42;

  /// No description provided for @homeMission43.
  ///
  /// In en, this message translates to:
  /// **'Choose rest before exhaustion.'**
  String get homeMission43;

  /// No description provided for @homeMission44.
  ///
  /// In en, this message translates to:
  /// **'Write one sentence that begins: \"Today I protected…\"'**
  String get homeMission44;

  /// No description provided for @homeMission45.
  ///
  /// In en, this message translates to:
  /// **'Notice one moment of peace, however small.'**
  String get homeMission45;

  /// No description provided for @homeMission46.
  ///
  /// In en, this message translates to:
  /// **'Thank yourself for staying present.'**
  String get homeMission46;

  /// No description provided for @homeMission47.
  ///
  /// In en, this message translates to:
  /// **'Do a 10-minute reset of your space.'**
  String get homeMission47;

  /// No description provided for @homeMission48.
  ///
  /// In en, this message translates to:
  /// **'Choose one boundary that supports your recovery.'**
  String get homeMission48;

  /// No description provided for @homeMission49.
  ///
  /// In en, this message translates to:
  /// **'Let yourself pause before reacting.'**
  String get homeMission49;

  /// No description provided for @homeMission50.
  ///
  /// In en, this message translates to:
  /// **'Write down one thing you are learning about yourself.'**
  String get homeMission50;

  /// No description provided for @homeMission51.
  ///
  /// In en, this message translates to:
  /// **'Prepare a simple comfort plan for tonight.'**
  String get homeMission51;

  /// No description provided for @homeMission52.
  ///
  /// In en, this message translates to:
  /// **'Place your hand on your chest and breathe slowly.'**
  String get homeMission52;

  /// No description provided for @homeMission53.
  ///
  /// In en, this message translates to:
  /// **'Drink tea, water, or something calming without rushing.'**
  String get homeMission53;

  /// No description provided for @homeMission54.
  ///
  /// In en, this message translates to:
  /// **'Spend a few minutes with a plant, pet, or quiet object.'**
  String get homeMission54;

  /// No description provided for @homeMission55.
  ///
  /// In en, this message translates to:
  /// **'Write down one thing you do not need to carry today.'**
  String get homeMission55;

  /// No description provided for @homeMission56.
  ///
  /// In en, this message translates to:
  /// **'Take a short walk without headphones.'**
  String get homeMission56;

  /// No description provided for @homeMission57.
  ///
  /// In en, this message translates to:
  /// **'Do one practical task you have been avoiding.'**
  String get homeMission57;

  /// No description provided for @homeMission58.
  ///
  /// In en, this message translates to:
  /// **'End the day by naming one quiet victory.'**
  String get homeMission58;

  /// No description provided for @homeMission59.
  ///
  /// In en, this message translates to:
  /// **'Remind yourself: small steps still count.'**
  String get homeMission59;

  /// No description provided for @journalTitle.
  ///
  /// In en, this message translates to:
  /// **'My Journal'**
  String get journalTitle;

  /// No description provided for @journalTabJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journalTabJournal;

  /// No description provided for @journalTabAffirm.
  ///
  /// In en, this message translates to:
  /// **'Affirm'**
  String get journalTabAffirm;

  /// No description provided for @journalTabVision.
  ///
  /// In en, this message translates to:
  /// **'Vision'**
  String get journalTabVision;

  /// No description provided for @journalTabZen.
  ///
  /// In en, this message translates to:
  /// **'Zen'**
  String get journalTabZen;

  /// No description provided for @journalAffirm0.
  ///
  /// In en, this message translates to:
  /// **'I am worthy of love and belonging.'**
  String get journalAffirm0;

  /// No description provided for @journalAffirm1.
  ///
  /// In en, this message translates to:
  /// **'I choose recovery every single day.'**
  String get journalAffirm1;

  /// No description provided for @journalAffirm2.
  ///
  /// In en, this message translates to:
  /// **'My past does not define my future.'**
  String get journalAffirm2;

  /// No description provided for @journalAffirm3.
  ///
  /// In en, this message translates to:
  /// **'I am getting stronger with each passing moment.'**
  String get journalAffirm3;

  /// No description provided for @journalAffirm4.
  ///
  /// In en, this message translates to:
  /// **'I deserve peace, health, and happiness.'**
  String get journalAffirm4;

  /// No description provided for @journalAffirm5.
  ///
  /// In en, this message translates to:
  /// **'I am proud of how far I have come.'**
  String get journalAffirm5;

  /// No description provided for @journalAffirm6.
  ///
  /// In en, this message translates to:
  /// **'I have the strength to overcome challenges.'**
  String get journalAffirm6;

  /// No description provided for @journalAffirm7.
  ///
  /// In en, this message translates to:
  /// **'Today I choose myself.'**
  String get journalAffirm7;

  /// No description provided for @journalAffirm8.
  ///
  /// In en, this message translates to:
  /// **'I am healing and growing every day.'**
  String get journalAffirm8;

  /// No description provided for @journalAffirm9.
  ///
  /// In en, this message translates to:
  /// **'I am not alone in this journey.'**
  String get journalAffirm9;

  /// No description provided for @journalAffirm10.
  ///
  /// In en, this message translates to:
  /// **'My sobriety is my greatest achievement.'**
  String get journalAffirm10;

  /// No description provided for @journalAffirm11.
  ///
  /// In en, this message translates to:
  /// **'I release what no longer serves me.'**
  String get journalAffirm11;

  /// No description provided for @journalAffirm12.
  ///
  /// In en, this message translates to:
  /// **'I am capable of change.'**
  String get journalAffirm12;

  /// No description provided for @journalAffirm13.
  ///
  /// In en, this message translates to:
  /// **'Every sober day is a victory.'**
  String get journalAffirm13;

  /// No description provided for @journalAffirm14.
  ///
  /// In en, this message translates to:
  /// **'I am becoming the person I want to be.'**
  String get journalAffirm14;

  /// No description provided for @zenQuote0.
  ///
  /// In en, this message translates to:
  /// **'The present moment is the only time over which we have dominion.'**
  String get zenQuote0;

  /// No description provided for @zenQuoteAuthor0.
  ///
  /// In en, this message translates to:
  /// **'Thich Nhat Hanh'**
  String get zenQuoteAuthor0;

  /// No description provided for @zenQuote1.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have to control your thoughts. You just have to stop letting them control you.'**
  String get zenQuote1;

  /// No description provided for @zenQuoteAuthor1.
  ///
  /// In en, this message translates to:
  /// **'Dan Millman'**
  String get zenQuoteAuthor1;

  /// No description provided for @zenQuote2.
  ///
  /// In en, this message translates to:
  /// **'Peace is not the absence of conflict, but the ability to cope with it.'**
  String get zenQuote2;

  /// No description provided for @zenQuoteAuthor2.
  ///
  /// In en, this message translates to:
  /// **'Mahatma Gandhi'**
  String get zenQuoteAuthor2;

  /// No description provided for @zenQuote3.
  ///
  /// In en, this message translates to:
  /// **'Recovery is not a race. You don\'t have to feel guilty if it takes you longer than you thought it would.'**
  String get zenQuote3;

  /// No description provided for @zenQuoteAuthor3.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get zenQuoteAuthor3;

  /// No description provided for @zenQuote4.
  ///
  /// In en, this message translates to:
  /// **'Every day is a new beginning. Take a deep breath, smile, and start again.'**
  String get zenQuote4;

  /// No description provided for @zenQuoteAuthor4.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get zenQuoteAuthor4;

  /// No description provided for @zenQuote5.
  ///
  /// In en, this message translates to:
  /// **'The wound is the place where the Light enters you.'**
  String get zenQuote5;

  /// No description provided for @zenQuoteAuthor5.
  ///
  /// In en, this message translates to:
  /// **'Rumi'**
  String get zenQuoteAuthor5;

  /// No description provided for @zenQuote6.
  ///
  /// In en, this message translates to:
  /// **'You are enough just as you are.'**
  String get zenQuote6;

  /// No description provided for @zenQuoteAuthor6.
  ///
  /// In en, this message translates to:
  /// **'Meghan Markle'**
  String get zenQuoteAuthor6;

  /// No description provided for @zenQuote7.
  ///
  /// In en, this message translates to:
  /// **'Healing is not linear.'**
  String get zenQuote7;

  /// No description provided for @zenQuoteAuthor7.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get zenQuoteAuthor7;

  /// No description provided for @zenQuote8.
  ///
  /// In en, this message translates to:
  /// **'What lies behind us and what lies before us are tiny matters compared to what lies within us.'**
  String get zenQuote8;

  /// No description provided for @zenQuoteAuthor8.
  ///
  /// In en, this message translates to:
  /// **'Ralph Waldo Emerson'**
  String get zenQuoteAuthor8;

  /// No description provided for @zenQuote9.
  ///
  /// In en, this message translates to:
  /// **'You have been assigned this mountain to show others it can be moved.'**
  String get zenQuote9;

  /// No description provided for @zenQuoteAuthor9.
  ///
  /// In en, this message translates to:
  /// **'Mel Robbins'**
  String get zenQuoteAuthor9;

  /// No description provided for @zenQuote10.
  ///
  /// In en, this message translates to:
  /// **'It does not matter how slowly you go as long as you do not stop.'**
  String get zenQuote10;

  /// No description provided for @zenQuoteAuthor10.
  ///
  /// In en, this message translates to:
  /// **'Confucius'**
  String get zenQuoteAuthor10;

  /// No description provided for @zenQuote11.
  ///
  /// In en, this message translates to:
  /// **'The hardest step she ever took was to blindly trust in who she was.'**
  String get zenQuote11;

  /// No description provided for @zenQuoteAuthor11.
  ///
  /// In en, this message translates to:
  /// **'Atticus'**
  String get zenQuoteAuthor11;

  /// No description provided for @zenQuote12.
  ///
  /// In en, this message translates to:
  /// **'One day at a time — this is enough. Do not look back and grieve over the past, for it is gone.'**
  String get zenQuote12;

  /// No description provided for @zenQuoteAuthor12.
  ///
  /// In en, this message translates to:
  /// **'Ida Scott Taylor'**
  String get zenQuoteAuthor12;

  /// No description provided for @zenQuote13.
  ///
  /// In en, this message translates to:
  /// **'Rock bottom became the solid foundation on which I rebuilt my life.'**
  String get zenQuote13;

  /// No description provided for @zenQuoteAuthor13.
  ///
  /// In en, this message translates to:
  /// **'J.K. Rowling'**
  String get zenQuoteAuthor13;

  /// No description provided for @zenQuote14.
  ///
  /// In en, this message translates to:
  /// **'Be patient with yourself. You are a child of the universe.'**
  String get zenQuote14;

  /// No description provided for @zenQuoteAuthor14.
  ///
  /// In en, this message translates to:
  /// **'Max Ehrmann'**
  String get zenQuoteAuthor14;

  /// No description provided for @zenQuote15.
  ///
  /// In en, this message translates to:
  /// **'In the middle of every difficulty lies opportunity.'**
  String get zenQuote15;

  /// No description provided for @zenQuoteAuthor15.
  ///
  /// In en, this message translates to:
  /// **'Albert Einstein'**
  String get zenQuoteAuthor15;

  /// No description provided for @zenQuote16.
  ///
  /// In en, this message translates to:
  /// **'Your present circumstances don\'t determine where you can go; they merely determine where you start.'**
  String get zenQuote16;

  /// No description provided for @zenQuoteAuthor16.
  ///
  /// In en, this message translates to:
  /// **'Nido Qubein'**
  String get zenQuoteAuthor16;

  /// No description provided for @zenQuote17.
  ///
  /// In en, this message translates to:
  /// **'The secret of getting ahead is getting started.'**
  String get zenQuote17;

  /// No description provided for @zenQuoteAuthor17.
  ///
  /// In en, this message translates to:
  /// **'Mark Twain'**
  String get zenQuoteAuthor17;

  /// No description provided for @zenQuote18.
  ///
  /// In en, this message translates to:
  /// **'You are braver than you believe, stronger than you seem, and smarter than you think.'**
  String get zenQuote18;

  /// No description provided for @zenQuoteAuthor18.
  ///
  /// In en, this message translates to:
  /// **'A.A. Milne'**
  String get zenQuoteAuthor18;

  /// No description provided for @zenQuote19.
  ///
  /// In en, this message translates to:
  /// **'Don\'t watch the clock; do what it does. Keep going.'**
  String get zenQuote19;

  /// No description provided for @zenQuoteAuthor19.
  ///
  /// In en, this message translates to:
  /// **'Sam Levenson'**
  String get zenQuoteAuthor19;

  /// No description provided for @zenQuote20.
  ///
  /// In en, this message translates to:
  /// **'Accept yourself, love yourself, and keep moving forward.'**
  String get zenQuote20;

  /// No description provided for @zenQuoteAuthor20.
  ///
  /// In en, this message translates to:
  /// **'Roy T. Bennett'**
  String get zenQuoteAuthor20;

  /// No description provided for @zenQuote21.
  ///
  /// In en, this message translates to:
  /// **'The journey of a thousand miles begins with one step.'**
  String get zenQuote21;

  /// No description provided for @zenQuoteAuthor21.
  ///
  /// In en, this message translates to:
  /// **'Lao Tzu'**
  String get zenQuoteAuthor21;

  /// No description provided for @zenQuote22.
  ///
  /// In en, this message translates to:
  /// **'You can\'t go back and change the beginning, but you can start where you are and change the ending.'**
  String get zenQuote22;

  /// No description provided for @zenQuoteAuthor22.
  ///
  /// In en, this message translates to:
  /// **'C.S. Lewis'**
  String get zenQuoteAuthor22;

  /// No description provided for @zenQuote23.
  ///
  /// In en, this message translates to:
  /// **'Strength does not come from physical capacity. It comes from an indomitable will.'**
  String get zenQuote23;

  /// No description provided for @zenQuoteAuthor23.
  ///
  /// In en, this message translates to:
  /// **'Mahatma Gandhi'**
  String get zenQuoteAuthor23;

  /// No description provided for @zenQuote24.
  ///
  /// In en, this message translates to:
  /// **'Every moment is a fresh beginning.'**
  String get zenQuote24;

  /// No description provided for @zenQuoteAuthor24.
  ///
  /// In en, this message translates to:
  /// **'T.S. Eliot'**
  String get zenQuoteAuthor24;

  /// No description provided for @zenQuote25.
  ///
  /// In en, this message translates to:
  /// **'Just when the caterpillar thought the world was ending, he turned into a butterfly.'**
  String get zenQuote25;

  /// No description provided for @zenQuoteAuthor25.
  ///
  /// In en, this message translates to:
  /// **'Proverb'**
  String get zenQuoteAuthor25;

  /// No description provided for @zenQuote26.
  ///
  /// In en, this message translates to:
  /// **'Courage doesn\'t always roar. Sometimes courage is the quiet voice at the end of the day saying, I will try again tomorrow.'**
  String get zenQuote26;

  /// No description provided for @zenQuoteAuthor26.
  ///
  /// In en, this message translates to:
  /// **'Mary Anne Radmacher'**
  String get zenQuoteAuthor26;

  /// No description provided for @zenQuote27.
  ///
  /// In en, this message translates to:
  /// **'The only way out is through.'**
  String get zenQuote27;

  /// No description provided for @zenQuoteAuthor27.
  ///
  /// In en, this message translates to:
  /// **'Robert Frost'**
  String get zenQuoteAuthor27;

  /// No description provided for @zenQuote28.
  ///
  /// In en, this message translates to:
  /// **'You are not your past. You are the lessons you\'ve learned from it.'**
  String get zenQuote28;

  /// No description provided for @zenQuoteAuthor28.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get zenQuoteAuthor28;

  /// No description provided for @zenQuote29.
  ///
  /// In en, this message translates to:
  /// **'Progress, not perfection.'**
  String get zenQuote29;

  /// No description provided for @zenQuoteAuthor29.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get zenQuoteAuthor29;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressTitle;

  /// No description provided for @progressDaysChip.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String progressDaysChip(int days);

  /// No description provided for @progressTabJourney.
  ///
  /// In en, this message translates to:
  /// **'Journey'**
  String get progressTabJourney;

  /// No description provided for @progressTabInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get progressTabInsights;

  /// No description provided for @progressMilestoneLabel1.
  ///
  /// In en, this message translates to:
  /// **'First Day'**
  String get progressMilestoneLabel1;

  /// No description provided for @progressMilestoneLabel2.
  ///
  /// In en, this message translates to:
  /// **'Two Days'**
  String get progressMilestoneLabel2;

  /// No description provided for @progressMilestoneLabel3.
  ///
  /// In en, this message translates to:
  /// **'Three Days'**
  String get progressMilestoneLabel3;

  /// No description provided for @progressMilestoneLabel5.
  ///
  /// In en, this message translates to:
  /// **'Five Days'**
  String get progressMilestoneLabel5;

  /// No description provided for @progressMilestoneLabel7.
  ///
  /// In en, this message translates to:
  /// **'One Week'**
  String get progressMilestoneLabel7;

  /// No description provided for @progressMilestoneLabel10.
  ///
  /// In en, this message translates to:
  /// **'Ten Days'**
  String get progressMilestoneLabel10;

  /// No description provided for @progressMilestoneLabel14.
  ///
  /// In en, this message translates to:
  /// **'Two Weeks'**
  String get progressMilestoneLabel14;

  /// No description provided for @progressMilestoneLabel21.
  ///
  /// In en, this message translates to:
  /// **'Three Weeks'**
  String get progressMilestoneLabel21;

  /// No description provided for @progressMilestoneLabel30.
  ///
  /// In en, this message translates to:
  /// **'One Month'**
  String get progressMilestoneLabel30;

  /// No description provided for @progressMilestoneLabel60.
  ///
  /// In en, this message translates to:
  /// **'Two Months'**
  String get progressMilestoneLabel60;

  /// No description provided for @progressMilestoneLabel90.
  ///
  /// In en, this message translates to:
  /// **'Three Months'**
  String get progressMilestoneLabel90;

  /// No description provided for @progressMilestoneLabel100.
  ///
  /// In en, this message translates to:
  /// **'100 Days'**
  String get progressMilestoneLabel100;

  /// No description provided for @progressMilestoneLabel180.
  ///
  /// In en, this message translates to:
  /// **'Six Months'**
  String get progressMilestoneLabel180;

  /// No description provided for @progressMilestoneLabel365.
  ///
  /// In en, this message translates to:
  /// **'One Year'**
  String get progressMilestoneLabel365;

  /// No description provided for @progressMilestoneLabel730.
  ///
  /// In en, this message translates to:
  /// **'Two Years'**
  String get progressMilestoneLabel730;

  /// No description provided for @progressMilestoneLabel1095.
  ///
  /// In en, this message translates to:
  /// **'Three Years'**
  String get progressMilestoneLabel1095;

  /// No description provided for @insightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insightsTitle;

  /// No description provided for @insights7DayView.
  ///
  /// In en, this message translates to:
  /// **'7-day view'**
  String get insights7DayView;

  /// No description provided for @milestoneScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get milestoneScreenTitle;

  /// No description provided for @milestoneOneDay.
  ///
  /// In en, this message translates to:
  /// **'One Day'**
  String get milestoneOneDay;

  /// No description provided for @milestoneOneDayShort.
  ///
  /// In en, this message translates to:
  /// **'1 Day'**
  String get milestoneOneDayShort;

  /// No description provided for @milestoneOneDayBenefit.
  ///
  /// In en, this message translates to:
  /// **'One full day. Alcohol typically clears from the body within this window. For many people, tonight\'s sleep — though sometimes restless — feels different from the nights that came before.'**
  String get milestoneOneDayBenefit;

  /// No description provided for @milestoneThreeDays.
  ///
  /// In en, this message translates to:
  /// **'Three Days'**
  String get milestoneThreeDays;

  /// No description provided for @milestoneThreeDaysShort.
  ///
  /// In en, this message translates to:
  /// **'3 Days'**
  String get milestoneThreeDaysShort;

  /// No description provided for @milestoneThreeDaysBenefit.
  ///
  /// In en, this message translates to:
  /// **'Most alcohol metabolites have left your body. The brain\'s GABA system is recalibrating — this can bring restlessness, but it means your nervous system is finding its natural balance again. Hydration is improving.'**
  String get milestoneThreeDaysBenefit;

  /// No description provided for @milestoneOneWeek.
  ///
  /// In en, this message translates to:
  /// **'One Week'**
  String get milestoneOneWeek;

  /// No description provided for @milestoneOneWeekShort.
  ///
  /// In en, this message translates to:
  /// **'1 Week'**
  String get milestoneOneWeekShort;

  /// No description provided for @milestoneOneWeekBenefit.
  ///
  /// In en, this message translates to:
  /// **'One full week. Many people start to notice sharper thinking, more natural energy, and better hydration around this stage. Your body has had a meaningful stretch of recovery time.'**
  String get milestoneOneWeekBenefit;

  /// No description provided for @milestoneTwoWeeks.
  ///
  /// In en, this message translates to:
  /// **'Two Weeks'**
  String get milestoneTwoWeeks;

  /// No description provided for @milestoneTwoWeeksShort.
  ///
  /// In en, this message translates to:
  /// **'2 Weeks'**
  String get milestoneTwoWeeksShort;

  /// No description provided for @milestoneTwoWeeksBenefit.
  ///
  /// In en, this message translates to:
  /// **'Two weeks. For many people, anxiety begins to stabilise and sleep deepens. The early-recovery storm often starts to soften here, though every person\'s timeline is different.'**
  String get milestoneTwoWeeksBenefit;

  /// No description provided for @milestoneOneMonth.
  ///
  /// In en, this message translates to:
  /// **'One Month'**
  String get milestoneOneMonth;

  /// No description provided for @milestoneOneMonthShort.
  ///
  /// In en, this message translates to:
  /// **'1 Month'**
  String get milestoneOneMonthShort;

  /// No description provided for @milestoneOneMonthBenefit.
  ///
  /// In en, this message translates to:
  /// **'One month. Many people describe meaningful gains in clarity and emotional steadiness at this point. Cravings can become easier to observe without acting on them.'**
  String get milestoneOneMonthBenefit;

  /// No description provided for @milestoneTwoMonths.
  ///
  /// In en, this message translates to:
  /// **'Two Months'**
  String get milestoneTwoMonths;

  /// No description provided for @milestoneTwoMonthsShort.
  ///
  /// In en, this message translates to:
  /// **'2 Months'**
  String get milestoneTwoMonthsShort;

  /// No description provided for @milestoneTwoMonthsBenefit.
  ///
  /// In en, this message translates to:
  /// **'Two months. Research suggests the prefrontal cortex — responsible for decisions, impulse control, and empathy — begins to recover meaningfully around this stage. Many people see improvements in cholesterol levels. You are physically and neurologically different from who you were.'**
  String get milestoneTwoMonthsBenefit;

  /// No description provided for @milestoneThreeMonths.
  ///
  /// In en, this message translates to:
  /// **'Three Months'**
  String get milestoneThreeMonths;

  /// No description provided for @milestoneThreeMonthsShort.
  ///
  /// In en, this message translates to:
  /// **'3 Months'**
  String get milestoneThreeMonthsShort;

  /// No description provided for @milestoneThreeMonthsBenefit.
  ///
  /// In en, this message translates to:
  /// **'Three months. Skin can look clearer, sleep can feel deeper, and concentration often continues to sharpen. You have built real momentum.'**
  String get milestoneThreeMonthsBenefit;

  /// No description provided for @milestoneSixMonths.
  ///
  /// In en, this message translates to:
  /// **'Six Months'**
  String get milestoneSixMonths;

  /// No description provided for @milestoneSixMonthsShort.
  ///
  /// In en, this message translates to:
  /// **'6 Months'**
  String get milestoneSixMonthsShort;

  /// No description provided for @milestoneSixMonthsBenefit.
  ///
  /// In en, this message translates to:
  /// **'Six months. Many people report that around this point, sobriety has begun to feel like part of who they are — not just a goal they\'re chasing.'**
  String get milestoneSixMonthsBenefit;

  /// No description provided for @milestoneOneYear.
  ///
  /// In en, this message translates to:
  /// **'One Year'**
  String get milestoneOneYear;

  /// No description provided for @milestoneOneYearShort.
  ///
  /// In en, this message translates to:
  /// **'1 Year'**
  String get milestoneOneYearShort;

  /// No description provided for @milestoneOneYearBenefit.
  ///
  /// In en, this message translates to:
  /// **'One year. This is a profound milestone. Many people describe genuine, lasting changes in how they feel and how they relate to themselves. The cumulative gains of a year without alcohol are real — and they are yours.'**
  String get milestoneOneYearBenefit;

  /// No description provided for @recoveryTitle.
  ///
  /// In en, this message translates to:
  /// **'The Healing Timeline'**
  String get recoveryTitle;

  /// No description provided for @recoverySubtitle.
  ///
  /// In en, this message translates to:
  /// **'How your mind and body are restoring themselves'**
  String get recoverySubtitle;

  /// No description provided for @recoveryHeroLabel.
  ///
  /// In en, this message translates to:
  /// **'YOUR BODY TODAY'**
  String get recoveryHeroLabel;

  /// No description provided for @recoveryDaysSober.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day sober} other{{days} days sober}}'**
  String recoveryDaysSober(int days);

  /// No description provided for @recoveryMilestonesReached.
  ///
  /// In en, this message translates to:
  /// **'{achieved} of {total} milestones reached'**
  String recoveryMilestonesReached(int achieved, int total);

  /// No description provided for @recoveryM1Label.
  ///
  /// In en, this message translates to:
  /// **'12 Hours'**
  String get recoveryM1Label;

  /// No description provided for @recoveryM1Title.
  ///
  /// In en, this message translates to:
  /// **'The Reset Begins'**
  String get recoveryM1Title;

  /// No description provided for @recoveryM1Body.
  ///
  /// In en, this message translates to:
  /// **'Your body begins adjusting to the absence of alcohol. Hydration, sleep pressure, blood sugar, and stress hormones may feel unsettled as your system begins to rebalance.'**
  String get recoveryM1Body;

  /// No description provided for @recoveryM1System.
  ///
  /// In en, this message translates to:
  /// **'Total Body'**
  String get recoveryM1System;

  /// No description provided for @recoveryM2Label.
  ///
  /// In en, this message translates to:
  /// **'24 Hours'**
  String get recoveryM2Label;

  /// No description provided for @recoveryM2Title.
  ///
  /// In en, this message translates to:
  /// **'Restoring Rhythm'**
  String get recoveryM2Title;

  /// No description provided for @recoveryM2Body.
  ///
  /// In en, this message translates to:
  /// **'For many people, the body\'s basic rhythms — heart rate, hydration, sleep — start to shift as it adjusts. This can feel calming for some and uncomfortable for others.'**
  String get recoveryM2Body;

  /// No description provided for @recoveryM2System.
  ///
  /// In en, this message translates to:
  /// **'Cardiovascular System'**
  String get recoveryM2System;

  /// No description provided for @recoveryM3Label.
  ///
  /// In en, this message translates to:
  /// **'48 Hours'**
  String get recoveryM3Label;

  /// No description provided for @recoveryM3Title.
  ///
  /// In en, this message translates to:
  /// **'The Pivot Point'**
  String get recoveryM3Title;

  /// No description provided for @recoveryM3Body.
  ///
  /// In en, this message translates to:
  /// **'For people who were drinking heavily, this can be one of the highest-risk windows for withdrawal symptoms. Your nervous system may feel overstimulated as it works to rebalance.'**
  String get recoveryM3Body;

  /// No description provided for @recoveryM3System.
  ///
  /// In en, this message translates to:
  /// **'Central Nervous System'**
  String get recoveryM3System;

  /// No description provided for @recoveryM4Label.
  ///
  /// In en, this message translates to:
  /// **'3 Days'**
  String get recoveryM4Label;

  /// No description provided for @recoveryM4Title.
  ///
  /// In en, this message translates to:
  /// **'Clearing the System'**
  String get recoveryM4Title;

  /// No description provided for @recoveryM4Body.
  ///
  /// In en, this message translates to:
  /// **'For many people, the most intense early physical adjustment begins to ease around this point, though recovery is individual and some symptoms can continue.'**
  String get recoveryM4Body;

  /// No description provided for @recoveryM4System.
  ///
  /// In en, this message translates to:
  /// **'Total Body'**
  String get recoveryM4System;

  /// No description provided for @recoveryM5Label.
  ///
  /// In en, this message translates to:
  /// **'1 Week'**
  String get recoveryM5Label;

  /// No description provided for @recoveryM5Title.
  ///
  /// In en, this message translates to:
  /// **'Deepening Rest'**
  String get recoveryM5Title;

  /// No description provided for @recoveryM5Body.
  ///
  /// In en, this message translates to:
  /// **'Restorative sleep often begins to return. Hydration, appetite, and daily energy may start to feel more stable, although sleep and mood can still fluctuate.'**
  String get recoveryM5Body;

  /// No description provided for @recoveryM5System.
  ///
  /// In en, this message translates to:
  /// **'Brain & Sleep Cycles'**
  String get recoveryM5System;

  /// No description provided for @recoveryM6Label.
  ///
  /// In en, this message translates to:
  /// **'2 Weeks'**
  String get recoveryM6Label;

  /// No description provided for @recoveryM6Title.
  ///
  /// In en, this message translates to:
  /// **'Finding Balance'**
  String get recoveryM6Title;

  /// No description provided for @recoveryM6Body.
  ///
  /// In en, this message translates to:
  /// **'Physical stamina may begin to return as sleep, appetite, hydration, and daily rhythm become more stable.'**
  String get recoveryM6Body;

  /// No description provided for @recoveryM6System.
  ///
  /// In en, this message translates to:
  /// **'Energy & Digestion'**
  String get recoveryM6System;

  /// No description provided for @recoveryM7Label.
  ///
  /// In en, this message translates to:
  /// **'1 Month'**
  String get recoveryM7Label;

  /// No description provided for @recoveryM7Title.
  ///
  /// In en, this message translates to:
  /// **'Meaningful Relief'**
  String get recoveryM7Title;

  /// No description provided for @recoveryM7Body.
  ///
  /// In en, this message translates to:
  /// **'Your body has had a meaningful stretch of relief from the strain of alcohol. Many people notice steadier energy, clearer thinking, and improved sleep around this stage.'**
  String get recoveryM7Body;

  /// No description provided for @recoveryM7System.
  ///
  /// In en, this message translates to:
  /// **'Liver & Vital Organs'**
  String get recoveryM7System;

  /// No description provided for @recoveryM8Label.
  ///
  /// In en, this message translates to:
  /// **'3 Months'**
  String get recoveryM8Label;

  /// No description provided for @recoveryM8Title.
  ///
  /// In en, this message translates to:
  /// **'Restoring Joy'**
  String get recoveryM8Title;

  /// No description provided for @recoveryM8Body.
  ///
  /// In en, this message translates to:
  /// **'Your body may feel more resilient as sleep, nourishment, movement, and reduced alcohol strain begin working together.'**
  String get recoveryM8Body;

  /// No description provided for @recoveryM8System.
  ///
  /// In en, this message translates to:
  /// **'Neurochemistry'**
  String get recoveryM8System;

  /// No description provided for @recoveryM9Label.
  ///
  /// In en, this message translates to:
  /// **'6 Months'**
  String get recoveryM9Label;

  /// No description provided for @recoveryM9Title.
  ///
  /// In en, this message translates to:
  /// **'True Resilience'**
  String get recoveryM9Title;

  /// No description provided for @recoveryM9Body.
  ///
  /// In en, this message translates to:
  /// **'Many people notice a steadier baseline by this stage. Stress may feel more manageable, sleep may feel more reliable.'**
  String get recoveryM9Body;

  /// No description provided for @recoveryM9System.
  ///
  /// In en, this message translates to:
  /// **'Nervous System'**
  String get recoveryM9System;

  /// No description provided for @recoveryM10Label.
  ///
  /// In en, this message translates to:
  /// **'1 Year'**
  String get recoveryM10Label;

  /// No description provided for @recoveryM10Title.
  ///
  /// In en, this message translates to:
  /// **'A New Baseline'**
  String get recoveryM10Title;

  /// No description provided for @recoveryM10Body.
  ///
  /// In en, this message translates to:
  /// **'For many people, the long-term load on energy, sleep, and mood is meaningfully lighter after a year without alcohol.'**
  String get recoveryM10Body;

  /// No description provided for @recoveryM10System.
  ///
  /// In en, this message translates to:
  /// **'Whole Body'**
  String get recoveryM10System;

  /// No description provided for @recoveryM11Label.
  ///
  /// In en, this message translates to:
  /// **'2 Years & Beyond'**
  String get recoveryM11Label;

  /// No description provided for @recoveryM11Title.
  ///
  /// In en, this message translates to:
  /// **'Lasting Vitality'**
  String get recoveryM11Title;

  /// No description provided for @recoveryM11Body.
  ///
  /// In en, this message translates to:
  /// **'The benefits of reduced alcohol strain can continue to deepen over time, supporting your body, mind, relationships, and daily sense of stability.'**
  String get recoveryM11Body;

  /// No description provided for @recoveryM11System.
  ///
  /// In en, this message translates to:
  /// **'Whole Body Renewal'**
  String get recoveryM11System;

  /// No description provided for @emergencyHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Calm Toolkit'**
  String get emergencyHomeTitle;

  /// No description provided for @emergencyHomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What do you need right now?'**
  String get emergencyHomeSubtitle;

  /// No description provided for @emergencyBreathingTitle.
  ///
  /// In en, this message translates to:
  /// **'Breathing'**
  String get emergencyBreathingTitle;

  /// No description provided for @emergencyMeditationTitle.
  ///
  /// In en, this message translates to:
  /// **'Meditation'**
  String get emergencyMeditationTitle;

  /// No description provided for @emergencyCBTTitle.
  ///
  /// In en, this message translates to:
  /// **'CBT Guides'**
  String get emergencyCBTTitle;

  /// No description provided for @emergencyReasonsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Reasons'**
  String get emergencyReasonsTitle;

  /// No description provided for @emergencyHALTTitle.
  ///
  /// In en, this message translates to:
  /// **'HALT Check'**
  String get emergencyHALTTitle;

  /// No description provided for @emergencyUrgeTimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Urge Timer'**
  String get emergencyUrgeTimerTitle;

  /// No description provided for @emergencyPlayTapeTitle.
  ///
  /// In en, this message translates to:
  /// **'Play the Tape'**
  String get emergencyPlayTapeTitle;

  /// No description provided for @emergencyMindfulnessTitle.
  ///
  /// In en, this message translates to:
  /// **'Mindfulness'**
  String get emergencyMindfulnessTitle;

  /// No description provided for @breathPatternBoxName.
  ///
  /// In en, this message translates to:
  /// **'Box'**
  String get breathPatternBoxName;

  /// No description provided for @breathPatternBoxDesc.
  ///
  /// In en, this message translates to:
  /// **'Equal sides — focus and calm'**
  String get breathPatternBoxDesc;

  /// No description provided for @breathPattern478Name.
  ///
  /// In en, this message translates to:
  /// **'4-7-8'**
  String get breathPattern478Name;

  /// No description provided for @breathPattern478Desc.
  ///
  /// In en, this message translates to:
  /// **'Deep relaxation and sleep'**
  String get breathPattern478Desc;

  /// No description provided for @breathPatternCalmName.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get breathPatternCalmName;

  /// No description provided for @breathPatternCalmDesc.
  ///
  /// In en, this message translates to:
  /// **'Quick anxiety reset'**
  String get breathPatternCalmDesc;

  /// No description provided for @breathPatternPowerName.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get breathPatternPowerName;

  /// No description provided for @breathPatternPowerDesc.
  ///
  /// In en, this message translates to:
  /// **'Energy and alertness'**
  String get breathPatternPowerDesc;

  /// No description provided for @breathPatternResetName.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get breathPatternResetName;

  /// No description provided for @breathPatternResetDesc.
  ///
  /// In en, this message translates to:
  /// **'Instant stress relief'**
  String get breathPatternResetDesc;

  /// No description provided for @breathPatternTriangleName.
  ///
  /// In en, this message translates to:
  /// **'Triangle'**
  String get breathPatternTriangleName;

  /// No description provided for @breathPatternTriangleDesc.
  ///
  /// In en, this message translates to:
  /// **'Simple three-phase balance'**
  String get breathPatternTriangleDesc;

  /// No description provided for @breathPatternAnchorName.
  ///
  /// In en, this message translates to:
  /// **'Anchor'**
  String get breathPatternAnchorName;

  /// No description provided for @breathPatternAnchorDesc.
  ///
  /// In en, this message translates to:
  /// **'Grounding in difficult moments'**
  String get breathPatternAnchorDesc;

  /// No description provided for @breathPatternRescueName.
  ///
  /// In en, this message translates to:
  /// **'Rescue'**
  String get breathPatternRescueName;

  /// No description provided for @breathPatternRescueDesc.
  ///
  /// In en, this message translates to:
  /// **'Panic and high anxiety'**
  String get breathPatternRescueDesc;

  /// No description provided for @breathPatternOceanName.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get breathPatternOceanName;

  /// No description provided for @breathPatternOceanDesc.
  ///
  /// In en, this message translates to:
  /// **'Wave-like natural rhythm'**
  String get breathPatternOceanDesc;

  /// No description provided for @breathPatternMorningName.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get breathPatternMorningName;

  /// No description provided for @breathPatternMorningDesc.
  ///
  /// In en, this message translates to:
  /// **'Wake up and energise'**
  String get breathPatternMorningDesc;

  /// No description provided for @breathPatternCoherentName.
  ///
  /// In en, this message translates to:
  /// **'Coherent'**
  String get breathPatternCoherentName;

  /// No description provided for @breathPatternCoherentDesc.
  ///
  /// In en, this message translates to:
  /// **'Heart-rate variability balance'**
  String get breathPatternCoherentDesc;

  /// No description provided for @breathPattern628Name.
  ///
  /// In en, this message translates to:
  /// **'6-2-8'**
  String get breathPattern628Name;

  /// No description provided for @breathPattern628Desc.
  ///
  /// In en, this message translates to:
  /// **'Deep parasympathetic activation'**
  String get breathPattern628Desc;

  /// No description provided for @breathPatternSquarePlusName.
  ///
  /// In en, this message translates to:
  /// **'Square+'**
  String get breathPatternSquarePlusName;

  /// No description provided for @breathPatternSquarePlusDesc.
  ///
  /// In en, this message translates to:
  /// **'Extended box for deep calm'**
  String get breathPatternSquarePlusDesc;

  /// No description provided for @breathPatternWarriorName.
  ///
  /// In en, this message translates to:
  /// **'Warrior'**
  String get breathPatternWarriorName;

  /// No description provided for @breathPatternWarriorDesc.
  ///
  /// In en, this message translates to:
  /// **'Strength and determination'**
  String get breathPatternWarriorDesc;

  /// No description provided for @breathPatternNightName.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get breathPatternNightName;

  /// No description provided for @breathPatternNightDesc.
  ///
  /// In en, this message translates to:
  /// **'Pre-sleep wind-down'**
  String get breathPatternNightDesc;

  /// No description provided for @breathPhaseInhale.
  ///
  /// In en, this message translates to:
  /// **'Inhale'**
  String get breathPhaseInhale;

  /// No description provided for @breathPhaseHold.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get breathPhaseHold;

  /// No description provided for @breathPhaseExhale.
  ///
  /// In en, this message translates to:
  /// **'Exhale'**
  String get breathPhaseExhale;

  /// No description provided for @breathCycleCount.
  ///
  /// In en, this message translates to:
  /// **'{count} cycles'**
  String breathCycleCount(int count);

  /// No description provided for @cbtGuide0Title.
  ///
  /// In en, this message translates to:
  /// **'Challenge the Thought'**
  String get cbtGuide0Title;

  /// No description provided for @cbtGuide0Step0.
  ///
  /// In en, this message translates to:
  /// **'Write down the thought that\'s troubling you.'**
  String get cbtGuide0Step0;

  /// No description provided for @cbtGuide0Step1.
  ///
  /// In en, this message translates to:
  /// **'Ask: Is this thought based on fact or feeling?'**
  String get cbtGuide0Step1;

  /// No description provided for @cbtGuide0Step2.
  ///
  /// In en, this message translates to:
  /// **'What evidence supports this thought? What contradicts it?'**
  String get cbtGuide0Step2;

  /// No description provided for @cbtGuide0Step3.
  ///
  /// In en, this message translates to:
  /// **'What would you say to a friend having this thought?'**
  String get cbtGuide0Step3;

  /// No description provided for @cbtGuide0Step4.
  ///
  /// In en, this message translates to:
  /// **'Write a more balanced version of the thought.'**
  String get cbtGuide0Step4;

  /// No description provided for @cbtGuide0Step5.
  ///
  /// In en, this message translates to:
  /// **'Notice how you feel after reframing it.'**
  String get cbtGuide0Step5;

  /// No description provided for @cbtGuide1Title.
  ///
  /// In en, this message translates to:
  /// **'Surf the Urge'**
  String get cbtGuide1Title;

  /// No description provided for @cbtGuide1Step0.
  ///
  /// In en, this message translates to:
  /// **'Recognise the urge — name it: \"I notice a craving.\"'**
  String get cbtGuide1Step0;

  /// No description provided for @cbtGuide1Step1.
  ///
  /// In en, this message translates to:
  /// **'Don\'t fight it. Observe it like a wave.'**
  String get cbtGuide1Step1;

  /// No description provided for @cbtGuide1Step2.
  ///
  /// In en, this message translates to:
  /// **'Notice where you feel it in your body.'**
  String get cbtGuide1Step2;

  /// No description provided for @cbtGuide1Step3.
  ///
  /// In en, this message translates to:
  /// **'Breathe slowly. The wave will peak and pass.'**
  String get cbtGuide1Step3;

  /// No description provided for @cbtGuide1Step4.
  ///
  /// In en, this message translates to:
  /// **'Remind yourself: urges always pass within 20–30 minutes.'**
  String get cbtGuide1Step4;

  /// No description provided for @cbtGuide2Title.
  ///
  /// In en, this message translates to:
  /// **'Cost-Benefit Check'**
  String get cbtGuide2Title;

  /// No description provided for @cbtGuide2Step0.
  ///
  /// In en, this message translates to:
  /// **'List the short-term benefits of drinking.'**
  String get cbtGuide2Step0;

  /// No description provided for @cbtGuide2Step1.
  ///
  /// In en, this message translates to:
  /// **'List the short-term costs of drinking.'**
  String get cbtGuide2Step1;

  /// No description provided for @cbtGuide2Step2.
  ///
  /// In en, this message translates to:
  /// **'List the long-term benefits of staying sober.'**
  String get cbtGuide2Step2;

  /// No description provided for @cbtGuide2Step3.
  ///
  /// In en, this message translates to:
  /// **'List the long-term costs of drinking.'**
  String get cbtGuide2Step3;

  /// No description provided for @cbtGuide2Step4.
  ///
  /// In en, this message translates to:
  /// **'Which column weighs more to your future self?'**
  String get cbtGuide2Step4;

  /// No description provided for @cbtGuide3Title.
  ///
  /// In en, this message translates to:
  /// **'Trigger Action Plan'**
  String get cbtGuide3Title;

  /// No description provided for @cbtGuide3Step0.
  ///
  /// In en, this message translates to:
  /// **'Identify the trigger: person, place, feeling, or time.'**
  String get cbtGuide3Step0;

  /// No description provided for @cbtGuide3Step1.
  ///
  /// In en, this message translates to:
  /// **'What has worked before in similar moments?'**
  String get cbtGuide3Step1;

  /// No description provided for @cbtGuide3Step2.
  ///
  /// In en, this message translates to:
  /// **'Who can you call or text right now?'**
  String get cbtGuide3Step2;

  /// No description provided for @cbtGuide3Step3.
  ///
  /// In en, this message translates to:
  /// **'What activity can you do for the next 20 minutes?'**
  String get cbtGuide3Step3;

  /// No description provided for @cbtGuide3Step4.
  ///
  /// In en, this message translates to:
  /// **'Write your commitment: \"When X happens, I will Y.\"'**
  String get cbtGuide3Step4;

  /// No description provided for @cbtGuide4Title.
  ///
  /// In en, this message translates to:
  /// **'Identity Shift'**
  String get cbtGuide4Title;

  /// No description provided for @cbtGuide4Step0.
  ///
  /// In en, this message translates to:
  /// **'Describe the person you are becoming.'**
  String get cbtGuide4Step0;

  /// No description provided for @cbtGuide4Step1.
  ///
  /// In en, this message translates to:
  /// **'What values guide that person?'**
  String get cbtGuide4Step1;

  /// No description provided for @cbtGuide4Step2.
  ///
  /// In en, this message translates to:
  /// **'What would that person do right now?'**
  String get cbtGuide4Step2;

  /// No description provided for @cbtGuide4Step3.
  ///
  /// In en, this message translates to:
  /// **'Write: \"I am someone who...\"'**
  String get cbtGuide4Step3;

  /// No description provided for @cbtGuide4Step4.
  ///
  /// In en, this message translates to:
  /// **'Act from that identity for the next hour.'**
  String get cbtGuide4Step4;

  /// No description provided for @haltH.
  ///
  /// In en, this message translates to:
  /// **'H'**
  String get haltH;

  /// No description provided for @haltHungry.
  ///
  /// In en, this message translates to:
  /// **'Hungry'**
  String get haltHungry;

  /// No description provided for @haltHungryAdvice.
  ///
  /// In en, this message translates to:
  /// **'Eat something nourishing before making any decisions.'**
  String get haltHungryAdvice;

  /// No description provided for @haltA.
  ///
  /// In en, this message translates to:
  /// **'A'**
  String get haltA;

  /// No description provided for @haltAngry.
  ///
  /// In en, this message translates to:
  /// **'Angry'**
  String get haltAngry;

  /// No description provided for @haltAngryAdvice.
  ///
  /// In en, this message translates to:
  /// **'Breathe first. Anger distorts judgment. Pause for 10 minutes.'**
  String get haltAngryAdvice;

  /// No description provided for @haltL.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get haltL;

  /// No description provided for @haltLonely.
  ///
  /// In en, this message translates to:
  /// **'Lonely'**
  String get haltLonely;

  /// No description provided for @haltLonelyAdvice.
  ///
  /// In en, this message translates to:
  /// **'Reach out to one person. Connection is medicine.'**
  String get haltLonelyAdvice;

  /// No description provided for @haltT.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get haltT;

  /// No description provided for @haltTired.
  ///
  /// In en, this message translates to:
  /// **'Tired'**
  String get haltTired;

  /// No description provided for @haltTiredAdvice.
  ///
  /// In en, this message translates to:
  /// **'Rest before responding. Exhaustion lowers your defenses.'**
  String get haltTiredAdvice;

  /// No description provided for @mindful0Title.
  ///
  /// In en, this message translates to:
  /// **'5-4-3-2-1'**
  String get mindful0Title;

  /// No description provided for @mindful0Desc.
  ///
  /// In en, this message translates to:
  /// **'5 things you can see, 4 you can touch, 3 you can hear, 2 you can smell, 1 you can taste.'**
  String get mindful0Desc;

  /// No description provided for @mindful1Title.
  ///
  /// In en, this message translates to:
  /// **'One Breath'**
  String get mindful1Title;

  /// No description provided for @mindful1Desc.
  ///
  /// In en, this message translates to:
  /// **'Take the longest, slowest breath of your day right now. Feel your lungs expand fully.'**
  String get mindful1Desc;

  /// No description provided for @mindful2Title.
  ///
  /// In en, this message translates to:
  /// **'Body Check'**
  String get mindful2Title;

  /// No description provided for @mindful2Desc.
  ///
  /// In en, this message translates to:
  /// **'Starting from your feet, slowly scan upward. Notice tension without judging it.'**
  String get mindful2Desc;

  /// No description provided for @mindful3Title.
  ///
  /// In en, this message translates to:
  /// **'The Observer'**
  String get mindful3Title;

  /// No description provided for @mindful3Desc.
  ///
  /// In en, this message translates to:
  /// **'Step back from your thoughts. Watch them like clouds passing — you are the sky, not the clouds.'**
  String get mindful3Desc;

  /// No description provided for @mindful4Title.
  ///
  /// In en, this message translates to:
  /// **'Label It'**
  String get mindful4Title;

  /// No description provided for @mindful4Desc.
  ///
  /// In en, this message translates to:
  /// **'Name what you\'re feeling: \"Anxiety is here.\" Naming it reduces its power.'**
  String get mindful4Desc;

  /// No description provided for @mindful5Title.
  ///
  /// In en, this message translates to:
  /// **'Present Anchor'**
  String get mindful5Title;

  /// No description provided for @mindful5Desc.
  ///
  /// In en, this message translates to:
  /// **'Press your feet into the floor. Feel the weight of your body. You are here. You are safe.'**
  String get mindful5Desc;

  /// No description provided for @crisisTitle.
  ///
  /// In en, this message translates to:
  /// **'Crisis Lines'**
  String get crisisTitle;

  /// No description provided for @crisisTooltipBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get crisisTooltipBack;

  /// No description provided for @crisisEmergencyHeadline.
  ///
  /// In en, this message translates to:
  /// **'In immediate danger? Call emergency services'**
  String get crisisEmergencyHeadline;

  /// No description provided for @crisisWithdrawalTitle.
  ///
  /// In en, this message translates to:
  /// **'Alcohol withdrawal can be dangerous'**
  String get crisisWithdrawalTitle;

  /// No description provided for @crisisWithdrawalTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to see warning signs'**
  String get crisisWithdrawalTapHint;

  /// No description provided for @crisisSectionHeader.
  ///
  /// In en, this message translates to:
  /// **'CRISIS LINES'**
  String get crisisSectionHeader;

  /// No description provided for @crisisSeekMedical.
  ///
  /// In en, this message translates to:
  /// **'Seek immediate medical attention if you experience:'**
  String get crisisSeekMedical;

  /// No description provided for @crisisCallEmergency.
  ///
  /// In en, this message translates to:
  /// **'If you experience any of these, call emergency services immediately. Do not try to manage alone.'**
  String get crisisCallEmergency;

  /// No description provided for @crisisTooltipCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get crisisTooltipCall;

  /// No description provided for @crisisTooltipCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get crisisTooltipCopy;

  /// No description provided for @crisisLinesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 line} other{{count} lines}}'**
  String crisisLinesCount(int count);

  /// No description provided for @crisisWithdrawal0.
  ///
  /// In en, this message translates to:
  /// **'Seizures or convulsions'**
  String get crisisWithdrawal0;

  /// No description provided for @crisisWithdrawal1.
  ///
  /// In en, this message translates to:
  /// **'Hallucinations (seeing or hearing things)'**
  String get crisisWithdrawal1;

  /// No description provided for @crisisWithdrawal2.
  ///
  /// In en, this message translates to:
  /// **'Severe tremors (whole-body shaking)'**
  String get crisisWithdrawal2;

  /// No description provided for @crisisWithdrawal3.
  ///
  /// In en, this message translates to:
  /// **'Confusion or disorientation'**
  String get crisisWithdrawal3;

  /// No description provided for @crisisWithdrawal4.
  ///
  /// In en, this message translates to:
  /// **'High fever (above 38.5 C / 101 F)'**
  String get crisisWithdrawal4;

  /// No description provided for @crisisWithdrawal5.
  ///
  /// In en, this message translates to:
  /// **'Rapid heart rate (above 100 bpm)'**
  String get crisisWithdrawal5;

  /// No description provided for @crisisWithdrawal6.
  ///
  /// In en, this message translates to:
  /// **'Extreme sweating or clamminess'**
  String get crisisWithdrawal6;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsTitle;

  /// No description provided for @settingsYourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get settingsYourName;

  /// No description provided for @settingsNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Alex'**
  String get settingsNameHint;

  /// No description provided for @settingsSavingsGoalDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Savings goal'**
  String get settingsSavingsGoalDialogTitle;

  /// No description provided for @settingsGoalNameHint.
  ///
  /// In en, this message translates to:
  /// **'Goal name (e.g. Holiday)'**
  String get settingsGoalNameHint;

  /// No description provided for @settingsTargetAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Target amount'**
  String get settingsTargetAmountHint;

  /// No description provided for @settingsEmergencyContactDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency contact'**
  String get settingsEmergencyContactDialogTitle;

  /// No description provided for @settingsContactNameHint.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get settingsContactNameHint;

  /// No description provided for @settingsContactPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get settingsContactPhoneHint;

  /// No description provided for @settingsSoberDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Sober date'**
  String get settingsSoberDateLabel;

  /// No description provided for @settingsDailySpendLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily spend'**
  String get settingsDailySpendLabel;

  /// No description provided for @settingsLockMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get settingsLockMethodLabel;

  /// No description provided for @settingsNotificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotificationsLabel;

  /// No description provided for @settingsPrivacyLabel.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacyLabel;

  /// No description provided for @settingsBackupLabel.
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get settingsBackupLabel;

  /// No description provided for @settingsHistoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Full history'**
  String get settingsHistoryLabel;

  /// No description provided for @settingsInsightsLabel.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get settingsInsightsLabel;

  /// No description provided for @settingsGroupsLabel.
  ///
  /// In en, this message translates to:
  /// **'Support groups'**
  String get settingsGroupsLabel;

  /// No description provided for @settingsHeatmapLabel.
  ///
  /// In en, this message translates to:
  /// **'Activity heatmap'**
  String get settingsHeatmapLabel;

  /// No description provided for @settingsWeeklyGoalsLabel.
  ///
  /// In en, this message translates to:
  /// **'Weekly goals'**
  String get settingsWeeklyGoalsLabel;

  /// No description provided for @settingsMyReasonsLabel.
  ///
  /// In en, this message translates to:
  /// **'My reasons'**
  String get settingsMyReasonsLabel;

  /// No description provided for @settingsSavingsGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Savings goal'**
  String get settingsSavingsGoalLabel;

  /// No description provided for @settingsEmergencyContactLabel.
  ///
  /// In en, this message translates to:
  /// **'Emergency contact'**
  String get settingsEmergencyContactLabel;

  /// No description provided for @settingsChangePinLabel.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get settingsChangePinLabel;

  /// No description provided for @groupsTitle.
  ///
  /// In en, this message translates to:
  /// **'Support Groups'**
  String get groupsTitle;

  /// No description provided for @groupsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have to do this alone'**
  String get groupsSubtitle;

  /// No description provided for @groupsIntroNote.
  ///
  /// In en, this message translates to:
  /// **'Peer support is one of the strongest predictors of long-term recovery. Tap any group to visit their website.'**
  String get groupsIntroNote;

  /// No description provided for @groupsVisitWebsite.
  ///
  /// In en, this message translates to:
  /// **'Visit website'**
  String get groupsVisitWebsite;

  /// No description provided for @groupAaName.
  ///
  /// In en, this message translates to:
  /// **'Alcoholics Anonymous'**
  String get groupAaName;

  /// No description provided for @groupAaTagline.
  ///
  /// In en, this message translates to:
  /// **'AA'**
  String get groupAaTagline;

  /// No description provided for @groupAaDesc.
  ///
  /// In en, this message translates to:
  /// **'The original peer-led fellowship. Meetings worldwide — in-person and online. Based on 12 steps and mutual support. Free and anonymous.'**
  String get groupAaDesc;

  /// No description provided for @groupAaApproach.
  ///
  /// In en, this message translates to:
  /// **'12-step · Peer support · Spiritual'**
  String get groupAaApproach;

  /// No description provided for @groupAaRegions.
  ///
  /// In en, this message translates to:
  /// **'Worldwide · South Africa: aa.org.za'**
  String get groupAaRegions;

  /// No description provided for @groupSmartName.
  ///
  /// In en, this message translates to:
  /// **'SMART Recovery'**
  String get groupSmartName;

  /// No description provided for @groupSmartTagline.
  ///
  /// In en, this message translates to:
  /// **'Self-Management & Recovery Training'**
  String get groupSmartTagline;

  /// No description provided for @groupSmartDesc.
  ///
  /// In en, this message translates to:
  /// **'Science-based alternative to 12-step. Uses CBT and motivational techniques. No spiritual component required. In-person and online meetings globally.'**
  String get groupSmartDesc;

  /// No description provided for @groupSmartApproach.
  ///
  /// In en, this message translates to:
  /// **'CBT-based · Evidence-based · Non-spiritual'**
  String get groupSmartApproach;

  /// No description provided for @groupSmartRegions.
  ///
  /// In en, this message translates to:
  /// **'Worldwide · South Africa: smartrecovery.org.za'**
  String get groupSmartRegions;

  /// No description provided for @groupNaName.
  ///
  /// In en, this message translates to:
  /// **'Narcotics Anonymous'**
  String get groupNaName;

  /// No description provided for @groupNaTagline.
  ///
  /// In en, this message translates to:
  /// **'NA'**
  String get groupNaTagline;

  /// No description provided for @groupNaDesc.
  ///
  /// In en, this message translates to:
  /// **'Peer-led 12-step fellowship for people recovering from drug addiction. Meetings in most cities and online. Free and welcoming to all.'**
  String get groupNaDesc;

  /// No description provided for @groupNaApproach.
  ///
  /// In en, this message translates to:
  /// **'12-step · Peer support · Drug-focused'**
  String get groupNaApproach;

  /// No description provided for @groupNaRegions.
  ///
  /// In en, this message translates to:
  /// **'Worldwide'**
  String get groupNaRegions;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historyToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get historyToday;

  /// No description provided for @historyYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get historyYesterday;

  /// No description provided for @historySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search entries…'**
  String get historySearchHint;

  /// No description provided for @historyFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get historyFilterAll;

  /// No description provided for @historyFilterJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get historyFilterJournal;

  /// No description provided for @historyFilterGratitude.
  ///
  /// In en, this message translates to:
  /// **'Gratitude'**
  String get historyFilterGratitude;

  /// No description provided for @historyFilterCravings.
  ///
  /// In en, this message translates to:
  /// **'Cravings'**
  String get historyFilterCravings;

  /// No description provided for @historyFilterThoughts.
  ///
  /// In en, this message translates to:
  /// **'Thoughts'**
  String get historyFilterThoughts;

  /// No description provided for @historyFilterActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get historyFilterActivity;

  /// No description provided for @historyFilterSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get historyFilterSleep;

  /// No description provided for @historyFilterSlips.
  ///
  /// In en, this message translates to:
  /// **'Slips'**
  String get historyFilterSlips;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get historyEmpty;

  /// No description provided for @historyEmptySub.
  ///
  /// In en, this message translates to:
  /// **'Your logs will appear here as you use the app.'**
  String get historyEmptySub;

  /// No description provided for @historyMoodGreat.
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get historyMoodGreat;

  /// No description provided for @historyMoodGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get historyMoodGood;

  /// No description provided for @historyMoodOkay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get historyMoodOkay;

  /// No description provided for @historyMoodHard.
  ///
  /// In en, this message translates to:
  /// **'Hard day'**
  String get historyMoodHard;

  /// No description provided for @historyMoodCrisis.
  ///
  /// In en, this message translates to:
  /// **'Crisis'**
  String get historyMoodCrisis;

  /// No description provided for @puzzleTitle.
  ///
  /// In en, this message translates to:
  /// **'Calm Activities'**
  String get puzzleTitle;

  /// No description provided for @puzzleActivity0Label.
  ///
  /// In en, this message translates to:
  /// **'Slow Count'**
  String get puzzleActivity0Label;

  /// No description provided for @puzzleActivity0Desc.
  ///
  /// In en, this message translates to:
  /// **'Count backwards — it interrupts anxious thought loops.'**
  String get puzzleActivity0Desc;

  /// No description provided for @puzzleActivity0Duration.
  ///
  /// In en, this message translates to:
  /// **'2 – 5 min'**
  String get puzzleActivity0Duration;

  /// No description provided for @puzzleActivity1Label.
  ///
  /// In en, this message translates to:
  /// **'Gratitude Shuffle'**
  String get puzzleActivity1Label;

  /// No description provided for @puzzleActivity1Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap for a new gratitude prompt until one lands.'**
  String get puzzleActivity1Desc;

  /// No description provided for @puzzleActivity1Duration.
  ///
  /// In en, this message translates to:
  /// **'2 min'**
  String get puzzleActivity1Duration;

  /// No description provided for @puzzleActivity2Label.
  ///
  /// In en, this message translates to:
  /// **'Memory Match'**
  String get puzzleActivity2Label;

  /// No description provided for @puzzleActivity2Desc.
  ///
  /// In en, this message translates to:
  /// **'Flip cards to find pairs. Focusing the mind calms it.'**
  String get puzzleActivity2Desc;

  /// No description provided for @puzzleActivity2Duration.
  ///
  /// In en, this message translates to:
  /// **'5 min'**
  String get puzzleActivity2Duration;

  /// No description provided for @puzzleActivity3Label.
  ///
  /// In en, this message translates to:
  /// **'Strength Compass'**
  String get puzzleActivity3Label;

  /// No description provided for @puzzleActivity3Desc.
  ///
  /// In en, this message translates to:
  /// **'Rate your recovery strengths and see where you are today.'**
  String get puzzleActivity3Desc;

  /// No description provided for @puzzleActivity3Duration.
  ///
  /// In en, this message translates to:
  /// **'3 min'**
  String get puzzleActivity3Duration;

  /// No description provided for @puzzleActivity4Label.
  ///
  /// In en, this message translates to:
  /// **'Now Moment'**
  String get puzzleActivity4Label;

  /// No description provided for @puzzleActivity4Desc.
  ///
  /// In en, this message translates to:
  /// **'Notice · Feel · Choose — a mindful 60-second reset.'**
  String get puzzleActivity4Desc;

  /// No description provided for @puzzleActivity4Duration.
  ///
  /// In en, this message translates to:
  /// **'1 min'**
  String get puzzleActivity4Duration;

  /// No description provided for @cbtScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Thought Reframe'**
  String get cbtScreenTitle;

  /// No description provided for @cbtStepIndicator.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of 4'**
  String cbtStepIndicator(int step);

  /// No description provided for @cbtStep0Title.
  ///
  /// In en, this message translates to:
  /// **'What\'s the thought?'**
  String get cbtStep0Title;

  /// No description provided for @cbtStep0Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Write the automatic thought exactly as it appeared — raw, unfiltered. Don\'t judge it yet.'**
  String get cbtStep0Subtitle;

  /// No description provided for @cbtStep0HintText.
  ///
  /// In en, this message translates to:
  /// **'e.g. \"I\'ve already ruined everything. What\'s the point?\"'**
  String get cbtStep0HintText;

  /// No description provided for @cbtEducation.
  ///
  /// In en, this message translates to:
  /// **'CBT works by carefully examining the thoughts that drive distress — not to dismiss them, but to understand them more clearly.'**
  String get cbtEducation;

  /// No description provided for @cbtStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Spot the pattern'**
  String get cbtStep1Title;

  /// No description provided for @cbtStep1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Does this thought follow a recognisable pattern? Tap the one that fits best.'**
  String get cbtStep1Subtitle;

  /// No description provided for @cbtDistortionAllOrNothing.
  ///
  /// In en, this message translates to:
  /// **'All-or-nothing thinking'**
  String get cbtDistortionAllOrNothing;

  /// No description provided for @cbtDistortionAllOrNothingExample.
  ///
  /// In en, this message translates to:
  /// **'\"If I\'m not perfect, I\'ve completely failed.\"'**
  String get cbtDistortionAllOrNothingExample;

  /// No description provided for @cbtDistortionCatastrophising.
  ///
  /// In en, this message translates to:
  /// **'Catastrophising'**
  String get cbtDistortionCatastrophising;

  /// No description provided for @cbtDistortionCatastrophisingExample.
  ///
  /// In en, this message translates to:
  /// **'\"This will ruin everything forever.\"'**
  String get cbtDistortionCatastrophisingExample;

  /// No description provided for @cbtDistortionMindReading.
  ///
  /// In en, this message translates to:
  /// **'Mind reading'**
  String get cbtDistortionMindReading;

  /// No description provided for @cbtDistortionMindReadingExample.
  ///
  /// In en, this message translates to:
  /// **'\"Everyone must think I\'m weak.\"'**
  String get cbtDistortionMindReadingExample;

  /// No description provided for @cbtDistortionEmotionalReasoning.
  ///
  /// In en, this message translates to:
  /// **'Emotional reasoning'**
  String get cbtDistortionEmotionalReasoning;

  /// No description provided for @cbtDistortionEmotionalReasoningExample.
  ///
  /// In en, this message translates to:
  /// **'\"I feel hopeless, so the situation must be hopeless.\"'**
  String get cbtDistortionEmotionalReasoningExample;

  /// No description provided for @cbtDistortionShouldStatements.
  ///
  /// In en, this message translates to:
  /// **'Should statements'**
  String get cbtDistortionShouldStatements;

  /// No description provided for @cbtDistortionShouldStatementsExample.
  ///
  /// In en, this message translates to:
  /// **'\"I should be further along by now.\"'**
  String get cbtDistortionShouldStatementsExample;

  /// No description provided for @cbtDistortionPersonalisation.
  ///
  /// In en, this message translates to:
  /// **'Personalisation'**
  String get cbtDistortionPersonalisation;

  /// No description provided for @cbtDistortionPersonalisationExample.
  ///
  /// In en, this message translates to:
  /// **'\"This is all my fault.\"'**
  String get cbtDistortionPersonalisationExample;

  /// No description provided for @cbtDistortionOvergeneralisation.
  ///
  /// In en, this message translates to:
  /// **'Overgeneralisation'**
  String get cbtDistortionOvergeneralisation;

  /// No description provided for @cbtDistortionOvergeneralisationExample.
  ///
  /// In en, this message translates to:
  /// **'\"This always happens to me.\"'**
  String get cbtDistortionOvergeneralisationExample;

  /// No description provided for @cbtDistortionNoneOfAbove.
  ///
  /// In en, this message translates to:
  /// **'None of the above'**
  String get cbtDistortionNoneOfAbove;

  /// No description provided for @cbtDistortionNoneOfAboveExample.
  ///
  /// In en, this message translates to:
  /// **'The thought doesn\'t fit a specific pattern.'**
  String get cbtDistortionNoneOfAboveExample;

  /// No description provided for @cbtStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Test the evidence'**
  String get cbtStep2Title;

  /// No description provided for @cbtStep2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Look at the thought like a scientist. What\'s the actual evidence for and against it?'**
  String get cbtStep2Subtitle;

  /// No description provided for @cbtEvidenceForLabel.
  ///
  /// In en, this message translates to:
  /// **'Evidence FOR the thought'**
  String get cbtEvidenceForLabel;

  /// No description provided for @cbtEvidenceForHint.
  ///
  /// In en, this message translates to:
  /// **'What facts support it? (It\'s ok if there are some.)'**
  String get cbtEvidenceForHint;

  /// No description provided for @cbtEvidenceAgainstLabel.
  ///
  /// In en, this message translates to:
  /// **'Evidence AGAINST the thought'**
  String get cbtEvidenceAgainstLabel;

  /// No description provided for @cbtEvidenceAgainstHint.
  ///
  /// In en, this message translates to:
  /// **'What facts challenge it? What am I ignoring?'**
  String get cbtEvidenceAgainstHint;

  /// No description provided for @cbtStep3Title.
  ///
  /// In en, this message translates to:
  /// **'A more balanced view'**
  String get cbtStep3Title;

  /// No description provided for @cbtStep3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Based on the evidence, write a thought that\'s more realistic and kind. It doesn\'t have to be positive — just fairer.'**
  String get cbtStep3Subtitle;

  /// No description provided for @cbtReframeHintText.
  ///
  /// In en, this message translates to:
  /// **'e.g. \"I\'ve had a hard time, but I\'ve also made real progress. One difficult moment doesn\'t erase that.\"'**
  String get cbtReframeHintText;

  /// No description provided for @cbtOriginalThoughtLabel.
  ///
  /// In en, this message translates to:
  /// **'Original thought'**
  String get cbtOriginalThoughtLabel;

  /// No description provided for @cbtSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Your reframe'**
  String get cbtSummaryTitle;

  /// No description provided for @cbtPatternIdentifiedLabel.
  ///
  /// In en, this message translates to:
  /// **'Pattern identified'**
  String get cbtPatternIdentifiedLabel;

  /// No description provided for @cbtEvidenceForSummaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Evidence for'**
  String get cbtEvidenceForSummaryLabel;

  /// No description provided for @cbtEvidenceAgainstSummaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Evidence against'**
  String get cbtEvidenceAgainstSummaryLabel;

  /// No description provided for @cbtStartOverButton.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get cbtStartOverButton;

  /// No description provided for @cbtSaveToJournalButton.
  ///
  /// In en, this message translates to:
  /// **'Save to journal'**
  String get cbtSaveToJournalButton;

  /// No description provided for @cbtSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved.'**
  String get cbtSavedTitle;

  /// No description provided for @cbtSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'That took courage. Questioning a thought is one of the most powerful things you can do.'**
  String get cbtSavedMessage;

  /// No description provided for @cbtReframeAnotherButton.
  ///
  /// In en, this message translates to:
  /// **'Reframe another thought'**
  String get cbtReframeAnotherButton;

  /// No description provided for @cbtNextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get cbtNextButton;

  /// No description provided for @cbtReviewButton.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get cbtReviewButton;

  /// No description provided for @heatmapTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity Heatmap'**
  String get heatmapTitle;

  /// No description provided for @heatmapSubtitle.
  ///
  /// In en, this message translates to:
  /// **'13 weeks of your recovery journey'**
  String get heatmapSubtitle;

  /// No description provided for @heatmapActiveDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE DAYS'**
  String get heatmapActiveDaysLabel;

  /// No description provided for @heatmapActiveDaysCount.
  ///
  /// In en, this message translates to:
  /// **'{active} of {total} days'**
  String heatmapActiveDaysCount(int active, int total);

  /// No description provided for @heatmapWhatCountsLabel.
  ///
  /// In en, this message translates to:
  /// **'WHAT COUNTS'**
  String get heatmapWhatCountsLabel;

  /// No description provided for @heatmapCategoryJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get heatmapCategoryJournal;

  /// No description provided for @heatmapCategoryCraving.
  ///
  /// In en, this message translates to:
  /// **'Craving'**
  String get heatmapCategoryCraving;

  /// No description provided for @heatmapCategoryActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get heatmapCategoryActivity;

  /// No description provided for @heatmapCategorySleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get heatmapCategorySleep;

  /// No description provided for @heatmapNothingLogged.
  ///
  /// In en, this message translates to:
  /// **'Nothing was logged this day.'**
  String get heatmapNothingLogged;

  /// No description provided for @heatmapIntensityFormat.
  ///
  /// In en, this message translates to:
  /// **'Intensity {intensity}/10'**
  String heatmapIntensityFormat(int intensity);

  /// No description provided for @heatmapActivityFormat.
  ///
  /// In en, this message translates to:
  /// **'{activity} · {minutes} min'**
  String heatmapActivityFormat(String activity, int minutes);

  /// No description provided for @heatmapSleepFormat.
  ///
  /// In en, this message translates to:
  /// **'{hours}h · quality {quality}/5'**
  String heatmapSleepFormat(String hours, int quality);

  /// No description provided for @slipSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'In this moment'**
  String get slipSupportTitle;

  /// No description provided for @slipSupportTemporary.
  ///
  /// In en, this message translates to:
  /// **'This feeling is temporary.'**
  String get slipSupportTemporary;

  /// No description provided for @slipSupportCravingWaves.
  ///
  /// In en, this message translates to:
  /// **'Cravings are like waves — they rise, they peak, and they pass. Most last 15 to 20 minutes. You don\'t have to act on this.'**
  String get slipSupportCravingWaves;

  /// No description provided for @slipSupportHaltHeader.
  ///
  /// In en, this message translates to:
  /// **'HALT CHECK'**
  String get slipSupportHaltHeader;

  /// No description provided for @slipSupportHaltQuestion.
  ///
  /// In en, this message translates to:
  /// **'Strong cravings are often signals for something else. Are you feeling any of these right now?'**
  String get slipSupportHaltQuestion;

  /// No description provided for @slipSupportHaltHungry.
  ///
  /// In en, this message translates to:
  /// **'Hungry'**
  String get slipSupportHaltHungry;

  /// No description provided for @slipSupportHaltAngry.
  ///
  /// In en, this message translates to:
  /// **'Angry'**
  String get slipSupportHaltAngry;

  /// No description provided for @slipSupportHaltLonely.
  ///
  /// In en, this message translates to:
  /// **'Lonely'**
  String get slipSupportHaltLonely;

  /// No description provided for @slipSupportHaltTired.
  ///
  /// In en, this message translates to:
  /// **'Tired'**
  String get slipSupportHaltTired;

  /// No description provided for @slipSupportHaltAdviceHungry.
  ///
  /// In en, this message translates to:
  /// **'Eat something small and nourishing.'**
  String get slipSupportHaltAdviceHungry;

  /// No description provided for @slipSupportHaltAdviceAngry.
  ///
  /// In en, this message translates to:
  /// **'Write it down or take a walk to release it.'**
  String get slipSupportHaltAdviceAngry;

  /// No description provided for @slipSupportHaltAdviceLonely.
  ///
  /// In en, this message translates to:
  /// **'Text or call someone you trust.'**
  String get slipSupportHaltAdviceLonely;

  /// No description provided for @slipSupportHaltAdviceTired.
  ///
  /// In en, this message translates to:
  /// **'Rest. Even a 10-minute lie-down helps.'**
  String get slipSupportHaltAdviceTired;

  /// No description provided for @slipSupportRideItOutHeader.
  ///
  /// In en, this message translates to:
  /// **'RIDE IT OUT'**
  String get slipSupportRideItOutHeader;

  /// No description provided for @slipSupportUrgeSurfingTitle.
  ///
  /// In en, this message translates to:
  /// **'Urge surfing'**
  String get slipSupportUrgeSurfingTitle;

  /// No description provided for @slipSupportUrgeSurfingDesc.
  ///
  /// In en, this message translates to:
  /// **'Instead of fighting the craving, observe it like a wave you\'re riding. Notice where you feel it in your body. Breathe into it. Let it be there without acting on it.'**
  String get slipSupportUrgeSurfingDesc;

  /// No description provided for @slipSupportBoxBreathingTitle.
  ///
  /// In en, this message translates to:
  /// **'Box breathing'**
  String get slipSupportBoxBreathingTitle;

  /// No description provided for @slipSupportBoxBreathingInstructions.
  ///
  /// In en, this message translates to:
  /// **'In for 4 · Hold for 4 · Out for 4 · Hold for 4. Repeat until the wave softens.'**
  String get slipSupportBoxBreathingInstructions;

  /// No description provided for @slipSupportRightNowHeader.
  ///
  /// In en, this message translates to:
  /// **'RIGHT NOW'**
  String get slipSupportRightNowHeader;

  /// No description provided for @slipSupportThingsYouCanDo.
  ///
  /// In en, this message translates to:
  /// **'Things you can do this minute'**
  String get slipSupportThingsYouCanDo;

  /// No description provided for @slipSupportDistraction0.
  ///
  /// In en, this message translates to:
  /// **'Drink a glass of cold water'**
  String get slipSupportDistraction0;

  /// No description provided for @slipSupportDistraction1.
  ///
  /// In en, this message translates to:
  /// **'Step outside for two minutes'**
  String get slipSupportDistraction1;

  /// No description provided for @slipSupportDistraction2.
  ///
  /// In en, this message translates to:
  /// **'Call or text someone you trust'**
  String get slipSupportDistraction2;

  /// No description provided for @slipSupportDistraction3.
  ///
  /// In en, this message translates to:
  /// **'Put on a song that shifts your mood'**
  String get slipSupportDistraction3;

  /// No description provided for @slipSupportDistraction4.
  ///
  /// In en, this message translates to:
  /// **'Write down what you\'re feeling'**
  String get slipSupportDistraction4;

  /// No description provided for @slipSupportLogHeader.
  ///
  /// In en, this message translates to:
  /// **'LOG THIS MOMENT'**
  String get slipSupportLogHeader;

  /// No description provided for @slipSupportRateCravingTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate this craving'**
  String get slipSupportRateCravingTitle;

  /// No description provided for @slipSupportRateCravingDesc.
  ///
  /// In en, this message translates to:
  /// **'Logging it helps you see patterns. You\'re not judged — just witnessed.'**
  String get slipSupportRateCravingDesc;

  /// No description provided for @slipSupportIntensityMild.
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get slipSupportIntensityMild;

  /// No description provided for @slipSupportIntensityIntense.
  ///
  /// In en, this message translates to:
  /// **'Intense'**
  String get slipSupportIntensityIntense;

  /// No description provided for @slipSupportCravingIntensityFormat.
  ///
  /// In en, this message translates to:
  /// **'{intensity} / 10'**
  String slipSupportCravingIntensityFormat(int intensity);

  /// No description provided for @slipSupportLogCravingButton.
  ///
  /// In en, this message translates to:
  /// **'Log craving'**
  String get slipSupportLogCravingButton;

  /// No description provided for @slipSupportCravingLoggedTitle.
  ///
  /// In en, this message translates to:
  /// **'Craving logged.'**
  String get slipSupportCravingLoggedTitle;

  /// No description provided for @slipSupportCravingLoggedMessage.
  ///
  /// In en, this message translates to:
  /// **'You noticed it. You named it. That\'s the work.'**
  String get slipSupportCravingLoggedMessage;

  /// No description provided for @slipSupportNeedToTalk.
  ///
  /// In en, this message translates to:
  /// **'Need to talk to someone?'**
  String get slipSupportNeedToTalk;

  /// No description provided for @slipSupportCrisisLinesAvailable.
  ///
  /// In en, this message translates to:
  /// **'Crisis lines are available 24/7.'**
  String get slipSupportCrisisLinesAvailable;

  /// No description provided for @slipSupportViewLinesButton.
  ///
  /// In en, this message translates to:
  /// **'View lines'**
  String get slipSupportViewLinesButton;

  /// No description provided for @slipLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Slip Log'**
  String get slipLogTitle;

  /// No description provided for @slipLogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your journey, without judgment'**
  String get slipLogSubtitle;

  /// No description provided for @slipLogInfoText.
  ///
  /// In en, this message translates to:
  /// **'Slips are information, not failure. Each record here is evidence that you kept going.'**
  String get slipLogInfoText;

  /// No description provided for @slipLogEmpty.
  ///
  /// In en, this message translates to:
  /// **'No slips recorded'**
  String get slipLogEmpty;

  /// No description provided for @slipLogEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your recovery journey is continuing.'**
  String get slipLogEmptySubtitle;

  /// No description provided for @slipLogNoNote.
  ///
  /// In en, this message translates to:
  /// **'No note recorded.'**
  String get slipLogNoNote;

  /// No description provided for @slipLogStreakBadge.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day sober} other{{count} days sober}}'**
  String slipLogStreakBadge(int count);

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupTitle;

  /// No description provided for @backupExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get backupExportTitle;

  /// No description provided for @backupExportDesc.
  ///
  /// In en, this message translates to:
  /// **'Save all your journal entries, gratitude logs, slip records, and profile data. Choose an encrypted backup (.jfwbk) protected by a passphrase, or a plain JSON file.'**
  String get backupExportDesc;

  /// No description provided for @backupExportButton.
  ///
  /// In en, this message translates to:
  /// **'Export now'**
  String get backupExportButton;

  /// No description provided for @backupRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get backupRestoreTitle;

  /// No description provided for @backupRestoreDesc.
  ///
  /// In en, this message translates to:
  /// **'Pick a previously exported backup file. Your current data will be fully replaced.'**
  String get backupRestoreDesc;

  /// No description provided for @backupRestoreButton.
  ///
  /// In en, this message translates to:
  /// **'Choose backup file'**
  String get backupRestoreButton;

  /// No description provided for @backupWhatsIncludedTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s included'**
  String get backupWhatsIncludedTitle;

  /// No description provided for @backupItemProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile & sober date'**
  String get backupItemProfile;

  /// No description provided for @backupItemJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal entries'**
  String get backupItemJournal;

  /// No description provided for @backupItemGratitude.
  ///
  /// In en, this message translates to:
  /// **'Gratitude entries'**
  String get backupItemGratitude;

  /// No description provided for @backupItemSlipLog.
  ///
  /// In en, this message translates to:
  /// **'Slip log'**
  String get backupItemSlipLog;

  /// No description provided for @backupItemSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security setting'**
  String get backupItemSecurity;

  /// No description provided for @backupItemVisionBoard.
  ///
  /// In en, this message translates to:
  /// **'Vision board'**
  String get backupItemVisionBoard;

  /// No description provided for @backupItemAffirmations.
  ///
  /// In en, this message translates to:
  /// **'Custom affirmations'**
  String get backupItemAffirmations;

  /// No description provided for @backupPrivacyWarning.
  ///
  /// In en, this message translates to:
  /// **'Encrypted backups (.jfwbk) require your passphrase to open. Plain JSON backups are unencrypted — store them somewhere only you can access. Restore fully replaces the data in this app — any entries you\'ve made since the backup will be overwritten. Vision-board photos themselves aren\'t bundled into the backup file (only the references); if you restore on a new device, you may need to re-attach those images.'**
  String get backupPrivacyWarning;

  /// No description provided for @backupConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore backup?'**
  String get backupConfirmTitle;

  /// No description provided for @backupConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will replace your current data with the backup file. This cannot be undone.'**
  String get backupConfirmMessage;

  /// No description provided for @backupExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed. Please try again.'**
  String get backupExportFailed;

  /// No description provided for @backupInvalidFile.
  ///
  /// In en, this message translates to:
  /// **'This file is not a Journey Forward backup.'**
  String get backupInvalidFile;

  /// No description provided for @backupRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed — the file may be corrupted.'**
  String get backupRestoreFailed;

  /// No description provided for @backupRestoredSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup restored. Your app lock has been cleared — set a new PIN in Settings if needed. Restart to apply.'**
  String get backupRestoredSuccess;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyTitle;

  /// No description provided for @privacyAbsoluteHeadline.
  ///
  /// In en, this message translates to:
  /// **'Your privacy is absolute.'**
  String get privacyAbsoluteHeadline;

  /// No description provided for @privacyCommitment.
  ///
  /// In en, this message translates to:
  /// **'Journey Forward stores everything on your device only. No data is ever sent to any server.'**
  String get privacyCommitment;

  /// No description provided for @privacyAllDataOnDevice.
  ///
  /// In en, this message translates to:
  /// **'All data stays on your device'**
  String get privacyAllDataOnDevice;

  /// No description provided for @privacyAllDataOnDeviceBody.
  ///
  /// In en, this message translates to:
  /// **'Every piece of information you enter — your sober date, journal entries, gratitude notes, slip records, and profile — is stored locally on your device using the operating system\'s standard app storage. Nothing is transmitted to any external server, cloud service, or third party at any time.'**
  String get privacyAllDataOnDeviceBody;

  /// No description provided for @privacyNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection required'**
  String get privacyNoInternet;

  /// No description provided for @privacyNoInternetBody.
  ///
  /// In en, this message translates to:
  /// **'Journey Forward works fully offline. All fonts and assets are bundled inside the app. The app itself makes no network requests. If you tap a link to a crisis line, support group, or external resource, your device will open it in your system browser — outside of the app and subject to that site\'s own privacy policy.'**
  String get privacyNoInternetBody;

  /// No description provided for @privacyNoAnalytics.
  ///
  /// In en, this message translates to:
  /// **'No analytics or tracking'**
  String get privacyNoAnalytics;

  /// No description provided for @privacyNoAnalyticsBody.
  ///
  /// In en, this message translates to:
  /// **'There are no analytics SDKs, crash reporters, or usage trackers in this app. We do not collect any data about how you use the app, how often you open it, or what features you use.'**
  String get privacyNoAnalyticsBody;

  /// No description provided for @privacyEmergencyContacts.
  ///
  /// In en, this message translates to:
  /// **'Emergency contacts'**
  String get privacyEmergencyContacts;

  /// No description provided for @privacyEmergencyContactsBody.
  ///
  /// In en, this message translates to:
  /// **'If you add an emergency contact, their name and phone number are stored only on your device as part of your profile. This information is never shared, synced, or backed up automatically.'**
  String get privacyEmergencyContactsBody;

  /// No description provided for @privacyBackupRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get privacyBackupRestore;

  /// No description provided for @privacyBackupRestoreBody.
  ///
  /// In en, this message translates to:
  /// **'When you export a backup, a file is created and shared via your device\'s share sheet — the same way you share photos. You can choose an encrypted backup (.jfwbk, protected by your passphrase) or a plain JSON file. Journey Forward does not receive or store this file. You control where it goes.'**
  String get privacyBackupRestoreBody;

  /// No description provided for @privacyPINBiometric.
  ///
  /// In en, this message translates to:
  /// **'PIN and biometric lock'**
  String get privacyPINBiometric;

  /// No description provided for @privacyPINBiometricBody.
  ///
  /// In en, this message translates to:
  /// **'If you enable a PIN, it is salted and run through a slow key-derivation hash (PBKDF2-style), then stored in your device\'s encrypted storage — never as plaintext. Biometric unlock uses your device\'s native biometric system; Journey Forward never accesses or stores your biometric data.'**
  String get privacyPINBiometricBody;

  /// No description provided for @privacyHowToDelete.
  ///
  /// In en, this message translates to:
  /// **'How to delete your data'**
  String get privacyHowToDelete;

  /// No description provided for @privacyHowToDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'To permanently delete all your data, simply uninstall the app. All data stored by Journey Forward is removed when the app is uninstalled. There is no account to delete because there is no account — only data on your device.'**
  String get privacyHowToDeleteBody;

  /// No description provided for @privacyChildrenPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Children\'s privacy'**
  String get privacyChildrenPrivacy;

  /// No description provided for @privacyChildrenPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'Journey Forward is designed for adults aged 18 and over. The app is not directed at children and does not knowingly collect any information from anyone under the age of 18.'**
  String get privacyChildrenPrivacyBody;

  /// No description provided for @privacyPolicyUpdates.
  ///
  /// In en, this message translates to:
  /// **'Policy updates'**
  String get privacyPolicyUpdates;

  /// No description provided for @privacyPolicyUpdatesBody.
  ///
  /// In en, this message translates to:
  /// **'If this privacy policy changes, the update will be included in a new app version. Since we collect no data, changes will only reflect improvements in transparency or new features added to the app.'**
  String get privacyPolicyUpdatesBody;

  /// No description provided for @weeklySummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Care Summary'**
  String get weeklySummaryTitle;

  /// No description provided for @weeklySummarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'A private summary to share with someone you trust.'**
  String get weeklySummarySubtitle;

  /// No description provided for @weeklySummaryThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get weeklySummaryThisWeek;

  /// No description provided for @weeklySummaryLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last week'**
  String get weeklySummaryLastWeek;

  /// No description provided for @weeklySummaryCustomRange.
  ///
  /// In en, this message translates to:
  /// **'Custom range'**
  String get weeklySummaryCustomRange;

  /// No description provided for @weeklySummaryCareRecorded.
  ///
  /// In en, this message translates to:
  /// **'Care recorded'**
  String get weeklySummaryCareRecorded;

  /// No description provided for @weeklySummaryJournalEntries.
  ///
  /// In en, this message translates to:
  /// **'Journal entries'**
  String get weeklySummaryJournalEntries;

  /// No description provided for @weeklySummaryCravingSupport.
  ///
  /// In en, this message translates to:
  /// **'Craving support used'**
  String get weeklySummaryCravingSupport;

  /// No description provided for @weeklySummaryThoughtExercises.
  ///
  /// In en, this message translates to:
  /// **'Thought exercises'**
  String get weeklySummaryThoughtExercises;

  /// No description provided for @weeklySummaryMovement.
  ///
  /// In en, this message translates to:
  /// **'Movement / activity'**
  String get weeklySummaryMovement;

  /// No description provided for @weeklySummarySleepLogs.
  ///
  /// In en, this message translates to:
  /// **'Sleep logs'**
  String get weeklySummarySleepLogs;

  /// No description provided for @weeklySummaryDailyGratitude.
  ///
  /// In en, this message translates to:
  /// **'Daily gratitude'**
  String get weeklySummaryDailyGratitude;

  /// No description provided for @weeklySummaryDailyPledge.
  ///
  /// In en, this message translates to:
  /// **'Daily pledge'**
  String get weeklySummaryDailyPledge;

  /// No description provided for @weeklySummaryReflection.
  ///
  /// In en, this message translates to:
  /// **'Reflection'**
  String get weeklySummaryReflection;

  /// No description provided for @weeklySummaryPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Privacy note'**
  String get weeklySummaryPrivacyNote;

  /// No description provided for @weeklySummaryPrivacyNoteBody.
  ///
  /// In en, this message translates to:
  /// **'This summary was created on your device and shared only because you chose to share it.'**
  String get weeklySummaryPrivacyNoteBody;

  /// No description provided for @weeklySummaryShareWarning.
  ///
  /// In en, this message translates to:
  /// **'This summary may contain personal recovery information. Only share it with someone you trust.'**
  String get weeklySummaryShareWarning;

  /// No description provided for @weeklySummarySharePdf.
  ///
  /// In en, this message translates to:
  /// **'Share Summary'**
  String get weeklySummarySharePdf;

  /// No description provided for @weeklySummaryEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get weeklySummaryEdit;

  /// No description provided for @weeklySummaryPdfError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the PDF right now. Please try again.'**
  String get weeklySummaryPdfError;

  /// No description provided for @weeklySummaryNoActivity.
  ///
  /// In en, this message translates to:
  /// **'No care entries were recorded for this period. A quiet week still counts.'**
  String get weeklySummaryNoActivity;

  /// No description provided for @weeklySummaryCareDays.
  ///
  /// In en, this message translates to:
  /// **'You returned to your care practices on {count} {count, plural, =1{day} other{days}} this week.'**
  String weeklySummaryCareDays(int count);

  /// No description provided for @weeklySummaryMostUsed.
  ///
  /// In en, this message translates to:
  /// **'Most used support: {support}'**
  String weeklySummaryMostUsed(String support);

  /// No description provided for @weeklySummaryQuietWeek.
  ///
  /// In en, this message translates to:
  /// **'A quiet week of showing up still counts.'**
  String get weeklySummaryQuietWeek;

  /// No description provided for @weeklySummaryAppName.
  ///
  /// In en, this message translates to:
  /// **'Journey Forward'**
  String get weeklySummaryAppName;

  /// No description provided for @safetyModalTitle.
  ///
  /// In en, this message translates to:
  /// **'Before you begin'**
  String get safetyModalTitle;

  /// No description provided for @safetyModalBody.
  ///
  /// In en, this message translates to:
  /// **'Journey Forward is a companion for your recovery — a private place to track, reflect, and find steadying tools. It is not a medical device and does not provide medical advice, diagnosis, or treatment.'**
  String get safetyModalBody;

  /// No description provided for @safetyModalWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'If you are stopping alcohol or certain medications, withdrawal can be medically serious. Please talk to a doctor or healthcare professional about doing it safely.'**
  String get safetyModalWithdrawal;

  /// No description provided for @safetyModalCrisis.
  ///
  /// In en, this message translates to:
  /// **'And if you are ever in crisis, you deserve immediate human support — helplines are always one tap away.'**
  String get safetyModalCrisis;

  /// No description provided for @safetyModalCrisisButton.
  ///
  /// In en, this message translates to:
  /// **'View crisis helplines'**
  String get safetyModalCrisisButton;

  /// No description provided for @safetyModalDismiss.
  ///
  /// In en, this message translates to:
  /// **'I understand'**
  String get safetyModalDismiss;

  /// No description provided for @urgeTimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Ride the Wave'**
  String get urgeTimerTitle;

  /// No description provided for @urgeTimerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Urges feel overwhelming, then they pass — usually within minutes. You don\'t have to fight this one. Just stay with it.'**
  String get urgeTimerSubtitle;

  /// No description provided for @urgeTimerPhaseRising.
  ///
  /// In en, this message translates to:
  /// **'Notice it like a wave — rising, cresting, falling.'**
  String get urgeTimerPhaseRising;

  /// No description provided for @urgeTimerPhaseCresting.
  ///
  /// In en, this message translates to:
  /// **'You\'re not fighting it. You\'re outlasting it.'**
  String get urgeTimerPhaseCresting;

  /// No description provided for @urgeTimerPhaseFalling.
  ///
  /// In en, this message translates to:
  /// **'It\'s already losing strength. Stay with yourself.'**
  String get urgeTimerPhaseFalling;

  /// No description provided for @urgeTimerImSteady.
  ///
  /// In en, this message translates to:
  /// **'I\'m steady now'**
  String get urgeTimerImSteady;

  /// No description provided for @urgeTimerOpenPlan.
  ///
  /// In en, this message translates to:
  /// **'Open my plan'**
  String get urgeTimerOpenPlan;

  /// No description provided for @urgeTimerCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'The wave passed'**
  String get urgeTimerCompleteTitle;

  /// No description provided for @urgeTimerCompleteBody.
  ///
  /// In en, this message translates to:
  /// **'You stayed with it, and it passed. That\'s exactly how this is done.'**
  String get urgeTimerCompleteBody;

  /// No description provided for @urgeTimerWins.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 urge outlasted} other{{count} urges outlasted}}'**
  String urgeTimerWins(int count);

  /// No description provided for @urgeTimerDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get urgeTimerDone;

  /// No description provided for @toolkitUrgeCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Craving right now?'**
  String get toolkitUrgeCardTitle;

  /// No description provided for @toolkitUrgeCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ride the wave — most urges pass in minutes'**
  String get toolkitUrgeCardSubtitle;

  /// Settings row label and dialog title for choosing the app language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Language picker option: follow the device's language setting
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageSystem;

  /// Generic Delete button/action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// A duration in hours
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour} other{{count} hours}}'**
  String commonHours(int count);

  /// Meetings screen title
  ///
  /// In en, this message translates to:
  /// **'Meetings'**
  String get meetingsTitle;

  /// Meetings screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Plan recovery meetings, sponsor calls, and therapy sessions. Get a quiet reminder before each one.'**
  String get meetingsSubtitle;

  /// Button: create a new meeting
  ///
  /// In en, this message translates to:
  /// **'New meeting'**
  String get meetingsNew;

  /// Button: add a meeting
  ///
  /// In en, this message translates to:
  /// **'Add meeting'**
  String get meetingsAdd;

  /// Section header for future meetings (a count is appended after it)
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get meetingsUpcoming;

  /// Section header for past meetings (a count is appended after it)
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get meetingsPast;

  /// Confirm dialog title when deleting a meeting
  ///
  /// In en, this message translates to:
  /// **'Delete meeting?'**
  String get meetingsDeleteTitle;

  /// Confirm dialog body when deleting a meeting
  ///
  /// In en, this message translates to:
  /// **'This will remove \"{title}\" from your schedule.'**
  String meetingsDeleteBody(String title);

  /// Empty state title on the meetings screen
  ///
  /// In en, this message translates to:
  /// **'No meetings yet'**
  String get meetingsEmptyTitle;

  /// Empty state body on the meetings screen
  ///
  /// In en, this message translates to:
  /// **'Tap \"New meeting\" to schedule your first one. We\'ll quietly remind you before it starts.'**
  String get meetingsEmptyBody;

  /// Title of the editor sheet when editing an existing meeting
  ///
  /// In en, this message translates to:
  /// **'Edit meeting'**
  String get meetingsEdit;

  /// Meeting editor: name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get meetingsFieldName;

  /// Meeting editor: date field label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get meetingsFieldDate;

  /// Meeting editor: time field label
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get meetingsFieldTime;

  /// Meeting editor: location field label
  ///
  /// In en, this message translates to:
  /// **'Where (optional)'**
  String get meetingsFieldWhere;

  /// Meeting editor: notes field label
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get meetingsFieldNotes;

  /// Meeting editor: name field placeholder
  ///
  /// In en, this message translates to:
  /// **'e.g. AA Monday night'**
  String get meetingsNameHint;

  /// Meeting editor: location field placeholder
  ///
  /// In en, this message translates to:
  /// **'Zoom, church hall, etc.'**
  String get meetingsWhereHint;

  /// Meeting editor: notes field placeholder
  ///
  /// In en, this message translates to:
  /// **'Anything to remember'**
  String get meetingsNotesHint;

  /// Validation message when the meeting name is empty
  ///
  /// In en, this message translates to:
  /// **'Please give your meeting a name'**
  String get meetingsNameRequired;

  /// Meeting editor: reminder toggle label
  ///
  /// In en, this message translates to:
  /// **'Remind me before'**
  String get meetingsRemindToggle;

  /// Meeting editor: reminder-on subtitle; {label} is a duration like '15 min'
  ///
  /// In en, this message translates to:
  /// **'A quiet notification will fire {label} early.'**
  String meetingsRemindOn(String label);

  /// Meeting editor: reminder-off subtitle
  ///
  /// In en, this message translates to:
  /// **'No reminder will be sent.'**
  String get meetingsRemindOff;

  /// Meeting editor: label above the reminder-timing chips
  ///
  /// In en, this message translates to:
  /// **'How early?'**
  String get meetingsHowEarly;

  /// Button: save edits to an existing meeting
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get meetingsSaveChanges;

  /// Reminder chip on a meeting card; {label} is a duration like '15 min'
  ///
  /// In en, this message translates to:
  /// **'🔔 {label} before'**
  String meetingsReminderChip(String label);

  /// Button: start writing a letter to your future self
  ///
  /// In en, this message translates to:
  /// **'Write a letter'**
  String get letterWrite;

  /// Future-letters screen title
  ///
  /// In en, this message translates to:
  /// **'Letters to future you'**
  String get letterTitle;

  /// Future-letters screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Write today. Open later. Your future self gets to hear from the version of you who started this.'**
  String get letterSubtitle;

  /// Section header for letters that can be opened now (count appended after)
  ///
  /// In en, this message translates to:
  /// **'Ready to open'**
  String get letterReady;

  /// Section header for still-sealed letters (count appended after)
  ///
  /// In en, this message translates to:
  /// **'Sealed'**
  String get letterSealed;

  /// Empty state title on the future-letters screen
  ///
  /// In en, this message translates to:
  /// **'No letters yet'**
  String get letterEmptyTitle;

  /// Empty state body on the future-letters screen
  ///
  /// In en, this message translates to:
  /// **'Tap below to write your first sealed letter. Pick day 30, 90, or 365 — and meet yourself there.'**
  String get letterEmptyBody;

  /// Letter card title when still sealed; {day} is the sobriety day it unlocks
  ///
  /// In en, this message translates to:
  /// **'Sealed until day {day}'**
  String letterSealedUntil(int day);

  /// Letter card title when ready to open
  ///
  /// In en, this message translates to:
  /// **'Open me — day {day}'**
  String letterOpenMe(int day);

  /// Letter unlocks tomorrow
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get letterTomorrow;

  /// Days remaining until a sealed letter unlocks
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day to go} other{{count} days to go}}'**
  String letterDaysToGo(int count);

  /// Lowercase, appears mid-sentence after '·'; {date} is a short date like '5 Jun'
  ///
  /// In en, this message translates to:
  /// **'written {date}'**
  String letterWritten(String date);

  /// Letter card subtitle for an opened letter
  ///
  /// In en, this message translates to:
  /// **'Already read · tap to re-open'**
  String get letterAlreadyRead;

  /// Letter card subtitle for a newly-unlocked unopened letter
  ///
  /// In en, this message translates to:
  /// **'New — tap to break the seal'**
  String get letterNewSeal;

  /// Letter reader dialog header
  ///
  /// In en, this message translates to:
  /// **'Day {day} · from past you'**
  String letterFromPast(int day);

  /// Letter reader: when it was written; {date} is a full date
  ///
  /// In en, this message translates to:
  /// **'Written {date}'**
  String letterWrittenFull(String date);

  /// Validation: letter body is empty
  ///
  /// In en, this message translates to:
  /// **'Write something first'**
  String get letterWriteFirst;

  /// Title of the letter-writing sheet
  ///
  /// In en, this message translates to:
  /// **'Letter to future you'**
  String get letterWriterTitle;

  /// Writer sheet: when the letter will unlock
  ///
  /// In en, this message translates to:
  /// **'Unlocks day {day} · {date}'**
  String letterUnlocks(int day, String date);

  /// Preset chip choosing which sobriety day the letter unlocks
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String letterDayChip(int day);

  /// Chip: choose a custom unlock day
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get letterCustom;

  /// Placeholder text in the letter body field
  ///
  /// In en, this message translates to:
  /// **'Dear future me…\n\nWhat do you want to remember about who you are right now? What do you want them to know you survived?'**
  String get letterBodyHint;

  /// Button: save and seal the letter
  ///
  /// In en, this message translates to:
  /// **'Seal letter'**
  String get letterSeal;

  /// Title of the custom-day picker dialog
  ///
  /// In en, this message translates to:
  /// **'Custom day'**
  String get letterCustomDayTitle;

  /// Custom-day picker: how many days after the sober date
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day from your sober date} other{{count} days from your sober date}}'**
  String letterCustomDaysFromSober(int count);

  /// Button: confirm the custom unlock day
  ///
  /// In en, this message translates to:
  /// **'Use day {day}'**
  String letterUseDay(int day);

  /// Generic dismiss/acknowledge button
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get commonGotIt;

  /// Button: start a new CBT thought record
  ///
  /// In en, this message translates to:
  /// **'New record'**
  String get trNewRecord;

  /// Thought-record screen title
  ///
  /// In en, this message translates to:
  /// **'Thought record'**
  String get trTitle;

  /// Thought-record screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Catch a thought. Spot the distortion. Walk it through evidence. Land on something truer.'**
  String get trSubtitle;

  /// Confirm dialog: delete a thought record
  ///
  /// In en, this message translates to:
  /// **'Delete this record?'**
  String get trDeleteTitle;

  /// Empty state title, thought records
  ///
  /// In en, this message translates to:
  /// **'No records yet'**
  String get trEmptyTitle;

  /// Empty state body, thought records
  ///
  /// In en, this message translates to:
  /// **'When a thought hooks you, walk it through this. Most users find one record changes their whole week.'**
  String get trEmptyBody;

  /// Empty-state button: start a thought record
  ///
  /// In en, this message translates to:
  /// **'Start a record'**
  String get trStartRecord;

  /// Mood change badge on a record card; {value} is a signed number like +3 or -2
  ///
  /// In en, this message translates to:
  /// **'{value} mood'**
  String trMoodDelta(String value);

  /// Record card mini-label
  ///
  /// In en, this message translates to:
  /// **'Situation'**
  String get trLabelSituation;

  /// Record card mini-label
  ///
  /// In en, this message translates to:
  /// **'Automatic thought'**
  String get trLabelAutoThought;

  /// Record card mini-label
  ///
  /// In en, this message translates to:
  /// **'Reframe'**
  String get trLabelReframe;

  /// Validation: automatic thought is empty
  ///
  /// In en, this message translates to:
  /// **'Catch the thought first'**
  String get trCatchFirst;

  /// Button: save the thought record
  ///
  /// In en, this message translates to:
  /// **'Save record'**
  String get trSaveRecord;

  /// Thought-record step 1 title
  ///
  /// In en, this message translates to:
  /// **'What\'s the situation?'**
  String get trStep0Title;

  /// Thought-record step 1 subtitle
  ///
  /// In en, this message translates to:
  /// **'Where were you, who with, what was happening?'**
  String get trStep0Sub;

  /// Thought-record step 1 field hint
  ///
  /// In en, this message translates to:
  /// **'e.g. Saturday night. Home alone. Old playlist came on.'**
  String get trStep0Hint;

  /// Thought-record step 2 title
  ///
  /// In en, this message translates to:
  /// **'Catch the thought'**
  String get trStep1Title;

  /// Thought-record step 2 subtitle
  ///
  /// In en, this message translates to:
  /// **'The exact automatic thought, word-for-word.'**
  String get trStep1Sub;

  /// Thought-record step 2 field hint
  ///
  /// In en, this message translates to:
  /// **'e.g. \"I\'ll never be able to enjoy a weekend sober.\"'**
  String get trStep1Hint;

  /// Label above the before-mood slider
  ///
  /// In en, this message translates to:
  /// **'Mood right now'**
  String get trMoodNow;

  /// Label above the after-mood slider
  ///
  /// In en, this message translates to:
  /// **'Mood after writing this'**
  String get trMoodAfter;

  /// Mood slider value label
  ///
  /// In en, this message translates to:
  /// **'{value} / 10'**
  String trMoodScale(int value);

  /// Thought-record step 3 title
  ///
  /// In en, this message translates to:
  /// **'Which distortions fit?'**
  String get trStep2Title;

  /// Thought-record step 3 subtitle
  ///
  /// In en, this message translates to:
  /// **'Pick any that ring true — the label takes the sting out.'**
  String get trStep2Sub;

  /// Label before a reframe prompt in the distortion detail dialog
  ///
  /// In en, this message translates to:
  /// **'Try asking:'**
  String get trTryAsking;

  /// Thought-record step 4 title
  ///
  /// In en, this message translates to:
  /// **'Weigh the evidence'**
  String get trStep3Title;

  /// Thought-record step 4 subtitle
  ///
  /// In en, this message translates to:
  /// **'Like a courtroom — what supports the thought, what doesn\'t?'**
  String get trStep3Sub;

  /// Label above the evidence-for field
  ///
  /// In en, this message translates to:
  /// **'For the thought'**
  String get trEvidenceFor;

  /// Evidence-for field hint
  ///
  /// In en, this message translates to:
  /// **'Facts that suggest the thought is true'**
  String get trEvidenceForHint;

  /// Label above the evidence-against field
  ///
  /// In en, this message translates to:
  /// **'Against the thought'**
  String get trEvidenceAgainst;

  /// Evidence-against field hint
  ///
  /// In en, this message translates to:
  /// **'Facts that contradict or soften it'**
  String get trEvidenceAgainstHint;

  /// Thought-record step 5 title
  ///
  /// In en, this message translates to:
  /// **'Land somewhere truer'**
  String get trStep4Title;

  /// Thought-record step 5 subtitle
  ///
  /// In en, this message translates to:
  /// **'Not \"positive thinking\" — a fairer, more accurate version.'**
  String get trStep4Sub;

  /// Thought-record step 5 field hint
  ///
  /// In en, this message translates to:
  /// **'e.g. \"This is hard right now. I\'ve had sober Saturdays before. One is coming again.\"'**
  String get trStep4Hint;

  /// Cognitive distortion name
  ///
  /// In en, this message translates to:
  /// **'All-or-nothing'**
  String get trDistAllOrNothingName;

  /// Cognitive distortion description
  ///
  /// In en, this message translates to:
  /// **'Seeing things in black and white — anything less than perfect is failure.'**
  String get trDistAllOrNothingDesc;

  /// Cognitive distortion reframe prompt
  ///
  /// In en, this message translates to:
  /// **'Where on the spectrum is the truth actually sitting?'**
  String get trDistAllOrNothingPrompt;

  /// Cognitive distortion name
  ///
  /// In en, this message translates to:
  /// **'Catastrophizing'**
  String get trDistCatastrophizingName;

  /// Cognitive distortion description
  ///
  /// In en, this message translates to:
  /// **'Expecting the worst possible outcome and treating it as certain.'**
  String get trDistCatastrophizingDesc;

  /// Cognitive distortion reframe prompt
  ///
  /// In en, this message translates to:
  /// **'What is the most likely outcome, not the worst possible one?'**
  String get trDistCatastrophizingPrompt;

  /// Cognitive distortion name
  ///
  /// In en, this message translates to:
  /// **'Overgeneralization'**
  String get trDistOvergeneralizationName;

  /// Cognitive distortion description
  ///
  /// In en, this message translates to:
  /// **'One bad event becomes a never-ending pattern of defeat.'**
  String get trDistOvergeneralizationDesc;

  /// Cognitive distortion reframe prompt
  ///
  /// In en, this message translates to:
  /// **'Is this really \"always\" / \"never,\" or is it just this once?'**
  String get trDistOvergeneralizationPrompt;

  /// Cognitive distortion name
  ///
  /// In en, this message translates to:
  /// **'Mind reading'**
  String get trDistMindReadingName;

  /// Cognitive distortion description
  ///
  /// In en, this message translates to:
  /// **'Assuming you know what others are thinking about you.'**
  String get trDistMindReadingDesc;

  /// Cognitive distortion reframe prompt
  ///
  /// In en, this message translates to:
  /// **'What evidence do I actually have for that assumption?'**
  String get trDistMindReadingPrompt;

  /// Cognitive distortion name
  ///
  /// In en, this message translates to:
  /// **'\"Should\" statements'**
  String get trDistShouldName;

  /// Cognitive distortion description
  ///
  /// In en, this message translates to:
  /// **'Beating yourself up with \"should,\" \"must,\" \"ought to.\" Drives shame.'**
  String get trDistShouldDesc;

  /// Cognitive distortion reframe prompt
  ///
  /// In en, this message translates to:
  /// **'Replace \"I should\" with \"I would like to\" — does it land softer?'**
  String get trDistShouldPrompt;

  /// Cognitive distortion name
  ///
  /// In en, this message translates to:
  /// **'Emotional reasoning'**
  String get trDistEmotionalReasoningName;

  /// Cognitive distortion description
  ///
  /// In en, this message translates to:
  /// **'Believing something is true because it FEELS true.'**
  String get trDistEmotionalReasoningDesc;

  /// Cognitive distortion reframe prompt
  ///
  /// In en, this message translates to:
  /// **'Feelings are data, not verdicts. What do the facts say?'**
  String get trDistEmotionalReasoningPrompt;

  /// Cognitive distortion name
  ///
  /// In en, this message translates to:
  /// **'Personalization'**
  String get trDistPersonalizationName;

  /// Cognitive distortion description
  ///
  /// In en, this message translates to:
  /// **'Blaming yourself for things that aren\'t entirely your fault.'**
  String get trDistPersonalizationDesc;

  /// Cognitive distortion reframe prompt
  ///
  /// In en, this message translates to:
  /// **'What other factors contributed — was this all on me?'**
  String get trDistPersonalizationPrompt;

  /// Cognitive distortion name
  ///
  /// In en, this message translates to:
  /// **'Mental filter'**
  String get trDistMentalFilterName;

  /// Cognitive distortion description
  ///
  /// In en, this message translates to:
  /// **'Focusing only on the negative and screening out the positive.'**
  String get trDistMentalFilterDesc;

  /// Cognitive distortion reframe prompt
  ///
  /// In en, this message translates to:
  /// **'What good has happened today that I\'m discounting?'**
  String get trDistMentalFilterPrompt;

  /// Cognitive distortion name
  ///
  /// In en, this message translates to:
  /// **'Labeling'**
  String get trDistLabelingName;

  /// Cognitive distortion description
  ///
  /// In en, this message translates to:
  /// **'Attaching a global label to yourself: \"I\'m a failure,\" \"I\'m broken.\"'**
  String get trDistLabelingDesc;

  /// Cognitive distortion reframe prompt
  ///
  /// In en, this message translates to:
  /// **'Separate the behaviour from the person. What would I tell a friend?'**
  String get trDistLabelingPrompt;

  /// Cognitive distortion name
  ///
  /// In en, this message translates to:
  /// **'Disqualifying the positive'**
  String get trDistDisqualifyingPositiveName;

  /// Cognitive distortion description
  ///
  /// In en, this message translates to:
  /// **'Telling yourself good things \"don\'t count.\"'**
  String get trDistDisqualifyingPositiveDesc;

  /// Cognitive distortion reframe prompt
  ///
  /// In en, this message translates to:
  /// **'Why would that achievement count if a friend did it?'**
  String get trDistDisqualifyingPositivePrompt;

  /// Generic Read action button
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get commonRead;

  /// Generic Plan action button
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get commonPlan;

  /// Generic Undo action button
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get commonUndo;

  /// Home 'Today's strength' card title
  ///
  /// In en, this message translates to:
  /// **'Today\'s strength'**
  String get strengthCardTitle;

  /// Badge: how many hard days have been recorded
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hard day} other{{count} hard days}}'**
  String strengthHardDays(int count);

  /// Strength card: an unopened future letter is ready
  ///
  /// In en, this message translates to:
  /// **'A letter is waiting for you'**
  String get strengthLetterTitle;

  /// Strength card subtitle for a ready letter
  ///
  /// In en, this message translates to:
  /// **'You sealed it on day {day}. Open it.'**
  String strengthLetterSub(int day);

  /// Strength card: detected craving cluster, e.g. 'Mondays, 6-8pm'. {weekday} is a day name, {time} a time range.
  ///
  /// In en, this message translates to:
  /// **'{weekday}s, {time}'**
  String strengthPatternTitle(String weekday, String time);

  /// Strength card: craving cluster detail
  ///
  /// In en, this message translates to:
  /// **'{count} of your {total} cravings cluster here. Plan a ritual.'**
  String strengthPatternSub(int count, int total);

  /// Strength card: hard day already marked today
  ///
  /// In en, this message translates to:
  /// **'Hard day recorded'**
  String get strengthHardRecorded;

  /// Strength card: prompt to mark a hard day
  ///
  /// In en, this message translates to:
  /// **'Staying sober on a hard day?'**
  String get strengthHardAsk;

  /// Strength card subtitle when a hard day is recorded
  ///
  /// In en, this message translates to:
  /// **'Time sober counts the days. This records the hard ones.'**
  String get strengthHardRecordedSub;

  /// Strength card subtitle prompting to mark a hard day
  ///
  /// In en, this message translates to:
  /// **'Mark it — being present on a hard day is real recovery.'**
  String get strengthHardAskSub;

  /// Strength card action: mark today as a hard day
  ///
  /// In en, this message translates to:
  /// **'Mark it'**
  String get strengthMarkIt;

  /// Snackbar after marking a hard day
  ///
  /// In en, this message translates to:
  /// **'Logged. Staying present on a hard day matters.'**
  String get strengthHardLogged;

  /// Strength card link: write a first future letter
  ///
  /// In en, this message translates to:
  /// **'Write a letter to future you'**
  String get strengthWriteFirst;

  /// Strength card link: write another future letter
  ///
  /// In en, this message translates to:
  /// **'Write another letter'**
  String get strengthWriteAnother;

  /// Title of the Colour Calm mindful activity (tapping expanding circles).
  ///
  /// In en, this message translates to:
  /// **'Colour Calm'**
  String get puzzleActivity5Label;

  /// One-line description of the Colour Calm activity on the activity grid.
  ///
  /// In en, this message translates to:
  /// **'Tap the expanding circles and let your mind follow.'**
  String get puzzleActivity5Desc;

  /// Approximate duration label for the Colour Calm activity.
  ///
  /// In en, this message translates to:
  /// **'3 min'**
  String get puzzleActivity5Duration;

  /// Header title on the Calm Activities home/grid screen.
  ///
  /// In en, this message translates to:
  /// **'Mindful Activities'**
  String get puzzleHomeTitle;

  /// Subtitle under the Mindful Activities header.
  ///
  /// In en, this message translates to:
  /// **'Short exercises to calm and refocus'**
  String get puzzleHomeSubtitle;

  /// Intro text on the Slow Count activity explaining the technique. Keep the line break.
  ///
  /// In en, this message translates to:
  /// **'Counting backwards by 3 interrupts anxiety\nand brings you into the present.'**
  String get puzzleCountdownIntro;

  /// Shown in the center circle when the Slow Count countdown reaches zero.
  ///
  /// In en, this message translates to:
  /// **'Done!'**
  String get puzzleCountdownDone;

  /// Instruction shown after the Slow Count is finished; tapping restarts it.
  ///
  /// In en, this message translates to:
  /// **'Tap to restart'**
  String get puzzleCountdownRestart;

  /// Instruction during the Slow Count; each tap subtracts 3 from the number.
  ///
  /// In en, this message translates to:
  /// **'Tap to subtract 3'**
  String get puzzleCountdownSubtract;

  /// Gratitude reflection prompt (sentence starter). Keep the trailing ellipsis.
  ///
  /// In en, this message translates to:
  /// **'Something in nature I noticed today…'**
  String get puzzleGratitudePrompt0;

  /// Gratitude reflection prompt (sentence starter). Keep the trailing ellipsis.
  ///
  /// In en, this message translates to:
  /// **'A person who has shown me kindness…'**
  String get puzzleGratitudePrompt1;

  /// Gratitude reflection prompt (sentence starter). Keep the trailing ellipsis.
  ///
  /// In en, this message translates to:
  /// **'A simple pleasure I often overlook…'**
  String get puzzleGratitudePrompt2;

  /// Gratitude reflection prompt (sentence starter). Keep the trailing ellipsis.
  ///
  /// In en, this message translates to:
  /// **'Something my body does for me every day…'**
  String get puzzleGratitudePrompt3;

  /// Gratitude reflection prompt (sentence starter). Keep the trailing ellipsis.
  ///
  /// In en, this message translates to:
  /// **'A memory that still makes me smile…'**
  String get puzzleGratitudePrompt4;

  /// Gratitude reflection prompt (sentence starter). Keep the trailing ellipsis.
  ///
  /// In en, this message translates to:
  /// **'Something I\'ve learned in the past year…'**
  String get puzzleGratitudePrompt5;

  /// Gratitude reflection prompt (sentence starter). Keep the trailing ellipsis.
  ///
  /// In en, this message translates to:
  /// **'A challenge that made me stronger…'**
  String get puzzleGratitudePrompt6;

  /// Gratitude reflection prompt (sentence starter). Keep the trailing ellipsis.
  ///
  /// In en, this message translates to:
  /// **'A small comfort that I appreciate…'**
  String get puzzleGratitudePrompt7;

  /// Gratitude reflection prompt (sentence starter). Keep the trailing ellipsis.
  ///
  /// In en, this message translates to:
  /// **'Someone who believed in me when I didn\'t…'**
  String get puzzleGratitudePrompt8;

  /// Gratitude reflection prompt (sentence starter). Keep the trailing ellipsis.
  ///
  /// In en, this message translates to:
  /// **'A moment of peace I\'ve experienced…'**
  String get puzzleGratitudePrompt9;

  /// Gratitude reflection prompt (sentence starter). Keep the trailing ellipsis.
  ///
  /// In en, this message translates to:
  /// **'A skill or talent I\'m glad I have…'**
  String get puzzleGratitudePrompt10;

  /// Gratitude reflection prompt (sentence starter). Keep the trailing ellipsis.
  ///
  /// In en, this message translates to:
  /// **'Something I\'m looking forward to…'**
  String get puzzleGratitudePrompt11;

  /// Gratitude reflection prompt (sentence starter). Keep the trailing ellipsis.
  ///
  /// In en, this message translates to:
  /// **'A kindness I showed someone recently…'**
  String get puzzleGratitudePrompt12;

  /// Gratitude reflection prompt (sentence starter). Keep the trailing ellipsis.
  ///
  /// In en, this message translates to:
  /// **'Something that made me laugh recently…'**
  String get puzzleGratitudePrompt13;

  /// Gratitude reflection prompt (sentence starter). Keep the trailing ellipsis.
  ///
  /// In en, this message translates to:
  /// **'A place that brings me peace…'**
  String get puzzleGratitudePrompt14;

  /// Placeholder/hint text in the gratitude reflection text field.
  ///
  /// In en, this message translates to:
  /// **'Write your reflection here…'**
  String get puzzleReflectionHint;

  /// Button label that picks a new random gratitude prompt.
  ///
  /// In en, this message translates to:
  /// **'Shuffle prompt'**
  String get puzzleShufflePrompt;

  /// Live counter of moves taken in the Memory Match game.
  ///
  /// In en, this message translates to:
  /// **'Moves: {count}'**
  String puzzleMemoryMoves(int count);

  /// Button label to start a fresh Memory Match game.
  ///
  /// In en, this message translates to:
  /// **'New game'**
  String get puzzleNewGame;

  /// Congratulations heading shown when the Memory Match game is won.
  ///
  /// In en, this message translates to:
  /// **'Well done!'**
  String get puzzleWellDone;

  /// Shown after winning Memory Match, reporting how many moves it took.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Completed in 1 move} other{Completed in {count} moves}}'**
  String puzzleCompletedInMoves(int count);

  /// Button label to replay the Memory Match game after winning.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get puzzlePlayAgain;

  /// Intro instructions for the Strength Compass self-rating activity.
  ///
  /// In en, this message translates to:
  /// **'How strong does each feel today? This is just for you — there\'s no right answer.'**
  String get puzzleStrengthIntro;

  /// Name of a personal strength rated on a 1–5 slider in Strength Compass.
  ///
  /// In en, this message translates to:
  /// **'Courage'**
  String get puzzleStrength0;

  /// Name of a personal strength rated on a 1–5 slider in Strength Compass.
  ///
  /// In en, this message translates to:
  /// **'Patience'**
  String get puzzleStrength1;

  /// Name of a personal strength rated on a 1–5 slider in Strength Compass.
  ///
  /// In en, this message translates to:
  /// **'Honesty'**
  String get puzzleStrength2;

  /// Name of a personal strength rated on a 1–5 slider in Strength Compass.
  ///
  /// In en, this message translates to:
  /// **'Resilience'**
  String get puzzleStrength3;

  /// Name of a personal strength rated on a 1–5 slider in Strength Compass.
  ///
  /// In en, this message translates to:
  /// **'Gratitude'**
  String get puzzleStrength4;

  /// Name of a personal strength rated on a 1–5 slider in Strength Compass.
  ///
  /// In en, this message translates to:
  /// **'Hope'**
  String get puzzleStrength5;

  /// Name of a personal strength rated on a 1–5 slider in Strength Compass.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get puzzleStrength6;

  /// Name of a personal strength rated on a 1–5 slider in Strength Compass.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get puzzleStrength7;

  /// Numeric rating display next to each strength slider, e.g. 3/5.
  ///
  /// In en, this message translates to:
  /// **'{value}/5'**
  String puzzleStrengthRating(int value);

  /// Encouraging closing message at the bottom of the Strength Compass screen.
  ///
  /// In en, this message translates to:
  /// **'Wherever you rated yourself today — you showed up. That alone is strength.'**
  String get puzzleStrengthAffirmation;

  /// Step 1 title of the Now Moment grounding exercise.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get puzzleNowStep0Title;

  /// Step 1 body of the Now Moment grounding exercise.
  ///
  /// In en, this message translates to:
  /// **'Look around you right now. Name 3 things you can see without judging them. Just see them as they are.'**
  String get puzzleNowStep0Body;

  /// Step 2 title of the Now Moment grounding exercise.
  ///
  /// In en, this message translates to:
  /// **'Feel'**
  String get puzzleNowStep1Title;

  /// Step 2 body of the Now Moment grounding exercise.
  ///
  /// In en, this message translates to:
  /// **'Place both feet flat on the floor. Feel the weight of your body. Notice one sensation in your body right now — warmth, tension, breath.'**
  String get puzzleNowStep1Body;

  /// Step 3 title of the Now Moment grounding exercise.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get puzzleNowStep2Title;

  /// Step 3 body of the Now Moment grounding exercise.
  ///
  /// In en, this message translates to:
  /// **'You have arrived in this moment. What is one small, kind thing you can do for yourself in the next 10 minutes?'**
  String get puzzleNowStep2Body;

  /// Button label on the final step of the Now Moment exercise; finishes and returns.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get puzzleComplete;

  /// Instruction text under the Colour Calm header.
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere. Breathe with the circles.'**
  String get puzzleColorIntro;

  /// Ambient hint shown centered in the empty Colour Calm canvas before any taps.
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere'**
  String get puzzleColorTapAnywhere;

  /// Subject line for the OS share sheet when exporting an unencrypted (plain JSON) backup file.
  ///
  /// In en, this message translates to:
  /// **'Journey Forward Backup'**
  String get backupShareSubject;

  /// Subject line for the OS share sheet when exporting an encrypted (.jfwbk) backup file.
  ///
  /// In en, this message translates to:
  /// **'Journey Forward Backup (encrypted)'**
  String get backupShareSubjectEncrypted;

  /// Title of the dialog shown before exporting, asking whether to passphrase-protect the backup.
  ///
  /// In en, this message translates to:
  /// **'Protect your backup?'**
  String get backupProtectTitle;

  /// Title of the dialog shown when restoring an encrypted backup, prompting for the passphrase.
  ///
  /// In en, this message translates to:
  /// **'Enter backup passphrase'**
  String get backupEnterPassphraseTitle;

  /// Body text of the export passphrase dialog explaining why encryption is recommended.
  ///
  /// In en, this message translates to:
  /// **'Set a passphrase to encrypt the backup file. Without it, anyone with the file can read your journal.'**
  String get backupProtectDesc;

  /// Body text of the restore passphrase dialog, prompting for the passphrase used at export time.
  ///
  /// In en, this message translates to:
  /// **'This file is encrypted. Type the passphrase you used when exporting.'**
  String get backupEnterPassphraseDesc;

  /// Text field label for the backup passphrase input.
  ///
  /// In en, this message translates to:
  /// **'Passphrase'**
  String get backupPassphraseLabel;

  /// Text field label for the confirm-passphrase input shown only when exporting.
  ///
  /// In en, this message translates to:
  /// **'Confirm passphrase'**
  String get backupConfirmPassphraseLabel;

  /// Button that skips encryption and exports an unencrypted plain JSON backup.
  ///
  /// In en, this message translates to:
  /// **'Skip (plain JSON)'**
  String get backupSkipPlainJson;

  /// Validation error shown when the passphrase field is left blank.
  ///
  /// In en, this message translates to:
  /// **'Passphrase cannot be empty.'**
  String get backupPassphraseEmptyError;

  /// Validation error shown when the passphrase and confirm-passphrase fields differ.
  ///
  /// In en, this message translates to:
  /// **'Passphrases do not match.'**
  String get backupPassphraseMismatchError;

  /// Validation error shown when the export passphrase is shorter than 8 characters.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters — longer is safer.'**
  String get backupPassphraseTooShortError;

  /// Confirm button in the export passphrase dialog that encrypts the backup.
  ///
  /// In en, this message translates to:
  /// **'Encrypt'**
  String get backupEncryptButton;

  /// Confirm button in the restore passphrase dialog that decrypts the backup.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get backupUnlockButton;

  /// Note prefix stored with a saved CBT thought record; the user's reframed thought follows the label. Shown in the History screen notes.
  ///
  /// In en, this message translates to:
  /// **'Reframe: {reframe}'**
  String cbtReframeNotePrefix(String reframe);

  /// Expandable region group header on the Crisis Lines screen for international and United States helplines.
  ///
  /// In en, this message translates to:
  /// **'International / US'**
  String get crisisRegionInternationalUs;

  /// Expandable region group header on the Crisis Lines screen for United Kingdom and Ireland helplines.
  ///
  /// In en, this message translates to:
  /// **'UK / Ireland'**
  String get crisisRegionUkIreland;

  /// Expandable region group header on the Crisis Lines screen for South African helplines.
  ///
  /// In en, this message translates to:
  /// **'South Africa'**
  String get crisisRegionSouthAfrica;

  /// Expandable region group header on the Crisis Lines screen for Australian helplines.
  ///
  /// In en, this message translates to:
  /// **'Australia'**
  String get crisisRegionAustralia;

  /// Expandable region group header on the Crisis Lines screen for Canadian helplines.
  ///
  /// In en, this message translates to:
  /// **'Canada'**
  String get crisisRegionCanada;

  /// Expandable region group header on the Crisis Lines screen for New Zealand helplines.
  ///
  /// In en, this message translates to:
  /// **'New Zealand'**
  String get crisisRegionNewZealand;

  /// Expandable region group header on the Crisis Lines screen for European helplines.
  ///
  /// In en, this message translates to:
  /// **'Europe'**
  String get crisisRegionEurope;

  /// Availability badge on a crisis line meaning the line is open 24 hours a day, every day.
  ///
  /// In en, this message translates to:
  /// **'24/7'**
  String get crisisHours247;

  /// Availability badge on a crisis line meaning it is reachable only during normal business hours.
  ///
  /// In en, this message translates to:
  /// **'Business hours'**
  String get crisisHoursBusiness;

  /// Availability badge on a crisis line meaning it is reachable only during office hours.
  ///
  /// In en, this message translates to:
  /// **'Office hours'**
  String get crisisHoursOffice;

  /// Availability badge on a crisis line: open Monday to Friday, 9am to 8pm.
  ///
  /// In en, this message translates to:
  /// **'Mon-Fri 9am-8pm'**
  String get crisisHoursMonFri;

  /// Name of the US '988 Suicide & Crisis Lifeline' helpline. '988' is the dial code.
  ///
  /// In en, this message translates to:
  /// **'988 Suicide & Crisis Lifeline'**
  String get crisisLine988Name;

  /// One-line description of the US 988 Suicide & Crisis Lifeline.
  ///
  /// In en, this message translates to:
  /// **'US mental health & substance use crisis — call or text'**
  String get crisisLine988Desc;

  /// Name of the US SAMHSA (Substance Abuse and Mental Health Services Administration) helpline. SAMHSA is a proper name; keep it.
  ///
  /// In en, this message translates to:
  /// **'SAMHSA Helpline'**
  String get crisisLineSamhsaName;

  /// One-line description of the SAMHSA helpline.
  ///
  /// In en, this message translates to:
  /// **'Free, confidential substance abuse help'**
  String get crisisLineSamhsaDesc;

  /// Name of the US 'Crisis Text Line' SMS support service.
  ///
  /// In en, this message translates to:
  /// **'Crisis Text Line'**
  String get crisisLineCrisisTextName;

  /// Instruction shown in place of a phone number for the Crisis Text Line: text the word HOME to the shortcode 741741. Keep 'HOME' and '741741' unchanged.
  ///
  /// In en, this message translates to:
  /// **'Text HOME to 741741'**
  String get crisisLineCrisisTextNumber;

  /// One-line description of the Crisis Text Line.
  ///
  /// In en, this message translates to:
  /// **'Text-based crisis support'**
  String get crisisLineCrisisTextDesc;

  /// Name of the Alcoholics Anonymous (AA) general service line (US). 'AA' is an abbreviation for Alcoholics Anonymous.
  ///
  /// In en, this message translates to:
  /// **'AA General Service'**
  String get crisisLineAaGeneralName;

  /// One-line description of the AA General Service line.
  ///
  /// In en, this message translates to:
  /// **'Alcoholics Anonymous support'**
  String get crisisLineAaGeneralDesc;

  /// Name of the SMART Recovery support organisation (US). SMART Recovery is a proper name; keep it.
  ///
  /// In en, this message translates to:
  /// **'SMART Recovery'**
  String get crisisLineSmartUsName;

  /// One-line description of the SMART Recovery support line (US).
  ///
  /// In en, this message translates to:
  /// **'Science-based recovery support'**
  String get crisisLineSmartUsDesc;

  /// Name of the Alcoholics Anonymous helpline for the United Kingdom.
  ///
  /// In en, this message translates to:
  /// **'AA United Kingdom'**
  String get crisisLineAaUkName;

  /// One-line description of the AA United Kingdom helpline.
  ///
  /// In en, this message translates to:
  /// **'Alcoholics Anonymous UK'**
  String get crisisLineAaUkDesc;

  /// Name of the UK 'Drinkline' national alcohol helpline. Drinkline is a proper name; keep it.
  ///
  /// In en, this message translates to:
  /// **'Drinkline'**
  String get crisisLineDrinklineName;

  /// One-line description of the Drinkline helpline.
  ///
  /// In en, this message translates to:
  /// **'National alcohol helpline'**
  String get crisisLineDrinklineDesc;

  /// Name of the UK/Ireland 'Samaritans' emotional support charity. Proper name; keep it.
  ///
  /// In en, this message translates to:
  /// **'Samaritans'**
  String get crisisLineSamaritansName;

  /// One-line description of the Samaritans helpline.
  ///
  /// In en, this message translates to:
  /// **'Emotional support in crisis'**
  String get crisisLineSamaritansDesc;

  /// Name of the UK 'Frank' drug and alcohol helpline. Proper name; keep it.
  ///
  /// In en, this message translates to:
  /// **'Frank'**
  String get crisisLineFrankName;

  /// One-line description of the Frank helpline.
  ///
  /// In en, this message translates to:
  /// **'Drug and alcohol helpline'**
  String get crisisLineFrankDesc;

  /// Name of the Alcoholics Anonymous helpline for Ireland.
  ///
  /// In en, this message translates to:
  /// **'AA Ireland'**
  String get crisisLineAaIrelandName;

  /// One-line description of the AA Ireland helpline.
  ///
  /// In en, this message translates to:
  /// **'Alcoholics Anonymous Ireland'**
  String get crisisLineAaIrelandDesc;

  /// Name of the South African SADAG suicide crisis helpline.
  ///
  /// In en, this message translates to:
  /// **'Suicide Crisis Helpline'**
  String get crisisLineSadagSuicideName;

  /// One-line description of the SADAG suicide crisis line. SADAG is a proper-name acronym; keep it.
  ///
  /// In en, this message translates to:
  /// **'SADAG 24-hour suicide crisis line'**
  String get crisisLineSadagSuicideDesc;

  /// Name of the SADAG substance-abuse helpline (South Africa).
  ///
  /// In en, this message translates to:
  /// **'SADAG Substance Abuse'**
  String get crisisLineSadagSubstanceName;

  /// Full name of SADAG, shown as the description of its substance-abuse line.
  ///
  /// In en, this message translates to:
  /// **'South African Depression and Anxiety Group'**
  String get crisisLineSadagSubstanceDesc;

  /// Name of the SADAG SMS (text) support line (South Africa).
  ///
  /// In en, this message translates to:
  /// **'SADAG SMS Line'**
  String get crisisLineSadagSmsName;

  /// One-line description of the SADAG SMS support line.
  ///
  /// In en, this message translates to:
  /// **'Text-based support'**
  String get crisisLineSadagSmsDesc;

  /// Name of the Alcoholics Anonymous helpline for South Africa.
  ///
  /// In en, this message translates to:
  /// **'AA South Africa'**
  String get crisisLineAaSaName;

  /// One-line description of the AA South Africa helpline.
  ///
  /// In en, this message translates to:
  /// **'Alcoholics Anonymous SA'**
  String get crisisLineAaSaDesc;

  /// Name of the 'Lifeline South Africa' crisis counselling service.
  ///
  /// In en, this message translates to:
  /// **'Lifeline South Africa'**
  String get crisisLineLifelineSaName;

  /// One-line description of the Lifeline South Africa service.
  ///
  /// In en, this message translates to:
  /// **'Crisis counselling'**
  String get crisisLineLifelineSaDesc;

  /// Name of the South African FAMSA helpline. FAMSA is a proper-name acronym; keep it.
  ///
  /// In en, this message translates to:
  /// **'FAMSA'**
  String get crisisLineFamsaName;

  /// Full name of FAMSA, shown as its line description.
  ///
  /// In en, this message translates to:
  /// **'Family and Marriage Society of SA'**
  String get crisisLineFamsaDesc;

  /// Name of the South African SANCA helpline. SANCA is a proper-name acronym; keep it.
  ///
  /// In en, this message translates to:
  /// **'SANCA'**
  String get crisisLineSancaName;

  /// Full name of SANCA, shown as its line description.
  ///
  /// In en, this message translates to:
  /// **'SA National Council on Alcoholism'**
  String get crisisLineSancaDesc;

  /// Name of the Alcoholics Anonymous helpline for Australia.
  ///
  /// In en, this message translates to:
  /// **'AA Australia'**
  String get crisisLineAaAustraliaName;

  /// One-line description of the AA Australia helpline.
  ///
  /// In en, this message translates to:
  /// **'Alcoholics Anonymous Australia'**
  String get crisisLineAaAustraliaDesc;

  /// Name of the Australian 'Beyond Blue' mental health service. Proper name; keep it.
  ///
  /// In en, this message translates to:
  /// **'Beyond Blue'**
  String get crisisLineBeyondBlueName;

  /// One-line description of the Beyond Blue service.
  ///
  /// In en, this message translates to:
  /// **'Mental health support'**
  String get crisisLineBeyondBlueDesc;

  /// Name of the 'Lifeline Australia' crisis support service.
  ///
  /// In en, this message translates to:
  /// **'Lifeline Australia'**
  String get crisisLineLifelineAuName;

  /// One-line description of the Lifeline Australia service.
  ///
  /// In en, this message translates to:
  /// **'Crisis support'**
  String get crisisLineLifelineAuDesc;

  /// Name of the Australian 'Turning Point' alcohol and drug treatment service. Proper name; keep it.
  ///
  /// In en, this message translates to:
  /// **'Turning Point'**
  String get crisisLineTurningPointName;

  /// One-line description of the Turning Point service.
  ///
  /// In en, this message translates to:
  /// **'Alcohol and drug treatment'**
  String get crisisLineTurningPointDesc;

  /// Name of the SMART Recovery service for Australia (AU). SMART Recovery is a proper name; keep it.
  ///
  /// In en, this message translates to:
  /// **'SMART Recovery AU'**
  String get crisisLineSmartAuName;

  /// One-line description of the SMART Recovery AU service.
  ///
  /// In en, this message translates to:
  /// **'Science-based recovery'**
  String get crisisLineSmartAuDesc;

  /// Name of the 'Crisis Services Canada' national crisis line.
  ///
  /// In en, this message translates to:
  /// **'Crisis Services Canada'**
  String get crisisLineCrisisServicesCanadaName;

  /// One-line description of Crisis Services Canada.
  ///
  /// In en, this message translates to:
  /// **'National crisis line'**
  String get crisisLineCrisisServicesCanadaDesc;

  /// Name of the Canadian CAMH helpline. CAMH is a proper-name acronym; keep it.
  ///
  /// In en, this message translates to:
  /// **'CAMH'**
  String get crisisLineCamhName;

  /// Full name of CAMH, shown as its line description.
  ///
  /// In en, this message translates to:
  /// **'Centre for Addiction and Mental Health'**
  String get crisisLineCamhDesc;

  /// Name of the Alcoholics Anonymous helpline for Canada.
  ///
  /// In en, this message translates to:
  /// **'AA Canada'**
  String get crisisLineAaCanadaName;

  /// One-line description of the AA Canada helpline.
  ///
  /// In en, this message translates to:
  /// **'Alcoholics Anonymous Canada'**
  String get crisisLineAaCanadaDesc;

  /// Name of the Canadian 'ConnexOntario' helpline. Proper name; keep it.
  ///
  /// In en, this message translates to:
  /// **'ConnexOntario'**
  String get crisisLineConnexOntarioName;

  /// One-line description of the ConnexOntario helpline.
  ///
  /// In en, this message translates to:
  /// **'Mental health and addictions'**
  String get crisisLineConnexOntarioDesc;

  /// Name of the Alcoholics Anonymous helpline for New Zealand.
  ///
  /// In en, this message translates to:
  /// **'AA New Zealand'**
  String get crisisLineAaNzName;

  /// One-line description of the AA New Zealand helpline.
  ///
  /// In en, this message translates to:
  /// **'Alcoholics Anonymous NZ'**
  String get crisisLineAaNzDesc;

  /// Name of the 'Lifeline NZ' crisis support service (New Zealand).
  ///
  /// In en, this message translates to:
  /// **'Lifeline NZ'**
  String get crisisLineLifelineNzName;

  /// One-line description of the Lifeline NZ service.
  ///
  /// In en, this message translates to:
  /// **'Crisis support'**
  String get crisisLineLifelineNzDesc;

  /// Name of the New Zealand 'Need to Talk' (1737) free call-or-text support line. Proper name; keep it.
  ///
  /// In en, this message translates to:
  /// **'Need to Talk'**
  String get crisisLineNeedToTalkName;

  /// One-line description of the Need to Talk line.
  ///
  /// In en, this message translates to:
  /// **'Free call or text'**
  String get crisisLineNeedToTalkDesc;

  /// Name of the New Zealand 'Alcohol Drug Helpline'.
  ///
  /// In en, this message translates to:
  /// **'Alcohol Drug Helpline'**
  String get crisisLineAlcoholDrugNzName;

  /// One-line description of the New Zealand Alcohol Drug Helpline.
  ///
  /// In en, this message translates to:
  /// **'Alcohol and drug support'**
  String get crisisLineAlcoholDrugNzDesc;

  /// Name of the German DHS helpline; format is 'Country — Organisation'. Keep the em dash and 'DHS' acronym.
  ///
  /// In en, this message translates to:
  /// **'Germany — DHS'**
  String get crisisLineGermanyDhsName;

  /// Full German-language name of DHS (German Centre for Addiction Issues), shown as its description. Keep as-is.
  ///
  /// In en, this message translates to:
  /// **'Deutsche Hauptstelle fuer Suchtfragen'**
  String get crisisLineGermanyDhsDesc;

  /// Name of the French 'Ecoute Alcool' helpline; format is 'Country — Organisation'. Keep 'Ecoute Alcool'.
  ///
  /// In en, this message translates to:
  /// **'France — Ecoute Alcool'**
  String get crisisLineFranceEcouteName;

  /// One-line description of the France Ecoute Alcool helpline.
  ///
  /// In en, this message translates to:
  /// **'National alcohol helpline'**
  String get crisisLineFranceEcouteDesc;

  /// Name of the Dutch 'Jellinek' addiction service; format is 'Country — Organisation'. Keep 'Jellinek'.
  ///
  /// In en, this message translates to:
  /// **'Netherlands — Jellinek'**
  String get crisisLineNetherlandsJellinekName;

  /// One-line description of the Netherlands Jellinek service.
  ///
  /// In en, this message translates to:
  /// **'Addiction treatment'**
  String get crisisLineNetherlandsJellinekDesc;

  /// Name of the Spanish Alcoholics Anonymous service; format is 'Country — Organisation'. Keep 'AA Espana'.
  ///
  /// In en, this message translates to:
  /// **'Spain — AA Espana'**
  String get crisisLineSpainAaName;

  /// One-line description of the AA Spain service.
  ///
  /// In en, this message translates to:
  /// **'Alcoholics Anonymous Spain'**
  String get crisisLineSpainAaDesc;

  /// Title of the morning intention bottom-sheet when no intention has been set yet.
  ///
  /// In en, this message translates to:
  /// **'Set today\'s intention'**
  String get dailyIntentionSetTitle;

  /// Title of the intention bottom-sheet when an intention already exists and can be edited.
  ///
  /// In en, this message translates to:
  /// **'Edit today\'s intention'**
  String get dailyIntentionEditTitle;

  /// Subtitle prompting the user to write a small recovery intention for the day.
  ///
  /// In en, this message translates to:
  /// **'One small thing for your recovery today.'**
  String get dailyIntentionSubtitle;

  /// Hint text inside the daily intention text field giving an example intention.
  ///
  /// In en, this message translates to:
  /// **'e.g. Call my sponsor before noon.'**
  String get dailyIntentionHint;

  /// Button label to save the daily intention.
  ///
  /// In en, this message translates to:
  /// **'Save intention'**
  String get dailyIntentionSaveButton;

  /// Transient button label shown while a daily-practice entry is being saved.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get dailySaving;

  /// Title of the evening review pane asking the user to reflect on their intention.
  ///
  /// In en, this message translates to:
  /// **'How did today go?'**
  String get dailyReviewTitle;

  /// Label introducing the intention the user wrote earlier in the day, shown above the quoted intention text.
  ///
  /// In en, this message translates to:
  /// **'This morning you said:'**
  String get dailyReviewPrompt;

  /// Pill button: the user followed through on today's intention.
  ///
  /// In en, this message translates to:
  /// **'Did it'**
  String get dailyReviewDidIt;

  /// Pill button: the user partly followed through on today's intention.
  ///
  /// In en, this message translates to:
  /// **'Partly'**
  String get dailyReviewPartly;

  /// Pill button: the user has not yet followed through on today's intention.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get dailyReviewNotYet;

  /// Title of the weekly recovery-capital check bottom-sheet.
  ///
  /// In en, this message translates to:
  /// **'Recovery capital this week'**
  String get dailyCapitalTitle;

  /// Checklist row label: did the user connect with a supportive person this week.
  ///
  /// In en, this message translates to:
  /// **'Connected with someone supportive'**
  String get dailyCapitalConnected;

  /// Checklist row label: did the user move/exercise this week.
  ///
  /// In en, this message translates to:
  /// **'Moved my body'**
  String get dailyCapitalPhysical;

  /// Checklist row label: did the user sleep enough most nights this week.
  ///
  /// In en, this message translates to:
  /// **'Slept enough most nights'**
  String get dailyCapitalSlept;

  /// Checklist row label: did the user spend time in a place that supports recovery.
  ///
  /// In en, this message translates to:
  /// **'Spent time somewhere that helps me'**
  String get dailyCapitalHelpfulPlace;

  /// Checklist row label: did the user do something personally meaningful this week.
  ///
  /// In en, this message translates to:
  /// **'Did something meaningful to me'**
  String get dailyCapitalMeaningful;

  /// Hint text for the optional note field in the weekly recovery-capital check.
  ///
  /// In en, this message translates to:
  /// **'A note for future-you (optional)'**
  String get dailyCapitalNoteHint;

  /// Button label to save the weekly recovery-capital check.
  ///
  /// In en, this message translates to:
  /// **'Save this week'**
  String get dailyCapitalSaveButton;

  /// Button that closes the open CBT guide walkthrough. Keep the ✕ symbol.
  ///
  /// In en, this message translates to:
  /// **'✕ Close'**
  String get emergencyCloseGuide;

  /// Placeholder text for the free-text field where the user writes their reflection during a CBT guide step.
  ///
  /// In en, this message translates to:
  /// **'Your thoughts…'**
  String get cbtGuideThoughtsHint;

  /// Number of steps in a CBT guide, shown under the guide title in the list.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 step} other{{count} steps}}'**
  String cbtGuideStepCount(int count);

  /// Italic heading at the top of the My Reasons tab, framing the user's personal reasons for recovery.
  ///
  /// In en, this message translates to:
  /// **'Why I\'m doing this.'**
  String get reasonsWhyHeading;

  /// Empty-state message on the My Reasons tab when the user has not added any reasons yet.
  ///
  /// In en, this message translates to:
  /// **'Add your reasons in Settings → My Motivation. Reading them during a craving can be powerful.'**
  String get reasonsEmptyHint;

  /// Intro line above the HALT (Hungry/Angry/Lonely/Tired) self-check list.
  ///
  /// In en, this message translates to:
  /// **'Before acting on a craving, check in:'**
  String get haltCheckInPrompt;

  /// Hero heading on the Play the Tape tab. Keep the line break.
  ///
  /// In en, this message translates to:
  /// **'Pause for a moment.\nLook at what happens next.'**
  String get playTapeHeroHeading;

  /// Intro paragraph on the Play the Tape tab explaining the exercise.
  ///
  /// In en, this message translates to:
  /// **'An urge can feel urgent, but it is temporary. Before you act, walk yourself through the next few moments, tonight, and tomorrow morning.'**
  String get playTapeIntro;

  /// Title of the card showing consequences of drinking, on the Play the Tape tab.
  ///
  /// In en, this message translates to:
  /// **'If I drink now'**
  String get playTapeDrinkTitle;

  /// Title of the card showing benefits of staying sober, on the Play the Tape tab.
  ///
  /// In en, this message translates to:
  /// **'If I stay sober'**
  String get playTapeSoberTitle;

  /// Timeline row label (immediate timeframe) within a Play the Tape consequence card.
  ///
  /// In en, this message translates to:
  /// **'Right now'**
  String get playTapePhaseRightNow;

  /// Timeline row label (evening timeframe) within a Play the Tape consequence card.
  ///
  /// In en, this message translates to:
  /// **'Later tonight'**
  String get playTapePhaseTonight;

  /// Timeline row label (next-day timeframe) within a Play the Tape consequence card.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get playTapePhaseTomorrow;

  /// Bullet under 'Right now' in the 'If I drink now' card.
  ///
  /// In en, this message translates to:
  /// **'Relief may feel immediate'**
  String get playTapeDrinkNow0;

  /// Bullet under 'Right now' in the 'If I drink now' card.
  ///
  /// In en, this message translates to:
  /// **'The craving softens for a little while'**
  String get playTapeDrinkNow1;

  /// Bullet under 'Later tonight' in the 'If I drink now' card.
  ///
  /// In en, this message translates to:
  /// **'The difficult feelings often return'**
  String get playTapeDrinkTonight0;

  /// Bullet under 'Later tonight' in the 'If I drink now' card.
  ///
  /// In en, this message translates to:
  /// **'Sleep may be disrupted'**
  String get playTapeDrinkTonight1;

  /// Bullet under 'Later tonight' in the 'If I drink now' card.
  ///
  /// In en, this message translates to:
  /// **'My momentum is interrupted'**
  String get playTapeDrinkTonight2;

  /// Bullet under 'Tomorrow' in the 'If I drink now' card.
  ///
  /// In en, this message translates to:
  /// **'I may wake with regret'**
  String get playTapeDrinkTomorrow0;

  /// Bullet under 'Tomorrow' in the 'If I drink now' card.
  ///
  /// In en, this message translates to:
  /// **'The next day asks more of me'**
  String get playTapeDrinkTomorrow1;

  /// Bullet under 'Tomorrow' in the 'If I drink now' card.
  ///
  /// In en, this message translates to:
  /// **'Starting again feels harder'**
  String get playTapeDrinkTomorrow2;

  /// Bullet under 'Right now' in the 'If I stay sober' card.
  ///
  /// In en, this message translates to:
  /// **'The craving rises, then passes'**
  String get playTapeSoberNow0;

  /// Bullet under 'Right now' in the 'If I stay sober' card.
  ///
  /// In en, this message translates to:
  /// **'I give myself space instead of reacting'**
  String get playTapeSoberNow1;

  /// Bullet under 'Later tonight' in the 'If I stay sober' card.
  ///
  /// In en, this message translates to:
  /// **'I protect my peace'**
  String get playTapeSoberTonight0;

  /// Bullet under 'Later tonight' in the 'If I stay sober' card.
  ///
  /// In en, this message translates to:
  /// **'I go to bed with clarity'**
  String get playTapeSoberTonight1;

  /// Bullet under 'Later tonight' in the 'If I stay sober' card.
  ///
  /// In en, this message translates to:
  /// **'I strengthen self-trust'**
  String get playTapeSoberTonight2;

  /// Bullet under 'Tomorrow' in the 'If I stay sober' card.
  ///
  /// In en, this message translates to:
  /// **'I wake up clear-headed'**
  String get playTapeSoberTomorrow0;

  /// Bullet under 'Tomorrow' in the 'If I stay sober' card.
  ///
  /// In en, this message translates to:
  /// **'My momentum grows'**
  String get playTapeSoberTomorrow1;

  /// Bullet under 'Tomorrow' in the 'If I stay sober' card.
  ///
  /// In en, this message translates to:
  /// **'I feel proud of myself'**
  String get playTapeSoberTomorrow2;

  /// Title of the action card offering coping tools on the Play the Tape tab.
  ///
  /// In en, this message translates to:
  /// **'What would help right now?'**
  String get playTapeWhatHelpsTitle;

  /// Action button that opens the breathing exercise.
  ///
  /// In en, this message translates to:
  /// **'Breathe with me'**
  String get playTapeActionBreathe;

  /// Action button that opens the journal.
  ///
  /// In en, this message translates to:
  /// **'Open my journal'**
  String get playTapeActionJournal;

  /// Action button that opens the My Reasons tab.
  ///
  /// In en, this message translates to:
  /// **'Read my reason'**
  String get playTapeActionReason;

  /// Action button that opens the urge timer.
  ///
  /// In en, this message translates to:
  /// **'Ride the wave'**
  String get playTapeActionRideWave;

  /// Large header title at the top of the Recovery Map (activity heatmap) screen.
  ///
  /// In en, this message translates to:
  /// **'Recovery Map'**
  String get heatmapRecoveryMapTitle;

  /// Subtitle under the Recovery Map title for users who have been recording for a year or more.
  ///
  /// In en, this message translates to:
  /// **'Last 365 days · A quiet record of the days you showed up.'**
  String get heatmapSubtitleLastYear;

  /// Subtitle under the Recovery Map title for users who began recording less than a year ago.
  ///
  /// In en, this message translates to:
  /// **'Since you began · A quiet record of the days you showed up.'**
  String get heatmapSubtitleSinceStart;

  /// Filter chip on the Recovery Map showing entries from all categories.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get heatmapFilterAll;

  /// Filter chip on the Recovery Map for craving log entries (plural).
  ///
  /// In en, this message translates to:
  /// **'Cravings'**
  String get heatmapFilterCravings;

  /// Filter chip / section label on the Recovery Map for logged thought entries.
  ///
  /// In en, this message translates to:
  /// **'Thoughts'**
  String get heatmapFilterThoughts;

  /// Filter chip / section label on the Recovery Map for movement/activity entries.
  ///
  /// In en, this message translates to:
  /// **'Movement'**
  String get heatmapFilterMovement;

  /// Summary card stat label: number of days the user logged any self-care entry.
  ///
  /// In en, this message translates to:
  /// **'Care days'**
  String get heatmapStatCareDays;

  /// Summary card stat label: total number of check-in entries logged.
  ///
  /// In en, this message translates to:
  /// **'Total check-ins'**
  String get heatmapStatTotalCheckIns;

  /// Summary card stat label: the category the user logged most often.
  ///
  /// In en, this message translates to:
  /// **'Most used'**
  String get heatmapStatMostUsed;

  /// Summary card stat label: number of check-ins logged in the current calendar month.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get heatmapStatThisMonth;

  /// Tappable link that expands the Recovery Map to show all 12 months.
  ///
  /// In en, this message translates to:
  /// **'See full year'**
  String get heatmapSeeFullYear;

  /// Tappable link that collapses the Recovery Map back to the most recent two months.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get heatmapShowLess;

  /// Single-letter day-of-week initial for Monday in the calendar grid header.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get heatmapDowMon;

  /// Single-letter day-of-week initial for Tuesday in the calendar grid header.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get heatmapDowTue;

  /// Single-letter day-of-week initial for Wednesday in the calendar grid header.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get heatmapDowWed;

  /// Single-letter day-of-week initial for Thursday in the calendar grid header.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get heatmapDowThu;

  /// Single-letter day-of-week initial for Friday in the calendar grid header.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get heatmapDowFri;

  /// Single-letter day-of-week initial for Saturday in the calendar grid header.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get heatmapDowSat;

  /// Single-letter day-of-week initial for Sunday in the calendar grid header.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get heatmapDowSun;

  /// Legend label for calendar tiles dated before the user's recovery start date.
  ///
  /// In en, this message translates to:
  /// **'Before you began'**
  String get heatmapLegendBeforeBegan;

  /// Legend label for calendar tiles on days with no logged entry.
  ///
  /// In en, this message translates to:
  /// **'No entry'**
  String get heatmapLegendNoEntry;

  /// Heading in the day-detail bottom sheet when no entries exist for the tapped day.
  ///
  /// In en, this message translates to:
  /// **'No entry recorded.'**
  String get heatmapDayNoEntryTitle;

  /// Reassuring subtitle in the day-detail bottom sheet when no entries exist for that day.
  ///
  /// In en, this message translates to:
  /// **'A quiet day still counts.'**
  String get heatmapDayQuietCounts;

  /// Section header in the day-detail bottom sheet grouping logged craving entries.
  ///
  /// In en, this message translates to:
  /// **'Craving support'**
  String get heatmapSectionCravingSupport;

  /// Placeholder text shown for a journal entry in the day-detail sheet when the entry has no text body.
  ///
  /// In en, this message translates to:
  /// **'(entry)'**
  String get heatmapEntryFallback;

  /// Placeholder shown for a logged thought in the day-detail sheet when the thought has no text; {type} is the thought tone identifier (e.g. negative).
  ///
  /// In en, this message translates to:
  /// **'(thought — {type})'**
  String heatmapThoughtFallback(String type);

  /// Encouraging closing line in the day-detail bottom sheet when entries exist for that day.
  ///
  /// In en, this message translates to:
  /// **'You showed up for yourself today.'**
  String get heatmapDayShowedUp;

  /// App bar title on the personal history screen listing all logged entries.
  ///
  /// In en, this message translates to:
  /// **'My History'**
  String get historyScreenTitle;

  /// Confirmation dialog title shown before deleting a history entry.
  ///
  /// In en, this message translates to:
  /// **'Delete entry?'**
  String get historyDeleteEntryTitle;

  /// Confirmation dialog body warning that deleting an entry is permanent.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get historyDeleteEntryBody;

  /// Label under a summary stat chip showing the count of journal entries logged in the past week.
  ///
  /// In en, this message translates to:
  /// **'Journal this week'**
  String get historyStatJournalThisWeek;

  /// Label under a summary stat chip showing the count of gratitude entries logged in the past week.
  ///
  /// In en, this message translates to:
  /// **'Gratitude this week'**
  String get historyStatGratitudeThisWeek;

  /// Label under a summary stat chip showing how many days the user has been sober.
  ///
  /// In en, this message translates to:
  /// **'Days sober'**
  String get historyStatDaysSober;

  /// Compact days value, e.g. '12d' for 12 days, shown in a stat chip.
  ///
  /// In en, this message translates to:
  /// **'{days}d'**
  String historyDaysShort(int days);

  /// Type label at the top of a journal entry card in the history list.
  ///
  /// In en, this message translates to:
  /// **'Journal entry'**
  String get historyCardJournal;

  /// Hint under a long, collapsed journal entry inviting the user to tap to expand it.
  ///
  /// In en, this message translates to:
  /// **'Tap to read more'**
  String get historyTapToReadMore;

  /// Type label at the top of a gratitude entry card in the history list.
  ///
  /// In en, this message translates to:
  /// **'Gratitude'**
  String get historyCardGratitude;

  /// Type label at the top of a craving entry card in the history list.
  ///
  /// In en, this message translates to:
  /// **'Craving'**
  String get historyCardCraving;

  /// Type label at the top of a thought entry card in the history list.
  ///
  /// In en, this message translates to:
  /// **'Thought'**
  String get historyCardThought;

  /// Name of the 'run' physical activity type, shown on an activity card.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get historyActivityRun;

  /// Name of the 'cycle' physical activity type, shown on an activity card.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get historyActivityCycle;

  /// Name of the 'swim' physical activity type, shown on an activity card.
  ///
  /// In en, this message translates to:
  /// **'Swim'**
  String get historyActivitySwim;

  /// Name of the 'weights' (weight training) physical activity type, shown on an activity card.
  ///
  /// In en, this message translates to:
  /// **'Weights'**
  String get historyActivityWeights;

  /// Fallback name for an unrecognised physical activity type, shown on an activity card.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get historyActivityGeneric;

  /// Sub-label on an activity card showing distance in km and duration in minutes.
  ///
  /// In en, this message translates to:
  /// **'{distance} km · {minutes} min'**
  String historyActivityDistanceTime(String distance, int minutes);

  /// Sleep duration shown on a sleep entry card, e.g. '7.5 hours'.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours'**
  String historySleepHours(String hours);

  /// Sleep quality label on a sleep entry card, where {quality} is a word like Poor/Fair/OK/Good/Great.
  ///
  /// In en, this message translates to:
  /// **'Quality: {quality}'**
  String historySleepQuality(String quality);

  /// Badge on a slip entry card indicating the sobriety streak was reset at that point.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get historySlipReset;

  /// Line on a slip card showing how long the user was sober when the slip occurred; {streak} is a phrase like '12 days sober'.
  ///
  /// In en, this message translates to:
  /// **'Sober at the time: {streak}'**
  String historySlipSoberAtTime(String streak);

  /// Empty-state title when the unfiltered history list has no entries.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get historyEmptyAllTitle;

  /// Empty-state subtitle when the unfiltered history list has no entries.
  ///
  /// In en, this message translates to:
  /// **'Your entries will appear here'**
  String get historyEmptyAllSub;

  /// Empty-state title shown when the history list is filtered to cravings and there are none.
  ///
  /// In en, this message translates to:
  /// **'No cravings yet'**
  String get historyEmptyCravingsTitle;

  /// Empty-state subtitle prompting the user to log cravings from the home screen.
  ///
  /// In en, this message translates to:
  /// **'Log your cravings from the home screen'**
  String get historyEmptyCravingsSub;

  /// Empty-state title shown when the history list is filtered to thoughts and there are none.
  ///
  /// In en, this message translates to:
  /// **'No thoughts yet'**
  String get historyEmptyThoughtsTitle;

  /// Empty-state subtitle prompting the user to log thoughts from the home screen.
  ///
  /// In en, this message translates to:
  /// **'Log your thoughts from the home screen'**
  String get historyEmptyThoughtsSub;

  /// Empty-state title shown when the history list is filtered to exercise/activity and there is none.
  ///
  /// In en, this message translates to:
  /// **'No exercise yet'**
  String get historyEmptyActivityTitle;

  /// Empty-state subtitle prompting the user to log exercise/activity from the home screen.
  ///
  /// In en, this message translates to:
  /// **'Log your exercise from the home screen'**
  String get historyEmptyActivitySub;

  /// Empty-state title shown when the history list is filtered to sleep and there are none.
  ///
  /// In en, this message translates to:
  /// **'No sleep yet'**
  String get historyEmptySleepTitle;

  /// Empty-state subtitle prompting the user to log sleep from the home screen.
  ///
  /// In en, this message translates to:
  /// **'Log your sleep from the home screen'**
  String get historyEmptySleepSub;

  /// Empty-state title shown when the history list is filtered to journal entries and there are none.
  ///
  /// In en, this message translates to:
  /// **'No journal entries yet'**
  String get historyEmptyJournalTitle;

  /// Empty-state subtitle prompting the user to log journal entries from the home screen.
  ///
  /// In en, this message translates to:
  /// **'Log your journal entries from the home screen'**
  String get historyEmptyJournalSub;

  /// Empty-state title shown when the history list is filtered to gratitude notes and there are none.
  ///
  /// In en, this message translates to:
  /// **'No gratitude notes yet'**
  String get historyEmptyGratitudeTitle;

  /// Empty-state subtitle prompting the user to log gratitude notes from the home screen.
  ///
  /// In en, this message translates to:
  /// **'Log your gratitude notes from the home screen'**
  String get historyEmptyGratitudeSub;

  /// Empty-state title shown when the history list is filtered to slips and there are none.
  ///
  /// In en, this message translates to:
  /// **'No slips yet'**
  String get historyEmptySlipsTitle;

  /// Empty-state subtitle prompting the user to log slips from the home screen.
  ///
  /// In en, this message translates to:
  /// **'Log your slips from the home screen'**
  String get historyEmptySlipsSub;

  /// Rotating daily hero line on the home Serenity card (1 of 50).
  ///
  /// In en, this message translates to:
  /// **'Every day forward is a win.'**
  String get homeHeroQuote0;

  /// Rotating daily hero line on the home Serenity card (2 of 50).
  ///
  /// In en, this message translates to:
  /// **'Progress is built in days like this.'**
  String get homeHeroQuote1;

  /// Rotating daily hero line on the home Serenity card (3 of 50).
  ///
  /// In en, this message translates to:
  /// **'You\'re farther than yesterday.'**
  String get homeHeroQuote2;

  /// Rotating daily hero line on the home Serenity card (4 of 50).
  ///
  /// In en, this message translates to:
  /// **'Today counted. Tomorrow will too.'**
  String get homeHeroQuote3;

  /// Rotating daily hero line on the home Serenity card (5 of 50).
  ///
  /// In en, this message translates to:
  /// **'Momentum compounds. Keep going.'**
  String get homeHeroQuote4;

  /// Rotating daily hero line on the home Serenity card (6 of 50).
  ///
  /// In en, this message translates to:
  /// **'Each day is a brick in the wall.'**
  String get homeHeroQuote5;

  /// Rotating daily hero line on the home Serenity card (7 of 50).
  ///
  /// In en, this message translates to:
  /// **'You chose this. Again.'**
  String get homeHeroQuote6;

  /// Rotating daily hero line on the home Serenity card (8 of 50).
  ///
  /// In en, this message translates to:
  /// **'Sober is a verb today.'**
  String get homeHeroQuote7;

  /// Rotating daily hero line on the home Serenity card (9 of 50).
  ///
  /// In en, this message translates to:
  /// **'The streak is the strategy.'**
  String get homeHeroQuote8;

  /// Rotating daily hero line on the home Serenity card (10 of 50).
  ///
  /// In en, this message translates to:
  /// **'You earned this day.'**
  String get homeHeroQuote9;

  /// Rotating daily hero line on the home Serenity card (11 of 50).
  ///
  /// In en, this message translates to:
  /// **'Forward is the only direction.'**
  String get homeHeroQuote10;

  /// Rotating daily hero line on the home Serenity card (12 of 50).
  ///
  /// In en, this message translates to:
  /// **'Days stack into years.'**
  String get homeHeroQuote11;

  /// Rotating daily hero line on the home Serenity card (13 of 50).
  ///
  /// In en, this message translates to:
  /// **'Discipline becomes identity.'**
  String get homeHeroQuote12;

  /// Rotating daily hero line on the home Serenity card (14 of 50).
  ///
  /// In en, this message translates to:
  /// **'You\'re rewriting the story.'**
  String get homeHeroQuote13;

  /// Rotating daily hero line on the home Serenity card (15 of 50).
  ///
  /// In en, this message translates to:
  /// **'The next right choice is the whole game.'**
  String get homeHeroQuote14;

  /// Rotating daily hero line on the home Serenity card (16 of 50).
  ///
  /// In en, this message translates to:
  /// **'Show up. The rest follows.'**
  String get homeHeroQuote15;

  /// Rotating daily hero line on the home Serenity card (17 of 50).
  ///
  /// In en, this message translates to:
  /// **'Old life. New chapter.'**
  String get homeHeroQuote16;

  /// Rotating daily hero line on the home Serenity card (18 of 50).
  ///
  /// In en, this message translates to:
  /// **'You did the hard thing today.'**
  String get homeHeroQuote17;

  /// Rotating daily hero line on the home Serenity card (19 of 50).
  ///
  /// In en, this message translates to:
  /// **'Progress isn\'t loud. It\'s daily.'**
  String get homeHeroQuote18;

  /// Rotating daily hero line on the home Serenity card (20 of 50).
  ///
  /// In en, this message translates to:
  /// **'Better is built, not found.'**
  String get homeHeroQuote19;

  /// Rotating daily hero line on the home Serenity card (21 of 50).
  ///
  /// In en, this message translates to:
  /// **'Today is the receipt.'**
  String get homeHeroQuote20;

  /// Rotating daily hero line on the home Serenity card (22 of 50).
  ///
  /// In en, this message translates to:
  /// **'You moved the needle.'**
  String get homeHeroQuote21;

  /// Rotating daily hero line on the home Serenity card (23 of 50).
  ///
  /// In en, this message translates to:
  /// **'Sobriety is the work and the reward.'**
  String get homeHeroQuote22;

  /// Rotating daily hero line on the home Serenity card (24 of 50).
  ///
  /// In en, this message translates to:
  /// **'What you do daily defines you.'**
  String get homeHeroQuote23;

  /// Rotating daily hero line on the home Serenity card (25 of 50).
  ///
  /// In en, this message translates to:
  /// **'Hours add to days. Days add to years.'**
  String get homeHeroQuote24;

  /// Rotating daily hero line on the home Serenity card (26 of 50).
  ///
  /// In en, this message translates to:
  /// **'You\'re closer than you were.'**
  String get homeHeroQuote25;

  /// Rotating daily hero line on the home Serenity card (27 of 50).
  ///
  /// In en, this message translates to:
  /// **'The first hard choice is behind you.'**
  String get homeHeroQuote26;

  /// Rotating daily hero line on the home Serenity card (28 of 50).
  ///
  /// In en, this message translates to:
  /// **'You\'re not who you were yesterday.'**
  String get homeHeroQuote27;

  /// Rotating daily hero line on the home Serenity card (29 of 50).
  ///
  /// In en, this message translates to:
  /// **'Action over feeling. Always.'**
  String get homeHeroQuote28;

  /// Rotating daily hero line on the home Serenity card (30 of 50).
  ///
  /// In en, this message translates to:
  /// **'Hard now. Easier later.'**
  String get homeHeroQuote29;

  /// Rotating daily hero line on the home Serenity card (31 of 50).
  ///
  /// In en, this message translates to:
  /// **'You\'re stacking days.'**
  String get homeHeroQuote30;

  /// Rotating daily hero line on the home Serenity card (32 of 50).
  ///
  /// In en, this message translates to:
  /// **'The streak doesn\'t lie.'**
  String get homeHeroQuote31;

  /// Rotating daily hero line on the home Serenity card (33 of 50).
  ///
  /// In en, this message translates to:
  /// **'Choose forward. Choose again.'**
  String get homeHeroQuote32;

  /// Rotating daily hero line on the home Serenity card (34 of 50).
  ///
  /// In en, this message translates to:
  /// **'You showed up. That\'s everything.'**
  String get homeHeroQuote33;

  /// Rotating daily hero line on the home Serenity card (35 of 50).
  ///
  /// In en, this message translates to:
  /// **'Days like this are how it changes.'**
  String get homeHeroQuote34;

  /// Rotating daily hero line on the home Serenity card (36 of 50).
  ///
  /// In en, this message translates to:
  /// **'You\'re building something real.'**
  String get homeHeroQuote35;

  /// Rotating daily hero line on the home Serenity card (37 of 50).
  ///
  /// In en, this message translates to:
  /// **'Today is proof.'**
  String get homeHeroQuote36;

  /// Rotating daily hero line on the home Serenity card (38 of 50).
  ///
  /// In en, this message translates to:
  /// **'Discipline is freedom.'**
  String get homeHeroQuote37;

  /// Rotating daily hero line on the home Serenity card (39 of 50).
  ///
  /// In en, this message translates to:
  /// **'One choice. Then the next.'**
  String get homeHeroQuote38;

  /// Rotating daily hero line on the home Serenity card (40 of 50).
  ///
  /// In en, this message translates to:
  /// **'The reps are the result.'**
  String get homeHeroQuote39;

  /// Rotating daily hero line on the home Serenity card (41 of 50).
  ///
  /// In en, this message translates to:
  /// **'You\'re earning your future.'**
  String get homeHeroQuote40;

  /// Rotating daily hero line on the home Serenity card (42 of 50).
  ///
  /// In en, this message translates to:
  /// **'Effort compounds quietly.'**
  String get homeHeroQuote41;

  /// Rotating daily hero line on the home Serenity card (43 of 50).
  ///
  /// In en, this message translates to:
  /// **'Today\'s win is tomorrow\'s foundation.'**
  String get homeHeroQuote42;

  /// Rotating daily hero line on the home Serenity card (44 of 50).
  ///
  /// In en, this message translates to:
  /// **'Forward is enough.'**
  String get homeHeroQuote43;

  /// Rotating daily hero line on the home Serenity card (45 of 50).
  ///
  /// In en, this message translates to:
  /// **'You\'re not starting over. You\'re continuing.'**
  String get homeHeroQuote44;

  /// Rotating daily hero line on the home Serenity card (46 of 50).
  ///
  /// In en, this message translates to:
  /// **'The work is the win.'**
  String get homeHeroQuote45;

  /// Rotating daily hero line on the home Serenity card (47 of 50).
  ///
  /// In en, this message translates to:
  /// **'Strong is what you become.'**
  String get homeHeroQuote46;

  /// Rotating daily hero line on the home Serenity card (48 of 50).
  ///
  /// In en, this message translates to:
  /// **'The hard days build you.'**
  String get homeHeroQuote47;

  /// Rotating daily hero line on the home Serenity card (49 of 50).
  ///
  /// In en, this message translates to:
  /// **'Decision by decision. Day by day.'**
  String get homeHeroQuote48;

  /// Rotating daily hero line on the home Serenity card (50 of 50).
  ///
  /// In en, this message translates to:
  /// **'You\'re doing it.'**
  String get homeHeroQuote49;

  /// Short healing-timeline body text on the home recovery banner for the 12-hour milestone.
  ///
  /// In en, this message translates to:
  /// **'Your body begins adjusting. Hydration and rest are your allies right now.'**
  String get homeRecoveryBody0;

  /// Short healing-timeline body text on the home recovery banner for the 24-hour milestone.
  ///
  /// In en, this message translates to:
  /// **'Heart rate and sleep patterns may begin to shift as your body finds its rhythm.'**
  String get homeRecoveryBody1;

  /// Short healing-timeline body text on the home recovery banner for the 48-hour milestone.
  ///
  /// In en, this message translates to:
  /// **'A significant window — be patient with yourself. Seek support if anything feels unsafe.'**
  String get homeRecoveryBody2;

  /// Short healing-timeline body text on the home recovery banner for the 3-day milestone.
  ///
  /// In en, this message translates to:
  /// **'The most intense early adjustment may begin to ease. A small window of calm can emerge.'**
  String get homeRecoveryBody3;

  /// Short healing-timeline body text on the home recovery banner for the 1-week milestone.
  ///
  /// In en, this message translates to:
  /// **'Restorative sleep often begins to return. Vivid dreams can be a sign of deep repair.'**
  String get homeRecoveryBody4;

  /// Short healing-timeline body text on the home recovery banner for the 2-week milestone.
  ///
  /// In en, this message translates to:
  /// **'Physical stamina may begin to return. Concentration and memory are beginning to sharpen.'**
  String get homeRecoveryBody5;

  /// Short healing-timeline body text on the home recovery banner for the 1-month milestone.
  ///
  /// In en, this message translates to:
  /// **'Many people describe a sense of physical relief settling in around this point.'**
  String get homeRecoveryBody6;

  /// Short healing-timeline body text on the home recovery banner for the 3-month milestone.
  ///
  /// In en, this message translates to:
  /// **'Day-to-day satisfaction may slowly start to feel more accessible again.'**
  String get homeRecoveryBody7;

  /// Short healing-timeline body text on the home recovery banner for the 6-month milestone.
  ///
  /// In en, this message translates to:
  /// **'Many people notice a steadier baseline. Urges may become less frequent and easier to move through.'**
  String get homeRecoveryBody8;

  /// Short healing-timeline body text on the home recovery banner for the 1-year milestone.
  ///
  /// In en, this message translates to:
  /// **'For many people, the long-term load on sleep, energy, and mood begins to ease at this point.'**
  String get homeRecoveryBody9;

  /// Short healing-timeline body text on the home recovery banner for the 2-years-and-beyond milestone.
  ///
  /// In en, this message translates to:
  /// **'The space you have created can continue to deepen over time — one ordinary day at a time.'**
  String get homeRecoveryBody10;

  /// Recovery banner current-stage label shown before the first (12-hour) milestone is reached.
  ///
  /// In en, this message translates to:
  /// **'Just Starting'**
  String get homeRecoveryJustStarting;

  /// Recovery banner body shown before the first milestone is reached.
  ///
  /// In en, this message translates to:
  /// **'The decision you made today already matters. Be gentle with yourself.'**
  String get homeRecoveryJustStartingBody;

  /// Recovery banner relative-time phrase: the next milestone is reached right now.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get homeRecoveryNow;

  /// Recovery banner countdown: time until next milestone, in minutes.
  ///
  /// In en, this message translates to:
  /// **'in {min} min'**
  String homeRecoveryInMin(int min);

  /// Recovery banner countdown: time until next milestone, in hours.
  ///
  /// In en, this message translates to:
  /// **'in {hrs} hrs'**
  String homeRecoveryInHrs(int hrs);

  /// Recovery banner countdown: time until next milestone, in days.
  ///
  /// In en, this message translates to:
  /// **'in {days, plural, =1{1 day} other{{days} days}}'**
  String homeRecoveryInDays(int days);

  /// Uppercase header on the home recovery/healing-timeline banner card.
  ///
  /// In en, this message translates to:
  /// **'THE HEALING TIMELINE'**
  String get homeHealingTimelineHeader;

  /// Recovery banner: label of the next milestone, e.g. 'Next: 1 Week'.
  ///
  /// In en, this message translates to:
  /// **'Next: {label}'**
  String homeRecoveryNext(String label);

  /// Recovery banner line shown once every healing milestone has been reached.
  ///
  /// In en, this message translates to:
  /// **'You have reached every milestone. Remarkable.'**
  String get homeRecoveryAllMilestones;

  /// Journey timeline node label for the 180-day milestone (sentence case).
  ///
  /// In en, this message translates to:
  /// **'Six months'**
  String get homeMilestoneNode5Label;

  /// Journey timeline node label for the 365-day milestone (sentence case).
  ///
  /// In en, this message translates to:
  /// **'One year'**
  String get homeMilestoneNode6Label;

  /// Home header greeting using the user's first name.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String homeGreetingName(String name);

  /// Uppercase caption above the live counter when the quit date is in the future (counting down).
  ///
  /// In en, this message translates to:
  /// **'STARTS IN'**
  String get homeStartsIn;

  /// Uppercase caption above the live counter when counting time elapsed since the sober date.
  ///
  /// In en, this message translates to:
  /// **'TIME SOBER'**
  String get homeTimeSober;

  /// Uppercase unit label under the days digit in the live home counter.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{DAY} other{DAYS}}'**
  String homeCounterDays(int count);

  /// Uppercase unit label under the hours digit in the live home counter.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{HOUR} other{HOURS}}'**
  String homeCounterHours(int count);

  /// Uppercase unit label under the minutes digit in the live home counter.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{MINUTE} other{MINUTES}}'**
  String homeCounterMinutes(int count);

  /// Uppercase unit label under the seconds digit in the live home counter.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{SECOND} other{SECONDS}}'**
  String homeCounterSeconds(int count);

  /// Journey card timing caption for the day-0 milestone node.
  ///
  /// In en, this message translates to:
  /// **'start'**
  String get homeMilestoneTimingStart;

  /// Journey card timing caption for an unreached milestone under one year, e.g. 'Day 30'.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String homeMilestoneTimingDay(int day);

  /// Journey card timing caption for the 365-day milestone node.
  ///
  /// In en, this message translates to:
  /// **'1 year'**
  String get homeMilestoneTimingOneYear;

  /// Journey card timing caption for a multi-year milestone node, e.g. '2 yr'.
  ///
  /// In en, this message translates to:
  /// **'{years} yr'**
  String homeMilestoneTimingYears(int years);

  /// Journey card progress-bar caption shown once the final milestone is reached.
  ///
  /// In en, this message translates to:
  /// **'One year of sobriety — remarkable.'**
  String get homeJourneyProgressComplete;

  /// Journey card progress-bar caption: days remaining until the next milestone, e.g. '5 days to one week'. {label} is the lowercased next-milestone name.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}} to {label}'**
  String homeJourneyDaysTo(int count, String label);

  /// Title on the home daily-intention card.
  ///
  /// In en, this message translates to:
  /// **'Today\'s intention'**
  String get homeIntentionTitle;

  /// Subtitle inviting the user to set today's intention on the home intention card.
  ///
  /// In en, this message translates to:
  /// **'One small thing for your recovery today.'**
  String get homeIntentionPrompt;

  /// Evening-review prompt label on the home intention card after 4pm.
  ///
  /// In en, this message translates to:
  /// **'How did today go?'**
  String get homeIntentionReviewPrompt;

  /// Home intention card outcome blurb when the user marked the intention as done. Keep the leading checkmark.
  ///
  /// In en, this message translates to:
  /// **'✓ You did it.'**
  String get homeIntentionOutcomeDid;

  /// Home intention card outcome blurb when partly done. Keep the leading tilde.
  ///
  /// In en, this message translates to:
  /// **'~ Partly — that still counts.'**
  String get homeIntentionOutcomePartly;

  /// Home intention card outcome blurb when not yet done. Keep the leading ellipsis.
  ///
  /// In en, this message translates to:
  /// **'… Not yet — tomorrow is a new day.'**
  String get homeIntentionOutcomeNotYet;

  /// Section label above the HALT (hungry/angry/lonely/tired) chips in the log-a-craving sheet.
  ///
  /// In en, this message translates to:
  /// **'Right now, are you any of these?'**
  String get homeCravingHaltQuestion;

  /// Helper caption under the HALT chips in the log-a-craving sheet. H.A.L.T. is an acronym.
  ///
  /// In en, this message translates to:
  /// **'Naming it slows the wave down — H.A.L.T.'**
  String get homeCravingHaltBlurb;

  /// Section label above the outcome pills in the log-a-craving sheet.
  ///
  /// In en, this message translates to:
  /// **'How did it turn out?'**
  String get homeCravingOutcomeQuestion;

  /// Outcome pill in the log-a-craving sheet: the user stayed sober.
  ///
  /// In en, this message translates to:
  /// **'Stayed sober'**
  String get homeCravingOutcomeStayedSober;

  /// Outcome pill in the log-a-craving sheet: outcome was unclear.
  ///
  /// In en, this message translates to:
  /// **'Unclear'**
  String get homeCravingOutcomeUnclear;

  /// Outcome pill in the log-a-craving sheet: the user slipped.
  ///
  /// In en, this message translates to:
  /// **'Slipped'**
  String get homeCravingOutcomeSlipped;

  /// Clause inserted into the 'last time' craving hint when the prior similar craving ended in staying sober.
  ///
  /// In en, this message translates to:
  /// **'and you stayed sober'**
  String get homeLastTimeOutcomeSober;

  /// Clause inserted into the 'last time' craving hint when the prior similar craving ended in a slip.
  ///
  /// In en, this message translates to:
  /// **'and you slipped — useful to know'**
  String get homeLastTimeOutcomeSlipped;

  /// Parenthetical inserted into the 'last time' craving hint giving how long the prior craving lasted. Keep the leading space.
  ///
  /// In en, this message translates to:
  /// **' (passed in {minutes} min)'**
  String homeLastTimeDuration(int minutes);

  /// Personal 'last time' hint in the craving sheet. {response} is a lowercased response verb phrase, {duration} is an optional parenthetical, {outcome} is an optional outcome clause.
  ///
  /// In en, this message translates to:
  /// **'Last time around this level you {response}{duration} {outcome}.'**
  String homeLastTimeBlurb(String response, String duration, String outcome);

  /// Snackbar confirmation after saving a thought log.
  ///
  /// In en, this message translates to:
  /// **'Thought saved privately'**
  String get homeThoughtSavedPrivately;

  /// Snackbar shown when saving a thought log fails.
  ///
  /// In en, this message translates to:
  /// **'Could not save: {error}'**
  String homeThoughtSaveError(String error);

  /// Text field hint in the log-a-thought sheet (optional variant).
  ///
  /// In en, this message translates to:
  /// **'Write the thought in your own words (optional).'**
  String get homeThoughtWriteHintOptional;

  /// Activity-type chip label in the log-activity sheet.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get homeActivityTypeRun;

  /// Activity-type chip label in the log-activity sheet.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get homeActivityTypeCycle;

  /// Activity-type chip label in the log-activity sheet.
  ///
  /// In en, this message translates to:
  /// **'Swim'**
  String get homeActivityTypeSwim;

  /// Activity-type chip label in the log-activity sheet.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get homeActivityTypeGym;

  /// Section label for the time + distance inputs in the log-activity sheet (distance-based activities).
  ///
  /// In en, this message translates to:
  /// **'Time & distance'**
  String get homeActivityTimeDistance;

  /// Field label above the minutes input for distance-based activities in the log-activity sheet.
  ///
  /// In en, this message translates to:
  /// **'Duration (min)'**
  String get homeActivityDurationMin;

  /// Field label above the distance input in the log-activity sheet; {unit} is km or miles.
  ///
  /// In en, this message translates to:
  /// **'Distance ({unit})'**
  String homeActivityDistanceLabel(String unit);

  /// Abbreviation for minutes used as a text-field suffix in the log-activity sheet.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get homeUnitMin;

  /// Metric distance unit abbreviation (kilometres).
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get homeUnitKm;

  /// Imperial distance unit (miles).
  ///
  /// In en, this message translates to:
  /// **'miles'**
  String get homeUnitMiles;

  /// Section label above the sleep-factor chips in the log-sleep sheet (short variant).
  ///
  /// In en, this message translates to:
  /// **'What affected sleep?'**
  String get homeSleepFactorsShortQuestion;

  /// Notes field hint in the log-sleep sheet.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional) - e.g., woke once, settled again quickly.'**
  String get homeSleepNotesHintShort;

  /// Subtitle under each summary stat chip indicating the metric covers the last 7 days.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get insightsStatSub7Days;

  /// Label for the summary stat chip showing average hours of sleep over 7 days.
  ///
  /// In en, this message translates to:
  /// **'Avg Sleep'**
  String get insightsStatAvgSleep;

  /// Label for the summary stat chip showing the number of days with logged activity.
  ///
  /// In en, this message translates to:
  /// **'Active Days'**
  String get insightsStatActiveDays;

  /// Label for the summary stat chip showing the number of days with a journal entry.
  ///
  /// In en, this message translates to:
  /// **'Journal Days'**
  String get insightsStatJournalDays;

  /// Title of the mood trend chart card, covering the last 7 days.
  ///
  /// In en, this message translates to:
  /// **'Mood — 7 days'**
  String get insightsChartMood;

  /// Title of the cravings trend chart card, covering the last 7 days.
  ///
  /// In en, this message translates to:
  /// **'Cravings — 7 days'**
  String get insightsChartCravings;

  /// Title of the sleep chart card; values shown are hours per day over 7 days.
  ///
  /// In en, this message translates to:
  /// **'Sleep — 7 days (hours)'**
  String get insightsChartSleep;

  /// Title of the exercise chart card; values shown are minutes per day over 7 days.
  ///
  /// In en, this message translates to:
  /// **'Exercise — 7 days (minutes)'**
  String get insightsChartExercise;

  /// Empty-state message shown in the mood chart when no journal entries exist.
  ///
  /// In en, this message translates to:
  /// **'No journal entries yet'**
  String get insightsEmptyMood;

  /// Empty-state message shown in the cravings chart when no cravings are logged.
  ///
  /// In en, this message translates to:
  /// **'No cravings logged'**
  String get insightsEmptyCravings;

  /// Empty-state message shown in the sleep chart when no sleep is logged.
  ///
  /// In en, this message translates to:
  /// **'No sleep logged'**
  String get insightsEmptySleep;

  /// Empty-state message shown in the exercise chart when no activity is logged.
  ///
  /// In en, this message translates to:
  /// **'No activity logged'**
  String get insightsEmptyActivity;

  /// Mood-chart legend label for a hard/low mood day (short form, distinct from 'Hard day').
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get insightsMoodHard;

  /// Title of the thought-patterns card showing positive/neutral/challenging thought breakdown over 7 days.
  ///
  /// In en, this message translates to:
  /// **'Thought Patterns — 7 days'**
  String get insightsThoughtPatterns;

  /// Empty-state message in the thought-patterns card when no thoughts are logged.
  ///
  /// In en, this message translates to:
  /// **'No thoughts logged'**
  String get insightsEmptyThoughts;

  /// Label for the challenging (negative) category row in the thought-patterns card.
  ///
  /// In en, this message translates to:
  /// **'Challenging'**
  String get insightsThoughtChallenging;

  /// Single-letter abbreviation for Monday, shown on chart x-axes.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get insightsWeekdayMon;

  /// Single-letter abbreviation for Tuesday, shown on chart x-axes.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get insightsWeekdayTue;

  /// Single-letter abbreviation for Wednesday, shown on chart x-axes.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get insightsWeekdayWed;

  /// Single-letter abbreviation for Thursday, shown on chart x-axes.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get insightsWeekdayThu;

  /// Single-letter abbreviation for Friday, shown on chart x-axes.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get insightsWeekdayFri;

  /// Single-letter abbreviation for Saturday, shown on chart x-axes.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get insightsWeekdaySat;

  /// Single-letter abbreviation for Sunday, shown on chart x-axes.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get insightsWeekdaySun;

  /// Tooltip on the lock icon button when the journal entry is currently locked; tapping unlocks it.
  ///
  /// In en, this message translates to:
  /// **'Unlock entry'**
  String get journalDetailUnlockEntry;

  /// Tooltip on the lock icon button when the journal entry is currently unlocked; tapping locks it.
  ///
  /// In en, this message translates to:
  /// **'Lock entry'**
  String get journalDetailLockEntry;

  /// Reason shown in the biometric / PIN re-authentication prompt when the user unlocks a locked journal entry.
  ///
  /// In en, this message translates to:
  /// **'Unlock this entry'**
  String get journalDetailUnlockThisEntry;

  /// Reason shown in the biometric / PIN re-authentication prompt when the user opens a locked older 'on this day' echo entry.
  ///
  /// In en, this message translates to:
  /// **'Open this entry'**
  String get journalDetailOpenThisEntry;

  /// Tooltip on the edit icon button in the journal entry detail screen app bar.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get journalDetailEdit;

  /// Italic stamp showing when a journal entry was last edited, e.g. 'Edited 5m ago'. {time} is an already-formatted relative time string.
  ///
  /// In en, this message translates to:
  /// **'Edited {time}'**
  String journalDetailEdited(String time);

  /// Placeholder card shown when a journal entry has a mood but no written text, inviting the user to add words.
  ///
  /// In en, this message translates to:
  /// **'A quick mood check-in. Tap edit to add words when you\'re ready.'**
  String get journalDetailQuickMoodInvite;

  /// Section header above older journal entries from prior years that share the same calendar day.
  ///
  /// In en, this message translates to:
  /// **'On this day, earlier'**
  String get journalDetailOnThisDayEarlier;

  /// Title of the confirmation dialog shown before deleting a journal entry.
  ///
  /// In en, this message translates to:
  /// **'Delete this entry?'**
  String get journalDetailDeleteTitle;

  /// Body text of the confirmation dialog shown before deleting a journal entry.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get journalDetailDeleteBody;

  /// Button that cancels deletion and keeps the journal entry, in the delete confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get journalDetailKeep;

  /// Compact relative time for under an hour ago, e.g. '5m ago'. Used in the 'Edited ...' stamp.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String journalDetailMinutesAgo(int count);

  /// Compact relative time for under a day ago, e.g. '3h ago'. Used in the 'Edited ...' stamp.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String journalDetailHoursAgo(int count);

  /// Compact relative time for under a week ago, e.g. '4d ago'. Used in the 'Edited ...' stamp.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String journalDetailDaysAgo(int count);

  /// Label on an older 'on this day' echo card indicating how many years ago that entry was written.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 year ago} other{{count} years ago}}'**
  String journalDetailYearsAgo(int count);

  /// Preview text shown in place of the body on a locked older 'on this day' echo card.
  ///
  /// In en, this message translates to:
  /// **'Locked entry · tap to unlock'**
  String get journalDetailLockedEntryTapToUnlock;

  /// Preview text shown on an older 'on this day' echo card when that entry recorded a mood but no written text.
  ///
  /// In en, this message translates to:
  /// **'Mood check-in (no words)'**
  String get journalDetailMoodCheckInNoWords;

  /// Snackbar shown after the user logs a quick mood with no body text yet.
  ///
  /// In en, this message translates to:
  /// **'Mood logged. Tap the card to add words.'**
  String get journalMoodLoggedSnack;

  /// Reason shown in the biometric/PIN re-auth prompt when opening a locked journal entry.
  ///
  /// In en, this message translates to:
  /// **'View this entry'**
  String get journalReauthViewEntry;

  /// Title of the empty state when no journal entries match the active filter/search.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches'**
  String get journalFilterEmptyTitle;

  /// Subtitle of the journal filter empty state.
  ///
  /// In en, this message translates to:
  /// **'Try a different filter or clear the search.'**
  String get journalFilterEmptySubtitle;

  /// Header of the bottom sheet that lets the user choose what kind of journal entry to write.
  ///
  /// In en, this message translates to:
  /// **'New entry'**
  String get journalNewEntryTitle;

  /// Subtitle under the New entry chooser header.
  ///
  /// In en, this message translates to:
  /// **'Pick how you want to write today.'**
  String get journalNewEntrySubtitle;

  /// Title of the option that opens a blank journal entry.
  ///
  /// In en, this message translates to:
  /// **'Plain entry'**
  String get journalPlainEntryTitle;

  /// Description of the plain journal entry option.
  ///
  /// In en, this message translates to:
  /// **'A blank page for your thoughts. Mood, tags, optional prompt.'**
  String get journalPlainEntrySubtitle;

  /// Title of the option that opens the guided daily-reflection template.
  ///
  /// In en, this message translates to:
  /// **'Daily reflection'**
  String get journalDailyReflectionTitle;

  /// Description of the guided daily reflection option.
  ///
  /// In en, this message translates to:
  /// **'A guided page: gratitude, anchors, wins, cravings, intention.'**
  String get journalDailyReflectionSubtitle;

  /// Small 'New' badge on the daily reflection option.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get journalBadgeNew;

  /// Heading of the support sheet shown after a fresh entry with a 'crisis' mood.
  ///
  /// In en, this message translates to:
  /// **'I see you. Want a hand?'**
  String get journalCrisisTitleCrisis;

  /// Heading of the support sheet shown after a fresh entry with a 'hard' mood.
  ///
  /// In en, this message translates to:
  /// **'That sounds heavy.'**
  String get journalCrisisTitleHard;

  /// Body of the support sheet for a crisis-mood entry.
  ///
  /// In en, this message translates to:
  /// **'Saving your entry helped. A short calm exercise can take it from here.'**
  String get journalCrisisBodyCrisis;

  /// Body of the support sheet for a hard-mood entry.
  ///
  /// In en, this message translates to:
  /// **'You wrote it down — that already counts. A 60-second thought record can help if you want it.'**
  String get journalCrisisBodyHard;

  /// Action label routing the user to the calm/emergency toolkit.
  ///
  /// In en, this message translates to:
  /// **'Open the calm room'**
  String get journalCrisisCalmRoomLabel;

  /// Detail line under the 'Open the calm room' action.
  ///
  /// In en, this message translates to:
  /// **'Breath work, grounding, and one safe action.'**
  String get journalCrisisCalmRoomDetail;

  /// Action label routing the user to the CBT thought-record tool.
  ///
  /// In en, this message translates to:
  /// **'Try a thought record'**
  String get journalCrisisThoughtRecordLabel;

  /// Detail line under the 'Try a thought record' action.
  ///
  /// In en, this message translates to:
  /// **'Name the thought, weigh the evidence, reframe it.'**
  String get journalCrisisThoughtRecordDetail;

  /// Dismiss button on the post-entry crisis support sheet.
  ///
  /// In en, this message translates to:
  /// **'I\'m okay for now'**
  String get journalCrisisDismiss;

  /// Section header grouping journal entries from the last 7 days.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get journalBucketThisWeek;

  /// Section header grouping journal entries from 8-14 days ago.
  ///
  /// In en, this message translates to:
  /// **'Last week'**
  String get journalBucketLastWeek;

  /// Section header grouping older journal entries within the current month.
  ///
  /// In en, this message translates to:
  /// **'Earlier this month'**
  String get journalBucketEarlierThisMonth;

  /// Journal writing streak label shown in the diary header.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day writing} other{{count} day writing streak}}'**
  String journalWritingStreak(int count);

  /// Prompt on the one-tap quick-mood pill.
  ///
  /// In en, this message translates to:
  /// **'How are you right now?'**
  String get journalQuickMoodPrompt;

  /// Label on the 'on this day' memory card showing how many years ago an entry was written.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{On this day, 1 year ago} other{On this day, {count} years ago}}'**
  String journalOnThisDay(int count);

  /// Placeholder text for a locked entry shown in the 'on this day' card.
  ///
  /// In en, this message translates to:
  /// **'A locked entry'**
  String get journalEchoLockedEntry;

  /// Placeholder text for a body-less mood entry shown in the 'on this day' card.
  ///
  /// In en, this message translates to:
  /// **'A mood check-in'**
  String get journalEchoMoodCheckIn;

  /// Counter showing how many more entries exist from the same day in the 'on this day' card.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{+1 more from this day} other{+{count} more from this day}}'**
  String journalEchoMore(int count);

  /// Filter chip showing all journal entries (also reused on the vision board).
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get journalFilterAll;

  /// Filter chip showing only today's journal entries.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get journalFilterToday;

  /// Filter chip showing hard/crisis-mood journal entries.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get journalFilterHard;

  /// Filter chip showing good/great-mood journal entries.
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get journalFilterWins;

  /// Filter chip showing locked journal entries.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get journalFilterLocked;

  /// Hint text in the journal search field.
  ///
  /// In en, this message translates to:
  /// **'Search your entries…'**
  String get journalSearchHint;

  /// Title of the journal empty state (no entries yet).
  ///
  /// In en, this message translates to:
  /// **'A place for the unfiltered you'**
  String get journalEmptyTitle;

  /// Subtitle of the journal empty state.
  ///
  /// In en, this message translates to:
  /// **'Pick a door — or tap + to start with a blank page.'**
  String get journalEmptySubtitle;

  /// Button to open a blank journal entry from the empty state.
  ///
  /// In en, this message translates to:
  /// **'Start with a blank page'**
  String get journalBlankPageButton;

  /// Title of the confirmation dialog when swiping to delete a journal entry.
  ///
  /// In en, this message translates to:
  /// **'Delete entry?'**
  String get journalDeleteEntryTitle;

  /// Body of the delete-entry confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get journalDeleteEntryBody;

  /// Hint shown in place of the body on a locked journal card.
  ///
  /// In en, this message translates to:
  /// **'Locked entry · tap to unlock'**
  String get journalCardLockedHint;

  /// Hint shown on a body-less mood-only journal card.
  ///
  /// In en, this message translates to:
  /// **'Mood check-in · tap to add words'**
  String get journalCardMoodCheckInHint;

  /// Date label on a journal card written today, including the time of day.
  ///
  /// In en, this message translates to:
  /// **'Today {time}'**
  String journalCardDateToday(String time);

  /// Header of the journal entry sheet when editing an existing entry.
  ///
  /// In en, this message translates to:
  /// **'Edit Entry'**
  String get journalEditEntryTitle;

  /// Header of the journal entry sheet when creating a new entry.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Entry'**
  String get journalTodaysEntryTitle;

  /// Label above the primary mood picker in the entry sheet.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling?'**
  String get journalMoodQuestion;

  /// Label above the sub-mood picker when the primary mood is 'great'.
  ///
  /// In en, this message translates to:
  /// **'A little more specific?'**
  String get journalSubMoodSpecific;

  /// Label above the sub-mood picker for non-great moods.
  ///
  /// In en, this message translates to:
  /// **'What\'s underneath?'**
  String get journalSubMoodUnderneath;

  /// Label above the journal body text field.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind?'**
  String get journalMindQuestion;

  /// Button label to stop voice dictation in the entry sheet.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get journalVoiceStop;

  /// Button label to start voice dictation in the entry sheet.
  ///
  /// In en, this message translates to:
  /// **'Speak'**
  String get journalVoiceSpeak;

  /// Snackbar shown when voice input cannot be initialised.
  ///
  /// In en, this message translates to:
  /// **'Voice input is unavailable. Check microphone permission in Settings.'**
  String get journalVoiceUnavailable;

  /// Hint text in the journal body text field.
  ///
  /// In en, this message translates to:
  /// **'Write freely — no one else will see this...'**
  String get journalBodyHint;

  /// Label above the tag picker in the entry sheet.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get journalTagsLabel;

  /// Hint text in the new-tag input field.
  ///
  /// In en, this message translates to:
  /// **'Add a tag…'**
  String get journalAddTagHint;

  /// Button to add a new tag or affirmation.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get journalAdd;

  /// Lock-toggle title when the entry is locked.
  ///
  /// In en, this message translates to:
  /// **'Locked entry'**
  String get journalLockedEntryLabel;

  /// Lock-toggle title when the entry is unlocked.
  ///
  /// In en, this message translates to:
  /// **'Lock this entry'**
  String get journalLockEntryLabel;

  /// Explanation under the lock-this-entry toggle.
  ///
  /// In en, this message translates to:
  /// **'Hidden from the list. Re-auth required to view.'**
  String get journalLockEntryHint;

  /// Save button when editing an existing journal entry or vision item.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get journalSaveChanges;

  /// Save button when creating a new journal entry.
  ///
  /// In en, this message translates to:
  /// **'Save Entry'**
  String get journalSaveEntry;

  /// Headline of the collapsed prompt strip showing a suggested journaling prompt.
  ///
  /// In en, this message translates to:
  /// **'Suggested: {prompt}'**
  String journalSuggestedPrompt(String prompt);

  /// Small tag marking the smart-default journaling prompt category.
  ///
  /// In en, this message translates to:
  /// **'· suggested'**
  String get journalSuggestedTag;

  /// Title of the draft-restore banner; {age} is a relative time like '5m ago'.
  ///
  /// In en, this message translates to:
  /// **'Unsaved draft from {age}'**
  String journalDraftFrom(String age);

  /// Subtitle of the draft-restore banner showing the draft mood and character count.
  ///
  /// In en, this message translates to:
  /// **'{mood} · {count} chars'**
  String journalDraftChars(String mood, int count);

  /// Button to discard an unsaved journal draft.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get journalDraftDiscard;

  /// Relative time for a draft saved less than a minute ago.
  ///
  /// In en, this message translates to:
  /// **'a moment ago'**
  String get journalAgeMomentAgo;

  /// Relative time for a draft saved N minutes ago.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String journalAgeMinutesAgo(int count);

  /// Relative time for a draft saved N hours ago.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String journalAgeHoursAgo(int count);

  /// Relative time for a draft saved more than a day ago.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get journalAgeYesterday;

  /// Personalised affirmation card addressing the user by name.
  ///
  /// In en, this message translates to:
  /// **'{name}, you are doing harder things than most people will ever try.'**
  String journalPersonalCard0(String name);

  /// Personalised affirmation card addressing the user by name.
  ///
  /// In en, this message translates to:
  /// **'{name}, your sober self is the realest version of you.'**
  String journalPersonalCard1(String name);

  /// Personalised affirmation card addressing the user by name.
  ///
  /// In en, this message translates to:
  /// **'{name}, this moment is enough. You are enough.'**
  String journalPersonalCard2(String name);

  /// Personalised affirmation card addressing the user by name.
  ///
  /// In en, this message translates to:
  /// **'{name}, the version of you a year from now is rooting for today\'s you.'**
  String journalPersonalCard3(String name);

  /// Affirmation card mirroring back a recent gratitude the user wrote.
  ///
  /// In en, this message translates to:
  /// **'You wrote this: \"{gratitude}\" — that\'s still true.'**
  String journalPersonalGratitudeCard(String gratitude);

  /// Hint under the swipeable affirmation card.
  ///
  /// In en, this message translates to:
  /// **'Swipe for more affirmations'**
  String get journalSwipeHint;

  /// Section header for the user's custom affirmations list.
  ///
  /// In en, this message translates to:
  /// **'Your affirmations'**
  String get journalYourAffirmations;

  /// Empty-state hint when the user has no custom affirmations.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your own'**
  String get journalTapToAddAffirmation;

  /// Header of the add-affirmation bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Add Affirmation'**
  String get journalAddAffirmationTitle;

  /// Hint text in the add-affirmation input field.
  ///
  /// In en, this message translates to:
  /// **'I am...'**
  String get journalAffirmationHint;

  /// Title of the vision-board empty state when no items match the active filter.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get visionFilterEmptyTitle;

  /// Subtitle of the vision-board filter empty state.
  ///
  /// In en, this message translates to:
  /// **'Try a different filter, or add a new dream.'**
  String get visionFilterEmptySubtitle;

  /// Title of the vision board header banner.
  ///
  /// In en, this message translates to:
  /// **'Your Vision Board'**
  String get visionBoardTitle;

  /// Tagline shown in the vision board header when there are no items.
  ///
  /// In en, this message translates to:
  /// **'Visualise the life ahead of you'**
  String get visionBoardEmptyTagline;

  /// Count of dreams on the vision board, shown in the header subtitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 dream} other{{count} dreams}}'**
  String visionDreamCount(int count);

  /// Count of pinned dreams in the vision board header subtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} pinned'**
  String visionPinnedCount(int count);

  /// Count of achieved dreams in the vision board header subtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} achieved'**
  String visionAchievedCount(int count);

  /// Vision board filter chip for active (not-yet-achieved) dreams.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get visionFilterActive;

  /// Vision board filter chip for pinned dreams.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get visionFilterPinned;

  /// Vision board filter chip for achieved dreams.
  ///
  /// In en, this message translates to:
  /// **'Achieved'**
  String get visionFilterAchieved;

  /// Title of the vision board empty state (no items yet).
  ///
  /// In en, this message translates to:
  /// **'What does your life ahead look like?'**
  String get visionEmptyTitle;

  /// Subtitle of the vision board empty state.
  ///
  /// In en, this message translates to:
  /// **'Start with one of these — or tap + for a blank canvas.'**
  String get visionEmptySubtitle;

  /// Button to add a blank vision item from the empty state.
  ///
  /// In en, this message translates to:
  /// **'Start with a blank dream'**
  String get visionBlankDreamButton;

  /// Hint on a vision card without milestones, prompting the user to open it.
  ///
  /// In en, this message translates to:
  /// **'Tap to open'**
  String get visionTapToOpen;

  /// Title of the confirm dialog when long-pressing to delete a vision item.
  ///
  /// In en, this message translates to:
  /// **'Remove this dream?'**
  String get visionRemoveDreamTitle;

  /// Button to cancel removing a vision item.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get visionKeep;

  /// Button to confirm removing a vision item.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get visionRemove;

  /// Header of the vision edit sheet when editing an existing item.
  ///
  /// In en, this message translates to:
  /// **'Edit Dream'**
  String get visionEditDreamTitle;

  /// Header of the vision edit sheet when adding a new item.
  ///
  /// In en, this message translates to:
  /// **'Add a Dream'**
  String get visionAddDreamTitle;

  /// Primary button to save a new vision item.
  ///
  /// In en, this message translates to:
  /// **'Add to Vision Board'**
  String get visionAddToBoard;

  /// Secondary button to delete a vision item from the edit sheet.
  ///
  /// In en, this message translates to:
  /// **'Remove this dream'**
  String get visionRemoveThisDream;

  /// Field label for the vision item title.
  ///
  /// In en, this message translates to:
  /// **'Dream title'**
  String get visionDreamTitleLabel;

  /// Hint text for the vision item title field.
  ///
  /// In en, this message translates to:
  /// **'e.g. Be more present for my family'**
  String get visionDreamTitleHint;

  /// Field label for the optional vision item notes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get visionNotesLabel;

  /// Hint text for the vision item notes field.
  ///
  /// In en, this message translates to:
  /// **'Anything to remember…'**
  String get visionNotesHint;

  /// Field label for the optional 'why it matters' field.
  ///
  /// In en, this message translates to:
  /// **'Why this matters (optional)'**
  String get visionWhyLabel;

  /// Hint text for the 'why it matters' field.
  ///
  /// In en, this message translates to:
  /// **'When this matters most, why does it matter?'**
  String get visionWhyHint;

  /// Field label for the vision item category picker.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get visionCategoryLabel;

  /// Field label for the vision item icon picker.
  ///
  /// In en, this message translates to:
  /// **'Choose your icon'**
  String get visionChooseIcon;

  /// Field label for the optional vision item target date.
  ///
  /// In en, this message translates to:
  /// **'Target date (optional)'**
  String get visionTargetDateLabel;

  /// Placeholder shown when no target date is set.
  ///
  /// In en, this message translates to:
  /// **'Pick a date to work toward'**
  String get visionTargetDatePlaceholder;

  /// Field label for the vision item photo picker.
  ///
  /// In en, this message translates to:
  /// **'Photos help you feel it (up to 20)'**
  String get visionPhotosLabel;

  /// Button label to add the first photo to a vision item.
  ///
  /// In en, this message translates to:
  /// **'Add your first photo'**
  String get visionAddFirstPhoto;

  /// Button label to add another photo, showing how many of 20 are used.
  ///
  /// In en, this message translates to:
  /// **'Add another ({count}/20)'**
  String visionAddAnotherPhoto(int count);

  /// Privacy note under the vision item photo picker.
  ///
  /// In en, this message translates to:
  /// **'Photos are stored on this device only — they never leave your phone.'**
  String get visionPhotosPrivacyNote;

  /// Field label for the vision item milestones/steps.
  ///
  /// In en, this message translates to:
  /// **'Small concrete steps'**
  String get visionStepsLabel;

  /// Description under the vision item steps label.
  ///
  /// In en, this message translates to:
  /// **'Break the dream into 3–6 tiny wins. Check them off as life moves.'**
  String get visionStepsDescription;

  /// Empty-state text when a vision item has no milestones.
  ///
  /// In en, this message translates to:
  /// **'No steps yet — add one below.'**
  String get visionNoStepsYet;

  /// Hint text for the add-milestone input field.
  ///
  /// In en, this message translates to:
  /// **'e.g. Walk 20 minutes today'**
  String get visionStepHint;

  /// Field label for the vision item affirmation.
  ///
  /// In en, this message translates to:
  /// **'Affirmation'**
  String get visionAffirmationLabel;

  /// Description under the vision item affirmation label.
  ///
  /// In en, this message translates to:
  /// **'\"I am…\" beats \"I want to…\" — the brain hears it as already real.'**
  String get visionAffirmationDescription;

  /// Hint text for the vision item affirmation field.
  ///
  /// In en, this message translates to:
  /// **'I am present, patient, and proud of how I show up.'**
  String get visionAffirmationHint;

  /// Button that auto-suggests an affirmation from the dream title.
  ///
  /// In en, this message translates to:
  /// **'Suggest from title'**
  String get visionSuggestFromTitle;

  /// Tab label for the vision details tab in the edit sheet.
  ///
  /// In en, this message translates to:
  /// **'Vision'**
  String get visionTabVision;

  /// Tab label for the photos tab in the vision edit sheet.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get visionTabPhotos;

  /// Tab label for the milestones/steps tab in the vision edit sheet.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get visionTabSteps;

  /// Tab label for the affirmation tab in the vision edit sheet.
  ///
  /// In en, this message translates to:
  /// **'Affirm'**
  String get visionTabAffirm;

  /// Overline label above the daily zen quote.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Reflection'**
  String get zenTodaysReflection;

  /// Section title for the morning intention widget in the Zen tab.
  ///
  /// In en, this message translates to:
  /// **'Morning Intention'**
  String get zenMorningIntention;

  /// Section title for the evening reflection prompts in the Zen tab.
  ///
  /// In en, this message translates to:
  /// **'Reflection Prompts'**
  String get zenReflectionPrompts;

  /// Section title for the gratitude widget in the Zen tab.
  ///
  /// In en, this message translates to:
  /// **'Three Good Things'**
  String get zenThreeGoodThings;

  /// Section title for the breathing reminder in the Zen tab.
  ///
  /// In en, this message translates to:
  /// **'Mindful Moment'**
  String get zenMindfulMoment;

  /// Rotating hint for the morning intention field.
  ///
  /// In en, this message translates to:
  /// **'Today I intend to…'**
  String get zenIntentionPrompt0;

  /// Rotating hint for the morning intention field.
  ///
  /// In en, this message translates to:
  /// **'My focus for today is…'**
  String get zenIntentionPrompt1;

  /// Rotating hint for the morning intention field.
  ///
  /// In en, this message translates to:
  /// **'I will show up for myself by…'**
  String get zenIntentionPrompt2;

  /// Rotating hint for the morning intention field.
  ///
  /// In en, this message translates to:
  /// **'One thing I\'m grateful for right now is…'**
  String get zenIntentionPrompt3;

  /// Button to save the morning intention.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get zenSetIntention;

  /// Evening reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'What went well today?'**
  String get zenReflectionPrompt0;

  /// Evening reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'What challenged me, and how did I handle it?'**
  String get zenReflectionPrompt1;

  /// Evening reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'What am I most proud of today?'**
  String get zenReflectionPrompt2;

  /// Evening reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'How did I take care of myself today?'**
  String get zenReflectionPrompt3;

  /// Evening reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'What would I do differently tomorrow?'**
  String get zenReflectionPrompt4;

  /// Evening reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'Who or what am I grateful for right now?'**
  String get zenReflectionPrompt5;

  /// Evening reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'What did I learn about myself today?'**
  String get zenReflectionPrompt6;

  /// Evening reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'How did I show up for my sobriety today?'**
  String get zenReflectionPrompt7;

  /// Button to cycle to the next evening reflection prompt.
  ///
  /// In en, this message translates to:
  /// **'Next prompt'**
  String get zenNextPrompt;

  /// Hint text in each of the three good-things gratitude fields.
  ///
  /// In en, this message translates to:
  /// **'Something good today…'**
  String get zenGoodThingHint;

  /// Title of a mindful-moment grounding exercise.
  ///
  /// In en, this message translates to:
  /// **'5-4-3-2-1 Grounding'**
  String get zenExercise0Title;

  /// Description of the 5-4-3-2-1 grounding exercise.
  ///
  /// In en, this message translates to:
  /// **'Name 5 things you see, 4 you can touch, 3 you hear, 2 you smell, 1 you taste.'**
  String get zenExercise0Desc;

  /// Title of a mindful-moment breathing exercise.
  ///
  /// In en, this message translates to:
  /// **'Box Breath'**
  String get zenExercise1Title;

  /// Description of the box breath exercise.
  ///
  /// In en, this message translates to:
  /// **'Breathe in for 4, hold for 4, breathe out for 4, hold for 4. Repeat 4 times.'**
  String get zenExercise1Desc;

  /// Title of a mindful-moment body scan exercise.
  ///
  /// In en, this message translates to:
  /// **'Body Scan'**
  String get zenExercise2Title;

  /// Description of the body scan exercise.
  ///
  /// In en, this message translates to:
  /// **'Close your eyes. Slowly scan from your toes to your head, releasing tension as you go.'**
  String get zenExercise2Desc;

  /// Title of a mindful-moment gratitude breathing exercise.
  ///
  /// In en, this message translates to:
  /// **'Gratitude Breath'**
  String get zenExercise3Title;

  /// Description of the gratitude breath exercise.
  ///
  /// In en, this message translates to:
  /// **'With each inhale, think of something you\'re grateful for. With each exhale, let go of what doesn\'t serve you.'**
  String get zenExercise3Desc;

  /// Link to the guided breathing tool for exercises that have a guided version.
  ///
  /// In en, this message translates to:
  /// **'Open guided breathing in Your Toolkit'**
  String get zenOpenGuidedBreathing;

  /// Link to more breathing exercises for exercises without a guided version.
  ///
  /// In en, this message translates to:
  /// **'More breathing exercises in Your Toolkit'**
  String get zenMoreBreathingExercises;

  /// AppBar title and saved-entry heading for the guided Daily Reflection journal template
  ///
  /// In en, this message translates to:
  /// **'Daily Reflection'**
  String get journalReflectionTitle;

  /// Save button label while the reflection is being saved
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get journalReflectionSaving;

  /// Section title above the mood picker on the Daily Reflection page
  ///
  /// In en, this message translates to:
  /// **'How I feel today'**
  String get journalReflectionMoodTitle;

  /// Section title above the three gratitude lines on the Daily Reflection page
  ///
  /// In en, this message translates to:
  /// **'I\'m grateful for'**
  String get journalReflectionGratefulTitle;

  /// Section title above the recovery-action checklist (anchors) on the Daily Reflection page
  ///
  /// In en, this message translates to:
  /// **'Today\'s anchors'**
  String get journalReflectionAnchorsTitle;

  /// Checklist item: a recovery anchor action — contacting another person
  ///
  /// In en, this message translates to:
  /// **'Reached out to someone'**
  String get journalReflectionAnchorReachedOut;

  /// Checklist item: a recovery anchor action — attending a support meeting or group
  ///
  /// In en, this message translates to:
  /// **'Attended a meeting or group'**
  String get journalReflectionAnchorMeeting;

  /// Checklist item: a recovery anchor action — physical movement or exercise
  ///
  /// In en, this message translates to:
  /// **'Moved my body'**
  String get journalReflectionAnchorMoved;

  /// Checklist item: a recovery anchor action — eating well and staying hydrated
  ///
  /// In en, this message translates to:
  /// **'Ate + hydrated well'**
  String get journalReflectionAnchorAteHydrated;

  /// Checklist item: a recovery anchor action — taking prescribed medication
  ///
  /// In en, this message translates to:
  /// **'Took my meds'**
  String get journalReflectionAnchorMeds;

  /// Checklist item: a recovery anchor action — avoiding a known trigger
  ///
  /// In en, this message translates to:
  /// **'Avoided a trigger'**
  String get journalReflectionAnchorAvoidedTrigger;

  /// Section title above the 'wins today' free-text field on the Daily Reflection page
  ///
  /// In en, this message translates to:
  /// **'Wins today'**
  String get journalReflectionWinsTitle;

  /// Placeholder hint text for the 'wins today' field
  ///
  /// In en, this message translates to:
  /// **'Anything you\'re proud of — big or small.'**
  String get journalReflectionWinsHint;

  /// Section title above the cravings/triggers free-text field on the Daily Reflection page
  ///
  /// In en, this message translates to:
  /// **'Cravings or triggers noticed'**
  String get journalReflectionCravingsTitle;

  /// Placeholder hint text for the cravings/triggers field
  ///
  /// In en, this message translates to:
  /// **'What showed up, and how did you respond?'**
  String get journalReflectionCravingsHint;

  /// Section title above the 'tomorrow's intention' free-text field on the Daily Reflection page
  ///
  /// In en, this message translates to:
  /// **'Tomorrow\'s intention'**
  String get journalReflectionIntentionTitle;

  /// Placeholder hint text for the 'tomorrow's intention' field
  ///
  /// In en, this message translates to:
  /// **'One small thing you\'ll do for your recovery.'**
  String get journalReflectionIntentionHint;

  /// Section title above the affirmation free-text field on the Daily Reflection page
  ///
  /// In en, this message translates to:
  /// **'An affirmation for me'**
  String get journalReflectionAffirmationTitle;

  /// Placeholder hint text for the affirmation field
  ///
  /// In en, this message translates to:
  /// **'A kind sentence in your own voice.'**
  String get journalReflectionAffirmationHint;

  /// Reassuring footer note at the bottom of the Daily Reflection page; contains a line break
  ///
  /// In en, this message translates to:
  /// **'You don\'t have to fill every field.\nWhat you write is enough.'**
  String get journalReflectionFooter;

  /// Heading written into the saved reflection entry text above the gratitude list; keep the emoji
  ///
  /// In en, this message translates to:
  /// **'🙏 Grateful for'**
  String get journalReflectionBodyGratefulHeading;

  /// Heading written into the saved reflection entry text above the checked anchors list; keep the emoji
  ///
  /// In en, this message translates to:
  /// **'⚓ Today\'s anchors'**
  String get journalReflectionBodyAnchorsHeading;

  /// Heading written into the saved reflection entry text above the wins section; keep the emoji
  ///
  /// In en, this message translates to:
  /// **'✨ Wins today'**
  String get journalReflectionBodyWinsHeading;

  /// Heading written into the saved reflection entry text above the cravings section; keep the emoji
  ///
  /// In en, this message translates to:
  /// **'⚡ Cravings or triggers noticed'**
  String get journalReflectionBodyCravingsHeading;

  /// Heading written into the saved reflection entry text above the intention section; keep the emoji
  ///
  /// In en, this message translates to:
  /// **'🌱 Tomorrow\'s intention'**
  String get journalReflectionBodyIntentionHeading;

  /// Heading written into the saved reflection entry text above the affirmation section; keep the emoji
  ///
  /// In en, this message translates to:
  /// **'💛 An affirmation for me'**
  String get journalReflectionBodyAffirmationHeading;

  /// Milestone label for reaching 100 days sober.
  ///
  /// In en, this message translates to:
  /// **'100 Days'**
  String get milestoneHundredDays;

  /// Short milestone label (tile grid) for 100 days sober.
  ///
  /// In en, this message translates to:
  /// **'100 Days'**
  String get milestoneHundredDaysShort;

  /// Body text describing physiological/psychological benefits at the 100-day milestone.
  ///
  /// In en, this message translates to:
  /// **'One hundred days. Brain neuroplasticity is in full swing. The reward system has largely recalibrated to find pleasure in life without alcohol. Relationships, work, and your sense of self are transforming.'**
  String get milestoneHundredDaysBenefit;

  /// Text shared along with the milestone image card to social/messaging apps. {emoji} is a milestone emoji, {name} is the user's name, {label} is the milestone label e.g. 'One Month'.
  ///
  /// In en, this message translates to:
  /// **'{emoji} {name} — {label} sober. One day at a time. #JourneyForward #Sobriety'**
  String milestoneShareText(String emoji, String name, String label);

  /// Snackbar shown when generating the shareable milestone image fails.
  ///
  /// In en, this message translates to:
  /// **'Could not generate card. Try again.'**
  String get milestoneCardGenerateError;

  /// Overline/section header above the previewed shareable milestone card.
  ///
  /// In en, this message translates to:
  /// **'SHARE CARD'**
  String get milestoneShareCardLabel;

  /// Button label to share the achieved milestone card.
  ///
  /// In en, this message translates to:
  /// **'Share this milestone'**
  String get milestoneShareButton;

  /// Disabled share-button label shown when the selected milestone has not been reached yet.
  ///
  /// In en, this message translates to:
  /// **'Not yet achieved'**
  String get milestoneNotYetAchieved;

  /// Overline/section header above the grid of all milestones.
  ///
  /// In en, this message translates to:
  /// **'ALL MILESTONES'**
  String get milestoneAllMilestonesLabel;

  /// Hero card greeting shown when the user has not set a name.
  ///
  /// In en, this message translates to:
  /// **'Well done.'**
  String get milestoneHeroGreeting;

  /// Hero card greeting that includes the user's first name.
  ///
  /// In en, this message translates to:
  /// **'Well done, {name}.'**
  String milestoneHeroGreetingNamed(String name);

  /// Two-line unit label shown next to the big day count on the hero card when the count is exactly 1. Keep the newline (\n) between the two words.
  ///
  /// In en, this message translates to:
  /// **'day\nsober'**
  String get milestoneHeroDaySober;

  /// Two-line unit label shown next to the big day count on the hero card (plural). Keep the newline (\n) between the two words.
  ///
  /// In en, this message translates to:
  /// **'days\nsober'**
  String get milestoneHeroDaysSober;

  /// Hero card label showing the next upcoming milestone. {label} is the milestone name e.g. 'One Week'.
  ///
  /// In en, this message translates to:
  /// **'Next: {label}'**
  String milestoneHeroNext(String label);

  /// Hero card progress text showing current sober days out of the next milestone's target days.
  ///
  /// In en, this message translates to:
  /// **'{days} of {target} days'**
  String milestoneHeroProgressDays(int days, int target);

  /// Badge shown on the hero card when the user has reached the final/all milestones. Keep the sparkle emoji.
  ///
  /// In en, this message translates to:
  /// **'Every milestone reached ✨'**
  String get milestoneEveryReached;

  /// Small badge on the achievement card indicating the milestone is reached. Keep the check mark.
  ///
  /// In en, this message translates to:
  /// **'Achieved ✓'**
  String get milestoneAchievedBadge;

  /// Badge on the achievement card showing how many days until the milestone is reached.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day to go} other{{count} days to go}}'**
  String milestoneDaysToGo(int count);

  /// Section header above the benefit text when the milestone has been achieved (past tense).
  ///
  /// In en, this message translates to:
  /// **'What happened in your body'**
  String get milestoneWhatHappenedLabel;

  /// Section header above the benefit text when the milestone has not been achieved yet (future tense).
  ///
  /// In en, this message translates to:
  /// **'What will happen'**
  String get milestoneWhatWillHappenLabel;

  /// Fallback name shown on the shareable card when the user has not entered a name.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get milestoneShareCardFallbackName;

  /// Singular unit word ('day') shown under the big number on the shareable card.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get milestoneUnitDay;

  /// Plural unit word ('days') shown under the big number on the shareable card.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get milestoneUnitDays;

  /// Singular unit word ('year') shown under the big number on the shareable card for year milestones.
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get milestoneUnitYear;

  /// Plural unit word ('years') shown under the big number on the shareable card for year milestones.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get milestoneUnitYears;

  /// Second line under the big number on the shareable card (e.g. '1 / year / sober').
  ///
  /// In en, this message translates to:
  /// **'sober'**
  String get milestoneUnitSober;

  /// Brand name displayed at the top of the shareable milestone card.
  ///
  /// In en, this message translates to:
  /// **'JOURNEY FORWARD'**
  String get milestoneShareCardBrand;

  /// Overlay text on a locked (unachieved) shareable card showing days remaining to unlock it.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 more day to unlock} other{{count} more days to unlock}}'**
  String milestoneDaysToUnlock(int count);

  /// Two-line label under the total-days stat at the bottom of the screen. Keep the newline (\n).
  ///
  /// In en, this message translates to:
  /// **'total\ndays sober'**
  String get milestoneStatsTotalDaysSober;

  /// Two-line label under the money-saved stat at the bottom of the screen. Keep the newline (\n).
  ///
  /// In en, this message translates to:
  /// **'money\nreclaimed'**
  String get milestoneStatsMoneyReclaimed;

  /// Error shown when the user picks biometric lock but no fingerprint/face is enrolled on the device.
  ///
  /// In en, this message translates to:
  /// **'Biometrics aren\'t set up on this device. Add a fingerprint or face in your phone\'s settings, then try again.'**
  String get onbBiometricNotEnrolledError;

  /// Prompt reason shown by the OS biometric dialog while enabling biometric app lock during onboarding.
  ///
  /// In en, this message translates to:
  /// **'Confirm to enable biometric lock'**
  String get onbBiometricConfirmReason;

  /// Error shown when the biometric authentication attempt throws a platform exception during onboarding setup.
  ///
  /// In en, this message translates to:
  /// **'Biometric setup failed: {error}'**
  String onbBiometricSetupFailed(String error);

  /// Error shown when saving the profile / finishing onboarding fails.
  ///
  /// In en, this message translates to:
  /// **'Could not complete setup: {error}'**
  String onbSetupFailed(String error);

  /// Uppercase eyebrow label above the welcome headline on the first onboarding screen.
  ///
  /// In en, this message translates to:
  /// **'DAY ONE  ·  A WELCOME'**
  String get onbWelcomeEyebrow;

  /// Large serif headline on the welcome onboarding screen. Keep the line break.
  ///
  /// In en, this message translates to:
  /// **'A new chapter,\nquietly begun.'**
  String get onbWelcomeHeadline;

  /// Subtitle of the '100% on-device' feature pill on the welcome screen. Keep the line break.
  ///
  /// In en, this message translates to:
  /// **'Works without\nthe internet'**
  String get onbWelcomePillOnDeviceSub;

  /// Uppercase title of the no-account feature pill on the welcome screen.
  ///
  /// In en, this message translates to:
  /// **'NO ACCOUNT'**
  String get onbWelcomePillNoAccountTitle;

  /// Subtitle of the no-account feature pill on the welcome screen. Keep the line break.
  ///
  /// In en, this message translates to:
  /// **'No login or\nprofile upload'**
  String get onbWelcomePillNoAccountSub;

  /// Uppercase title of the zero-tracking feature pill on the welcome screen.
  ///
  /// In en, this message translates to:
  /// **'ZERO TRACKING'**
  String get onbWelcomePillZeroTrackingTitle;

  /// Subtitle of the zero-tracking feature pill on the welcome screen. Keep the line break.
  ///
  /// In en, this message translates to:
  /// **'Your data stays\non device'**
  String get onbWelcomePillZeroTrackingSub;

  /// Primary call-to-action button on the welcome onboarding screen.
  ///
  /// In en, this message translates to:
  /// **'Begin'**
  String get onbWelcomeBeginButton;

  /// Small disclaimer text at the bottom of the welcome onboarding screen.
  ///
  /// In en, this message translates to:
  /// **'Not medical advice — a companion, not a clinician.'**
  String get onbWelcomeDisclaimer;

  /// Label on the date tile when the user has chosen a future quit date (countdown mode).
  ///
  /// In en, this message translates to:
  /// **'Quit date'**
  String get onbQuitDateLabel;

  /// Label on the time tile in the sober-date onboarding step.
  ///
  /// In en, this message translates to:
  /// **'Time of day'**
  String get onbTimeOfDayLabel;

  /// Trailing label after the countdown number when a future quit date is selected, e.g. '12 days until day one'.
  ///
  /// In en, this message translates to:
  /// **'days until day one'**
  String get onbDaysUntilDayOneLabel;

  /// Data-recovery warning shown when the user selects PIN lock during onboarding.
  ///
  /// In en, this message translates to:
  /// **'If you forget your PIN, your data cannot be recovered without a backup. Set up a backup later in Profile → Backup.'**
  String get onbSecurityPinRecoveryWarning;

  /// Data-recovery warning shown when the user selects biometric lock during onboarding.
  ///
  /// In en, this message translates to:
  /// **'If you lose biometric access (factory reset, device change, etc.), your data cannot be recovered without a backup. Set one up in Profile → Backup.'**
  String get onbSecurityBiometricRecoveryWarning;

  /// Finish-step headline when the user entered a name. Keep the line break.
  ///
  /// In en, this message translates to:
  /// **'You\'re ready,\n{name}.'**
  String onbFinishHeadlineWithName(String name);

  /// Finish-step headline when no name was entered. Keep the line break.
  ///
  /// In en, this message translates to:
  /// **'You\'re ready\nfor this.'**
  String get onbFinishHeadline;

  /// Uppercase eyebrow on the finish step when a future quit date is set, counting down to day one.
  ///
  /// In en, this message translates to:
  /// **'IN {days} DAYS  ·  YOUR JOURNEY BEGINS'**
  String onbFinishEyebrowCountdown(int days);

  /// Uppercase eyebrow on the finish step when the user already has sober days logged.
  ///
  /// In en, this message translates to:
  /// **'DAY {day}  ·  THE PATH CONTINUES'**
  String onbFinishEyebrowContinuing(int day);

  /// Uppercase eyebrow on the finish step when the journey starts today (day one).
  ///
  /// In en, this message translates to:
  /// **'DAY ONE  ·  THE JOURNEY BEGINS'**
  String get onbFinishEyebrowDayOne;

  /// Finish-step subtitle shown when the user picked a future quit date.
  ///
  /// In en, this message translates to:
  /// **'Your quit date is set. We\'ll count down with you — and the moment it arrives, day one begins.'**
  String get onbFinishBodyFuture;

  /// Toolkit exercise name: a 4-4-4-4 guided breathing technique the user can link to a craving-plan step.
  ///
  /// In en, this message translates to:
  /// **'Box Breathing'**
  String get planToolkitBoxBreathingLabel;

  /// Sub-label describing the Box Breathing toolkit exercise.
  ///
  /// In en, this message translates to:
  /// **'Guided 4-4-4-4 breath cycle'**
  String get planToolkitBoxBreathingSub;

  /// Toolkit exercise name: a sensory grounding technique (notice 5 things you see, 4 you hear, etc.).
  ///
  /// In en, this message translates to:
  /// **'5-4-3-2-1 Grounding'**
  String get planToolkitGroundingLabel;

  /// Sub-label describing the 5-4-3-2-1 Grounding toolkit exercise.
  ///
  /// In en, this message translates to:
  /// **'Ground yourself through your senses'**
  String get planToolkitGroundingSub;

  /// Toolkit exercise name: a cognitive behavioural therapy thought-reframing exercise.
  ///
  /// In en, this message translates to:
  /// **'CBT Thought Reframe'**
  String get planToolkitCbtReframeLabel;

  /// Sub-label describing the CBT Thought Reframe toolkit exercise.
  ///
  /// In en, this message translates to:
  /// **'Challenge the craving thought'**
  String get planToolkitCbtReframeSub;

  /// Toolkit exercise name: reading personal affirmations.
  ///
  /// In en, this message translates to:
  /// **'Affirmations'**
  String get planToolkitAffirmationsLabel;

  /// Sub-label describing the Affirmations toolkit exercise.
  ///
  /// In en, this message translates to:
  /// **'Read a personal affirmation'**
  String get planToolkitAffirmationsSub;

  /// Toolkit exercise name: splashing cold water on the face to interrupt a craving.
  ///
  /// In en, this message translates to:
  /// **'Cold Water'**
  String get planToolkitColdWaterLabel;

  /// Sub-label describing the Cold Water toolkit exercise.
  ///
  /// In en, this message translates to:
  /// **'Splash cold water on your face'**
  String get planToolkitColdWaterSub;

  /// Toolkit exercise name: taking a short walk outdoors to reset.
  ///
  /// In en, this message translates to:
  /// **'Walk Outside'**
  String get planToolkitWalkOutsideLabel;

  /// Sub-label describing the Walk Outside toolkit exercise.
  ///
  /// In en, this message translates to:
  /// **'Take a short walk to reset'**
  String get planToolkitWalkOutsideSub;

  /// Toolkit exercise name: phoning a sponsor or friend for support.
  ///
  /// In en, this message translates to:
  /// **'Call Someone'**
  String get planToolkitCallSomeoneLabel;

  /// Sub-label describing the Call Someone toolkit exercise.
  ///
  /// In en, this message translates to:
  /// **'Reach out to your sponsor or a friend'**
  String get planToolkitCallSomeoneSub;

  /// Toolkit exercise name: a body-scan relaxation from toes to head.
  ///
  /// In en, this message translates to:
  /// **'Body Scan'**
  String get planToolkitBodyScanLabel;

  /// Sub-label describing the Body Scan toolkit exercise.
  ///
  /// In en, this message translates to:
  /// **'Scan from toes to head, release tension'**
  String get planToolkitBodyScanSub;

  /// Placeholder hint for the first pre-craving plan step input.
  ///
  /// In en, this message translates to:
  /// **'e.g. Take three slow box-breaths'**
  String get planStepHint1;

  /// Placeholder hint for the second pre-craving plan step input.
  ///
  /// In en, this message translates to:
  /// **'e.g. Drink a glass of cold water'**
  String get planStepHint2;

  /// Placeholder hint for the third pre-craving plan step input.
  ///
  /// In en, this message translates to:
  /// **'e.g. Text my sponsor: \"Craving\"'**
  String get planStepHint3;

  /// Snackbar confirmation shown after the user saves their pre-craving plan.
  ///
  /// In en, this message translates to:
  /// **'Plan saved — you\'ll see it when a craving hits.'**
  String get planSavedSnack;

  /// Screen title for the pre-craving plan screen.
  ///
  /// In en, this message translates to:
  /// **'Pre-craving plan'**
  String get planTitle;

  /// Subtitle on the pre-craving plan screen explaining its purpose.
  ///
  /// In en, this message translates to:
  /// **'Three things you commit to doing the moment a craving hits — written in calm so you don\'t have to think in a storm.'**
  String get planSubtitle;

  /// Tappable label that lets the user attach a toolkit exercise to a plan step.
  ///
  /// In en, this message translates to:
  /// **'Link a Toolkit exercise'**
  String get planLinkExercise;

  /// Informational note explaining what linking a toolkit exercise does.
  ///
  /// In en, this message translates to:
  /// **'Linking a Toolkit exercise adds a one-tap \"Open\" button during your plan so you can jump straight into the exercise.'**
  String get planLinkInfo;

  /// Button label to save the pre-craving plan when there are unsaved changes.
  ///
  /// In en, this message translates to:
  /// **'Save plan'**
  String get planSavePlan;

  /// Button label shown after the pre-craving plan has been saved (no unsaved changes).
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get planSaved;

  /// Title of the bottom sheet where the user picks a toolkit exercise to link.
  ///
  /// In en, this message translates to:
  /// **'Choose a Toolkit Exercise'**
  String get planPickerTitle;

  /// Subtitle of the toolkit-exercise picker bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Tap to add a one-tap link to this exercise in your plan.'**
  String get planPickerSubtitle;

  /// Small badge indicating that a toolkit exercise opens inside the app (has a route).
  ///
  /// In en, this message translates to:
  /// **'Opens in app'**
  String get planOpensInApp;

  /// Title of the plan-runner sheet shown before logging a craving.
  ///
  /// In en, this message translates to:
  /// **'Your plan'**
  String get planRunnerTitle;

  /// Subtitle of the plan-runner sheet prompting the user to work through their plan steps.
  ///
  /// In en, this message translates to:
  /// **'Run through these before logging. Breathe between each one.'**
  String get planRunnerSubtitle;

  /// Tappable label that opens a linked toolkit exercise from a plan step; {label} is the exercise name.
  ///
  /// In en, this message translates to:
  /// **'Open {label} →'**
  String planRunnerOpenExercise(String label);

  /// Button on the plan-runner sheet: the user feels okay and does not need to log the craving.
  ///
  /// In en, this message translates to:
  /// **'I\'m okay'**
  String get planRunnerImOkay;

  /// Button on the plan-runner sheet: continue to the craving-logging flow anyway.
  ///
  /// In en, this message translates to:
  /// **'Still log it'**
  String get planRunnerStillLogIt;

  /// Label on the small chip/button in the Progress header that opens the weekly care summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get progressSummaryChip;

  /// Eyebrow label above the live counter when the current day count exactly matches a milestone.
  ///
  /// In en, this message translates to:
  /// **'Milestone reached'**
  String get progressMilestoneReached;

  /// Eyebrow label above the live sober-time counter when not currently at a milestone.
  ///
  /// In en, this message translates to:
  /// **'Current journey'**
  String get progressCurrentJourney;

  /// Title showing the milestone the user is currently on. {label} is a milestone name like 'One Week'.
  ///
  /// In en, this message translates to:
  /// **'Milestone: {label}'**
  String progressMilestonePrefix(String label);

  /// Title showing the next milestone to reach. {label} is a milestone name like 'One Month'.
  ///
  /// In en, this message translates to:
  /// **'Next: {label}'**
  String progressNextPrefix(String label);

  /// Fallback milestone label used when no named milestone exists for a given day count. Capitalized 'Days'.
  ///
  /// In en, this message translates to:
  /// **'{count} Days'**
  String progressDaysLabel(int count);

  /// Percentage-complete text shown next to the milestone progress bar.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String progressPercentComplete(int percent);

  /// Encouraging caption under the progress bar when the user is exactly at a milestone.
  ///
  /// In en, this message translates to:
  /// **'A beautiful threshold crossed.'**
  String get progressThresholdCrossed;

  /// Progress caption showing current days out of the next-milestone target, e.g. '5 / 7 days'.
  ///
  /// In en, this message translates to:
  /// **'{days} / {target} days'**
  String progressDaysOfTarget(int days, int target);

  /// Section title for the milestone achievement grid.
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get progressMilestonesTitle;

  /// Tappable link in the Milestones section header that opens the shareable milestone cards screen.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get progressCardsLink;

  /// Compact label inside a milestone grid cell for the one-year (365-day) milestone.
  ///
  /// In en, this message translates to:
  /// **'1yr'**
  String get progressGridYear;

  /// Compact label inside a milestone grid cell showing months, e.g. '2mo'.
  ///
  /// In en, this message translates to:
  /// **'{count}mo'**
  String progressGridMonths(int count);

  /// Compact label inside a milestone grid cell showing days, e.g. '7d'.
  ///
  /// In en, this message translates to:
  /// **'{count}d'**
  String progressGridDays(int count);

  /// Uppercase unit label under the days digits in the live sober-time counter.
  ///
  /// In en, this message translates to:
  /// **'DAYS'**
  String get progressUnitDays;

  /// Uppercase unit label under the hours digits in the live sober-time counter.
  ///
  /// In en, this message translates to:
  /// **'HRS'**
  String get progressUnitHrs;

  /// Uppercase unit label under the minutes digits in the live sober-time counter.
  ///
  /// In en, this message translates to:
  /// **'MIN'**
  String get progressUnitMin;

  /// Uppercase unit label under the seconds digits in the live sober-time counter.
  ///
  /// In en, this message translates to:
  /// **'SEC'**
  String get progressUnitSec;

  /// Title of the cravings insight chart card on the Insights tab.
  ///
  /// In en, this message translates to:
  /// **'Craving Support'**
  String get progressInsightCravingTitle;

  /// Subtitle of the cravings insight chart card.
  ///
  /// In en, this message translates to:
  /// **'Every log is a brave step toward healing.'**
  String get progressInsightCravingSubtitle;

  /// Motivational quote shown at the bottom of the cravings insight card. Contains a line break.
  ///
  /// In en, this message translates to:
  /// **'Logging a craving is a sign of strength.\nYou\'re choosing awareness and support.'**
  String get progressInsightCravingQuote;

  /// Title of the sleep insight chart card on the Insights tab.
  ///
  /// In en, this message translates to:
  /// **'Sleep Quality'**
  String get progressInsightSleepTitle;

  /// Subtitle of the sleep insight chart card.
  ///
  /// In en, this message translates to:
  /// **'Hours logged per night, tracked daily.'**
  String get progressInsightSleepSubtitle;

  /// Motivational quote shown at the bottom of the sleep insight card. Contains a line break.
  ///
  /// In en, this message translates to:
  /// **'Rest is part of recovery.\nEvery hour of sleep supports your healing.'**
  String get progressInsightSleepQuote;

  /// Title of the physical-activity insight chart card on the Insights tab.
  ///
  /// In en, this message translates to:
  /// **'Movement'**
  String get progressInsightMovementTitle;

  /// Subtitle of the movement insight chart card.
  ///
  /// In en, this message translates to:
  /// **'Active minutes per day, two weeks out.'**
  String get progressInsightMovementSubtitle;

  /// Motivational quote shown at the bottom of the movement insight card. Contains a line break.
  ///
  /// In en, this message translates to:
  /// **'Movement lifts the spirit.\nEvery active minute counts.'**
  String get progressInsightMovementQuote;

  /// Title of the thoughts insight chart card on the Insights tab.
  ///
  /// In en, this message translates to:
  /// **'Thoughts'**
  String get progressInsightThoughtsTitle;

  /// Subtitle of the thoughts insight chart card.
  ///
  /// In en, this message translates to:
  /// **'Thoughts logged each day across 14 days.'**
  String get progressInsightThoughtsSubtitle;

  /// Motivational quote shown at the bottom of the thoughts insight card. Contains a line break.
  ///
  /// In en, this message translates to:
  /// **'Reflection builds resilience.\nYour thoughts are your inner compass.'**
  String get progressInsightThoughtsQuote;

  /// Y-axis unit caption for insight charts that count log entries.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get progressYLabelLogs;

  /// Y-axis unit caption for the sleep insight chart (hours).
  ///
  /// In en, this message translates to:
  /// **'Hrs'**
  String get progressYLabelHrs;

  /// Y-axis unit caption for the movement insight chart (minutes).
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get progressYLabelMin;

  /// Header of each insight card combining its title with a fixed '14 days' window suffix, e.g. 'Sleep Quality — 14 days'.
  ///
  /// In en, this message translates to:
  /// **'{title} — 14 days'**
  String progressInsightTitle14Days(String title);

  /// Column label for the current week's value in an insight card summary.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get progressThisWeek;

  /// Column label for the previous week's value in an insight card summary.
  ///
  /// In en, this message translates to:
  /// **'Last week'**
  String get progressLastWeek;

  /// Title of the risk-window card highlighting the time of day when the user logs most cravings.
  ///
  /// In en, this message translates to:
  /// **'Your tender hours'**
  String get progressTenderHoursTitle;

  /// Body text of the risk-window card. {count} of {total} cravings fall in the user's highest-risk time window.
  ///
  /// In en, this message translates to:
  /// **'{count} of your {total} logged cravings land in this window. Knowing your pattern is power — plan something gentle for those hours: a walk, a call, the urge timer.'**
  String progressTenderHoursBody(int count, int total);

  /// Button on the risk-window card that opens the pre-craving plan.
  ///
  /// In en, this message translates to:
  /// **'Review my plan'**
  String get progressReviewMyPlan;

  /// Placeholder button text shown in place of the cravings heatmap card after the user has hidden it; tapping re-enables the card.
  ///
  /// In en, this message translates to:
  /// **'Show cravings heatmap'**
  String get progressShowHeatmap;

  /// Header of the inline 28-day cravings heatmap card.
  ///
  /// In en, this message translates to:
  /// **'Cravings Heatmap'**
  String get progressCravingsHeatmapTitle;

  /// Link in the cravings heatmap card header that opens the full heatmap screen.
  ///
  /// In en, this message translates to:
  /// **'View full'**
  String get progressViewFull;

  /// Explanatory caption under the cravings heatmap header.
  ///
  /// In en, this message translates to:
  /// **'Day 1 = your first day in the app. Only cravings logged from the Home screen count.'**
  String get progressHeatmapCaption;

  /// Row label in the cravings heatmap grid, abbreviated 'Week N'.
  ///
  /// In en, this message translates to:
  /// **'Wk {number}'**
  String progressHeatmapWeekLabel(int number);

  /// Left-side legend label on the cravings heatmap color scale (fewer cravings).
  ///
  /// In en, this message translates to:
  /// **'Fewer'**
  String get progressHeatmapLegendFewer;

  /// Right-side legend label on the cravings heatmap color scale (more cravings).
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get progressHeatmapLegendMore;

  /// Title of the weekly recovery-capital card on the Insights tab (used in both empty and filled states).
  ///
  /// In en, this message translates to:
  /// **'Recovery capital — this week'**
  String get progressRecoveryCapitalTitle;

  /// Subtitle shown on the recovery-capital card when the user hasn't filled in this week's check.
  ///
  /// In en, this message translates to:
  /// **'A 30-second check across five things that protect recovery.'**
  String get progressRecoveryCapitalEmptySubtitle;

  /// Score badge on the filled recovery-capital card, e.g. '4 of 5' dimensions ticked.
  ///
  /// In en, this message translates to:
  /// **'{score} of 5'**
  String progressCapitalScore(int score);

  /// Hint at the bottom of the filled recovery-capital card indicating it can be tapped to edit.
  ///
  /// In en, this message translates to:
  /// **'Tap to edit'**
  String get progressTapToEdit;

  /// Single-letter abbreviation for Monday on the insight chart's x-axis.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get progressDayLetterMon;

  /// Single-letter abbreviation for Tuesday on the insight chart's x-axis.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get progressDayLetterTue;

  /// Single-letter abbreviation for Wednesday on the insight chart's x-axis.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get progressDayLetterWed;

  /// Single-letter abbreviation for Thursday on the insight chart's x-axis.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get progressDayLetterThu;

  /// Single-letter abbreviation for Friday on the insight chart's x-axis.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get progressDayLetterFri;

  /// Single-letter abbreviation for Saturday on the insight chart's x-axis.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get progressDayLetterSat;

  /// Single-letter abbreviation for Sunday on the insight chart's x-axis.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get progressDayLetterSun;

  /// Medical/safety disclaimer shown above the healing timeline on the Recovery screen.
  ///
  /// In en, this message translates to:
  /// **'Journey Forward is not a medical device and does not diagnose, treat, cure, or prevent any medical condition. This timeline is educational and reflects general recovery patterns only. Individual recovery varies. If you drink heavily, have a history of withdrawal, seizures, hallucinations, confusion, or feel physically unsafe, speak with a healthcare professional before stopping suddenly or seek urgent medical care.'**
  String get recoveryMedicalDisclaimer;

  /// Uppercase section label introducing the psychological/mind notes for a recovery milestone.
  ///
  /// In en, this message translates to:
  /// **'MIND'**
  String get recoveryMindLabel;

  /// Recovery milestone 1 (12 hours) — mind/psychological note.
  ///
  /// In en, this message translates to:
  /// **'You might feel a mix of relief and anxiety as your daily routine shifts. This is the normal friction of change.'**
  String get recoveryM1Mind;

  /// Recovery milestone 1 (12 hours) — what you may experience.
  ///
  /// In en, this message translates to:
  /// **'The first urges may appear. They can feel urgent, but they are temporary waves.'**
  String get recoveryM1Experience;

  /// Recovery milestone 1 (12 hours) — actionable tip.
  ///
  /// In en, this message translates to:
  /// **'Drink a large glass of water. When an urge hits, focus only on getting through the next hour.'**
  String get recoveryM1Tip;

  /// Recovery milestone 2 (24 hours) — mind/psychological note.
  ///
  /// In en, this message translates to:
  /// **'Your brain\'s reward circuitry is noticing the absence of its usual chemical trigger, which can cause irritability or a low mood.'**
  String get recoveryM2Mind;

  /// Recovery milestone 2 (24 hours) — what you may experience.
  ///
  /// In en, this message translates to:
  /// **'You may feel emotionally raw, tired, or slightly restless.'**
  String get recoveryM2Experience;

  /// Recovery milestone 2 (24 hours) — actionable tip.
  ///
  /// In en, this message translates to:
  /// **'Sleep and rest are your best allies right now. Keep your evening routine calm, quiet, and consistent.'**
  String get recoveryM2Tip;

  /// Recovery milestone 3 (48 hours) — mind/psychological note.
  ///
  /// In en, this message translates to:
  /// **'Your system is seeking balance. The intensity you feel right now is the feeling of that adjustment taking place.'**
  String get recoveryM3Mind;

  /// Recovery milestone 3 (48 hours) — what you may experience.
  ///
  /// In en, this message translates to:
  /// **'Restlessness and strong urges are common here. You might feel “wired” or on edge.'**
  String get recoveryM3Experience;

  /// Recovery milestone 3 (48 hours) — actionable tip with safety warning.
  ///
  /// In en, this message translates to:
  /// **'Be especially patient with yourself today. If you experience shaking, confusion, hallucinations, seizures, severe agitation, or feel unsafe, seek urgent medical support.'**
  String get recoveryM3Tip;

  /// Recovery milestone 4 (3 days) — mind/psychological note.
  ///
  /// In en, this message translates to:
  /// **'The mental fog often begins to thin. Neurotransmitter production starts to slowly adjust, paving the way for more natural energy.'**
  String get recoveryM4Mind;

  /// Recovery milestone 4 (3 days) — what you may experience.
  ///
  /// In en, this message translates to:
  /// **'A small window of calm may emerge. You might feel a quiet, cautious optimism taking root.'**
  String get recoveryM4Experience;

  /// Recovery milestone 4 (3 days) — actionable tip.
  ///
  /// In en, this message translates to:
  /// **'Reaching 72 hours is meaningful. Mark it with comfort, care, and support.'**
  String get recoveryM4Tip;

  /// Recovery milestone 5 (1 week) — mind/psychological note.
  ///
  /// In en, this message translates to:
  /// **'You may notice unusually vivid dreams — some people experience this as their sleep pattern settles into a new rhythm.'**
  String get recoveryM5Mind;

  /// Recovery milestone 5 (1 week) — what you may experience.
  ///
  /// In en, this message translates to:
  /// **'Improved clarity, though your mood may still naturally swing up and down.'**
  String get recoveryM5Experience;

  /// Recovery milestone 5 (1 week) — actionable tip.
  ///
  /// In en, this message translates to:
  /// **'Anchor yourself in routine. A predictable morning and evening structure is a powerful tool right now.'**
  String get recoveryM5Tip;

  /// Recovery milestone 6 (2 weeks) — mind/psychological note.
  ///
  /// In en, this message translates to:
  /// **'Concentration and short-term memory often start to feel sharper. Each healthier choice you repeat helps lay down new patterns.'**
  String get recoveryM6Mind;

  /// Recovery milestone 6 (2 weeks) — what you may experience.
  ///
  /// In en, this message translates to:
  /// **'You might start feeling surprisingly well, though random moments of emptiness are still normal.'**
  String get recoveryM6Experience;

  /// Recovery milestone 6 (2 weeks) — actionable tip.
  ///
  /// In en, this message translates to:
  /// **'This is when overconfidence can sneak in. Stay connected to your daily practices and support systems.'**
  String get recoveryM6Tip;

  /// Recovery milestone 7 (1 month) — mind/psychological note.
  ///
  /// In en, this message translates to:
  /// **'The brain systems involved in impulse control, decision-making, and emotional regulation may begin to feel steadier over time.'**
  String get recoveryM7Mind;

  /// Recovery milestone 7 (1 month) — what you may experience.
  ///
  /// In en, this message translates to:
  /// **'Emotional regulation continues to improve, and building resilience becomes a steady practice.'**
  String get recoveryM7Experience;

  /// Recovery milestone 7 (1 month) — actionable tip.
  ///
  /// In en, this message translates to:
  /// **'Review your journey so far. Note the situations that still feel tricky, and plan how you will navigate them gracefully.'**
  String get recoveryM7Tip;

  /// Recovery milestone 8 (3 months) — mind/psychological note.
  ///
  /// In en, this message translates to:
  /// **'For many people, the ability to find genuine satisfaction in simple, everyday activities slowly returns at this stage.'**
  String get recoveryM8Mind;

  /// Recovery milestone 8 (3 months) — what you may experience.
  ///
  /// In en, this message translates to:
  /// **'Many people describe feeling more like themselves again. Motivation may feel more available, though it can still rise and fall.'**
  String get recoveryM8Experience;

  /// Recovery milestone 8 (3 months) — actionable tip.
  ///
  /// In en, this message translates to:
  /// **'Continue to cultivate your environment. Hobbies, nature, and relationships are deeply protective elements of your growth.'**
  String get recoveryM8Tip;

  /// Recovery milestone 9 (6 months) — mind/psychological note.
  ///
  /// In en, this message translates to:
  /// **'Urges may become less frequent or easier to move through.'**
  String get recoveryM9Mind;

  /// Recovery milestone 9 (6 months) — what you may experience.
  ///
  /// In en, this message translates to:
  /// **'The highs and lows of early recovery begin to smooth out into a more consistent rhythm.'**
  String get recoveryM9Experience;

  /// Recovery milestone 9 (6 months) — actionable tip.
  ///
  /// In en, this message translates to:
  /// **'Take a moment to honor the quiet days. Peace and stability are among the quiet rewards of this process.'**
  String get recoveryM9Tip;

  /// Recovery milestone 10 (1 year) — mind/psychological note.
  ///
  /// In en, this message translates to:
  /// **'You have lived through many seasons, routines, and emotional moments with more awareness and care.'**
  String get recoveryM10Mind;

  /// Recovery milestone 10 (1 year) — what you may experience.
  ///
  /// In en, this message translates to:
  /// **'Support may still matter, and needing it does not diminish your progress.'**
  String get recoveryM10Experience;

  /// Recovery milestone 10 (1 year) — actionable tip.
  ///
  /// In en, this message translates to:
  /// **'Reflect on the person you were twelve months ago. Write them a letter from where you stand today.'**
  String get recoveryM10Tip;

  /// Recovery milestone 11 (2 years & beyond) — mind/psychological note.
  ///
  /// In en, this message translates to:
  /// **'Recovery may feel less like something you are forcing and more like a way of living you have grown into.'**
  String get recoveryM11Mind;

  /// Recovery milestone 11 (2 years & beyond) — actionable tip.
  ///
  /// In en, this message translates to:
  /// **'Your story may become a source of comfort for someone else. When the moment feels right, share your strength with someone just beginning their path.'**
  String get recoveryM11Tip;

  /// Dialog title and add-button label for adding a new weekly goal in the profile/settings screen.
  ///
  /// In en, this message translates to:
  /// **'Add weekly goal'**
  String get settingsAddWeeklyGoalTitle;

  /// Hint text in the add-weekly-goal dialog text field.
  ///
  /// In en, this message translates to:
  /// **'e.g. Exercise 3 times this week'**
  String get settingsWeeklyGoalHint;

  /// Snackbar shown when the user tries to enable biometric lock but no biometrics are enrolled on the device.
  ///
  /// In en, this message translates to:
  /// **'Biometrics aren\'t set up on this device. Add a fingerprint or face in your phone\'s settings, then try again.'**
  String get settingsBiometricNotSetUp;

  /// Prompt text shown by the OS biometric authentication dialog when enabling biometric app lock.
  ///
  /// In en, this message translates to:
  /// **'Confirm to enable biometric lock'**
  String get settingsBiometricConfirmReason;

  /// Error snackbar when the platform reports no biometrics are enrolled.
  ///
  /// In en, this message translates to:
  /// **'No biometrics enrolled on this device. Add a fingerprint or face in your phone\'s settings.'**
  String get settingsBiometricNotEnrolled;

  /// Error snackbar when biometric hardware is temporarily unavailable.
  ///
  /// In en, this message translates to:
  /// **'Biometric hardware is unavailable right now. Try again in a moment.'**
  String get settingsBiometricUnavailable;

  /// Error snackbar when biometric auth is temporarily locked out after failed attempts.
  ///
  /// In en, this message translates to:
  /// **'Too many failed attempts. Wait a moment and try again.'**
  String get settingsBiometricLockedOut;

  /// Error snackbar when biometric auth is permanently locked and needs the device screen lock to re-enable.
  ///
  /// In en, this message translates to:
  /// **'Biometrics are locked. Use your phone\'s screen lock to re-enable.'**
  String get settingsBiometricPermanentlyLockedOut;

  /// Generic biometric failure snackbar with the underlying platform error message.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication failed: {error}'**
  String settingsBiometricAuthFailed(String error);

  /// Snackbar shown when scheduling notification reminders fails.
  ///
  /// In en, this message translates to:
  /// **'Reminder scheduling failed. Please check notification permissions.'**
  String get settingsReminderScheduleFailed;

  /// Snackbar shown after saving notification settings while notifications are blocked at the OS level.
  ///
  /// In en, this message translates to:
  /// **'Saved — but notifications are blocked in system settings.'**
  String get settingsNotificationsBlockedSaved;

  /// Snackbar action button that deep-links to the system notification settings.
  ///
  /// In en, this message translates to:
  /// **'OPEN SETTINGS'**
  String get settingsOpenSettingsAction;

  /// Snackbar confirming notification settings were saved successfully.
  ///
  /// In en, this message translates to:
  /// **'Notification settings saved'**
  String get settingsNotificationSettingsSaved;

  /// Snackbar shown after tapping the version label five times to unlock the hidden diagnostics section.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics enabled'**
  String get settingsDiagnosticsEnabled;

  /// Diagnostic label describing a scheduled morning reminder notification.
  ///
  /// In en, this message translates to:
  /// **'Morning reminder'**
  String get settingsDiagMorningReminder;

  /// Diagnostic label describing a scheduled evening reminder notification.
  ///
  /// In en, this message translates to:
  /// **'Evening reminder'**
  String get settingsDiagEveningReminder;

  /// Diagnostic label describing a test notification entry.
  ///
  /// In en, this message translates to:
  /// **'Test notification'**
  String get settingsDiagTestNotification;

  /// Diagnostic label describing a scheduled milestone notification for a given sober day.
  ///
  /// In en, this message translates to:
  /// **'Milestone: day {day}'**
  String settingsDiagMilestoneDay(int day);

  /// Diagnostic label describing a scheduled savings milestone notification.
  ///
  /// In en, this message translates to:
  /// **'Savings milestone'**
  String get settingsDiagSavingsMilestone;

  /// Diagnostic label describing a scheduled meeting reminder notification.
  ///
  /// In en, this message translates to:
  /// **'Meeting reminder'**
  String get settingsDiagMeetingReminder;

  /// Diagnostic label for a notification whose ID does not match any known category.
  ///
  /// In en, this message translates to:
  /// **'Unknown (ID {id})'**
  String settingsDiagUnknownId(int id);

  /// Diagnostic value meaning a boolean condition is true.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get settingsDiagYes;

  /// Diagnostic value meaning a boolean condition is false.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get settingsDiagNo;

  /// Diagnostic value meaning a condition could not be determined.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get settingsDiagUnknown;

  /// Diagnostic value meaning battery optimization is not restricting the app.
  ///
  /// In en, this message translates to:
  /// **'Not restricted'**
  String get settingsDiagNotRestricted;

  /// Diagnostic value meaning battery optimization is restricting the app.
  ///
  /// In en, this message translates to:
  /// **'Restricted'**
  String get settingsDiagRestricted;

  /// Title of the diagnostics bottom sheet listing scheduled notifications.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Notifications'**
  String get settingsDiagScheduledNotificationsTitle;

  /// Diagnostic status line shown when the notification scheduler ran successfully.
  ///
  /// In en, this message translates to:
  /// **'Scheduler ran OK'**
  String get settingsDiagSchedulerRanOk;

  /// Diagnostic status line shown when the notification scheduler failed, with the error detail.
  ///
  /// In en, this message translates to:
  /// **'Scheduler error: {error}'**
  String settingsDiagSchedulerError(String error);

  /// Diagnostic row label for whether the OS allows notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications allowed'**
  String get settingsDiagNotificationsAllowed;

  /// Diagnostic row label for the battery optimization status.
  ///
  /// In en, this message translates to:
  /// **'Battery optimization'**
  String get settingsDiagBatteryOptimization;

  /// Diagnostic row label for the exact-alarm permission status.
  ///
  /// In en, this message translates to:
  /// **'Exact alarms'**
  String get settingsDiagExactAlarms;

  /// Diagnostic value meaning exact alarms are available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get settingsDiagAvailable;

  /// Diagnostic value meaning exact alarms are unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get settingsDiagUnavailable;

  /// Diagnostic value meaning the exact-alarm status is unknown or not applicable on this platform.
  ///
  /// In en, this message translates to:
  /// **'Unknown / not applicable'**
  String get settingsDiagUnknownNotApplicable;

  /// Diagnostic row label for the device timezone name.
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get settingsDiagTimezone;

  /// Diagnostic row label for the current time in the device timezone.
  ///
  /// In en, this message translates to:
  /// **'Timezone now'**
  String get settingsDiagTimezoneNow;

  /// Diagnostic row label for the number of pending scheduled notifications.
  ///
  /// In en, this message translates to:
  /// **'Pending count'**
  String get settingsDiagPendingCount;

  /// Diagnostic row label for whether the morning reminder is queued.
  ///
  /// In en, this message translates to:
  /// **'Morning queued'**
  String get settingsDiagMorningQueued;

  /// Diagnostic row label for whether the evening reminder is queued.
  ///
  /// In en, this message translates to:
  /// **'Evening queued'**
  String get settingsDiagEveningQueued;

  /// Warning shown in the diagnostics sheet when no notifications are scheduled.
  ///
  /// In en, this message translates to:
  /// **'No notifications are scheduled. Your daily reminders will not fire.'**
  String get settingsDiagNoneScheduled;

  /// Button in the diagnostics sheet that sends a test notification immediately.
  ///
  /// In en, this message translates to:
  /// **'Send test notification now'**
  String get settingsDiagSendTestNow;

  /// Snackbar confirming a diagnostic test notification was sent.
  ///
  /// In en, this message translates to:
  /// **'Test sent - you should see it within 2 seconds'**
  String get settingsDiagTestSent;

  /// Snackbar shown when a diagnostic test notification could not be sent.
  ///
  /// In en, this message translates to:
  /// **'Test failed - check notification permissions'**
  String get settingsDiagTestFailed;

  /// Button in the diagnostics sheet that opens the device battery optimization settings.
  ///
  /// In en, this message translates to:
  /// **'Open Battery Settings'**
  String get settingsDiagOpenBatterySettings;

  /// Section header above the reasons/pros/cons motivation cards in settings.
  ///
  /// In en, this message translates to:
  /// **'My Motivation'**
  String get settingsMyMotivationLabel;

  /// Collapsible card title for the user's list of reasons to quit.
  ///
  /// In en, this message translates to:
  /// **'My Reasons to Quit'**
  String get settingsReasonsToQuitTitle;

  /// Placeholder hint in the add-reason text field.
  ///
  /// In en, this message translates to:
  /// **'e.g. To be healthier'**
  String get settingsReasonsToQuitHint;

  /// Collapsible card title for the list of benefits of staying sober.
  ///
  /// In en, this message translates to:
  /// **'Pros of Sobriety'**
  String get settingsProsTitle;

  /// Placeholder hint in the add-pro text field.
  ///
  /// In en, this message translates to:
  /// **'e.g. More energy'**
  String get settingsProsHint;

  /// Collapsible card title for the list of negatives the user is leaving behind.
  ///
  /// In en, this message translates to:
  /// **'Cons I\'m Leaving Behind'**
  String get settingsConsTitle;

  /// Placeholder hint in the add-con text field.
  ///
  /// In en, this message translates to:
  /// **'e.g. Feeling anxious'**
  String get settingsConsHint;

  /// Section header above the app-lock security card.
  ///
  /// In en, this message translates to:
  /// **'App security'**
  String get settingsAppSecurityLabel;

  /// Section header above the hidden diagnostics section.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get settingsDiagnosticsLabel;

  /// Row label that opens the notification diagnostics sheet.
  ///
  /// In en, this message translates to:
  /// **'Check scheduled reminders'**
  String get settingsCheckScheduledReminders;

  /// Subtitle for the check-scheduled-reminders diagnostics row.
  ///
  /// In en, this message translates to:
  /// **'Verify alarms, permissions, and timezone'**
  String get settingsCheckScheduledRemindersSub;

  /// Section header above the About card.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutLabel;

  /// App version label shown at the bottom of settings; tapping it repeatedly unlocks diagnostics.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsVersionLabel(String version);

  /// Tappable sober-date line in the profile header, showing the formatted start date.
  ///
  /// In en, this message translates to:
  /// **'Sober since {date}'**
  String settingsSoberSinceDate(String date);

  /// Daily-spend chip in the profile header showing the formatted amount and a hint to tap to edit.
  ///
  /// In en, this message translates to:
  /// **'{amount}/day · tap to edit'**
  String settingsDailySpendChip(String amount);

  /// Pledge streak badge in the profile header showing how many calm days were pledged.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 calm day pledged} other{{count} calm days pledged}}'**
  String settingsPledgeStreakBadge(int count);

  /// Small caption under the money-saved amount in the profile header.
  ///
  /// In en, this message translates to:
  /// **'saved'**
  String get settingsSavedLabel;

  /// Progress line under the savings-goal bar showing amount saved out of the goal amount (both pre-formatted with currency).
  ///
  /// In en, this message translates to:
  /// **'{saved} of {goal}'**
  String settingsSavingsProgress(String saved, String goal);

  /// Row label to edit an existing savings goal.
  ///
  /// In en, this message translates to:
  /// **'Edit goal'**
  String get settingsEditGoal;

  /// Row label to create a savings goal when none exists.
  ///
  /// In en, this message translates to:
  /// **'Set a savings goal'**
  String get settingsSetSavingsGoal;

  /// Subtitle for the set-a-savings-goal row.
  ///
  /// In en, this message translates to:
  /// **'Track what you\'re saving up for'**
  String get settingsSetSavingsGoalSub;

  /// Row label to add an emergency contact when none exists.
  ///
  /// In en, this message translates to:
  /// **'Add emergency contact'**
  String get settingsAddEmergencyContact;

  /// Subtitle for the add-emergency-contact row.
  ///
  /// In en, this message translates to:
  /// **'Someone to reach when you need support'**
  String get settingsAddEmergencyContactSub;

  /// Empty-state text shown inside an expanded motivation card with no items.
  ///
  /// In en, this message translates to:
  /// **'No items added yet.'**
  String get settingsNoItemsYet;

  /// Lock-method option label and current-state label meaning the app opens without any lock.
  ///
  /// In en, this message translates to:
  /// **'No lock'**
  String get settingsLockNoneLabel;

  /// Subtitle for the No lock option in the security card.
  ///
  /// In en, this message translates to:
  /// **'App opens immediately'**
  String get settingsLockNoneSub;

  /// Lock-method option label and current-state label for biometric (fingerprint/face) unlock.
  ///
  /// In en, this message translates to:
  /// **'Biometric'**
  String get settingsLockBiometricLabel;

  /// Subtitle for the Biometric option in the security card.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint or face unlock'**
  String get settingsLockBiometricSub;

  /// Lock-method option label and current-state label for PIN unlock.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get settingsLockPinLabel;

  /// Subtitle for the PIN option in the security card.
  ///
  /// In en, this message translates to:
  /// **'4-digit numeric PIN'**
  String get settingsLockPinSub;

  /// Warning shown when PIN lock is active, reminding the user a forgotten PIN means data loss without a backup.
  ///
  /// In en, this message translates to:
  /// **'If you forget your PIN, your data cannot be recovered without a backup. Set one up in Profile → Backup.'**
  String get settingsLockPinRecoveryWarning;

  /// Warning shown when biometric lock is active, reminding the user that losing biometric access means data loss without a backup.
  ///
  /// In en, this message translates to:
  /// **'If you lose biometric access (factory reset, device change, etc.), your data cannot be recovered without a backup. Set one up in Profile → Backup.'**
  String get settingsLockBiometricRecoveryWarning;

  /// Section header for the records group (history, heatmap, insights, etc.) in the More card.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get settingsRecordsGroupLabel;

  /// Row label linking to the full history screen.
  ///
  /// In en, this message translates to:
  /// **'My history'**
  String get settingsMyHistory;

  /// Row label linking to the mood and craving insights tab.
  ///
  /// In en, this message translates to:
  /// **'Mood & craving insights'**
  String get settingsMoodCravingInsights;

  /// Row label linking to the milestone cards screen.
  ///
  /// In en, this message translates to:
  /// **'Milestone cards'**
  String get settingsMilestoneCards;

  /// Subtitle for the Weekly Care Summary row.
  ///
  /// In en, this message translates to:
  /// **'Create a private summary to share with someone you trust.'**
  String get settingsWeeklyCareSummarySub;

  /// Section header for the tools and app group in the More card.
  ///
  /// In en, this message translates to:
  /// **'Tools & App'**
  String get settingsToolsAppGroupLabel;

  /// Row label linking to the CBT thought tools screen.
  ///
  /// In en, this message translates to:
  /// **'CBT thought tools'**
  String get settingsCbtThoughtTools;

  /// Row label linking to the pre-craving plan screen.
  ///
  /// In en, this message translates to:
  /// **'Pre-craving plan'**
  String get settingsPreCravingPlan;

  /// Row label linking to the support/recovery groups screen.
  ///
  /// In en, this message translates to:
  /// **'Recovery groups'**
  String get settingsRecoveryGroups;

  /// Row label linking to the meeting planner screen.
  ///
  /// In en, this message translates to:
  /// **'Meeting planner'**
  String get settingsMeetingPlanner;

  /// Status title shown when the OS reports notifications are enabled.
  ///
  /// In en, this message translates to:
  /// **'System notifications enabled'**
  String get settingsSystemNotifsEnabled;

  /// Status title shown when the OS reports notifications are blocked.
  ///
  /// In en, this message translates to:
  /// **'System notifications blocked'**
  String get settingsSystemNotifsBlocked;

  /// Status subtitle shown when notifications are enabled.
  ///
  /// In en, this message translates to:
  /// **'Your reminders will appear on time.'**
  String get settingsSystemNotifsEnabledSub;

  /// Status subtitle shown when notifications are blocked at the OS level.
  ///
  /// In en, this message translates to:
  /// **'Reminders will not appear until enabled in system settings.'**
  String get settingsSystemNotifsBlockedSub;

  /// Small pill button that deep-links to system notification settings when notifications are blocked.
  ///
  /// In en, this message translates to:
  /// **'Fix it'**
  String get settingsFixItAction;

  /// Row label that opens the notification times and toggles sheet.
  ///
  /// In en, this message translates to:
  /// **'Check-in & reminders'**
  String get settingsCheckInReminders;

  /// Subtitle for the check-in & reminders row.
  ///
  /// In en, this message translates to:
  /// **'Morning & evening times'**
  String get settingsMorningEveningTimes;

  /// Row label and dialog title for the light/dark/system theme picker.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// Theme option label for light mode.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// Theme option label for dark mode.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// Theme option label meaning follow the device's system theme setting.
  ///
  /// In en, this message translates to:
  /// **'Match system'**
  String get settingsThemeSystem;

  /// Description of the light theme option in the appearance picker.
  ///
  /// In en, this message translates to:
  /// **'Warm cream — the classic Stillwater look'**
  String get settingsThemeLightHint;

  /// Description of the dark theme option in the appearance picker.
  ///
  /// In en, this message translates to:
  /// **'Dim forest tones for late nights'**
  String get settingsThemeDarkHint;

  /// Description of the match-system theme option in the appearance picker.
  ///
  /// In en, this message translates to:
  /// **'Follow your phone setting'**
  String get settingsThemeSystemHint;

  /// Toggle label for enabling/disabling haptic (vibration) feedback.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get settingsHapticFeedback;

  /// Toggle label for using imperial (miles) instead of metric units.
  ///
  /// In en, this message translates to:
  /// **'Imperial units'**
  String get settingsImperialUnits;

  /// Subtitle for the imperial units toggle.
  ///
  /// In en, this message translates to:
  /// **'Distance in miles instead of km'**
  String get settingsImperialUnitsSub;

  /// Subtitle under the Notifications title in the reminders bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Check-in and reminder schedule'**
  String get settingsCheckInReminderSchedule;

  /// Row label for the morning notification time in the reminders sheet.
  ///
  /// In en, this message translates to:
  /// **'Morning check-in'**
  String get settingsMorningCheckIn;

  /// Row label for the evening notification time in the reminders sheet.
  ///
  /// In en, this message translates to:
  /// **'Evening reminder'**
  String get settingsEveningReminder;

  /// Toggle label for daily motivation message notifications.
  ///
  /// In en, this message translates to:
  /// **'Motivation messages'**
  String get settingsMotivationMessages;

  /// Toggle label for daily reminder notifications.
  ///
  /// In en, this message translates to:
  /// **'Daily reminders'**
  String get settingsDailyReminders;

  /// Toggle label for milestone celebration notifications.
  ///
  /// In en, this message translates to:
  /// **'Milestone alerts'**
  String get settingsMilestoneAlerts;

  /// Snackbar confirming a test notification was posted; tells the user to check their notification shade.
  ///
  /// In en, this message translates to:
  /// **'Test sent — check your notification shade.'**
  String get settingsTestSentShade;

  /// Snackbar shown when a test notification could not post because notifications appear blocked.
  ///
  /// In en, this message translates to:
  /// **'Test could not post. Notifications appear to be blocked for Journey Forward.'**
  String get settingsTestCouldNotPost;

  /// Outlined button in the reminders sheet that sends a test notification.
  ///
  /// In en, this message translates to:
  /// **'Send test notification'**
  String get settingsSendTestNotification;

  /// Collapsible card header for the About section.
  ///
  /// In en, this message translates to:
  /// **'About Journey Forward'**
  String get settingsAboutTitle;

  /// Long personal letter from the developer shown in the expanded About card. Keep the paragraph breaks (\n\n) and the em-dash before the signature 'Shawn'.
  ///
  /// In en, this message translates to:
  /// **'Recovery and personal growth are rarely a straight line. Having walked a difficult road myself, I know how heavy some days can feel — and how exhausting it can be to use tools filled with noise, pressure, and distraction.\n\nWhen you are trying to heal or rebuild, the last thing you need is advertising, attention-grabbing notifications, or the worry that your deeply personal reflections are being harvested.\n\nYour recovery is not a data product.\n\nI built Journey Forward to be a quiet alternative: no ads, no accounts, no tracking analytics, and no built-in cloud sync. It is designed as a private, offline-first sanctuary for honest days and steady progress.\n\nBecause Journey Forward has no accounts, analytics, tracking, or cloud sync, I have no way of seeing how you experience the app, what feels confusing, or what features might help you most. If something is not working, or if you have an idea for a future improvement, you are welcome to contact me directly.\n\nThis app is not here to shame you, score you, or punish you for difficult moments. It is here to help you return — to your reason, your routines, your breath, and the next small step forward.\n\nI am also working toward language support, including Zulu and Afrikaans, so Journey Forward can become more welcoming while keeping its privacy-first foundation.\n\nMy hope is that this space helps you find grounding, reflection, and the grace to take one honest step at a time.\n\n— Shawn'**
  String get settingsAboutBody;

  /// Snackbar confirming the developer's contact email was copied to the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Email copied'**
  String get settingsEmailCopied;

  /// Button that opens the Play Store page to share the app.
  ///
  /// In en, this message translates to:
  /// **'Share app'**
  String get settingsShareApp;

  /// Prompt above the amount field in the daily-spend dialog.
  ///
  /// In en, this message translates to:
  /// **'How much did you spend per day?'**
  String get settingsSpendPerDayQuestion;

  /// Label above the currency-symbol chooser in the daily-spend dialog.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settingsCurrencyLabel;

  /// Title of the PIN setup dialog on the first (enter) step.
  ///
  /// In en, this message translates to:
  /// **'Set a PIN'**
  String get settingsSetAPin;

  /// Instruction on the first step of the PIN setup dialog.
  ///
  /// In en, this message translates to:
  /// **'Enter a 4-digit PIN'**
  String get settingsEnter4DigitPin;

  /// Instruction on the confirm step of the PIN setup dialog.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN again'**
  String get settingsEnterPinAgain;

  /// Snackbar shown when the user tries to pin a vision item but already has the maximum of 3 pinned.
  ///
  /// In en, this message translates to:
  /// **'You can pin up to 3 dreams — unpin one to make room.'**
  String get visionPinCapReached;

  /// Snackbar confirming a vision/dream item was marked as achieved.
  ///
  /// In en, this message translates to:
  /// **'Marked achieved. Beautiful.'**
  String get visionMarkedAchievedToast;

  /// Tooltip on the pin icon button when the vision item is currently pinned; tapping unpins it.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get visionUnpinTooltip;

  /// Tooltip on the pin icon button when the vision item is not pinned; tapping pins it to the home screen.
  ///
  /// In en, this message translates to:
  /// **'Pin to home'**
  String get visionPinTooltip;

  /// Tooltip on the achieved-toggle icon button when the vision item is achieved; tapping returns it to active goals.
  ///
  /// In en, this message translates to:
  /// **'Move back to active'**
  String get visionMoveToActiveTooltip;

  /// Tooltip on the achieved-toggle icon button to mark the vision item as achieved.
  ///
  /// In en, this message translates to:
  /// **'Mark achieved'**
  String get visionMarkAchievedTooltip;

  /// Tooltip on the edit icon button for a vision item.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get visionEditTooltip;

  /// Banner text shown at the top of an achieved vision item when no achieved date is recorded.
  ///
  /// In en, this message translates to:
  /// **'You achieved this. Beautiful.'**
  String get visionAchievedBanner;

  /// Banner text on an achieved vision item showing the date it was achieved.
  ///
  /// In en, this message translates to:
  /// **'Achieved on {date}'**
  String visionAchievedOnDate(String date);

  /// Chip label for a vision item whose target date has passed; {count} is the number of days past the target.
  ///
  /// In en, this message translates to:
  /// **'{count}d past target'**
  String visionDaysPastTarget(int count);

  /// Chip label shown when a vision item's target date is today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get visionTargetToday;

  /// Chip label counting down the days remaining until a vision item's target date.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day to go} other{{count} days to go}}'**
  String visionDaysToGo(int count);

  /// Chip label indicating a vision item is pinned to the home screen.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get visionPinnedChip;

  /// Section heading for the milestone checklist on a vision item.
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get visionMilestonesLabel;

  /// Progress subtitle showing how many milestones are completed out of the total.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} complete'**
  String visionMilestonesComplete(int done, int total);

  /// Heading for the 'why it matters' prose card on the vision detail screen.
  ///
  /// In en, this message translates to:
  /// **'Why this matters'**
  String get visionWhyItMattersHeading;

  /// Heading for the description/notes prose card on the vision detail screen.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get visionNotesHeading;

  /// Greeting heading at the top of the Emergency Toolkit home tab.
  ///
  /// In en, this message translates to:
  /// **'Your Toolkit'**
  String get emergencyToolkitHeading;

  /// Subheading under the toolkit heading on the Emergency home tab; recovery encouragement.
  ///
  /// In en, this message translates to:
  /// **'One Day at a Time'**
  String get emergencyToolkitSubheading;

  /// Label on the emergency-contact call button; {name} is the saved contact's name.
  ///
  /// In en, this message translates to:
  /// **'Call {name}'**
  String emergencyCallContact(String name);

  /// Short tile label for the HALT self-check tool (Hungry/Angry/Lonely/Tired). Keep the dotted acronym.
  ///
  /// In en, this message translates to:
  /// **'H.A.L.T.'**
  String get emergencyHaltShortLabel;

  /// Tile label for the distraction puzzle mini-game on the Emergency home tab.
  ///
  /// In en, this message translates to:
  /// **'Puzzle'**
  String get emergencyPuzzleTitle;

  /// Description under the Weekly Care Summary row on the Emergency home tab.
  ///
  /// In en, this message translates to:
  /// **'Prepare a gentle report for therapy, support, or reflection.'**
  String get emergencyWeeklyCareSummaryDesc;

  /// Small uppercase overline shown above breathing-screen titles. Keep it uppercase.
  ///
  /// In en, this message translates to:
  /// **'CALM TOOLKIT'**
  String get emergencyCalmToolkitOverline;

  /// Button label shown on the final step of a guided meditation or CBT walkthrough. Keep the ✓ checkmark.
  ///
  /// In en, this message translates to:
  /// **'Complete ✓'**
  String get emergencyComplete;

  /// Large serif title on the breathing pattern selection screen.
  ///
  /// In en, this message translates to:
  /// **'Choose your breath.'**
  String get breathChooseTitle;

  /// Subtitle under the breathing selection title.
  ///
  /// In en, this message translates to:
  /// **'A steady rhythm for this moment.'**
  String get breathChooseSubtitle;

  /// Section heading for the grid of breathing patterns on the selection screen.
  ///
  /// In en, this message translates to:
  /// **'Breathing Library'**
  String get breathLibraryTitle;

  /// Tappable link that opens the full breathing-pattern library.
  ///
  /// In en, this message translates to:
  /// **'More breathing patterns'**
  String get breathMorePatterns;

  /// Uppercase badge on the recommended breathing-pattern card. Keep it uppercase.
  ///
  /// In en, this message translates to:
  /// **'RECOMMENDED NOW'**
  String get breathRecommendedNow;

  /// Rhythm chip label for the inhale phase duration on the recommended breathing card.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get breathRhythmIn;

  /// Rhythm chip label for a breath-hold phase duration on the recommended breathing card.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get breathRhythmHold;

  /// Rhythm chip label for the exhale phase duration on the recommended breathing card.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get breathRhythmOut;

  /// Button that starts the recommended breathing session.
  ///
  /// In en, this message translates to:
  /// **'Begin'**
  String get breathBegin;

  /// Serif title at the top of the active breathing-session screen.
  ///
  /// In en, this message translates to:
  /// **'Breathe with me.'**
  String get breathSessionTitle;

  /// Calming subtitle under the breathing-session title.
  ///
  /// In en, this message translates to:
  /// **'Nothing to solve right now.'**
  String get breathSessionSubtitle;

  /// Word shown in the breathing ring before the session is started.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get breathReady;

  /// Caption under the session countdown timer (e.g. '4:32 remaining'). Lowercase.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get breathRemaining;

  /// Button that begins the breathing-session countdown.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get breathStart;

  /// Button that resumes a paused breathing session.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get breathResume;

  /// Button that pauses the active breathing session.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get breathPause;

  /// Outlined button that ends the breathing session and returns to the pattern list.
  ///
  /// In en, this message translates to:
  /// **'End session'**
  String get breathEndSession;

  /// Safety footer shown during a breathing session.
  ///
  /// In en, this message translates to:
  /// **'If you feel dizzy, return to normal breathing.'**
  String get breathDizzyWarning;

  /// Serif title on the full breathing-pattern library screen.
  ///
  /// In en, this message translates to:
  /// **'All breathing patterns.'**
  String get breathAllPatternsTitle;

  /// Subtitle under the full breathing-library title.
  ///
  /// In en, this message translates to:
  /// **'Find the rhythm that fits this moment.'**
  String get breathAllPatternsSubtitle;

  /// Uppercase badge on the Urge Surfing guided-audio player card. Keep it uppercase.
  ///
  /// In en, this message translates to:
  /// **'GUIDED AUDIO'**
  String get meditationGuidedAudioLabel;

  /// Divider label separating the audio player from the text-based guided meditation list.
  ///
  /// In en, this message translates to:
  /// **'Guided scripts'**
  String get meditationGuidedScripts;

  /// Tagline under the Urge Surfing audio title. Keep the em dash.
  ///
  /// In en, this message translates to:
  /// **'Ride the wave — urges peak and pass.'**
  String get meditationUrgeSurfingTagline;

  /// Explainer paragraph describing what urge surfing is, shown under the audio player.
  ///
  /// In en, this message translates to:
  /// **'Urge surfing: instead of fighting a craving, you observe it like a wave — it rises, peaks, and falls on its own. This guided session teaches you to ride the wave without acting on it.'**
  String get meditationUrgeSurfingExplainer;

  /// Duration label for an 8-minute guided meditation.
  ///
  /// In en, this message translates to:
  /// **'8 min'**
  String get meditationDuration8min;

  /// Duration label for a 10-minute guided meditation.
  ///
  /// In en, this message translates to:
  /// **'10 min'**
  String get meditationDuration10min;

  /// Duration label for a 12-minute guided meditation.
  ///
  /// In en, this message translates to:
  /// **'12 min'**
  String get meditationDuration12min;

  /// Duration label for a 15-minute guided meditation.
  ///
  /// In en, this message translates to:
  /// **'15 min'**
  String get meditationDuration15min;

  /// Title of the Urge Surfing guided meditation.
  ///
  /// In en, this message translates to:
  /// **'Urge Surfing'**
  String get meditationUrgeSurfingTitle;

  /// Urge Surfing meditation step 1 of 7.
  ///
  /// In en, this message translates to:
  /// **'Close your eyes and take three slow breaths.'**
  String get meditationUrgeSurfingStep0;

  /// Urge Surfing meditation step 2 of 7.
  ///
  /// In en, this message translates to:
  /// **'Notice the craving. Where do you feel it in your body?'**
  String get meditationUrgeSurfingStep1;

  /// Urge Surfing meditation step 3 of 7. Keep the em dash.
  ///
  /// In en, this message translates to:
  /// **'Imagine it as a wave in the ocean — rising slowly.'**
  String get meditationUrgeSurfingStep2;

  /// Urge Surfing meditation step 4 of 7.
  ///
  /// In en, this message translates to:
  /// **'You are a surfer. You don\'t fight the wave. You ride it.'**
  String get meditationUrgeSurfingStep3;

  /// Urge Surfing meditation step 5 of 7.
  ///
  /// In en, this message translates to:
  /// **'Watch the wave peak. It cannot go higher than it already is.'**
  String get meditationUrgeSurfingStep4;

  /// Urge Surfing meditation step 6 of 7.
  ///
  /// In en, this message translates to:
  /// **'Now watch it begin to fall. Urges always fade.'**
  String get meditationUrgeSurfingStep5;

  /// Urge Surfing meditation step 7 of 7.
  ///
  /// In en, this message translates to:
  /// **'You did not drink. The wave passed. You surfed it.'**
  String get meditationUrgeSurfingStep6;

  /// Title of the Body Scan guided meditation.
  ///
  /// In en, this message translates to:
  /// **'Body Scan'**
  String get meditationBodyScanTitle;

  /// Body Scan meditation step 1 of 7.
  ///
  /// In en, this message translates to:
  /// **'Lie down or sit comfortably. Close your eyes.'**
  String get meditationBodyScanStep0;

  /// Body Scan meditation step 2 of 7. Keep the em dash.
  ///
  /// In en, this message translates to:
  /// **'Bring attention to your feet. Notice any sensation — warmth, tingling.'**
  String get meditationBodyScanStep1;

  /// Body Scan meditation step 3 of 7.
  ///
  /// In en, this message translates to:
  /// **'Slowly move up to your calves, then knees, then thighs.'**
  String get meditationBodyScanStep2;

  /// Body Scan meditation step 4 of 7.
  ///
  /// In en, this message translates to:
  /// **'Notice your belly rising and falling with each breath.'**
  String get meditationBodyScanStep3;

  /// Body Scan meditation step 5 of 7.
  ///
  /// In en, this message translates to:
  /// **'Scan your chest, shoulders, arms, and hands.'**
  String get meditationBodyScanStep4;

  /// Body Scan meditation step 6 of 7.
  ///
  /// In en, this message translates to:
  /// **'Finally, relax your jaw, eyes, and forehead.'**
  String get meditationBodyScanStep5;

  /// Body Scan meditation step 7 of 7.
  ///
  /// In en, this message translates to:
  /// **'Rest here for a moment. You are safe. You are whole.'**
  String get meditationBodyScanStep6;

  /// Title of the Gratitude Reset guided meditation.
  ///
  /// In en, this message translates to:
  /// **'Gratitude Reset'**
  String get meditationGratitudeResetTitle;

  /// Gratitude Reset meditation step 1 of 7.
  ///
  /// In en, this message translates to:
  /// **'Sit quietly. Take three slow breaths.'**
  String get meditationGratitudeResetStep0;

  /// Gratitude Reset meditation step 2 of 7.
  ///
  /// In en, this message translates to:
  /// **'Think of one person in your life you\'re grateful for.'**
  String get meditationGratitudeResetStep1;

  /// Gratitude Reset meditation step 3 of 7.
  ///
  /// In en, this message translates to:
  /// **'What did they do or say that mattered to you?'**
  String get meditationGratitudeResetStep2;

  /// Gratitude Reset meditation step 4 of 7.
  ///
  /// In en, this message translates to:
  /// **'Think of one moment from today, however small, that was good.'**
  String get meditationGratitudeResetStep3;

  /// Gratitude Reset meditation step 5 of 7.
  ///
  /// In en, this message translates to:
  /// **'Think of something about your body or health you appreciate.'**
  String get meditationGratitudeResetStep4;

  /// Gratitude Reset meditation step 6 of 7.
  ///
  /// In en, this message translates to:
  /// **'Let gratitude fill your chest like warmth.'**
  String get meditationGratitudeResetStep5;

  /// Gratitude Reset meditation step 7 of 7.
  ///
  /// In en, this message translates to:
  /// **'Carry this feeling into your next hour.'**
  String get meditationGratitudeResetStep6;

  /// Title of the Safe Place guided meditation.
  ///
  /// In en, this message translates to:
  /// **'Safe Place'**
  String get meditationSafePlaceTitle;

  /// Safe Place meditation step 1 of 7.
  ///
  /// In en, this message translates to:
  /// **'Close your eyes. Take three slow, deep breaths.'**
  String get meditationSafePlaceStep0;

  /// Safe Place meditation step 2 of 7.
  ///
  /// In en, this message translates to:
  /// **'Imagine a place where you feel completely safe.'**
  String get meditationSafePlaceStep1;

  /// Safe Place meditation step 3 of 7. Keep the em dash.
  ///
  /// In en, this message translates to:
  /// **'It can be real or imagined — a beach, a forest, a room.'**
  String get meditationSafePlaceStep2;

  /// Safe Place meditation step 4 of 7.
  ///
  /// In en, this message translates to:
  /// **'Notice what you see, hear, smell in this place.'**
  String get meditationSafePlaceStep3;

  /// Safe Place meditation step 5 of 7.
  ///
  /// In en, this message translates to:
  /// **'Feel the ground beneath you. You are supported.'**
  String get meditationSafePlaceStep4;

  /// Safe Place meditation step 6 of 7.
  ///
  /// In en, this message translates to:
  /// **'Breathe here for a while. Nothing can harm you.'**
  String get meditationSafePlaceStep5;

  /// Safe Place meditation step 7 of 7.
  ///
  /// In en, this message translates to:
  /// **'When you\'re ready, slowly return, carrying this calm.'**
  String get meditationSafePlaceStep6;

  /// Title of the Self-Compassion guided meditation.
  ///
  /// In en, this message translates to:
  /// **'Self-Compassion'**
  String get meditationSelfCompassionTitle;

  /// Self-Compassion meditation step 1 of 7.
  ///
  /// In en, this message translates to:
  /// **'Place your hand on your heart. Feel its warmth.'**
  String get meditationSelfCompassionStep0;

  /// Self-Compassion meditation step 2 of 7. Keep the quotation marks.
  ///
  /// In en, this message translates to:
  /// **'Say: \"This is a moment of difficulty.\"'**
  String get meditationSelfCompassionStep1;

  /// Self-Compassion meditation step 3 of 7. Keep the quotation marks.
  ///
  /// In en, this message translates to:
  /// **'Say: \"Difficulty is part of life. I am not alone in this.\"'**
  String get meditationSelfCompassionStep2;

  /// Self-Compassion meditation step 4 of 7. Keep the quotation marks.
  ///
  /// In en, this message translates to:
  /// **'Say: \"May I be kind to myself right now.\"'**
  String get meditationSelfCompassionStep3;

  /// Self-Compassion meditation step 5 of 7.
  ///
  /// In en, this message translates to:
  /// **'Think of something you\'ve been critical of yourself about.'**
  String get meditationSelfCompassionStep4;

  /// Self-Compassion meditation step 6 of 7.
  ///
  /// In en, this message translates to:
  /// **'Ask: what would I say to a dear friend in this situation?'**
  String get meditationSelfCompassionStep5;

  /// Self-Compassion meditation step 7 of 7.
  ///
  /// In en, this message translates to:
  /// **'Say those words to yourself. You deserve them too.'**
  String get meditationSelfCompassionStep6;

  /// Notification title shown when the user reaches a sober-day milestone.
  ///
  /// In en, this message translates to:
  /// **'Milestone Reached'**
  String get notifMilestoneTitle;

  /// Notification title shown when the user reaches a money-saved milestone.
  ///
  /// In en, this message translates to:
  /// **'Savings Milestone'**
  String get notifSavingsTitle;

  /// Notification title for a scheduled recovery meeting / sponsor call / therapy reminder.
  ///
  /// In en, this message translates to:
  /// **'Meeting reminder'**
  String get notifMeetingTitle;

  /// Body of the diagnostic test notification fired from Settings to verify the reminder pipeline. Keep the em dash (—).
  ///
  /// In en, this message translates to:
  /// **'Test notification — your reminders are working.'**
  String get notifTestBody;

  /// Body of the savings-milestone notification. {amount} is a pre-formatted currency string (e.g. "$100").
  ///
  /// In en, this message translates to:
  /// **'You\'ve saved {amount} through sobriety. Keep going!'**
  String notifSavingsBody(String amount);

  /// Meeting-reminder notification body when no location is set. {title} is the meeting name, {time} is a 24h HH:mm clock label.
  ///
  /// In en, this message translates to:
  /// **'{title} at {time}'**
  String notifMeetingBody(String title, String time);

  /// Meeting-reminder notification body when a location is set. {title} is the meeting name, {time} is a 24h HH:mm clock label, {location} is the place. Keep the middle dot separator ( · ).
  ///
  /// In en, this message translates to:
  /// **'{title} at {time} · {location}'**
  String notifMeetingBodyLocation(String title, String time, String location);

  /// Morning daily-motivation notification body, variant 0 of 5 (chosen by day-of-year rotation).
  ///
  /// In en, this message translates to:
  /// **'Good morning. Your recovery is worth showing up for today.'**
  String get notifMorning0;

  /// Morning daily-motivation notification body, variant 1 of 5. Keep the em dash (—).
  ///
  /// In en, this message translates to:
  /// **'One day at a time. You\'ve got this — check in now.'**
  String get notifMorning1;

  /// Morning daily-motivation notification body, variant 2 of 5. Keep the em dash (—).
  ///
  /// In en, this message translates to:
  /// **'Morning check-in — Log your mood and set your intentions.'**
  String get notifMorning2;

  /// Morning daily-motivation notification body, variant 3 of 5.
  ///
  /// In en, this message translates to:
  /// **'Your sober journey continues today. Open the app and check in.'**
  String get notifMorning3;

  /// Morning daily-motivation notification body, variant 4 of 5.
  ///
  /// In en, this message translates to:
  /// **'A new day, a fresh start. Take a moment to ground yourself.'**
  String get notifMorning4;

  /// Evening daily-reminder notification body, variant 0 of 5. Keep the em dash (—).
  ///
  /// In en, this message translates to:
  /// **'You\'ve made it through another day — Log your progress.'**
  String get notifEvening0;

  /// Evening daily-reminder notification body, variant 1 of 5. Keep the em dash (—).
  ///
  /// In en, this message translates to:
  /// **'Evening check-in — How did your day go? Log it and reflect.'**
  String get notifEvening1;

  /// Evening daily-reminder notification body, variant 2 of 5.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget to log today before it slips away.'**
  String get notifEvening2;

  /// Evening daily-reminder notification body, variant 3 of 5. Keep the em dash (—).
  ///
  /// In en, this message translates to:
  /// **'Great job today — Take a moment to reflect and log your day.'**
  String get notifEvening3;

  /// Evening daily-reminder notification body, variant 4 of 5.
  ///
  /// In en, this message translates to:
  /// **'You kept going today. Log tonight before you sleep.'**
  String get notifEvening4;

  /// Body of the 1-day sober-milestone notification.
  ///
  /// In en, this message translates to:
  /// **'1 Day Sober. The first step is the hardest. You showed up.'**
  String get notifMilestone1d;

  /// Body of the 2-day sober-milestone notification.
  ///
  /// In en, this message translates to:
  /// **'2 Days Sober. Two days in a row. You\'re doing this.'**
  String get notifMilestone2d;

  /// Body of the 3-day sober-milestone notification.
  ///
  /// In en, this message translates to:
  /// **'3 Days Sober. Day three is one of the hardest. You\'re still here.'**
  String get notifMilestone3d;

  /// Body of the 5-day sober-milestone notification.
  ///
  /// In en, this message translates to:
  /// **'5 Days Sober. Five days of showing up for yourself.'**
  String get notifMilestone5d;

  /// Body of the 7-day (one week) sober-milestone notification. Keep the em dash (—).
  ///
  /// In en, this message translates to:
  /// **'7 Days Sober. One full week — that takes real courage.'**
  String get notifMilestone7d;

  /// Body of the 10-day sober-milestone notification.
  ///
  /// In en, this message translates to:
  /// **'10 Days Sober. Double digits. Quietly, steadily, you keep going.'**
  String get notifMilestone10d;

  /// Body of the 14-day (two weeks) sober-milestone notification.
  ///
  /// In en, this message translates to:
  /// **'14 Days Sober. Two weeks. Your body and mind are already responding.'**
  String get notifMilestone14d;

  /// Body of the 21-day (three weeks) sober-milestone notification.
  ///
  /// In en, this message translates to:
  /// **'21 Days Sober. Three weeks. New routines are starting to take root.'**
  String get notifMilestone21d;

  /// Body of the 30-day (one month) sober-milestone notification.
  ///
  /// In en, this message translates to:
  /// **'30 Days Sober. One month of choosing yourself, one day at a time.'**
  String get notifMilestone30d;

  /// Body of the 60-day (two months) sober-milestone notification.
  ///
  /// In en, this message translates to:
  /// **'60 Days Sober. Two months. Every single day has mattered.'**
  String get notifMilestone60d;

  /// Body of the 90-day (three months) sober-milestone notification.
  ///
  /// In en, this message translates to:
  /// **'90 Days Sober. Three months. Keep going at your own pace.'**
  String get notifMilestone90d;

  /// Body of the 180-day (half a year) sober-milestone notification.
  ///
  /// In en, this message translates to:
  /// **'180 Days Sober. Half a year. That\'s a lot of days showing up.'**
  String get notifMilestone180d;

  /// Body of the 1-year (365 days) sober-milestone notification.
  ///
  /// In en, this message translates to:
  /// **'1 Year Sober. 365 days. Take a moment to acknowledge how far you\'ve come.'**
  String get notifMilestone365d;

  /// Body of the 2-year sober-milestone notification.
  ///
  /// In en, this message translates to:
  /// **'2 Years Sober. Two years of choosing yourself, over and over again.'**
  String get notifMilestone730d;

  /// Body of the 3-year sober-milestone notification.
  ///
  /// In en, this message translates to:
  /// **'3 Years Sober. Three years. Your path forward is your own.'**
  String get notifMilestone1095d;

  /// Mood option label (mood key 'great'). Shown on the journal mood picker and entry cards.
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get moodGreat;

  /// Mood option label (mood key 'good').
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get moodGood;

  /// Mood option label (mood key 'okay').
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get moodOkay;

  /// Mood option label (mood key 'hard'). Single word — distinct from the 'Hard day' label used in History.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get moodHard;

  /// Mood option label (mood key 'crisis').
  ///
  /// In en, this message translates to:
  /// **'Crisis'**
  String get moodCrisis;

  /// Journal sub-mood word (lowercase) shown as a selectable chip after a hard/crisis mood. Slug: 'anxious'.
  ///
  /// In en, this message translates to:
  /// **'anxious'**
  String get subMoodAnxious;

  /// Journal sub-mood chip word. Slug: 'ashamed'.
  ///
  /// In en, this message translates to:
  /// **'ashamed'**
  String get subMoodAshamed;

  /// Journal sub-mood chip word. Slug: 'lonely'.
  ///
  /// In en, this message translates to:
  /// **'lonely'**
  String get subMoodLonely;

  /// Journal sub-mood chip word. Slug: 'angry'.
  ///
  /// In en, this message translates to:
  /// **'angry'**
  String get subMoodAngry;

  /// Journal sub-mood chip word. Slug: 'grieving'.
  ///
  /// In en, this message translates to:
  /// **'grieving'**
  String get subMoodGrieving;

  /// Journal sub-mood chip word. Slug: 'numb'.
  ///
  /// In en, this message translates to:
  /// **'numb'**
  String get subMoodNumb;

  /// Journal sub-mood chip word. Slug: 'overwhelmed'.
  ///
  /// In en, this message translates to:
  /// **'overwhelmed'**
  String get subMoodOverwhelmed;

  /// Journal sub-mood chip word. Slug: 'craving'.
  ///
  /// In en, this message translates to:
  /// **'craving'**
  String get subMoodCraving;

  /// Journal sub-mood word shown after a 'great' mood. Slug: 'proud'.
  ///
  /// In en, this message translates to:
  /// **'proud'**
  String get subMoodProud;

  /// Journal sub-mood chip word. Slug: 'energized'.
  ///
  /// In en, this message translates to:
  /// **'energized'**
  String get subMoodEnergized;

  /// Journal sub-mood chip word. Slug: 'peaceful'.
  ///
  /// In en, this message translates to:
  /// **'peaceful'**
  String get subMoodPeaceful;

  /// Journal sub-mood chip word. Slug: 'grateful'.
  ///
  /// In en, this message translates to:
  /// **'grateful'**
  String get subMoodGrateful;

  /// Journal sub-mood chip word. Slug: 'hopeful'.
  ///
  /// In en, this message translates to:
  /// **'hopeful'**
  String get subMoodHopeful;

  /// Journal sub-mood chip word. Slug: 'connected'.
  ///
  /// In en, this message translates to:
  /// **'connected'**
  String get subMoodConnected;

  /// Journal sub-mood chip word. Slug: 'focused'.
  ///
  /// In en, this message translates to:
  /// **'focused'**
  String get subMoodFocused;

  /// Journal sub-mood chip word. Slug: 'free'.
  ///
  /// In en, this message translates to:
  /// **'free'**
  String get subMoodFree;

  /// Journal prompt category label (id 'reflection').
  ///
  /// In en, this message translates to:
  /// **'Reflection'**
  String get promptCatReflection;

  /// Journal prompt category label (id 'gratitude').
  ///
  /// In en, this message translates to:
  /// **'Gratitude'**
  String get promptCatGratitude;

  /// Journal prompt category label (id 'hard').
  ///
  /// In en, this message translates to:
  /// **'Hard day'**
  String get promptCatHard;

  /// Journal prompt category label (id 'win').
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get promptCatWins;

  /// Journal prompt category label (id 'craving').
  ///
  /// In en, this message translates to:
  /// **'Craving'**
  String get promptCatCraving;

  /// Journal prompt category label (id 'relationships').
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get promptCatPeople;

  /// Journal reflection prompt r1.
  ///
  /// In en, this message translates to:
  /// **'What pulled at me today — and what held me steady?'**
  String get journalPromptR1;

  /// Journal reflection prompt r2.
  ///
  /// In en, this message translates to:
  /// **'If today had a colour, what would it be? Why?'**
  String get journalPromptR2;

  /// Journal reflection prompt r3.
  ///
  /// In en, this message translates to:
  /// **'What did my body tell me today that I almost ignored?'**
  String get journalPromptR3;

  /// Journal reflection prompt r4.
  ///
  /// In en, this message translates to:
  /// **'Where did I show up for myself today, even imperfectly?'**
  String get journalPromptR4;

  /// Journal reflection prompt r5.
  ///
  /// In en, this message translates to:
  /// **'What truth am I avoiding right now?'**
  String get journalPromptR5;

  /// Journal reflection prompt r6.
  ///
  /// In en, this message translates to:
  /// **'What story did I tell myself today — and was it kind, or just familiar?'**
  String get journalPromptR6;

  /// Journal reflection prompt r7.
  ///
  /// In en, this message translates to:
  /// **'What would the wisest version of me say about today?'**
  String get journalPromptR7;

  /// Journal reflection prompt r8.
  ///
  /// In en, this message translates to:
  /// **'What is one thing I am ready to set down?'**
  String get journalPromptR8;

  /// Journal reflection prompt r9.
  ///
  /// In en, this message translates to:
  /// **'What feeling have I been outrunning?'**
  String get journalPromptR9;

  /// Journal reflection prompt r10.
  ///
  /// In en, this message translates to:
  /// **'When did I feel most like myself today?'**
  String get journalPromptR10;

  /// Journal gratitude prompt g1.
  ///
  /// In en, this message translates to:
  /// **'Three small things I am grateful for right now.'**
  String get journalPromptG1;

  /// Journal gratitude prompt g2.
  ///
  /// In en, this message translates to:
  /// **'Someone who made my life easier this week — and why.'**
  String get journalPromptG2;

  /// Journal gratitude prompt g3.
  ///
  /// In en, this message translates to:
  /// **'A body part that did its job today without me noticing.'**
  String get journalPromptG3;

  /// Journal gratitude prompt g4.
  ///
  /// In en, this message translates to:
  /// **'A sound, smell, or taste that landed today.'**
  String get journalPromptG4;

  /// Journal gratitude prompt g5.
  ///
  /// In en, this message translates to:
  /// **'A thing I have now that past-me would have begged for.'**
  String get journalPromptG5;

  /// Journal gratitude prompt g6 (also a starter prompt in the empty state).
  ///
  /// In en, this message translates to:
  /// **'A small comfort that softened a hard moment.'**
  String get journalPromptG6;

  /// Journal gratitude prompt g7.
  ///
  /// In en, this message translates to:
  /// **'A piece of music, a view, a meal — what fed me today?'**
  String get journalPromptG7;

  /// Journal gratitude prompt g8.
  ///
  /// In en, this message translates to:
  /// **'Who in my life right now is steady? Name them.'**
  String get journalPromptG8;

  /// Journal gratitude prompt g9.
  ///
  /// In en, this message translates to:
  /// **'A skill I have today that I did not have a year ago.'**
  String get journalPromptG9;

  /// Journal gratitude prompt g10.
  ///
  /// In en, this message translates to:
  /// **'One ordinary moment today that I want to remember.'**
  String get journalPromptG10;

  /// Journal hard-day prompt h1.
  ///
  /// In en, this message translates to:
  /// **'What hurt today? Just name it — no fix, no spin.'**
  String get journalPromptH1;

  /// Journal hard-day prompt h2.
  ///
  /// In en, this message translates to:
  /// **'If this feeling could speak, what would it say it needs?'**
  String get journalPromptH2;

  /// Journal hard-day prompt h3.
  ///
  /// In en, this message translates to:
  /// **'What part of today felt unfair?'**
  String get journalPromptH3;

  /// Journal hard-day prompt h4.
  ///
  /// In en, this message translates to:
  /// **'Is there a feeling I am calling anger that is actually something else underneath?'**
  String get journalPromptH4;

  /// Journal hard-day prompt h5 (also a starter prompt in the empty state).
  ///
  /// In en, this message translates to:
  /// **'What would I say to a friend who was where I am right now?'**
  String get journalPromptH5;

  /// Journal hard-day prompt h6.
  ///
  /// In en, this message translates to:
  /// **'What is the smallest next step I can take, even if I do not feel like it?'**
  String get journalPromptH6;

  /// Journal hard-day prompt h7.
  ///
  /// In en, this message translates to:
  /// **'Who can I tell about this — even one person, even one sentence?'**
  String get journalPromptH7;

  /// Journal hard-day prompt h8.
  ///
  /// In en, this message translates to:
  /// **'What am I making this mean about me — and is that true?'**
  String get journalPromptH8;

  /// Journal hard-day prompt h9.
  ///
  /// In en, this message translates to:
  /// **'What did today take from me? What did it leave?'**
  String get journalPromptH9;

  /// Journal hard-day prompt h10.
  ///
  /// In en, this message translates to:
  /// **'If I could fast-forward 24 hours, what would I want to be true?'**
  String get journalPromptH10;

  /// Journal wins prompt w1.
  ///
  /// In en, this message translates to:
  /// **'A moment today I am quietly proud of.'**
  String get journalPromptW1;

  /// Journal wins prompt w2.
  ///
  /// In en, this message translates to:
  /// **'Something I did today that past-me could not have done.'**
  String get journalPromptW2;

  /// Journal wins prompt w3.
  ///
  /// In en, this message translates to:
  /// **'A risk I took — however small — and how it landed.'**
  String get journalPromptW3;

  /// Journal wins prompt w4.
  ///
  /// In en, this message translates to:
  /// **'Where did I choose myself today?'**
  String get journalPromptW4;

  /// Journal wins prompt w5.
  ///
  /// In en, this message translates to:
  /// **'A boundary I held, even if no one noticed.'**
  String get journalPromptW5;

  /// Journal wins prompt w6.
  ///
  /// In en, this message translates to:
  /// **'A craving I rode through.'**
  String get journalPromptW6;

  /// Journal wins prompt w7.
  ///
  /// In en, this message translates to:
  /// **'A conversation I am glad I had.'**
  String get journalPromptW7;

  /// Journal wins prompt w8.
  ///
  /// In en, this message translates to:
  /// **'Something I finished. Anything.'**
  String get journalPromptW8;

  /// Journal wins prompt w9.
  ///
  /// In en, this message translates to:
  /// **'A way my body felt strong today.'**
  String get journalPromptW9;

  /// Journal wins prompt w10.
  ///
  /// In en, this message translates to:
  /// **'A way I treated myself the way I would treat someone I love.'**
  String get journalPromptW10;

  /// Journal craving prompt c1.
  ///
  /// In en, this message translates to:
  /// **'When did the urge start today, and what was happening around me?'**
  String get journalPromptC1;

  /// Journal craving prompt c2.
  ///
  /// In en, this message translates to:
  /// **'What was my body doing when the craving hit?'**
  String get journalPromptC2;

  /// Journal craving prompt c3.
  ///
  /// In en, this message translates to:
  /// **'What was the lie the craving was telling me?'**
  String get journalPromptC3;

  /// Journal craving prompt c4.
  ///
  /// In en, this message translates to:
  /// **'What did I actually need underneath the craving — rest, connection, food, quiet?'**
  String get journalPromptC4;

  /// Journal craving prompt c5.
  ///
  /// In en, this message translates to:
  /// **'How long did it last before it began to pass?'**
  String get journalPromptC5;

  /// Journal craving prompt c6.
  ///
  /// In en, this message translates to:
  /// **'What did I do instead — and how do I feel about that choice now?'**
  String get journalPromptC6;

  /// Journal craving prompt c7.
  ///
  /// In en, this message translates to:
  /// **'Who or what helped me ride this one out?'**
  String get journalPromptC7;

  /// Journal craving prompt c8.
  ///
  /// In en, this message translates to:
  /// **'If this craving returns tomorrow, what is one thing I can have ready?'**
  String get journalPromptC8;

  /// Journal craving prompt c9.
  ///
  /// In en, this message translates to:
  /// **'What would the version of me a year sober say to this craving?'**
  String get journalPromptC9;

  /// Journal craving prompt c10.
  ///
  /// In en, this message translates to:
  /// **'What is the craving costing me, even when I do not use?'**
  String get journalPromptC10;

  /// Journal people/relationships prompt p1.
  ///
  /// In en, this message translates to:
  /// **'Who do I owe an honest sentence to — even if I never say it?'**
  String get journalPromptP1;

  /// Journal people/relationships prompt p2.
  ///
  /// In en, this message translates to:
  /// **'A relationship that feels lighter than it did a year ago.'**
  String get journalPromptP2;

  /// Journal people/relationships prompt p3.
  ///
  /// In en, this message translates to:
  /// **'Someone I keep replaying conversations with — what is unfinished there?'**
  String get journalPromptP3;

  /// Journal people/relationships prompt p4.
  ///
  /// In en, this message translates to:
  /// **'A person I keep meaning to reach out to — what is one sentence I could send?'**
  String get journalPromptP4;

  /// Journal people/relationships prompt p5.
  ///
  /// In en, this message translates to:
  /// **'Where do I feel most seen lately? Where do I feel most invisible?'**
  String get journalPromptP5;

  /// Journal people/relationships prompt p6.
  ///
  /// In en, this message translates to:
  /// **'What is one boundary I am proud of — even a small one?'**
  String get journalPromptP6;

  /// Journal people/relationships prompt p7.
  ///
  /// In en, this message translates to:
  /// **'Who in my life has earned more of me? Who has earned less?'**
  String get journalPromptP7;

  /// Journal people/relationships prompt p8.
  ///
  /// In en, this message translates to:
  /// **'A thing someone said to me that I am still carrying.'**
  String get journalPromptP8;

  /// Journal people/relationships prompt p9.
  ///
  /// In en, this message translates to:
  /// **'What would a healthier version of me say to the people in my life right now?'**
  String get journalPromptP9;

  /// Journal people/relationships prompt p10.
  ///
  /// In en, this message translates to:
  /// **'Who do I want to be remembered as — by the people closest to me?'**
  String get journalPromptP10;

  /// Vision-board icon-picker label (key 'guide').
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get visionIconGuide;

  /// Vision-board icon-picker label (key 'strength').
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get visionIconStrength;

  /// Vision-board icon-picker label (key 'love').
  ///
  /// In en, this message translates to:
  /// **'Love'**
  String get visionIconLove;

  /// Vision-board icon-picker label (key 'home').
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get visionIconHome;

  /// Vision-board icon-picker label (key 'family').
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get visionIconFamily;

  /// Vision-board icon-picker label (key 'savings').
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get visionIconSavings;

  /// Vision-board icon-picker label (key 'learn').
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get visionIconLearn;

  /// Vision-board icon-picker label (key 'growth').
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get visionIconGrowth;

  /// Vision-board icon-picker label (key 'journey').
  ///
  /// In en, this message translates to:
  /// **'Journey'**
  String get visionIconJourney;

  /// Vision-board icon-picker label (key 'create').
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get visionIconCreate;

  /// Vision-board icon-picker label (key 'move').
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get visionIconMove;

  /// Vision-board icon-picker label (key 'stillness').
  ///
  /// In en, this message translates to:
  /// **'Stillness'**
  String get visionIconStillness;

  /// Vision-board icon-picker label (key 'wisdom').
  ///
  /// In en, this message translates to:
  /// **'Wisdom'**
  String get visionIconWisdom;

  /// Vision-board icon-picker label (key 'aim').
  ///
  /// In en, this message translates to:
  /// **'Aim'**
  String get visionIconAim;

  /// Vision-board icon-picker label (key 'hope').
  ///
  /// In en, this message translates to:
  /// **'Hope'**
  String get visionIconHope;

  /// Vision-board icon-picker label (key 'peace').
  ///
  /// In en, this message translates to:
  /// **'Peace'**
  String get visionIconPeace;

  /// Vision-board icon-picker label (key 'support').
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get visionIconSupport;

  /// Vision-board icon-picker label (key 'bloom').
  ///
  /// In en, this message translates to:
  /// **'Bloom'**
  String get visionIconBloom;

  /// Vision-board icon-picker label (key 'milestone').
  ///
  /// In en, this message translates to:
  /// **'Milestone'**
  String get visionIconMilestone;

  /// Vision-board icon-picker label (key 'spark').
  ///
  /// In en, this message translates to:
  /// **'Spark'**
  String get visionIconSpark;

  /// Vision-board category label (VisionCategory.health).
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get visionCategoryHealth;

  /// Vision-board category label (VisionCategory.family).
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get visionCategoryFamily;

  /// Vision-board category label (VisionCategory.career).
  ///
  /// In en, this message translates to:
  /// **'Career'**
  String get visionCategoryCareer;

  /// Vision-board category label (VisionCategory.growth).
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get visionCategoryGrowth;

  /// Vision-board category label (VisionCategory.freedom).
  ///
  /// In en, this message translates to:
  /// **'Freedom'**
  String get visionCategoryFreedom;

  /// Vision-board category label (VisionCategory.adventure).
  ///
  /// In en, this message translates to:
  /// **'Adventure'**
  String get visionCategoryAdventure;

  /// Vision-board category label (VisionCategory.service).
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get visionCategoryService;

  /// Vision-board category label (VisionCategory.creativity).
  ///
  /// In en, this message translates to:
  /// **'Creativity'**
  String get visionCategoryCreativity;

  /// Vision-board category label for items with no category (VisionCategory.none).
  ///
  /// In en, this message translates to:
  /// **'Uncategorised'**
  String get visionCategoryUncategorised;

  /// Vision-board sample/seed dream title (id 'freedom_year'). Pre-fills the title field; the user can edit it.
  ///
  /// In en, this message translates to:
  /// **'One year of freedom'**
  String get visionStarterFreedomYearTitle;

  /// Vision-board sample dream affirmation (id 'freedom_year').
  ///
  /// In en, this message translates to:
  /// **'I am building a life I love, one sober day at a time.'**
  String get visionStarterFreedomYearAffirmation;

  /// Vision-board sample dream title (id 'present_parent').
  ///
  /// In en, this message translates to:
  /// **'Be the parent I want to be'**
  String get visionStarterPresentParentTitle;

  /// Vision-board sample dream affirmation (id 'present_parent').
  ///
  /// In en, this message translates to:
  /// **'I am present, patient, and proud of how I show up for my family.'**
  String get visionStarterPresentParentAffirmation;

  /// Vision-board sample dream title (id 'run_5k').
  ///
  /// In en, this message translates to:
  /// **'Run a 5K'**
  String get visionStarterRun5kTitle;

  /// Vision-board sample dream affirmation (id 'run_5k').
  ///
  /// In en, this message translates to:
  /// **'I am strong, I move with purpose, and my body is reclaiming itself.'**
  String get visionStarterRun5kAffirmation;

  /// Vision-board sample dream title (id 'save_meaningful').
  ///
  /// In en, this message translates to:
  /// **'Save for something meaningful'**
  String get visionStarterSaveMeaningfulTitle;

  /// Vision-board sample dream affirmation (id 'save_meaningful').
  ///
  /// In en, this message translates to:
  /// **'Every day sober is money in my pocket and possibility in my future.'**
  String get visionStarterSaveMeaningfulAffirmation;

  /// Vision-board sample dream title (id 'learn_skill').
  ///
  /// In en, this message translates to:
  /// **'Learn a new skill'**
  String get visionStarterLearnSkillTitle;

  /// Vision-board sample dream affirmation (id 'learn_skill').
  ///
  /// In en, this message translates to:
  /// **'I am curious, I am capable, and I keep growing.'**
  String get visionStarterLearnSkillAffirmation;

  /// Vision-board sample dream title (id 'heal_relationship').
  ///
  /// In en, this message translates to:
  /// **'Heal a relationship'**
  String get visionStarterHealRelationshipTitle;

  /// Vision-board sample dream affirmation (id 'heal_relationship').
  ///
  /// In en, this message translates to:
  /// **'I lead with honesty and humility. The right people are coming closer.'**
  String get visionStarterHealRelationshipAffirmation;

  /// Craving-response chip label (slug 'walked') — what the user did when a craving hit.
  ///
  /// In en, this message translates to:
  /// **'Walked away / outside'**
  String get cravingResponseWalked;

  /// Craving-response chip label (slug 'called').
  ///
  /// In en, this message translates to:
  /// **'Called someone'**
  String get cravingResponseCalled;

  /// Craving-response chip label (slug 'breathed').
  ///
  /// In en, this message translates to:
  /// **'Breathed / urge-surfed'**
  String get cravingResponseBreathed;

  /// Craving-response chip label (slug 'journaled').
  ///
  /// In en, this message translates to:
  /// **'Journaled / wrote'**
  String get cravingResponseJournaled;

  /// Craving-response chip label (slug 'water').
  ///
  /// In en, this message translates to:
  /// **'Drank water / ate'**
  String get cravingResponseWater;

  /// Craving-response chip label (slug 'grounded').
  ///
  /// In en, this message translates to:
  /// **'Grounded / prayed / meditated'**
  String get cravingResponseGrounded;

  /// Morning meridiem marker for the craving risk-window time label (e.g. the 'AM' in '8–11 AM').
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get cravingTimeAm;

  /// Afternoon/evening meridiem marker for the craving risk-window time label (e.g. the 'PM' in '8–11 PM').
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get cravingTimePm;

  /// A single clock hour with its AM/PM marker, e.g. '8 PM'. Used to build the craving risk-window range.
  ///
  /// In en, this message translates to:
  /// **'{hour} {meridiem}'**
  String cravingHourMeridiem(int hour, String meridiem);

  /// The user's highest-risk 3-hour craving window as a range, e.g. '8 PM–11 PM'. Separator is an en dash (–). {start} and {end} are each an hour+meridiem from cravingHourMeridiem.
  ///
  /// In en, this message translates to:
  /// **'{start}–{end}'**
  String cravingRiskWindowRange(String start, String end);

  /// Default biometric/device-auth prompt reason when re-authenticating to view a locked journal entry.
  ///
  /// In en, this message translates to:
  /// **'Unlock this entry'**
  String get journalReauthUnlockEntry;

  /// Inline error shown under the PIN field in the per-entry unlock dialog when the entered PIN is wrong.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN'**
  String get journalReauthIncorrectPin;

  /// SnackBar shown when an emergency-contact call button can't launch the phone dialer; {number} is the contact's phone number so the user can still dial it manually.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the dialer. Call {number} directly.'**
  String emergencyCallFailed(String number);

  /// Tappable crisis/help affordance shown on the lock screen before the app is unlocked.
  ///
  /// In en, this message translates to:
  /// **'Need help right now?'**
  String get lockScreenNeedHelp;

  /// SnackBar shown when a picked vision-board photo could not be copied into permanent storage, so it was not added.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save that photo. Please try again.'**
  String get visionPhotoSaveFailed;

  /// Android notification channel description shown in the system notification settings for this app.
  ///
  /// In en, this message translates to:
  /// **'Daily reminders and milestone alerts'**
  String get notifChannelDescription;

  /// Short tagline shown under the Refuge Recovery group name on the Support Groups screen.
  ///
  /// In en, this message translates to:
  /// **'Mindfulness-based recovery'**
  String get groupRefugeTagline;

  /// Description paragraph for the Refuge Recovery support group, shown when its card is expanded.
  ///
  /// In en, this message translates to:
  /// **'Uses Buddhist principles and meditation as the foundation for recovery. No requirement to be Buddhist — the focus is on compassion, mindfulness, and the causes of suffering.'**
  String get groupRefugeDesc;

  /// Approach tags for the Refuge Recovery support group, split on ' · ' into chips. Keep the ' · ' separators.
  ///
  /// In en, this message translates to:
  /// **'Mindfulness · Buddhist-informed · Meditation'**
  String get groupRefugeApproach;

  /// Where the Refuge Recovery support group is available, shown next to a location icon.
  ///
  /// In en, this message translates to:
  /// **'Worldwide · Online'**
  String get groupRefugeRegions;

  /// Short tagline shown under the Celebrate Recovery group name on the Support Groups screen.
  ///
  /// In en, this message translates to:
  /// **'Faith-based recovery'**
  String get groupCelebrateTagline;

  /// Description paragraph for the Celebrate Recovery support group, shown when its card is expanded.
  ///
  /// In en, this message translates to:
  /// **'A Christ-centred 12-step programme for hurts, habits, and hang-ups. Runs through local churches. Welcoming to anyone dealing with addiction or life struggles.'**
  String get groupCelebrateDesc;

  /// Approach tags for the Celebrate Recovery support group, split on ' · ' into chips. Keep the ' · ' separators.
  ///
  /// In en, this message translates to:
  /// **'12-step · Christian · Faith-based'**
  String get groupCelebrateApproach;

  /// Where the Celebrate Recovery support group is available, shown next to a location icon. 'SA' means South Africa.
  ///
  /// In en, this message translates to:
  /// **'Worldwide · Many SA churches'**
  String get groupCelebrateRegions;

  /// Short tagline shown under the Women for Sobriety group name on the Support Groups screen. 'WFS' is the organisation's abbreviation.
  ///
  /// In en, this message translates to:
  /// **'WFS — women-only support'**
  String get groupWfsTagline;

  /// Description paragraph for the Women for Sobriety support group, shown when its card is expanded.
  ///
  /// In en, this message translates to:
  /// **'A programme specifically for women, focusing on building positive emotions, self-worth, and a new life. Online and in-person meetings.'**
  String get groupWfsDesc;

  /// Approach tags for the Women for Sobriety support group, split on ' · ' into chips. Keep the ' · ' separators.
  ///
  /// In en, this message translates to:
  /// **'Women-only · Positive focus · Empowerment'**
  String get groupWfsApproach;

  /// Where the Women for Sobriety support group is available, shown next to a location icon.
  ///
  /// In en, this message translates to:
  /// **'Worldwide · Online'**
  String get groupWfsRegions;

  /// Short tagline shown under the LifeRing Secular Recovery group name on the Support Groups screen.
  ///
  /// In en, this message translates to:
  /// **'Non-spiritual peer support'**
  String get groupLifeRingTagline;

  /// Description paragraph for the LifeRing Secular Recovery support group, shown when its card is expanded.
  ///
  /// In en, this message translates to:
  /// **'Secular, non-religious peer support. No steps, no higher power. Focus on sobriety, secularity, and self-help. Online and in-person.'**
  String get groupLifeRingDesc;

  /// Approach tags for the LifeRing Secular Recovery support group, split on ' · ' into chips. Keep the ' · ' separators.
  ///
  /// In en, this message translates to:
  /// **'Secular · Non-12-step · Self-directed'**
  String get groupLifeRingApproach;

  /// Where the LifeRing Secular Recovery support group is available, shown next to a location icon.
  ///
  /// In en, this message translates to:
  /// **'Worldwide · Online'**
  String get groupLifeRingRegions;

  /// Short tagline shown under the Online Sobriety Communities group name on the Support Groups screen.
  ///
  /// In en, this message translates to:
  /// **'Digital support — always available'**
  String get groupOnlineTagline;

  /// Description paragraph for the Online Sobriety Communities entry, shown when its card is expanded. 'r/stopdrinking', 'SoberGrid', and 'Sober.com' are proper names — keep them as-is.
  ///
  /// In en, this message translates to:
  /// **'Communities like r/stopdrinking, SoberGrid, and Sober.com offer 24/7 peer support, accountability partners, and daily check-ins — right from your phone.'**
  String get groupOnlineDesc;

  /// Approach tags for the Online Sobriety Communities entry, split on ' · ' into chips. Keep the ' · ' separators.
  ///
  /// In en, this message translates to:
  /// **'Online · Anonymous · 24/7'**
  String get groupOnlineApproach;

  /// Where the Online Sobriety Communities are available, shown next to a location icon.
  ///
  /// In en, this message translates to:
  /// **'Global · Always online'**
  String get groupOnlineRegions;

  /// Short support-category label used to name the most-used care practice in the weekly summary reflection (e.g. 'Most used support: Journal').
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get weeklySummarySupportJournal;

  /// Short support-category label used to name the most-used care practice in the weekly summary reflection (e.g. 'Most used support: Craving support').
  ///
  /// In en, this message translates to:
  /// **'Craving support'**
  String get weeklySummarySupportCraving;

  /// Short support-category label used to name the most-used care practice in the weekly summary reflection (e.g. 'Most used support: Thought exercises').
  ///
  /// In en, this message translates to:
  /// **'Thought exercises'**
  String get weeklySummarySupportThought;

  /// Short support-category label used to name the most-used care practice in the weekly summary reflection (e.g. 'Most used support: Movement').
  ///
  /// In en, this message translates to:
  /// **'Movement'**
  String get weeklySummarySupportMovement;

  /// Short support-category label used to name the most-used care practice in the weekly summary reflection (e.g. 'Most used support: Sleep log').
  ///
  /// In en, this message translates to:
  /// **'Sleep log'**
  String get weeklySummarySupportSleep;

  /// Short support-category label used to name the most-used care practice in the weekly summary reflection (e.g. 'Most used support: Gratitude').
  ///
  /// In en, this message translates to:
  /// **'Gratitude'**
  String get weeklySummarySupportGratitude;

  /// Short support-category label used to name the most-used care practice in the weekly summary reflection (e.g. 'Most used support: Daily pledge').
  ///
  /// In en, this message translates to:
  /// **'Daily pledge'**
  String get weeklySummarySupportPledge;

  /// Fallback support-category label used in the weekly summary reflection when no single care practice stands out (e.g. 'Most used support: Various').
  ///
  /// In en, this message translates to:
  /// **'Various'**
  String get weeklySummarySupportVarious;

  /// Subtitle line under the title in the shared weekly-summary PDF header. {appName} is the app name (Journey Forward) and {range} is the formatted date range, e.g. '01 Jun 2026 – 07 Jun 2026'.
  ///
  /// In en, this message translates to:
  /// **'{appName}  •  {range}'**
  String weeklySummaryPdfHeaderLine(String appName, String range);

  /// Small italic footer line at the bottom-right of the shared weekly-summary PDF, attributing the document to the app.
  ///
  /// In en, this message translates to:
  /// **'Generated by Journey Forward'**
  String get weeklySummaryPdfGeneratedBy;

  /// No description provided for @learnedTitle.
  ///
  /// In en, this message translates to:
  /// **'What I\'ve learned'**
  String get learnedTitle;

  /// No description provided for @learnedShareButton.
  ///
  /// In en, this message translates to:
  /// **'Share my plan'**
  String get learnedShareButton;

  /// No description provided for @learnedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quiet patterns from your own check-ins — kept on this device, no judgement.'**
  String get learnedSubtitle;

  /// No description provided for @learnedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your insights are still growing'**
  String get learnedEmptyTitle;

  /// No description provided for @learnedEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'As you log how cravings go and what you did about them, this page fills with what actually works for you. Nothing to get right — just keep checking in.'**
  String get learnedEmptyBody;

  /// No description provided for @learnedEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Check in now'**
  String get learnedEmptyCta;

  /// No description provided for @learnedWorkedHeader.
  ///
  /// In en, this message translates to:
  /// **'WHAT\'S WORKED FOR YOU'**
  String get learnedWorkedHeader;

  /// No description provided for @learnedWorkedIntro.
  ///
  /// In en, this message translates to:
  /// **'When you tried these, here\'s how often the urge passed without a slip.'**
  String get learnedWorkedIntro;

  /// No description provided for @learnedWorkedStat.
  ///
  /// In en, this message translates to:
  /// **'stayed sober {sober} of {total}'**
  String learnedWorkedStat(int sober, int total);

  /// No description provided for @learnedRiskHeader.
  ///
  /// In en, this message translates to:
  /// **'YOUR TENDER HOURS'**
  String get learnedRiskHeader;

  /// No description provided for @learnedRiskBody.
  ///
  /// In en, this message translates to:
  /// **'{count} of your {total} logged cravings landed around {window}. Worth planning something steadying for then.'**
  String learnedRiskBody(int count, int total, String window);

  /// No description provided for @learnedHaltHeader.
  ///
  /// In en, this message translates to:
  /// **'WHAT\'S OFTEN UNDERNEATH'**
  String get learnedHaltHeader;

  /// No description provided for @learnedHaltBody.
  ///
  /// In en, this message translates to:
  /// **'Your cravings most often showed up when you were:'**
  String get learnedHaltBody;

  /// No description provided for @learnedTimesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 time} other{{count} times}}'**
  String learnedTimesCount(int count);

  /// No description provided for @learnedTriggersHeader.
  ///
  /// In en, this message translates to:
  /// **'YOUR COMMON TRIGGERS'**
  String get learnedTriggersHeader;

  /// No description provided for @learnedTriggersIntro.
  ///
  /// In en, this message translates to:
  /// **'The situations you\'ve named most often:'**
  String get learnedTriggersIntro;

  /// No description provided for @learnedTriggerChip.
  ///
  /// In en, this message translates to:
  /// **'{label} ×{count}'**
  String learnedTriggerChip(String label, int count);

  /// No description provided for @learnedWinsHeader.
  ///
  /// In en, this message translates to:
  /// **'YOUR WINS'**
  String get learnedWinsHeader;

  /// No description provided for @learnedWinsRidden.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 urge ridden out} other{{count} urges ridden out}}'**
  String learnedWinsRidden(int count);

  /// No description provided for @learnedWinsSober.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{stayed sober through 1 craving} other{stayed sober through {count} cravings}}'**
  String learnedWinsSober(int count);

  /// No description provided for @learnedPlanHeader.
  ///
  /// In en, this message translates to:
  /// **'YOUR PLAN WHEN A CRAVING HITS'**
  String get learnedPlanHeader;

  /// No description provided for @learnedPlanEmpty.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t written a plan yet. A few lines now can carry you through a hard moment later.'**
  String get learnedPlanEmpty;

  /// No description provided for @learnedPlanCreate.
  ///
  /// In en, this message translates to:
  /// **'Create my plan'**
  String get learnedPlanCreate;

  /// No description provided for @learnedPlanEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit plan'**
  String get learnedPlanEdit;

  /// No description provided for @learnedReasonsHeader.
  ///
  /// In en, this message translates to:
  /// **'WHY YOU\'RE DOING THIS'**
  String get learnedReasonsHeader;

  /// No description provided for @learnedFooter.
  ///
  /// In en, this message translates to:
  /// **'Slips are information, not failure. Every line here is something you learned by showing up.'**
  String get learnedFooter;

  /// No description provided for @learnedShareHeading.
  ///
  /// In en, this message translates to:
  /// **'My recovery safety plan'**
  String get learnedShareHeading;

  /// No description provided for @tippTitle.
  ///
  /// In en, this message translates to:
  /// **'TIPP — fast reset'**
  String get tippTitle;

  /// No description provided for @tippIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'When it spikes past thinking'**
  String get tippIntroTitle;

  /// No description provided for @tippIntro.
  ///
  /// In en, this message translates to:
  /// **'These four shift your body chemistry in minutes — no thinking required. Pick one and follow along.'**
  String get tippIntro;

  /// No description provided for @tippTempLabel.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get tippTempLabel;

  /// No description provided for @tippTempWhy.
  ///
  /// In en, this message translates to:
  /// **'Cold on your face slows a racing heart fast.'**
  String get tippTempWhy;

  /// No description provided for @tippTempStep1.
  ///
  /// In en, this message translates to:
  /// **'Fill a bowl with cold water, or grab a cold pack or ice.'**
  String get tippTempStep1;

  /// No description provided for @tippTempStep2.
  ///
  /// In en, this message translates to:
  /// **'Hold your breath and put your face in the cold water — or hold the cold to your eyes and cheeks — for about 30 seconds.'**
  String get tippTempStep2;

  /// No description provided for @tippTempStep3.
  ///
  /// In en, this message translates to:
  /// **'Notice your body settle as your heart rate drops. Repeat once if you need to.'**
  String get tippTempStep3;

  /// No description provided for @tippIntenseLabel.
  ///
  /// In en, this message translates to:
  /// **'Intense movement'**
  String get tippIntenseLabel;

  /// No description provided for @tippIntenseWhy.
  ///
  /// In en, this message translates to:
  /// **'A short burst burns off the surge of stress hormones.'**
  String get tippIntenseWhy;

  /// No description provided for @tippIntenseStep1.
  ///
  /// In en, this message translates to:
  /// **'Pick something you can do hard for a short burst — jumping jacks, running on the spot, fast stairs.'**
  String get tippIntenseStep1;

  /// No description provided for @tippIntenseStep2.
  ///
  /// In en, this message translates to:
  /// **'Go all-out for 1 to 5 minutes, until you\'re a little out of breath.'**
  String get tippIntenseStep2;

  /// No description provided for @tippIntenseStep3.
  ///
  /// In en, this message translates to:
  /// **'Let your breathing come back down. The urge usually drops with it.'**
  String get tippIntenseStep3;

  /// No description provided for @tippPacedLabel.
  ///
  /// In en, this message translates to:
  /// **'Paced breathing'**
  String get tippPacedLabel;

  /// No description provided for @tippPacedWhy.
  ///
  /// In en, this message translates to:
  /// **'Longer out-breaths than in-breaths switch on the body\'s calming system.'**
  String get tippPacedWhy;

  /// No description provided for @tippPacedHint.
  ///
  /// In en, this message translates to:
  /// **'Follow the circle. The out-breath is the longest part.'**
  String get tippPacedHint;

  /// No description provided for @tippBreatheIn.
  ///
  /// In en, this message translates to:
  /// **'Breathe in'**
  String get tippBreatheIn;

  /// No description provided for @tippHold.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get tippHold;

  /// No description provided for @tippBreatheOut.
  ///
  /// In en, this message translates to:
  /// **'Breathe out'**
  String get tippBreatheOut;

  /// No description provided for @tippPmrLabel.
  ///
  /// In en, this message translates to:
  /// **'Paired muscle relaxation'**
  String get tippPmrLabel;

  /// No description provided for @tippPmrWhy.
  ///
  /// In en, this message translates to:
  /// **'Tense as you breathe in, release as you breathe out — tension leaves with the breath.'**
  String get tippPmrWhy;

  /// No description provided for @tippPmrStep1.
  ///
  /// In en, this message translates to:
  /// **'Breathe in and tense a muscle group — fists, shoulders, or jaw — firmly but not to the point of pain.'**
  String get tippPmrStep1;

  /// No description provided for @tippPmrStep2.
  ///
  /// In en, this message translates to:
  /// **'Hold the tension for a few seconds while you notice it.'**
  String get tippPmrStep2;

  /// No description provided for @tippPmrStep3.
  ///
  /// In en, this message translates to:
  /// **'Breathe out and let it go all at once. Move through your body, group by group.'**
  String get tippPmrStep3;

  /// No description provided for @tippStartTimer.
  ///
  /// In en, this message translates to:
  /// **'Start 30-second timer'**
  String get tippStartTimer;

  /// No description provided for @tippTimerRemaining.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String tippTimerRemaining(int seconds);

  /// No description provided for @tippNeedMore.
  ///
  /// In en, this message translates to:
  /// **'Need more than this right now?'**
  String get tippNeedMore;

  /// No description provided for @tippCrisisButton.
  ///
  /// In en, this message translates to:
  /// **'Crisis lines'**
  String get tippCrisisButton;

  /// No description provided for @emergencyTippTitle.
  ///
  /// In en, this message translates to:
  /// **'TIPP reset'**
  String get emergencyTippTitle;

  /// No description provided for @progressLearnedCardTitle.
  ///
  /// In en, this message translates to:
  /// **'What I\'ve learned'**
  String get progressLearnedCardTitle;

  /// No description provided for @progressLearnedCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your patterns & safety plan, from your own logs'**
  String get progressLearnedCardSubtitle;

  /// No description provided for @slipSupportTryTipp.
  ///
  /// In en, this message translates to:
  /// **'Try a TIPP reset'**
  String get slipSupportTryTipp;

  /// No description provided for @slipSupportTryTippSub.
  ///
  /// In en, this message translates to:
  /// **'Fast body-based skills for when it spikes'**
  String get slipSupportTryTippSub;

  /// No description provided for @planToolkitTippLabel.
  ///
  /// In en, this message translates to:
  /// **'TIPP reset'**
  String get planToolkitTippLabel;

  /// No description provided for @planToolkitTippSub.
  ///
  /// In en, this message translates to:
  /// **'Temperature · move · breathe · release'**
  String get planToolkitTippSub;

  /// No description provided for @a11ySoberDuration.
  ///
  /// In en, this message translates to:
  /// **'{days} days, {hours} hours, {minutes} minutes, {seconds} seconds sober'**
  String a11ySoberDuration(int days, int hours, int minutes, int seconds);

  /// No description provided for @a11yCountdownDuration.
  ///
  /// In en, this message translates to:
  /// **'Starts in {days} days, {hours} hours, {minutes} minutes, {seconds} seconds'**
  String a11yCountdownDuration(int days, int hours, int minutes, int seconds);

  /// No description provided for @a11yHeatmapSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Cravings heatmap, last 28 days. None logged yet.} =1{Cravings heatmap, last 28 days. 1 logged.} other{Cravings heatmap, last 28 days. {count} logged.}}'**
  String a11yHeatmapSummary(int count);

  /// No description provided for @a11yHeatmapDayCravings.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{no cravings} =1{1 craving} other{{count} cravings}}'**
  String a11yHeatmapDayCravings(int count);

  /// No description provided for @challengeTitle.
  ///
  /// In en, this message translates to:
  /// **'100-day challenge'**
  String get challengeTitle;

  /// No description provided for @challengeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One hundred days, marked off one at a time.'**
  String get challengeSubtitle;

  /// No description provided for @challengeCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} days'**
  String challengeCountLabel(int done, int total);

  /// No description provided for @challengeHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a day to tick it off. Press and hold to add a sticker or clear it.'**
  String get challengeHint;

  /// No description provided for @challengeOnDay.
  ///
  /// In en, this message translates to:
  /// **'You\'re on day {day} of your streak.'**
  String challengeOnDay(int day);

  /// No description provided for @challengeComplete.
  ///
  /// In en, this message translates to:
  /// **'All 100 days. What a thing you\'ve done. 🏆'**
  String get challengeComplete;

  /// No description provided for @challengeStickerSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String challengeStickerSheetTitle(int day);

  /// No description provided for @challengePickSticker.
  ///
  /// In en, this message translates to:
  /// **'Choose a sticker'**
  String get challengePickSticker;

  /// No description provided for @challengeClearDay.
  ///
  /// In en, this message translates to:
  /// **'Clear this day'**
  String get challengeClearDay;

  /// No description provided for @challengeShareSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'SHARE YOUR PROGRESS'**
  String get challengeShareSectionLabel;

  /// No description provided for @challengeShareButton.
  ///
  /// In en, this message translates to:
  /// **'Share my progress'**
  String get challengeShareButton;

  /// No description provided for @challengeShareCardBrand.
  ///
  /// In en, this message translates to:
  /// **'100 DAYS SOBER'**
  String get challengeShareCardBrand;

  /// No description provided for @challengeShareText.
  ///
  /// In en, this message translates to:
  /// **'{done} of my 100 sober days, marked off. 🌱 One day at a time.'**
  String challengeShareText(int done);

  /// No description provided for @challengeReset.
  ///
  /// In en, this message translates to:
  /// **'Reset challenge'**
  String get challengeReset;

  /// No description provided for @challengeResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset the challenge?'**
  String get challengeResetTitle;

  /// No description provided for @challengeResetBody.
  ///
  /// In en, this message translates to:
  /// **'This clears every day you have marked off. Your sobriety streak and all your other data stay exactly as they are.'**
  String get challengeResetBody;

  /// No description provided for @challengeResetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get challengeResetConfirm;

  /// No description provided for @challengeResetCancel.
  ///
  /// In en, this message translates to:
  /// **'Keep my progress'**
  String get challengeResetCancel;

  /// No description provided for @challengeA11yDayDone.
  ///
  /// In en, this message translates to:
  /// **'Day {day}, marked off'**
  String challengeA11yDayDone(int day);

  /// No description provided for @challengeA11yDayTodo.
  ///
  /// In en, this message translates to:
  /// **'Day {day}, not yet marked'**
  String challengeA11yDayTodo(int day);

  /// Bottom-nav / tab label for the training & body planner.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get navPlanner;

  /// Planner sub-tab label: overview of goals and today.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get plannerTabOverview;

  /// Planner sub-tab label: the weekly plan editor.
  ///
  /// In en, this message translates to:
  /// **'Planner'**
  String get plannerTabPlanner;

  /// Planner sub-tab label: streaks and weekly progress.
  ///
  /// In en, this message translates to:
  /// **'Streaks'**
  String get plannerTabStreaks;

  /// Section heading listing the user's training/body goals.
  ///
  /// In en, this message translates to:
  /// **'My goals'**
  String get plannerMyGoals;

  /// Button to create a new planner goal.
  ///
  /// In en, this message translates to:
  /// **'Add goal'**
  String get plannerAddGoal;

  /// Empty-state shown when the planner has no goals.
  ///
  /// In en, this message translates to:
  /// **'No goals yet. Add one to start your plan.'**
  String get plannerNoGoals;

  /// Goal-type label: training for a race.
  ///
  /// In en, this message translates to:
  /// **'Race'**
  String get plannerGoalTypeRace;

  /// Goal-type label: a body-weight goal.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get plannerGoalTypeWeight;

  /// Goal-type label: a recurring fitness habit.
  ///
  /// In en, this message translates to:
  /// **'Habit'**
  String get plannerGoalTypeHabit;

  /// Goal-type label: a dated exercise/training campaign fed by any logged activity.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get plannerGoalTypeExercise;

  /// Field label for the free-text goal name.
  ///
  /// In en, this message translates to:
  /// **'Goal name'**
  String get plannerGoalNameLabel;

  /// Placeholder example for the goal-name field.
  ///
  /// In en, this message translates to:
  /// **'e.g. Two Oceans Half'**
  String get plannerGoalNameHint;

  /// Label above the exercise-goal measure picker (distance / time / sessions).
  ///
  /// In en, this message translates to:
  /// **'Track progress by'**
  String get plannerMeasureLabel;

  /// Exercise-goal measure: total distance across activities.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get plannerMeasureDistance;

  /// Exercise-goal measure: total active minutes across activities.
  ///
  /// In en, this message translates to:
  /// **'Active time'**
  String get plannerMeasureTime;

  /// Exercise-goal measure: a count of logged activities.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get plannerMeasureSessions;

  /// Field label for the exercise-goal target value.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get plannerTargetLabel;

  /// Field label for a goal's start date.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get plannerStartDateLabel;

  /// Field label for a goal's end / target date.
  ///
  /// In en, this message translates to:
  /// **'Goal date'**
  String get plannerEndDateLabel;

  /// On-track verdict: progress is ahead of where the time elapsed suggests.
  ///
  /// In en, this message translates to:
  /// **'Ahead of pace'**
  String get plannerPaceAhead;

  /// On-track verdict: progress roughly matches time elapsed.
  ///
  /// In en, this message translates to:
  /// **'On track'**
  String get plannerPaceOnTrack;

  /// On-track verdict: progress is behind where the time elapsed suggests.
  ///
  /// In en, this message translates to:
  /// **'Behind pace'**
  String get plannerPaceBehind;

  /// Shown when an exercise goal hits 100% of its target.
  ///
  /// In en, this message translates to:
  /// **'Goal reached!'**
  String get plannerGoalReached;

  /// Neutral status when a goal has no target to pace against.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get plannerInProgress;

  /// Countdown to a goal's end date.
  ///
  /// In en, this message translates to:
  /// **'{count} days left'**
  String plannerDaysLeft(int count);

  /// Adaptive weekly pace needed to finish a goal by its date.
  ///
  /// In en, this message translates to:
  /// **'~{amount} / week to finish on time'**
  String plannerPerWeekHint(String amount);

  /// Progress detail, e.g. '110 km of 200 km'.
  ///
  /// In en, this message translates to:
  /// **'{logged} of {target}'**
  String plannerLoggedOfTarget(String logged, String target);

  /// Button: soft-hide a goal without deleting its data.
  ///
  /// In en, this message translates to:
  /// **'Archive goal'**
  String get plannerArchiveGoal;

  /// Button: restore a previously archived goal.
  ///
  /// In en, this message translates to:
  /// **'Restore goal'**
  String get plannerUnarchiveGoal;

  /// Exercise discipline: running.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get plannerDisciplineRun;

  /// Exercise discipline: cycling.
  ///
  /// In en, this message translates to:
  /// **'Ride'**
  String get plannerDisciplineRide;

  /// Exercise discipline: swimming.
  ///
  /// In en, this message translates to:
  /// **'Swim'**
  String get plannerDisciplineSwim;

  /// Exercise discipline: walking.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get plannerDisciplineWalk;

  /// Exercise discipline: hiking.
  ///
  /// In en, this message translates to:
  /// **'Hike'**
  String get plannerDisciplineHike;

  /// Exercise discipline: strength / gym.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get plannerDisciplineGym;

  /// Exercise discipline: yoga / mobility.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get plannerDisciplineYoga;

  /// Exercise discipline: generic cardio / cross-training.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get plannerDisciplineCardio;

  /// Exercise discipline: anything else.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get plannerDisciplineOther;

  /// Insights metric: summed active minutes across all activities.
  ///
  /// In en, this message translates to:
  /// **'Total active time'**
  String get plannerTotalActiveTime;

  /// Insights section header above the per-discipline tiles.
  ///
  /// In en, this message translates to:
  /// **'By activity'**
  String get plannerByActivity;

  /// Count of activities in a discipline tile.
  ///
  /// In en, this message translates to:
  /// **'{count} activities'**
  String plannerActivityCount(int count);

  /// Active-time duration formatted as hours and minutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String plannerDurationHm(int hours, int minutes);

  /// Field label above the discipline picker in the manual log sheet.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get plannerActivityTypeLabel;

  /// Field label for the activity date in the manual log sheet.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get plannerActivityDateLabel;

  /// Field label for perceived effort / RPE.
  ///
  /// In en, this message translates to:
  /// **'Effort (1–10)'**
  String get plannerMetricEffort;

  /// Field label for elevation gain on a run/ride/walk/hike.
  ///
  /// In en, this message translates to:
  /// **'Elevation gain'**
  String get plannerMetricElevation;

  /// Field label for the pool length on a swim.
  ///
  /// In en, this message translates to:
  /// **'Pool length'**
  String get plannerMetricPoolLength;

  /// Section header above the gym exercise list.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get plannerStrengthExercises;

  /// Placeholder for a gym exercise name (e.g. Bench press).
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get plannerStrengthExerciseHint;

  /// Button to add another exercise row to a gym activity.
  ///
  /// In en, this message translates to:
  /// **'Add exercise'**
  String get plannerStrengthAddExercise;

  /// Field label for number of sets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get plannerStrengthSets;

  /// Field label for number of reps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get plannerStrengthReps;

  /// Field label for the weight lifted.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get plannerStrengthWeight;

  /// Abbreviation for metres.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get plannerUnitMeters;

  /// Abbreviation for feet.
  ///
  /// In en, this message translates to:
  /// **'ft'**
  String get plannerUnitFeet;

  /// Compact effort readout in history, e.g. 'RPE 7'.
  ///
  /// In en, this message translates to:
  /// **'RPE {value}'**
  String plannerEffortValue(int value);

  /// History summary of a gym activity's exercise count.
  ///
  /// In en, this message translates to:
  /// **'{count} exercises'**
  String plannerStrengthSummary(int count);

  /// Speed unit (metric) for cycling.
  ///
  /// In en, this message translates to:
  /// **'km/h'**
  String get plannerUnitSpeedKmh;

  /// Speed unit (imperial) for cycling.
  ///
  /// In en, this message translates to:
  /// **'mph'**
  String get plannerUnitSpeedMph;

  /// Swim pace unit (per 100 metres).
  ///
  /// In en, this message translates to:
  /// **'/100m'**
  String get plannerUnitPace100m;

  /// Action + screen title for sharing a training summary image.
  ///
  /// In en, this message translates to:
  /// **'Share progress'**
  String get plannerShareProgress;

  /// Heading on the shareable training-summary card.
  ///
  /// In en, this message translates to:
  /// **'My training'**
  String get plannerShareHeading;

  /// Date-range option: the last 7 days.
  ///
  /// In en, this message translates to:
  /// **'1 week'**
  String get plannerRange1Week;

  /// Date-range option: the last 14 days.
  ///
  /// In en, this message translates to:
  /// **'2 weeks'**
  String get plannerRange2Weeks;

  /// Date-range option: the last 28 days.
  ///
  /// In en, this message translates to:
  /// **'4 weeks'**
  String get plannerRange4Weeks;

  /// Date-range option: all logged activity.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get plannerRangeAll;

  /// Button to share the training summary image.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get plannerShareCta;

  /// Default text accompanying the shared training-summary image.
  ///
  /// In en, this message translates to:
  /// **'My training on Journey Forward'**
  String get plannerShareMessage;

  /// Race-distance label for a 10-kilometre race.
  ///
  /// In en, this message translates to:
  /// **'10K'**
  String get plannerRace10k;

  /// Race-distance label for a half marathon.
  ///
  /// In en, this message translates to:
  /// **'Half marathon'**
  String get plannerRaceHalf;

  /// Race-distance label for a full marathon.
  ///
  /// In en, this message translates to:
  /// **'Marathon'**
  String get plannerRaceFull;

  /// Race-distance label for the Comrades ultramarathon.
  ///
  /// In en, this message translates to:
  /// **'Comrades'**
  String get plannerRaceComrades;

  /// Progress label for a goal, e.g. '60% there'.
  ///
  /// In en, this message translates to:
  /// **'{percent}% there'**
  String plannerGoalProgress(int percent);

  /// Session-type label: an easy-paced run.
  ///
  /// In en, this message translates to:
  /// **'Easy run'**
  String get plannerSessionEasyRun;

  /// Session-type label: interval training.
  ///
  /// In en, this message translates to:
  /// **'Intervals'**
  String get plannerSessionIntervals;

  /// Session-type label: a tempo run.
  ///
  /// In en, this message translates to:
  /// **'Tempo'**
  String get plannerSessionTempo;

  /// Session-type label: a long endurance run.
  ///
  /// In en, this message translates to:
  /// **'Long run'**
  String get plannerSessionLongRun;

  /// Session-type label: a rest day.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get plannerSessionRest;

  /// Session-type label: cross-training.
  ///
  /// In en, this message translates to:
  /// **'Cross-train'**
  String get plannerSessionCrossTrain;

  /// Session-type label: a swim session.
  ///
  /// In en, this message translates to:
  /// **'Swim'**
  String get plannerSessionSwim;

  /// Session-type label: another kind of session.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get plannerSessionOther;

  /// One-line session summary, e.g. 'Long run · 18 km'.
  ///
  /// In en, this message translates to:
  /// **'{label} · {distance}'**
  String plannerSessionLine(String label, String distance);

  /// Heading for the current training week.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get plannerCurrentWeek;

  /// Action to mark a session as completed.
  ///
  /// In en, this message translates to:
  /// **'Mark complete'**
  String get plannerMarkComplete;

  /// Action to un-mark a completed session.
  ///
  /// In en, this message translates to:
  /// **'Mark incomplete'**
  String get plannerMarkIncomplete;

  /// Button to add a training session to the plan.
  ///
  /// In en, this message translates to:
  /// **'Add session'**
  String get plannerAddSession;

  /// Button to edit a training session.
  ///
  /// In en, this message translates to:
  /// **'Edit session'**
  String get plannerEditSession;

  /// Button to delete a training session.
  ///
  /// In en, this message translates to:
  /// **'Delete session'**
  String get plannerDeleteSession;

  /// Option to start from a built-in training plan.
  ///
  /// In en, this message translates to:
  /// **'Use a preset plan'**
  String get plannerUsePreset;

  /// Option to build a custom training plan.
  ///
  /// In en, this message translates to:
  /// **'Build your own'**
  String get plannerBuildYourOwn;

  /// Label for the date the training plan begins.
  ///
  /// In en, this message translates to:
  /// **'Plan start date'**
  String get plannerPlanStartDate;

  /// Name of the 10K preset training plan.
  ///
  /// In en, this message translates to:
  /// **'Couch to 10K'**
  String get plannerPreset10k;

  /// Name of the half-marathon preset training plan.
  ///
  /// In en, this message translates to:
  /// **'Half marathon build'**
  String get plannerPresetHalf;

  /// Name of the marathon preset training plan.
  ///
  /// In en, this message translates to:
  /// **'Marathon build'**
  String get plannerPresetFull;

  /// Name of the Comrades preset training plan.
  ///
  /// In en, this message translates to:
  /// **'Comrades build'**
  String get plannerPresetComrades;

  /// Label for the current training streak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get plannerCurrentStreak;

  /// Weekly completion progress, e.g. '75% of this week'.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of this week'**
  String plannerWeeklyProgress(int percent);

  /// Workouts completed versus target this week.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} workouts'**
  String plannerWorkoutsOfTarget(int done, int total);

  /// Heading for the weight / body-journey screen.
  ///
  /// In en, this message translates to:
  /// **'Body journey'**
  String get plannerBodyJourney;

  /// Label for the latest recorded weight.
  ///
  /// In en, this message translates to:
  /// **'Current weight'**
  String get plannerCurrentWeight;

  /// Label for weight change since the journey began.
  ///
  /// In en, this message translates to:
  /// **'Change since start'**
  String get plannerChangeSinceStart;

  /// Label for the target body weight.
  ///
  /// In en, this message translates to:
  /// **'Goal weight'**
  String get plannerGoalWeight;

  /// Heading for the weight-over-time chart.
  ///
  /// In en, this message translates to:
  /// **'Weight trend'**
  String get plannerWeightTrend;

  /// Button to log a new weight reading.
  ///
  /// In en, this message translates to:
  /// **'Add weight entry'**
  String get plannerAddWeightEntry;

  /// Label for an optional note on a weight entry.
  ///
  /// In en, this message translates to:
  /// **'Reflection'**
  String get plannerWeightReflection;

  /// Label for a weight milestone marker.
  ///
  /// In en, this message translates to:
  /// **'Milestone'**
  String get plannerWeightMilestone;

  /// Caption noting the start date of a weight comparison.
  ///
  /// In en, this message translates to:
  /// **'Since {date}'**
  String plannerWeightSince(String date);

  /// Unit abbreviation for kilograms.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get plannerUnitKg;

  /// Unit abbreviation for pounds.
  ///
  /// In en, this message translates to:
  /// **'lb'**
  String get plannerUnitLb;

  /// Pace unit: minutes per kilometre.
  ///
  /// In en, this message translates to:
  /// **'min/km'**
  String get plannerUnitPaceKm;

  /// Pace unit: minutes per mile.
  ///
  /// In en, this message translates to:
  /// **'min/mi'**
  String get plannerUnitPaceMi;

  /// Settings toggle to display weight in pounds instead of kilograms.
  ///
  /// In en, this message translates to:
  /// **'Use pounds (lb)'**
  String get settingsImperialWeight;

  /// Sub-label for the imperial-weight settings toggle.
  ///
  /// In en, this message translates to:
  /// **'Show weight in lb instead of kg'**
  String get settingsImperialWeightSub;

  /// Button to link a Strava account.
  ///
  /// In en, this message translates to:
  /// **'Connect Strava'**
  String get plannerConnectStrava;

  /// Message shown when Strava API credentials are absent.
  ///
  /// In en, this message translates to:
  /// **'Strava isn\'t set up in this build.'**
  String get plannerStravaNotConfigured;

  /// Attribution required by Strava's brand guidelines.
  ///
  /// In en, this message translates to:
  /// **'Powered by Strava'**
  String get plannerPoweredByStrava;

  /// Title of the Strava privacy explainer.
  ///
  /// In en, this message translates to:
  /// **'About Strava sync'**
  String get plannerStravaPrivacyTitle;

  /// Body of the Strava privacy explainer.
  ///
  /// In en, this message translates to:
  /// **'Your activities are fetched directly from Strava to your phone. Journey Forward has no server and never sees your account.'**
  String get plannerStravaPrivacyBody;

  /// Note that Strava access is read-only.
  ///
  /// In en, this message translates to:
  /// **'Read-only access'**
  String get plannerStravaReadOnly;

  /// Note that the Strava connection is phone-to-Strava.
  ///
  /// In en, this message translates to:
  /// **'Direct device connection'**
  String get plannerStravaDirect;

  /// Note that no Journey Forward server is involved in Strava sync.
  ///
  /// In en, this message translates to:
  /// **'No server involved'**
  String get plannerStravaNoServer;

  /// Button to unlink the Strava account.
  ///
  /// In en, this message translates to:
  /// **'Disconnect Strava'**
  String get plannerStravaDisconnect;

  /// Confirmation after importing Strava activities.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} activities'**
  String plannerStravaImported(int count);

  /// Message shown when Strava returns a rate-limit error.
  ///
  /// In en, this message translates to:
  /// **'Strava is rate-limiting requests. Try again later.'**
  String get plannerStravaRateLimited;

  /// Activity-source label: entered by hand.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get plannerSourceManual;

  /// Activity-source label: imported from Strava.
  ///
  /// In en, this message translates to:
  /// **'Strava'**
  String get plannerSourceStrava;

  /// Heading for the activity history screen.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get plannerHistory;

  /// Heading for the training insights screen.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get plannerInsights;

  /// Heading for the distance-over-time chart.
  ///
  /// In en, this message translates to:
  /// **'Distance trend'**
  String get plannerDistanceTrend;

  /// Heading for the weekly training-volume chart.
  ///
  /// In en, this message translates to:
  /// **'Weekly volume'**
  String get plannerWeeklyVolume;

  /// Label for average pace across activities.
  ///
  /// In en, this message translates to:
  /// **'Average pace'**
  String get plannerAvgPace;

  /// Label for the average heart-rate input field (in bpm) on a logged activity.
  ///
  /// In en, this message translates to:
  /// **'Avg heart rate'**
  String get plannerAvgHeartRate;

  /// Label for the free-text field naming what a habit goal counts, e.g. 'sessions'.
  ///
  /// In en, this message translates to:
  /// **'Metric (what you\'re counting)'**
  String get plannerHabitMetricLabel;

  /// Label for the numeric target-value field of a habit goal.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get plannerHabitTargetLabel;

  /// Label for cumulative distance covered.
  ///
  /// In en, this message translates to:
  /// **'Total distance'**
  String get plannerTotalDistance;

  /// Empty-state for the activity history / insights.
  ///
  /// In en, this message translates to:
  /// **'No activities logged yet.'**
  String get plannerNoActivities;

  /// Home-screen card title for today's planned training session.
  ///
  /// In en, this message translates to:
  /// **'Today\'s session'**
  String get homeTodaySessionTitle;

  /// Home-screen label shown when today is a planned rest day.
  ///
  /// In en, this message translates to:
  /// **'Rest day'**
  String get homeRestDay;

  /// Home-screen button opening the training planner.
  ///
  /// In en, this message translates to:
  /// **'Open planner'**
  String get homeTodaySessionCta;

  /// Screen-reader label for a completed workout day.
  ///
  /// In en, this message translates to:
  /// **'Workout done'**
  String get plannerA11yDayDone;

  /// Screen-reader label for a planned (not yet done) workout day.
  ///
  /// In en, this message translates to:
  /// **'Workout planned'**
  String get plannerA11yDayTodo;

  /// Screen-reader label for the weekly-progress ring.
  ///
  /// In en, this message translates to:
  /// **'{percent} percent of weekly goal complete'**
  String plannerA11yProgressRing(int percent);

  /// Prefix showing what a session originally planned, e.g. 'Planned: 10 km · 60 min'.
  ///
  /// In en, this message translates to:
  /// **'Planned: {value}'**
  String plannerPlannedPrefix(String value);

  /// Title of the close-off sheet where the user logs what they actually did.
  ///
  /// In en, this message translates to:
  /// **'How did it go?'**
  String get plannerLogSessionTitle;

  /// Section header above the actual distance/time inputs in the close-off sheet.
  ///
  /// In en, this message translates to:
  /// **'What you actually did'**
  String get plannerLogActualHeader;

  /// Primary button: log the session as done with the entered actuals.
  ///
  /// In en, this message translates to:
  /// **'Log session'**
  String get plannerLogSessionCta;

  /// Secondary button: mark the session skipped without logging an activity.
  ///
  /// In en, this message translates to:
  /// **'Mark as skipped'**
  String get plannerSkipSessionCta;

  /// Badge/label for a session the user skipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get plannerSkippedLabel;

  /// Edit-sheet button that opens the close-off flow (log actuals or skip).
  ///
  /// In en, this message translates to:
  /// **'Close off session'**
  String get plannerCloseOffCta;

  /// Action to reopen a completed or skipped session back to a pending to-do.
  ///
  /// In en, this message translates to:
  /// **'Reopen session'**
  String get plannerReopenSession;

  /// Goal-card window line showing the training-start and goal dates.
  ///
  /// In en, this message translates to:
  /// **'Training {start} → Goal {goal}'**
  String plannerTimelineRange(String start, String goal);

  /// Goal-card window line when only a goal date is set (no training-start date).
  ///
  /// In en, this message translates to:
  /// **'Goal {goal}'**
  String plannerTimelineGoalOnly(String goal);

  /// Countdown readout when the goal date is in the past.
  ///
  /// In en, this message translates to:
  /// **'Goal date passed'**
  String get plannerGoalDatePassed;

  /// Countdown readout when the goal date is today.
  ///
  /// In en, this message translates to:
  /// **'Goal day is today'**
  String get plannerGoalDayToday;

  /// Countdown readout when exactly one day remains to the goal date.
  ///
  /// In en, this message translates to:
  /// **'1 day left'**
  String get plannerOneDayLeft;

  /// Hint shown when the goal's training-start date is still in the future.
  ///
  /// In en, this message translates to:
  /// **'Training hasn\'t started yet'**
  String get plannerTrainingNotStarted;

  /// Caption above the goal's target/volume progress bar.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get plannerTargetCaption;

  /// Screen-reader label for a skipped workout day.
  ///
  /// In en, this message translates to:
  /// **'Workout skipped'**
  String get plannerA11yDaySkipped;

  /// Screen-reader/tooltip label for the calendar's previous-month button.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get plannerPrevMonth;

  /// Screen-reader/tooltip label for the calendar's next-month button.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get plannerNextMonth;

  /// Count of sessions on a calendar day (e.g. for a day holding several).
  ///
  /// In en, this message translates to:
  /// **'{count} sessions'**
  String plannerSessionsCount(int count);

  /// Section header in the goal editor for planning the goal's own sessions.
  ///
  /// In en, this message translates to:
  /// **'Training sessions'**
  String get plannerSessionsSectionLabel;

  /// Empty-state shown when a goal (or day) has no planned sessions.
  ///
  /// In en, this message translates to:
  /// **'No sessions planned yet'**
  String get plannerNoSessionsYet;

  /// Week heading in a goal's plan view (relative to training start).
  ///
  /// In en, this message translates to:
  /// **'Week {number}'**
  String plannerWeekLabel(int number);

  /// Health/safety disclaimer shown at the bottom of the planner overview.
  ///
  /// In en, this message translates to:
  /// **'Before starting any fitness or health activity, make sure you\'re fit to do so. If in doubt, check with your GP or a qualified health professional.'**
  String get plannerHealthDisclaimer;

  /// Hint for the notes field when PLANNING a session (forward-looking workout detail, not an after-the-fact reflection).
  ///
  /// In en, this message translates to:
  /// **'Session plan (optional) - e.g. 8 x 400m, 200m jog recoveries'**
  String get plannerSessionNotesHint;
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
      <String>['af', 'en', 'es', 'pt', 'zu'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'af':
      return AppLocalizationsAf();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
    case 'zu':
      return AppLocalizationsZu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
