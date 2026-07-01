// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get errorBoundaryMessage =>
      'Something went wrong loading this screen.\nPlease restart the app.';

  @override
  String get welcomeShawnTitle => 'A note from Shawn';

  @override
  String get welcomeShawnBody =>
      'Hi, I\'m Shawn. I built this app, and I\'m rooting for you. Take some time to look at your profile and set up your reasons — it\'s how you\'ll get the most from the app. I\'m with you. I\'m on the same journey.';

  @override
  String get welcomeShawnButton => 'I\'m in';

  @override
  String get plannerSwimUnitMetres => 'Metres';

  @override
  String get plannerSwimUnitPool25 => '25 m pool';

  @override
  String get plannerSwimUnitPool50 => '50 m pool';

  @override
  String get plannerSwimLapsUnit => 'laps';

  @override
  String plannerPaceLabel(String unit) {
    return 'Pace ($unit)';
  }

  @override
  String get plannerSessionNotesHintSwim =>
      'Session plan (optional) - e.g. 8 x 100m, 20s rest';

  @override
  String get plannerSessionNotesHintCross =>
      'Session plan (optional) - e.g. 30 min cycling, zone 2';

  @override
  String get plannerSessionNotesHintRest =>
      'Rest day (optional) - e.g. stretch, early night';

  @override
  String get plannerSessionNotesHintOther => 'Session plan (optional)';

  @override
  String get plannerSessionOtherNameLabel => 'What is it?';

  @override
  String get plannerSessionOtherNameHint => 'e.g. Yoga, cycling, climbing';

  @override
  String get appTitle => 'Journey Forward';

  @override
  String get navHome => 'Home';

  @override
  String get navProgress => 'Progress';

  @override
  String get navToolkit => 'Toolkit';

  @override
  String get navJournal => 'Journal';

  @override
  String get navProfile => 'Profile';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonBack => 'Back';

  @override
  String get commonNext => 'Next';

  @override
  String get commonRestore => 'Restore';

  @override
  String get commonClear => 'Clear';

  @override
  String get commonCopied => 'Copied to clipboard';

  @override
  String commonDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String commonMinutes(int count) {
    return '$count minutes';
  }

  @override
  String commonMin(int count) {
    return '$count min';
  }

  @override
  String get lockAppName => 'Journey Forward';

  @override
  String get lockAuthenticateSubtitle => 'Authenticate to continue';

  @override
  String get lockTapToAuthenticate => 'Tap to authenticate';

  @override
  String get lockEnterYourPin => 'Enter your PIN';

  @override
  String get lockUsePinInstead => 'Use PIN instead';

  @override
  String get lockIncorrectPin => 'Incorrect PIN. Try again.';

  @override
  String get lockBiometricsNotAvailable =>
      'Biometrics not available on this device.';

  @override
  String get lockAuthCancelled => 'Authentication cancelled.';

  @override
  String get lockUnlockReason => 'Unlock Journey Forward';

  @override
  String get lockTooManyAttempts => 'Too many attempts. Try again later.';

  @override
  String get lockPermanentlyLockedOut =>
      'Biometrics locked. Restart your device.';

  @override
  String get lockBiometricsUnavailable => 'Biometrics unavailable.';

  @override
  String get lockAuthFailed => 'Authentication failed.';

  @override
  String get lockNotEnrolled => 'No biometrics enrolled. Use your device PIN.';

  @override
  String onbStepIndicator(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get onbContinue => 'Continue';

  @override
  String get onbBeginMyJourney => 'Begin my journey';

  @override
  String get onbLetsBegin => 'Let\'s begin';

  @override
  String get onbWelcomeTitle => 'A new chapter\nbegins.';

  @override
  String get onbWelcomeBody =>
      'Journey Forward is your private, on-device companion for building a sober life — one day at a time.';

  @override
  String get onbPrivacy100OnDevice => '100% on-device';

  @override
  String get onbPrivacy100OnDeviceSub =>
      'Your data stays on this phone unless you choose to export it';

  @override
  String get onbPrivacyNoAccount => 'No account needed';

  @override
  String get onbPrivacyNoAccountSub => 'No email, no sign-up, no cloud';

  @override
  String get onbPrivacyZeroTracking => 'Zero tracking';

  @override
  String get onbPrivacyZeroTrackingSub =>
      'No analytics, no ads, no data collection';

  @override
  String get onbNameHeadline => 'What should\nwe call you?';

  @override
  String get onbNameSub =>
      'Your name stays private — only shown within this app.';

  @override
  String get onbNameHint => 'Your name';

  @override
  String get onbJourneyTitle => 'What are you stepping away from?';

  @override
  String get onbJourneySub =>
      'This helps Journey Forward speak to your journey — your healing timeline, your milestones. You can skip it or change it any time in Settings.';

  @override
  String get onbJourneyPrivacyNote =>
      'Like everything in this app, your answer never leaves your phone.';

  @override
  String get homeBackupNudge =>
      'Beautiful milestone — a 2-minute backup keeps it safe forever.';

  @override
  String get homeBackupNudgeAction => 'Back up';

  @override
  String get backupReminderTitle => 'Protect your progress';

  @override
  String get backupReminderBody =>
      'It\'s been a while since your last backup. Save a copy so a new or lost phone never costs you your streak.';

  @override
  String get backupReminderDismiss => 'Dismiss';

  @override
  String get onbNameError => 'Please enter your name.';

  @override
  String get onbDateHeadline => 'When did your\njourney begin?';

  @override
  String get onbDateSub =>
      'Already started? Pick that day. Planning ahead? Choose a future date and we\'ll count down to it. You can change this anytime.';

  @override
  String get onbDatePickerHelp => 'Choose your start date';

  @override
  String get onbSoberSince => 'Sober since';

  @override
  String onbDaysOfCourage(int count) {
    return '$count days of courage';
  }

  @override
  String get onbDaysOfCourageLabel => 'days of courage';

  @override
  String get onbSpendHeadline => 'What did\nalcohol cost you?';

  @override
  String get onbSpendSub =>
      'Your daily spend lets us show how much you\'re reclaiming. Leave it at 0 to skip — this calculation stays on your device.';

  @override
  String get onbSpendAmountHint => 'Amount per day';

  @override
  String onbSpendSavingsPreview(String currency, String amount) {
    return 'In 30 days you\'d save $currency$amount';
  }

  @override
  String get onbSpendSkipNote =>
      'You can always add this later in your profile settings.';

  @override
  String get onbSecurityHeadline => 'Protect\nyour space.';

  @override
  String get onbSecuritySub =>
      'Lock methods run 100% on-device — your PIN never touches a server.';

  @override
  String get onbSecurityNoLockLabel => 'No lock';

  @override
  String get onbSecurityNoLockSub => 'Open straight to your journey';

  @override
  String get onbSecurityBiometricLabel => 'Biometric';

  @override
  String get onbSecurityBiometricSub =>
      'Face ID or fingerprint — fastest and most private';

  @override
  String get onbSecurityPinLabel => '4-digit PIN';

  @override
  String get onbSecurityPinSub =>
      'Your PIN is salted, hashed, and stored in your device\'s encrypted storage';

  @override
  String get onbPinCreateHeadline => 'Create\nyour PIN.';

  @override
  String get onbPinConfirmHeadline => 'Confirm\nyour PIN.';

  @override
  String get onbPinCreateSub =>
      'Your PIN is salted and hashed, then stored in your device\'s encrypted storage — never in plaintext, never in the cloud.';

  @override
  String get onbPinConfirmSub => 'Enter the same 4 digits to confirm.';

  @override
  String get onbPinConfirmButton => 'Confirm PIN';

  @override
  String get onbPinDigitsError => 'Enter all 4 digits.';

  @override
  String get onbPinMismatchError => 'PINs don\'t match. Try again.';

  @override
  String get onbNotifHeadline => 'Daily\nsupport.';

  @override
  String get onbNotifSub =>
      'All notifications are local — your phone generates them, no server involved.';

  @override
  String get onbNotifPrivacyNote =>
      'Notifications fire from your device. No push servers. No data leaves your phone.';

  @override
  String get onbNotifMorningLabel => 'Morning motivation';

  @override
  String get onbNotifMorningSub => 'A daily affirmation to start strong';

  @override
  String get onbNotifEveningLabel => 'Evening check-in';

  @override
  String get onbNotifEveningSub => 'An evening reminder to reflect';

  @override
  String get onbNotifMilestonesLabel => 'Milestone alerts';

  @override
  String get onbNotifMilestonesSub => 'Celebrate 1 day, 1 week, 30 days…';

  @override
  String get onbNotifMorningTime => 'Morning time';

  @override
  String get onbNotifEveningTime => 'Evening time';

  @override
  String get onbNotifChangeAnytime =>
      'You can change these anytime in Settings.';

  @override
  String onbFinishReadyWithName(String name) {
    return 'You\'re ready, $name! 🌿';
  }

  @override
  String get onbFinishReady => 'You\'re ready! 🌿';

  @override
  String onbFinishBodyDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'You\'ve already been on this journey for $_temp0. Every single one matters.';
  }

  @override
  String get onbFinishBodyToday =>
      'Your journey starts right now. You\'ve got this.';

  @override
  String get onbFinishPrivacyNote =>
      'Your journey lives only on this device — private, secure, and completely yours.';

  @override
  String get homeFriendFallback => 'friend';

  @override
  String homeGreetingFirst(String name) {
    return 'Hi $name,';
  }

  @override
  String homeGreetingReturning(String name) {
    return 'Welcome back, $name.';
  }

  @override
  String get homeTagline => 'Every day forward is a win.';

  @override
  String homeErrorPrefix(String message) {
    return 'Error: $message';
  }

  @override
  String get homeDaysSober => 'DAYS SOBER';

  @override
  String get homeDaysLabel => 'days';

  @override
  String get homeSerenityTagline => 'A clearer mind.\nA stronger you.';

  @override
  String get homeMoneyReclaimed => 'MONEY\nRECLAIMED';

  @override
  String get homeMoneyAllTime => 'All time';

  @override
  String get homeMoneyInvesting => 'You\'re investing in\nyour future self.';

  @override
  String homeMoneyGoalSavedOf(String saved, String goal) {
    return '$saved saved of $goal goal';
  }

  @override
  String homeMoneyGoalPercent(int percent) {
    return '$percent% complete';
  }

  @override
  String get homeMoneyGoalClear => 'Clear goal';

  @override
  String get homeMyReasonTitle => 'My Reason';

  @override
  String get homeMyReasonRotates => 'rotates daily';

  @override
  String get homeMyReasonAddPrompt => 'Add your reasons\nin Profile';

  @override
  String get homeYourJourney => 'YOUR JOURNEY';

  @override
  String get homeJourneySubtitle => 'Milestones are ahead. Keep going.';

  @override
  String get homeMilestoneNode0Label => 'First hours';

  @override
  String get homeMilestoneNode1Label => 'Clear morning';

  @override
  String get homeMilestoneNode2Label => 'Energy returns';

  @override
  String get homeMilestoneNode3Label => 'Mind healing';

  @override
  String get homeMilestoneNode4Label => 'A new chapter';

  @override
  String get homeMilestoneTimingDone => 'done';

  @override
  String get homeDailyPledge => 'DAILY PLEDGE';

  @override
  String get homePledgeHint => 'e.g., Today I choose clarity.';

  @override
  String homePledgeCalmDays(int count) {
    return '$count calm days kept';
  }

  @override
  String get homeDailyGratitude => 'DAILY GRATITUDE';

  @override
  String get homeGratitudeHint =>
      'e.g., I\'m grateful for\nanother fresh start.';

  @override
  String get homeGratitudeLoggedToday => 'Logged today';

  @override
  String get homeWeeklyGoals => 'Weekly Goals';

  @override
  String homeWeeklyGoalsProgress(int done, int total) {
    return '$done of $total';
  }

  @override
  String get homeWeeklyGoalsResetHint =>
      'Each Sunday, completed goals move to your history and clear — unfinished ones carry over.';

  @override
  String get homeWeeklyGoalsHistoryTitle => 'Weekly goals history';

  @override
  String get homeDailyMissions => 'TODAY\'S STEPS';

  @override
  String get homeMissionsSubtitle => 'Small acts of care for today.';

  @override
  String homeMissionsProgress(int done, int total) {
    return '$done of $total complete';
  }

  @override
  String get homeDailyCheckIn => 'DAILY CHECK-IN';

  @override
  String get homeCheckInCraving => 'Craving';

  @override
  String get homeCheckInThought => 'Thought';

  @override
  String get homeCheckInActivity => 'Activity';

  @override
  String get homeCheckInSleep => 'Sleep';

  @override
  String get homeQuittingTimeline => 'QUITTING TIMELINE';

  @override
  String get homeRecoveryBannerSub0 => 'See what\'s happening in your body';

  @override
  String get homeRecoveryBannerSub1 => 'Your body is already healing';

  @override
  String get homeRecoveryBannerSub2 => 'Your brain chemistry is shifting';

  @override
  String get homeRecoveryBannerSub3 =>
      'Your body has had a real break from the load';

  @override
  String get homeRecoveryBannerSub4 => 'You are building real momentum';

  @override
  String get homeEditProfile => 'Edit Profile';

  @override
  String get homeProfileNameLabel => 'Name';

  @override
  String get homeProfileNameHint => 'Your name';

  @override
  String get homeSoberSince => 'Sober since';

  @override
  String get homeProfileDailySpend => 'Daily spend';

  @override
  String get homeProfileSpendHint => '0';

  @override
  String get homeCravingSheetTitle => 'Log a craving';

  @override
  String get homeCravingSheetSubtitle =>
      'Noticing the shape of a craving helps you understand the pattern without obeying it.';

  @override
  String get homeCravingStrengthQuestion => 'How strong was the craving?';

  @override
  String get homeCravingIntensityLabel => 'Intensity';

  @override
  String homeCravingIntensityValue(int value) {
    return '$value / 10';
  }

  @override
  String get homeCravingTriggerQuestion => 'What triggered it?';

  @override
  String get homeCravingDurationQuestion => 'How long did it last?';

  @override
  String homeCravingDurationValue(int minutes) {
    return '$minutes minutes';
  }

  @override
  String get homeCravingNotesHint =>
      'Notes (optional) - e.g., passed a bar on the way home.';

  @override
  String get homeSaveCraving => 'Save craving';

  @override
  String get homeThoughtSheetTitle => 'Log a thought';

  @override
  String get homeThoughtSheetSubtitle =>
      'Noticing thoughts about alcohol is normal. Logging them helps reveal the pattern.';

  @override
  String get homeThoughtWhatQuestion => 'What was the thought?';

  @override
  String get homeThoughtWriteHint => 'Write the thought in your own words.';

  @override
  String get homeThoughtStrengthQuestion => 'How strong was the thought?';

  @override
  String get homeThoughtTriggerQuestion => 'What triggered the thought?';

  @override
  String get homeThoughtDurationQuestion => 'How long did it last?';

  @override
  String get homeThoughtToneLabel => 'Tone';

  @override
  String get homeThoughtNotesHint =>
      'Notes (optional) - e.g., saw an ad and noticed the thought arrive.';

  @override
  String get homeSaveThought => 'Save thought';

  @override
  String get homeActivitySheetTitle => 'Log activity';

  @override
  String get homeActivitySheetSubtitle =>
      'Movement can shift the nervous system. Capture enough detail to see what truly helps.';

  @override
  String get homeActivityTypeQuestion => 'What did you do?';

  @override
  String get homeActivityTypeWalk => 'Walk';

  @override
  String get homeActivityTypeExercise => 'Exercise';

  @override
  String get homeActivityTypeYoga => 'Yoga';

  @override
  String get homeActivityTypeOther => 'Other';

  @override
  String get homeActivityEffortQuestion => 'How much effort did it take?';

  @override
  String get homeActivityOutcomeQuestion => 'How did you feel after?';

  @override
  String get homeActivityDurationLabel => 'Duration';

  @override
  String homeActivityDurationValue(int minutes) {
    return '$minutes min';
  }

  @override
  String get homeActivityNotesHint =>
      'Notes (optional) - e.g., walked after dinner and felt steadier.';

  @override
  String get homeSaveActivity => 'Save activity';

  @override
  String get homeSleepSheetTitle => 'Log sleep';

  @override
  String get homeSleepSheetSubtitle =>
      'Sleep is one of the clearest signals in recovery. Small details help reveal the trend.';

  @override
  String get homeSleepHoursLabel => 'Hours slept';

  @override
  String homeSleepHoursValue(String hours) {
    return '$hours hrs';
  }

  @override
  String get homeSleepQualityLabel => 'Sleep quality';

  @override
  String get homeSleepFactorsQuestion => 'What affected your sleep?';

  @override
  String get homeSleepNotesHint =>
      'Notes (optional) - e.g., woke at 3am with cravings, fell back asleep.';

  @override
  String get homeSaveSleep => 'Save sleep';

  @override
  String get homeSeverityBrief => 'Brief';

  @override
  String get homeSeverityMild => 'Mild';

  @override
  String get homeSeverityModerate => 'Moderate';

  @override
  String get homeSeverityStrong => 'Strong';

  @override
  String get homeSeverityConsuming => 'Consuming';

  @override
  String get homeTriggerStress => 'Stress';

  @override
  String get homeTriggerSocial => 'Social';

  @override
  String get homeTriggerBoredom => 'Boredom';

  @override
  String get homeTriggerTimeOfDay => 'Time of day';

  @override
  String get homeTriggerCelebration => 'Celebration';

  @override
  String get homeTriggerSadness => 'Sadness';

  @override
  String get homeTriggerLocation => 'Location';

  @override
  String get homeTriggerMemory => 'Memory';

  @override
  String get homeTriggerHungry => 'Hungry';

  @override
  String get homeTriggerAngry => 'Angry';

  @override
  String get homeTriggerTired => 'Tired';

  @override
  String get homeEffortGentle => 'Light';

  @override
  String get homeEffortModerate => 'Moderate';

  @override
  String get homeEffortStrong => 'Strong';

  @override
  String get homeOutcomeCalmer => 'Calmer';

  @override
  String get homeOutcomeClearer => 'Clearer';

  @override
  String get homeOutcomeEnergized => 'Energized';

  @override
  String get homeOutcomeSame => 'Same';

  @override
  String get homeSleepQualityPoor => 'Poor';

  @override
  String get homeSleepQualityFair => 'Fair';

  @override
  String get homeSleepQualityOK => 'OK';

  @override
  String get homeSleepQualityGood => 'Good';

  @override
  String get homeSleepQualityGreat => 'Great';

  @override
  String get homeSleepFactorRestless => 'Restless';

  @override
  String get homeSleepFactorWokeOften => 'Woke often';

  @override
  String get homeSleepFactorDreams => 'Dreams';

  @override
  String get homeSleepFactorStress => 'Stress';

  @override
  String get homeSleepFactorCravings => 'Cravings';

  @override
  String get homeSleepFactorLateCaffeine => 'Late caffeine';

  @override
  String get homeToneNegative => 'Negative';

  @override
  String get homeToneNeutral => 'Neutral';

  @override
  String get homeTonePositive => 'Positive';

  @override
  String get homeQuote0 =>
      'Every sober day is an act of love for your future self.';

  @override
  String get homeQuote1 =>
      'You do not have to feel ready. You only have to begin.';

  @override
  String get homeQuote2 => 'Healing is allowed to be quiet.';

  @override
  String get homeQuote3 => 'One calm choice can change the shape of a day.';

  @override
  String get homeQuote4 => 'You are not starting over. You are starting wiser.';

  @override
  String get homeQuote5 => 'Recovery is not linear, but it is still real.';

  @override
  String get homeQuote6 =>
      'Even a difficult sober day is proof that you are choosing yourself.';

  @override
  String get homeQuote7 => 'The version of you that kept going is still here.';

  @override
  String get homeQuote8 => 'Strength can look like softness.';

  @override
  String get homeQuote9 => 'Clarity is built one honest moment at a time.';

  @override
  String get homeQuote10 =>
      'You have survived hard days before. Today is another step forward.';

  @override
  String get homeQuote11 =>
      'Cravings are temporary. Your progress is still here.';

  @override
  String get homeQuote12 =>
      'Each morning is another chance to care for yourself.';

  @override
  String get homeQuote13 =>
      'Progress does not need to be perfect to be meaningful.';

  @override
  String get homeQuote14 => 'You are becoming someone you can trust.';

  @override
  String get homeQuote15 => 'Small choices become a safer life.';

  @override
  String get homeQuote16 => 'Peace is not rushed. It is practised.';

  @override
  String get homeQuote17 => 'You are allowed to outgrow what once numbed you.';

  @override
  String get homeQuote18 => 'The urge will pass. Your dignity can remain.';

  @override
  String get homeQuote19 => 'Recovery is a return to yourself.';

  @override
  String get homeQuote20 =>
      'You are not behind. You are healing at human speed.';

  @override
  String get homeQuote21 => 'A softer life is still a strong life.';

  @override
  String get homeQuote22 =>
      'Your future self is being protected by today\'s choices.';

  @override
  String get homeQuote23 =>
      'You can pause. You can breathe. You can choose again.';

  @override
  String get homeQuote24 => 'Every honest day is part of the way forward.';

  @override
  String get homeQuote25 => 'You do not need to punish yourself to change.';

  @override
  String get homeQuote26 => 'The quiet work counts.';

  @override
  String get homeQuote27 => 'Your nervous system is learning safety again.';

  @override
  String get homeQuote28 => 'You are worthy of care before you feel strong.';

  @override
  String get homeQuote29 => 'Let today be simple. Let today be enough.';

  @override
  String get homeQuote30 =>
      'One breath can become one minute. One minute can become one day.';

  @override
  String get homeQuote31 =>
      'You are not your craving. You are the one witnessing it.';

  @override
  String get homeQuote32 =>
      'You can build a life that no longer asks you to escape it.';

  @override
  String get homeQuote33 => 'There is strength in staying.';

  @override
  String get homeQuote34 => 'Healing begins where shame loses its voice.';

  @override
  String get homeQuote35 => 'You are allowed to need support.';

  @override
  String get homeQuote36 => 'The path forward is yours — one step at a time.';

  @override
  String get homeQuote37 => 'Your progress is not erased by a hard moment.';

  @override
  String get homeQuote38 =>
      'Choose the next right thing, not the perfect thing.';

  @override
  String get homeQuote39 => 'Sobriety is not a punishment. It is protection.';

  @override
  String get homeQuote40 => 'You are learning how to come home to yourself.';

  @override
  String get homeQuote41 => 'The life you want is built in ordinary moments.';

  @override
  String get homeQuote42 => 'You can be proud without being finished.';

  @override
  String get homeQuote43 =>
      'Nothing about healing needs to be loud to be real.';

  @override
  String get homeQuote44 => 'Your peace is worth protecting.';

  @override
  String get homeQuote45 => 'A craving is a wave, not a command.';

  @override
  String get homeQuote46 =>
      'You are building evidence that you can trust yourself.';

  @override
  String get homeQuote47 =>
      'Today does not need to be conquered. It only needs to be lived.';

  @override
  String get homeQuote48 => 'There is still time to become someone new.';

  @override
  String get homeQuote49 => 'Keep going. Every step still counts.';

  @override
  String get homeMission0 => 'Drink a full glass of water slowly.';

  @override
  String get homeMission1 => 'Take a 10-minute walk outside.';

  @override
  String get homeMission2 => 'Write down three things you are grateful for.';

  @override
  String get homeMission3 => 'Send a kind message to someone you trust.';

  @override
  String get homeMission4 => 'Do five minutes of slow breathing.';

  @override
  String get homeMission5 => 'Read a few pages of something calming.';

  @override
  String get homeMission6 => 'Eat one nourishing meal without distractions.';

  @override
  String get homeMission7 => 'Prepare for an earlier, softer night.';

  @override
  String get homeMission8 => 'Do one kind thing for yourself today.';

  @override
  String get homeMission9 => 'Sit in silence for three minutes.';

  @override
  String get homeMission10 => 'Write one honest sentence in your journal.';

  @override
  String get homeMission11 => 'Put your phone away for one quiet hour.';

  @override
  String get homeMission12 => 'Stretch your shoulders, neck, and back.';

  @override
  String get homeMission13 => 'Listen to music that steadies you.';

  @override
  String get homeMission14 => 'Tidy one small area of your space.';

  @override
  String get homeMission15 => 'Step outside and notice the sky.';

  @override
  String get homeMission16 => 'Say \"I am allowed to heal\" three times.';

  @override
  String get homeMission17 => 'Make yourself something warm to drink.';

  @override
  String get homeMission18 => 'Reach out to your support network.';

  @override
  String get homeMission19 => 'Honour the progress you have made today.';

  @override
  String get homeMission20 =>
      'Take five slow breaths before your next decision.';

  @override
  String get homeMission21 => 'Write down one trigger you noticed today.';

  @override
  String get homeMission22 => 'Write down one thing that helped you today.';

  @override
  String get homeMission23 => 'Place one comforting item near your bed.';

  @override
  String get homeMission24 => 'Wash your face slowly and mindfully.';

  @override
  String get homeMission25 => 'Spend 10 minutes away from screens.';

  @override
  String get homeMission26 => 'Prepare tomorrow\'s first small task.';

  @override
  String get homeMission27 => 'Let one room feel a little lighter.';

  @override
  String get homeMission28 => 'Notice one thing your body needs.';

  @override
  String get homeMission29 => 'Choose a meal that supports your energy.';

  @override
  String get homeMission30 => 'Read one recovery note or affirmation.';

  @override
  String get homeMission31 =>
      'Save one emergency support number somewhere visible.';

  @override
  String get homeMission32 => 'Write a short note to your future self.';

  @override
  String get homeMission33 => 'Take a warm shower or bath.';

  @override
  String get homeMission34 => 'Breathe through a craving without judging it.';

  @override
  String get homeMission35 => 'Name the emotion underneath the urge.';

  @override
  String get homeMission36 => 'Do one thing slowly on purpose.';

  @override
  String get homeMission37 => 'Put clean water beside your bed.';

  @override
  String get homeMission38 => 'Open a window and take three deep breaths.';

  @override
  String get homeMission39 => 'Write down one reason you are continuing.';

  @override
  String get homeMission40 => 'Spend five minutes in natural light.';

  @override
  String get homeMission41 => 'Make your bed with care.';

  @override
  String get homeMission42 => 'Delete or mute one digital trigger.';

  @override
  String get homeMission43 => 'Choose rest before exhaustion.';

  @override
  String get homeMission44 =>
      'Write one sentence that begins: \"Today I protected…\"';

  @override
  String get homeMission45 => 'Notice one moment of peace, however small.';

  @override
  String get homeMission46 => 'Thank yourself for staying present.';

  @override
  String get homeMission47 => 'Do a 10-minute reset of your space.';

  @override
  String get homeMission48 =>
      'Choose one boundary that supports your recovery.';

  @override
  String get homeMission49 => 'Let yourself pause before reacting.';

  @override
  String get homeMission50 =>
      'Write down one thing you are learning about yourself.';

  @override
  String get homeMission51 => 'Prepare a simple comfort plan for tonight.';

  @override
  String get homeMission52 =>
      'Place your hand on your chest and breathe slowly.';

  @override
  String get homeMission53 =>
      'Drink tea, water, or something calming without rushing.';

  @override
  String get homeMission54 =>
      'Spend a few minutes with a plant, pet, or quiet object.';

  @override
  String get homeMission55 =>
      'Write down one thing you do not need to carry today.';

  @override
  String get homeMission56 => 'Take a short walk without headphones.';

  @override
  String get homeMission57 => 'Do one practical task you have been avoiding.';

  @override
  String get homeMission58 => 'End the day by naming one quiet victory.';

  @override
  String get homeMission59 => 'Remind yourself: small steps still count.';

  @override
  String get journalTitle => 'My Journal';

  @override
  String get journalTabJournal => 'Journal';

  @override
  String get journalTabAffirm => 'Affirm';

  @override
  String get journalTabVision => 'Vision';

  @override
  String get journalTabZen => 'Zen';

  @override
  String get journalAffirm0 => 'I am worthy of love and belonging.';

  @override
  String get journalAffirm1 => 'I choose recovery every single day.';

  @override
  String get journalAffirm2 => 'My past does not define my future.';

  @override
  String get journalAffirm3 =>
      'I am getting stronger with each passing moment.';

  @override
  String get journalAffirm4 => 'I deserve peace, health, and happiness.';

  @override
  String get journalAffirm5 => 'I am proud of how far I have come.';

  @override
  String get journalAffirm6 => 'I have the strength to overcome challenges.';

  @override
  String get journalAffirm7 => 'Today I choose myself.';

  @override
  String get journalAffirm8 => 'I am healing and growing every day.';

  @override
  String get journalAffirm9 => 'I am not alone in this journey.';

  @override
  String get journalAffirm10 => 'My sobriety is my greatest achievement.';

  @override
  String get journalAffirm11 => 'I release what no longer serves me.';

  @override
  String get journalAffirm12 => 'I am capable of change.';

  @override
  String get journalAffirm13 => 'Every sober day is a victory.';

  @override
  String get journalAffirm14 => 'I am becoming the person I want to be.';

  @override
  String get zenQuote0 =>
      'The present moment is the only time over which we have dominion.';

  @override
  String get zenQuoteAuthor0 => 'Thich Nhat Hanh';

  @override
  String get zenQuote1 =>
      'You don\'t have to control your thoughts. You just have to stop letting them control you.';

  @override
  String get zenQuoteAuthor1 => 'Dan Millman';

  @override
  String get zenQuote2 =>
      'Peace is not the absence of conflict, but the ability to cope with it.';

  @override
  String get zenQuoteAuthor2 => 'Mahatma Gandhi';

  @override
  String get zenQuote3 =>
      'Recovery is not a race. You don\'t have to feel guilty if it takes you longer than you thought it would.';

  @override
  String get zenQuoteAuthor3 => 'Anonymous';

  @override
  String get zenQuote4 =>
      'Every day is a new beginning. Take a deep breath, smile, and start again.';

  @override
  String get zenQuoteAuthor4 => 'Anonymous';

  @override
  String get zenQuote5 => 'The wound is the place where the Light enters you.';

  @override
  String get zenQuoteAuthor5 => 'Rumi';

  @override
  String get zenQuote6 => 'You are enough just as you are.';

  @override
  String get zenQuoteAuthor6 => 'Meghan Markle';

  @override
  String get zenQuote7 => 'Healing is not linear.';

  @override
  String get zenQuoteAuthor7 => 'Anonymous';

  @override
  String get zenQuote8 =>
      'What lies behind us and what lies before us are tiny matters compared to what lies within us.';

  @override
  String get zenQuoteAuthor8 => 'Ralph Waldo Emerson';

  @override
  String get zenQuote9 =>
      'You have been assigned this mountain to show others it can be moved.';

  @override
  String get zenQuoteAuthor9 => 'Mel Robbins';

  @override
  String get zenQuote10 =>
      'It does not matter how slowly you go as long as you do not stop.';

  @override
  String get zenQuoteAuthor10 => 'Confucius';

  @override
  String get zenQuote11 =>
      'The hardest step she ever took was to blindly trust in who she was.';

  @override
  String get zenQuoteAuthor11 => 'Atticus';

  @override
  String get zenQuote12 =>
      'One day at a time — this is enough. Do not look back and grieve over the past, for it is gone.';

  @override
  String get zenQuoteAuthor12 => 'Ida Scott Taylor';

  @override
  String get zenQuote13 =>
      'Rock bottom became the solid foundation on which I rebuilt my life.';

  @override
  String get zenQuoteAuthor13 => 'J.K. Rowling';

  @override
  String get zenQuote14 =>
      'Be patient with yourself. You are a child of the universe.';

  @override
  String get zenQuoteAuthor14 => 'Max Ehrmann';

  @override
  String get zenQuote15 =>
      'In the middle of every difficulty lies opportunity.';

  @override
  String get zenQuoteAuthor15 => 'Albert Einstein';

  @override
  String get zenQuote16 =>
      'Your present circumstances don\'t determine where you can go; they merely determine where you start.';

  @override
  String get zenQuoteAuthor16 => 'Nido Qubein';

  @override
  String get zenQuote17 => 'The secret of getting ahead is getting started.';

  @override
  String get zenQuoteAuthor17 => 'Mark Twain';

  @override
  String get zenQuote18 =>
      'You are braver than you believe, stronger than you seem, and smarter than you think.';

  @override
  String get zenQuoteAuthor18 => 'A.A. Milne';

  @override
  String get zenQuote19 =>
      'Don\'t watch the clock; do what it does. Keep going.';

  @override
  String get zenQuoteAuthor19 => 'Sam Levenson';

  @override
  String get zenQuote20 =>
      'Accept yourself, love yourself, and keep moving forward.';

  @override
  String get zenQuoteAuthor20 => 'Roy T. Bennett';

  @override
  String get zenQuote21 =>
      'The journey of a thousand miles begins with one step.';

  @override
  String get zenQuoteAuthor21 => 'Lao Tzu';

  @override
  String get zenQuote22 =>
      'You can\'t go back and change the beginning, but you can start where you are and change the ending.';

  @override
  String get zenQuoteAuthor22 => 'C.S. Lewis';

  @override
  String get zenQuote23 =>
      'Strength does not come from physical capacity. It comes from an indomitable will.';

  @override
  String get zenQuoteAuthor23 => 'Mahatma Gandhi';

  @override
  String get zenQuote24 => 'Every moment is a fresh beginning.';

  @override
  String get zenQuoteAuthor24 => 'T.S. Eliot';

  @override
  String get zenQuote25 =>
      'Just when the caterpillar thought the world was ending, he turned into a butterfly.';

  @override
  String get zenQuoteAuthor25 => 'Proverb';

  @override
  String get zenQuote26 =>
      'Courage doesn\'t always roar. Sometimes courage is the quiet voice at the end of the day saying, I will try again tomorrow.';

  @override
  String get zenQuoteAuthor26 => 'Mary Anne Radmacher';

  @override
  String get zenQuote27 => 'The only way out is through.';

  @override
  String get zenQuoteAuthor27 => 'Robert Frost';

  @override
  String get zenQuote28 =>
      'You are not your past. You are the lessons you\'ve learned from it.';

  @override
  String get zenQuoteAuthor28 => 'Anonymous';

  @override
  String get zenQuote29 => 'Progress, not perfection.';

  @override
  String get zenQuoteAuthor29 => 'Anonymous';

  @override
  String get progressTitle => 'Progress';

  @override
  String progressDaysChip(int days) {
    return '$days days';
  }

  @override
  String get progressTabJourney => 'Journey';

  @override
  String get progressTabInsights => 'Insights';

  @override
  String get progressMilestoneLabel1 => 'First Day';

  @override
  String get progressMilestoneLabel2 => 'Two Days';

  @override
  String get progressMilestoneLabel3 => 'Three Days';

  @override
  String get progressMilestoneLabel5 => 'Five Days';

  @override
  String get progressMilestoneLabel7 => 'One Week';

  @override
  String get progressMilestoneLabel10 => 'Ten Days';

  @override
  String get progressMilestoneLabel14 => 'Two Weeks';

  @override
  String get progressMilestoneLabel21 => 'Three Weeks';

  @override
  String get progressMilestoneLabel30 => 'One Month';

  @override
  String get progressMilestoneLabel60 => 'Two Months';

  @override
  String get progressMilestoneLabel90 => 'Three Months';

  @override
  String get progressMilestoneLabel100 => '100 Days';

  @override
  String get progressMilestoneLabel180 => 'Six Months';

  @override
  String get progressMilestoneLabel365 => 'One Year';

  @override
  String get progressMilestoneLabel730 => 'Two Years';

  @override
  String get progressMilestoneLabel1095 => 'Three Years';

  @override
  String get insightsTitle => 'Insights';

  @override
  String get insights7DayView => '7-day view';

  @override
  String get milestoneScreenTitle => 'Milestones';

  @override
  String get milestoneOneDay => 'One Day';

  @override
  String get milestoneOneDayShort => '1 Day';

  @override
  String get milestoneOneDayBenefit =>
      'One full day. Alcohol typically clears from the body within this window. For many people, tonight\'s sleep — though sometimes restless — feels different from the nights that came before.';

  @override
  String get milestoneThreeDays => 'Three Days';

  @override
  String get milestoneThreeDaysShort => '3 Days';

  @override
  String get milestoneThreeDaysBenefit =>
      'Most alcohol metabolites have left your body. The brain\'s GABA system is recalibrating — this can bring restlessness, but it means your nervous system is finding its natural balance again. Hydration is improving.';

  @override
  String get milestoneOneWeek => 'One Week';

  @override
  String get milestoneOneWeekShort => '1 Week';

  @override
  String get milestoneOneWeekBenefit =>
      'One full week. Many people start to notice sharper thinking, more natural energy, and better hydration around this stage. Your body has had a meaningful stretch of recovery time.';

  @override
  String get milestoneTwoWeeks => 'Two Weeks';

  @override
  String get milestoneTwoWeeksShort => '2 Weeks';

  @override
  String get milestoneTwoWeeksBenefit =>
      'Two weeks. For many people, anxiety begins to stabilise and sleep deepens. The early-recovery storm often starts to soften here, though every person\'s timeline is different.';

  @override
  String get milestoneOneMonth => 'One Month';

  @override
  String get milestoneOneMonthShort => '1 Month';

  @override
  String get milestoneOneMonthBenefit =>
      'One month. Many people describe meaningful gains in clarity and emotional steadiness at this point. Cravings can become easier to observe without acting on them.';

  @override
  String get milestoneTwoMonths => 'Two Months';

  @override
  String get milestoneTwoMonthsShort => '2 Months';

  @override
  String get milestoneTwoMonthsBenefit =>
      'Two months. Research suggests the prefrontal cortex — responsible for decisions, impulse control, and empathy — begins to recover meaningfully around this stage. Many people see improvements in cholesterol levels. You are physically and neurologically different from who you were.';

  @override
  String get milestoneThreeMonths => 'Three Months';

  @override
  String get milestoneThreeMonthsShort => '3 Months';

  @override
  String get milestoneThreeMonthsBenefit =>
      'Three months. Skin can look clearer, sleep can feel deeper, and concentration often continues to sharpen. You have built real momentum.';

  @override
  String get milestoneSixMonths => 'Six Months';

  @override
  String get milestoneSixMonthsShort => '6 Months';

  @override
  String get milestoneSixMonthsBenefit =>
      'Six months. Many people report that around this point, sobriety has begun to feel like part of who they are — not just a goal they\'re chasing.';

  @override
  String get milestoneOneYear => 'One Year';

  @override
  String get milestoneOneYearShort => '1 Year';

  @override
  String get milestoneOneYearBenefit =>
      'One year. This is a profound milestone. Many people describe genuine, lasting changes in how they feel and how they relate to themselves. The cumulative gains of a year without alcohol are real — and they are yours.';

  @override
  String get recoveryTitle => 'The Healing Timeline';

  @override
  String get recoverySubtitle =>
      'How your mind and body are restoring themselves';

  @override
  String get recoveryHeroLabel => 'YOUR BODY TODAY';

  @override
  String recoveryDaysSober(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days sober',
      one: '1 day sober',
    );
    return '$_temp0';
  }

  @override
  String recoveryMilestonesReached(int achieved, int total) {
    return '$achieved of $total milestones reached';
  }

  @override
  String get recoveryM1Label => '12 Hours';

  @override
  String get recoveryM1Title => 'The Reset Begins';

  @override
  String get recoveryM1Body =>
      'Your body begins adjusting to the absence of alcohol. Hydration, sleep pressure, blood sugar, and stress hormones may feel unsettled as your system begins to rebalance.';

  @override
  String get recoveryM1System => 'Total Body';

  @override
  String get recoveryM2Label => '24 Hours';

  @override
  String get recoveryM2Title => 'Restoring Rhythm';

  @override
  String get recoveryM2Body =>
      'For many people, the body\'s basic rhythms — heart rate, hydration, sleep — start to shift as it adjusts. This can feel calming for some and uncomfortable for others.';

  @override
  String get recoveryM2System => 'Cardiovascular System';

  @override
  String get recoveryM3Label => '48 Hours';

  @override
  String get recoveryM3Title => 'The Pivot Point';

  @override
  String get recoveryM3Body =>
      'For people who were drinking heavily, this can be one of the highest-risk windows for withdrawal symptoms. Your nervous system may feel overstimulated as it works to rebalance.';

  @override
  String get recoveryM3System => 'Central Nervous System';

  @override
  String get recoveryM4Label => '3 Days';

  @override
  String get recoveryM4Title => 'Clearing the System';

  @override
  String get recoveryM4Body =>
      'For many people, the most intense early physical adjustment begins to ease around this point, though recovery is individual and some symptoms can continue.';

  @override
  String get recoveryM4System => 'Total Body';

  @override
  String get recoveryM5Label => '1 Week';

  @override
  String get recoveryM5Title => 'Deepening Rest';

  @override
  String get recoveryM5Body =>
      'Restorative sleep often begins to return. Hydration, appetite, and daily energy may start to feel more stable, although sleep and mood can still fluctuate.';

  @override
  String get recoveryM5System => 'Brain & Sleep Cycles';

  @override
  String get recoveryM6Label => '2 Weeks';

  @override
  String get recoveryM6Title => 'Finding Balance';

  @override
  String get recoveryM6Body =>
      'Physical stamina may begin to return as sleep, appetite, hydration, and daily rhythm become more stable.';

  @override
  String get recoveryM6System => 'Energy & Digestion';

  @override
  String get recoveryM7Label => '1 Month';

  @override
  String get recoveryM7Title => 'Meaningful Relief';

  @override
  String get recoveryM7Body =>
      'Your body has had a meaningful stretch of relief from the strain of alcohol. Many people notice steadier energy, clearer thinking, and improved sleep around this stage.';

  @override
  String get recoveryM7System => 'Liver & Vital Organs';

  @override
  String get recoveryM8Label => '3 Months';

  @override
  String get recoveryM8Title => 'Restoring Joy';

  @override
  String get recoveryM8Body =>
      'Your body may feel more resilient as sleep, nourishment, movement, and reduced alcohol strain begin working together.';

  @override
  String get recoveryM8System => 'Neurochemistry';

  @override
  String get recoveryM9Label => '6 Months';

  @override
  String get recoveryM9Title => 'True Resilience';

  @override
  String get recoveryM9Body =>
      'Many people notice a steadier baseline by this stage. Stress may feel more manageable, sleep may feel more reliable.';

  @override
  String get recoveryM9System => 'Nervous System';

  @override
  String get recoveryM10Label => '1 Year';

  @override
  String get recoveryM10Title => 'A New Baseline';

  @override
  String get recoveryM10Body =>
      'For many people, the long-term load on energy, sleep, and mood is meaningfully lighter after a year without alcohol.';

  @override
  String get recoveryM10System => 'Whole Body';

  @override
  String get recoveryM11Label => '2 Years & Beyond';

  @override
  String get recoveryM11Title => 'Lasting Vitality';

  @override
  String get recoveryM11Body =>
      'The benefits of reduced alcohol strain can continue to deepen over time, supporting your body, mind, relationships, and daily sense of stability.';

  @override
  String get recoveryM11System => 'Whole Body Renewal';

  @override
  String get emergencyHomeTitle => 'Calm Toolkit';

  @override
  String get emergencyHomeSubtitle => 'What do you need right now?';

  @override
  String get emergencyBreathingTitle => 'Breathing';

  @override
  String get emergencyMeditationTitle => 'Meditation';

  @override
  String get emergencyCBTTitle => 'CBT Guides';

  @override
  String get emergencyReasonsTitle => 'My Reasons';

  @override
  String get emergencyHALTTitle => 'HALT Check';

  @override
  String get emergencyUrgeTimerTitle => 'Urge Timer';

  @override
  String get emergencyPlayTapeTitle => 'Play the Tape';

  @override
  String get emergencyMindfulnessTitle => 'Mindfulness';

  @override
  String get breathPatternBoxName => 'Box';

  @override
  String get breathPatternBoxDesc => 'Equal sides — focus and calm';

  @override
  String get breathPattern478Name => '4-7-8';

  @override
  String get breathPattern478Desc => 'Deep relaxation and sleep';

  @override
  String get breathPatternCalmName => 'Calm';

  @override
  String get breathPatternCalmDesc => 'Quick anxiety reset';

  @override
  String get breathPatternPowerName => 'Power';

  @override
  String get breathPatternPowerDesc => 'Energy and alertness';

  @override
  String get breathPatternResetName => 'Reset';

  @override
  String get breathPatternResetDesc => 'Instant stress relief';

  @override
  String get breathPatternTriangleName => 'Triangle';

  @override
  String get breathPatternTriangleDesc => 'Simple three-phase balance';

  @override
  String get breathPatternAnchorName => 'Anchor';

  @override
  String get breathPatternAnchorDesc => 'Grounding in difficult moments';

  @override
  String get breathPatternRescueName => 'Rescue';

  @override
  String get breathPatternRescueDesc => 'Panic and high anxiety';

  @override
  String get breathPatternOceanName => 'Ocean';

  @override
  String get breathPatternOceanDesc => 'Wave-like natural rhythm';

  @override
  String get breathPatternMorningName => 'Morning';

  @override
  String get breathPatternMorningDesc => 'Wake up and energise';

  @override
  String get breathPatternCoherentName => 'Coherent';

  @override
  String get breathPatternCoherentDesc => 'Heart-rate variability balance';

  @override
  String get breathPattern628Name => '6-2-8';

  @override
  String get breathPattern628Desc => 'Deep parasympathetic activation';

  @override
  String get breathPatternSquarePlusName => 'Square+';

  @override
  String get breathPatternSquarePlusDesc => 'Extended box for deep calm';

  @override
  String get breathPatternWarriorName => 'Warrior';

  @override
  String get breathPatternWarriorDesc => 'Strength and determination';

  @override
  String get breathPatternNightName => 'Night';

  @override
  String get breathPatternNightDesc => 'Pre-sleep wind-down';

  @override
  String get breathPhaseInhale => 'Inhale';

  @override
  String get breathPhaseHold => 'Hold';

  @override
  String get breathPhaseExhale => 'Exhale';

  @override
  String breathCycleCount(int count) {
    return '$count cycles';
  }

  @override
  String get cbtGuide0Title => 'Challenge the Thought';

  @override
  String get cbtGuide0Step0 => 'Write down the thought that\'s troubling you.';

  @override
  String get cbtGuide0Step1 => 'Ask: Is this thought based on fact or feeling?';

  @override
  String get cbtGuide0Step2 =>
      'What evidence supports this thought? What contradicts it?';

  @override
  String get cbtGuide0Step3 =>
      'What would you say to a friend having this thought?';

  @override
  String get cbtGuide0Step4 => 'Write a more balanced version of the thought.';

  @override
  String get cbtGuide0Step5 => 'Notice how you feel after reframing it.';

  @override
  String get cbtGuide1Title => 'Surf the Urge';

  @override
  String get cbtGuide1Step0 =>
      'Recognise the urge — name it: \"I notice a craving.\"';

  @override
  String get cbtGuide1Step1 => 'Don\'t fight it. Observe it like a wave.';

  @override
  String get cbtGuide1Step2 => 'Notice where you feel it in your body.';

  @override
  String get cbtGuide1Step3 => 'Breathe slowly. The wave will peak and pass.';

  @override
  String get cbtGuide1Step4 =>
      'Remind yourself: urges always pass within 20–30 minutes.';

  @override
  String get cbtGuide2Title => 'Cost-Benefit Check';

  @override
  String get cbtGuide2Step0 => 'List the short-term benefits of drinking.';

  @override
  String get cbtGuide2Step1 => 'List the short-term costs of drinking.';

  @override
  String get cbtGuide2Step2 => 'List the long-term benefits of staying sober.';

  @override
  String get cbtGuide2Step3 => 'List the long-term costs of drinking.';

  @override
  String get cbtGuide2Step4 => 'Which column weighs more to your future self?';

  @override
  String get cbtGuide3Title => 'Trigger Action Plan';

  @override
  String get cbtGuide3Step0 =>
      'Identify the trigger: person, place, feeling, or time.';

  @override
  String get cbtGuide3Step1 => 'What has worked before in similar moments?';

  @override
  String get cbtGuide3Step2 => 'Who can you call or text right now?';

  @override
  String get cbtGuide3Step3 =>
      'What activity can you do for the next 20 minutes?';

  @override
  String get cbtGuide3Step4 =>
      'Write your commitment: \"When X happens, I will Y.\"';

  @override
  String get cbtGuide4Title => 'Identity Shift';

  @override
  String get cbtGuide4Step0 => 'Describe the person you are becoming.';

  @override
  String get cbtGuide4Step1 => 'What values guide that person?';

  @override
  String get cbtGuide4Step2 => 'What would that person do right now?';

  @override
  String get cbtGuide4Step3 => 'Write: \"I am someone who...\"';

  @override
  String get cbtGuide4Step4 => 'Act from that identity for the next hour.';

  @override
  String get haltH => 'H';

  @override
  String get haltHungry => 'Hungry';

  @override
  String get haltHungryAdvice =>
      'Eat something nourishing before making any decisions.';

  @override
  String get haltA => 'A';

  @override
  String get haltAngry => 'Angry';

  @override
  String get haltAngryAdvice =>
      'Breathe first. Anger distorts judgment. Pause for 10 minutes.';

  @override
  String get haltL => 'L';

  @override
  String get haltLonely => 'Lonely';

  @override
  String get haltLonelyAdvice =>
      'Reach out to one person. Connection is medicine.';

  @override
  String get haltT => 'T';

  @override
  String get haltTired => 'Tired';

  @override
  String get haltTiredAdvice =>
      'Rest before responding. Exhaustion lowers your defenses.';

  @override
  String get mindful0Title => '5-4-3-2-1';

  @override
  String get mindful0Desc =>
      '5 things you can see, 4 you can touch, 3 you can hear, 2 you can smell, 1 you can taste.';

  @override
  String get mindful1Title => 'One Breath';

  @override
  String get mindful1Desc =>
      'Take the longest, slowest breath of your day right now. Feel your lungs expand fully.';

  @override
  String get mindful2Title => 'Body Check';

  @override
  String get mindful2Desc =>
      'Starting from your feet, slowly scan upward. Notice tension without judging it.';

  @override
  String get mindful3Title => 'The Observer';

  @override
  String get mindful3Desc =>
      'Step back from your thoughts. Watch them like clouds passing — you are the sky, not the clouds.';

  @override
  String get mindful4Title => 'Label It';

  @override
  String get mindful4Desc =>
      'Name what you\'re feeling: \"Anxiety is here.\" Naming it reduces its power.';

  @override
  String get mindful5Title => 'Present Anchor';

  @override
  String get mindful5Desc =>
      'Press your feet into the floor. Feel the weight of your body. You are here. You are safe.';

  @override
  String get crisisTitle => 'Crisis Lines';

  @override
  String get crisisTooltipBack => 'Back';

  @override
  String get crisisEmergencyHeadline =>
      'In immediate danger? Call emergency services';

  @override
  String get crisisWithdrawalTitle => 'Alcohol withdrawal can be dangerous';

  @override
  String get crisisWithdrawalTapHint => 'Tap to see warning signs';

  @override
  String get crisisSectionHeader => 'CRISIS LINES';

  @override
  String get crisisSeekMedical =>
      'Seek immediate medical attention if you experience:';

  @override
  String get crisisCallEmergency =>
      'If you experience any of these, call emergency services immediately. Do not try to manage alone.';

  @override
  String get crisisTooltipCall => 'Call';

  @override
  String get crisisTooltipCopy => 'Copy';

  @override
  String crisisLinesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lines',
      one: '1 line',
    );
    return '$_temp0';
  }

  @override
  String get crisisWithdrawal0 => 'Seizures or convulsions';

  @override
  String get crisisWithdrawal1 => 'Hallucinations (seeing or hearing things)';

  @override
  String get crisisWithdrawal2 => 'Severe tremors (whole-body shaking)';

  @override
  String get crisisWithdrawal3 => 'Confusion or disorientation';

  @override
  String get crisisWithdrawal4 => 'High fever (above 38.5 C / 101 F)';

  @override
  String get crisisWithdrawal5 => 'Rapid heart rate (above 100 bpm)';

  @override
  String get crisisWithdrawal6 => 'Extreme sweating or clamminess';

  @override
  String get settingsTitle => 'Profile';

  @override
  String get settingsYourName => 'Your name';

  @override
  String get settingsNameHint => 'e.g. Alex';

  @override
  String get settingsSavingsGoalDialogTitle => 'Savings goal';

  @override
  String get settingsGoalNameHint => 'Goal name (e.g. Holiday)';

  @override
  String get settingsTargetAmountHint => 'Target amount';

  @override
  String get settingsEmergencyContactDialogTitle => 'Emergency contact';

  @override
  String get settingsContactNameHint => 'Name';

  @override
  String get settingsContactPhoneHint => 'Phone number';

  @override
  String get settingsSoberDateLabel => 'Sober date';

  @override
  String get settingsDailySpendLabel => 'Daily spend';

  @override
  String get settingsLockMethodLabel => 'App lock';

  @override
  String get settingsNotificationsLabel => 'Notifications';

  @override
  String get settingsPrivacyLabel => 'Privacy policy';

  @override
  String get settingsBackupLabel => 'Backup & restore';

  @override
  String get settingsHistoryLabel => 'Full history';

  @override
  String get settingsInsightsLabel => 'Insights';

  @override
  String get settingsGroupsLabel => 'Support groups';

  @override
  String get settingsHeatmapLabel => 'Activity heatmap';

  @override
  String get settingsWeeklyGoalsLabel => 'Weekly goals';

  @override
  String get settingsMyReasonsLabel => 'My reasons';

  @override
  String get settingsSavingsGoalLabel => 'Savings goal';

  @override
  String get settingsEmergencyContactLabel => 'Emergency contact';

  @override
  String get settingsChangePinLabel => 'Change PIN';

  @override
  String get groupsTitle => 'Support Groups';

  @override
  String get groupsSubtitle => 'You don\'t have to do this alone';

  @override
  String get groupsIntroNote =>
      'Peer support is one of the strongest predictors of long-term recovery. Tap any group to visit their website.';

  @override
  String get groupsVisitWebsite => 'Visit website';

  @override
  String get groupAaName => 'Alcoholics Anonymous';

  @override
  String get groupAaTagline => 'AA';

  @override
  String get groupAaDesc =>
      'The original peer-led fellowship. Meetings worldwide — in-person and online. Based on 12 steps and mutual support. Free and anonymous.';

  @override
  String get groupAaApproach => '12-step · Peer support · Spiritual';

  @override
  String get groupAaRegions => 'Worldwide · South Africa: aa.org.za';

  @override
  String get groupSmartName => 'SMART Recovery';

  @override
  String get groupSmartTagline => 'Self-Management & Recovery Training';

  @override
  String get groupSmartDesc =>
      'Science-based alternative to 12-step. Uses CBT and motivational techniques. No spiritual component required. In-person and online meetings globally.';

  @override
  String get groupSmartApproach => 'CBT-based · Evidence-based · Non-spiritual';

  @override
  String get groupSmartRegions =>
      'Worldwide · South Africa: smartrecovery.org.za';

  @override
  String get groupNaName => 'Narcotics Anonymous';

  @override
  String get groupNaTagline => 'NA';

  @override
  String get groupNaDesc =>
      'Peer-led 12-step fellowship for people recovering from drug addiction. Meetings in most cities and online. Free and welcoming to all.';

  @override
  String get groupNaApproach => '12-step · Peer support · Drug-focused';

  @override
  String get groupNaRegions => 'Worldwide';

  @override
  String get historyTitle => 'History';

  @override
  String get historyToday => 'Today';

  @override
  String get historyYesterday => 'Yesterday';

  @override
  String get historySearchHint => 'Search entries…';

  @override
  String get historyFilterAll => 'All';

  @override
  String get historyFilterJournal => 'Journal';

  @override
  String get historyFilterGratitude => 'Gratitude';

  @override
  String get historyFilterCravings => 'Cravings';

  @override
  String get historyFilterThoughts => 'Thoughts';

  @override
  String get historyFilterActivity => 'Activity';

  @override
  String get historyFilterSleep => 'Sleep';

  @override
  String get historyFilterSlips => 'Slips';

  @override
  String get historyEmpty => 'No entries yet';

  @override
  String get historyEmptySub =>
      'Your logs will appear here as you use the app.';

  @override
  String get historyMoodGreat => 'Great';

  @override
  String get historyMoodGood => 'Good';

  @override
  String get historyMoodOkay => 'Okay';

  @override
  String get historyMoodHard => 'Hard day';

  @override
  String get historyMoodCrisis => 'Crisis';

  @override
  String get puzzleTitle => 'Calm Activities';

  @override
  String get puzzleActivity0Label => 'Slow Count';

  @override
  String get puzzleActivity0Desc =>
      'Count backwards — it interrupts anxious thought loops.';

  @override
  String get puzzleActivity0Duration => '2 – 5 min';

  @override
  String get puzzleActivity1Label => 'Gratitude Shuffle';

  @override
  String get puzzleActivity1Desc =>
      'Tap for a new gratitude prompt until one lands.';

  @override
  String get puzzleActivity1Duration => '2 min';

  @override
  String get puzzleActivity2Label => 'Memory Match';

  @override
  String get puzzleActivity2Desc =>
      'Flip cards to find pairs. Focusing the mind calms it.';

  @override
  String get puzzleActivity2Duration => '5 min';

  @override
  String get puzzleActivity3Label => 'Strength Compass';

  @override
  String get puzzleActivity3Desc =>
      'Rate your recovery strengths and see where you are today.';

  @override
  String get puzzleActivity3Duration => '3 min';

  @override
  String get puzzleActivity4Label => 'Now Moment';

  @override
  String get puzzleActivity4Desc =>
      'Notice · Feel · Choose — a mindful 60-second reset.';

  @override
  String get puzzleActivity4Duration => '1 min';

  @override
  String get cbtScreenTitle => 'Thought Reframe';

  @override
  String cbtStepIndicator(int step) {
    return 'Step $step of 4';
  }

  @override
  String get cbtStep0Title => 'What\'s the thought?';

  @override
  String get cbtStep0Subtitle =>
      'Write the automatic thought exactly as it appeared — raw, unfiltered. Don\'t judge it yet.';

  @override
  String get cbtStep0HintText =>
      'e.g. \"I\'ve already ruined everything. What\'s the point?\"';

  @override
  String get cbtEducation =>
      'CBT works by carefully examining the thoughts that drive distress — not to dismiss them, but to understand them more clearly.';

  @override
  String get cbtStep1Title => 'Spot the pattern';

  @override
  String get cbtStep1Subtitle =>
      'Does this thought follow a recognisable pattern? Tap the one that fits best.';

  @override
  String get cbtDistortionAllOrNothing => 'All-or-nothing thinking';

  @override
  String get cbtDistortionAllOrNothingExample =>
      '\"If I\'m not perfect, I\'ve completely failed.\"';

  @override
  String get cbtDistortionCatastrophising => 'Catastrophising';

  @override
  String get cbtDistortionCatastrophisingExample =>
      '\"This will ruin everything forever.\"';

  @override
  String get cbtDistortionMindReading => 'Mind reading';

  @override
  String get cbtDistortionMindReadingExample =>
      '\"Everyone must think I\'m weak.\"';

  @override
  String get cbtDistortionEmotionalReasoning => 'Emotional reasoning';

  @override
  String get cbtDistortionEmotionalReasoningExample =>
      '\"I feel hopeless, so the situation must be hopeless.\"';

  @override
  String get cbtDistortionShouldStatements => 'Should statements';

  @override
  String get cbtDistortionShouldStatementsExample =>
      '\"I should be further along by now.\"';

  @override
  String get cbtDistortionPersonalisation => 'Personalisation';

  @override
  String get cbtDistortionPersonalisationExample => '\"This is all my fault.\"';

  @override
  String get cbtDistortionOvergeneralisation => 'Overgeneralisation';

  @override
  String get cbtDistortionOvergeneralisationExample =>
      '\"This always happens to me.\"';

  @override
  String get cbtDistortionNoneOfAbove => 'None of the above';

  @override
  String get cbtDistortionNoneOfAboveExample =>
      'The thought doesn\'t fit a specific pattern.';

  @override
  String get cbtStep2Title => 'Test the evidence';

  @override
  String get cbtStep2Subtitle =>
      'Look at the thought like a scientist. What\'s the actual evidence for and against it?';

  @override
  String get cbtEvidenceForLabel => 'Evidence FOR the thought';

  @override
  String get cbtEvidenceForHint =>
      'What facts support it? (It\'s ok if there are some.)';

  @override
  String get cbtEvidenceAgainstLabel => 'Evidence AGAINST the thought';

  @override
  String get cbtEvidenceAgainstHint =>
      'What facts challenge it? What am I ignoring?';

  @override
  String get cbtStep3Title => 'A more balanced view';

  @override
  String get cbtStep3Subtitle =>
      'Based on the evidence, write a thought that\'s more realistic and kind. It doesn\'t have to be positive — just fairer.';

  @override
  String get cbtReframeHintText =>
      'e.g. \"I\'ve had a hard time, but I\'ve also made real progress. One difficult moment doesn\'t erase that.\"';

  @override
  String get cbtOriginalThoughtLabel => 'Original thought';

  @override
  String get cbtSummaryTitle => 'Your reframe';

  @override
  String get cbtPatternIdentifiedLabel => 'Pattern identified';

  @override
  String get cbtEvidenceForSummaryLabel => 'Evidence for';

  @override
  String get cbtEvidenceAgainstSummaryLabel => 'Evidence against';

  @override
  String get cbtStartOverButton => 'Start over';

  @override
  String get cbtSaveToJournalButton => 'Save to journal';

  @override
  String get cbtSavedTitle => 'Saved.';

  @override
  String get cbtSavedMessage =>
      'That took courage. Questioning a thought is one of the most powerful things you can do.';

  @override
  String get cbtReframeAnotherButton => 'Reframe another thought';

  @override
  String get cbtNextButton => 'Next';

  @override
  String get cbtReviewButton => 'Review';

  @override
  String get heatmapTitle => 'Activity Heatmap';

  @override
  String get heatmapSubtitle => '13 weeks of your recovery journey';

  @override
  String get heatmapActiveDaysLabel => 'ACTIVE DAYS';

  @override
  String heatmapActiveDaysCount(int active, int total) {
    return '$active of $total days';
  }

  @override
  String get heatmapWhatCountsLabel => 'WHAT COUNTS';

  @override
  String get heatmapCategoryJournal => 'Journal';

  @override
  String get heatmapCategoryCraving => 'Craving';

  @override
  String get heatmapCategoryActivity => 'Activity';

  @override
  String get heatmapCategorySleep => 'Sleep';

  @override
  String get heatmapNothingLogged => 'Nothing was logged this day.';

  @override
  String heatmapIntensityFormat(int intensity) {
    return 'Intensity $intensity/10';
  }

  @override
  String heatmapActivityFormat(String activity, int minutes) {
    return '$activity · $minutes min';
  }

  @override
  String heatmapSleepFormat(String hours, int quality) {
    return '${hours}h · quality $quality/5';
  }

  @override
  String get slipSupportTitle => 'In this moment';

  @override
  String get slipSupportTemporary => 'This feeling is temporary.';

  @override
  String get slipSupportCravingWaves =>
      'Cravings are like waves — they rise, they peak, and they pass. Most last 15 to 20 minutes. You don\'t have to act on this.';

  @override
  String get slipSupportHaltHeader => 'HALT CHECK';

  @override
  String get slipSupportHaltQuestion =>
      'Strong cravings are often signals for something else. Are you feeling any of these right now?';

  @override
  String get slipSupportHaltHungry => 'Hungry';

  @override
  String get slipSupportHaltAngry => 'Angry';

  @override
  String get slipSupportHaltLonely => 'Lonely';

  @override
  String get slipSupportHaltTired => 'Tired';

  @override
  String get slipSupportHaltAdviceHungry =>
      'Eat something small and nourishing.';

  @override
  String get slipSupportHaltAdviceAngry =>
      'Write it down or take a walk to release it.';

  @override
  String get slipSupportHaltAdviceLonely => 'Text or call someone you trust.';

  @override
  String get slipSupportHaltAdviceTired =>
      'Rest. Even a 10-minute lie-down helps.';

  @override
  String get slipSupportRideItOutHeader => 'RIDE IT OUT';

  @override
  String get slipSupportUrgeSurfingTitle => 'Urge surfing';

  @override
  String get slipSupportUrgeSurfingDesc =>
      'Instead of fighting the craving, observe it like a wave you\'re riding. Notice where you feel it in your body. Breathe into it. Let it be there without acting on it.';

  @override
  String get slipSupportBoxBreathingTitle => 'Box breathing';

  @override
  String get slipSupportBoxBreathingInstructions =>
      'In for 4 · Hold for 4 · Out for 4 · Hold for 4. Repeat until the wave softens.';

  @override
  String get slipSupportRightNowHeader => 'RIGHT NOW';

  @override
  String get slipSupportThingsYouCanDo => 'Things you can do this minute';

  @override
  String get slipSupportDistraction0 => 'Drink a glass of cold water';

  @override
  String get slipSupportDistraction1 => 'Step outside for two minutes';

  @override
  String get slipSupportDistraction2 => 'Call or text someone you trust';

  @override
  String get slipSupportDistraction3 => 'Put on a song that shifts your mood';

  @override
  String get slipSupportDistraction4 => 'Write down what you\'re feeling';

  @override
  String get slipSupportLogHeader => 'LOG THIS MOMENT';

  @override
  String get slipSupportRateCravingTitle => 'Rate this craving';

  @override
  String get slipSupportRateCravingDesc =>
      'Logging it helps you see patterns. You\'re not judged — just witnessed.';

  @override
  String get slipSupportIntensityMild => 'Mild';

  @override
  String get slipSupportIntensityIntense => 'Intense';

  @override
  String slipSupportCravingIntensityFormat(int intensity) {
    return '$intensity / 10';
  }

  @override
  String get slipSupportLogCravingButton => 'Log craving';

  @override
  String get slipSupportCravingLoggedTitle => 'Craving logged.';

  @override
  String get slipSupportCravingLoggedMessage =>
      'You noticed it. You named it. That\'s the work.';

  @override
  String get slipSupportNeedToTalk => 'Need to talk to someone?';

  @override
  String get slipSupportCrisisLinesAvailable =>
      'Crisis lines are available 24/7.';

  @override
  String get slipSupportViewLinesButton => 'View lines';

  @override
  String get slipLogTitle => 'Slip Log';

  @override
  String get slipLogSubtitle => 'Your journey, without judgment';

  @override
  String get slipLogInfoText =>
      'Slips are information, not failure. Each record here is evidence that you kept going.';

  @override
  String get slipLogEmpty => 'No slips recorded';

  @override
  String get slipLogEmptySubtitle => 'Your recovery journey is continuing.';

  @override
  String get slipLogNoNote => 'No note recorded.';

  @override
  String slipLogStreakBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days sober',
      one: '1 day sober',
    );
    return '$_temp0';
  }

  @override
  String get backupTitle => 'Backup & Restore';

  @override
  String get backupExportTitle => 'Export backup';

  @override
  String get backupExportDesc =>
      'Save your profile, journal, gratitude, vision board, planner, and everything else you\'ve logged. Choose an encrypted backup (.jfwbk) protected by a passphrase, or a plain JSON file.';

  @override
  String get backupExportButton => 'Export now';

  @override
  String get backupRestoreTitle => 'Restore from backup';

  @override
  String get backupRestoreDesc =>
      'Pick a previously exported backup file. Your current data will be fully replaced.';

  @override
  String get backupRestoreButton => 'Choose backup file';

  @override
  String get backupWhatsIncludedTitle => 'What\'s included';

  @override
  String get backupItemProfile => 'Profile & sober date';

  @override
  String get backupItemJournal => 'Journal entries';

  @override
  String get backupItemGratitude => 'Gratitude entries';

  @override
  String get backupItemSlipLog => 'Slip log';

  @override
  String get backupItemPlanner => 'Planner & training';

  @override
  String get backupItemSecurity => 'Security setting';

  @override
  String get backupItemVisionBoard => 'Vision board';

  @override
  String get backupItemAffirmations => 'Custom affirmations';

  @override
  String get backupPrivacyWarning =>
      'Encrypted backups (.jfwbk) require your passphrase to open. Plain JSON backups are unencrypted — store them somewhere only you can access. Restore fully replaces the data in this app — any entries you\'ve made since the backup will be overwritten. Vision-board photos themselves aren\'t bundled into the backup file (only the references); if you restore on a new device, you may need to re-attach those images.';

  @override
  String get backupConfirmTitle => 'Restore backup?';

  @override
  String get backupConfirmMessage =>
      'This will replace your current data with the backup file. This cannot be undone.';

  @override
  String get backupExportFailed => 'Export failed. Please try again.';

  @override
  String get backupInvalidFile => 'This file is not a Journey Forward backup.';

  @override
  String get backupRestoreFailed =>
      'Restore failed — the file may be corrupted.';

  @override
  String get backupRestoredSuccess =>
      'Backup restored. Your app lock has been cleared — set a new PIN in Settings if needed. Restart to apply.';

  @override
  String get privacyTitle => 'Privacy Policy';

  @override
  String get privacyAbsoluteHeadline => 'Your privacy is absolute.';

  @override
  String get privacyCommitment =>
      'Journey Forward stores everything on your device only. No data is ever sent to any server.';

  @override
  String get privacyAllDataOnDevice => 'All data stays on your device';

  @override
  String get privacyAllDataOnDeviceBody =>
      'Every piece of information you enter — your sober date, journal entries, gratitude notes, and profile — is stored locally on your device using the operating system\'s standard app storage. Nothing is transmitted to any external server, cloud service, or third party at any time.';

  @override
  String get privacyNoInternet => 'No internet connection required';

  @override
  String get privacyNoInternetBody =>
      'Journey Forward works fully offline. All fonts and assets are bundled inside the app. The app itself makes no network requests. If you tap a link to a crisis line, support group, or external resource, your device will open it in your system browser — outside of the app and subject to that site\'s own privacy policy.';

  @override
  String get privacyNoAnalytics => 'No analytics or tracking';

  @override
  String get privacyNoAnalyticsBody =>
      'There are no analytics SDKs, crash reporters, or usage trackers in this app. We do not collect any data about how you use the app, how often you open it, or what features you use.';

  @override
  String get privacyEmergencyContacts => 'Emergency contacts';

  @override
  String get privacyEmergencyContactsBody =>
      'If you add an emergency contact, their name and phone number are stored only on your device as part of your profile. This information is never shared, synced, or backed up automatically.';

  @override
  String get privacyBackupRestore => 'Backup & restore';

  @override
  String get privacyBackupRestoreBody =>
      'When you export a backup, a file is created and shared via your device\'s share sheet — the same way you share photos. You can choose an encrypted backup (.jfwbk, protected by your passphrase) or a plain JSON file. Journey Forward does not receive or store this file. You control where it goes.';

  @override
  String get privacyPINBiometric => 'PIN and biometric lock';

  @override
  String get privacyPINBiometricBody =>
      'If you enable a PIN, it is salted and run through a slow key-derivation hash (PBKDF2-style), then stored in your device\'s encrypted storage — never as plaintext. Biometric unlock uses your device\'s native biometric system; Journey Forward never accesses or stores your biometric data.';

  @override
  String get privacyHowToDelete => 'How to delete your data';

  @override
  String get privacyHowToDeleteBody =>
      'To permanently delete all your data, simply uninstall the app. All data stored by Journey Forward is removed when the app is uninstalled. There is no account to delete because there is no account — only data on your device.';

  @override
  String get privacyChildrenPrivacy => 'Children\'s privacy';

  @override
  String get privacyChildrenPrivacyBody =>
      'Journey Forward is designed for adults aged 18 and over. The app is not directed at children and does not knowingly collect any information from anyone under the age of 18.';

  @override
  String get privacyPolicyUpdates => 'Policy updates';

  @override
  String get privacyPolicyUpdatesBody =>
      'If this privacy policy changes, the update will be included in a new app version. Since we collect no data, changes will only reflect improvements in transparency or new features added to the app.';

  @override
  String get weeklySummaryTitle => 'Weekly Summary';

  @override
  String get weeklySummarySubtitle =>
      'A private summary to share with someone you trust.';

  @override
  String get weeklySummaryThisWeek => 'This week';

  @override
  String get weeklySummaryLastWeek => 'Last week';

  @override
  String get weeklySummaryCustomRange => 'Custom range';

  @override
  String get weeklySummaryCareRecorded => 'Recorded this week';

  @override
  String get weeklySummaryJournalEntries => 'Journal entries';

  @override
  String get weeklySummaryCravingSupport => 'Craving support used';

  @override
  String get weeklySummaryThoughtExercises => 'Thought exercises';

  @override
  String get weeklySummaryMovement => 'Movement / activity';

  @override
  String get weeklySummarySleepLogs => 'Sleep logs';

  @override
  String get weeklySummaryDailyGratitude => 'Daily gratitude';

  @override
  String get weeklySummaryDailyPledge => 'Daily pledge';

  @override
  String get weeklySummaryReflection => 'Reflection';

  @override
  String get weeklySummaryPrivacyNote => 'Privacy note';

  @override
  String get weeklySummaryPrivacyNoteBody =>
      'This summary was created on your device and shared only because you chose to share it.';

  @override
  String get weeklySummaryShareWarning =>
      'This summary may contain personal recovery information. Only share it with someone you trust.';

  @override
  String get weeklySummarySharePdf => 'Share Summary';

  @override
  String get weeklySummaryEdit => 'Edit';

  @override
  String get weeklySummaryPdfError =>
      'Couldn\'t create the PDF right now. Please try again.';

  @override
  String get weeklySummaryNoActivity =>
      'No care entries were recorded for this period. A quiet week still counts.';

  @override
  String weeklySummaryCareDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return 'You returned to your care practices on $count $_temp0 this week.';
  }

  @override
  String weeklySummaryMostUsed(String support) {
    return 'Most used support: $support';
  }

  @override
  String get weeklySummaryQuietWeek =>
      'A quiet week of showing up still counts.';

  @override
  String get weeklySummaryMostUsedLabel => 'Most used';

  @override
  String get weeklySummaryDaysShowedUp => 'days you showed up';

  @override
  String get weeklySummaryAffirmation => 'Another week of showing up.';

  @override
  String get weeklySummaryFooterPrivacy =>
      'Created on your device — shared only because you chose to. Nothing left your phone until now.';

  @override
  String get weeklySummaryAppName => 'Journey Forward';

  @override
  String get safetyModalTitle => 'Before you begin';

  @override
  String get safetyModalBody =>
      'Journey Forward is a companion for your recovery — a private place to track, reflect, and find steadying tools. It is not a medical device and does not provide medical advice, diagnosis, or treatment.';

  @override
  String get safetyModalWithdrawal =>
      'If you are stopping alcohol or certain medications, withdrawal can be medically serious. Please talk to a doctor or healthcare professional about doing it safely.';

  @override
  String get safetyModalCrisis =>
      'And if you are ever in crisis, you deserve immediate human support — helplines are always one tap away.';

  @override
  String get safetyModalCrisisButton => 'View crisis helplines';

  @override
  String get safetyModalDismiss => 'I understand';

  @override
  String get urgeTimerTitle => 'Ride the Wave';

  @override
  String get urgeTimerSubtitle =>
      'Urges feel overwhelming, then they pass — usually within minutes. You don\'t have to fight this one. Just stay with it.';

  @override
  String get urgeTimerPhaseRising =>
      'Notice it like a wave — rising, cresting, falling.';

  @override
  String get urgeTimerPhaseCresting =>
      'You\'re not fighting it. You\'re outlasting it.';

  @override
  String get urgeTimerPhaseFalling =>
      'It\'s already losing strength. Stay with yourself.';

  @override
  String get urgeTimerImSteady => 'I\'m steady now';

  @override
  String get urgeTimerOpenPlan => 'Open my plan';

  @override
  String get urgeTimerCompleteTitle => 'The wave passed';

  @override
  String get urgeTimerCompleteBody =>
      'You stayed with it, and it passed. That\'s exactly how this is done.';

  @override
  String urgeTimerWins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count urges outlasted',
      one: '1 urge outlasted',
    );
    return '$_temp0';
  }

  @override
  String get urgeTimerDone => 'Done';

  @override
  String get toolkitUrgeCardTitle => 'Craving right now?';

  @override
  String get toolkitUrgeCardSubtitle =>
      'Ride the wave — most urges pass in minutes';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String get commonDelete => 'Delete';

  @override
  String commonHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String get meetingsTitle => 'Meetings';

  @override
  String get meetingsSubtitle =>
      'Plan recovery meetings, sponsor calls, and therapy sessions. Get a quiet reminder before each one.';

  @override
  String get meetingsNew => 'New meeting';

  @override
  String get meetingsAdd => 'Add meeting';

  @override
  String get meetingsUpcoming => 'Upcoming';

  @override
  String get meetingsPast => 'Past';

  @override
  String get meetingsDeleteTitle => 'Delete meeting?';

  @override
  String meetingsDeleteBody(String title) {
    return 'This will remove \"$title\" from your schedule.';
  }

  @override
  String get meetingsEmptyTitle => 'No meetings yet';

  @override
  String get meetingsEmptyBody =>
      'Tap \"New meeting\" to schedule your first one. We\'ll quietly remind you before it starts.';

  @override
  String get meetingsEdit => 'Edit meeting';

  @override
  String get meetingsFieldName => 'Name';

  @override
  String get meetingsFieldDate => 'Date';

  @override
  String get meetingsFieldTime => 'Time';

  @override
  String get meetingsFieldWhere => 'Where (optional)';

  @override
  String get meetingsFieldNotes => 'Notes (optional)';

  @override
  String get meetingsNameHint => 'e.g. AA Monday night';

  @override
  String get meetingsWhereHint => 'Zoom, church hall, etc.';

  @override
  String get meetingsNotesHint => 'Anything to remember';

  @override
  String get meetingsNameRequired => 'Please give your meeting a name';

  @override
  String get meetingsRemindToggle => 'Remind me before';

  @override
  String meetingsRemindOn(String label) {
    return 'A quiet notification will fire $label early.';
  }

  @override
  String get meetingsRemindOff => 'No reminder will be sent.';

  @override
  String get meetingsHowEarly => 'How early?';

  @override
  String get meetingsSaveChanges => 'Save changes';

  @override
  String meetingsReminderChip(String label) {
    return '🔔 $label before';
  }

  @override
  String get letterWrite => 'Write a letter';

  @override
  String get letterTitle => 'Letters to future you';

  @override
  String get letterSubtitle =>
      'Write today. Open later. Your future self gets to hear from the version of you who started this.';

  @override
  String get letterReady => 'Ready to open';

  @override
  String get letterSealed => 'Sealed';

  @override
  String get letterEmptyTitle => 'No letters yet';

  @override
  String get letterEmptyBody =>
      'Tap below to write your first sealed letter. Pick day 30, 90, or 365 — and meet yourself there.';

  @override
  String letterSealedUntil(int day) {
    return 'Sealed until day $day';
  }

  @override
  String letterOpenMe(int day) {
    return 'Open me — day $day';
  }

  @override
  String get letterTomorrow => 'Tomorrow';

  @override
  String letterDaysToGo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days to go',
      one: '1 day to go',
    );
    return '$_temp0';
  }

  @override
  String letterWritten(String date) {
    return 'written $date';
  }

  @override
  String get letterAlreadyRead => 'Already read · tap to re-open';

  @override
  String get letterNewSeal => 'New — tap to break the seal';

  @override
  String letterFromPast(int day) {
    return 'Day $day · from past you';
  }

  @override
  String letterWrittenFull(String date) {
    return 'Written $date';
  }

  @override
  String get letterWriteFirst => 'Write something first';

  @override
  String get letterWriterTitle => 'Letter to future you';

  @override
  String letterUnlocks(int day, String date) {
    return 'Unlocks day $day · $date';
  }

  @override
  String letterDayChip(int day) {
    return 'Day $day';
  }

  @override
  String get letterCustom => 'Custom';

  @override
  String get letterBodyHint =>
      'Dear future me…\n\nWhat do you want to remember about who you are right now? What do you want them to know you survived?';

  @override
  String get letterSeal => 'Seal letter';

  @override
  String get letterCustomDayTitle => 'Custom day';

  @override
  String letterCustomDaysFromSober(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days from your sober date',
      one: '1 day from your sober date',
    );
    return '$_temp0';
  }

  @override
  String letterUseDay(int day) {
    return 'Use day $day';
  }

  @override
  String get commonGotIt => 'Got it';

  @override
  String get trNewRecord => 'New record';

  @override
  String get trTitle => 'Thought record';

  @override
  String get trSubtitle =>
      'Catch a thought. Spot the distortion. Walk it through evidence. Land on something truer.';

  @override
  String get trDeleteTitle => 'Delete this record?';

  @override
  String get trEmptyTitle => 'No records yet';

  @override
  String get trEmptyBody =>
      'When a thought hooks you, walk it through this. Most users find one record changes their whole week.';

  @override
  String get trStartRecord => 'Start a record';

  @override
  String trMoodDelta(String value) {
    return '$value mood';
  }

  @override
  String get trLabelSituation => 'Situation';

  @override
  String get trLabelAutoThought => 'Automatic thought';

  @override
  String get trLabelReframe => 'Reframe';

  @override
  String get trCatchFirst => 'Catch the thought first';

  @override
  String get trSaveRecord => 'Save record';

  @override
  String get trStep0Title => 'What\'s the situation?';

  @override
  String get trStep0Sub => 'Where were you, who with, what was happening?';

  @override
  String get trStep0Hint =>
      'e.g. Saturday night. Home alone. Old playlist came on.';

  @override
  String get trStep1Title => 'Catch the thought';

  @override
  String get trStep1Sub => 'The exact automatic thought, word-for-word.';

  @override
  String get trStep1Hint =>
      'e.g. \"I\'ll never be able to enjoy a weekend sober.\"';

  @override
  String get trMoodNow => 'Mood right now';

  @override
  String get trMoodAfter => 'Mood after writing this';

  @override
  String trMoodScale(int value) {
    return '$value / 10';
  }

  @override
  String get trStep2Title => 'Which distortions fit?';

  @override
  String get trStep2Sub =>
      'Pick any that ring true — the label takes the sting out.';

  @override
  String get trTryAsking => 'Try asking:';

  @override
  String get trStep3Title => 'Weigh the evidence';

  @override
  String get trStep3Sub =>
      'Like a courtroom — what supports the thought, what doesn\'t?';

  @override
  String get trEvidenceFor => 'For the thought';

  @override
  String get trEvidenceForHint => 'Facts that suggest the thought is true';

  @override
  String get trEvidenceAgainst => 'Against the thought';

  @override
  String get trEvidenceAgainstHint => 'Facts that contradict or soften it';

  @override
  String get trStep4Title => 'Land somewhere truer';

  @override
  String get trStep4Sub =>
      'Not \"positive thinking\" — a fairer, more accurate version.';

  @override
  String get trStep4Hint =>
      'e.g. \"This is hard right now. I\'ve had sober Saturdays before. One is coming again.\"';

  @override
  String get trDistAllOrNothingName => 'All-or-nothing';

  @override
  String get trDistAllOrNothingDesc =>
      'Seeing things in black and white — anything less than perfect is failure.';

  @override
  String get trDistAllOrNothingPrompt =>
      'Where on the spectrum is the truth actually sitting?';

  @override
  String get trDistCatastrophizingName => 'Catastrophizing';

  @override
  String get trDistCatastrophizingDesc =>
      'Expecting the worst possible outcome and treating it as certain.';

  @override
  String get trDistCatastrophizingPrompt =>
      'What is the most likely outcome, not the worst possible one?';

  @override
  String get trDistOvergeneralizationName => 'Overgeneralization';

  @override
  String get trDistOvergeneralizationDesc =>
      'One bad event becomes a never-ending pattern of defeat.';

  @override
  String get trDistOvergeneralizationPrompt =>
      'Is this really \"always\" / \"never,\" or is it just this once?';

  @override
  String get trDistMindReadingName => 'Mind reading';

  @override
  String get trDistMindReadingDesc =>
      'Assuming you know what others are thinking about you.';

  @override
  String get trDistMindReadingPrompt =>
      'What evidence do I actually have for that assumption?';

  @override
  String get trDistShouldName => '\"Should\" statements';

  @override
  String get trDistShouldDesc =>
      'Beating yourself up with \"should,\" \"must,\" \"ought to.\" Drives shame.';

  @override
  String get trDistShouldPrompt =>
      'Replace \"I should\" with \"I would like to\" — does it land softer?';

  @override
  String get trDistEmotionalReasoningName => 'Emotional reasoning';

  @override
  String get trDistEmotionalReasoningDesc =>
      'Believing something is true because it FEELS true.';

  @override
  String get trDistEmotionalReasoningPrompt =>
      'Feelings are data, not verdicts. What do the facts say?';

  @override
  String get trDistPersonalizationName => 'Personalization';

  @override
  String get trDistPersonalizationDesc =>
      'Blaming yourself for things that aren\'t entirely your fault.';

  @override
  String get trDistPersonalizationPrompt =>
      'What other factors contributed — was this all on me?';

  @override
  String get trDistMentalFilterName => 'Mental filter';

  @override
  String get trDistMentalFilterDesc =>
      'Focusing only on the negative and screening out the positive.';

  @override
  String get trDistMentalFilterPrompt =>
      'What good has happened today that I\'m discounting?';

  @override
  String get trDistLabelingName => 'Labeling';

  @override
  String get trDistLabelingDesc =>
      'Attaching a global label to yourself: \"I\'m a failure,\" \"I\'m broken.\"';

  @override
  String get trDistLabelingPrompt =>
      'Separate the behaviour from the person. What would I tell a friend?';

  @override
  String get trDistDisqualifyingPositiveName => 'Disqualifying the positive';

  @override
  String get trDistDisqualifyingPositiveDesc =>
      'Telling yourself good things \"don\'t count.\"';

  @override
  String get trDistDisqualifyingPositivePrompt =>
      'Why would that achievement count if a friend did it?';

  @override
  String get commonRead => 'Read';

  @override
  String get commonPlan => 'Plan';

  @override
  String get commonUndo => 'Undo';

  @override
  String get strengthCardTitle => 'Today\'s strength';

  @override
  String strengthHardDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hard days',
      one: '1 hard day',
    );
    return '$_temp0';
  }

  @override
  String get strengthLetterTitle => 'A letter is waiting for you';

  @override
  String strengthLetterSub(int day) {
    return 'You sealed it on day $day. Open it.';
  }

  @override
  String strengthPatternTitle(String weekday, String time) {
    return '${weekday}s, $time';
  }

  @override
  String strengthPatternSub(int count, int total) {
    return '$count of your $total cravings cluster here. Plan a ritual.';
  }

  @override
  String get strengthHardRecorded => 'Hard day recorded';

  @override
  String get strengthHardAsk => 'Staying sober on a hard day?';

  @override
  String get strengthHardRecordedSub =>
      'Time sober counts the days. This records the hard ones.';

  @override
  String get strengthHardAskSub =>
      'Mark it — being present on a hard day is real recovery.';

  @override
  String get strengthMarkIt => 'Mark it';

  @override
  String get strengthHardLogged =>
      'Logged. Staying present on a hard day matters.';

  @override
  String get strengthWriteFirst => 'Write a letter to future you';

  @override
  String get strengthWriteAnother => 'Write another letter';

  @override
  String get puzzleActivity5Label => 'Colour Calm';

  @override
  String get puzzleActivity5Desc =>
      'Tap the expanding circles and let your mind follow.';

  @override
  String get puzzleActivity5Duration => '3 min';

  @override
  String get puzzleHomeTitle => 'Calm Activities';

  @override
  String get puzzleHomeSubtitle => 'Short exercises to calm and refocus';

  @override
  String get puzzlesHomeTitle => 'Puzzles';

  @override
  String get puzzlesHomeSubtitle => 'A few minutes of focused play';

  @override
  String get puzzleSlideLabel => 'Slide Puzzle';

  @override
  String get puzzleSlideDesc => 'Slide the tiles into order, 1 through 15.';

  @override
  String get puzzleSlideDuration => '5 min';

  @override
  String get puzzleSlideHint => 'Tap a tile next to the gap to slide it in.';

  @override
  String get puzzle2048Label => '2048';

  @override
  String get puzzle2048Desc =>
      'Swipe to merge matching numbers. Can you reach 2048?';

  @override
  String get puzzle2048Duration => '10 min';

  @override
  String get puzzle2048Score => 'Score';

  @override
  String get puzzle2048Win => 'You reached 2048!';

  @override
  String get puzzle2048GameOver => 'Board full — no moves left.';

  @override
  String get puzzle2048Hint =>
      'Swipe up, down, left or right to move the tiles.';

  @override
  String get puzzle2048KeepGoing => 'Keep going';

  @override
  String get emergencyCalmTitle => 'Calm Activities';

  @override
  String get puzzleCountdownIntro =>
      'Counting backwards by 3 interrupts anxiety\nand brings you into the present.';

  @override
  String get puzzleCountdownDone => 'Done!';

  @override
  String get puzzleCountdownRestart => 'Tap to restart';

  @override
  String get puzzleCountdownSubtract => 'Tap to subtract 3';

  @override
  String get puzzleGratitudePrompt0 => 'Something in nature I noticed today…';

  @override
  String get puzzleGratitudePrompt1 => 'A person who has shown me kindness…';

  @override
  String get puzzleGratitudePrompt2 => 'A simple pleasure I often overlook…';

  @override
  String get puzzleGratitudePrompt3 =>
      'Something my body does for me every day…';

  @override
  String get puzzleGratitudePrompt4 => 'A memory that still makes me smile…';

  @override
  String get puzzleGratitudePrompt5 =>
      'Something I\'ve learned in the past year…';

  @override
  String get puzzleGratitudePrompt6 => 'A challenge that made me stronger…';

  @override
  String get puzzleGratitudePrompt7 => 'A small comfort that I appreciate…';

  @override
  String get puzzleGratitudePrompt8 =>
      'Someone who believed in me when I didn\'t…';

  @override
  String get puzzleGratitudePrompt9 => 'A moment of peace I\'ve experienced…';

  @override
  String get puzzleGratitudePrompt10 => 'A skill or talent I\'m glad I have…';

  @override
  String get puzzleGratitudePrompt11 => 'Something I\'m looking forward to…';

  @override
  String get puzzleGratitudePrompt12 => 'A kindness I showed someone recently…';

  @override
  String get puzzleGratitudePrompt13 =>
      'Something that made me laugh recently…';

  @override
  String get puzzleGratitudePrompt14 => 'A place that brings me peace…';

  @override
  String get puzzleReflectionHint => 'Write your reflection here…';

  @override
  String get puzzleShufflePrompt => 'Shuffle prompt';

  @override
  String puzzleMemoryMoves(int count) {
    return 'Moves: $count';
  }

  @override
  String get puzzleNewGame => 'New game';

  @override
  String get puzzleWellDone => 'Well done!';

  @override
  String puzzleCompletedInMoves(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Completed in $count moves',
      one: 'Completed in 1 move',
    );
    return '$_temp0';
  }

  @override
  String get puzzlePlayAgain => 'Play again';

  @override
  String get puzzleStrengthIntro =>
      'How strong does each feel today? This is just for you — there\'s no right answer.';

  @override
  String get puzzleStrength0 => 'Courage';

  @override
  String get puzzleStrength1 => 'Patience';

  @override
  String get puzzleStrength2 => 'Honesty';

  @override
  String get puzzleStrength3 => 'Resilience';

  @override
  String get puzzleStrength4 => 'Gratitude';

  @override
  String get puzzleStrength5 => 'Hope';

  @override
  String get puzzleStrength6 => 'Connection';

  @override
  String get puzzleStrength7 => 'Purpose';

  @override
  String puzzleStrengthRating(int value) {
    return '$value/5';
  }

  @override
  String get puzzleStrengthAffirmation =>
      'Wherever you rated yourself today — you showed up. That alone is strength.';

  @override
  String get puzzleNowStep0Title => 'Notice';

  @override
  String get puzzleNowStep0Body =>
      'Look around you right now. Name 3 things you can see without judging them. Just see them as they are.';

  @override
  String get puzzleNowStep1Title => 'Feel';

  @override
  String get puzzleNowStep1Body =>
      'Place both feet flat on the floor. Feel the weight of your body. Notice one sensation in your body right now — warmth, tension, breath.';

  @override
  String get puzzleNowStep2Title => 'Choose';

  @override
  String get puzzleNowStep2Body =>
      'You have arrived in this moment. What is one small, kind thing you can do for yourself in the next 10 minutes?';

  @override
  String get puzzleComplete => 'Complete';

  @override
  String get puzzleColorIntro => 'Tap anywhere. Breathe with the circles.';

  @override
  String get puzzleColorTapAnywhere => 'Tap anywhere';

  @override
  String get backupShareSubject => 'Journey Forward Backup';

  @override
  String get backupShareSubjectEncrypted =>
      'Journey Forward Backup (encrypted)';

  @override
  String get backupProtectTitle => 'Protect your backup?';

  @override
  String get backupEnterPassphraseTitle => 'Enter backup passphrase';

  @override
  String get backupProtectDesc =>
      'Set a passphrase to encrypt the backup file. Without it, anyone with the file can read your journal.';

  @override
  String get backupEnterPassphraseDesc =>
      'This file is encrypted. Type the passphrase you used when exporting.';

  @override
  String get backupPassphraseLabel => 'Passphrase';

  @override
  String get backupConfirmPassphraseLabel => 'Confirm passphrase';

  @override
  String get backupSkipPlainJson => 'Skip (plain JSON)';

  @override
  String get backupPassphraseEmptyError => 'Passphrase cannot be empty.';

  @override
  String get backupPassphraseMismatchError => 'Passphrases do not match.';

  @override
  String get backupPassphraseTooShortError =>
      'Use at least 8 characters — longer is safer.';

  @override
  String get backupEncryptButton => 'Encrypt';

  @override
  String get backupUnlockButton => 'Unlock';

  @override
  String cbtReframeNotePrefix(String reframe) {
    return 'Reframe: $reframe';
  }

  @override
  String get crisisRegionInternationalUs => 'International / US';

  @override
  String get crisisRegionUkIreland => 'UK / Ireland';

  @override
  String get crisisRegionSouthAfrica => 'South Africa';

  @override
  String get crisisRegionAustralia => 'Australia';

  @override
  String get crisisRegionCanada => 'Canada';

  @override
  String get crisisRegionNewZealand => 'New Zealand';

  @override
  String get crisisRegionEurope => 'Europe';

  @override
  String get crisisHours247 => '24/7';

  @override
  String get crisisHoursBusiness => 'Business hours';

  @override
  String get crisisHoursOffice => 'Office hours';

  @override
  String get crisisHoursMonFri => 'Mon-Fri 9am-8pm';

  @override
  String get crisisLine988Name => '988 Suicide & Crisis Lifeline';

  @override
  String get crisisLine988Desc =>
      'US mental health & substance use crisis — call or text';

  @override
  String get crisisLineSamhsaName => 'SAMHSA Helpline';

  @override
  String get crisisLineSamhsaDesc => 'Free, confidential substance abuse help';

  @override
  String get crisisLineCrisisTextName => 'Crisis Text Line';

  @override
  String get crisisLineCrisisTextNumber => 'Text HOME to 741741';

  @override
  String get crisisLineCrisisTextDesc => 'Text-based crisis support';

  @override
  String get crisisLineAaGeneralName => 'AA General Service';

  @override
  String get crisisLineAaGeneralDesc => 'Alcoholics Anonymous support';

  @override
  String get crisisLineSmartUsName => 'SMART Recovery';

  @override
  String get crisisLineSmartUsDesc => 'Science-based recovery support';

  @override
  String get crisisLineAaUkName => 'AA United Kingdom';

  @override
  String get crisisLineAaUkDesc => 'Alcoholics Anonymous UK';

  @override
  String get crisisLineDrinklineName => 'Drinkline';

  @override
  String get crisisLineDrinklineDesc => 'National alcohol helpline';

  @override
  String get crisisLineSamaritansName => 'Samaritans';

  @override
  String get crisisLineSamaritansDesc => 'Emotional support in crisis';

  @override
  String get crisisLineFrankName => 'Frank';

  @override
  String get crisisLineFrankDesc => 'Drug and alcohol helpline';

  @override
  String get crisisLineAaIrelandName => 'AA Ireland';

  @override
  String get crisisLineAaIrelandDesc => 'Alcoholics Anonymous Ireland';

  @override
  String get crisisLineSadagSuicideName => 'Suicide Crisis Helpline';

  @override
  String get crisisLineSadagSuicideDesc => 'SADAG 24-hour suicide crisis line';

  @override
  String get crisisLineSadagSubstanceName => 'SADAG Substance Abuse';

  @override
  String get crisisLineSadagSubstanceDesc =>
      'South African Depression and Anxiety Group';

  @override
  String get crisisLineSadagSmsName => 'SADAG SMS Line';

  @override
  String get crisisLineSadagSmsDesc => 'Text-based support';

  @override
  String get crisisLineAaSaName => 'AA South Africa';

  @override
  String get crisisLineAaSaDesc => 'Alcoholics Anonymous SA';

  @override
  String get crisisLineLifelineSaName => 'Lifeline South Africa';

  @override
  String get crisisLineLifelineSaDesc => 'Crisis counselling';

  @override
  String get crisisLineFamsaName => 'FAMSA';

  @override
  String get crisisLineFamsaDesc => 'Family and Marriage Society of SA';

  @override
  String get crisisLineSancaName => 'SANCA';

  @override
  String get crisisLineSancaDesc => 'SA National Council on Alcoholism';

  @override
  String get crisisLineAaAustraliaName => 'AA Australia';

  @override
  String get crisisLineAaAustraliaDesc => 'Alcoholics Anonymous Australia';

  @override
  String get crisisLineBeyondBlueName => 'Beyond Blue';

  @override
  String get crisisLineBeyondBlueDesc => 'Mental health support';

  @override
  String get crisisLineLifelineAuName => 'Lifeline Australia';

  @override
  String get crisisLineLifelineAuDesc => 'Crisis support';

  @override
  String get crisisLineTurningPointName => 'Turning Point';

  @override
  String get crisisLineTurningPointDesc => 'Alcohol and drug treatment';

  @override
  String get crisisLineSmartAuName => 'SMART Recovery AU';

  @override
  String get crisisLineSmartAuDesc => 'Science-based recovery';

  @override
  String get crisisLineCrisisServicesCanadaName => 'Crisis Services Canada';

  @override
  String get crisisLineCrisisServicesCanadaDesc => 'National crisis line';

  @override
  String get crisisLineCamhName => 'CAMH';

  @override
  String get crisisLineCamhDesc => 'Centre for Addiction and Mental Health';

  @override
  String get crisisLineAaCanadaName => 'AA Canada';

  @override
  String get crisisLineAaCanadaDesc => 'Alcoholics Anonymous Canada';

  @override
  String get crisisLineConnexOntarioName => 'ConnexOntario';

  @override
  String get crisisLineConnexOntarioDesc => 'Mental health and addictions';

  @override
  String get crisisLineAaNzName => 'AA New Zealand';

  @override
  String get crisisLineAaNzDesc => 'Alcoholics Anonymous NZ';

  @override
  String get crisisLineLifelineNzName => 'Lifeline NZ';

  @override
  String get crisisLineLifelineNzDesc => 'Crisis support';

  @override
  String get crisisLineNeedToTalkName => 'Need to Talk';

  @override
  String get crisisLineNeedToTalkDesc => 'Free call or text';

  @override
  String get crisisLineAlcoholDrugNzName => 'Alcohol Drug Helpline';

  @override
  String get crisisLineAlcoholDrugNzDesc => 'Alcohol and drug support';

  @override
  String get crisisLineGermanyDhsName => 'Germany — DHS';

  @override
  String get crisisLineGermanyDhsDesc =>
      'Deutsche Hauptstelle fuer Suchtfragen';

  @override
  String get crisisLineFranceEcouteName => 'France — Ecoute Alcool';

  @override
  String get crisisLineFranceEcouteDesc => 'National alcohol helpline';

  @override
  String get crisisLineNetherlandsJellinekName => 'Netherlands — Jellinek';

  @override
  String get crisisLineNetherlandsJellinekDesc => 'Addiction treatment';

  @override
  String get crisisLineSpainAaName => 'Spain — AA Espana';

  @override
  String get crisisLineSpainAaDesc => 'Alcoholics Anonymous Spain';

  @override
  String get dailyIntentionSetTitle => 'Set today\'s intention';

  @override
  String get dailyIntentionEditTitle => 'Edit today\'s intention';

  @override
  String get dailyIntentionSubtitle =>
      'One small thing for your recovery today.';

  @override
  String get dailyIntentionHint => 'e.g. Call my sponsor before noon.';

  @override
  String get dailyIntentionSaveButton => 'Save intention';

  @override
  String get dailySaving => 'Saving…';

  @override
  String get dailyReviewTitle => 'How did today go?';

  @override
  String get dailyReviewPrompt => 'This morning you said:';

  @override
  String get dailyReviewDidIt => 'Did it';

  @override
  String get dailyReviewPartly => 'Partly';

  @override
  String get dailyReviewNotYet => 'Not yet';

  @override
  String get dailyCapitalTitle => 'Recovery capital this week';

  @override
  String get dailyCapitalConnected => 'Connected with someone supportive';

  @override
  String get dailyCapitalPhysical => 'Moved my body';

  @override
  String get dailyCapitalSlept => 'Slept enough most nights';

  @override
  String get dailyCapitalHelpfulPlace => 'Spent time somewhere that helps me';

  @override
  String get dailyCapitalMeaningful => 'Did something meaningful to me';

  @override
  String get dailyCapitalNoteHint => 'A note for future-you (optional)';

  @override
  String get dailyCapitalSaveButton => 'Save this week';

  @override
  String get emergencyCloseGuide => '✕ Close';

  @override
  String get cbtGuideThoughtsHint => 'Your thoughts…';

  @override
  String cbtGuideStepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '1 step',
    );
    return '$_temp0';
  }

  @override
  String get reasonsWhyHeading => 'Why I\'m doing this.';

  @override
  String get reasonsEmptyHint =>
      'Add your reasons in Settings → My Motivation. Reading them during a craving can be powerful.';

  @override
  String get haltCheckInPrompt => 'Before acting on a craving, check in:';

  @override
  String get playTapeHeroHeading =>
      'Pause for a moment.\nLook at what happens next.';

  @override
  String get playTapeIntro =>
      'An urge can feel urgent, but it is temporary. Before you act, walk yourself through the next few moments, tonight, and tomorrow morning.';

  @override
  String get playTapeDrinkTitle => 'If I drink now';

  @override
  String get playTapeSoberTitle => 'If I stay sober';

  @override
  String get playTapePhaseRightNow => 'Right now';

  @override
  String get playTapePhaseTonight => 'Later tonight';

  @override
  String get playTapePhaseTomorrow => 'Tomorrow';

  @override
  String get playTapeDrinkNow0 => 'Relief may feel immediate';

  @override
  String get playTapeDrinkNow1 => 'The craving softens for a little while';

  @override
  String get playTapeDrinkTonight0 => 'The difficult feelings often return';

  @override
  String get playTapeDrinkTonight1 => 'Sleep may be disrupted';

  @override
  String get playTapeDrinkTonight2 => 'My momentum is interrupted';

  @override
  String get playTapeDrinkTomorrow0 => 'I may wake with regret';

  @override
  String get playTapeDrinkTomorrow1 => 'The next day asks more of me';

  @override
  String get playTapeDrinkTomorrow2 => 'Starting again feels harder';

  @override
  String get playTapeSoberNow0 => 'The craving rises, then passes';

  @override
  String get playTapeSoberNow1 => 'I give myself space instead of reacting';

  @override
  String get playTapeSoberTonight0 => 'I protect my peace';

  @override
  String get playTapeSoberTonight1 => 'I go to bed with clarity';

  @override
  String get playTapeSoberTonight2 => 'I strengthen self-trust';

  @override
  String get playTapeSoberTomorrow0 => 'I wake up clear-headed';

  @override
  String get playTapeSoberTomorrow1 => 'My momentum grows';

  @override
  String get playTapeSoberTomorrow2 => 'I feel proud of myself';

  @override
  String get playTapeWhatHelpsTitle => 'What would help right now?';

  @override
  String get playTapeActionBreathe => 'Breathe with me';

  @override
  String get playTapeActionJournal => 'Open my journal';

  @override
  String get playTapeActionReason => 'Read my reason';

  @override
  String get playTapeActionRideWave => 'Ride the wave';

  @override
  String get heatmapRecoveryMapTitle => 'Recovery Map';

  @override
  String get heatmapSubtitleLastYear =>
      'Last 365 days · A quiet record of the days you showed up.';

  @override
  String get heatmapSubtitleSinceStart =>
      'Since you began · A quiet record of the days you showed up.';

  @override
  String get heatmapFilterAll => 'All';

  @override
  String get heatmapFilterCravings => 'Cravings';

  @override
  String get heatmapFilterThoughts => 'Thoughts';

  @override
  String get heatmapFilterMovement => 'Movement';

  @override
  String get heatmapStatCareDays => 'Care days';

  @override
  String get heatmapStatTotalCheckIns => 'Total check-ins';

  @override
  String get heatmapStatMostUsed => 'Most used';

  @override
  String get heatmapStatThisMonth => 'This month';

  @override
  String get heatmapSeeFullYear => 'See full year';

  @override
  String get heatmapShowLess => 'Show less';

  @override
  String get heatmapDowMon => 'M';

  @override
  String get heatmapDowTue => 'T';

  @override
  String get heatmapDowWed => 'W';

  @override
  String get heatmapDowThu => 'T';

  @override
  String get heatmapDowFri => 'F';

  @override
  String get heatmapDowSat => 'S';

  @override
  String get heatmapDowSun => 'S';

  @override
  String get heatmapLegendBeforeBegan => 'Before you began';

  @override
  String get heatmapLegendNoEntry => 'No entry';

  @override
  String get heatmapDayNoEntryTitle => 'No entry recorded.';

  @override
  String get heatmapDayQuietCounts => 'A quiet day still counts.';

  @override
  String get heatmapSectionCravingSupport => 'Craving support';

  @override
  String get heatmapEntryFallback => '(entry)';

  @override
  String heatmapThoughtFallback(String type) {
    return '(thought — $type)';
  }

  @override
  String get heatmapDayShowedUp => 'You showed up for yourself today.';

  @override
  String get historyScreenTitle => 'My History';

  @override
  String get historyDeleteEntryTitle => 'Delete entry?';

  @override
  String get historyDeleteEntryBody => 'This cannot be undone.';

  @override
  String get historyStatJournalThisWeek => 'Journal this week';

  @override
  String get historyStatGratitudeThisWeek => 'Gratitude this week';

  @override
  String get historyStatDaysSober => 'Days sober';

  @override
  String historyDaysShort(int days) {
    return '${days}d';
  }

  @override
  String get historyCardJournal => 'Journal entry';

  @override
  String get historyTapToReadMore => 'Tap to read more';

  @override
  String get historyCardGratitude => 'Gratitude';

  @override
  String get historyCardCraving => 'Craving';

  @override
  String get historyCardThought => 'Thought';

  @override
  String get historyActivityRun => 'Run';

  @override
  String get historyActivityCycle => 'Cycle';

  @override
  String get historyActivitySwim => 'Swim';

  @override
  String get historyActivityWeights => 'Weights';

  @override
  String get historyActivityGeneric => 'Activity';

  @override
  String historyActivityDistanceTime(String distance, int minutes) {
    return '$distance km · $minutes min';
  }

  @override
  String historySleepHours(String hours) {
    return '$hours hours';
  }

  @override
  String historySleepQuality(String quality) {
    return 'Quality: $quality';
  }

  @override
  String get historySlipReset => 'Reset';

  @override
  String historySlipSoberAtTime(String streak) {
    return 'Sober at the time: $streak';
  }

  @override
  String get historyEmptyAllTitle => 'Nothing here yet';

  @override
  String get historyEmptyAllSub => 'Your entries will appear here';

  @override
  String get historyEmptyCravingsTitle => 'No cravings yet';

  @override
  String get historyEmptyCravingsSub =>
      'Log your cravings from the home screen';

  @override
  String get historyEmptyThoughtsTitle => 'No thoughts yet';

  @override
  String get historyEmptyThoughtsSub =>
      'Log your thoughts from the home screen';

  @override
  String get historyEmptyActivityTitle => 'No exercise yet';

  @override
  String get historyEmptyActivitySub =>
      'Log your exercise from the home screen';

  @override
  String get historyEmptySleepTitle => 'No sleep yet';

  @override
  String get historyEmptySleepSub => 'Log your sleep from the home screen';

  @override
  String get historyEmptyJournalTitle => 'No journal entries yet';

  @override
  String get historyEmptyJournalSub =>
      'Log your journal entries from the home screen';

  @override
  String get historyEmptyGratitudeTitle => 'No gratitude notes yet';

  @override
  String get historyEmptyGratitudeSub =>
      'Log your gratitude notes from the home screen';

  @override
  String get historyEmptySlipsTitle => 'No slips yet';

  @override
  String get historyEmptySlipsSub => 'Log your slips from the home screen';

  @override
  String get homeHeroQuote0 => 'Every day forward is a win.';

  @override
  String get homeHeroQuote1 => 'Progress is built in days like this.';

  @override
  String get homeHeroQuote2 => 'You\'re farther than yesterday.';

  @override
  String get homeHeroQuote3 => 'Today counted. Tomorrow will too.';

  @override
  String get homeHeroQuote4 => 'Momentum compounds. Keep going.';

  @override
  String get homeHeroQuote5 => 'Each day is a brick in the wall.';

  @override
  String get homeHeroQuote6 => 'You chose this. Again.';

  @override
  String get homeHeroQuote7 => 'Sober is a verb today.';

  @override
  String get homeHeroQuote8 => 'The streak is the strategy.';

  @override
  String get homeHeroQuote9 => 'You earned this day.';

  @override
  String get homeHeroQuote10 => 'Forward is the only direction.';

  @override
  String get homeHeroQuote11 => 'Days stack into years.';

  @override
  String get homeHeroQuote12 => 'Discipline becomes identity.';

  @override
  String get homeHeroQuote13 => 'You\'re rewriting the story.';

  @override
  String get homeHeroQuote14 => 'The next right choice is the whole game.';

  @override
  String get homeHeroQuote15 => 'Show up. The rest follows.';

  @override
  String get homeHeroQuote16 => 'Old life. New chapter.';

  @override
  String get homeHeroQuote17 => 'You did the hard thing today.';

  @override
  String get homeHeroQuote18 => 'Progress isn\'t loud. It\'s daily.';

  @override
  String get homeHeroQuote19 => 'Better is built, not found.';

  @override
  String get homeHeroQuote20 => 'Today is the receipt.';

  @override
  String get homeHeroQuote21 => 'You moved the needle.';

  @override
  String get homeHeroQuote22 => 'Sobriety is the work and the reward.';

  @override
  String get homeHeroQuote23 => 'What you do daily defines you.';

  @override
  String get homeHeroQuote24 => 'Hours add to days. Days add to years.';

  @override
  String get homeHeroQuote25 => 'You\'re closer than you were.';

  @override
  String get homeHeroQuote26 => 'The first hard choice is behind you.';

  @override
  String get homeHeroQuote27 => 'You\'re not who you were yesterday.';

  @override
  String get homeHeroQuote28 => 'Action over feeling. Always.';

  @override
  String get homeHeroQuote29 => 'Hard now. Easier later.';

  @override
  String get homeHeroQuote30 => 'You\'re stacking days.';

  @override
  String get homeHeroQuote31 => 'The streak doesn\'t lie.';

  @override
  String get homeHeroQuote32 => 'Choose forward. Choose again.';

  @override
  String get homeHeroQuote33 => 'You showed up. That\'s everything.';

  @override
  String get homeHeroQuote34 => 'Days like this are how it changes.';

  @override
  String get homeHeroQuote35 => 'You\'re building something real.';

  @override
  String get homeHeroQuote36 => 'Today is proof.';

  @override
  String get homeHeroQuote37 => 'Discipline is freedom.';

  @override
  String get homeHeroQuote38 => 'One choice. Then the next.';

  @override
  String get homeHeroQuote39 => 'The reps are the result.';

  @override
  String get homeHeroQuote40 => 'You\'re earning your future.';

  @override
  String get homeHeroQuote41 => 'Effort compounds quietly.';

  @override
  String get homeHeroQuote42 => 'Today\'s win is tomorrow\'s foundation.';

  @override
  String get homeHeroQuote43 => 'Forward is enough.';

  @override
  String get homeHeroQuote44 =>
      'You\'re not starting over. You\'re continuing.';

  @override
  String get homeHeroQuote45 => 'The work is the win.';

  @override
  String get homeHeroQuote46 => 'Strong is what you become.';

  @override
  String get homeHeroQuote47 => 'The hard days build you.';

  @override
  String get homeHeroQuote48 => 'Decision by decision. Day by day.';

  @override
  String get homeHeroQuote49 => 'You\'re doing it.';

  @override
  String get homeRecoveryBody0 =>
      'Your body begins adjusting. Hydration and rest are your allies right now.';

  @override
  String get homeRecoveryBody1 =>
      'Heart rate and sleep patterns may begin to shift as your body finds its rhythm.';

  @override
  String get homeRecoveryBody2 =>
      'A significant window — be patient with yourself. Seek support if anything feels unsafe.';

  @override
  String get homeRecoveryBody3 =>
      'The most intense early adjustment may begin to ease. A small window of calm can emerge.';

  @override
  String get homeRecoveryBody4 =>
      'Restorative sleep often begins to return. Vivid dreams can be a sign of deep repair.';

  @override
  String get homeRecoveryBody5 =>
      'Physical stamina may begin to return. Concentration and memory are beginning to sharpen.';

  @override
  String get homeRecoveryBody6 =>
      'Many people describe a sense of physical relief settling in around this point.';

  @override
  String get homeRecoveryBody7 =>
      'Day-to-day satisfaction may slowly start to feel more accessible again.';

  @override
  String get homeRecoveryBody8 =>
      'Many people notice a steadier baseline. Urges may become less frequent and easier to move through.';

  @override
  String get homeRecoveryBody9 =>
      'For many people, the long-term load on sleep, energy, and mood begins to ease at this point.';

  @override
  String get homeRecoveryBody10 =>
      'The space you have created can continue to deepen over time — one ordinary day at a time.';

  @override
  String get homeRecoveryJustStarting => 'Just Starting';

  @override
  String get homeRecoveryJustStartingBody =>
      'The decision you made today already matters. Be gentle with yourself.';

  @override
  String get homeRecoveryNow => 'now';

  @override
  String homeRecoveryInMin(int min) {
    return 'in $min min';
  }

  @override
  String homeRecoveryInHrs(int hrs) {
    return 'in $hrs hrs';
  }

  @override
  String homeRecoveryInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'in $_temp0';
  }

  @override
  String get homeHealingTimelineHeader => 'THE HEALING TIMELINE';

  @override
  String homeRecoveryNext(String label) {
    return 'Next: $label';
  }

  @override
  String get homeRecoveryAllMilestones =>
      'You have reached every milestone. Remarkable.';

  @override
  String get homeMilestoneNode5Label => 'Six months';

  @override
  String get homeMilestoneNode6Label => 'One year';

  @override
  String homeGreetingName(String name) {
    return 'Hi, $name';
  }

  @override
  String get homeStartsIn => 'STARTS IN';

  @override
  String get homeTimeSober => 'TIME SOBER';

  @override
  String homeCounterDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'DAYS',
      one: 'DAY',
    );
    return '$_temp0';
  }

  @override
  String homeCounterHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'HOURS',
      one: 'HOUR',
    );
    return '$_temp0';
  }

  @override
  String homeCounterMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'MINUTES',
      one: 'MINUTE',
    );
    return '$_temp0';
  }

  @override
  String homeCounterSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'SECONDS',
      one: 'SECOND',
    );
    return '$_temp0';
  }

  @override
  String get homeMilestoneTimingStart => 'start';

  @override
  String homeMilestoneTimingDay(int day) {
    return 'Day $day';
  }

  @override
  String get homeMilestoneTimingOneYear => '1 year';

  @override
  String homeMilestoneTimingYears(int years) {
    return '$years yr';
  }

  @override
  String get homeJourneyProgressComplete =>
      'One year of sobriety — remarkable.';

  @override
  String homeJourneyDaysTo(int count, String label) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0 to $label';
  }

  @override
  String get homeIntentionTitle => 'Today\'s intention';

  @override
  String get homeIntentionPrompt => 'One small thing for your recovery today.';

  @override
  String get homeIntentionReviewPrompt => 'How did today go?';

  @override
  String get homeIntentionOutcomeDid => '✓ You did it.';

  @override
  String get homeIntentionOutcomePartly => '~ Partly — that still counts.';

  @override
  String get homeIntentionOutcomeNotYet => '… Not yet — tomorrow is a new day.';

  @override
  String get homeCravingHaltQuestion => 'Right now, are you any of these?';

  @override
  String get homeCravingHaltBlurb => 'Naming it slows the wave down — H.A.L.T.';

  @override
  String get homeCravingOutcomeQuestion => 'How did it turn out?';

  @override
  String get homeCravingOutcomeStayedSober => 'Stayed sober';

  @override
  String get homeCravingOutcomeReachedOut => 'Reached out';

  @override
  String get homeCravingOutcomePracticedTools => 'Practiced tools';

  @override
  String get homeLastTimeOutcomeSober => 'and you stayed sober';

  @override
  String get homeLastTimeOutcomeSlipped => 'and you slipped — useful to know';

  @override
  String homeLastTimeDuration(int minutes) {
    return ' (passed in $minutes min)';
  }

  @override
  String homeLastTimeBlurb(String response, String duration, String outcome) {
    return 'Last time around this level you $response$duration $outcome.';
  }

  @override
  String get homeThoughtSavedPrivately => 'Thought saved privately';

  @override
  String homeThoughtSaveError(String error) {
    return 'Could not save: $error';
  }

  @override
  String get homeThoughtWriteHintOptional =>
      'Write the thought in your own words (optional).';

  @override
  String get homeActivityTypeRun => 'Run';

  @override
  String get homeActivityTypeCycle => 'Cycle';

  @override
  String get homeActivityTypeSwim => 'Swim';

  @override
  String get homeActivityTypeGym => 'Gym';

  @override
  String get homeActivityTimeDistance => 'Time & distance';

  @override
  String get homeActivityDurationMin => 'Duration (min)';

  @override
  String homeActivityDistanceLabel(String unit) {
    return 'Distance ($unit)';
  }

  @override
  String get homeUnitMin => 'min';

  @override
  String get homeUnitKm => 'km';

  @override
  String get homeUnitMiles => 'miles';

  @override
  String get homeSleepFactorsShortQuestion => 'What affected sleep?';

  @override
  String get homeSleepNotesHintShort =>
      'Notes (optional) - e.g., woke once, settled again quickly.';

  @override
  String get insightsStatSub7Days => '7 days';

  @override
  String get insightsStatAvgSleep => 'Avg Sleep';

  @override
  String get insightsStatActiveDays => 'Active Days';

  @override
  String get insightsStatJournalDays => 'Journal Days';

  @override
  String get insightsChartMood => 'Mood — 7 days';

  @override
  String get insightsChartCravings => 'Cravings — 7 days';

  @override
  String get insightsChartSleep => 'Sleep — 7 days (hours)';

  @override
  String get insightsChartExercise => 'Exercise — 7 days (minutes)';

  @override
  String get insightsEmptyMood => 'No journal entries yet';

  @override
  String get insightsEmptyCravings => 'No cravings logged';

  @override
  String get insightsEmptySleep => 'No sleep logged';

  @override
  String get insightsEmptyActivity => 'No activity logged';

  @override
  String get insightsMoodHard => 'Hard';

  @override
  String get insightsThoughtPatterns => 'Thought Patterns — 7 days';

  @override
  String get insightsEmptyThoughts => 'No thoughts logged';

  @override
  String get insightsThoughtChallenging => 'Challenging';

  @override
  String get insightsWeekdayMon => 'M';

  @override
  String get insightsWeekdayTue => 'T';

  @override
  String get insightsWeekdayWed => 'W';

  @override
  String get insightsWeekdayThu => 'T';

  @override
  String get insightsWeekdayFri => 'F';

  @override
  String get insightsWeekdaySat => 'S';

  @override
  String get insightsWeekdaySun => 'S';

  @override
  String get journalDetailUnlockEntry => 'Unlock entry';

  @override
  String get journalDetailLockEntry => 'Lock entry';

  @override
  String get journalDetailUnlockThisEntry => 'Unlock this entry';

  @override
  String get journalDetailOpenThisEntry => 'Open this entry';

  @override
  String get journalDetailEdit => 'Edit';

  @override
  String get journalDetailEditEntry => 'Edit entry';

  @override
  String journalDetailEdited(String time) {
    return 'Edited $time';
  }

  @override
  String get journalDetailQuickMoodInvite =>
      'A quick mood check-in. Tap edit to add words when you\'re ready.';

  @override
  String get journalDetailOnThisDayEarlier => 'On this day, earlier';

  @override
  String get journalDetailDeleteTitle => 'Delete this entry?';

  @override
  String get journalDetailDeleteBody => 'This cannot be undone.';

  @override
  String get journalDetailKeep => 'Keep';

  @override
  String journalDetailMinutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String journalDetailHoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String journalDetailDaysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String journalDetailYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years ago',
      one: '1 year ago',
    );
    return '$_temp0';
  }

  @override
  String get journalDetailLockedEntryTapToUnlock =>
      'Locked entry · tap to unlock';

  @override
  String get journalDetailMoodCheckInNoWords => 'Mood check-in (no words)';

  @override
  String get journalMoodLoggedSnack =>
      'Mood logged. Tap the card to add words.';

  @override
  String get journalReauthViewEntry => 'View this entry';

  @override
  String get journalFilterEmptyTitle => 'Nothing matches';

  @override
  String get journalFilterEmptySubtitle =>
      'Try a different filter or clear the search.';

  @override
  String get journalNewEntryTitle => 'New entry';

  @override
  String get journalNewEntrySubtitle => 'Pick how you want to write today.';

  @override
  String get journalPlainEntryTitle => 'Plain entry';

  @override
  String get journalPlainEntrySubtitle =>
      'A blank page for your thoughts. Mood, tags, optional prompt.';

  @override
  String get journalDailyReflectionTitle => 'Daily reflection';

  @override
  String get journalDailyReflectionSubtitle =>
      'A guided page: gratitude, anchors, wins, cravings, intention.';

  @override
  String get journalBadgeNew => 'New';

  @override
  String get journalCrisisTitleCrisis => 'I see you. Want a hand?';

  @override
  String get journalCrisisTitleHard => 'That sounds heavy.';

  @override
  String get journalCrisisBodyCrisis =>
      'You said this is a crisis — you don\'t have to hold it alone. Reaching a person can help right now.';

  @override
  String get tippTempCaution =>
      'Skip the cold-water or breath-hold step if you have a heart condition, low blood pressure, an eating disorder, or are pregnant — try Paced breathing instead.';

  @override
  String get tippIntenseCaution =>
      'Ease off if you have a heart condition, are pregnant, or feel faint — even a brisk walk works. Stop if you feel unwell.';

  @override
  String get journalCrisisLinesLabel => 'Talk to someone now';

  @override
  String get journalCrisisLinesDetail =>
      'Reach a trained crisis counsellor — free, confidential, any time.';

  @override
  String get journalCrisisBodyHard =>
      'You wrote it down — that already counts. A 60-second thought record can help if you want it.';

  @override
  String get journalCrisisCalmRoomLabel => 'Open the calm room';

  @override
  String get journalCrisisCalmRoomDetail =>
      'Breath work, grounding, and one safe action.';

  @override
  String get journalCrisisThoughtRecordLabel => 'Try a thought record';

  @override
  String get journalCrisisThoughtRecordDetail =>
      'Name the thought, weigh the evidence, reframe it.';

  @override
  String get journalCrisisDismiss => 'I\'m okay for now';

  @override
  String get journalBucketThisWeek => 'This week';

  @override
  String get journalBucketLastWeek => 'Last week';

  @override
  String get journalBucketEarlierThisMonth => 'Earlier this month';

  @override
  String journalWritingStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count day writing streak',
      one: '1 day writing',
    );
    return '$_temp0';
  }

  @override
  String get journalQuickMoodPrompt => 'How are you right now?';

  @override
  String journalOnThisDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'On this day, $count years ago',
      one: 'On this day, 1 year ago',
    );
    return '$_temp0';
  }

  @override
  String get journalEchoLockedEntry => 'A locked entry';

  @override
  String get journalEchoMoodCheckIn => 'A mood check-in';

  @override
  String journalEchoMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count more from this day',
      one: '+1 more from this day',
    );
    return '$_temp0';
  }

  @override
  String get journalFilterAll => 'All';

  @override
  String get journalFilterToday => 'Today';

  @override
  String get journalFilterHard => 'Hard';

  @override
  String get journalFilterWins => 'Wins';

  @override
  String get journalFilterLocked => 'Locked';

  @override
  String get journalSearchHint => 'Search your entries…';

  @override
  String get journalEmptyTitle => 'A place for the unfiltered you';

  @override
  String get journalEmptySubtitle =>
      'Pick a door — or tap + to start with a blank page.';

  @override
  String get journalBlankPageButton => 'Start with a blank page';

  @override
  String get journalDeleteEntryTitle => 'Delete entry?';

  @override
  String get journalDeleteEntryBody => 'This cannot be undone.';

  @override
  String get journalCardLockedHint => 'Locked entry · tap to unlock';

  @override
  String get journalCardMoodCheckInHint => 'Mood check-in · tap to add words';

  @override
  String journalCardDateToday(String time) {
    return 'Today $time';
  }

  @override
  String get journalEditEntryTitle => 'Edit Entry';

  @override
  String get journalTodaysEntryTitle => 'Today\'s Entry';

  @override
  String get journalMoodQuestion => 'How are you feeling?';

  @override
  String get journalSubMoodSpecific => 'A little more specific?';

  @override
  String get journalSubMoodUnderneath => 'What\'s underneath?';

  @override
  String get journalMindQuestion => 'What\'s on your mind?';

  @override
  String get journalVoiceStop => 'Stop';

  @override
  String get journalVoiceSpeak => 'Speak';

  @override
  String get journalVoiceUnavailable =>
      'Voice input is unavailable. Check microphone permission in Settings.';

  @override
  String get journalBodyHint => 'Write freely — no one else will see this...';

  @override
  String get journalTagsLabel => 'Tags';

  @override
  String get journalAddTagHint => 'Add a tag…';

  @override
  String get journalAdd => 'Add';

  @override
  String get journalLockedEntryLabel => 'Locked entry';

  @override
  String get journalLockEntryLabel => 'Lock this entry';

  @override
  String get journalLockEntryHint =>
      'Hidden from the list. Re-auth required to view.';

  @override
  String get journalSaveChanges => 'Save Changes';

  @override
  String get journalSaveEntry => 'Save Entry';

  @override
  String journalSuggestedPrompt(String prompt) {
    return 'Suggested: $prompt';
  }

  @override
  String get journalSuggestedTag => '· suggested';

  @override
  String journalDraftFrom(String age) {
    return 'Unsaved draft from $age';
  }

  @override
  String journalDraftChars(String mood, int count) {
    return '$mood · $count chars';
  }

  @override
  String get journalDraftDiscard => 'Discard';

  @override
  String get journalAgeMomentAgo => 'a moment ago';

  @override
  String journalAgeMinutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String journalAgeHoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String get journalAgeYesterday => 'yesterday';

  @override
  String journalPersonalCard0(String name) {
    return '$name, you are doing harder things than most people will ever try.';
  }

  @override
  String journalPersonalCard1(String name) {
    return '$name, your sober self is the realest version of you.';
  }

  @override
  String journalPersonalCard2(String name) {
    return '$name, this moment is enough. You are enough.';
  }

  @override
  String journalPersonalCard3(String name) {
    return '$name, the version of you a year from now is rooting for today\'s you.';
  }

  @override
  String journalPersonalGratitudeCard(String gratitude) {
    return 'You wrote this: \"$gratitude\" — that\'s still true.';
  }

  @override
  String get journalSwipeHint => 'Swipe for more affirmations';

  @override
  String get journalYourAffirmations => 'Your affirmations';

  @override
  String get journalTapToAddAffirmation => 'Tap + to add your own';

  @override
  String get journalAddAffirmationTitle => 'Add Affirmation';

  @override
  String get journalAffirmationHint => 'I am...';

  @override
  String get visionFilterEmptyTitle => 'Nothing here yet';

  @override
  String get visionFilterEmptySubtitle =>
      'Try a different filter, or add a new dream.';

  @override
  String get visionBoardTitle => 'Your Vision Board';

  @override
  String get visionBoardEmptyTagline => 'Visualise the life ahead of you';

  @override
  String visionDreamCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dreams',
      one: '1 dream',
    );
    return '$_temp0';
  }

  @override
  String visionPinnedCount(int count) {
    return '$count pinned';
  }

  @override
  String visionAchievedCount(int count) {
    return '$count achieved';
  }

  @override
  String get visionFilterActive => 'Active';

  @override
  String get visionFilterPinned => 'Pinned';

  @override
  String get visionFilterAchieved => 'Achieved';

  @override
  String get visionEmptyTitle => 'What does your life ahead look like?';

  @override
  String get visionEmptySubtitle =>
      'Start with one of these — or tap + for a blank canvas.';

  @override
  String get visionBlankDreamButton => 'Start with a blank dream';

  @override
  String get visionTapToOpen => 'Tap to open';

  @override
  String get visionRemoveDreamTitle => 'Remove this dream?';

  @override
  String get visionKeep => 'Keep';

  @override
  String get visionRemove => 'Remove';

  @override
  String get visionEditDreamTitle => 'Edit Dream';

  @override
  String get visionAddDreamTitle => 'Add a Dream';

  @override
  String get visionAddToBoard => 'Add to Vision Board';

  @override
  String get visionRemoveThisDream => 'Remove this dream';

  @override
  String get visionDreamTitleLabel => 'Dream title';

  @override
  String get visionDreamTitleHint => 'e.g. Be more present for my family';

  @override
  String get visionNotesLabel => 'Notes (optional)';

  @override
  String get visionNotesHint => 'Anything to remember…';

  @override
  String get visionWhyLabel => 'Why this matters (optional)';

  @override
  String get visionWhyHint => 'When this matters most, why does it matter?';

  @override
  String get visionCategoryLabel => 'Category';

  @override
  String get visionChooseIcon => 'Choose your icon';

  @override
  String get visionTargetDateLabel => 'Target date (optional)';

  @override
  String get visionTargetDatePlaceholder => 'Pick a date to work toward';

  @override
  String get visionPhotosLabel => 'Photos help you feel it (up to 20)';

  @override
  String get visionAddFirstPhoto => 'Add your first photo';

  @override
  String visionAddAnotherPhoto(int count) {
    return 'Add another ($count/20)';
  }

  @override
  String get visionPhotosPrivacyNote =>
      'Photos are stored on this device only — they never leave your phone.';

  @override
  String get visionStepsLabel => 'Small concrete steps';

  @override
  String get visionStepsDescription =>
      'Break the dream into 3–6 tiny wins. Check them off as life moves.';

  @override
  String get visionNoStepsYet => 'No steps yet — add one below.';

  @override
  String get visionStepHint => 'e.g. Walk 20 minutes today';

  @override
  String get visionAffirmationLabel => 'Affirmation';

  @override
  String get visionAffirmationDescription =>
      '\"I am…\" beats \"I want to…\" — the brain hears it as already real.';

  @override
  String get visionAffirmationHint =>
      'I am present, patient, and proud of how I show up.';

  @override
  String get visionSuggestFromTitle => 'Suggest from title';

  @override
  String get visionTabVision => 'Vision';

  @override
  String get visionTabPhotos => 'Photos';

  @override
  String get visionTabSteps => 'Steps';

  @override
  String get visionTabAffirm => 'Affirm';

  @override
  String get zenTodaysReflection => 'Today\'s Reflection';

  @override
  String get zenMorningIntention => 'Morning Intention';

  @override
  String get zenReflectionPrompts => 'Reflection Prompts';

  @override
  String get zenThreeGoodThings => 'Three Good Things';

  @override
  String get zenMindfulMoment => 'Mindful Moment';

  @override
  String get zenIntentionPrompt0 => 'Today I intend to…';

  @override
  String get zenIntentionPrompt1 => 'My focus for today is…';

  @override
  String get zenIntentionPrompt2 => 'I will show up for myself by…';

  @override
  String get zenIntentionPrompt3 => 'One thing I\'m grateful for right now is…';

  @override
  String get zenSetIntention => 'Set';

  @override
  String get zenReflectionPrompt0 => 'What went well today?';

  @override
  String get zenReflectionPrompt1 =>
      'What challenged me, and how did I handle it?';

  @override
  String get zenReflectionPrompt2 => 'What am I most proud of today?';

  @override
  String get zenReflectionPrompt3 => 'How did I take care of myself today?';

  @override
  String get zenReflectionPrompt4 => 'What would I do differently tomorrow?';

  @override
  String get zenReflectionPrompt5 => 'Who or what am I grateful for right now?';

  @override
  String get zenReflectionPrompt6 => 'What did I learn about myself today?';

  @override
  String get zenReflectionPrompt7 => 'How did I show up for my sobriety today?';

  @override
  String get zenNextPrompt => 'Next prompt';

  @override
  String get zenGoodThingHint => 'Something good today…';

  @override
  String get zenExercise0Title => '5-4-3-2-1 Grounding';

  @override
  String get zenExercise0Desc =>
      'Name 5 things you see, 4 you can touch, 3 you hear, 2 you smell, 1 you taste.';

  @override
  String get zenExercise1Title => 'Box Breath';

  @override
  String get zenExercise1Desc =>
      'Breathe in for 4, hold for 4, breathe out for 4, hold for 4. Repeat 4 times.';

  @override
  String get zenExercise2Title => 'Body Scan';

  @override
  String get zenExercise2Desc =>
      'Close your eyes. Slowly scan from your toes to your head, releasing tension as you go.';

  @override
  String get zenExercise3Title => 'Gratitude Breath';

  @override
  String get zenExercise3Desc =>
      'With each inhale, think of something you\'re grateful for. With each exhale, let go of what doesn\'t serve you.';

  @override
  String get zenOpenGuidedBreathing => 'Open guided breathing in Your Toolkit';

  @override
  String get zenMoreBreathingExercises =>
      'More breathing exercises in Your Toolkit';

  @override
  String get journalReflectionTitle => 'Daily Reflection';

  @override
  String get journalReflectionSaving => 'Saving…';

  @override
  String get journalReflectionMoodTitle => 'How I feel today';

  @override
  String get journalReflectionGratefulTitle => 'I\'m grateful for';

  @override
  String get journalReflectionAnchorsTitle => 'Today\'s anchors';

  @override
  String get journalReflectionAnchorReachedOut => 'Reached out to someone';

  @override
  String get journalReflectionAnchorMeeting => 'Attended a meeting or group';

  @override
  String get journalReflectionAnchorMoved => 'Moved my body';

  @override
  String get journalReflectionAnchorAteHydrated => 'Ate + hydrated well';

  @override
  String get journalReflectionAnchorMeds => 'Took my meds';

  @override
  String get journalReflectionAnchorAvoidedTrigger => 'Avoided a trigger';

  @override
  String get journalReflectionWinsTitle => 'Wins today';

  @override
  String get journalReflectionWinsHint =>
      'Anything you\'re proud of — big or small.';

  @override
  String get journalReflectionCravingsTitle => 'Cravings or triggers noticed';

  @override
  String get journalReflectionCravingsHint =>
      'What showed up, and how did you respond?';

  @override
  String get journalReflectionIntentionTitle => 'Tomorrow\'s intention';

  @override
  String get journalReflectionIntentionHint =>
      'One small thing you\'ll do for your recovery.';

  @override
  String get journalReflectionAffirmationTitle => 'An affirmation for me';

  @override
  String get journalReflectionAffirmationHint =>
      'A kind sentence in your own voice.';

  @override
  String get journalReflectionFooter =>
      'You don\'t have to fill every field.\nWhat you write is enough.';

  @override
  String get journalReflectionBodyGratefulHeading => '🙏 Grateful for';

  @override
  String get journalReflectionBodyAnchorsHeading => '⚓ Today\'s anchors';

  @override
  String get journalReflectionBodyWinsHeading => '✨ Wins today';

  @override
  String get journalReflectionBodyCravingsHeading =>
      '⚡ Cravings or triggers noticed';

  @override
  String get journalReflectionBodyIntentionHeading =>
      '🌱 Tomorrow\'s intention';

  @override
  String get journalReflectionBodyAffirmationHeading =>
      '💛 An affirmation for me';

  @override
  String get milestoneHundredDays => '100 Days';

  @override
  String get milestoneHundredDaysShort => '100 Days';

  @override
  String get milestoneHundredDaysBenefit =>
      'One hundred days. Brain neuroplasticity is in full swing. The reward system has largely recalibrated to find pleasure in life without alcohol. Relationships, work, and your sense of self are transforming.';

  @override
  String milestoneShareText(String emoji, String name, String label) {
    return '$emoji $name — $label sober. One day at a time. #JourneyForward #Sobriety';
  }

  @override
  String get milestoneCardGenerateError =>
      'Could not generate card. Try again.';

  @override
  String get milestoneShareCardLabel => 'SHARE CARD';

  @override
  String get milestoneShareButton => 'Share this milestone';

  @override
  String get milestoneNotYetAchieved => 'Not yet achieved';

  @override
  String get milestoneAllMilestonesLabel => 'ALL MILESTONES';

  @override
  String get milestoneHeroGreeting => 'Well done.';

  @override
  String milestoneHeroGreetingNamed(String name) {
    return 'Well done, $name.';
  }

  @override
  String get milestoneHeroDaySober => 'day\nsober';

  @override
  String get milestoneHeroDaysSober => 'days\nsober';

  @override
  String milestoneHeroNext(String label) {
    return 'Next: $label';
  }

  @override
  String milestoneHeroProgressDays(int days, int target) {
    return '$days of $target days';
  }

  @override
  String get milestoneEveryReached => 'Every milestone reached ✨';

  @override
  String get milestoneAchievedBadge => 'Achieved ✓';

  @override
  String milestoneDaysToGo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days to go',
      one: '1 day to go',
    );
    return '$_temp0';
  }

  @override
  String get milestoneWhatHappenedLabel => 'What happened in your body';

  @override
  String get milestoneWhatWillHappenLabel => 'What will happen';

  @override
  String get milestoneShareCardFallbackName => 'Friend';

  @override
  String get milestoneUnitDay => 'day';

  @override
  String get milestoneUnitDays => 'days';

  @override
  String get milestoneUnitYear => 'year';

  @override
  String get milestoneUnitYears => 'years';

  @override
  String get milestoneUnitSober => 'sober';

  @override
  String get milestoneShareCardBrand => 'JOURNEY FORWARD';

  @override
  String milestoneDaysToUnlock(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more days to unlock',
      one: '1 more day to unlock',
    );
    return '$_temp0';
  }

  @override
  String get milestoneStatsTotalDaysSober => 'total\ndays sober';

  @override
  String get milestoneStatsMoneyReclaimed => 'money\nreclaimed';

  @override
  String get onbBiometricNotEnrolledError =>
      'Biometrics aren\'t set up on this device. Add a fingerprint or face in your phone\'s settings, then try again.';

  @override
  String get onbBiometricConfirmReason => 'Confirm to enable biometric lock';

  @override
  String onbBiometricSetupFailed(String error) {
    return 'Biometric setup failed: $error';
  }

  @override
  String onbSetupFailed(String error) {
    return 'Could not complete setup: $error';
  }

  @override
  String get onbWelcomeEyebrow => 'DAY ONE  ·  A WELCOME';

  @override
  String get onbWelcomeHeadline => 'A new chapter,\nquietly begun.';

  @override
  String get onbWelcomePillOnDeviceSub => 'Works without the internet';

  @override
  String get onbWelcomePillNoAccountTitle => 'NO ACCOUNT';

  @override
  String get onbWelcomePillNoAccountSub => 'No login or profile upload';

  @override
  String get onbWelcomePillZeroTrackingTitle => 'ZERO TRACKING';

  @override
  String get onbWelcomePillZeroTrackingSub => 'Your data stays on device';

  @override
  String get onbWelcomeBeginButton => 'Begin';

  @override
  String get onbWelcomeDisclaimer =>
      'Not medical advice — a companion, not a clinician.';

  @override
  String get onbQuitDateLabel => 'Quit date';

  @override
  String get onbTimeOfDayLabel => 'Time of day';

  @override
  String get onbDaysUntilDayOneLabel => 'days until day one';

  @override
  String get onbSecurityPinRecoveryWarning =>
      'If you forget your PIN, your data cannot be recovered without a backup. Set up a backup later in Profile → Backup.';

  @override
  String get onbSecurityBiometricRecoveryWarning =>
      'If you lose biometric access (factory reset, device change, etc.), your data cannot be recovered without a backup. Set one up in Profile → Backup.';

  @override
  String onbFinishHeadlineWithName(String name) {
    return 'You\'re ready,\n$name.';
  }

  @override
  String get onbFinishHeadline => 'You\'re ready\nfor this.';

  @override
  String onbFinishEyebrowCountdown(int days) {
    return 'IN $days DAYS  ·  YOUR JOURNEY BEGINS';
  }

  @override
  String onbFinishEyebrowContinuing(int day) {
    return 'DAY $day  ·  THE PATH CONTINUES';
  }

  @override
  String get onbFinishEyebrowDayOne => 'DAY ONE  ·  THE JOURNEY BEGINS';

  @override
  String get onbFinishBodyFuture =>
      'Your quit date is set. We\'ll count down with you — and the moment it arrives, day one begins.';

  @override
  String get planToolkitBoxBreathingLabel => 'Box Breathing';

  @override
  String get planToolkitBoxBreathingSub => 'Guided 4-4-4-4 breath cycle';

  @override
  String get planToolkitGroundingLabel => '5-4-3-2-1 Grounding';

  @override
  String get planToolkitGroundingSub => 'Ground yourself through your senses';

  @override
  String get planToolkitCbtReframeLabel => 'CBT Thought Reframe';

  @override
  String get planToolkitCbtReframeSub => 'Challenge the craving thought';

  @override
  String get planToolkitAffirmationsLabel => 'Affirmations';

  @override
  String get planToolkitAffirmationsSub => 'Read a personal affirmation';

  @override
  String get planToolkitColdWaterLabel => 'Cold Water';

  @override
  String get planToolkitColdWaterSub => 'Splash cold water on your face';

  @override
  String get planToolkitWalkOutsideLabel => 'Walk Outside';

  @override
  String get planToolkitWalkOutsideSub => 'Take a short walk to reset';

  @override
  String get planToolkitCallSomeoneLabel => 'Call Someone';

  @override
  String get planToolkitCallSomeoneSub =>
      'Reach out to your sponsor or a friend';

  @override
  String get planToolkitBodyScanLabel => 'Body Scan';

  @override
  String get planToolkitBodyScanSub =>
      'Scan from toes to head, release tension';

  @override
  String get planStepHint1 => 'e.g. Take three slow box-breaths';

  @override
  String get planStepHint2 => 'e.g. Drink a glass of cold water';

  @override
  String get planStepHint3 => 'e.g. Text my sponsor: \"Craving\"';

  @override
  String get planSavedSnack =>
      'Plan saved — you\'ll see it when a craving hits.';

  @override
  String get planTitle => 'Pre-craving plan';

  @override
  String get planSubtitle =>
      'Three things you commit to doing the moment a craving hits — written in calm so you don\'t have to think in a storm.';

  @override
  String get planLinkExercise => 'Link a Toolkit exercise';

  @override
  String get planLinkInfo =>
      'Linking a Toolkit exercise adds a one-tap \"Open\" button during your plan so you can jump straight into the exercise.';

  @override
  String get planSavePlan => 'Save plan';

  @override
  String get planSaved => 'Saved';

  @override
  String get planPickerTitle => 'Choose a Toolkit Exercise';

  @override
  String get planPickerSubtitle =>
      'Tap to add a one-tap link to this exercise in your plan.';

  @override
  String get planOpensInApp => 'Opens in app';

  @override
  String get planRunnerTitle => 'Your plan';

  @override
  String get planRunnerSubtitle =>
      'Run through these before logging. Breathe between each one.';

  @override
  String planRunnerOpenExercise(String label) {
    return 'Open $label →';
  }

  @override
  String get planRunnerImOkay => 'I\'m okay';

  @override
  String get planRunnerStillLogIt => 'Still log it';

  @override
  String get progressSummaryChip => 'Summary';

  @override
  String get progressMilestoneReached => 'Milestone reached';

  @override
  String get progressCurrentJourney => 'Current journey';

  @override
  String progressMilestonePrefix(String label) {
    return 'Milestone: $label';
  }

  @override
  String progressNextPrefix(String label) {
    return 'Next: $label';
  }

  @override
  String progressDaysLabel(int count) {
    return '$count Days';
  }

  @override
  String progressPercentComplete(int percent) {
    return '$percent%';
  }

  @override
  String get progressThresholdCrossed => 'A beautiful threshold crossed.';

  @override
  String progressDaysOfTarget(int days, int target) {
    return '$days / $target days';
  }

  @override
  String get progressMilestonesTitle => 'Milestones';

  @override
  String get progressCardsLink => 'Cards';

  @override
  String get progressGridYear => '1yr';

  @override
  String progressGridMonths(int count) {
    return '${count}mo';
  }

  @override
  String progressGridDays(int count) {
    return '${count}d';
  }

  @override
  String get progressUnitDays => 'DAYS';

  @override
  String get progressUnitHrs => 'HRS';

  @override
  String get progressUnitMin => 'MIN';

  @override
  String get progressUnitSec => 'SEC';

  @override
  String get progressInsightCravingTitle => 'Craving Support';

  @override
  String get progressInsightCravingSubtitle =>
      'Every log is a brave step toward healing.';

  @override
  String get progressInsightCravingQuote =>
      'Logging a craving is a sign of strength.\nYou\'re choosing awareness and support.';

  @override
  String get progressInsightSleepTitle => 'Sleep Quality';

  @override
  String get progressInsightSleepSubtitle =>
      'Hours logged per night, tracked daily.';

  @override
  String get progressInsightSleepQuote =>
      'Rest is part of recovery.\nEvery hour of sleep supports your healing.';

  @override
  String get progressInsightMovementTitle => 'Movement';

  @override
  String get progressInsightMovementSubtitle =>
      'Active minutes per day, two weeks out.';

  @override
  String get progressInsightMovementQuote =>
      'Movement lifts the spirit.\nEvery active minute counts.';

  @override
  String get progressInsightThoughtsTitle => 'Thoughts';

  @override
  String get progressInsightThoughtsSubtitle =>
      'Thoughts logged each day across 14 days.';

  @override
  String get progressInsightThoughtsQuote =>
      'Reflection builds resilience.\nYour thoughts are your inner compass.';

  @override
  String get progressYLabelLogs => 'Logs';

  @override
  String get progressYLabelHrs => 'Hrs';

  @override
  String get progressYLabelMin => 'Min';

  @override
  String progressInsightTitle14Days(String title) {
    return '$title — 14 days';
  }

  @override
  String get progressThisWeek => 'This week';

  @override
  String get progressLastWeek => 'Last week';

  @override
  String get progressTenderHoursTitle => 'Your tender hours';

  @override
  String progressTenderHoursBody(int count, int total) {
    return '$count of your $total logged cravings land in this window. Knowing your pattern is power — plan something gentle for those hours: a walk, a call, the urge timer.';
  }

  @override
  String get progressReviewMyPlan => 'Review my plan';

  @override
  String get progressShowHeatmap => 'Show cravings heatmap';

  @override
  String get progressCravingsHeatmapTitle => 'Cravings Heatmap';

  @override
  String get progressViewFull => 'View full';

  @override
  String get progressHeatmapCaption =>
      'Day 1 = your first day in the app. Only cravings logged from the Home screen count.';

  @override
  String progressHeatmapWeekLabel(int number) {
    return 'Wk $number';
  }

  @override
  String get progressHeatmapLegendFewer => 'Fewer';

  @override
  String get progressHeatmapLegendMore => 'More';

  @override
  String get progressRecoveryCapitalTitle => 'Recovery capital — this week';

  @override
  String get progressRecoveryCapitalEmptySubtitle =>
      'A 30-second check across five things that protect recovery.';

  @override
  String progressCapitalScore(int score) {
    return '$score of 5';
  }

  @override
  String get progressTapToEdit => 'Tap to edit';

  @override
  String get progressDayLetterMon => 'M';

  @override
  String get progressDayLetterTue => 'T';

  @override
  String get progressDayLetterWed => 'W';

  @override
  String get progressDayLetterThu => 'T';

  @override
  String get progressDayLetterFri => 'F';

  @override
  String get progressDayLetterSat => 'S';

  @override
  String get progressDayLetterSun => 'S';

  @override
  String get recoveryMedicalDisclaimer =>
      'Journey Forward is not a medical device and does not diagnose, treat, cure, or prevent any medical condition. This timeline is educational and reflects general recovery patterns only. Individual recovery varies. If you drink heavily, have a history of withdrawal, seizures, hallucinations, confusion, or feel physically unsafe, speak with a healthcare professional before stopping suddenly or seek urgent medical care.';

  @override
  String get recoveryMindLabel => 'MIND';

  @override
  String get recoveryM1Mind =>
      'You might feel a mix of relief and anxiety as your daily routine shifts. This is the normal friction of change.';

  @override
  String get recoveryM1Experience =>
      'The first urges may appear. They can feel urgent, but they are temporary waves.';

  @override
  String get recoveryM1Tip =>
      'Drink a large glass of water. When an urge hits, focus only on getting through the next hour.';

  @override
  String get recoveryM2Mind =>
      'Your brain\'s reward circuitry is noticing the absence of its usual chemical trigger, which can cause irritability or a low mood.';

  @override
  String get recoveryM2Experience =>
      'You may feel emotionally raw, tired, or slightly restless.';

  @override
  String get recoveryM2Tip =>
      'Sleep and rest are your best allies right now. Keep your evening routine calm, quiet, and consistent.';

  @override
  String get recoveryM3Mind =>
      'Your system is seeking balance. The intensity you feel right now is the feeling of that adjustment taking place.';

  @override
  String get recoveryM3Experience =>
      'Restlessness and strong urges are common here. You might feel “wired” or on edge.';

  @override
  String get recoveryM3Tip =>
      'Be especially patient with yourself today. If you experience shaking, confusion, hallucinations, seizures, severe agitation, or feel unsafe, seek urgent medical support.';

  @override
  String get recoveryM4Mind =>
      'The mental fog often begins to thin. Neurotransmitter production starts to slowly adjust, paving the way for more natural energy.';

  @override
  String get recoveryM4Experience =>
      'A small window of calm may emerge. You might feel a quiet, cautious optimism taking root.';

  @override
  String get recoveryM4Tip =>
      'Reaching 72 hours is meaningful. Mark it with comfort, care, and support.';

  @override
  String get recoveryM5Mind =>
      'You may notice unusually vivid dreams — some people experience this as their sleep pattern settles into a new rhythm.';

  @override
  String get recoveryM5Experience =>
      'Improved clarity, though your mood may still naturally swing up and down.';

  @override
  String get recoveryM5Tip =>
      'Anchor yourself in routine. A predictable morning and evening structure is a powerful tool right now.';

  @override
  String get recoveryM6Mind =>
      'Concentration and short-term memory often start to feel sharper. Each healthier choice you repeat helps lay down new patterns.';

  @override
  String get recoveryM6Experience =>
      'You might start feeling surprisingly well, though random moments of emptiness are still normal.';

  @override
  String get recoveryM6Tip =>
      'This is when overconfidence can sneak in. Stay connected to your daily practices and support systems.';

  @override
  String get recoveryM7Mind =>
      'The brain systems involved in impulse control, decision-making, and emotional regulation may begin to feel steadier over time.';

  @override
  String get recoveryM7Experience =>
      'Emotional regulation continues to improve, and building resilience becomes a steady practice.';

  @override
  String get recoveryM7Tip =>
      'Review your journey so far. Note the situations that still feel tricky, and plan how you will navigate them gracefully.';

  @override
  String get recoveryM8Mind =>
      'For many people, the ability to find genuine satisfaction in simple, everyday activities slowly returns at this stage.';

  @override
  String get recoveryM8Experience =>
      'Many people describe feeling more like themselves again. Motivation may feel more available, though it can still rise and fall.';

  @override
  String get recoveryM8Tip =>
      'Continue to cultivate your environment. Hobbies, nature, and relationships are deeply protective elements of your growth.';

  @override
  String get recoveryM9Mind =>
      'Urges may become less frequent or easier to move through.';

  @override
  String get recoveryM9Experience =>
      'The highs and lows of early recovery begin to smooth out into a more consistent rhythm.';

  @override
  String get recoveryM9Tip =>
      'Take a moment to honor the quiet days. Peace and stability are among the quiet rewards of this process.';

  @override
  String get recoveryM10Mind =>
      'You have lived through many seasons, routines, and emotional moments with more awareness and care.';

  @override
  String get recoveryM10Experience =>
      'Support may still matter, and needing it does not diminish your progress.';

  @override
  String get recoveryM10Tip =>
      'Reflect on the person you were twelve months ago. Write them a letter from where you stand today.';

  @override
  String get recoveryM11Mind =>
      'Recovery may feel less like something you are forcing and more like a way of living you have grown into.';

  @override
  String get recoveryM11Tip =>
      'Your story may become a source of comfort for someone else. When the moment feels right, share your strength with someone just beginning their path.';

  @override
  String get settingsAddWeeklyGoalTitle => 'Add weekly goal';

  @override
  String get settingsWeeklyGoalHint => 'e.g. Exercise 3 times this week';

  @override
  String get settingsBiometricNotSetUp =>
      'Biometrics aren\'t set up on this device. Add a fingerprint or face in your phone\'s settings, then try again.';

  @override
  String get settingsBiometricConfirmReason =>
      'Confirm to enable biometric lock';

  @override
  String get settingsBiometricNotEnrolled =>
      'No biometrics enrolled on this device. Add a fingerprint or face in your phone\'s settings.';

  @override
  String get settingsBiometricUnavailable =>
      'Biometric hardware is unavailable right now. Try again in a moment.';

  @override
  String get settingsBiometricLockedOut =>
      'Too many failed attempts. Wait a moment and try again.';

  @override
  String get settingsBiometricPermanentlyLockedOut =>
      'Biometrics are locked. Use your phone\'s screen lock to re-enable.';

  @override
  String settingsBiometricAuthFailed(String error) {
    return 'Biometric authentication failed: $error';
  }

  @override
  String get settingsReminderScheduleFailed =>
      'Reminder scheduling failed. Please check notification permissions.';

  @override
  String get settingsNotificationsBlockedSaved =>
      'Saved — but notifications are blocked in system settings.';

  @override
  String get settingsOpenSettingsAction => 'OPEN SETTINGS';

  @override
  String get settingsNotificationSettingsSaved => 'Notification settings saved';

  @override
  String get settingsDiagnosticsEnabled => 'Diagnostics enabled';

  @override
  String get settingsDiagMorningReminder => 'Morning reminder';

  @override
  String get settingsDiagEveningReminder => 'Evening reminder';

  @override
  String get settingsDiagTestNotification => 'Test notification';

  @override
  String settingsDiagMilestoneDay(int day) {
    return 'Milestone: day $day';
  }

  @override
  String get settingsDiagSavingsMilestone => 'Savings milestone';

  @override
  String get settingsDiagMeetingReminder => 'Meeting reminder';

  @override
  String settingsDiagUnknownId(int id) {
    return 'Unknown (ID $id)';
  }

  @override
  String get settingsDiagYes => 'Yes';

  @override
  String get settingsDiagNo => 'No';

  @override
  String get settingsDiagUnknown => 'Unknown';

  @override
  String get settingsDiagNotRestricted => 'Not restricted';

  @override
  String get settingsDiagRestricted => 'Restricted';

  @override
  String get settingsDiagScheduledNotificationsTitle =>
      'Scheduled Notifications';

  @override
  String get settingsDiagSchedulerRanOk => 'Scheduler ran OK';

  @override
  String settingsDiagSchedulerError(String error) {
    return 'Scheduler error: $error';
  }

  @override
  String get settingsDiagNotificationsAllowed => 'Notifications allowed';

  @override
  String get settingsDiagBatteryOptimization => 'Battery optimization';

  @override
  String get settingsDiagExactAlarms => 'Exact alarms';

  @override
  String get settingsDiagAvailable => 'Available';

  @override
  String get settingsDiagUnavailable => 'Unavailable';

  @override
  String get settingsDiagUnknownNotApplicable => 'Unknown / not applicable';

  @override
  String get settingsDiagTimezone => 'Timezone';

  @override
  String get settingsDiagTimezoneNow => 'Timezone now';

  @override
  String get settingsDiagPendingCount => 'Pending count';

  @override
  String get settingsDiagMorningQueued => 'Morning queued';

  @override
  String get settingsDiagEveningQueued => 'Evening queued';

  @override
  String get settingsDiagNoneScheduled =>
      'No notifications are scheduled. Your daily reminders will not fire.';

  @override
  String get settingsDiagSendTestNow => 'Send test notification now';

  @override
  String get settingsDiagTestSent =>
      'Test sent - you should see it within 2 seconds';

  @override
  String get settingsDiagTestFailed =>
      'Test failed - check notification permissions';

  @override
  String get settingsDiagOpenBatterySettings => 'Open Battery Settings';

  @override
  String get settingsMyMotivationLabel => 'My Motivation';

  @override
  String get settingsReasonsToQuitTitle => 'My Reasons to Quit';

  @override
  String get settingsReasonsToQuitHint => 'e.g. To be healthier';

  @override
  String get settingsProsTitle => 'Pros of Sobriety';

  @override
  String get settingsProsHint => 'e.g. More energy';

  @override
  String get settingsConsTitle => 'Cons I\'m Leaving Behind';

  @override
  String get settingsConsHint => 'e.g. Feeling anxious';

  @override
  String get settingsAppSecurityLabel => 'App security';

  @override
  String get settingsDiagnosticsLabel => 'Diagnostics';

  @override
  String get settingsCheckScheduledReminders => 'Check scheduled reminders';

  @override
  String get settingsCheckScheduledRemindersSub =>
      'Verify alarms, permissions, and timezone';

  @override
  String get settingsAboutLabel => 'About';

  @override
  String settingsVersionLabel(String version) {
    return 'Version $version';
  }

  @override
  String settingsSoberSinceDate(String date) {
    return 'Sober since $date';
  }

  @override
  String settingsDailySpendChip(String amount) {
    return '$amount/day · tap to edit';
  }

  @override
  String settingsPledgeStreakBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count calm days pledged',
      one: '1 calm day pledged',
    );
    return '$_temp0';
  }

  @override
  String get settingsSavedLabel => 'saved';

  @override
  String settingsSavingsProgress(String saved, String goal) {
    return '$saved of $goal';
  }

  @override
  String get settingsEditGoal => 'Edit goal';

  @override
  String get settingsSetSavingsGoal => 'Set a savings goal';

  @override
  String get settingsSetSavingsGoalSub => 'Track what you\'re saving up for';

  @override
  String get settingsAddEmergencyContact => 'Add emergency contact';

  @override
  String get settingsAddEmergencyContactSub =>
      'Someone to reach when you need support';

  @override
  String get settingsNoItemsYet => 'No items added yet.';

  @override
  String get settingsLockNoneLabel => 'No lock';

  @override
  String get settingsLockNoneSub => 'App opens immediately';

  @override
  String get settingsLockBiometricLabel => 'Biometric';

  @override
  String get settingsLockBiometricSub => 'Fingerprint or face unlock';

  @override
  String get settingsLockPinLabel => 'PIN';

  @override
  String get settingsLockPinSub => '4-digit numeric PIN';

  @override
  String get settingsLockPinRecoveryWarning =>
      'If you forget your PIN, your data cannot be recovered without a backup. Set one up in Profile → Backup.';

  @override
  String get settingsLockBiometricRecoveryWarning =>
      'If you lose biometric access (factory reset, device change, etc.), your data cannot be recovered without a backup. Set one up in Profile → Backup.';

  @override
  String get settingsRecordsGroupLabel => 'Records';

  @override
  String get settingsMyHistory => 'My history';

  @override
  String get settingsMoodCravingInsights => 'Mood & craving insights';

  @override
  String get settingsMilestoneCards => 'Milestone cards';

  @override
  String get settingsWeeklyCareSummarySub =>
      'Create a private summary to share with someone you trust.';

  @override
  String get settingsToolsAppGroupLabel => 'Tools & App';

  @override
  String get settingsCbtThoughtTools => 'CBT thought tools';

  @override
  String get settingsPreCravingPlan => 'Pre-craving plan';

  @override
  String get settingsRecoveryGroups => 'Recovery groups';

  @override
  String get settingsMeetingPlanner => 'Meeting planner';

  @override
  String get settingsSystemNotifsEnabled => 'System notifications enabled';

  @override
  String get settingsSystemNotifsBlocked => 'System notifications blocked';

  @override
  String get settingsSystemNotifsEnabledSub =>
      'Your reminders will appear on time.';

  @override
  String get settingsSystemNotifsBlockedSub =>
      'Reminders will not appear until enabled in system settings.';

  @override
  String get settingsFixItAction => 'Fix it';

  @override
  String get settingsCheckInReminders => 'Check-in & reminders';

  @override
  String get settingsMorningEveningTimes => 'Morning & evening times';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'Match system';

  @override
  String get settingsThemeLightHint =>
      'Warm cream — the classic Stillwater look';

  @override
  String get settingsThemeDarkHint => 'Dim forest tones for late nights';

  @override
  String get settingsThemeSystemHint => 'Follow your phone setting';

  @override
  String get settingsHapticFeedback => 'Haptic feedback';

  @override
  String get settingsImperialUnits => 'Imperial units';

  @override
  String get settingsImperialUnitsSub => 'Distance in miles instead of km';

  @override
  String get settingsCheckInReminderSchedule =>
      'Check-in and reminder schedule';

  @override
  String get settingsMorningCheckIn => 'Morning check-in';

  @override
  String get settingsEveningReminder => 'Evening reminder';

  @override
  String get settingsMotivationMessages => 'Motivation messages';

  @override
  String get settingsDailyReminders => 'Daily reminders';

  @override
  String get settingsMilestoneAlerts => 'Milestone alerts';

  @override
  String get settingsTestSentShade =>
      'Test sent — check your notification shade.';

  @override
  String get settingsTestCouldNotPost =>
      'Test could not post. Notifications appear to be blocked for Journey Forward.';

  @override
  String get settingsSendTestNotification => 'Send test notification';

  @override
  String get settingsAboutTitle => 'About Journey Forward';

  @override
  String get settingsAboutBody =>
      'Recovery and personal growth are rarely a straight line. Having walked a difficult road myself, I know how heavy some days can feel — and how exhausting it can be to use tools filled with noise, pressure, and distraction.\n\nWhen you are trying to heal or rebuild, the last thing you need is advertising, attention-grabbing notifications, or the worry that your deeply personal reflections are being harvested.\n\nYour recovery is not a data product.\n\nI built Journey Forward to be a quiet alternative: no ads, no accounts, no tracking analytics, and no built-in cloud sync. It is designed as a private, offline-first sanctuary for honest days and steady progress.\n\nBecause Journey Forward has no accounts, analytics, tracking, or cloud sync, I have no way of seeing how you experience the app, what feels confusing, or what features might help you most. If something is not working, or if you have an idea for a future improvement, you are welcome to contact me directly.\n\nThis app is not here to shame you, score you, or punish you for difficult moments. It is here to help you return — to your reason, your routines, your breath, and the next small step forward.\n\nI am also working toward language support, including Zulu and Afrikaans, so Journey Forward can become more welcoming while keeping its privacy-first foundation.\n\nMy hope is that this space helps you find grounding, reflection, and the grace to take one honest step at a time.\n\n— Shawn';

  @override
  String get settingsEmailCopied => 'Email copied';

  @override
  String get settingsShareApp => 'Share app';

  @override
  String get settingsSpendPerDayQuestion => 'How much did you spend per day?';

  @override
  String get settingsCurrencyLabel => 'Currency';

  @override
  String get settingsSetAPin => 'Set a PIN';

  @override
  String get settingsEnter4DigitPin => 'Enter a 4-digit PIN';

  @override
  String get settingsEnterPinAgain => 'Enter your PIN again';

  @override
  String get visionPinCapReached =>
      'You can pin up to 3 dreams — unpin one to make room.';

  @override
  String get visionMarkedAchievedToast => 'Marked achieved. Beautiful.';

  @override
  String get visionUnpinTooltip => 'Unpin';

  @override
  String get visionPinTooltip => 'Pin to home';

  @override
  String get visionMoveToActiveTooltip => 'Move back to active';

  @override
  String get visionMarkAchievedTooltip => 'Mark achieved';

  @override
  String get visionEditTooltip => 'Edit';

  @override
  String get visionAchievedBanner => 'You achieved this. Beautiful.';

  @override
  String visionAchievedOnDate(String date) {
    return 'Achieved on $date';
  }

  @override
  String visionDaysPastTarget(int count) {
    return '${count}d past target';
  }

  @override
  String get visionTargetToday => 'Today';

  @override
  String visionDaysToGo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days to go',
      one: '1 day to go',
    );
    return '$_temp0';
  }

  @override
  String get visionPinnedChip => 'Pinned';

  @override
  String get visionMilestonesLabel => 'Milestones';

  @override
  String visionMilestonesComplete(int done, int total) {
    return '$done of $total complete';
  }

  @override
  String get visionWhyItMattersHeading => 'Why this matters';

  @override
  String get visionNotesHeading => 'Notes';

  @override
  String get emergencyToolkitHeading => 'Your Toolkit';

  @override
  String get emergencyToolkitSubheading => 'One Day at a Time';

  @override
  String emergencyCallContact(String name) {
    return 'Call $name';
  }

  @override
  String get emergencyHaltShortLabel => 'H.A.L.T.';

  @override
  String get emergencyPuzzleTitle => 'Puzzles';

  @override
  String get emergencyWeeklyCareSummaryDesc =>
      'Prepare a gentle report for therapy, support, or reflection.';

  @override
  String get emergencyCalmToolkitOverline => 'CALM TOOLKIT';

  @override
  String get emergencyComplete => 'Complete ✓';

  @override
  String get breathChooseTitle => 'Choose your breath.';

  @override
  String get breathChooseSubtitle => 'A steady rhythm for this moment.';

  @override
  String get breathLibraryTitle => 'Breathing Library';

  @override
  String get breathMorePatterns => 'More breathing patterns';

  @override
  String get breathRecommendedNow => 'RECOMMENDED NOW';

  @override
  String get breathRhythmIn => 'In';

  @override
  String get breathRhythmHold => 'Hold';

  @override
  String get breathRhythmOut => 'Out';

  @override
  String get breathBegin => 'Begin';

  @override
  String get breathSessionTitle => 'Breathe with me.';

  @override
  String get breathSessionSubtitle => 'Nothing to solve right now.';

  @override
  String get breathReady => 'Ready';

  @override
  String get breathRemaining => 'remaining';

  @override
  String get breathStart => 'Start';

  @override
  String get breathResume => 'Resume';

  @override
  String get breathPause => 'Pause';

  @override
  String get breathEndSession => 'End session';

  @override
  String get breathDizzyWarning =>
      'If you feel dizzy, return to normal breathing.';

  @override
  String get breathAllPatternsTitle => 'All breathing patterns.';

  @override
  String get breathAllPatternsSubtitle =>
      'Find the rhythm that fits this moment.';

  @override
  String get meditationGuidedAudioLabel => 'GUIDED AUDIO';

  @override
  String get meditationGuidedScripts => 'Guided scripts';

  @override
  String get meditationUrgeSurfingTagline =>
      'Ride the wave — urges peak and pass.';

  @override
  String get meditationUrgeSurfingExplainer =>
      'Urge surfing: instead of fighting a craving, you observe it like a wave — it rises, peaks, and falls on its own. This guided session teaches you to ride the wave without acting on it.';

  @override
  String get meditationDuration8min => '8 min';

  @override
  String get meditationDuration10min => '10 min';

  @override
  String get meditationDuration12min => '12 min';

  @override
  String get meditationDuration15min => '15 min';

  @override
  String get meditationUrgeSurfingTitle => 'Urge Surfing';

  @override
  String get meditationUrgeSurfingStep0 =>
      'Close your eyes and take three slow breaths.';

  @override
  String get meditationUrgeSurfingStep1 =>
      'Notice the craving. Where do you feel it in your body?';

  @override
  String get meditationUrgeSurfingStep2 =>
      'Imagine it as a wave in the ocean — rising slowly.';

  @override
  String get meditationUrgeSurfingStep3 =>
      'You are a surfer. You don\'t fight the wave. You ride it.';

  @override
  String get meditationUrgeSurfingStep4 =>
      'Watch the wave peak. It cannot go higher than it already is.';

  @override
  String get meditationUrgeSurfingStep5 =>
      'Now watch it begin to fall. Urges always fade.';

  @override
  String get meditationUrgeSurfingStep6 =>
      'You did not drink. The wave passed. You surfed it.';

  @override
  String get meditationBodyScanTitle => 'Body Scan';

  @override
  String get meditationBodyScanStep0 =>
      'Lie down or sit comfortably. Close your eyes.';

  @override
  String get meditationBodyScanStep1 =>
      'Bring attention to your feet. Notice any sensation — warmth, tingling.';

  @override
  String get meditationBodyScanStep2 =>
      'Slowly move up to your calves, then knees, then thighs.';

  @override
  String get meditationBodyScanStep3 =>
      'Notice your belly rising and falling with each breath.';

  @override
  String get meditationBodyScanStep4 =>
      'Scan your chest, shoulders, arms, and hands.';

  @override
  String get meditationBodyScanStep5 =>
      'Finally, relax your jaw, eyes, and forehead.';

  @override
  String get meditationBodyScanStep6 =>
      'Rest here for a moment. You are safe. You are whole.';

  @override
  String get meditationGratitudeResetTitle => 'Gratitude Reset';

  @override
  String get meditationGratitudeResetStep0 =>
      'Sit quietly. Take three slow breaths.';

  @override
  String get meditationGratitudeResetStep1 =>
      'Think of one person in your life you\'re grateful for.';

  @override
  String get meditationGratitudeResetStep2 =>
      'What did they do or say that mattered to you?';

  @override
  String get meditationGratitudeResetStep3 =>
      'Think of one moment from today, however small, that was good.';

  @override
  String get meditationGratitudeResetStep4 =>
      'Think of something about your body or health you appreciate.';

  @override
  String get meditationGratitudeResetStep5 =>
      'Let gratitude fill your chest like warmth.';

  @override
  String get meditationGratitudeResetStep6 =>
      'Carry this feeling into your next hour.';

  @override
  String get meditationSafePlaceTitle => 'Safe Place';

  @override
  String get meditationSafePlaceStep0 =>
      'Close your eyes. Take three slow, deep breaths.';

  @override
  String get meditationSafePlaceStep1 =>
      'Imagine a place where you feel completely safe.';

  @override
  String get meditationSafePlaceStep2 =>
      'It can be real or imagined — a beach, a forest, a room.';

  @override
  String get meditationSafePlaceStep3 =>
      'Notice what you see, hear, smell in this place.';

  @override
  String get meditationSafePlaceStep4 =>
      'Feel the ground beneath you. You are supported.';

  @override
  String get meditationSafePlaceStep5 =>
      'Breathe here for a while. Nothing can harm you.';

  @override
  String get meditationSafePlaceStep6 =>
      'When you\'re ready, slowly return, carrying this calm.';

  @override
  String get meditationSelfCompassionTitle => 'Self-Compassion';

  @override
  String get meditationSelfCompassionStep0 =>
      'Place your hand on your heart. Feel its warmth.';

  @override
  String get meditationSelfCompassionStep1 =>
      'Say: \"This is a moment of difficulty.\"';

  @override
  String get meditationSelfCompassionStep2 =>
      'Say: \"Difficulty is part of life. I am not alone in this.\"';

  @override
  String get meditationSelfCompassionStep3 =>
      'Say: \"May I be kind to myself right now.\"';

  @override
  String get meditationSelfCompassionStep4 =>
      'Think of something you\'ve been critical of yourself about.';

  @override
  String get meditationSelfCompassionStep5 =>
      'Ask: what would I say to a dear friend in this situation?';

  @override
  String get meditationSelfCompassionStep6 =>
      'Say those words to yourself. You deserve them too.';

  @override
  String get notifMilestoneTitle => 'Milestone Reached';

  @override
  String get notifSavingsTitle => 'Savings Milestone';

  @override
  String get notifMeetingTitle => 'Meeting reminder';

  @override
  String get notifTestBody => 'Test notification — your reminders are working.';

  @override
  String notifSavingsBody(String amount) {
    return 'You\'ve saved $amount through sobriety. Keep going!';
  }

  @override
  String notifMeetingBody(String title, String time) {
    return '$title at $time';
  }

  @override
  String notifMeetingBodyLocation(String title, String time, String location) {
    return '$title at $time · $location';
  }

  @override
  String get notifMorning0 =>
      'Good morning. Your recovery is worth showing up for today.';

  @override
  String get notifMorning1 =>
      'One day at a time. You\'ve got this — check in now.';

  @override
  String get notifMorning2 =>
      'Morning check-in — Log your mood and set your intentions.';

  @override
  String get notifMorning3 =>
      'Your sober journey continues today. Open the app and check in.';

  @override
  String get notifMorning4 =>
      'A new day, a fresh start. Take a moment to ground yourself.';

  @override
  String get notifEvening0 =>
      'You\'ve made it through another day — Log your progress.';

  @override
  String get notifEvening1 =>
      'Evening check-in — How did your day go? Log it and reflect.';

  @override
  String get notifEvening2 =>
      'Don\'t forget to log today before it slips away.';

  @override
  String get notifEvening3 =>
      'Great job today — Take a moment to reflect and log your day.';

  @override
  String get notifEvening4 =>
      'You kept going today. Log tonight before you sleep.';

  @override
  String get notifMilestone1d =>
      '1 Day Sober. The first step is the hardest. You showed up.';

  @override
  String get notifMilestone2d =>
      '2 Days Sober. Two days in a row. You\'re doing this.';

  @override
  String get notifMilestone3d =>
      '3 Days Sober. Day three is one of the hardest. You\'re still here.';

  @override
  String get notifMilestone5d =>
      '5 Days Sober. Five days of showing up for yourself.';

  @override
  String get notifMilestone7d =>
      '7 Days Sober. One full week — that takes real courage.';

  @override
  String get notifMilestone10d =>
      '10 Days Sober. Double digits. Quietly, steadily, you keep going.';

  @override
  String get notifMilestone14d =>
      '14 Days Sober. Two weeks. Your body and mind are already responding.';

  @override
  String get notifMilestone21d =>
      '21 Days Sober. Three weeks. New routines are starting to take root.';

  @override
  String get notifMilestone30d =>
      '30 Days Sober. One month of choosing yourself, one day at a time.';

  @override
  String get notifMilestone60d =>
      '60 Days Sober. Two months. Every single day has mattered.';

  @override
  String get notifMilestone90d =>
      '90 Days Sober. Three months. Keep going at your own pace.';

  @override
  String get notifMilestone180d =>
      '180 Days Sober. Half a year. That\'s a lot of days showing up.';

  @override
  String get notifMilestone365d =>
      '1 Year Sober. 365 days. Take a moment to acknowledge how far you\'ve come.';

  @override
  String get notifMilestone730d =>
      '2 Years Sober. Two years of choosing yourself, over and over again.';

  @override
  String get notifMilestone1095d =>
      '3 Years Sober. Three years. Your path forward is your own.';

  @override
  String get moodGreat => 'Great';

  @override
  String get moodGood => 'Good';

  @override
  String get moodOkay => 'Okay';

  @override
  String get moodHard => 'Hard';

  @override
  String get moodCrisis => 'Crisis';

  @override
  String get subMoodAnxious => 'anxious';

  @override
  String get subMoodAshamed => 'ashamed';

  @override
  String get subMoodLonely => 'lonely';

  @override
  String get subMoodAngry => 'angry';

  @override
  String get subMoodGrieving => 'grieving';

  @override
  String get subMoodNumb => 'numb';

  @override
  String get subMoodOverwhelmed => 'overwhelmed';

  @override
  String get subMoodCraving => 'craving';

  @override
  String get subMoodProud => 'proud';

  @override
  String get subMoodEnergized => 'energized';

  @override
  String get subMoodPeaceful => 'peaceful';

  @override
  String get subMoodGrateful => 'grateful';

  @override
  String get subMoodHopeful => 'hopeful';

  @override
  String get subMoodConnected => 'connected';

  @override
  String get subMoodFocused => 'focused';

  @override
  String get subMoodFree => 'free';

  @override
  String get promptCatReflection => 'Reflection';

  @override
  String get promptCatGratitude => 'Gratitude';

  @override
  String get promptCatHard => 'Hard day';

  @override
  String get promptCatWins => 'Wins';

  @override
  String get promptCatCraving => 'Craving';

  @override
  String get promptCatPeople => 'People';

  @override
  String get journalPromptR1 =>
      'What pulled at me today — and what held me steady?';

  @override
  String get journalPromptR2 => 'If today had a colour, what would it be? Why?';

  @override
  String get journalPromptR3 =>
      'What did my body tell me today that I almost ignored?';

  @override
  String get journalPromptR4 =>
      'Where did I show up for myself today, even imperfectly?';

  @override
  String get journalPromptR5 => 'What truth am I avoiding right now?';

  @override
  String get journalPromptR6 =>
      'What story did I tell myself today — and was it kind, or just familiar?';

  @override
  String get journalPromptR7 =>
      'What would the wisest version of me say about today?';

  @override
  String get journalPromptR8 => 'What is one thing I am ready to set down?';

  @override
  String get journalPromptR9 => 'What feeling have I been outrunning?';

  @override
  String get journalPromptR10 => 'When did I feel most like myself today?';

  @override
  String get journalPromptG1 =>
      'Three small things I am grateful for right now.';

  @override
  String get journalPromptG2 =>
      'Someone who made my life easier this week — and why.';

  @override
  String get journalPromptG3 =>
      'A body part that did its job today without me noticing.';

  @override
  String get journalPromptG4 => 'A sound, smell, or taste that landed today.';

  @override
  String get journalPromptG5 =>
      'A thing I have now that past-me would have begged for.';

  @override
  String get journalPromptG6 => 'A small comfort that softened a hard moment.';

  @override
  String get journalPromptG7 =>
      'A piece of music, a view, a meal — what fed me today?';

  @override
  String get journalPromptG8 =>
      'Who in my life right now is steady? Name them.';

  @override
  String get journalPromptG9 =>
      'A skill I have today that I did not have a year ago.';

  @override
  String get journalPromptG10 =>
      'One ordinary moment today that I want to remember.';

  @override
  String get journalPromptH1 =>
      'What hurt today? Just name it — no fix, no spin.';

  @override
  String get journalPromptH2 =>
      'If this feeling could speak, what would it say it needs?';

  @override
  String get journalPromptH3 => 'What part of today felt unfair?';

  @override
  String get journalPromptH4 =>
      'Is there a feeling I am calling anger that is actually something else underneath?';

  @override
  String get journalPromptH5 =>
      'What would I say to a friend who was where I am right now?';

  @override
  String get journalPromptH6 =>
      'What is the smallest next step I can take, even if I do not feel like it?';

  @override
  String get journalPromptH7 =>
      'Who can I tell about this — even one person, even one sentence?';

  @override
  String get journalPromptH8 =>
      'What am I making this mean about me — and is that true?';

  @override
  String get journalPromptH9 =>
      'What did today take from me? What did it leave?';

  @override
  String get journalPromptH10 =>
      'If I could fast-forward 24 hours, what would I want to be true?';

  @override
  String get journalPromptW1 => 'A moment today I am quietly proud of.';

  @override
  String get journalPromptW2 =>
      'Something I did today that past-me could not have done.';

  @override
  String get journalPromptW3 =>
      'A risk I took — however small — and how it landed.';

  @override
  String get journalPromptW4 => 'Where did I choose myself today?';

  @override
  String get journalPromptW5 => 'A boundary I held, even if no one noticed.';

  @override
  String get journalPromptW6 => 'A craving I rode through.';

  @override
  String get journalPromptW7 => 'A conversation I am glad I had.';

  @override
  String get journalPromptW8 => 'Something I finished. Anything.';

  @override
  String get journalPromptW9 => 'A way my body felt strong today.';

  @override
  String get journalPromptW10 =>
      'A way I treated myself the way I would treat someone I love.';

  @override
  String get journalPromptC1 =>
      'When did the urge start today, and what was happening around me?';

  @override
  String get journalPromptC2 => 'What was my body doing when the craving hit?';

  @override
  String get journalPromptC3 => 'What was the lie the craving was telling me?';

  @override
  String get journalPromptC4 =>
      'What did I actually need underneath the craving — rest, connection, food, quiet?';

  @override
  String get journalPromptC5 => 'How long did it last before it began to pass?';

  @override
  String get journalPromptC6 =>
      'What did I do instead — and how do I feel about that choice now?';

  @override
  String get journalPromptC7 => 'Who or what helped me ride this one out?';

  @override
  String get journalPromptC8 =>
      'If this craving returns tomorrow, what is one thing I can have ready?';

  @override
  String get journalPromptC9 =>
      'What would the version of me a year sober say to this craving?';

  @override
  String get journalPromptC10 =>
      'What is the craving costing me, even when I do not use?';

  @override
  String get journalPromptP1 =>
      'Who do I owe an honest sentence to — even if I never say it?';

  @override
  String get journalPromptP2 =>
      'A relationship that feels lighter than it did a year ago.';

  @override
  String get journalPromptP3 =>
      'Someone I keep replaying conversations with — what is unfinished there?';

  @override
  String get journalPromptP4 =>
      'A person I keep meaning to reach out to — what is one sentence I could send?';

  @override
  String get journalPromptP5 =>
      'Where do I feel most seen lately? Where do I feel most invisible?';

  @override
  String get journalPromptP6 =>
      'What is one boundary I am proud of — even a small one?';

  @override
  String get journalPromptP7 =>
      'Who in my life has earned more of me? Who has earned less?';

  @override
  String get journalPromptP8 =>
      'A thing someone said to me that I am still carrying.';

  @override
  String get journalPromptP9 =>
      'What would a healthier version of me say to the people in my life right now?';

  @override
  String get journalPromptP10 =>
      'Who do I want to be remembered as — by the people closest to me?';

  @override
  String get visionIconGuide => 'Guide';

  @override
  String get visionIconStrength => 'Strength';

  @override
  String get visionIconLove => 'Love';

  @override
  String get visionIconHome => 'Home';

  @override
  String get visionIconFamily => 'Family';

  @override
  String get visionIconSavings => 'Savings';

  @override
  String get visionIconLearn => 'Learn';

  @override
  String get visionIconGrowth => 'Growth';

  @override
  String get visionIconJourney => 'Journey';

  @override
  String get visionIconCreate => 'Create';

  @override
  String get visionIconMove => 'Move';

  @override
  String get visionIconStillness => 'Stillness';

  @override
  String get visionIconWisdom => 'Wisdom';

  @override
  String get visionIconAim => 'Aim';

  @override
  String get visionIconHope => 'Hope';

  @override
  String get visionIconPeace => 'Peace';

  @override
  String get visionIconSupport => 'Support';

  @override
  String get visionIconBloom => 'Bloom';

  @override
  String get visionIconMilestone => 'Milestone';

  @override
  String get visionIconSpark => 'Spark';

  @override
  String get visionCategoryHealth => 'Health';

  @override
  String get visionCategoryFamily => 'Family';

  @override
  String get visionCategoryCareer => 'Career';

  @override
  String get visionCategoryGrowth => 'Growth';

  @override
  String get visionCategoryFreedom => 'Freedom';

  @override
  String get visionCategoryAdventure => 'Adventure';

  @override
  String get visionCategoryService => 'Service';

  @override
  String get visionCategoryCreativity => 'Creativity';

  @override
  String get visionCategoryUncategorised => 'Uncategorised';

  @override
  String get visionStarterFreedomYearTitle => 'One year of freedom';

  @override
  String get visionStarterFreedomYearAffirmation =>
      'I am building a life I love, one sober day at a time.';

  @override
  String get visionStarterPresentParentTitle => 'Be the parent I want to be';

  @override
  String get visionStarterPresentParentAffirmation =>
      'I am present, patient, and proud of how I show up for my family.';

  @override
  String get visionStarterRun5kTitle => 'Run a 5K';

  @override
  String get visionStarterRun5kAffirmation =>
      'I am strong, I move with purpose, and my body is reclaiming itself.';

  @override
  String get visionStarterSaveMeaningfulTitle =>
      'Save for something meaningful';

  @override
  String get visionStarterSaveMeaningfulAffirmation =>
      'Every day sober is money in my pocket and possibility in my future.';

  @override
  String get visionStarterLearnSkillTitle => 'Learn a new skill';

  @override
  String get visionStarterLearnSkillAffirmation =>
      'I am curious, I am capable, and I keep growing.';

  @override
  String get visionStarterHealRelationshipTitle => 'Heal a relationship';

  @override
  String get visionStarterHealRelationshipAffirmation =>
      'I lead with honesty and humility. The right people are coming closer.';

  @override
  String get cravingResponseWalked => 'Walked away / outside';

  @override
  String get cravingResponseCalled => 'Called someone';

  @override
  String get cravingResponseBreathed => 'Breathed / urge-surfed';

  @override
  String get cravingResponseJournaled => 'Journaled / wrote';

  @override
  String get cravingResponseWater => 'Drank water / ate';

  @override
  String get cravingResponseGrounded => 'Grounded / prayed / meditated';

  @override
  String get cravingTimeAm => 'AM';

  @override
  String get cravingTimePm => 'PM';

  @override
  String cravingHourMeridiem(int hour, String meridiem) {
    return '$hour $meridiem';
  }

  @override
  String cravingRiskWindowRange(String start, String end) {
    return '$start–$end';
  }

  @override
  String get journalReauthUnlockEntry => 'Unlock this entry';

  @override
  String get journalReauthIncorrectPin => 'Incorrect PIN';

  @override
  String emergencyCallFailed(String number) {
    return 'Couldn\'t open the dialer. Call $number directly.';
  }

  @override
  String get lockScreenNeedHelp => 'Need help right now?';

  @override
  String get visionPhotoSaveFailed =>
      'Couldn\'t save that photo. Please try again.';

  @override
  String get notifChannelDescription => 'Daily reminders and milestone alerts';

  @override
  String get groupRefugeTagline => 'Mindfulness-based recovery';

  @override
  String get groupRefugeDesc =>
      'Uses Buddhist principles and meditation as the foundation for recovery. No requirement to be Buddhist — the focus is on compassion, mindfulness, and the causes of suffering.';

  @override
  String get groupRefugeApproach =>
      'Mindfulness · Buddhist-informed · Meditation';

  @override
  String get groupRefugeRegions => 'Worldwide · Online';

  @override
  String get groupCelebrateTagline => 'Faith-based recovery';

  @override
  String get groupCelebrateDesc =>
      'A Christ-centred 12-step programme for hurts, habits, and hang-ups. Runs through local churches. Welcoming to anyone dealing with addiction or life struggles.';

  @override
  String get groupCelebrateApproach => '12-step · Christian · Faith-based';

  @override
  String get groupCelebrateRegions => 'Worldwide · Many SA churches';

  @override
  String get groupWfsTagline => 'WFS — women-only support';

  @override
  String get groupWfsDesc =>
      'A programme specifically for women, focusing on building positive emotions, self-worth, and a new life. Online and in-person meetings.';

  @override
  String get groupWfsApproach => 'Women-only · Positive focus · Empowerment';

  @override
  String get groupWfsRegions => 'Worldwide · Online';

  @override
  String get groupLifeRingTagline => 'Non-spiritual peer support';

  @override
  String get groupLifeRingDesc =>
      'Secular, non-religious peer support. No steps, no higher power. Focus on sobriety, secularity, and self-help. Online and in-person.';

  @override
  String get groupLifeRingApproach => 'Secular · Non-12-step · Self-directed';

  @override
  String get groupLifeRingRegions => 'Worldwide · Online';

  @override
  String get groupOnlineTagline => 'Digital support — always available';

  @override
  String get groupOnlineDesc =>
      'Communities like r/stopdrinking, SoberGrid, and Sober.com offer 24/7 peer support, accountability partners, and daily check-ins — right from your phone.';

  @override
  String get groupOnlineApproach => 'Online · Anonymous · 24/7';

  @override
  String get groupOnlineRegions => 'Global · Always online';

  @override
  String get weeklySummarySupportJournal => 'Journal';

  @override
  String get weeklySummarySupportCraving => 'Craving support';

  @override
  String get weeklySummarySupportThought => 'Thought exercises';

  @override
  String get weeklySummarySupportMovement => 'Movement';

  @override
  String get weeklySummarySupportSleep => 'Sleep log';

  @override
  String get weeklySummarySupportGratitude => 'Gratitude';

  @override
  String get weeklySummarySupportPledge => 'Daily pledge';

  @override
  String get weeklySummarySupportVarious => 'Various';

  @override
  String weeklySummaryPdfHeaderLine(String appName, String range) {
    return '$appName  •  $range';
  }

  @override
  String get weeklySummaryPdfGeneratedBy => 'Generated by Journey Forward';

  @override
  String get learnedTitle => 'What I\'ve learned';

  @override
  String get learnedShareButton => 'Share my plan';

  @override
  String get learnedSubtitle =>
      'Quiet patterns from your own check-ins — kept on this device, no judgement.';

  @override
  String get learnedEmptyTitle => 'Your insights are still growing';

  @override
  String get learnedEmptyBody =>
      'As you log how cravings go and what you did about them, this page fills with what actually works for you. Nothing to get right — just keep checking in.';

  @override
  String get learnedEmptyCta => 'Check in now';

  @override
  String get learnedWorkedHeader => 'WHAT\'S WORKED FOR YOU';

  @override
  String get learnedWorkedIntro =>
      'When you tried these, here\'s how often the urge passed without a slip.';

  @override
  String learnedWorkedStat(int sober, int total) {
    return 'stayed sober $sober of $total';
  }

  @override
  String get learnedRiskHeader => 'YOUR TENDER HOURS';

  @override
  String learnedRiskBody(int count, int total, String window) {
    return '$count of your $total logged cravings landed around $window. Worth planning something steadying for then.';
  }

  @override
  String get learnedHaltHeader => 'WHAT\'S OFTEN UNDERNEATH';

  @override
  String get learnedHaltBody =>
      'Your cravings most often showed up when you were:';

  @override
  String learnedTimesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: '1 time',
    );
    return '$_temp0';
  }

  @override
  String get learnedTriggersHeader => 'YOUR COMMON TRIGGERS';

  @override
  String get learnedTriggersIntro => 'The situations you\'ve named most often:';

  @override
  String learnedTriggerChip(String label, int count) {
    return '$label ×$count';
  }

  @override
  String get learnedWinsHeader => 'YOUR WINS';

  @override
  String learnedWinsRidden(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count urges ridden out',
      one: '1 urge ridden out',
    );
    return '$_temp0';
  }

  @override
  String learnedWinsSober(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'stayed sober through $count cravings',
      one: 'stayed sober through 1 craving',
    );
    return '$_temp0';
  }

  @override
  String get learnedPlanHeader => 'YOUR PLAN WHEN A CRAVING HITS';

  @override
  String get learnedPlanEmpty =>
      'You haven\'t written a plan yet. A few lines now can carry you through a hard moment later.';

  @override
  String get learnedPlanCreate => 'Create my plan';

  @override
  String get learnedPlanEdit => 'Edit plan';

  @override
  String get learnedReasonsHeader => 'WHY YOU\'RE DOING THIS';

  @override
  String get learnedFooter =>
      'Slips are information, not failure. Every line here is something you learned by showing up.';

  @override
  String get learnedShareHeading => 'My recovery safety plan';

  @override
  String get tippTitle => 'TIPP — fast reset';

  @override
  String get tippIntroTitle => 'When it spikes past thinking';

  @override
  String get tippIntro =>
      'These four shift your body chemistry in minutes — no thinking required. Pick one and follow along.';

  @override
  String get tippTempLabel => 'Temperature';

  @override
  String get tippTempWhy => 'Cold on your face slows a racing heart fast.';

  @override
  String get tippTempStep1 =>
      'Fill a bowl with cold water, or grab a cold pack or ice.';

  @override
  String get tippTempStep2 =>
      'Hold your breath and put your face in the cold water — or hold the cold to your eyes and cheeks — for about 30 seconds.';

  @override
  String get tippTempStep3 =>
      'Notice your body settle as your heart rate drops. Repeat once if you need to.';

  @override
  String get tippIntenseLabel => 'Intense movement';

  @override
  String get tippIntenseWhy =>
      'A short burst burns off the surge of stress hormones.';

  @override
  String get tippIntenseStep1 =>
      'Pick something you can do hard for a short burst — jumping jacks, running on the spot, fast stairs.';

  @override
  String get tippIntenseStep2 =>
      'Go all-out for 1 to 5 minutes, until you\'re a little out of breath.';

  @override
  String get tippIntenseStep3 =>
      'Let your breathing come back down. The urge usually drops with it.';

  @override
  String get tippPacedLabel => 'Paced breathing';

  @override
  String get tippPacedWhy =>
      'Longer out-breaths than in-breaths switch on the body\'s calming system.';

  @override
  String get tippPacedHint =>
      'Follow the circle. The out-breath is the longest part.';

  @override
  String get tippBreatheIn => 'Breathe in';

  @override
  String get tippHold => 'Hold';

  @override
  String get tippBreatheOut => 'Breathe out';

  @override
  String get tippPmrLabel => 'Paired muscle relaxation';

  @override
  String get tippPmrWhy =>
      'Tense as you breathe in, release as you breathe out — tension leaves with the breath.';

  @override
  String get tippPmrStep1 =>
      'Breathe in and tense a muscle group — fists, shoulders, or jaw — firmly but not to the point of pain.';

  @override
  String get tippPmrStep2 =>
      'Hold the tension for a few seconds while you notice it.';

  @override
  String get tippPmrStep3 =>
      'Breathe out and let it go all at once. Move through your body, group by group.';

  @override
  String get tippStartTimer => 'Start 30-second timer';

  @override
  String tippTimerRemaining(int seconds) {
    return '${seconds}s';
  }

  @override
  String get tippNeedMore => 'Need more than this right now?';

  @override
  String get tippCrisisButton => 'Crisis lines';

  @override
  String get emergencyTippTitle => 'TIPP reset';

  @override
  String get progressLearnedCardTitle => 'What I\'ve learned';

  @override
  String get progressLearnedCardSubtitle =>
      'Your patterns & safety plan, from your own logs';

  @override
  String get slipSupportTryTipp => 'Try a TIPP reset';

  @override
  String get slipSupportTryTippSub =>
      'Fast body-based skills for when it spikes';

  @override
  String get planToolkitTippLabel => 'TIPP reset';

  @override
  String get planToolkitTippSub => 'Temperature · move · breathe · release';

  @override
  String a11ySoberDuration(int days, int hours, int minutes, int seconds) {
    return '$days days, $hours hours, $minutes minutes, $seconds seconds sober';
  }

  @override
  String a11yCountdownDuration(int days, int hours, int minutes, int seconds) {
    return 'Starts in $days days, $hours hours, $minutes minutes, $seconds seconds';
  }

  @override
  String a11yHeatmapSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cravings heatmap, last 28 days. $count logged.',
      one: 'Cravings heatmap, last 28 days. 1 logged.',
      zero: 'Cravings heatmap, last 28 days. None logged yet.',
    );
    return '$_temp0';
  }

  @override
  String a11yHeatmapDayCravings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cravings',
      one: '1 craving',
      zero: 'no cravings',
    );
    return '$_temp0';
  }

  @override
  String get challengeTitle => '100-day challenge';

  @override
  String get challengeTileLabel => 'The 100';

  @override
  String get challengeSubtitle => 'One hundred days, marked off one at a time.';

  @override
  String challengeCountLabel(int done, int total) {
    return '$done of $total days';
  }

  @override
  String get challengeHint =>
      'Tap a day to tick it off. Press and hold to add a sticker or clear it.';

  @override
  String challengeOnDay(int day) {
    return 'You\'re on day $day of your streak.';
  }

  @override
  String get challengeComplete => 'All 100 days. What a thing you\'ve done. 🏆';

  @override
  String challengeStickerSheetTitle(int day) {
    return 'Day $day';
  }

  @override
  String get challengePickSticker => 'Choose a sticker';

  @override
  String get challengeClearDay => 'Clear this day';

  @override
  String get challengeShareSectionLabel => 'SHARE YOUR PROGRESS';

  @override
  String get challengeShareButton => 'Share my progress';

  @override
  String get challengeShareCardBrand => '100 DAYS SOBER';

  @override
  String challengeShareText(int done) {
    return '$done of my 100 sober days, marked off. 🌱 One day at a time.';
  }

  @override
  String get challengeReset => 'Reset challenge';

  @override
  String get challengeResetTitle => 'Reset the challenge?';

  @override
  String get challengeResetBody =>
      'This clears every day you have marked off. Your sobriety streak and all your other data stay exactly as they are.';

  @override
  String get challengeResetConfirm => 'Reset';

  @override
  String get challengeResetCancel => 'Keep my progress';

  @override
  String challengeA11yDayDone(int day) {
    return 'Day $day, marked off';
  }

  @override
  String challengeA11yDayTodo(int day) {
    return 'Day $day, not yet marked';
  }

  @override
  String get navPlanner => 'Plan';

  @override
  String get plannerTabOverview => 'Overview';

  @override
  String get plannerTabPlanner => 'Planner';

  @override
  String get plannerTabStreaks => 'Streaks';

  @override
  String get plannerMyGoals => 'My goals';

  @override
  String get plannerAddGoal => 'Add goal';

  @override
  String get plannerNoGoals => 'No goals yet. Add one to start your plan.';

  @override
  String get plannerGoalTypeRace => 'Race';

  @override
  String get plannerGoalTypeWeight => 'Weight';

  @override
  String get plannerGoalTypeHabit => 'Habit';

  @override
  String get plannerGoalTypeExercise => 'Exercise';

  @override
  String get plannerGoalNameLabel => 'Goal name';

  @override
  String get plannerGoalNameHint => 'e.g. Two Oceans Half';

  @override
  String get plannerGoalNameHintWeight => 'e.g. Summer reset';

  @override
  String get plannerMeasureLabel => 'Track progress by';

  @override
  String get plannerMeasureDistance => 'Distance';

  @override
  String get plannerMeasureTime => 'Active time';

  @override
  String get plannerMeasureSessions => 'Sessions';

  @override
  String get plannerTargetLabel => 'Target';

  @override
  String get plannerStartDateLabel => 'Start date';

  @override
  String get plannerEndDateLabel => 'Goal date';

  @override
  String get plannerPaceAhead => 'Ahead of pace';

  @override
  String get plannerPaceOnTrack => 'On track';

  @override
  String get plannerPaceBehind => 'Behind pace';

  @override
  String get plannerGoalReached => 'Goal reached!';

  @override
  String get plannerInProgress => 'In progress';

  @override
  String plannerDaysLeft(int count) {
    return '$count days left';
  }

  @override
  String plannerPerWeekHint(String amount) {
    return '~$amount / week to finish on time';
  }

  @override
  String plannerLoggedOfTarget(String logged, String target) {
    return '$logged of $target';
  }

  @override
  String get plannerArchiveGoal => 'Archive goal';

  @override
  String get plannerUnarchiveGoal => 'Restore goal';

  @override
  String get plannerDisciplineRun => 'Run';

  @override
  String get plannerDisciplineRide => 'Ride';

  @override
  String get plannerDisciplineSwim => 'Swim';

  @override
  String get plannerDisciplineWalk => 'Walk';

  @override
  String get plannerDisciplineHike => 'Hike';

  @override
  String get plannerDisciplineGym => 'Gym';

  @override
  String get plannerDisciplineYoga => 'Yoga';

  @override
  String get plannerDisciplineCardio => 'Cardio';

  @override
  String get plannerDisciplineOther => 'Other';

  @override
  String get plannerTotalActiveTime => 'Total active time';

  @override
  String get plannerByActivity => 'By activity';

  @override
  String plannerActivityCount(int count) {
    return '$count activities';
  }

  @override
  String plannerDurationHm(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get plannerActivityTypeLabel => 'Activity';

  @override
  String get plannerActivityDateLabel => 'Date';

  @override
  String get plannerMetricEffort => 'Effort (1–10)';

  @override
  String get plannerMetricElevation => 'Elevation gain';

  @override
  String get plannerMetricPoolLength => 'Pool length';

  @override
  String get plannerStrengthExercises => 'Exercises';

  @override
  String get plannerStrengthExerciseHint => 'Exercise';

  @override
  String get plannerStrengthAddExercise => 'Add exercise';

  @override
  String get plannerStrengthSets => 'Sets';

  @override
  String get plannerStrengthReps => 'Reps';

  @override
  String get plannerStrengthWeight => 'Weight';

  @override
  String get plannerUnitMeters => 'm';

  @override
  String get plannerUnitFeet => 'ft';

  @override
  String plannerEffortValue(int value) {
    return 'RPE $value';
  }

  @override
  String plannerStrengthSummary(int count) {
    return '$count exercises';
  }

  @override
  String get plannerUnitSpeedKmh => 'km/h';

  @override
  String get plannerUnitSpeedMph => 'mph';

  @override
  String get plannerUnitPace100m => '/100m';

  @override
  String get plannerShareProgress => 'Share progress';

  @override
  String get plannerShareHeading => 'My training';

  @override
  String get plannerRange1Week => '1 week';

  @override
  String get plannerRange2Weeks => '2 weeks';

  @override
  String get plannerRange4Weeks => '4 weeks';

  @override
  String get plannerRangeAll => 'All time';

  @override
  String get plannerShareCta => 'Share';

  @override
  String get plannerShareMessage => 'My training on Journey Forward';

  @override
  String get plannerRace10k => '10K';

  @override
  String get plannerRaceHalf => 'Half marathon';

  @override
  String get plannerRaceFull => 'Marathon';

  @override
  String get plannerRaceComrades => 'Comrades';

  @override
  String plannerGoalProgress(int percent) {
    return '$percent% there';
  }

  @override
  String get plannerSessionEasyRun => 'Easy run';

  @override
  String get plannerSessionIntervals => 'Intervals';

  @override
  String get plannerSessionTempo => 'Tempo';

  @override
  String get plannerSessionLongRun => 'Long run';

  @override
  String get plannerSessionRest => 'Rest';

  @override
  String get plannerSessionCrossTrain => 'Cross-train';

  @override
  String get plannerSessionSwim => 'Swim';

  @override
  String get plannerSessionOther => 'Other';

  @override
  String plannerSessionLine(String label, String distance) {
    return '$label · $distance';
  }

  @override
  String get plannerCurrentWeek => 'This week';

  @override
  String get plannerNextWeek => 'Next week';

  @override
  String get plannerNextWeekEmpty => 'Nothing planned for next week yet.';

  @override
  String get plannerNoActivitiesThisWeek => 'No activity logged this week.';

  @override
  String get plannerTrendLast8Weeks => 'Last 8 weeks';

  @override
  String get plannerWeekThis => 'This week';

  @override
  String get plannerWeekLast => 'Last week';

  @override
  String get plannerWeekPrev => 'Previous week';

  @override
  String get plannerWeekNext => 'Next week';

  @override
  String get plannerMarkComplete => 'Mark complete';

  @override
  String get plannerMarkIncomplete => 'Mark incomplete';

  @override
  String get plannerAddSession => 'Add session';

  @override
  String get plannerResetPlan => 'Reset plan';

  @override
  String get plannerResetPlanTitle => 'Reset your plan?';

  @override
  String get plannerResetPlanBody =>
      'This clears every planned session. Your logged workouts and history stay exactly as they are.';

  @override
  String get plannerResetPlanConfirm => 'Reset plan';

  @override
  String get plannerResetPlanCancel => 'Keep my plan';

  @override
  String get plannerEditSession => 'Edit session';

  @override
  String get plannerDeleteSession => 'Delete session';

  @override
  String get plannerUsePreset => 'Use a preset plan';

  @override
  String get plannerBuildYourOwn => 'Build your own';

  @override
  String get plannerPlanStartDate => 'Plan start date';

  @override
  String get plannerPreset10k => 'Couch to 10K';

  @override
  String get plannerPresetHalf => 'Half marathon build';

  @override
  String get plannerPresetFull => 'Marathon build';

  @override
  String get plannerPresetComrades => 'Comrades build';

  @override
  String get plannerCurrentStreak => 'Current streak';

  @override
  String plannerWeeklyProgress(int percent) {
    return '$percent% of this week';
  }

  @override
  String plannerWorkoutsOfTarget(int done, int total) {
    return '$done of $total workouts';
  }

  @override
  String get plannerBodyJourney => 'Body journey';

  @override
  String get bodyCareTitle => 'Body Care';

  @override
  String get bodyCareGateTitle => 'How do you want to care for your body here?';

  @override
  String get bodyCareGateBody =>
      'There\'s no right answer, and you can change this anytime.';

  @override
  String get bodyCareModeFeelings => 'Track how I feel';

  @override
  String get bodyCareModeFeelingsDesc =>
      'No numbers — just wins and how your body feels.';

  @override
  String get bodyCareModeSometimes => 'Weigh now and then';

  @override
  String get bodyCareModeSometimesDesc =>
      'A gentle, occasional check-in. You can hide the number anytime.';

  @override
  String get bodyCareHeroNew =>
      'Your garden is ready. Tend it with one small act of care.';

  @override
  String get bodyCareTendedThisWeek => 'You\'ve tended your journey this week.';

  @override
  String get bodyCareTendThisWeek =>
      'Tend your journey this week — log a win or a moment of care.';

  @override
  String get bodyCareWinsTitle => 'Today\'s wins';

  @override
  String get bodyCareWinLogged => 'Win logged.';

  @override
  String get bodyCareCustomWinTitle => 'Your own win';

  @override
  String get bodyCareCustomWinHint => 'Something kind your body did today…';

  @override
  String get bodyCareWinEnergy => 'More energy today';

  @override
  String get bodyCareWinClothes => 'Clothes felt better';

  @override
  String get bodyCareWinMoved => 'Moved without getting winded';

  @override
  String get bodyCareWinCraving => 'Rode out a craving';

  @override
  String get bodyCareWinSleep => 'Slept well';

  @override
  String get bodyCareWinNourished => 'Ate to nourish, not punish';

  @override
  String get bodyCareWinStrong => 'Felt strong';

  @override
  String get bodyCareWinShowedUp => 'I just showed up today';

  @override
  String get bodyCareWinCustom => 'A win of my own';

  @override
  String get bodyCareRecentTitle => 'Recent care';

  @override
  String get bodyCareNoWinsYet => 'Your wins will gather here.';

  @override
  String get bodyCareShowNumbers => 'Show the number';

  @override
  String get bodyCareHideNumbers => 'Hide the number';

  @override
  String get bodyCareNumbersHidden =>
      'The number is resting. Your care continues.';

  @override
  String get bodyCareNoWeighIn => 'No weigh-in yet — only when you\'re ready.';

  @override
  String get bodyCareLogWeighIn => 'Log a weigh-in';

  @override
  String get bodyCareTrendTitle => 'Gentle trend';

  @override
  String get bodyCareTrendBandHint =>
      'Day-to-day weight naturally drifts up and down — a small bump is just your body, not a setback.';

  @override
  String get bodyCareTowardGentleGoal => 'Toward your gentle goal';

  @override
  String get bodyCareEnterWeight => 'Enter a weight to log it.';

  @override
  String get bodyCareGoalTooLow =>
      'That goal looks very low. Let\'s choose a gentler target — your wellbeing matters far more than a number.';

  @override
  String get bodyCareGoalTooMuch =>
      'That\'s a big change to aim for at once. A smaller, kinder goal tends to be more sustainable — and you can always set a new one later.';

  @override
  String get bodyCareUseGentlerGoal => 'Choose a gentler goal';

  @override
  String bodyCareWeeksTended(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks tended',
      one: '1 week tended',
    );
    return '$_temp0';
  }

  @override
  String bodyCareWeightCaption(String weight) {
    return 'Latest $weight';
  }

  @override
  String get plannerCurrentWeight => 'Current weight';

  @override
  String get plannerChangeSinceStart => 'Change since start';

  @override
  String get plannerGoalWeight => 'Goal weight';

  @override
  String get plannerWeightTrend => 'Weight trend';

  @override
  String get plannerAddWeightEntry => 'Add weight entry';

  @override
  String get plannerWeightReflection => 'Reflection';

  @override
  String get plannerWeightMilestone => 'Milestone';

  @override
  String plannerWeightSince(String date) {
    return 'Since $date';
  }

  @override
  String get plannerUnitKg => 'kg';

  @override
  String get plannerUnitLb => 'lb';

  @override
  String get plannerUnitPaceKm => 'min/km';

  @override
  String get plannerUnitPaceMi => 'min/mi';

  @override
  String get settingsImperialWeight => 'Use pounds (lb)';

  @override
  String get settingsImperialWeightSub => 'Show weight in lb instead of kg';

  @override
  String get plannerSourceManual => 'Manual';

  @override
  String get plannerHistory => 'History';

  @override
  String get plannerInsights => 'Insights';

  @override
  String get plannerDistanceTrend => 'Distance trend';

  @override
  String get plannerWeeklyVolume => 'Weekly volume';

  @override
  String get plannerAvgPace => 'Average pace';

  @override
  String get plannerAvgHeartRate => 'Avg heart rate';

  @override
  String get plannerHabitMetricLabel => 'Metric (what you\'re counting)';

  @override
  String get plannerHabitTargetLabel => 'Target';

  @override
  String get plannerTotalDistance => 'Total distance';

  @override
  String get plannerNoActivities => 'No activities logged yet.';

  @override
  String get homeTodaySessionTitle => 'Today\'s session';

  @override
  String get homeRestDay => 'Rest day';

  @override
  String get homeTodaySessionCta => 'Open planner';

  @override
  String get plannerA11yDayDone => 'Workout done';

  @override
  String get plannerA11yDayTodo => 'Workout planned';

  @override
  String plannerA11yProgressRing(int percent) {
    return '$percent percent of weekly goal complete';
  }

  @override
  String plannerPlannedPrefix(String value) {
    return 'Planned: $value';
  }

  @override
  String get plannerLogSessionTitle => 'How did it go?';

  @override
  String get plannerLogActualHeader => 'What you actually did';

  @override
  String get plannerLogSessionCta => 'Log session';

  @override
  String get plannerSkipSessionCta => 'Mark as skipped';

  @override
  String get plannerSkippedLabel => 'Skipped';

  @override
  String get plannerCloseOffCta => 'Close off session';

  @override
  String get plannerReopenSession => 'Reopen session';

  @override
  String plannerTimelineRange(String start, String goal) {
    return 'Training $start → Goal $goal';
  }

  @override
  String plannerTimelineGoalOnly(String goal) {
    return 'Goal $goal';
  }

  @override
  String get plannerGoalDatePassed => 'Goal date passed';

  @override
  String get plannerGoalDayToday => 'Goal day is today';

  @override
  String get plannerOneDayLeft => '1 day left';

  @override
  String get plannerTrainingNotStarted => 'Training hasn\'t started yet';

  @override
  String get plannerTargetCaption => 'Target';

  @override
  String get plannerA11yDaySkipped => 'Workout skipped';

  @override
  String get plannerPrevMonth => 'Previous month';

  @override
  String get plannerNextMonth => 'Next month';

  @override
  String plannerSessionsCount(int count) {
    return '$count sessions';
  }

  @override
  String get plannerSessionsSectionLabel => 'Training sessions';

  @override
  String get plannerNoSessionsYet => 'No sessions planned yet';

  @override
  String plannerWeekLabel(int number) {
    return 'Week $number';
  }

  @override
  String get plannerHealthDisclaimer =>
      'Before starting any fitness or health activity, make sure you\'re fit to do so. If in doubt, check with your GP or a qualified health professional.';

  @override
  String get plannerGoalEncourageTitle => 'Every goal counts';

  @override
  String get plannerGoalEncourageBody =>
      'Setting a goal and working towards it is one of the most rewarding parts of recovery — it gives your days shape and your energy somewhere to go. It doesn’t have to be big: getting out to walk more, sleeping better, losing a little weight, running your first 5k, or one day a marathon. Whatever it is, any goal is worth working towards. Start small, stay steady, and let it grow with you.';

  @override
  String get plannerSessionNotesHint =>
      'Session plan (optional) - e.g. 8 x 400m, 200m jog recoveries';

  @override
  String get onbLanguageHeadline => 'Choose your language';

  @override
  String get onbLanguageSub => 'You can change this anytime in Settings.';

  @override
  String get commonComingSoon => 'Coming soon';

  @override
  String get plannerGoalKindQuestion =>
      'Are you working toward a goal, or training for an event?';

  @override
  String get plannerGoalKindGoal => 'A goal';

  @override
  String get plannerGoalKindEvent => 'An event';

  @override
  String get plannerEventDayLabel => 'Event day';

  @override
  String get recordTitle => 'Record';

  @override
  String get recordEntryLabel => 'Record a walk or run';

  @override
  String get recordPrimingTitle => 'Track your walk or run';

  @override
  String get recordPrimingBody =>
      'Journey Forward uses your phone\'s GPS to measure distance, time and pace. Your location stays on this device — no map, no internet, nothing shared.';

  @override
  String get recordPrimingCta => 'Enable location';

  @override
  String get recordPrimingNotNow => 'Not now';

  @override
  String get recordPermDeniedTitle => 'Location is off';

  @override
  String get recordPermDeniedBody =>
      'Location permission is needed to measure your distance. You can turn it on in Settings.';

  @override
  String get recordOpenSettings => 'Open settings';

  @override
  String get recordServicesOffBody =>
      'Turn on your device\'s location services to record a walk or run.';

  @override
  String get recordAcquiring => 'Finding GPS signal…';

  @override
  String get recordGpsWeak => 'Weak GPS — move to open sky';

  @override
  String get recordGpsReady => 'GPS ready';

  @override
  String get recordStatDistance => 'Distance';

  @override
  String get recordStatTime => 'Time';

  @override
  String get recordStatPace => 'Pace';

  @override
  String get recordPaceUnitKm => '/km';

  @override
  String get recordPaceUnitMi => '/mi';

  @override
  String get recordStart => 'Start';

  @override
  String get recordPause => 'Pause';

  @override
  String get recordResume => 'Resume';

  @override
  String get recordFinish => 'Finish';

  @override
  String get recordDiscardTitle => 'Discard recording?';

  @override
  String get recordDiscardBody => 'Your recorded walk or run won\'t be saved.';

  @override
  String get recordDiscard => 'Discard';

  @override
  String get recordKeepRecording => 'Keep recording';

  @override
  String get recordTooShort => 'Too short to save yet — keep moving.';

  @override
  String get recordNotifTitle => 'Recording your activity';

  @override
  String get recordNotifText =>
      'Tracking distance, time and pace — tap to return.';

  @override
  String get recordKeepsRecordingHint => 'Keeps recording with the screen off.';
}
