import 'package:flutter/material.dart';
import 'app_strings.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ?? AppLocalizations(const Locale('en'));
  }

  String translate(String key) {
    return AppStrings.get(key, locale.languageCode);
  }

  // Quick access methods
  String get login => translate('login');
  String get register => translate('register');
  String get email => translate('email');
  String get password => translate('password');
  String get fullName => translate('fullName');
  String get signUp => translate('signUp');
  String get signIn => translate('signIn');
  String get signOut => translate('signOut');
  String get forgotPassword => translate('forgotPassword');
  String get dontHaveAccount => translate('dontHaveAccount');
  String get haveAccount => translate('haveAccount');
  
  String get chats => translate('chats');
  String get users => translate('users');
  String get settings => translate('settings');
  String get home => translate('home');
  String get search => translate('search');
  String get noChats => translate('noChats');
  String get noUsers => translate('noUsers');
  String get online => translate('online');
  String get offline => translate('offline');
  
  String get typeMessage => translate('typeMessage');
  String get send => translate('send');
  
  String get language => translate('language');
  String get theme => translate('theme');
  String get darkMode => translate('darkMode');
  String get lightMode => translate('lightMode');
  String get english => translate('english');
  String get swahili => translate('swahili');
  String get logout => translate('logout');
  String get confirm => translate('confirm');
  String get cancel => translate('cancel');
  
  String get error => translate('error');
  String get success => translate('success');
  String get loading => translate('loading');
  String get welcome => translate('welcome');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'sw'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
