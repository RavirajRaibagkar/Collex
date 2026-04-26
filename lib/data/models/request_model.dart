class RequestModel {
  final String id;
  final String itemId;
  final String requesterId;
  final String status; // pending, accepted, rejected
  final String? itemTitle;
  final String? itemImageUrl;
  final String? requesterName;
  final String? sellerId;
  final String? sellerName;
  final DateTime? createdAt;

  RequestModel({
    required this.id,
    required this.itemId,
    required this.requesterId,
    this.status = 'pending',
    this.itemTitle,
    this.itemImageUrl,
    this.requesterName,
    this.sellerId,
    this.sellerName,
    this.createdAt,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: json['id'] as String,
      itemId: json['item_id'] as String? ?? '',
      requesterId: json['requester_id'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      itemTitle: json['items']?['title'] as String?,
      itemImageUrl: json['items']?['image_url'] as String?,
      requesterName: json['requester']?['name'] as String?,
      sellerId: json['items']?['seller_id'] as String?,
      sellerName: json['items']?['users']?['name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'requester_id': requesterId,
      'status': status,
    };
  }
}
