import 'package:flutter/material.dart';
import 'security_section.dart';
import 'icloud_sync_section.dart';

class SettingsPage extends StatelessWidget {
  final VoidCallback? toggleTheme;
  final bool? isDarkMode;

  const SettingsPage({super.key, this.toggleTheme, this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final tileBg = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity(0.04)
        : Colors.white;
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Theme group
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: tileBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
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
                    ],
                  ),
                ),
                // Security group
                const SecuritySection(),
                // iCloud sync group
                const ICloudSyncSection(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
