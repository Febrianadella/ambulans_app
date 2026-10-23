import '../../domain/entities/chat_message_entity.dart';

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.orderId,
    required super.senderId,
    required super.senderRole,
    required super.message,
    required super.timestamp,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String? ?? '',
      orderId: json['orderId'] as String? ?? json['order_id'] as String? ?? '',
      senderId:
          json['senderId'] as String? ?? json['sender_id'] as String? ?? '',
      senderRole:
          json['senderRole'] as String? ?? json['sender_role'] as String? ?? '',
      message: json['message'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'senderId': senderId,
      'senderRole': senderRole,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
