import 'package:flat_up/Controller/chat_controller.dart';
import 'package:flat_up/constants/elementConstant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConversationsPage extends StatefulWidget {
  static const String routeName = '/conversations';

  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  final ChatController _controller = Get.find<ChatController>();

  @override
  void initState() {
    super.initState();

    // تحميل المحادثات مرة واحدة فقط
    if (_controller.conversations.isEmpty) {
      _controller.loadConversations(refresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('المحادثات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.loadConversations(refresh: true),
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoadingConversations.value &&
            _controller.conversations.isEmpty) {
          return Center(child: Image.asset(kLogoApp, width: 120, height: 100));
        }

        if (_controller.conversations.isEmpty) {
          return Center(
            child: Column(
              children: [
                Text('لا توجد محادثات'),
                Icon(Icons.chat_bubble_outline_outlined, color: colors.primary),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: _controller.conversations.length,
          itemBuilder: (context, index) {
            final conversation = _controller.conversations[index];

            // عدد الرسائل غير المقروءة
            final unreadCount = conversation.unreadCount(_controller.userId);

            // معلومات الطرف الآخر
            final otherUser = conversation.getOtherUser(_controller.userId);
            final otherUserName = otherUser != null
                ? '${otherUser.firstName ?? ''} ${otherUser.lastName ?? ''}'
                : 'مستخدم';
            final otherUserAvatar = otherUser?.profileImageUrl ?? '';

            // آخر رسالة
            final lastMessageText = conversation.messages.isNotEmpty
                ? conversation.messages.last.message
                : 'بدون رسائل';

            // تنسيق الوقت
            String timeText = '';
            try {
              final diff = DateTime.now().difference(
                conversation.lastMessageAt,
              );
              if (diff.inMinutes < 60) {
                timeText = '${diff.inMinutes} دقيقة';
              } else if (diff.inHours < 24) {
                timeText = '${diff.inHours} ساعة';
              } else if (diff.inDays < 7) {
                timeText = '${diff.inDays} يوم';
              } else {
                final dt = conversation.lastMessageAt;
                timeText = '${dt.day}/${dt.month}';
              }
            } catch (_) {}

            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: Stack(
                  children: [
                    CircleAvatar(
                      backgroundImage: otherUserAvatar.isNotEmpty
                          ? NetworkImage(otherUserAvatar)
                          : null,
                      child: otherUserAvatar.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text(
                  otherUserName,
                  style: TextStyle(
                    fontWeight: unreadCount > 0
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  lastMessageText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: timeText.isNotEmpty
                    ? Text(
                        'منذ $timeText',
                        style: const TextStyle(fontSize: 12),
                      )
                    : null,
                onTap: () {
                  // تعليم الرسائل كمقروءة عند فتح المحادثة
                  conversation.markAllAsRead(_controller.userId);
                  Get.toNamed(
                    '/chat',
                    arguments: {
                      'conversationId': conversation.id,
                      'otherUserName': otherUserName,
                      'avatar': otherUserAvatar,
                    },
                  );
                },
              ),
            );
          },
        );
      }),
    );
  }
}
