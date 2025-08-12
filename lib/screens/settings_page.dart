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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                children: [
                  // App Info Card
                  _buildAppInfoCard(context, isDark),
                  const SizedBox(height: 24),

                  // Theme Section
                  _buildSectionHeader(
                    context,
                    'Appearance',
                    Icons.palette_rounded,
                    isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildThemeCard(context, isDark, screenWidth),
                  const SizedBox(height: 24),

                  // Security Section
                  _buildSectionHeader(
                    context,
                    'Security',
                    Icons.shield_rounded,
                    isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildSecurityCard(context, isDark, screenWidth),
                  const SizedBox(height: 24),

                  // Cloud Sync Section
                  _buildSectionHeader(
                    context,
                    'Backup & Sync',
                    Icons.cloud_rounded,
                    isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildCloudSyncCard(context, isDark, screenWidth),
                  const SizedBox(height: 24),

                  // About Section
                  _buildSectionHeader(
                    context,
                    'About',
                    Icons.info_rounded,
                    isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildAboutCard(context, isDark, screenWidth),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoCard(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.credit_card_rounded,
              size: 24,
              color: const Color(0xFF6366F1),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VaultDeck',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your Personal Card Vault',
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'v1.0.0',
              style: TextStyle(
                color: const Color(0xFF6366F1),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(
    BuildContext context,
    bool isDark,
    double screenWidth,
  ) {
    return Container(
      width: screenWidth > 500 ? 500 : screenWidth * 0.98,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ValueListenableBuilder<bool>(
        valueListenable: isDarkModeNotifier,
        builder: (context, isDarkMode, _) => ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF6366F1).withValues(alpha: 0.1)
                  : const Color(0xFFF59E0B).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: isDarkMode
                  ? const Color(0xFF6366F1)
                  : const Color(0xFFF59E0B),
              size: 24,
            ),
          ),
          title: Text(
            'Dark Mode',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.grey[600],
              fontSize: 14,
            ),
          ),
          trailing: Switch(
            value: isDarkMode,
            onChanged: (_) {
              if (toggleTheme != null) toggleTheme!();
            },
            activeColor: const Color(0xFF6366F1),
            activeTrackColor: const Color(0xFF6366F1).withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityCard(
    BuildContext context,
    bool isDark,
    double screenWidth,
  ) {
    return Container(
      width: screenWidth > 500 ? 500 : screenWidth * 0.98,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SecuritySection(
        pinEnabled: pinEnabled,
        pin: pin,
        onPinToggle: setPinEnabled,
      ),
    );
  }

  Widget _buildCloudSyncCard(
    BuildContext context,
    bool isDark,
    double screenWidth,
  ) {
    return Container(
      width: screenWidth > 500 ? 500 : screenWidth * 0.98,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const CloudSyncSection(),
    );
  }

  Widget _buildAboutCard(
    BuildContext context,
    bool isDark,
    double screenWidth,
  ) {
    return Container(
      width: screenWidth > 500 ? 500 : screenWidth * 0.98,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildAboutTile(
            context,
            'Privacy Policy',
            Icons.privacy_tip_rounded,
            () {},
            isDark,
          ),
          _buildDivider(isDark),
          _buildAboutTile(
            context,
            'Terms of Service',
            Icons.description_rounded,
            () {},
            isDark,
          ),
          _buildDivider(isDark),
          _buildAboutTile(
            context,
            'Support',
            Icons.support_agent_rounded,
            () {},
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
    bool isDark,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white70 : Colors.grey[700],
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: isDark ? Colors.white54 : Colors.grey[500],
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 70,
      endIndent: 20,
      color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB),
    );
  }
}
