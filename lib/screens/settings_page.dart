import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          ListTile(
            leading: Icon(Icons.dark_mode_rounded),
            title: Text('Theme'),
            subtitle: Text('Toggle light/dark mode'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.lock_rounded),
            title: Text('Security'),
            subtitle: Text('Set up app lock or biometrics'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info_rounded),
            title: Text('About VaultDeck'),
            subtitle: Text('Version 1.0.0'),
          ),
        ],
      ),
    );
  }
}
