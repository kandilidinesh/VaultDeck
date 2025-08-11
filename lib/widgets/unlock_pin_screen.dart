import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class UnlockPinScreen extends StatefulWidget {
  final VoidCallback? onCancel;
  const UnlockPinScreen({super.key, this.onCancel});

  @override
  State<UnlockPinScreen> createState() => _UnlockPinScreenState();
}

class _UnlockPinScreenState extends State<UnlockPinScreen> {
  String pin = '';
  String error = '';
  bool isLoading = false;

  void _onKeyTap(String value) {
    setState(() {
      if (pin.length < 4) pin += value;
      error = '';
    });
    if (pin.length == 4) _onSubmit();
  }

  void _onDelete() {
    setState(() {
      if (pin.isNotEmpty) pin = pin.substring(0, pin.length - 1);
      error = '';
    });
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        bool filled = i < pin.length;
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
          padding: const EdgeInsets.symmetric(vertical: 14.0),
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

  Future<void> _onSubmit() async {
    if (pin.length < 4) return;
    setState(() {
      isLoading = true;
    });
    final box = await Hive.openBox('settingsBox');
    final savedPin = box.get('pin');
    if (pin == (savedPin?.toString() ?? '')) {
      if (mounted) Navigator.of(context).pop(true);
    } else {
      setState(() {
        error = 'Incorrect PIN';
        pin = '';
      });
    }
    setState(() {
      isLoading = false;
    });
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
                const Text(
                  'Enter your PIN',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                _buildPinDots(),
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
            const SizedBox(height: 48), // Spacer to keep layout similar
          ],
        ),
      ),
    );
  }
}
