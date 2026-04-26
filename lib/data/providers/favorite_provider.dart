import 'package:flutter/foundation.dart';
import '../models/item_model.dart';
import '../services/favorite_service.dart';

class FavoriteProvider extends ChangeNotifier {
  final FavoriteService _service = FavoriteService();

  List<ItemModel> _favoriteItems = [];
  Set<String> _favoriteItemIds = {};
  bool _isLoading = false;

  List<ItemModel> get favoriteItems => _favoriteItems;
  bool get isLoading => _isLoading;

  bool isFavorite(String itemId) => _favoriteItemIds.contains(itemId);

  Future<void> loadFavorites(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _favoriteItems = await _service.getFavoriteItems(userId);
      _favoriteItemIds = _favoriteItems.map((e) => e.id).toSet();
    } catch (e) {
      debugPrint('Error in loadFavorites: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFavorite(String userId, ItemModel item) async {
    final isFav = isFavorite(item.id);

    // Optimistic update
    if (isFav) {
      _favoriteItemIds.remove(item.id);
      _favoriteItems.removeWhere((e) => e.id == item.id);
    } else {
      _favoriteItemIds.add(item.id);
      _favoriteItems.insert(0, item);
    }
    notifyListeners();

    try {
      if (isFav) {
        await _service.removeFavorite(userId, item.id);
      } else {
        await _service.addFavorite(userId, item.id);
      }
    } catch (e) {
      // Revert on failure
      if (isFav) {
        _favoriteItemIds.add(item.id);
        _favoriteItems.add(item); // Note: might not restore original order
      } else {
        _favoriteItemIds.remove(item.id);
        _favoriteItems.removeWhere((e) => e.id == item.id);
      }
      notifyListeners();
    }
  }
}
