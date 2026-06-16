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
