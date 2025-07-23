import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/card_model.dart';
import '../services/card_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './input_formatters.dart';

class AddCardDialog extends StatefulWidget {
  final VoidCallback onCardAdded;
  final CardModel? initialCard;
  final int? cardKey;

  const AddCardDialog({
    super.key,
    required this.onCardAdded,
    this.initialCard,
    this.cardKey,
  });

  @override
  State<AddCardDialog> createState() => _AddCardDialogState();

  // Helper to show as bottom sheet
  static Future<void> show(BuildContext context, VoidCallback onCardAdded) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: AddCardDialog(onCardAdded: onCardAdded),
      ),
    );
  }

  static Future<void> showEdit(
    BuildContext context,
    VoidCallback onCardAdded,
    CardModel card,
  ) {
    final box = CardStorage.getBox();
    final key = box.keyAt(box.values.toList().indexOf(card));
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: AddCardDialog(
          onCardAdded: onCardAdded,
          initialCard: card,
          cardKey: key,
        ),
      ),
    );
  }
}

class _AddCardDialogState extends State<AddCardDialog> {
  String _liveCardType = 'Other';

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

  final _formKey = GlobalKey<FormState>();
  final _holderController = TextEditingController();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _pinController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialCard != null) {
      final card = widget.initialCard!;
      _holderController.text = card.cardHolderName;
      _numberController.text = card.cardNumber;
      _expiryController.text = card.expiryDate;
      _cvvController.text = card.cvv ?? '';
      _pinController.text = card.pin ?? '';
      _nicknameController.text = card.nickname ?? '';
      _bankNameController.text = card.bankName ?? '';
      _notesController.text = card.notes ?? '';
      _liveCardType = card.cardType;
    }
  }

  @override
  void dispose() {
    _holderController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _pinController.dispose();
    _nicknameController.dispose();
    _bankNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _detectCardType(String number) {
    if (number.startsWith('4')) return 'Visa';
    if (number.startsWith('5')) return 'Mastercard';
    if (number.startsWith('3')) return 'American Express';
    if (number.startsWith('6')) return 'Discover';
    if (number.startsWith('60') ||
        number.startsWith('6521') ||
        number.startsWith('6522')) {
      return 'RuPay';
    }
    return 'Other';
  }

  Future<void> _addCard() async {
    if (_formKey.currentState?.validate() ?? false) {
      final cardType = _detectCardType(
        _numberController.text.replaceAll('-', ''),
      );
      final newCard = CardModel(
        cardHolderName: _holderController.text.trim(),
        cardNumber: _numberController.text.trim(),
        expiryDate: _expiryController.text.trim(),
        cardType: cardType,
        cvv: _cvvController.text.trim(),
        pin: _pinController.text.trim(),
        nickname: _nicknameController.text.trim(),
        bankName: _bankNameController.text.trim(),
        notes: _notesController.text.trim(),
      );
      if (widget.cardKey != null) {
        // Update existing card
        await CardStorage.getBox().put(widget.cardKey, newCard);
      } else {
        // Add new card
        await CardStorage.addCard(newCard);
      }
      if (!mounted) return;
      widget.onCardAdded();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 32,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // iOS-style top bar with Back and Done
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Back',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _addCard,
                      child: Text(
                        'Done',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Removed 'Card Details' section header for cleaner look
                TextFormField(
                  controller: _nicknameController,
                  decoration: InputDecoration(
                    labelText: 'Card Nickname',
                    prefixIcon: const Icon(Icons.label),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.fromLTRB(20, 22, 16, 12),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                  validator: (value) {
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _bankNameController,
                  decoration: InputDecoration(
                    labelText: 'Bank Name',
                    prefixIcon: const Icon(Icons.account_balance),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.fromLTRB(20, 22, 16, 12),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                  validator: (value) {
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _holderController,
                  decoration: InputDecoration(
                    labelText: 'Card Holder Name',
                    prefixIcon: const Icon(Icons.person),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.fromLTRB(20, 22, 16, 12),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Please enter name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _numberController,
                  decoration: InputDecoration(
                    labelText: 'Card Number',
                    hintText: 'XXXX-XXXX-XXXX-XXXX',
                    prefixIcon: const Icon(CupertinoIcons.creditcard),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: SvgPicture.asset(
                        _getCardLogoAsset(_liveCardType),
                        width: 32,
                        height: 32,
                      ),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    alignLabelWithHint: true,
                    contentPadding: const EdgeInsets.fromLTRB(20, 22, 16, 12),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
                    LengthLimitingTextInputFormatter(19),
                    CardNumberInputFormatter(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _liveCardType = _detectCardType(
                        value.replaceAll('-', ''),
                      );
                    });
                  },
                  validator: (value) {
                    final cardNumberPattern = RegExp(r'^(\d{4}-){3}\d{4}$');
                    if (value?.trim().isEmpty ?? true) {
                      return 'Please enter card number';
                    }
                    if (!cardNumberPattern.hasMatch(value!.trim())) {
                      return 'Enter as 1234-5678-9012-3456';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _expiryController,
                  decoration: InputDecoration(
                    labelText: 'Expiry Date (MM/YY)',
                    hintText: 'MM/YY',
                    prefixIcon: const Icon(CupertinoIcons.calendar),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.fromLTRB(20, 22, 16, 12),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                    LengthLimitingTextInputFormatter(5),
                    ExpiryDateInputFormatter(),
                  ],
                  validator: (value) {
                    final regex = RegExp(r'^(0[1-9]|1[0-2])/\d{2}$');
                    if (value?.trim().isEmpty ?? true) {
                      return 'Please enter expiry date';
                    }
                    if (!regex.hasMatch(value!.trim())) {
                      return 'Please use MM/YY format';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cvvController,
                        decoration: InputDecoration(
                          labelText: 'CVV',
                          prefixIcon: const Icon(Icons.lock_outline),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.fromLTRB(
                            20,
                            22,
                            16,
                            12,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return 'Please enter CVV';
                          }
                          if (!(value!.length == 3 || value.length == 4)) {
                            return 'CVV must be 3 or 4 digits';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextFormField(
                        controller: _pinController,
                        decoration: InputDecoration(
                          labelText: 'PIN',
                          prefixIcon: const Icon(Icons.password),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.fromLTRB(
                            20,
                            22,
                            16,
                            12,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              value.length < 4) {
                            return 'PIN must be at least 4 digits';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'Notes',
                    prefixIcon: const Icon(Icons.note_alt_outlined),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.fromLTRB(20, 22, 16, 12),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                  maxLines: 2,
                  validator: (value) {
                    return null;
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
