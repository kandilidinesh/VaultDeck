import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

class ThemeToggleButton extends StatelessWidget {
  final ThemeProvider themeProvider;

  const ThemeToggleButton({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
      onPressed: themeProvider.toggleTheme,
      tooltip: themeProvider.isDarkMode
          ? 'Switch to light mode'
          : 'Switch to dark mode',
    );
  }
}
