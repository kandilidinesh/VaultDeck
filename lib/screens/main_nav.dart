import 'package:flutter/material.dart';
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

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      HomePage(
        title: widget.title,
        toggleTheme: widget.toggleTheme,
        isDarkMode: widget.isDarkMode,
      ),
      const FavoritesPage(),
      const SettingsPage(),
    ]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card_rounded),
            label: 'Cards',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_rounded),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
