import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/favorite_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/item/item_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<FavoriteProvider>().loadFavorites(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = context.watch<FavoriteProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Items'),
      ),
      body: favoriteProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteProvider.favoriteItems.isEmpty
              ? _buildEmptyState(context)
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: favoriteProvider.favoriteItems.length,
                  itemBuilder: (context, i) {
                    final item = favoriteProvider.favoriteItems[i];
                    return ItemCard(
                      item: item,
                      onTap: () => context.push('/item/${item.id}', extra: item),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_outline,
              size: 64, color: AppColors.textSecondaryLight.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('No favorites yet',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Items you like will appear here.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Browse Items'),
          ),
        ],
      ),
    );
  }
}
