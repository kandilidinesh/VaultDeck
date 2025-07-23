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

  const VaultDeckAppBar({
    super.key,
    required this.isDarkModeNotifier,
    this.toggleTheme,
    required this.pinEnabled,
    required this.pin,
    required this.setPinEnabled,
    required this.pinEnabledNotifier,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkModeNotifier.value;

    return AppBar(
      elevation: 0,
      shadowColor: Colors.transparent,
      backgroundColor: isDark ? const Color(0xFF181A20) : Colors.grey[50],
      foregroundColor: Colors.white,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: isDark ? Colors.grey[50] : const Color(0xFF181A20),
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
                    color: isDark ? Colors.grey[50] : const Color(0xFF181A20),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.settings_rounded,
              color: isDark ? Colors.grey[50] : const Color(0xFF181A20),
            ),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return ValueListenableBuilder<bool>(
                      valueListenable: pinEnabledNotifier,
                      builder: (context, pinEnabledValue, _) {
                        return SettingsPage(
                          isDarkModeNotifier: isDarkModeNotifier,
                          toggleTheme: toggleTheme,
                          pinEnabled: pinEnabledValue,
                          pin: pin,
                          setPinEnabled: setPinEnabled,
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
