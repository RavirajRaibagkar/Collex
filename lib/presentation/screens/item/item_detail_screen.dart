import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/item_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/request_provider.dart';
import '../../../core/theme/app_theme.dart';
import 'package:timeago/timeago.dart' as timeago;

class ItemDetailScreen extends StatefulWidget {
  final ItemModel item;
  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  bool _isWishlisted = false;

  Future<void> _requestItem() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    if (user.id == widget.item.sellerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can't request your own item")),
      );
      return;
    }

    final requestProvider = context.read<RequestProvider>();
    final errorMsg = await requestProvider.createRequest(
      itemId: widget.item.id,
      requesterId: user.id,
    );

    if (mounted) {
      final success = errorMsg == null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? '✅ Request sent! Waiting for seller.'
              : '⚠️ $errorMsg'),
          backgroundColor: success ? AppColors.accent : AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final user = context.watch<AuthProvider>().user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final conditionColor = item.condition == 'New'
        ? AppColors.secondary
        : item.condition == 'Good'
            ? AppColors.primary
            : AppColors.warning;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image App Bar
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => setState(() => _isWishlisted = !_isWishlisted),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        _isWishlisted ? Icons.favorite : Icons.favorite_border,
                        color: _isWishlisted ? AppColors.warning : Colors.white,
                        key: ValueKey(_isWishlisted),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: item.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: item.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: isDark ? AppColors.surfaceDark : AppColors.borderLight,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (_, __, ___) => _itemImagePlaceholder(item),
                    )
                  : _itemImagePlaceholder(item),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags row
                  Row(
                    children: [
                      if (item.isFree)
                        _buildTag('FREE', AppColors.accent)
                      else
                        _buildTag('₹${item.price.toStringAsFixed(0)}', AppColors.primary),
                      const SizedBox(width: 8),
                      _buildTag(item.condition, conditionColor),
                      const SizedBox(width: 8),
                      _buildTag(item.category, AppColors.secondary),
                      const SizedBox(width: 8),
                      _buildTag('Qty: ${item.quantity}', AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(item.title, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 4),

                  if (item.createdAt != null)
                    Text(
                      'Posted ${timeago.format(item.createdAt!)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  const SizedBox(height: 16),

                  // Description
                  if (item.description != null && item.description!.isNotEmpty) ...[
                    Text('About this item',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(item.description!,
                        style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 20),
                  ],

                  // Seller card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primary.withOpacity(0.15),
                          child: Text(
                            (item.sellerName?.isNotEmpty == true)
                                ? item.sellerName![0].toUpperCase()
                                : 'S',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.sellerName ?? 'Unknown Seller',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded,
                                      color: Colors.amber, size: 16),
                                  const SizedBox(width: 2),
                                  Text(
                                    item.sellerRating?.toStringAsFixed(1) ?? '0.0',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (user?.id != item.sellerId)
                          OutlinedButton.icon(
                            onPressed: () => context.push(
                              '/chat/${item.sellerId}',
                              extra: item.sellerName ?? 'Seller',
                            ),
                            icon: const Icon(Icons.chat_bubble_outline, size: 16),
                            label: const Text('Chat'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 36),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 0),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Action buttons
      bottomSheet: item.isSold
          ? Container(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.textSecondaryLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text('This item has been sold',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            )
          : user?.id == item.sellerId
              ? null
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _requestItem,
                            icon: const Icon(Icons.handshake_outlined),
                            label: const Text('Request Item'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary, width: 1.5),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.chat_bubble_outline,
                                color: AppColors.primary),
                            onPressed: () => context.push(
                              '/chat/${item.sellerId}',
                              extra: item.sellerName ?? 'Seller',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _itemImagePlaceholder(ItemModel item) {
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 80,
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
    );
  }
}
