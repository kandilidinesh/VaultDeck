import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final VoidCallback? toggleTheme;
  final bool? isDarkMode;

  const SettingsPage({
    super.key,
    this.toggleTheme,
    this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ListTile(
            leading: const Icon(Icons.dark_mode_rounded),
            title: const Text('Theme'),
            subtitle: const Text('Toggle light/dark mode'),
            trailing: Switch(
              value: isDarkMode ?? false,
              onChanged: (_) {
                if (toggleTheme != null) toggleTheme!();
              },
            ),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.lock_rounded),
            title: Text('Security'),
            subtitle: Text('Set up app lock or biometrics'),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_rounded),
            title: Text('About VaultDeck'),
            subtitle: Text('Version 1.0.0'),
          ),
        ],
      ),
    );
  }
}
