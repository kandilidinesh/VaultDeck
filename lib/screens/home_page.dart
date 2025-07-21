import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/card_model.dart';
import '../services/card_storage.dart';
import '../widgets/vaultdeck_app_bar.dart';

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
    String holder = '';
    String number = '';
    String expiry = '';
    String type = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Card'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Card Holder Name',
                  ),
                  onChanged: (v) => holder = v,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Card Number'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => number = v,
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Expiry Date (MM/YY)',
                  ),
                  onChanged: (v) => expiry = v,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () async {
                type = _detectCardType(number);
                if (holder.isNotEmpty &&
                    number.isNotEmpty &&
                    expiry.isNotEmpty) {
                  await CardStorage.addCard(
                    CardModel(
                      cardHolderName: holder,
                      cardNumber: number,
                      expiryDate: expiry,
                      cardType: type,
                    ),
                  );
                  setState(() {});
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: VaultDeckAppBar(),
      body: cards.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your vault is empty',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first card to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
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
        child: FloatingActionButton.extended(
          onPressed: _showAddCardDialog,
          tooltip: 'Add Card to Vault',
          icon: Icon(
            Icons.add_card_rounded,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.white,
          ),
          label: Text(
            'Add Card',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.indigo.shade700
              : Theme.of(context).colorScheme.primary,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildCardTile(CardModel card) {
    final cardIcons = {
      'Visa': Icons.credit_card,
      'Mastercard': Icons.credit_card,
      'American Express': Icons.credit_card,
      'Discover': Icons.credit_card,
      'Other': Icons.credit_card,
    };
    final cardColors = {
      'Visa': Colors.blue.shade700,
      'Mastercard': Colors.orange.shade700,
      'American Express': Colors.green.shade700,
      'Discover': Colors.purple.shade700,
      'Other': Colors.grey.shade700,
    };
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardColors[card.cardType] ?? Colors.grey.shade700,
      child: ListTile(
        leading: Icon(cardIcons[card.cardType], color: Colors.white, size: 32),
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
              card.cardNumber,
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
      ),
    );
  }
}
