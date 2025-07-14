import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_ch.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('ar'),
    Locale('bn'),
    Locale('ch'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr'),
  ];

  /// No description provided for @profileInfo.
  ///
  /// In en, this message translates to:
  /// **'Profile Info'**
  String get profileInfo;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @downloadOverWiFi.
  ///
  /// In en, this message translates to:
  /// **'Download Over WiFi Only'**
  String get downloadOverWiFi;

  /// No description provided for @storageLocation.
  ///
  /// In en, this message translates to:
  /// **'Storage Location'**
  String get storageLocation;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @wifiEnabled.
  ///
  /// In en, this message translates to:
  /// **'Wi‑Fi downloads enabled'**
  String get wifiEnabled;

  /// No description provided for @wifiDisabled.
  ///
  /// In en, this message translates to:
  /// **'Wi‑Fi downloads disabled'**
  String get wifiDisabled;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Online downloads are available only\nto registered users.'**
  String get signInPrompt;

  /// No description provided for @logInButton.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logInButton;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @downloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloads;

  /// No description provided for @addedTo.
  ///
  /// In en, this message translates to:
  /// **'Added to'**
  String get addedTo;

  /// No description provided for @addTo.
  ///
  /// In en, this message translates to:
  /// **'Add to'**
  String get addTo;

  /// No description provided for @playlistDisabled.
  ///
  /// In en, this message translates to:
  /// **'Add to Playlist (disabled)'**
  String get playlistDisabled;

  /// No description provided for @allLabel.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allLabel;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search songs or artists'**
  String get searchHint;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Offline & online, favorite & fresh.'**
  String get homeSubtitle;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @splashDescription.
  ///
  /// In en, this message translates to:
  /// **'Hey there, Music Lover!\nDive into your tunes, favorite your jams,\nand discover more with TuneCrate.'**
  String get splashDescription;

  /// No description provided for @downloaddescription.
  ///
  /// In en, this message translates to:
  /// **'Online downloads are available only\n to registered users. Log in or\n sign up to continue.!'**
  String get downloaddescription;

  /// No description provided for @playlist.
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get playlist;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @nofavourite.
  ///
  /// In en, this message translates to:
  /// **'No Favourites'**
  String get nofavourite;

  /// No description provided for @favsubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart icon on any song,\nplaylist, or album to add it to your favorites.\nYour saved music will appear\nhere for quick access!'**
  String get favsubtitle;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @searchhere.
  ///
  /// In en, this message translates to:
  /// **'Search here'**
  String get searchhere;

  /// No description provided for @alphabet.
  ///
  /// In en, this message translates to:
  /// **'ABCDEFGHIJKLMNOPQRSTUVWXYZ'**
  String get alphabet;

  /// No description provided for @tunecrate.
  ///
  /// In en, this message translates to:
  /// **'TuneCrate'**
  String get tunecrate;

  /// No description provided for @subtitle.
  ///
  /// In en, this message translates to:
  /// **'our music universe — offline & \nonline, favorite & fresh.'**
  String get subtitle;

  /// No description provided for @recentplayer.
  ///
  /// In en, this message translates to:
  /// **'Recently Played'**
  String get recentplayer;

  /// No description provided for @mostplayed.
  ///
  /// In en, this message translates to:
  /// **'Most Played'**
  String get mostplayed;

  /// No description provided for @createplaylist.
  ///
  /// In en, this message translates to:
  /// **'Create Your Playlist'**
  String get createplaylist;

  /// No description provided for @enterplaylistname.
  ///
  /// In en, this message translates to:
  /// **'Enter playlist name'**
  String get enterplaylistname;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @accountsetting.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountsetting;

  /// No description provided for @langauge.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get langauge;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @trendingNow.
  ///
  /// In en, this message translates to:
  /// **'Trending Now'**
  String get trendingNow;

  /// No description provided for @mostStreamed.
  ///
  /// In en, this message translates to:
  /// **'Most Streamed'**
  String get mostStreamed;

  /// No description provided for @newReleases.
  ///
  /// In en, this message translates to:
  /// **'New Releases'**
  String get newReleases;

  /// No description provided for @popularsong.
  ///
  /// In en, this message translates to:
  /// **'Popular Songs'**
  String get popularsong;

  /// No description provided for @romanticsong.
  ///
  /// In en, this message translates to:
  /// **'Romantic Songs'**
  String get romanticsong;

  /// No description provided for @indiansong.
  ///
  /// In en, this message translates to:
  /// **'Indian Songs'**
  String get indiansong;

  /// No description provided for @sadsong.
  ///
  /// In en, this message translates to:
  /// **'Sad Songs'**
  String get sadsong;

  /// No description provided for @oldsong.
  ///
  /// In en, this message translates to:
  /// **'Old Songs'**
  String get oldsong;

  /// No description provided for @a.
  ///
  /// In en, this message translates to:
  /// **'A'**
  String get a;

  /// No description provided for @b.
  ///
  /// In en, this message translates to:
  /// **'B'**
  String get b;

  /// No description provided for @c.
  ///
  /// In en, this message translates to:
  /// **'C'**
  String get c;

  /// No description provided for @d.
  ///
  /// In en, this message translates to:
  /// **'D'**
  String get d;

  /// No description provided for @e.
  ///
  /// In en, this message translates to:
  /// **'E'**
  String get e;

  /// No description provided for @f.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get f;

  /// No description provided for @g.
  ///
  /// In en, this message translates to:
  /// **'G'**
  String get g;

  /// No description provided for @h.
  ///
  /// In en, this message translates to:
  /// **'H'**
  String get h;

  /// No description provided for @i.
  ///
  /// In en, this message translates to:
  /// **'I'**
  String get i;

  /// No description provided for @j.
  ///
  /// In en, this message translates to:
  /// **'J'**
  String get j;

  /// No description provided for @k.
  ///
  /// In en, this message translates to:
  /// **'K'**
  String get k;

  /// No description provided for @l.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get l;

  /// No description provided for @m.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get m;

  /// No description provided for @n.
  ///
  /// In en, this message translates to:
  /// **'N'**
  String get n;

  /// No description provided for @o.
  ///
  /// In en, this message translates to:
  /// **'O'**
  String get o;

  /// No description provided for @p.
  ///
  /// In en, this message translates to:
  /// **'P'**
  String get p;

  /// No description provided for @q.
  ///
  /// In en, this message translates to:
  /// **'Q'**
  String get q;

  /// No description provided for @r.
  ///
  /// In en, this message translates to:
  /// **'R'**
  String get r;

  /// No description provided for @s.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get s;

  /// No description provided for @t.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get t;

  /// No description provided for @u.
  ///
  /// In en, this message translates to:
  /// **'U'**
  String get u;

  /// No description provided for @v.
  ///
  /// In en, this message translates to:
  /// **'V'**
  String get v;

  /// No description provided for @w.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get w;

  /// No description provided for @x.
  ///
  /// In en, this message translates to:
  /// **'X'**
  String get x;

  /// No description provided for @y.
  ///
  /// In en, this message translates to:
  /// **'Y'**
  String get y;

  /// No description provided for @z.
  ///
  /// In en, this message translates to:
  /// **'Z'**
  String get z;
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
    'ar',
    'bn',
    'ch',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'id',
    'ja',
    'ko',
    'pt',
    'ru',
    'tr',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'ch':
      return AppLocalizationsCh();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
