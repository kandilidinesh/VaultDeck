import 'package:flutter_test/flutter_test.dart';

import 'package:vaultdeck/services/pin_lock_service.dart';
import 'mock_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Box box;
  late PinLockService pinLockService;

  setUpAll(() async {
    Hive.init('.dart_tool/test_hive');
    box = await Hive.openBox('settingsBox');
    pinLockService = PinLockService(
      secureStorage: MockFlutterSecureStorage(),
      boxOpener: (String boxName, {HiveAesCipher? encryptionCipher}) async =>
          box,
    );
  });

  tearDown(() async {
    await box.clear();
  });

  test('set, get, and validate PIN', () async {
    await pinLockService.setPin('1234');
    final pin = await pinLockService.getPin();
    expect(pin, '1234');
    expect(await pinLockService.isPinEnabled(), isTrue);
    expect(await pinLockService.validatePin('1234'), isTrue);
    expect(await pinLockService.validatePin('0000'), isFalse);
  });

  test('disable PIN', () async {
    await pinLockService.setPin('5678');
    await pinLockService.disablePin();
    expect(await pinLockService.isPinEnabled(), isFalse);
    expect(await pinLockService.getPin(), isNull);
  });

  test('set and get PIN lock timer', () async {
    await pinLockService.setPinLockTimerMinutes(5);
    final timer = await pinLockService.getPinLockTimerMinutes();
    expect(timer, 5);
  });
}
