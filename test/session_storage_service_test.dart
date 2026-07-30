import 'package:finanzas_app_mobile/core/constants/session_keys.dart';
import 'package:finanzas_app_mobile/data/services/session_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('guarda y restaura una sesión válida', () async {
    final service = SessionStorageService();

    await service.saveAuthenticatedUser(
      userId: 7,
      userName: 'Usuario de prueba',
      userEmail: 'usuario@prueba.com',
      occupation: 'Desarrollador',
    );

    final prefs = await SharedPreferences.getInstance();

    expect(await service.hasActiveSession(), isTrue);
    expect(prefs.getBool(SessionKeys.isLoggedIn), isTrue);
    expect(prefs.getInt(SessionKeys.userId), 7);
    expect(prefs.getString(SessionKeys.userName), 'Usuario de prueba');
    expect(prefs.getString(SessionKeys.userEmail), 'usuario@prueba.com');
    expect(prefs.getString(SessionKeys.occupation), 'Desarrollador');
    expect(prefs.getString(SessionKeys.userOccupation), 'Desarrollador');
    expect(prefs.getString('password'), isNull);
  });

  test('mantiene la ocupación actualizada en las claves compatibles', () async {
    SharedPreferences.setMockInitialValues({
      SessionKeys.userName: 'Usuario anterior',
      SessionKeys.userEmail: 'anterior@prueba.com',
      SessionKeys.occupation: 'Ocupación anterior',
      SessionKeys.userOccupation: 'Ocupación anterior',
    });
    final service = SessionStorageService();

    await service.updateProfile(
      userName: 'Usuario actualizado',
      userEmail: 'actualizado@prueba.com',
      occupation: 'Ingeniero de software',
    );

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(SessionKeys.userName), 'Usuario actualizado');
    expect(prefs.getString(SessionKeys.userEmail), 'actualizado@prueba.com');
    expect(prefs.getString(SessionKeys.occupation), 'Ingeniero de software');
    expect(
      prefs.getString(SessionKeys.userOccupation),
      'Ingeniero de software',
    );
  });

  test('limpia solo los datos de sesión', () async {
    SharedPreferences.setMockInitialValues({
      SessionKeys.isLoggedIn: true,
      SessionKeys.userId: 7,
      SessionKeys.userName: 'Usuario de prueba',
      SessionKeys.userEmail: 'usuario@prueba.com',
      SessionKeys.rememberCredentials: true,
      SessionKeys.rememberedEmail: 'usuario@prueba.com',
      'themeMode': 'light',
      'show_home_insights': false,
      'show_home_saving_recommendations': false,
    });
    final service = SessionStorageService();

    await service.clearSession();

    final prefs = await SharedPreferences.getInstance();
    for (final key in SessionKeys.sessionKeys) {
      expect(prefs.containsKey(key), isFalse);
    }
    expect(prefs.getBool(SessionKeys.rememberCredentials), isTrue);
    expect(prefs.getString(SessionKeys.rememberedEmail), 'usuario@prueba.com');
    expect(prefs.getString('themeMode'), 'light');
    expect(prefs.getBool('show_home_insights'), isFalse);
    expect(prefs.getBool('show_home_saving_recommendations'), isFalse);
  });

  test('descarta una sesión incompleta', () async {
    SharedPreferences.setMockInitialValues({
      SessionKeys.isLoggedIn: true,
      SessionKeys.userName: 'Sesión incompleta',
    });
    final service = SessionStorageService();

    expect(await service.hasActiveSession(), isFalse);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(SessionKeys.isLoggedIn), isNull);
    expect(prefs.getString(SessionKeys.userName), isNull);
  });

  test('reemplaza los datos personales de una sesión anterior', () async {
    SharedPreferences.setMockInitialValues({
      SessionKeys.isLoggedIn: true,
      SessionKeys.userId: 1,
      SessionKeys.userName: 'Usuario anterior',
      SessionKeys.userEmail: 'anterior@prueba.com',
      SessionKeys.occupation: 'Ocupación anterior',
    });
    final service = SessionStorageService();

    await service.saveAuthenticatedUser(
      userId: 2,
      userName: 'Usuario nuevo',
      userEmail: 'nuevo@prueba.com',
    );

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt(SessionKeys.userId), 2);
    expect(prefs.getString(SessionKeys.userName), 'Usuario nuevo');
    expect(prefs.getString(SessionKeys.userEmail), 'nuevo@prueba.com');
    expect(prefs.getString(SessionKeys.occupation), isNull);
  });

  test(
    'conserva la ocupación si el mismo usuario recibe una sesión parcial',
    () async {
      SharedPreferences.setMockInitialValues({
        SessionKeys.isLoggedIn: true,
        SessionKeys.userId: 7,
        SessionKeys.userName: 'Usuario',
        SessionKeys.userEmail: 'usuario@prueba.com',
        SessionKeys.occupation: 'Contador',
        SessionKeys.userOccupation: 'Contador',
      });
      final service = SessionStorageService();

      await service.saveAuthenticatedUser(
        userId: 7,
        userName: 'Usuario',
        userEmail: 'usuario@prueba.com',
      );

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(SessionKeys.occupation), 'Contador');
      expect(prefs.getString(SessionKeys.userOccupation), 'Contador');
    },
  );
}
