import 'package:flutter/material.dart';

class CardUtils {
  // Card type detection
  static String detectCardType(String number) {
    if (number.startsWith('4')) return 'Visa';
    if (number.startsWith('5')) return 'Mastercard';
    if (number.startsWith('3')) return 'American Express';
    if (number.startsWith('6')) return 'Discover';
    return 'Other';
  }

  // Card type to icon mapping
  static IconData getCardIcon(String cardType) {
    const cardIcons = {
      'Visa': Icons.credit_card,
      'Mastercard': Icons.credit_card,
      'American Express': Icons.credit_card,
      'Discover': Icons.credit_card,
      'Other': Icons.credit_card,
    };
    return cardIcons[cardType] ?? Icons.credit_card;
  }

  // Card type to color mapping
  static Color getCardColor(String cardType) {
    final cardColors = {
      'Visa': Colors.blue.shade700,
      'Mastercard': Colors.orange.shade700,
      'American Express': Colors.green.shade700,
      'Discover': Colors.purple.shade700,
      'Other': Colors.grey.shade700,
    };
    return cardColors[cardType] ?? Colors.grey.shade700;
  }

  // Format card number for display
  static String formatCardNumber(String cardNumber) {
    if (cardNumber.length >= 4) {
      return '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';
    }
    return cardNumber;
  }

  // Validate card number (basic length check)
  static bool isValidCardNumber(String number) {
    return number.trim().length >= 13 && number.trim().length <= 19;
  }

  // Validate expiry date format
  static bool isValidExpiryDate(String expiry) {
    final regex = RegExp(r'^\d{2}\/\d{2}$');
    return regex.hasMatch(expiry.trim());
  }
}
