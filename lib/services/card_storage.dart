import 'package:hive/hive.dart';
import '../models/card_model.dart';

class CardStorage {
  static Box<CardModel> getBox() => Hive.box<CardModel>('cardsBox');

  static Future<void> addCard(CardModel card) async {
    await getBox().add(card);
  }

  static List<CardModel> getAllCards() {
    return getBox().values.toList();
  }

  static Future<void> deleteCard(int key) async {
    await getBox().delete(key);
  }
}
