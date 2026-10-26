import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class ChatRoomPage extends StatefulWidget {
  final String orderId;
  final String? driverName;
  final String? driverPlate;
  final bool isFromDriver;
  final String? patientName;

  const ChatRoomPage({
    super.key,
    required this.orderId,
    this.driverName,
    this.driverPlate,
    this.isFromDriver = false,
    this.patientName,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Memori percakapan berbasis orderId agar pesan tetap tersimpan saat navigasi
  static final Map<String, List<Map<String, dynamic>>> _messagesByOrder = {};

  List<Map<String, dynamic>> get _messages {
    final cleanId = widget.orderId.replaceAll('#', '').trim();
    if (!_messagesByOrder.containsKey(cleanId)) {
      _messagesByOrder[cleanId] = [
        {
          'sender': widget.driverName != null
              ? '${widget.driverName} (Sopir)'
              : 'Sopir Ambulans',
          'senderRole': 'sopir',
          'message':
              'Halo, kami sedang menuju lokasi Anda dengan sirene aktif.',
          'time': '08:31 WIB',
        },
        {
          'sender': widget.patientName ?? 'Pengguna',
          'senderRole': 'pengguna',
          'message': 'Baik pak, kami menunggu di depan gerbang utama rumah.',
          'time': '08:32 WIB',
        },
        {
          'sender': widget.driverName != null
              ? '${widget.driverName} (Sopir)'
              : 'Sopir Ambulans',
          'senderRole': 'sopir',
          'message': 'Siap, estimasi tiba dalam 5-7 menit. Mohon pastikan jalan masuk tidak terhalang kendaraan lain.',
          'time': '08:33 WIB',
        },
      ];
    }
    return _messagesByOrder[cleanId]!;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();

    if (text.isEmpty) return;

    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB';
    final isDriver = widget.isFromDriver;
    final senderName = isDriver
        ? (widget.driverName != null
              ? '${widget.driverName} (Sopir)'
              : 'Sopir Ambulans')
        : (widget.patientName ?? 'Pengguna');
    final senderRole = isDriver ? 'sopir' : 'pengguna';

    setState(() {
      _messages.add({
        'sender': senderName,
        'senderRole': senderRole,
        'message': text,
        'time': timeStr,
      });
    });

    _messageController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget titleWidget;
    if (widget.isFromDriver) {
      final name = widget.patientName ?? 'Budi Pratama';
      titleWidget = Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'P',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Pemesan Ambulans • #${widget.orderId}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      );
    } else if (widget.driverName != null) {
      titleWidget = Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              widget.driverName!.isNotEmpty
                  ? widget.driverName!.substring(0, 1).toUpperCase()
                  : 'S',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.driverName!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${widget.driverPlate ?? "Ambulans"} • #${widget.orderId}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      titleWidget = Text('Chat Tim Ambulans #${widget.orderId}');
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        title: titleWidget,
        actions: [
          IconButton(
            tooltip: 'Panggilan Darurat',
            icon: const Icon(Icons.call, color: AppColors.primary),
            onPressed: () {
              final target = widget.isFromDriver
                  ? (widget.patientName ?? 'Pemesan')
                  : (widget.driverName ?? 'Sopir Ambulans');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Menghubungi $target (+62 812-9876-5432)...'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.primaryLight.withValues(alpha: 0.5),
            child: Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Percakapan terhubung langsung untuk pesanan ambulans #${widget.orderId}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final senderRole =
                    message['senderRole'] as String? ??
                    ((message['sender'] as String).toLowerCase().contains(
                          'sopir',
                        )
                        ? 'sopir'
                        : 'pengguna');
                final isMe = widget.isFromDriver
                    ? (senderRole == 'sopir')
                    : (senderRole == 'pengguna');
                final time = message['time'] as String? ?? '';

                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(14),
                        topRight: const Radius.circular(14),
                        bottomLeft: Radius.circular(isMe ? 14 : 2),
                        bottomRight: Radius.circular(isMe ? 2 : 14),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: isMe ? null : Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (!isMe)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text(
                              message['sender'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        Text(
                          message['message'] as String,
                          style: TextStyle(
                            color: isMe ? Colors.white : AppColors.textPrimary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 9.5,
                            color: isMe
                                ? Colors.white.withValues(alpha: 0.8)
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Ketik pesan untuk tim sopir...',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 20,
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
