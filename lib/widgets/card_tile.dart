import 'package:flutter/material.dart';
import '../models/card_model.dart';

class CardTile extends StatelessWidget {
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
        leading: Icon(
          _getCardIcon(card.cardType),
          color: Colors.white,
          size: 32,
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

  IconData _getCardIcon(String cardType) {
    const cardIcons = {
      'Visa': Icons.credit_card,
      'Mastercard': Icons.credit_card,
      'American Express': Icons.credit_card,
      'Discover': Icons.credit_card,
      'Other': Icons.credit_card,
    };
    return cardIcons[cardType] ?? Icons.credit_card;
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
