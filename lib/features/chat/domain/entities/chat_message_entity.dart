class ChatMessageEntity {
  final String id;
  final String orderId;
  final String senderId;
  final String senderRole;
  final String message;
  final DateTime timestamp;

  const ChatMessageEntity({
    required this.id,
    required this.orderId,
    required this.senderId,
    required this.senderRole,
    required this.message,
    required this.timestamp,
  });
}
