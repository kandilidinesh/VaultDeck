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
  final String title;
  final VoidCallback? toggleTheme;
  final bool? isDarkMode;
  final bool pinEnabled;
  final String? pin;
  final void Function(bool, [String?]) setPinEnabled;

  const HomePage({
    super.key,
    required this.title,
    this.toggleTheme,
    this.isDarkMode,
    required this.pinEnabled,
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
      backgroundColor: isDark ? const Color(0xFF181A20) : Colors.transparent,
      appBar: VaultDeckAppBar(
        toggleTheme: widget.toggleTheme,
        isDarkMode: widget.isDarkMode,
        pinEnabled: widget.pinEnabled,
        pin: widget.pin,
        setPinEnabled: widget.setPinEnabled,
      ),
      body: cards.isEmpty
          ? EmptyVaultView(isDark: isDark)
          : Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + kToolbarHeight,
              ),
              child: CardListView(
                cards: cards,
                onDeleteCard: _deleteCard,
                onCardChanged: () => setState(() {}),
                buildCardTile: _buildCardTile,
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCardDialog,
        tooltip: 'Add Card to Vault',
        backgroundColor: isDark
            ? const Color(0xFF3A3F4A)
            : Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add_card_rounded, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? const Color(0xFF23262F) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
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
                child: DraggableScrollableSheet(
                  initialChildSize: 0.45,
                  minChildSize: 0.35,
                  maxChildSize: 0.7,
                  expand: false,
                  builder: (_, controller) => Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF181A20) : Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 24,
                          offset: Offset(0, -8),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      controller: controller,
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
                ),
              );
            },
          );
        },
        child: ListTile(
          leading: SizedBox(
            width: 40,
            height: 28,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: SvgPicture.asset(
                getCardLogoAsset(detectedType),
                width: 36,
                height: 24,
              ),
            ),
          ),
          title: Text(
            card.nickname?.isNotEmpty == true
                ? card.nickname!
                : card.cardHolderName,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (card.bankName?.isNotEmpty == true)
                Text(
                  card.bankName!,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              Text(
                maskedNumber,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontFeatures: [FontFeature.tabularFigures()],
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Exp: ${card.expiryDate}',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.copy,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            tooltip: 'Copy card number',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: card.cardNumber));
              final snackBar = SnackBar(
                elevation: 8,
                behavior: SnackBarBehavior.floating,
                backgroundColor: isDark
                    ? const Color(0xFF23262F)
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                content: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: isDark ? Colors.greenAccent : Colors.green,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Card number copied',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                duration: const Duration(seconds: 1),
              );
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
          ),
        ),
      ),
    );
  }
}
