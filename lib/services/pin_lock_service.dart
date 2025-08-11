import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

typedef BoxOpener =
    Future<Box> Function(String boxName, {HiveAesCipher? encryptionCipher});

class PinLockService {
  static const String _settingsBox = 'settingsBox';
  static const String _pinEnabledKey = 'pinEnabled';
  static const String _pinKey = 'pin';
  static const String _pinLockTimerKey = 'pinLockTimerMinutes';
  static const String _encryptionKeyName = 'settingsBoxEncryptionKey';

  final FlutterSecureStorage secureStorage;
  final BoxOpener boxOpener;

  PinLockService({FlutterSecureStorage? secureStorage, BoxOpener? boxOpener})
    : secureStorage = secureStorage ?? const FlutterSecureStorage(),
      boxOpener = boxOpener ?? _defaultBoxOpener;

  static Future<Box> _defaultBoxOpener(
    String boxName, {
    HiveAesCipher? encryptionCipher,
  }) {
    return Hive.openBox(boxName, encryptionCipher: encryptionCipher);
  }

  Future<List<int>> _getEncryptionKey() async {
    String? encodedKey = await secureStorage.read(key: _encryptionKeyName);
    if (encodedKey == null) {
      final key = Hive.generateSecureKey();
      encodedKey = base64UrlEncode(key);
      try {
        await secureStorage.write(key: _encryptionKeyName, value: encodedKey);
      } catch (e) {
        // Handle duplicate key error gracefully
        if (e is PlatformException &&
            e.code == 'Unexpected security result code' &&
            e.message?.contains('already exists') == true) {
          // Key already exists, read it again
          encodedKey = await secureStorage.read(key: _encryptionKeyName);
        } else {
          rethrow;
        }
      }
      return base64Url.decode(encodedKey!);
    }
    return base64Url.decode(encodedKey);
  }

  Future<Box> _openEncryptedBox() async {
    final key = await _getEncryptionKey();
    return await boxOpener(_settingsBox, encryptionCipher: HiveAesCipher(key));
  }

  Future<bool> isPinEnabled() async {
    final box = await _openEncryptedBox();
    final pinEnabled = box.get(_pinEnabledKey, defaultValue: false);
    final pin = box.get(_pinKey);
    return pinEnabled && pin != null && pin.toString().isNotEmpty;
  }

  Future<int> getPinLockTimerMinutes() async {
    final box = await _openEncryptedBox();
    return box.get(_pinLockTimerKey, defaultValue: 0);
  }

  Future<void> setPinLockTimerMinutes(int minutes) async {
    final box = await _openEncryptedBox();
    await box.put(_pinLockTimerKey, minutes);
  }

  Future<String?> getPin() async {
    final box = await _openEncryptedBox();
    return box.get(_pinKey);
  }

  Future<void> setPin(String pin) async {
    final box = await _openEncryptedBox();
    await box.put(_pinEnabledKey, true);
    await box.put(_pinKey, pin);
  }

  Future<void> disablePin() async {
    final box = await _openEncryptedBox();
    await box.put(_pinEnabledKey, false);
    await box.delete(_pinKey);
  }

  Future<bool> validatePin(String input) async {
    final pin = await getPin();
    return input == pin;
  }
}
