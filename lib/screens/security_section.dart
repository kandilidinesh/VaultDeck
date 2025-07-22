import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'pin_lock.dart';
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
  bool _isAuthenticating = false;
  String _authStatus = '';

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      bool canCheck = await _localAuth.canCheckBiometrics;
      bool isAvailable = await _localAuth.isDeviceSupported();
      if (!canCheck || !isAvailable) {
        setState(() {
          _authStatus = 'Biometric authentication not available.';
        });
        return;
      }
      bool authenticated = false;
      try {
        setState(() {
          _isAuthenticating = true;
        });
        authenticated = await _localAuth.authenticate(
          localizedReason: 'Authenticate to enable biometric lock',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );
      } catch (e) {
        setState(() {
          _authStatus = 'Error: ${e.toString()}';
        });
      } finally {
        setState(() {
          _isAuthenticating = false;
        });
      }
      if (authenticated) {
        setState(() {
          _biometricEnabled = true;
          _authStatus = 'Biometric authentication enabled.';
        });
      } else {
        setState(() {
          _authStatus = 'Authentication failed.';
        });
      }
    } else {
      setState(() {
        _biometricEnabled = false;
        _authStatus = 'Biometric authentication disabled.';
      });
    }
  }

  void _togglePin(bool value) async {
    if (value) {
      // Show PIN setup dialog
      await showDialog(
        context: context,
        builder: (ctx) => PinLockDialog(
          isSetup: true,
          onPinSet: (pin) {
            if (pin.toString().isNotEmpty) {
              widget.onPinToggle(true, pin);
            } else {
              widget.onPinToggle(false);
            }
          },
        ),
      );
    } else {
      widget.onPinToggle(false);
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedTimer = widget.pinLockTimerMinutes;
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
            onChanged: (val) => _toggleBiometric(val),
            secondary: const Icon(Icons.fingerprint_rounded),
            tileColor: tileBg,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
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
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Enable PIN Lock'),
            value: widget.pinEnabled,
            onChanged: _togglePin,
            secondary: const Icon(Icons.lock_rounded),
            tileColor: tileBg,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
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
                          DropdownMenuItem(value: 10, child: Text('10 min')),
                        ],
                        onChanged: (val) async {
                          if (val != null) {
                            setState(() => _selectedTimer = val);
                            // Persist timer value
                            if (!mounted) return;
                            final pinLockService = PinLockService();
                            await pinLockService.setPinLockTimerMinutes(val);
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
    );
  }
}
