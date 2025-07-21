import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/card_model.dart';

class CardDetailView extends StatelessWidget {
  final CardModel card;
  final String cardLogoAsset;

  const CardDetailView({
    super.key,
    required this.card,
    required this.cardLogoAsset,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: isDark
                ? [Color(0xFF23262F), Color(0xFF181A20)]
                : [Color(0xFFBBDEFB), Color(0xFFE0E0E0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 24,
              left: 24,
              child: SvgPicture.asset(cardLogoAsset, width: 48, height: 32),
            ),
            Positioned(
              top: 24,
              right: 24,
              child: Icon(
                Icons.credit_card,
                color: isDark ? Colors.white54 : Colors.black26,
                size: 32,
              ),
            ),
            Positioned(
              left: 24,
              bottom: 64,
              child: Text(
                card.cardNumber,
                style: TextStyle(
                  fontSize: 22,
                  letterSpacing: 2,
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              left: 24,
              bottom: 32,
              child: Text(
                card.cardHolderName,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            Positioned(
              right: 24,
              bottom: 32,
              child: Text(
                'Exp: ${card.expiryDate}',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
