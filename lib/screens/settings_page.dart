import 'package:flutter/material.dart';
import 'security_section.dart';
import 'cloud_sync_section.dart';

class SettingsPage extends StatelessWidget {
  final ValueNotifier<bool> isDarkModeNotifier;
  final VoidCallback? toggleTheme;
  final bool pinEnabled;
  final String? pin;
  final void Function(bool, [String?]) setPinEnabled;

  const SettingsPage({
    super.key,
    required this.isDarkModeNotifier,
    this.toggleTheme,
    required this.pinEnabled,
    required this.pin,
    required this.setPinEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileBg = isDark
        ? const Color(0xFF23262F)
        : const Color(0xFFE0E0E0); // Slightly darker gray for light mode
    final bgColor = isDark
        ? const Color(0xFF181A20)
        : const Color(0xFFF5F5F5); // Slightly darker background for light mode
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF181A20) : Colors.white,
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Theme group
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                      right: 8,
                      top: 8,
                      bottom: 0,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.dark_mode_rounded, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Theme',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width > 500
                          ? 500
                          : MediaQuery.of(context).size.width * 0.98,
                      margin: const EdgeInsets.symmetric(horizontal: 0),
                      decoration: BoxDecoration(
                        color: tileBg,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(16),
                        ),
                      ),
                      child: ValueListenableBuilder<bool>(
                        valueListenable: isDarkModeNotifier,
                        builder: (context, isDark, _) => ListTile(
                          title: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Toggle light/dark mode',
                              style: Theme.of(context).textTheme.bodyLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          trailing: Switch(
                            value: isDark,
                            onChanged: (_) {
                              if (toggleTheme != null) toggleTheme!();
                            },
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Security group
                  Builder(
                    builder: (context) {
                      return SecuritySection(
                        pinEnabled: pinEnabled,
                        pin: pin,
                        onPinToggle: setPinEnabled,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // iCloud sync group
                  const CloudSyncSection(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black45,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
