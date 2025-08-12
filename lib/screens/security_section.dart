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
        return;
      }
      await box.put('biometricEnabled', true);
      setState(() {
        _biometricEnabled = true;
      });
    } else {
      await box.put('biometricEnabled', false);
      setState(() {
        _biometricEnabled = false;
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
    return Column(
      children: [
        // Biometric Authentication
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _biometricEnabled
                  ? const Color(0xFF10B981).withValues(alpha: 0.1)
                  : (isDark
                        ? const Color(0xFF2D2D2D)
                        : const Color(0xFFF3F4F6)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.fingerprint_rounded,
              color: _biometricEnabled
                  ? const Color(0xFF10B981)
                  : (isDark ? Colors.white70 : Colors.grey[700]),
              size: 24,
            ),
          ),
          title: Text(
            'Biometric Authentication',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            _biometricEnabled
                ? 'Face ID / Touch ID enabled'
                : 'Use biometric to unlock',
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.grey[600],
              fontSize: 14,
            ),
          ),
          trailing: Switch(
            value: _biometricEnabled,
            onChanged: _toggleBiometric,
            activeColor: const Color(0xFF10B981),
            activeTrackColor: const Color(0xFF10B981).withValues(alpha: 0.3),
          ),
        ),

        Divider(
          height: 1,
          indent: 70,
          endIndent: 20,
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB),
        ),

        // PIN Lock
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: widget.pinEnabled
                  ? const Color(0xFF6366F1).withValues(alpha: 0.1)
                  : (isDark
                        ? const Color(0xFF2D2D2D)
                        : const Color(0xFFF3F4F6)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.lock_rounded,
              color: widget.pinEnabled
                  ? const Color(0xFF6366F1)
                  : (isDark ? Colors.white70 : Colors.grey[700]),
              size: 24,
            ),
          ),
          title: Text(
            'PIN Lock',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            widget.pinEnabled
                ? 'PIN protection enabled'
                : 'Set a PIN to secure your vault',
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.grey[600],
              fontSize: 14,
            ),
          ),
          trailing: Switch(
            value: widget.pinEnabled,
            onChanged: _togglePin,
            activeColor: const Color(0xFF6366F1),
            activeTrackColor: const Color(0xFF6366F1).withValues(alpha: 0.3),
          ),
        ),

        // PIN Timer (only show if PIN is enabled)
        if (widget.pinEnabled) ...[
          Divider(
            height: 1,
            indent: 70,
            endIndent: 20,
            color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2D2D2D)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.timer_rounded,
                color: isDark ? Colors.white70 : Colors.grey[700],
                size: 24,
              ),
            ),
            title: Text(
              'Auto-Lock Timer',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              _getTimerDescription(_selectedTimer),
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.grey[600],
                fontSize: 14,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2D2D2D)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF404040)
                      : const Color(0xFFE5E7EB),
                ),
              ),
              child: DropdownButton<int>(
                value: _selectedTimer,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Immediately')),
                  DropdownMenuItem(value: 1, child: Text('1 min')),
                  DropdownMenuItem(value: 2, child: Text('2 min')),
                  DropdownMenuItem(value: 5, child: Text('5 min')),
                  DropdownMenuItem(value: 10, child: Text('10 min')),
                ],
                onChanged: (val) async {
                  if (val != null) {
                    await _setPinPromptTimer(val);
                  }
                },
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: isDark ? Colors.white54 : Colors.grey[500],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _getTimerDescription(int timer) {
    switch (timer) {
      case 0:
        return 'Lock immediately when app is closed';
      case 1:
        return 'Lock after 1 minute of inactivity';
      case 2:
        return 'Lock after 2 minutes of inactivity';
      case 5:
        return 'Lock after 5 minutes of inactivity';
      case 10:
        return 'Lock after 10 minutes of inactivity';
      default:
        return 'Lock immediately when app is closed';
    }
  }
}
