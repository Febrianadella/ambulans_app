import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/chat_message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<ChatMessageEntity>> getMessagesStream(String orderId) {
    return remoteDataSource.getMessagesStream(orderId);
  }

  @override
  Future<void> sendMessage({
    required String orderId,
    required String senderId,
    required String senderRole,
    required String message,
  }) async {
    final chatModel = ChatMessageModel(
      id: 'MSG-${DateTime.now().millisecondsSinceEpoch}',
      orderId: orderId,
      senderId: senderId,
      senderRole: senderRole,
      message: message,
      timestamp: DateTime.now(),
    );
    await remoteDataSource.sendMessage(chatModel);
  }
}
