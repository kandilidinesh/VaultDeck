import 'package:flutter_test/flutter_test.dart';
import 'package:vaultdeck/services/card_storage.dart';
import 'package:vaultdeck/models/card_model.dart';
import 'package:vaultdeck/constants/app_constants.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  setUpAll(() async {
    await Hive.initFlutter();
    Hive.registerAdapter(CardModelAdapter());
    await Hive.openBox<CardModel>(AppConstants.cardsBoxKey);
  });

  tearDown(() async {
    final box = Hive.box<CardModel>(AppConstants.cardsBoxKey);
    await box.clear();
  });

  test('add, get, and delete card', () async {
    final card = CardModel(
      cardHolderName: 'Test User',
      cardNumber: '1234567890123456',
      expiryDate: '12/34',
      cardType: 'Credit',
    );
    await CardStorage.addCard(card);
    final cards = CardStorage.getAllCards();
    expect(cards.length, 1);
    expect(cards.first.cardHolderName, 'Test User');

    await CardStorage.deleteCard(cards.first.key as int);
    expect(CardStorage.getAllCards().isEmpty, isTrue);
  });
}
