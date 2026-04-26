import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/request_model.dart';
import '../../core/constants/app_constants.dart';

class RequestService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<RequestModel> createRequest({
    required String itemId,
    required String requesterId,
  }) async {
    final data = await _supabase
        .from(AppConstants.requestsTable)
        .insert({
          'item_id': itemId,
          'requester_id': requesterId,
          'status': 'pending',
        })
        .select()
        .single();

    return RequestModel.fromJson(data);
  }

  /// Fetch all requests for items owned by [sellerId].
  Future<List<RequestModel>> getRequestsForSeller(String sellerId) async {
    try {
      // Step 1: Get user's items
      final itemsRaw = await _supabase
          .from(AppConstants.itemsTable)
          .select('id, title, image_url')
          .eq('seller_id', sellerId);
      
      final itemIds = (itemsRaw as List).map((e) => e['id'] as String).toList();
      if (itemIds.isEmpty) return [];

      // Step 2: Get requests for those items
      final requestsRaw = await _supabase
          .from(AppConstants.requestsTable)
          .select('*')
          .inFilter('item_id', itemIds)
          .order('created_at', ascending: false);

      final requests = <RequestModel>[];
      for (final row in (requestsRaw as List)) {
        final itemId = row['item_id'] as String;
        final requesterId = row['requester_id'] as String;
        
        // Find item details
        final item = (itemsRaw as List).firstWhere((it) => it['id'] == itemId);
        
        // Fetch requester name
        String? requesterName;
        try {
          final userRow = await _supabase
              .from('users')
              .select('name')
              .eq('id', requesterId)
              .maybeSingle();
          requesterName = userRow?['name'] as String?;
        } catch (_) {}

        requests.add(RequestModel(
          id: row['id'] as String,
          itemId: itemId,
          requesterId: requesterId,
          status: row['status'] as String? ?? 'pending',
          itemTitle: item['title'] as String?,
          itemImageUrl: item['image_url'] as String?,
          requesterName: requesterName,
          createdAt: row['created_at'] != null
              ? DateTime.tryParse(row['created_at'] as String)
              : null,
        ));
      }
      return requests;
    } catch (e) {
      debugPrint('[RequestService] getRequestsForSeller error: $e');
      return [];
    }
  }

  Future<List<RequestModel>> getMyRequests(String requesterId) async {
    try {
      final data = await _supabase
          .from(AppConstants.requestsTable)
          .select('*')
          .eq('requester_id', requesterId)
          .order('created_at', ascending: false);

      final requests = <RequestModel>[];
      for (final row in (data as List)) {
        final itemId = row['item_id'] as String;
        
        // Fetch item details
        final itemRes = await _supabase
            .from(AppConstants.itemsTable)
            .select('title, image_url, seller_id')
            .eq('id', itemId)
            .maybeSingle();
        
        String? sellerName;
        if (itemRes != null) {
          final sellerId = itemRes['seller_id'] as String?;
          if (sellerId != null) {
            try {
              final userRes = await _supabase
                  .from('users')
                  .select('name')
                  .eq('id', sellerId)
                  .maybeSingle();
              sellerName = userRes?['name'] as String?;
            } catch (_) {}
          }
        }

        requests.add(RequestModel(
          id: row['id'] as String,
          itemId: itemId,
          requesterId: requesterId,
          status: row['status'] as String? ?? 'pending',
          itemTitle: itemRes?['title'] as String?,
          itemImageUrl: itemRes?['image_url'] as String?,
          sellerId: itemRes?['seller_id'] as String?,
          sellerName: sellerName,
          createdAt: row['created_at'] != null
              ? DateTime.tryParse(row['created_at'] as String)
              : null,
        ));
      }
      return requests;
    } catch (e) {
      debugPrint('[RequestService] getMyRequests error: $e');
      return [];
    }
  }

  Future<bool> hasAlreadyRequested(String itemId, String requesterId) async {
    final data = await _supabase
        .from(AppConstants.requestsTable)
        .select('id')
        .eq('item_id', itemId)
        .eq('requester_id', requesterId);

    return (data as List).isNotEmpty;
  }

  Future<void> updateRequestStatus(String requestId, String status, {String? itemId}) async {
    try {
      await _supabase
          .from(AppConstants.requestsTable)
          .update({'status': status}).eq('id', requestId);

      // If accepted, decrement item quantity
      if (status == 'accepted' && itemId != null) {
        final itemData = await _supabase
            .from(AppConstants.itemsTable)
            .select('quantity')
            .eq('id', itemId)
            .single();
        
        int currentQuantity = itemData['quantity'] as int? ?? 0;
        if (currentQuantity > 0) {
          await _supabase
              .from(AppConstants.itemsTable)
              .update({
                'quantity': currentQuantity - 1,
                'is_sold': (currentQuantity - 1) == 0,
              })
              .eq('id', itemId);
        }
      }
    } catch (e) {
      debugPrint('[RequestService] updateRequestStatus ERROR: $e');
      rethrow;
    }
  }
}
