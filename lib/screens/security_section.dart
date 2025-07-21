import 'package:flutter/material.dart';
import 'pin_lock.dart';

class SecuritySection extends StatefulWidget {
  const SecuritySection({Key? key}) : super(key: key);

  @override
  State<SecuritySection> createState() => _SecuritySectionState();
}

class _SecuritySectionState extends State<SecuritySection> {
  bool _biometricEnabled = false;
  bool _pinEnabled = false;
  String? _pin;

  void _toggleBiometric(bool value) {
    setState(() {
      _biometricEnabled = value;
    });
    // TODO: Integrate with device biometrics
  }

  void _togglePin(bool value) async {
    if (value) {
      // Show PIN setup dialog
      await showDialog(
        context: context,
        builder: (ctx) => PinLockDialog(
          isSetup: true,
          onPinSet: (pin) {
            setState(() {
              _pin = pin;
              _pinEnabled = true;
            });
          },
        ),
      );
    } else {
      setState(() {
        _pinEnabled = false;
        _pin = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileBg = isDark ? const Color(0xFF23262F) : Colors.white;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: tileBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.security_rounded),
            title: const Text('Security'),
            titleTextStyle: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Enable Biometric Authentication'),
            value: _biometricEnabled,
            onChanged: _toggleBiometric,
            secondary: const Icon(Icons.fingerprint_rounded),
            tileColor: tileBg,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Enable PIN Lock'),
            value: _pinEnabled,
            onChanged: _togglePin,
            secondary: const Icon(Icons.lock_rounded),
            tileColor: tileBg,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
          if (_pinEnabled)
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 4,
                bottom: 8,
              ),
              child: Text(
                _pin != null ? 'PIN is set.' : 'PIN not set.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}
