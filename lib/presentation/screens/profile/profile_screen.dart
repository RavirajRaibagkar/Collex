import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/item_provider.dart';
import '../../../data/providers/request_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/item/item_card.dart';
import '../../widgets/common/app_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    // Load data after first frame to avoid setState-during-build
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    context.read<ItemProvider>().loadMyItems(user.id);
    context.read<RequestProvider>().loadMyRequests(user.id);
    context.read<RequestProvider>().loadReceivedRequests(user.id);
  }

  Future<void> _showChangePasswordDialog() async {
    final passCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter your new password.',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            AppTextField(
                controller: passCtrl,
                label: 'New Password',
                icon: Icons.lock_outline,
                obscureText: true),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (passCtrl.text.isEmpty) return;
              final success = await context
                  .read<AuthProvider>()
                  .updatePassword(passCtrl.text);
              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(success
                      ? 'Password updated!'
                      : 'Failed to update password.'),
                  backgroundColor:
                      success ? AppColors.accent : AppColors.warning,
                ));
              }
            },
            child: const Text('Update',
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditProfileDialog() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    final nameCtrl = TextEditingController(text: user.name);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Name'),
        content: AppTextField(
            controller: nameCtrl,
            label: 'Full Name',
            icon: Icons.person_outline),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty) return;
              final success = await context
                  .read<AuthProvider>()
                  .updateProfile(nameCtrl.text.trim());
              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(success
                      ? 'Name updated!'
                      : 'Failed to update name.'),
                  backgroundColor:
                      success ? AppColors.accent : AppColors.warning,
                ));
              }
            },
            child: const Text('Save',
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final itemProvider = context.watch<ItemProvider>();
    final requestProvider = context.watch<RequestProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Gradient Header ────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  // Top action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.password_outlined,
                            color: Colors.white),
                        onPressed: _showChangePasswordDialog,
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_outlined,
                            color: Colors.white),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Sign Out'),
                              content: const Text(
                                  'Are you sure you want to sign out?'),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, false),
                                    child: const Text('Cancel')),
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, true),
                                    child: const Text('Sign Out',
                                        style: TextStyle(
                                            color: AppColors.warning))),
                              ],
                            ),
                          );
                          if (confirmed == true && mounted) {
                            await context.read<AuthProvider>().signOut();
                          }
                        },
                      ),
                    ],
                  ),
                  // Avatar
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withOpacity(0.25),
                    child: Text(
                      user.name.isNotEmpty
                          ? user.name[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Name + edit icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(user.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: _showEditProfileDialog,
                        child: const Icon(Icons.edit,
                            color: Colors.white70, size: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(user.email,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12)),
                  const SizedBox(height: 12),
                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _statBadge(
                          itemProvider.myItems.length.toString(),
                          'Listings'),
                      const SizedBox(width: 24),
                      _statBadge(
                          user.rating.toStringAsFixed(1), 'Rating'),
                      const SizedBox(width: 24),
                      _statBadge(
                          requestProvider.myRequests.length.toString(),
                          'Requests'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // ── Pill Tab Buttons ─────────────────────────────────
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        _pillTab(0, 'My Products'),
                        _pillTab(1, 'Sent'),
                        _pillTab(2, 'Received'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Tab Content (IndexedStack — no constraint issues) ───────
            Expanded(
              child: IndexedStack(
                index: _selectedTab,
                sizing: StackFit.expand,
                children: [
                  // ── Tab 0: My Products ─────────────────────────────
                  itemProvider.myItems.isEmpty
                      ? _emptyState('No listings yet',
                          'Post your first item!', Icons.sell_outlined)
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.72,
                          ),
                          itemCount: itemProvider.myItems.length,
                          itemBuilder: (context, i) {
                            final item = itemProvider.myItems[i];
                            return Stack(
                              children: [
                                ItemCard(
                                  item: item,
                                  onTap: () => context.push(
                                      '/item/${item.id}',
                                      extra: item),
                                ),
                                if (!item.isSold)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: PopupMenuButton<String>(
                                      itemBuilder: (_) => [
                                        const PopupMenuItem(
                                            value: 'sold',
                                            child: Text('Mark as Sold')),
                                        const PopupMenuItem(
                                            value: 'delete',
                                            child: Text('Delete',
                                                style: TextStyle(
                                                    color: AppColors
                                                        .warning))),
                                      ],
                                      onSelected: (val) async {
                                        if (val == 'sold') {
                                          await itemProvider
                                              .markAsSold(item.id);
                                        } else if (val == 'delete') {
                                          await itemProvider
                                              .deleteItem(item.id);
                                          if (mounted) {
                                            await itemProvider
                                                .loadMyItems(user.id);
                                          }
                                        }
                                      },
                                      icon: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black
                                              .withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.more_vert,
                                            color: Colors.white, size: 16),
                                      ),
                                    ),
                                  ),
                                if (item.isSold)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.black.withOpacity(0.5),
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                      child: const Center(
                                        child: Text('SOLD',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight:
                                                    FontWeight.bold,
                                                fontSize: 18)),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),

                  // ── Tab 1: Sent Requests ────────────────────────────
                  requestProvider.myRequestsLoading
                      ? const Center(child: CircularProgressIndicator())
                      : requestProvider.myRequests.isEmpty
                          ? _emptyState('No requests yet',
                              'Browse items and request them!',
                              Icons.handshake_outlined)
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount:
                                  requestProvider.myRequests.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, i) {
                                final req =
                                    requestProvider.myRequests[i];
                                final sc = _statusColor(req.status);
                                final itemWidth = MediaQuery.of(context).size.width - 32;
                                return ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: itemWidth),
                                  child: _requestCard(
                                    isDark: isDark,
                                    imageUrl: req.itemImageUrl,
                                    title: req.itemTitle ?? 'Item',
                                    subtitle: 'Status: ${req.status}',
                                    subtitleColor: sc,
                                    badge: req.status.toUpperCase(),
                                    badgeColor: sc,
                                    onChatTap: req.status == 'accepted' && req.sellerId != null
                                        ? () => context.push('/chat/${req.sellerId}', extra: req.sellerName)
                                        : null,
                                  ),
                                );
                              },
                            ),

                  // ── Tab 2: Received Requests ────────────────────────
                  requestProvider.receivedLoading
                      ? const Center(child: CircularProgressIndicator())
                      : requestProvider.receivedRequests.isEmpty
                          ? _emptyState('No received requests',
                              'Nobody has requested your items yet.',
                              Icons.inbox_outlined)
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: requestProvider
                                  .receivedRequests.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, i) {
                                final req = requestProvider
                                    .receivedRequests[i];
                                final sc = _statusColor(req.status);
                                final itemWidth = MediaQuery.of(context).size.width - 32;
                                return ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: itemWidth),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      _requestCard(
                                        isDark: isDark,
                                        imageUrl: req.itemImageUrl,
                                        title: req.itemTitle ?? 'Item',
                                        subtitle:
                                            'By: ${req.requesterName ?? 'Unknown'}',
                                        subtitleColor: isDark
                                            ? Colors.white60
                                            : Colors.black54,
                                        badge: req.status.toUpperCase(),
                                        badgeColor: sc,
                                        onChatTap: req.status == 'accepted'
                                            ? () => context.push('/chat/${req.requesterId}', extra: req.requesterName)
                                            : null,
                                      ),
                                      if (req.status == 'pending')
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Wrap(
                                            alignment: WrapAlignment.end,
                                            spacing: 8,
                                            children: [
                                              TextButton(
                                                onPressed: () => context
                                                    .read<RequestProvider>()
                                                    .updateRequestStatus(
                                                        req.id, 'rejected'),
                                                child: const Text('Reject',
                                                    style: TextStyle(
                                                        color:
                                                            AppColors.warning)),
                                              ),
                                              ElevatedButton(
                                                onPressed: () => context
                                                    .read<RequestProvider>()
                                                    .updateRequestStatus(
                                                        req.id, 'accepted', itemId: req.itemId),
                                                style:
                                                    ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppColors.accent,
                                                  foregroundColor:
                                                      Colors.white,
                                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                                ),
                                                child:
                                                    const Text('Accept'),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Pill tab button ────────────────────────────────────────────────
  Widget _pillTab(int index, String label) {
    final selected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.primary : Colors.white,
              fontWeight:
                  selected ? FontWeight.bold : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  // ── Request card ───────────────────────────────────────────────────
  Widget _requestCard({
    required bool isDark,
    required String? imageUrl,
    required String title,
    required String subtitle,
    required Color subtitleColor,
    required String badge,
    required Color badgeColor,
    VoidCallback? onChatTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 56,
                    height: 56,
                    color: AppColors.primary.withOpacity(0.1),
                    child: const Icon(Icons.image_outlined,
                        color: AppColors.primary),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(
                        color: subtitleColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(badge,
                style: TextStyle(
                    color: badgeColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 10)),
          ),
          if (onChatTap != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onChatTap,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chat_bubble_outline,
                    color: AppColors.accent, size: 18),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return AppColors.accent;
      case 'rejected':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  Widget _statBadge(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.8), fontSize: 11)),
      ],
    );
  }

  Widget _emptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              size: 56,
              color: AppColors.textSecondaryLight.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 6),
          Text(subtitle,
              style: const TextStyle(
                  color: AppColors.textSecondaryLight, fontSize: 13)),
        ],
      ),
    );
  }
}
