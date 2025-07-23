import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:hive/hive.dart';
import '../widgets/set_pin_screen.dart';
import '../services/pin_lock_service.dart';

class SecuritySection extends StatefulWidget {
  final bool pinEnabled;
  final String? pin;
  final void Function(bool, [String?]) onPinToggle;
  final int pinLockTimerMinutes;
  final void Function(int)? onPinLockTimerChanged;
  const SecuritySection({
    super.key,
    required this.pinEnabled,
    required this.pin,
    required this.onPinToggle,
    this.pinLockTimerMinutes = 0,
    this.onPinLockTimerChanged,
  });

  @override
  State<SecuritySection> createState() => _SecuritySectionState();
}

class _SecuritySectionState extends State<SecuritySection> {
  bool _biometricEnabled = false;
  int _selectedTimer = 0;

  final LocalAuthentication _localAuth = LocalAuthentication();
  final bool _isAuthenticating = false;
  String _authStatus = '';

  Future<void> _toggleBiometric(bool value) async {
    final box = await Hive.openBox('settingsBox');
    if (value) {
      bool canCheck = await _localAuth.canCheckBiometrics;
      bool isAvailable = await _localAuth.isDeviceSupported();
      debugPrint(
        '[BIOMETRIC] canCheckBiometrics: $canCheck, isDeviceSupported: $isAvailable',
      );
      if (!canCheck || !isAvailable) {
        debugPrint('[BIOMETRIC] Biometric authentication not available.');
        setState(() {
          _authStatus = 'Biometric authentication not available.';
        });
        return;
      }
      // Only persist and update UI, do not trigger unlock flow here
      await box.put('biometricEnabled', true);
      setState(() {
        _biometricEnabled = true;
        _authStatus = 'Biometric authentication enabled.';
      });
      debugPrint(
        '[BIOMETRIC] Biometric enabled and persisted, will prompt on next app start/resume.',
      );
    } else {
      debugPrint('[BIOMETRIC] Biometric authentication disabled by user.');
      await box.put('biometricEnabled', false);
      setState(() {
        _biometricEnabled = false;
        _authStatus = 'Biometric authentication disabled.';
      });
    }
  }

  void _togglePin(bool value) async {
    if (value) {
      // Optimistically enable PIN lock so switch updates instantly
      widget.onPinToggle(true);
      // Show full-screen PIN setup and await result
      final pin = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (ctx) => SetPinScreen(
            onPinSet: (pin) {
              Navigator.of(ctx).pop(pin); // Return pin to parent
            },
            onCancel: () {
              Navigator.of(ctx).pop(); // Just close
            },
          ),
        ),
      );
      if (pin != null && pin.isNotEmpty) {
        widget.onPinToggle(true, pin);
      } else {
        // User cancelled or didn't set a PIN, revert toggle
        widget.onPinToggle(false);
      }
    } else {
      widget.onPinToggle(false);
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedTimer = widget.pinLockTimerMinutes;
    _loadBiometricEnabled();
  }

  Future<void> _loadBiometricEnabled() async {
    final box = await Hive.openBox('settingsBox');
    final enabled = box.get('biometricEnabled', defaultValue: false);
    setState(() {
      _biometricEnabled = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileBg = isDark ? const Color(0xFF23262F) : Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 0),
          child: Row(
            children: [
              const Icon(Icons.security_rounded, size: 22),
              const SizedBox(width: 8),
              Text(
                'Security',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: tileBg,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                title: const Text('Enable Biometric Authentication'),
                value: _biometricEnabled,
                onChanged: (val) => _toggleBiometric(val),
                secondary: const Icon(Icons.fingerprint_rounded),
                tileColor: tileBg,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              if (_isAuthenticating)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 4,
                    bottom: 8,
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Authenticating...',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              if (_authStatus.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 4,
                    bottom: 8,
                  ),
                  child: Text(
                    _authStatus,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              SwitchListTile(
                title: const Text('Enable PIN Lock'),
                value: widget.pinEnabled,
                onChanged: _togglePin,
                secondary: const Icon(Icons.lock_rounded),
                tileColor: tileBg,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                // Debug log for pinEnabled value
              ),
              if (widget.pinEnabled)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 4,
                    bottom: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.timer_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'PIN Prompt Timer:',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 8),
                          DropdownButton<int>(
                            value: _selectedTimer,
                            items: const [
                              DropdownMenuItem(
                                value: 0,
                                child: Text('Immediately'),
                              ),
                              DropdownMenuItem(value: 1, child: Text('1 min')),
                              DropdownMenuItem(value: 2, child: Text('2 min')),
                              DropdownMenuItem(value: 5, child: Text('5 min')),
                              DropdownMenuItem(
                                value: 10,
                                child: Text('10 min'),
                              ),
                            ],
                            onChanged: (val) async {
                              if (val != null) {
                                setState(() => _selectedTimer = val);
                                // Persist timer value
                                if (!mounted) return;
                                final pinLockService = PinLockService();
                                await pinLockService.setPinLockTimerMinutes(
                                  val,
                                );
                                if (widget.onPinLockTimerChanged != null) {
                                  widget.onPinLockTimerChanged!(val);
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
