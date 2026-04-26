import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/item_model.dart';
import '../../core/constants/app_constants.dart';

class ItemService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _uuid = const Uuid();

  Future<List<ItemModel>> getItems({
    String? category,
    String? searchQuery,
    bool freeOnly = false,
  }) async {
    // Build the filter step by step (all .eq() before .order())
    var filterQuery = _supabase
        .from(AppConstants.itemsTable)
        .select('*, users(name, rating)')
        .eq('is_sold', false);

    if (category != null && category != 'All') {
      filterQuery = filterQuery.eq('category', category);
    }

    if (freeOnly) {
      filterQuery = filterQuery.eq('price', 0);
    }

    final data = await filterQuery.order('created_at', ascending: false);

    List<ItemModel> items = (data as List)
        .map((e) => ItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // Search filter client-side
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      items = items
          .where((item) =>
              item.title.toLowerCase().contains(q) ||
              (item.description?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    return items;
  }

  Future<ItemModel?> getItemById(String id) async {
    final data = await _supabase
        .from(AppConstants.itemsTable)
        .select('*, users(name, rating)')
        .eq('id', id)
        .single();

    return ItemModel.fromJson(data);
  }

  Future<List<ItemModel>> getMyItems(String sellerId) async {
    final data = await _supabase
        .from(AppConstants.itemsTable)
        .select('*, users(name, rating)')
        .eq('seller_id', sellerId)
        .order('created_at', ascending: false);

    return (data as List)
        .map((e) => ItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<String?> uploadImage(File imageFile, String userId) async {
    final filename = '${userId}_${_uuid.v4()}.jpg';
    await _supabase.storage
        .from(AppConstants.itemImagesBucket)
        .upload(filename, imageFile);

    final publicUrl = _supabase.storage
        .from(AppConstants.itemImagesBucket)
        .getPublicUrl(filename);

    return publicUrl;
  }

  Future<ItemModel> createItem(ItemModel item) async {
    final data = await _supabase
        .from(AppConstants.itemsTable)
        .insert(item.toJson())
        .select('*, users(name, rating)')
        .single();

    return ItemModel.fromJson(data);
  }

  Future<void> markAsSold(String itemId) async {
    await _supabase
        .from(AppConstants.itemsTable)
        .update({'is_sold': true}).eq('id', itemId);
  }

  Future<void> deleteItem(String itemId) async {
    await _supabase
        .from(AppConstants.itemsTable)
        .delete()
        .eq('id', itemId);
  }
}
