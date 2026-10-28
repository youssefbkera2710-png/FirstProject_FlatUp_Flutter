import 'package:flat_up/Controller/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatPage extends StatefulWidget {
  static const String routeName = '/chat';

  final int? conversationId;
  final String? otherUserName;
  final String? avatar;

  const ChatPage({
    super.key,
    required this.conversationId,
    this.otherUserName,
    this.avatar,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatController _controller = Get.find<ChatController>();
  final TextEditingController _textController = TextEditingController();

  late final int conversationId;
  late final String otherUserName;
  late final String avatar;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments as Map<String, dynamic>?;

    conversationId = args?['conversationId'] ?? 0;
    otherUserName = args?['nameLandllord'] ?? 'مستخدم';
    avatar = args?['pictureAvatar'] ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.openChat(conversationId);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  (widget.avatar != null && widget.avatar!.isNotEmpty)
                  ? NetworkImage(widget.avatar!)
                  : null,
              child: (widget.avatar == null || widget.avatar!.isEmpty)
                  ? const Icon(Icons.person)
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.otherUserName ?? 'محادثة'),
                Obx(
                  () => _controller.otherUserTyping.value
                      ? const Text(
                          'يكتب الآن...',
                          style: TextStyle(color: Colors.green),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (_controller.isLoadingMessages.value &&
                  _controller.messages.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_controller.messages.isEmpty) {
                return const Center(child: Text('ابدأ المحادثة'));
              }

              return ListView.builder(
                reverse: true,
                controller: _controller.messagesScroll,
                padding: const EdgeInsets.all(16),
                itemCount: _controller.messages.length,
                itemBuilder: (context, index) {
                  final message = _controller.messages[index];
                  final isMe = message.userId == _controller.userId;

                  return Align(
                    alignment: isMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blue : Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        message.message,
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالة...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Obx(
                  () => _controller.isSending.value
                      ? const CircularProgressIndicator()
                      : IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _sendMessage,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      _controller.sendMessage(text);
      _textController.clear();
    }
  }
}
