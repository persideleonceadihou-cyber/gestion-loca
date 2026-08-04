class AppLinks {
  static const String netlifyBase = 'https://gestion-locat.netlify.app/';

  static String payer([String? code]) {
    final uri = Uri.parse(netlifyBase).resolve('payer');
    if (code != null && code.isNotEmpty) {
      return uri.replace(queryParameters: {'code': code}).toString();
    }
    return uri.toString();
  }

  static String generalPayer() => Uri.parse(netlifyBase).resolve('payer').toString();
}
