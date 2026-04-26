import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/item_model.dart';
import '../services/item_service.dart';

class ItemProvider extends ChangeNotifier {
  final ItemService _itemService = ItemService();

  List<ItemModel> _items = [];
  List<ItemModel> _myItems = [];
  bool _isLoading = false;
  bool _isPosting = false;
  String? _error;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _freeOnly = false;

  List<ItemModel> get items => _items;
  List<ItemModel> get myItems => _myItems;
  bool get isLoading => _isLoading;
  bool get isPosting => _isPosting;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get freeOnly => _freeOnly;

  Future<void> loadItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _itemService.getItems(
        category: _selectedCategory,
        searchQuery: _searchQuery,
        freeOnly: _freeOnly,
      );
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMyItems(String sellerId) async {
    try {
      _myItems = await _itemService.getMyItems(sellerId);
      notifyListeners();
    } catch (_) {}
  }

  void setCategory(String category) {
    _selectedCategory = category;
    loadItems();
  }

  void setSearch(String query) {
    _searchQuery = query;
    loadItems();
  }

  void setFreeOnly(bool value) {
    _freeOnly = value;
    loadItems();
  }

  Future<bool> postItem({
    required String title,
    required String description,
    required double price,
    required int quantity,
    required String category,
    required String condition,
    required String sellerId,
    File? imageFile,
  }) async {
    _isPosting = true;
    _error = null;
    notifyListeners();

    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _itemService.uploadImage(imageFile, sellerId);
      }

      final item = ItemModel(
        id: '',
        title: title,
        description: description,
        price: price,
        quantity: quantity,
        category: category,
        condition: condition,
        imageUrl: imageUrl,
        sellerId: sellerId,
      );

      await _itemService.createItem(item);
      await loadItems();
      _isPosting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isPosting = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> markAsSold(String itemId) async {
    try {
      await _itemService.markAsSold(itemId);
      _items.removeWhere((item) => item.id == itemId);
      _myItems = _myItems.map((item) {
        if (item.id == itemId) return item.copyWith(isSold: true);
        return item;
      }).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> deleteItem(String itemId) async {
    try {
      await _itemService.deleteItem(itemId);
      _items.removeWhere((item) => item.id == itemId);
      _myItems.removeWhere((item) => item.id == itemId);
      notifyListeners();
    } catch (_) {}
  }
}
