import '../widgets/card_list_view.dart';
import '../widgets/empty_vault_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../models/card_model.dart';
import '../services/card_storage.dart';
import '../widgets/vaultdeck_app_bar.dart';
import '../widgets/card_detail_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/add_card_dialog.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? toggleTheme;
  final String title;
  final ValueNotifier<bool> isDarkModeNotifier;
  final bool pinEnabled;
  final ValueNotifier<bool> pinEnabledNotifier;
  final String? pin;
  final void Function(bool, [String?]) setPinEnabled;

  const HomePage({
    super.key,
    required this.title,
    required this.isDarkModeNotifier,
    this.toggleTheme,
    required this.pinEnabled,
    required this.pinEnabledNotifier,
    required this.pin,
    required this.setPinEnabled,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Box<CardModel> cardBox;

  @override
  void initState() {
    super.initState();
    cardBox = CardStorage.getBox();
  }

  void _showAddCardDialog() {
    AddCardDialog.show(context, () {
      setState(() {});
    });
  }

  String _detectCardType(String number) {
    if (number.startsWith('4')) return 'Visa';
    if (number.startsWith('5')) return 'Mastercard';
    if (number.startsWith('3')) return 'American Express';
    if (number.startsWith('6')) return 'Discover';
    return 'Other';
  }

  void _deleteCard(int key) async {
    await CardStorage.deleteCard(key);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cards = cardBox.keys
        .map((key) {
          final card = cardBox.get(key);
          return {'key': key, 'card': card};
        })
        .where((e) => e['card'] != null)
        .toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFFAFAFA),
      appBar: VaultDeckAppBar(
        isDarkModeNotifier: widget.isDarkModeNotifier,
        toggleTheme: widget.toggleTheme,
        pinEnabled: widget.pinEnabled,
        pin: widget.pin,
        setPinEnabled: widget.setPinEnabled,
        pinEnabledNotifier: widget.pinEnabledNotifier,
      ),
      body: cards.isEmpty
          ? EmptyVaultView(isDark: isDark)
          : _buildCardListView(cards, isDark),
      floatingActionButton: _buildFloatingActionButton(isDark),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildCardListView(List<Map<String, dynamic>> cards, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + kToolbarHeight,
      ),
      child: Column(
        children: [
          // Add proper spacing from app bar
          const SizedBox(height: 8),
          // Cards list
          Expanded(
            child: CardListView(
              cards: cards,
              onDeleteCard: _deleteCard,
              onCardChanged: () => setState(() {}),
              buildCardTile: _buildCardTile,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalHeaderSection(int cardCount, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.credit_card_rounded,
            color: isDark ? Colors.white70 : Colors.grey[700],
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            '$cardCount card${cardCount == 1 ? '' : 's'} in vault',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey[700],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              cardCount.toString(),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: _showAddCardDialog,
        tooltip: 'Add Card to Vault',
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildCardTile(CardModel card) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final detectedType = _detectCardType(card.cardNumber);

    String getCardLogoAsset(String type) {
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

    // Mask card number except last 4 digits
    String maskedNumber = card.cardNumber.length >= 4
        ? '•••• •••• •••• ${card.cardNumber.substring(card.cardNumber.length - 4)}'
        : card.cardNumber;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showCardDetail(card, detectedType, getCardLogoAsset),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with logo and actions
                Row(
                  children: [
                    // Card logo
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2D2D2D)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SvgPicture.asset(
                        getCardLogoAsset(detectedType),
                        width: 32,
                        height: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Card info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.nickname?.isNotEmpty == true
                                ? card.nickname!
                                : card.cardHolderName,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (card.bankName?.isNotEmpty == true) ...[
                            const SizedBox(height: 2),
                            Text(
                              card.bankName!,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white60
                                    : Colors.grey[600],
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Copy button
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2D2D2D)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.copy_rounded,
                          color: isDark ? Colors.white70 : Colors.grey[700],
                          size: 20,
                        ),
                        onPressed: () => _copyCardNumber(card, isDark),
                        tooltip: 'Copy card number',
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Card number
                Text(
                  maskedNumber,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 18,
                    fontFeatures: [FontFeature.tabularFigures()],
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                // Expiry date
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      color: isDark ? Colors.white60 : Colors.grey[600],
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Expires ${card.expiryDate}',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.grey[600],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCardDetail(
    CardModel card,
    String detectedType,
    String Function(String) getCardLogoAsset,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 24,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CardDetailView(
                      card: card,
                      cardLogoAsset: getCardLogoAsset(detectedType),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _copyCardNumber(CardModel card, bool isDark) {
    Clipboard.setData(ClipboardData(text: card.cardNumber));
    final snackBar = SnackBar(
      elevation: 8,
      behavior: SnackBarBehavior.floating,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Color(0xFF10B981),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Card number copied to clipboard',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
    );
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
