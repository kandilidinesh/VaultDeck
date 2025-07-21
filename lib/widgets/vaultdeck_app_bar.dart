import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class VaultDeckAppBar extends StatelessWidget implements PreferredSizeWidget {
  const VaultDeckAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        ],
      ),
    );
  }
}
