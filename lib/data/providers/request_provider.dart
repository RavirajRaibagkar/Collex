import 'package:flutter/foundation.dart';
import '../models/request_model.dart';
import '../services/request_service.dart';

class RequestProvider extends ChangeNotifier {
  final RequestService _requestService = RequestService();

  List<RequestModel> _myRequests = [];
  List<RequestModel> _receivedRequests = [];
  bool _myRequestsLoading = false;
  bool _receivedLoading = false;

  List<RequestModel> get myRequests => _myRequests;
  List<RequestModel> get receivedRequests => _receivedRequests;
  bool get myRequestsLoading => _myRequestsLoading;
  bool get receivedLoading => _receivedLoading;
  bool get isLoading => _myRequestsLoading && _receivedLoading;

  Future<String?> createRequest({
    required String itemId,
    required String requesterId,
  }) async {
    try {
      final alreadyRequested = await _requestService.hasAlreadyRequested(
        itemId,
        requesterId,
      );
      if (alreadyRequested) return 'You already requested this item.';

      await _requestService.createRequest(
        itemId: itemId,
        requesterId: requesterId,
      );
      // Reload sent requests in background — do NOT await to avoid blocking UI
      loadMyRequests(requesterId);
      return null;
    } catch (e) {
      debugPrint('Create request error: $e');
      return e
          .toString()
          .replaceAll('Exception: ', '')
          .replaceAll('PostgrestException', 'DB Error');
    }
  }

  Future<void> loadMyRequests(String requesterId) async {
    _myRequestsLoading = true;
    notifyListeners();

    try {
      _myRequests = await _requestService.getMyRequests(requesterId);
    } catch (e) {
      debugPrint('Error loading my requests: $e');
    }

    _myRequestsLoading = false;
    notifyListeners();
  }

  Future<void> loadReceivedRequests(String sellerId) async {
    _receivedLoading = true;
    notifyListeners();

    try {
      _receivedRequests =
          await _requestService.getRequestsForSeller(sellerId);
    } catch (e) {
      debugPrint('Error loading received requests: $e');
    }

    _receivedLoading = false;
    notifyListeners();
  }

  Future<void> updateRequestStatus(String requestId, String status, {String? itemId}) async {
    try {
      await _requestService.updateRequestStatus(requestId, status, itemId: itemId);
      
      // Update received requests locally
      _receivedRequests = _receivedRequests.map((r) {
        if (r.id == requestId) {
          return RequestModel(
            id: r.id,
            itemId: r.itemId,
            requesterId: r.requesterId,
            status: status,
            itemTitle: r.itemTitle,
            itemImageUrl: r.itemImageUrl,
            requesterName: r.requesterName,
            sellerId: r.sellerId,
            sellerName: r.sellerName,
            createdAt: r.createdAt,
          );
        }
        return r;
      }).toList();

      // Update my requests locally in case it was a status change that affects current user
      _myRequests = _myRequests.map((r) {
        if (r.id == requestId) {
          return RequestModel(
            id: r.id,
            itemId: r.itemId,
            requesterId: r.requesterId,
            status: status,
            itemTitle: r.itemTitle,
            itemImageUrl: r.itemImageUrl,
            requesterName: r.requesterName,
            sellerId: r.sellerId,
            sellerName: r.sellerName,
            createdAt: r.createdAt,
          );
        }
        return r;
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('updateRequestStatus error: $e');
    }
  }
}
