import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.star_rounded, size: 64, color: Colors.amber),
          SizedBox(height: 16),
          Text('No favorites yet', style: TextStyle(fontSize: 20)),
          SizedBox(height: 8),
          Text('Mark cards as favorites to see them here'),
        ],
      ),
    );
  }
}
