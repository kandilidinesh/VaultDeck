import 'package:hive/hive.dart';

part 'card_model.g.dart';

@HiveType(typeId: 0)
class CardModel extends HiveObject {
  @HiveField(0)
  String cardHolderName;

  @HiveField(1)
  String cardNumber;

  @HiveField(2)
  String expiryDate;

  @HiveField(3)
  String cardType; // e.g., 'Credit', 'Debit'

  CardModel({
    required this.cardHolderName,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardType,
  });
}
