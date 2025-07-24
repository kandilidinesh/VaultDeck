import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class PinLockService {
  static const String _settingsBox = 'settingsBox';
  static const String _pinEnabledKey = 'pinEnabled';
  static const String _pinKey = 'pin';
  static const String _pinLockTimerKey = 'pinLockTimerMinutes';
  static const String _encryptionKeyName = 'settingsBoxEncryptionKey';
  static final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage();

  Future<List<int>> _getEncryptionKey() async {
    String? encodedKey = await _secureStorage.read(key: _encryptionKeyName);
    if (encodedKey == null) {
      final key = Hive.generateSecureKey();
      encodedKey = base64UrlEncode(key);
      await _secureStorage.write(key: _encryptionKeyName, value: encodedKey);
      return key;
    }
    return base64Url.decode(encodedKey);
  }

  Future<Box> _openEncryptedBox() async {
    final key = await _getEncryptionKey();
    return await Hive.openBox(
      _settingsBox,
      encryptionCipher: HiveAesCipher(key),
    );
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
