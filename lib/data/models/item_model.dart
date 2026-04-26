class ItemModel {
  final String id;
  final String title;
  final String? description;
  final double price;
  final String category;
  final String condition;
  final String? imageUrl;
  final String sellerId;
  final String? sellerName;
  final double? sellerRating;
  final bool isSold;
  final bool isFree;
  final int quantity;
  final DateTime? createdAt;

  ItemModel({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    required this.category,
    required this.condition,
    this.imageUrl,
    required this.sellerId,
    this.sellerName,
    this.sellerRating,
    this.isSold = false,
    this.isFree = false,
    this.quantity = 1,
    this.createdAt,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    final price = (json['price'] as num?)?.toDouble() ?? 0.0;
    return ItemModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      price: price,
      category: json['category'] as String? ?? 'Others',
      condition: json['condition'] as String? ?? 'Good',
      imageUrl: json['image_url'] as String?,
      sellerId: json['seller_id'] as String? ?? '',
      sellerName: json['users']?['name'] as String?,
      sellerRating: (json['users']?['rating'] as num?)?.toDouble(),
      isSold: json['is_sold'] as bool? ?? false,
      isFree: price == 0,
      quantity: json['quantity'] as int? ?? 1,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'condition': condition,
      'image_url': imageUrl,
      'seller_id': sellerId,
      'is_sold': isSold,
      'quantity': quantity,
    };
  }

  ItemModel copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? category,
    String? condition,
    String? imageUrl,
    String? sellerId,
    bool? isSold,
    int? quantity,
  }) {
    return ItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      imageUrl: imageUrl ?? this.imageUrl,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName,
      sellerRating: sellerRating,
      isSold: isSold ?? this.isSold,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt,
    );
  }
}
