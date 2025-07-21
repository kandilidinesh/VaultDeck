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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (card.nickname?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                card.nickname!,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 24, top: 8),
                      child: SvgPicture.asset(
                        cardLogoAsset,
                        width: 48,
                        height: 32,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 24, top: 8),
                      child: Icon(
                        Icons.credit_card,
                        color: isDark ? Colors.white54 : Colors.black26,
                        size: 32,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24, top: 12, right: 24),
                  child: Text(
                    card.cardHolderName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
                if (card.bankName?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(left: 24, top: 2, right: 24),
                    child: Text(
                      card.bankName!,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 24, top: 12, right: 24),
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
                Padding(
                  padding: const EdgeInsets.only(left: 24, top: 8, right: 24),
                  child: Row(
                    children: [
                      Text(
                        'Exp: ${card.expiryDate}',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Text(
                        'CVV: ${card.cvv ?? '--'}',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Text(
                        'PIN: ${card.pin?.isNotEmpty == true ? card.pin : '--'}',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (card.notes?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
                left: 24,
                right: 24,
                bottom: 8,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: isDark
                        ? [Color(0xFF23262F), Color(0xFF181A20)]
                        : [Color(0xFFBBDEFB), Color(0xFFE0E0E0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.notes,
                      color: isDark ? Colors.white54 : Colors.black38,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        card.notes!,
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
