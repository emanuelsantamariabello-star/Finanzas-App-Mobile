class ApiConstants {
  // Emulator (Android) local host
  static const String baseUrlEmulator = 'http://10.0.2.2/finanzas_app/api';

  // Physical device on local network
  static const String baseUrlDevice = 'http://192.168.20.29/finanzas_app/api';

  // TODO: switch this when you move between emulator and device
  static const String baseUrl = baseUrlEmulator;
}
