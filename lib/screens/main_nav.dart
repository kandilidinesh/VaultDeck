import 'package:flutter/material.dart';
import 'dart:ui';
import 'home_page.dart';
import 'favorites_page.dart';
import 'settings_page.dart';

class MainNav extends StatefulWidget {
  final String title;
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const MainNav({
    super.key,
    required this.title,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(title: widget.title),
      const FavoritesPage(),
      SettingsPage(
        toggleTheme: widget.toggleTheme,
        isDarkMode: widget.isDarkMode,
      ),
    ];
    return Scaffold(
      extendBody: true,
      body: pages[_selectedIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height:
                kBottomNavigationBarHeight +
                MediaQuery.of(context).padding.bottom,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.white.withOpacity(0.7),
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.08),
                  width: 1.2,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(context, 0, Icons.credit_card_rounded, 'Cards'),
                _buildNavItem(context, 1, Icons.star_rounded, 'Favorites'),
                _buildNavItem(context, 2, Icons.settings_rounded, 'Settings'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    final isSelected = _selectedIndex == index;
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).iconTheme.color?.withOpacity(0.5);
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
