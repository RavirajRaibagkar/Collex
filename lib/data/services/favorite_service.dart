import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/item_model.dart';
import '../../core/constants/app_constants.dart';

class FavoriteService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> addFavorite(String userId, String itemId) async {
    try {
      await _supabase.from(AppConstants.favoritesTable).insert({
        'user_id': userId,
        'item_id': itemId,
      });
    } catch (e) {
      debugPrint('Error adding favorite: $e');
      rethrow;
    }
  }

  Future<void> removeFavorite(String userId, String itemId) async {
    try {
      await _supabase
          .from(AppConstants.favoritesTable)
          .delete()
          .eq('user_id', userId)
          .eq('item_id', itemId);
    } catch (e) {
      debugPrint('Error removing favorite: $e');
      rethrow;
    }
  }

  Future<List<ItemModel>> getFavoriteItems(String userId) async {
    try {
      // Need to join the items table
      // Actually we also need to join the users table for the seller name of the item
      // But let's check how ItemModel handles it. It expects users: { name, rating } in the root or inside items?
      // Since it's nested: items(*, users(name, rating))
      final data = await _supabase
          .from(AppConstants.favoritesTable)
          .select('*, items(*, users(name, rating))')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (data as List).map((row) {
        final itemMap = row['items'] as Map<String, dynamic>;
        return ItemModel.fromJson(itemMap);
      }).toList();
    } catch (e, st) {
      debugPrint('Error getting favorites: $e\n$st');
      return [];
    }
  }

  Future<List<String>> getFavoriteItemIds(String userId) async {
    try {
      final data = await _supabase
          .from(AppConstants.favoritesTable)
          .select('item_id')
          .eq('user_id', userId);

      return (data as List).map((row) => row['item_id'] as String).toList();
    } catch (e) {
      debugPrint('Error getting favorite ids: $e');
      return [];
    }
  }
}
