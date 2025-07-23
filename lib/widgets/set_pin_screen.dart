import 'package:flutter/material.dart';

class SetPinScreen extends StatefulWidget {
  final void Function(String pin)? onPinSet;
  final VoidCallback? onCancel;

  const SetPinScreen({super.key, this.onPinSet, this.onCancel});

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  String pin = '';
  String confirmPin = '';
  bool isConfirming = false;
  String error = '';

  void _onKeyTap(String value) {
    setState(() {
      if (!isConfirming) {
        if (pin.length < 4) pin += value;
        if (pin.length == 4) isConfirming = true;
      } else {
        if (confirmPin.length < 4) confirmPin += value;
        if (confirmPin.length == 4) {
          if (pin == confirmPin) {
            Navigator.of(context).pop(pin); // Return pin to parent
          } else {
            error = 'PINs do not match';
            confirmPin = '';
          }
        }
      }
    });
  }

  void _onDelete() {
    setState(() {
      if (!isConfirming) {
        if (pin.isNotEmpty) pin = pin.substring(0, pin.length - 1);
      } else {
        if (confirmPin.isNotEmpty) {
          confirmPin = confirmPin.substring(0, confirmPin.length - 1);
        }
      }
      error = '';
    });
  }

  Widget _buildPinDots(String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        bool filled = i < value.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: filled ? Colors.white : Colors.transparent,
            border: Border.all(color: Colors.white, width: 2),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildKeypad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'del'],
    ];
    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0), // Increased gap
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) {
              if (key == '') {
                return const SizedBox(width: 64);
              } else if (key == 'del') {
                return IconButton(
                  icon: const Icon(
                    Icons.backspace_outlined,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: _onDelete,
                );
              } else {
                return SizedBox(
                  width: 64,
                  height: 64,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF23262F),
                      shape: const CircleBorder(),
                      elevation: 0,
                    ),
                    onPressed: () => _onKeyTap(key),
                    child: Text(
                      key,
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF181A20) : Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 32),
            Column(
              children: [
                Text(
                  isConfirming ? 'Confirm PIN' : 'Set PIN',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                _buildPinDots(isConfirming ? confirmPin : pin),
                if (error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      error,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],
            ),
            _buildKeypad(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      widget.onCancel?.call();
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  if (isConfirming && confirmPin.length == 4 && error.isEmpty)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF23262F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (pin == confirmPin) {
                          Navigator.of(
                            context,
                          ).pop(pin); // Return pin to parent
                        } else {
                          setState(() {
                            error = 'PINs do not match';
                            confirmPin = '';
                          });
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        child: Text(
                          'Set PIN',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
