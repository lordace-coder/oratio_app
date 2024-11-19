class AppDataProvider {
  ///base class to store all constants and configuraton for the app
  bool debugMode = false;

  String get baseUrl =>
      debugMode ? 'http://10.0.2.2:8090' : 'https://bookmass.pockethost.io';

  // payment details
  String secretKey = 'sk_test_e2aba0ded96b172f2e52001ae5a1e8fac58f40ca';

  String publicKey = 'pk_test_1e58496e55250d0e8d81fd3e0f31c8581391d5ec';
}
