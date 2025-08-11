import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:hive/hive.dart';
import '../widgets/set_pin_screen.dart';
import '../widgets/unlock_pin_screen.dart';
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
  String _authStatus = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final box = await Hive.openBox('settingsBox');
    final enabled = box.get('biometricEnabled', defaultValue: false);
    int timer;
    if (box.containsKey('pinPromptTimer')) {
      timer = box.get('pinPromptTimer');
    } else {
      timer = widget.pinLockTimerMinutes;
      await box.put('pinPromptTimer', timer);
    }
    setState(() {
      _biometricEnabled = enabled;
      _selectedTimer = timer;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    final box = await Hive.openBox('settingsBox');
    if (value) {
      bool canCheck = await _localAuth.canCheckBiometrics;
      bool isAvailable = await _localAuth.isDeviceSupported();

      if (!canCheck || !isAvailable) {
        setState(() {
          _authStatus = 'Biometric authentication not available.';
        });
        return;
      }
      await box.put('biometricEnabled', true);
      setState(() {
        _biometricEnabled = true;
        _authStatus = '';
      });
    } else {
      await box.put('biometricEnabled', false);
      setState(() {
        _biometricEnabled = false;
        _authStatus = '';
      });
    }
  }

  void _togglePin(bool value) async {
    if (value) {
      widget.onPinToggle(true);
      final pin = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (ctx) => SetPinScreen(
            onPinSet: (pin) {
              Navigator.of(ctx).pop(pin);
            },
            onCancel: () {
              Navigator.of(ctx).pop();
            },
          ),
        ),
      );
      if (pin != null && pin.isNotEmpty) {
        widget.onPinToggle(true, pin);
      } else {
        widget.onPinToggle(false);
      }
    } else {
      // Use full screen PIN prompt for validation before disabling
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (ctx) => UnlockPinScreen(),
        ),
      );
      if (result == true) {
        widget.onPinToggle(false);
      }
      // If cancelled or incorrect, do nothing
    }
  }

  Future<void> _setPinPromptTimer(int val) async {
    final box = await Hive.openBox('settingsBox');
    await box.put('pinPromptTimer', val);
    setState(() => _selectedTimer = val);
    final pinLockService = PinLockService();
    await pinLockService.setPinLockTimerMinutes(val);
    if (widget.onPinLockTimerChanged != null) {
      widget.onPinLockTimerChanged!(val);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileBg = isDark ? const Color(0xFF23262F) : Colors.white;
    final screenWidth = MediaQuery.of(context).size.width;
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
        Center(
          child: Container(
            width: screenWidth > 500 ? 500 : screenWidth * 0.98,
            margin: const EdgeInsets.symmetric(horizontal: 0),
            decoration: BoxDecoration(
              color: tileBg,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Enable Biometric',
                      style: Theme.of(context).textTheme.bodyLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  value: _biometricEnabled,
                  onChanged: (val) => _toggleBiometric(val),
                  secondary: const Icon(Icons.fingerprint_rounded),
                  tileColor: tileBg,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
                  title: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Enable PIN Lock',
                      style: Theme.of(context).textTheme.bodyLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  value: widget.pinEnabled,
                  onChanged: _togglePin,
                  secondary: const Icon(Icons.lock_rounded),
                  tileColor: tileBg,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
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
                            onChanged: widget.pinEnabled
                                ? (val) async {
                                    if (val != null) {
                                      await _setPinPromptTimer(val);
                                    }
                                  }
                                : null,
                            disabledHint: Text(
                              _selectedTimer == 0
                                  ? 'Immediately'
                                  : _selectedTimer == 1
                                  ? '1 min'
                                  : _selectedTimer == 2
                                  ? '2 min'
                                  : _selectedTimer == 5
                                  ? '5 min'
                                  : _selectedTimer == 10
                                  ? '10 min'
                                  : '',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
