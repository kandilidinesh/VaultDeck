import '../screens/settings_page.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class VaultDeckAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ValueNotifier<bool> isDarkModeNotifier;
  final VoidCallback? toggleTheme;
  final bool pinEnabled;
  final String? pin;
  final void Function(bool, [String?]) setPinEnabled;
  final ValueNotifier<bool> pinEnabledNotifier;
  final bool shouldBlur;

  const VaultDeckAppBar({
    super.key,
    required this.isDarkModeNotifier,
    this.toggleTheme,
    required this.pinEnabled,
    required this.pin,
    required this.setPinEnabled,
    required this.pinEnabledNotifier,
    required this.shouldBlur,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkModeNotifier.value;

    return AppBar(
      elevation: 0,
      shadowColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      foregroundColor: isDark ? Colors.white : Colors.black87,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: isDark ? Colors.white : Colors.black87,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.settings_rounded,
              color: isDark ? Colors.white : Colors.black87,
              size: 24,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    toggleTheme: toggleTheme,
                    isDarkModeNotifier: isDarkModeNotifier,
                    pinEnabled: pinEnabled,
                    pin: pin,
                    setPinEnabled: setPinEnabled,
                    shouldBlur: shouldBlur,
                  ),
                ),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
    );
  }
}
