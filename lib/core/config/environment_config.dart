import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentConfig {
  // gestión centralizada de credenciales y variables de entorno
  static String get wpApiUrl => dotenv.env['BASE_URL'] ?? 'https://naviux.com/wp-json';
  
  static String get redsysFuc => dotenv.env['REDSYS_FUC'] ?? '';
  static String get redsysTerminal => dotenv.env['REDSYS_TERMINAL'] ?? '1';
  static String get redsysUrl => dotenv.env['REDSYS_URL_ENTORNO'] ?? 'https://sis-t.redsys.es:25443/sis/realizarPago';
  static String get redsysSecretKey => dotenv.env['REDSYS_SECRET_KEY'] ?? '';
  
  static String get googleClientId => dotenv.env['GOOGLE_CLIENT_ID'] ?? ''; 
  static String get googleServerClientId => dotenv.env['GOOGLE_SERVER_CLIENT_ID'] ?? '';
  static String get googleLoginEndpoint => dotenv.env['GOOGLE_LOGIN_ENDPOINT'] ?? '/naviux/v1/google-login';

  static String get captchaSiteKey => dotenv.env['CAPTCHA_SITE_KEY'] ?? '6Lfq0MYsAAAAAEu1jGtn1Thu7dxXwvW-nluoqNye';
  static String get captchaSecretKey => dotenv.env['CAPTCHA_SECRET_KEY'] ?? '6Lfq0MYsAAAAAKq8vJ8vJ8vJ8vJ8vJ8vJ8vJ8vJ';

  static String get removeBgApiKey => dotenv.env['REMOVE_BG_API_KEY'] ?? 'TXF66hyoYhbnb8cfDbp5yagh';
}
