import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('ja'),
    Locale('pt'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ja, this message translates to:
  /// **'中学数学 ドリル'**
  String get appTitle;

  /// No description provided for @statsTooltip.
  ///
  /// In ja, this message translates to:
  /// **'成績'**
  String get statsTooltip;

  /// No description provided for @todayReviewCount.
  ///
  /// In ja, this message translates to:
  /// **'今日の復習: {count}問'**
  String todayReviewCount(int count);

  /// No description provided for @beginButton.
  ///
  /// In ja, this message translates to:
  /// **'始める'**
  String get beginButton;

  /// No description provided for @gradeName1.
  ///
  /// In ja, this message translates to:
  /// **'中1'**
  String get gradeName1;

  /// No description provided for @gradeName2.
  ///
  /// In ja, this message translates to:
  /// **'中2'**
  String get gradeName2;

  /// No description provided for @gradeName3.
  ///
  /// In ja, this message translates to:
  /// **'中3'**
  String get gradeName3;

  /// No description provided for @unitTitleFormat.
  ///
  /// In ja, this message translates to:
  /// **'{grade}「{title}」'**
  String unitTitleFormat(String grade, String title);

  /// No description provided for @loadError.
  ///
  /// In ja, this message translates to:
  /// **'問題データの読み込みに失敗しました: {error}'**
  String loadError(String error);

  /// No description provided for @resumeButton.
  ///
  /// In ja, this message translates to:
  /// **'続きから ({current}/{total})'**
  String resumeButton(int current, int total);

  /// No description provided for @restartButton.
  ///
  /// In ja, this message translates to:
  /// **'最初から'**
  String get restartButton;

  /// No description provided for @randomTenButton.
  ///
  /// In ja, this message translates to:
  /// **'ランダム10問'**
  String get randomTenButton;

  /// No description provided for @reviewDueButton.
  ///
  /// In ja, this message translates to:
  /// **'復習する (今日の分 {count}問)'**
  String reviewDueButton(int count);

  /// No description provided for @reviewWaitingLabel.
  ///
  /// In ja, this message translates to:
  /// **'復習待ち {count}問(次の復習まで あと{days}日)'**
  String reviewWaitingLabel(int count, int days);

  /// No description provided for @answerHint.
  ///
  /// In ja, this message translates to:
  /// **'答え'**
  String get answerHint;

  /// No description provided for @submitButton.
  ///
  /// In ja, this message translates to:
  /// **'決定'**
  String get submitButton;

  /// No description provided for @correctLabel.
  ///
  /// In ja, this message translates to:
  /// **'正解！'**
  String get correctLabel;

  /// No description provided for @incorrectLabel.
  ///
  /// In ja, this message translates to:
  /// **'不正解(正解: {answer})'**
  String incorrectLabel(String answer);

  /// No description provided for @nextQuestionButton.
  ///
  /// In ja, this message translates to:
  /// **'次の問題へ'**
  String get nextQuestionButton;

  /// No description provided for @seeResultsButton.
  ///
  /// In ja, this message translates to:
  /// **'結果を見る'**
  String get seeResultsButton;

  /// No description provided for @resultTitle.
  ///
  /// In ja, this message translates to:
  /// **'結果'**
  String get resultTitle;

  /// No description provided for @scoreSummary.
  ///
  /// In ja, this message translates to:
  /// **'{score} / {total} 問正解'**
  String scoreSummary(int score, int total);

  /// No description provided for @accuracySummary.
  ///
  /// In ja, this message translates to:
  /// **'正答率 {percent}%'**
  String accuracySummary(int percent);

  /// No description provided for @backToUnitsButton.
  ///
  /// In ja, this message translates to:
  /// **'単元選択に戻る'**
  String get backToUnitsButton;

  /// No description provided for @overallSection.
  ///
  /// In ja, this message translates to:
  /// **'全体'**
  String get overallSection;

  /// No description provided for @answeredStat.
  ///
  /// In ja, this message translates to:
  /// **'解いた問題'**
  String get answeredStat;

  /// No description provided for @accuracyStat.
  ///
  /// In ja, this message translates to:
  /// **'正答率'**
  String get accuracyStat;

  /// No description provided for @reviewListStat.
  ///
  /// In ja, this message translates to:
  /// **'復習リスト'**
  String get reviewListStat;

  /// No description provided for @weakPointsSection.
  ///
  /// In ja, this message translates to:
  /// **'苦手ポイント'**
  String get weakPointsSection;

  /// No description provided for @noRecords.
  ///
  /// In ja, this message translates to:
  /// **'まだ学習記録がありません。単元を選んで始めましょう！'**
  String get noRecords;

  /// No description provided for @unitAnswerLine.
  ///
  /// In ja, this message translates to:
  /// **'{answered}問解答 / 正解{correct}問'**
  String unitAnswerLine(int answered, int correct);

  /// No description provided for @reviewPendingLine.
  ///
  /// In ja, this message translates to:
  /// **'復習待ち{count}問'**
  String reviewPendingLine(int count);

  /// No description provided for @weakCountLabel.
  ///
  /// In ja, this message translates to:
  /// **'{count}問'**
  String weakCountLabel(int count);

  /// No description provided for @languageTitle.
  ///
  /// In ja, this message translates to:
  /// **'言語'**
  String get languageTitle;

  /// No description provided for @systemDefault.
  ///
  /// In ja, this message translates to:
  /// **'端末の設定に従う'**
  String get systemDefault;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'ja',
    'pt',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ja':
      return AppLocalizationsJa();
    case 'pt':
      return AppLocalizationsPt();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
