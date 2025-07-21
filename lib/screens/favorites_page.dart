import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  // Helper to detect card type from card number
  String _detectCardType(String number) {
    if (number.startsWith('4')) return 'Visa';
    if (number.startsWith('5')) return 'Mastercard';
    if (number.startsWith('3')) return 'American Express';
    if (number.startsWith('6')) return 'Discover';
    return 'Other';
  }

  // Map card type to icon
  IconData _getCardIcon(String type) {
    switch (type) {
      case 'Visa':
        return Icons.credit_card;
      case 'Mastercard':
        return Icons.credit_card;
      case 'American Express':
        return Icons.credit_card;
      case 'Discover':
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }

  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Example card number for demo; replace with actual favorite card data
    final demoCardNumber = '4111111111111111';
    final cardType = _detectCardType(demoCardNumber);
    final cardIcon = _getCardIcon(cardType);
    return Container(
      color: isDark ? const Color(0xFF181A20) : Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(cardIcon, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              cardType,
              style: TextStyle(
                fontSize: 20,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mark cards as favorites to see them here',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
