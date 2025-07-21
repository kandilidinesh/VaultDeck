import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class VaultDeckAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onThemeToggle;
  final bool? isDarkMode;

  const VaultDeckAppBar({super.key, this.onThemeToggle, this.isDarkMode});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade400, Colors.indigo.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
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
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: (onThemeToggle != null)
          ? [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: AnimatedSwitcher(
                    duration: AppConstants.defaultAnimationDuration,
                    child: Icon(
                      (isDarkMode ?? false)
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      key: ValueKey(isDarkMode ?? false),
                      color: Colors.white,
                    ),
                  ),
                  onPressed: onThemeToggle,
                  tooltip: (isDarkMode ?? false)
                      ? 'Switch to light mode'
                      : 'Switch to dark mode',
                ),
              ),
            ]
          : [],
      // No flexibleSpace for transparency
    );
  }
}
