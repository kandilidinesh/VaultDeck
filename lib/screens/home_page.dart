import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/card_model.dart';
import '../services/card_storage.dart';
import '../widgets/vaultdeck_app_bar.dart';
import '../widgets/card_detail_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/add_card_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

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
          return card == null ? null : {'key': key, 'card': card};
        })
        .where((e) => e != null)
        .toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? const Color(0xFF181A20) : Colors.transparent,
      appBar: VaultDeckAppBar(),
      body: cards.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 64,
                    color: isDark
                        ? Colors.grey.shade800
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your vault is empty',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: isDark
                          ? Colors.grey.shade400
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first card to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? Colors.grey.shade500
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.of(context).padding.top + kToolbarHeight + 16,
                16,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              itemCount: cards.length,
              itemBuilder: (context, idx) {
                final key = cards[idx]!['key'] as int;
                final card = cards[idx]!['card'] as CardModel;
                return Dismissible(
                  key: Key(key.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _deleteCard(key),
                  child: _buildCardTile(card),
                );
              },
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100.0),
        child: FloatingActionButton(
          onPressed: _showAddCardDialog,
          tooltip: 'Add Card to Vault',
          child: Icon(Icons.add_card_rounded, color: Colors.white),
          backgroundColor: isDark
              ? const Color(0xFF3A3F4A)
              : Theme.of(context).colorScheme.primary,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildCardTile(CardModel card) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColors = {
      'Visa': isDark
          ? const Color(0xFF2D3140)
          : const Color(0xFFBBDEFB), // Slightly darker blue
      'Mastercard': isDark
          ? const Color(0xFF3A3F4A)
          : const Color(0xFFFFE0B2), // Slightly darker orange
      'American Express': isDark
          ? const Color(0xFF23262F)
          : const Color(0xFFB2EBF2), // Slightly darker teal
      'Discover': isDark
          ? const Color(0xFF181A20)
          : const Color(0xFFD1C4E9), // Slightly darker purple
      'Other': isDark
          ? const Color(0xFF23262F)
          : const Color(0xFFE0E0E0), // Slightly darker gray
    };
    final detectedType = _detectCardType(card.cardNumber);
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

    // Mask card number except last 4 digits
    String maskedNumber = card.cardNumber.length >= 4
        ? '•••• •••• •••• ${card.cardNumber.substring(card.cardNumber.length - 4)}'
        : card.cardNumber;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color:
          cardColors[card.cardType] ??
          (isDark ? const Color(0xFF23262F) : Colors.grey.shade700),
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
                          color: Colors.black.withOpacity(0.15),
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
                              cardLogoAsset: _getCardLogoAsset(detectedType),
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
                _getCardLogoAsset(detectedType),
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
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: isDark ? Colors.white : Colors.black38,
          ),
        ),
      ),
    );
  }
}
