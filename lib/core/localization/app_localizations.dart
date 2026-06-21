import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appName': 'Mani Kanakku',
      'appSubtitle': 'Time Calculator',
      'totalTime': 'Total Time (HH:MM)',
      'amount': 'Amount',
      'saveBill': '💾 Save Bill',
      'billSaved': 'Bill Saved!',
      'history': 'History',
      'clearAll': 'Clear All History',
      'clearAllConfirm': 'Are you sure you want to clear all history?',
      'noBills': 'No bills saved yet',
      'noBillsSubtitle': 'Your saved bills will appear here',
      'delete': 'Delete',
      'share': 'Share',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'rate': 'Rate',
      'ratePerHour': '/hr',
      'setRate': 'Set Hourly Rate',
      'currentRate': 'Current Rate',
      'save': 'Save',
      'enterRate': 'Enter rate',
      'perHour': 'per hour',
      'billDeleted': 'Bill deleted',
      'historyCleared': 'History cleared',
      'language': 'Language',
      'english': 'English',
      'tamil': 'தமிழ்',
      'instant': 'Instant',
      'calculator': 'Calculator',
    },
    'ta': {
      'appName': 'மணி கணக்கு',
      'appSubtitle': 'நேரக் கணிப்பான்',
      'totalTime': 'மொத்த நேரம் (HH:MM)',
      'amount': 'தொகை',
      'saveBill': '💾 சேமி',
      'billSaved': 'பில் சேமிக்கப்பட்டது!',
      'history': 'வரலாறு',
      'clearAll': 'அனைத்து வரலாற்றையும் அழி',
      'clearAllConfirm': 'அனைத்து வரலாற்றையும் அழிக்க விரும்புகிறீர்களா?',
      'noBills': 'எந்த பில்லும் சேமிக்கப்படவில்லை',
      'noBillsSubtitle': 'சேமிக்கப்பட்ட பில்கள் இங்கே தோன்றும்',
      'delete': 'நீக்கு',
      'share': 'பகிர்',
      'cancel': 'ரத்துசெய்',
      'confirm': 'உறுதிப்படுத்து',
      'rate': 'கட்டணம்',
      'ratePerHour': '/மணி',
      'setRate': 'மணி நேர கட்டணம்',
      'currentRate': 'தற்போதைய கட்டணம்',
      'save': 'சேமி',
      'enterRate': 'கட்டணத்தை உள்ளிடவும்',
      'perHour': 'ஒரு மணி நேரத்திற்கு',
      'billDeleted': 'பில் நீக்கப்பட்டது',
      'historyCleared': 'வரலாறு அழிக்கப்பட்டது',
      'language': 'மொழி',
      'english': 'English',
      'tamil': 'தமிழ்',
      'instant': 'உடனடி',
      'calculator': 'கணிப்பான்',
    },
  };

  String get appName => _localizedValues[locale.languageCode]!['appName']!;
  String get appSubtitle =>
      _localizedValues[locale.languageCode]!['appSubtitle']!;
  String get totalTime =>
      _localizedValues[locale.languageCode]!['totalTime']!;
  String get amount => _localizedValues[locale.languageCode]!['amount']!;
  String get saveBill => _localizedValues[locale.languageCode]!['saveBill']!;
  String get billSaved =>
      _localizedValues[locale.languageCode]!['billSaved']!;
  String get history => _localizedValues[locale.languageCode]!['history']!;
  String get clearAll => _localizedValues[locale.languageCode]!['clearAll']!;
  String get clearAllConfirm =>
      _localizedValues[locale.languageCode]!['clearAllConfirm']!;
  String get noBills => _localizedValues[locale.languageCode]!['noBills']!;
  String get noBillsSubtitle =>
      _localizedValues[locale.languageCode]!['noBillsSubtitle']!;
  String get delete => _localizedValues[locale.languageCode]!['delete']!;
  String get share => _localizedValues[locale.languageCode]!['share']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get confirm => _localizedValues[locale.languageCode]!['confirm']!;
  String get rate => _localizedValues[locale.languageCode]!['rate']!;
  String get ratePerHour =>
      _localizedValues[locale.languageCode]!['ratePerHour']!;
  String get setRate => _localizedValues[locale.languageCode]!['setRate']!;
  String get currentRate =>
      _localizedValues[locale.languageCode]!['currentRate']!;
  String get save => _localizedValues[locale.languageCode]!['save']!;
  String get enterRate =>
      _localizedValues[locale.languageCode]!['enterRate']!;
  String get perHour => _localizedValues[locale.languageCode]!['perHour']!;
  String get billDeleted =>
      _localizedValues[locale.languageCode]!['billDeleted']!;
  String get historyCleared =>
      _localizedValues[locale.languageCode]!['historyCleared']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get english => _localizedValues[locale.languageCode]!['english']!;
  String get tamil => _localizedValues[locale.languageCode]!['tamil']!;
  String get instant => _localizedValues[locale.languageCode]!['instant']!;
  String get calculator =>
      _localizedValues[locale.languageCode]!['calculator']!;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ta'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
