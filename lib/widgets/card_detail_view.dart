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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: card.nickname?.isNotEmpty == true
                    ? Padding(
                        padding: const EdgeInsets.only(
                          left: 24.0,
                          top: 16.0,
                          bottom: 16.0,
                        ),
                        child: Text(
                          card.nickname!,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      )
                    : SizedBox(height: 40),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 24.0, top: 8.0),
                child: Material(
                  color: isDark
                      ? const Color(0xFF23262F)
                      : Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      // TODO: Implement edit dialog or navigation
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Edit Card'),
                          content: Text('Edit functionality coming soon.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Tooltip(
                      message: 'Edit',
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Icon(
                          Icons.edit,
                          size: 22,
                          color: isDark ? Colors.white : Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.92,
            constraints: BoxConstraints(minHeight: 180, maxHeight: 280),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 0),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Removed extra card icon for cleaner look
                    // ...existing code...
                    if (card.bankName?.isNotEmpty == true)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 24,
                          top: 4,
                          right: 24,
                        ),
                        child: Text(
                          card.bankName!,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 24,
                        top: 34,
                        right: 24,
                      ),
                      child: Text(
                        card.cardNumber,
                        style: TextStyle(
                          fontSize: 22,
                          letterSpacing: 2,
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 24,
                        top: 40,
                        right: 24,
                        bottom: 0,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Exp: ${card.expiryDate}',
                            style: TextStyle(
                              fontSize: 17,
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 32),
                          Text(
                            'CVV: ${card.cvv ?? '--'}',
                            style: TextStyle(
                              fontSize: 17,
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 32),
                          Text(
                            'PIN: ${card.pin?.isNotEmpty == true ? card.pin : '--'}',
                            style: TextStyle(
                              fontSize: 17,
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 16,
                  left: 24,
                  child: Text(
                    card.cardHolderName,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(isDark ? 0.08 : 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: SvgPicture.asset(
                      cardLogoAsset,
                      width: 40,
                      height: 24,
                      fit: BoxFit.contain,
                    ),
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
