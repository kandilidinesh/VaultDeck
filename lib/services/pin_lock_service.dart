import 'package:hive/hive.dart';

class PinLockService {
  static const String _settingsBox = 'settingsBox';
  static const String _pinEnabledKey = 'pinEnabled';
  static const String _pinKey = 'pin';
  static const String _pinLockTimerKey = 'pinLockTimerMinutes';

  Future<bool> isPinEnabled() async {
    final box = await Hive.openBox(_settingsBox);
    final pinEnabled = box.get(_pinEnabledKey, defaultValue: false);
    final pin = box.get(_pinKey);
    return pinEnabled && pin != null && pin.toString().isNotEmpty;
  }

  Future<int> getPinLockTimerMinutes() async {
    final box = await Hive.openBox(_settingsBox);
    return box.get(_pinLockTimerKey, defaultValue: 0);
  }

  Future<void> setPinLockTimerMinutes(int minutes) async {
    final box = await Hive.openBox(_settingsBox);
    await box.put(_pinLockTimerKey, minutes);
  }

  Future<String?> getPin() async {
    final box = await Hive.openBox(_settingsBox);
    return box.get(_pinKey);
  }

  Future<void> setPin(String pin) async {
    final box = await Hive.openBox(_settingsBox);
    await box.put(_pinEnabledKey, true);
    await box.put(_pinKey, pin);
  }

  Future<void> disablePin() async {
    final box = await Hive.openBox(_settingsBox);
    await box.put(_pinEnabledKey, false);
    await box.delete(_pinKey);
  }

  Future<bool> validatePin(String input) async {
    final pin = await getPin();
    return input == pin;
  }
}
