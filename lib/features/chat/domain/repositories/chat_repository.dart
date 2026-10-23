import '../entities/chat_message_entity.dart';

abstract class ChatRepository {
  Stream<List<ChatMessageEntity>> getMessagesStream(String orderId);
  Future<void> sendMessage({
    required String orderId,
    required String senderId,
    required String senderRole,
    required String message,
  });
}
