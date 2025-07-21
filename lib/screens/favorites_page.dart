import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? const Color(0xFF181A20) : Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_rounded, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            Text('No favorites yet', style: TextStyle(fontSize: 20, color: isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 8),
            Text('Mark cards as favorites to see them here', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
          ],
        ),
      ),
    );
  }
}
