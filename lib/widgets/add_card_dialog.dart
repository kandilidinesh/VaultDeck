import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/card_model.dart';
import '../services/card_storage.dart';
import '../services/cloud_sync_service.dart';
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
  final CloudSyncService _cloudSyncService = CloudSyncService();

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

      try {
        if (widget.cardKey != null) {
          // Update existing card
          await CardStorage.getBox().put(widget.cardKey, newCard);
        } else {
          // Add new card
          await CardStorage.addCard(newCard);
        }

        // Trigger automatic cloud sync after card change
        _cloudSyncService.performCardChangeSync();

        if (!mounted) return;
        widget.onCardAdded();
        Navigator.of(context).pop();
      } catch (e) {
        // Handle error if needed
        if (!mounted) return;
        widget.onCardAdded();
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight - keyboardHeight - 100;

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxHeight: availableHeight),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 32,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Modern header with proper dark mode design
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF2D2D2D)
                        : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.2)
                              : Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Title and buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Title and subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.initialCard != null
                                    ? 'Edit Card'
                                    : 'Add New Card',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Secure your card information',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.6)
                                      : Colors.grey[600],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Action buttons
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                backgroundColor: isDark
                                    ? const Color(0xFF2D2D2D)
                                    : const Color(0xFFF1F5F9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _addCard,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: Text(
                                widget.initialCard != null ? 'Update' : 'Save',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Form content
              Expanded(
                child: ListView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Form fields
                    _buildFormSection('Basic Information', [
                      _buildTextField(
                        controller: _nicknameController,
                        label: 'Card Nickname',
                        hint: 'Card Nickname',
                        icon: Icons.label_rounded,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _bankNameController,
                        label: 'Bank Name',
                        hint: 'Bank Name',
                        icon: Icons.account_balance_rounded,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _holderController,
                        label: 'Card Holder Name',
                        hint: 'Card Holder Name',
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return 'Please enter name';
                          }
                          return null;
                        },
                        icon: Icons.person_rounded,
                        isDark: isDark,
                      ),
                    ]),

                    const SizedBox(height: 32),

                    _buildFormSection('Card Details', [
                      _buildTextField(
                        controller: _numberController,
                        label: 'Card Number',
                        hint: 'Card Number',
                        icon: CupertinoIcons.creditcard,
                        isDark: isDark,
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
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: SvgPicture.asset(
                            _getCardLogoAsset(_liveCardType),
                            width: 32,
                            height: 20,
                          ),
                        ),
                        validator: (value) {
                          final cardNumberPattern = RegExp(
                            r'^(\d{4}-){3}\d{4}$',
                          );
                          if (value?.trim().isEmpty ?? true) {
                            return 'Please enter card number';
                          }
                          if (!cardNumberPattern.hasMatch(value!.trim())) {
                            return 'Enter as 1234-5678-9012-3456';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _expiryController,
                              label: 'Expiry Date',
                              hint: 'Expiry Date',
                              icon: CupertinoIcons.calendar,
                              isDark: isDark,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9/]'),
                                ),
                                LengthLimitingTextInputFormatter(5),
                                ExpiryDateInputFormatter(),
                              ],
                              validator: (value) {
                                final regex = RegExp(
                                  r'^(0[1-9]|1[0-2])/\d{2}$',
                                );
                                if (value?.trim().isEmpty ?? true) {
                                  return 'Please enter expiry date';
                                }
                                if (!regex.hasMatch(value!.trim())) {
                                  return 'Please use MM/YY format';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildTextField(
                              controller: _cvvController,
                              label: 'CVV',
                              hint: 'CVV',
                              icon: Icons.lock_outline_rounded,
                              isDark: isDark,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                              ],
                              validator: (value) {
                                if (value?.trim().isEmpty ?? true) {
                                  return 'Please enter CVV';
                                }
                                if (!(value!.length == 3 ||
                                    value.length == 4)) {
                                  return 'CVV must be 3 or 4 digits';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _pinController,
                        label: 'PIN',
                        hint: 'PIN',
                        icon: Icons.password_rounded,
                        isDark: isDark,
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
                    ]),

                    const SizedBox(height: 32),

                    _buildFormSection('Additional Information', [
                      _buildTextField(
                        controller: _notesController,
                        label: 'Notes',
                        hint: 'Notes',
                        icon: Icons.note_alt_rounded,
                        isDark: isDark,
                        maxLines: 3,
                      ),
                    ]),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(
              0xFF10B981,
            ), // Subtle green instead of bright blue
          ),
        ),
        const SizedBox(height: 20),
        ...children,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Function(String)? onChanged,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Container(
          margin: const EdgeInsets.only(left: 16, right: 8),
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDark ? Colors.white70 : Colors.grey[600],
            size: 20,
          ),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF3D3D3D) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF3D3D3D) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        contentPadding: const EdgeInsets.fromLTRB(16, 20, 20, 20),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        labelStyle: TextStyle(
          color: isDark ? Colors.white60 : Colors.grey[600],
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: isDark
              ? Colors.white.withValues(alpha: 0.4)
              : Colors.grey[400],
          fontSize: 14,
        ),
      ),
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      validator: validator,
    );
  }
}
