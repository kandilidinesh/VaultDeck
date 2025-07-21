import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FavoritesPage extends StatelessWidget {
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
    return Container(
      color: isDark ? const Color(0xFF181A20) : Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/card_logos/generic.svg',
              width: 64,
              height: 40,
            ),
            const SizedBox(height: 16),
            Text(
              'Your Cards',
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
