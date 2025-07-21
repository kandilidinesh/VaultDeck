import 'package:flutter/material.dart';

class PinLockDialog extends StatefulWidget {
  final void Function(String pin)? onPinSet;
  final void Function(String pin)? onPinVerify;
  final bool isSetup;

  const PinLockDialog({Key? key, this.onPinSet, this.onPinVerify, this.isSetup = true}) : super(key: key);

  @override
  State<PinLockDialog> createState() => _PinLockDialogState();
}

class _PinLockDialogState extends State<PinLockDialog> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  String? _error;

  void _handlePin() {
    final pin = _pinController.text.trim();
    if (widget.isSetup) {
      final confirm = _confirmController.text.trim();
      if (pin.length != 4 || confirm.length != 4) {
        setState(() => _error = 'PIN must be 4 digits');
        return;
      }
      if (pin != confirm) {
        setState(() => _error = 'PINs do not match');
        return;
      }
      widget.onPinSet?.call(pin);
      Navigator.pop(context);
    } else {
      if (pin.length != 4) {
        setState(() => _error = 'PIN must be 4 digits');
        return;
      }
      widget.onPinVerify?.call(pin);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isSetup ? 'Set PIN' : 'Enter PIN'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _pinController,
            decoration: const InputDecoration(labelText: 'PIN'),
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
          ),
          if (widget.isSetup)
            TextField(
              controller: _confirmController,
              decoration: const InputDecoration(labelText: 'Confirm PIN'),
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: Text(widget.isSetup ? 'Set PIN' : 'Verify'),
          onPressed: _handlePin,
        ),
      ],
    );
  }
}
