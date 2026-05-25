// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
  String get onbNameError => 'Please enter your name.';

  @override
  String get onbDateHeadline => 'When did your\njourney begin?';

  @override
  String get onbDateSub =>
      'If you\'re starting today, leave it as today. You can change this anytime.';

  @override
  String get onbDatePickerHelp => 'When did you get sober?';

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
  String get progressMilestoneLabel3 => 'Three Days';

  @override
  String get progressMilestoneLabel7 => 'One Week';

  @override
  String get progressMilestoneLabel14 => 'Two Weeks';

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
      'Save all your journal entries, gratitude logs, slip records, and profile data. Choose an encrypted backup (.jfwbk) protected by a passphrase, or a plain JSON file.';

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
      'Every piece of information you enter — your sober date, journal entries, gratitude notes, slip records, and profile — is stored locally on your device using the operating system\'s standard app storage. Nothing is transmitted to any external server, cloud service, or third party at any time.';

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
}
