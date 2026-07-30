import 'dart:convert';

import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:finanzas_app_mobile/presentation/screens/edit_profile_screen.dart';
import 'package:finanzas_app_mobile/presentation/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final imageBytes = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
  );

  for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('muestra foto y acción en tema ${themeMode.name}', (
      tester,
    ) async {
      var edited = false;
      final semanticsHandle = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: Scaffold(
            body: Center(
              child: ProfileAvatar(
                fallbackText: 'U',
                imageBytes: imageBytes,
                size: 96,
                onEdit: () => edited = true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(Icons.photo_camera_rounded), findsOneWidget);
      final editTarget = find.bySemanticsLabel('Cambiar foto de perfil');
      expect(editTarget, findsOneWidget);
      expect(tester.getSize(editTarget).width, greaterThanOrEqualTo(48));
      expect(tester.getSize(editTarget).height, greaterThanOrEqualTo(48));

      await tester.tap(find.byIcon(Icons.photo_camera_rounded));
      expect(edited, isTrue);
      semanticsHandle.dispose();
    });
  }

  testWidgets('abre acciones de cámara y galería desde Editar perfil', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'userId': 7,
      'userName': 'Usuario de prueba',
      'userEmail': 'usuario@prueba.com',
      'occupation': 'Profesional',
      'profilePhotoAvailable': false,
    });
    FlutterSecureStorage.setMockInitialValues({});

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const EditProfileScreen(recoverInterruptedSelection: false),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Foto de perfil'), findsOneWidget);
    expect(find.text('Toca la cámara para cambiarla'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.photo_camera_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Tomar una foto'), findsOneWidget);
    expect(find.text('Elegir de la galería'), findsOneWidget);
    expect(find.text('Eliminar foto'), findsNothing);
  });

  testWidgets('muestra eliminación cuando existe una foto guardada', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'userId': 7,
      'userName': 'Usuario de prueba',
      'userEmail': 'usuario@prueba.com',
      'occupation': 'Profesional',
      'profilePhotoAvailable': true,
    });
    FlutterSecureStorage.setMockInitialValues({});

    await tester.pumpWidget(
      MaterialApp(
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const EditProfileScreen(recoverInterruptedSelection: false),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.photo_camera_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Eliminar foto'), findsOneWidget);
  });

  testWidgets('adapta las acciones a pantalla pequeña y texto ampliado', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({
      'userId': 7,
      'userName': 'Usuario',
      'userEmail': 'usuario@prueba.com',
      'occupation': 'Profesional',
      'profilePhotoAvailable': false,
    });
    FlutterSecureStorage.setMockInitialValues({});

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: const EditProfileScreen(recoverInterruptedSelection: false),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.photo_camera_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Tomar una foto'), findsOneWidget);
    expect(find.text('Elegir de la galería'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
