import 'package:hive/hive.dart';

part 'card_model.g.dart';

@HiveType(typeId: 0)
class CardModel extends HiveObject {
  @HiveField(6)
  String? nickname;

  @HiveField(7)
  String? bankName;

  @HiveField(8)
  String? notes;
  @HiveField(0)
  String cardHolderName;

  @HiveField(1)
  String cardNumber;

  @HiveField(2)
  String expiryDate;

  @HiveField(3)
  String cardType; // e.g., 'Credit', 'Debit'

  @HiveField(4)
  String? cvv;

  @HiveField(5)
  String? pin;

  CardModel({
    required this.cardHolderName,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardType,
    this.cvv,
    this.pin,
    this.nickname,
    this.bankName,
    this.notes,
  });
}
