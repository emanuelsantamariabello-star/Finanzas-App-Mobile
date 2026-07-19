class ApiConstants {
  // Host local para el emulador Android
  static const String baseUrlEmulator = 'http://10.0.2.2/finanzas_app/api';

  // Dispositivo físico en la red local
  static const String baseUrlDevice = 'http://192.168.20.29/finanzas_app/api';

  // Cambia esto cuando alternes entre emulador y dispositivo
  static const String baseUrl = baseUrlEmulator;
}
