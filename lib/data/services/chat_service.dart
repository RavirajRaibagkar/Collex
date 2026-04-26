import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message_model.dart';
import '../../core/constants/app_constants.dart';

class ChatService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Stream<List<MessageModel>> getMessages(String userId, String otherId) {
    return _supabase
        .from(AppConstants.messagesTable)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .map((data) {
          return (data as List)
              .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
              .where((msg) =>
                  (msg.senderId == userId && msg.receiverId == otherId) ||
                  (msg.senderId == otherId && msg.receiverId == userId))
              .toList();
        });
  }

  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String message,
  }) async {
    await _supabase.from(AppConstants.messagesTable).insert({
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
    });
  }

  Future<List<Map<String, dynamic>>> getConversations(String userId) async {
    // Get all messages involving the user
    final data = await _supabase
        .from(AppConstants.messagesTable)
        .select('*, sender:sender_id(id, name, avatar_url), receiver:receiver_id(id, name, avatar_url)')
        .or('sender_id.eq.$userId,receiver_id.eq.$userId')
        .order('created_at', ascending: false);

    // Extract unique conversations
    final Map<String, Map<String, dynamic>> conversations = {};
    for (final msg in data as List) {
      final Map<String, dynamic> m = msg as Map<String, dynamic>;
      final otherId = m['sender_id'] == userId
          ? m['receiver_id'] as String
          : m['sender_id'] as String;

      if (!conversations.containsKey(otherId)) {
        final other = m['sender_id'] == userId ? m['receiver'] : m['sender'];
        conversations[otherId] = {
          'other_user': other,
          'last_message': m['message'],
          'created_at': m['created_at'],
          'other_id': otherId,
        };
      }
    }

    return conversations.values.toList();
  }
}
