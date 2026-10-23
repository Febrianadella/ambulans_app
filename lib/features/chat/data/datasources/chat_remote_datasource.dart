import '../models/chat_message_model.dart';

abstract class ChatRemoteDataSource {
  Stream<List<ChatMessageModel>> getMessagesStream(String orderId);
  Future<void> sendMessage(ChatMessageModel message);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  @override
  Stream<List<ChatMessageModel>> getMessagesStream(String orderId) async* {
    yield [
      ChatMessageModel(
        id: 'MSG-001',
        orderId: orderId,
        senderId: 'DVR-202',
        senderRole: 'sopir',
        message: 'Halo, tim medis dan ambulans sudah dalam perjalanan ke lokasi Anda.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
  }

  @override
  Future<void> sendMessage(ChatMessageModel message) async {
    // Kirim pesan ke API / Firestore
  }
}
