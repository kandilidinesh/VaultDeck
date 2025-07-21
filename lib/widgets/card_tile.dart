import 'package:flutter/material.dart';
import '../models/card_model.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CardTile extends StatelessWidget {
  String _getCardLogoAsset(String type) {
    switch (type) {
      case 'Visa':
        return 'assets/card_logos/visa.svg';
      case 'Mastercard':
        return 'assets/card_logos/mastercard.svg';
      case 'American Express':
        return 'assets/card_logos/amex.svg';
      case 'Discover':
        return 'assets/card_logos/discover.svg';
      case 'RuPay':
        return 'assets/card_logos/rupay.svg';
      default:
        return 'assets/card_logos/generic.svg';
    }
  }

  final CardModel card;
  final VoidCallback? onTap;

  const CardTile({super.key, required this.card, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: _getCardColor(card.cardType),
      child: ListTile(
        leading: SizedBox(
          width: 40,
          height: 28,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: SvgPicture.asset(
              _getCardLogoAsset(card.cardType),
              width: 36,
              height: 24,
            ),
          ),
        ),
        title: Text(
          card.cardHolderName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatCardNumber(card.cardNumber),
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Exp: ${card.expiryDate}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(card.cardType, style: const TextStyle(color: Colors.white70)),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
        onTap: onTap,
      ),
    );
  }

  Color _getCardColor(String cardType) {
    final cardColors = {
      'Visa': Colors.blue.shade700,
      'Mastercard': Colors.orange.shade700,
      'American Express': Colors.green.shade700,
      'Discover': Colors.purple.shade700,
      'Other': Colors.grey.shade700,
    };
    return cardColors[cardType] ?? Colors.grey.shade700;
  }

  String _formatCardNumber(String cardNumber) {
    // Add some basic formatting for display (optional)
    if (cardNumber.length >= 4) {
      return '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';
    }
    return cardNumber;
  }
}
