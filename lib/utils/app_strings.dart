class AppStrings {
  static const Map<String, Map<String, String>> _translations = {
    'en': {
      // Auth screens
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'fullName': 'Full Name',
      'signUp': 'Sign Up',
      'signIn': 'Sign In',
      'signOut': 'Sign Out',
      'forgotPassword': 'Forgot Password?',
      'dontHaveAccount': "Don't have an account?",
      'haveAccount': 'Already have an account?',
      'passwordReset': 'Reset Password',
      'resetEmail': 'Check your email to reset password',

      // Home screens
      'chats': 'Chats',
      'users': 'Users',
      'settings': 'Settings',
      'home': 'Home',
      'search': 'Search',
      'noChats': 'No chats yet',
      'noUsers': 'No users found',
      'onlineUsers': 'Online Users',
      'offline': 'Offline',
      'online': 'Online',

      // Chat room
      'typeMessage': 'Type a message...',
      'send': 'Send',
      'messageRead': 'Read',
      'messageDelivered': 'Delivered',
      'today': 'Today',
      'yesterday': 'Yesterday',

      // Settings
      'language': 'Language',
      'theme': 'Theme',
      'darkMode': 'Dark Mode',
      'lightMode': 'Light Mode',
      'notification': 'Notifications',
      'privacy': 'Privacy & Security',
      'help': 'Help & Support',
      'about': 'About',
      'version': 'Version',
      'logout': 'Logout',
      'confirm': 'Confirm',
      'cancel': 'Cancel',
      'english': 'English',
      'swahili': 'Swahili',

      // Privacy
      'privacyPolicy': 'Privacy Policy',
      'termsOfService': 'Terms of Service',

      // Help
      'faqTitle': 'Frequently Asked Questions',
      'contactSupport': 'Contact Support',
      'reportBug': 'Report a Bug',

      // Error messages
      'emailRequired': 'Email is required',
      'invalidEmail': 'Please enter a valid email',
      'passwordRequired': 'Password is required',
      'passwordTooShort': 'Password must be at least 6 characters',
      'passwordMismatch': 'Passwords do not match',
      'nameRequired': 'Name is required',
      'error': 'Error',
      'success': 'Success',
      'loading': 'Loading...',
      'retry': 'Retry',

      // Validation
      'welcome': 'Welcome to Chat App',
      'connectingToFirebase': 'Connecting to Firebase...',
      'enterEmail': 'Enter your email',
      'enterPassword': 'Enter your password',
      'enterName': 'Enter your full name',
    },
    'sw': {
      // Auth screens
      'login': 'Ingia',
      'register': 'Jisajili',
      'email': 'Barua Pepe',
      'password': 'Nenosiri',
      'confirmPassword': 'Thibitisha Nenosiri',
      'fullName': 'Jina Kamili',
      'signUp': 'Jisajili',
      'signIn': 'Ingia',
      'signOut': 'Toka',
      'forgotPassword': 'Umesahau Nenosiri?',
      'dontHaveAccount': 'Huna akaunti?',
      'haveAccount': 'Tayari una akaunti?',
      'passwordReset': 'Sezesha Nenosiri',
      'resetEmail': 'Angalia barua pepe yako ili kusezesha nenosiri',

      // Home screens
      'chats': 'Mazungumzo',
      'users': 'Watumiaji',
      'settings': 'Mipangilio',
      'home': 'Nyumbani',
      'search': 'Tafuta',
      'noChats': 'Hakuna mazungumzo bado',
      'noUsers': 'Hakuna watumiaji walioweza kupatikana',
      'onlineUsers': 'Watumiaji Mkondoni',
      'offline': 'Mgogoro',
      'online': 'Mkondoni',

      // Chat room
      'typeMessage': 'Andika ujumbe...',
      'send': 'Tuma',
      'messageRead': 'Kusomwa',
      'messageDelivered': 'Kufika',
      'today': 'Leo',
      'yesterday': 'Jana',

      // Settings
      'language': 'Lugha',
      'theme': 'Mtindo',
      'darkMode': 'Mtindo Giza',
      'lightMode': 'Mtindo Mwanga',
      'notification': 'Arifa',
      'privacy': 'Faragha & Usalama',
      'help': 'Msaada & Usaidizi',
      'about': 'Kuhusu',
      'version': 'Toleo',
      'logout': 'Toka',
      'confirm': 'Thibitisha',
      'cancel': 'Ghairi',
      'english': 'Kiingereza',
      'swahili': 'Kiswahili',

      // Privacy
      'privacyPolicy': 'Sera ya Faragha',
      'termsOfService': 'Masharti ya Huduma',

      // Help
      'faqTitle': 'Maswali Yanayoulizwa Mara Kwa Mara',
      'contactSupport': 'Wasiliana na Msaada',
      'reportBug': 'Ripoti Hitilafu',

      // Error messages
      'emailRequired': 'Barua pepe inahitajika',
      'invalidEmail': 'Tafadhali ingiza barua pepe halali',
      'passwordRequired': 'Nenosiri linahitajika',
      'passwordTooShort': 'Nenosiri lazima liwe na angalau herufi 6',
      'passwordMismatch': 'Nensiri hazilingani',
      'nameRequired': 'Jina linahitajika',
      'error': 'Kosa',
      'success': 'Kumefaulu',
      'loading': 'Inapakua...',
      'retry': 'Jaribu Tena',

      // Validation
      'welcome': 'Karibu katika Programu ya Mazungumzo',
      'connectingToFirebase': 'Inaunganisha na Firebase...',
      'enterEmail': 'Ingiza barua pepe yako',
      'enterPassword': 'Ingiza nenosiri lako',
      'enterName': 'Ingiza jina lako kamili',
    },
  };

  /// Get translated string by key
  static String get(String key, String languageCode) {
    return _translations[languageCode]?[key] ?? _translations['en']?[key] ?? key;
  }

  /// Get translated string based on current language
  static String getText(String key) {
    final currentLang = _translations.keys.contains('en') ? 'en' : 'en';
    return _translations[currentLang]?[key] ?? key;
  }
}
