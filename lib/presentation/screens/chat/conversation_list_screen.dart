import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/chat_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConversationListScreen extends StatefulWidget {
  const ConversationListScreen({super.key});

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  final _chatService = ChatService();
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    try {
      final convos = await _chatService.getConversations(user.id);
      if (mounted) {
        setState(() {
          _conversations = convos;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_conversations.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline,
                  size: 64,
                  color: AppColors.textSecondaryLight.withOpacity(0.4)),
              const SizedBox(height: 16),
              Text('No conversations yet',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('Browse items and start chatting!',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _conversations.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 76),
        itemBuilder: (context, i) {
          final convo = _conversations[i];
          final other = convo['other_user'] as Map<String, dynamic>?;
          final otherName = other?['name'] as String? ?? 'Unknown';
          final otherId = convo['other_id'] as String;
          final lastMsg = convo['last_message'] as String? ?? '';
          final createdAt = convo['created_at'] as String?;

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            leading: CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primary.withOpacity(0.15),
              child: Text(
                otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            title: Text(otherName,
                style: Theme.of(context).textTheme.titleMedium),
            subtitle: Text(
              lastMsg,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            trailing: createdAt != null
                ? Text(
                    timeago.format(DateTime.parse(createdAt)),
                    style: Theme.of(context).textTheme.labelSmall,
                  )
                : null,
            onTap: () => context.push('/chat/$otherId', extra: otherName),
          );
        },
      ),
    );
  }
}
