class AppLinks {
  static const String netlifyBase = 'https://gestion-locat.netlify.app';

  static String payer([String? code]) {
    if (code != null && code.isNotEmpty) {
      return '$netlifyBase/payer?code=$code';
    }
    return '$netlifyBase/payer';
  }

  static String generalPayer() => '$netlifyBase/payer';
}
