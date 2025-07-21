import 'package:flutter/material.dart';
import 'security_section.dart';
import 'icloud_sync_section.dart';
import 'dart:ui';

class SettingsPage extends StatelessWidget {
  final VoidCallback? toggleTheme;
  final bool? isDarkMode;

  const SettingsPage({super.key, this.toggleTheme, this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileBg = isDark ? const Color(0xFF23262F) : const Color(0xFFE0E0E0); // Slightly darker gray for light mode
    final bgColor = isDark ? const Color(0xFF181A20) : const Color(0xFFF5F5F5); // Slightly darker background for light mode
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        flexibleSpace: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.grey.shade200.withOpacity(0.18),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.12)
                      : Colors.grey.shade300.withOpacity(0.18),
                  width: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
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
                        InkWell(
                          borderRadius: BorderRadius.circular(16),
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          child: ListTile(
                            leading: Icon(
                              Icons.dark_mode_rounded,
                              color: isDark ? Colors.white : Colors.black54,
                            ),
                            title: Text(
                              'Theme',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Toggle light/dark mode',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            trailing: Switch(
                              value: isDarkMode ?? false,
                              onChanged: (_) {
                                if (toggleTheme != null) toggleTheme!();
                              },
                            ),
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
