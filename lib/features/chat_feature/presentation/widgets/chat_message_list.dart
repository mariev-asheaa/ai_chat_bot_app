import 'package:flutter/material.dart';
import 'package:ai_chat_bot/features/chat_feature/domain/entities/ui_chat_message.dart';
import 'package:ai_chat_bot/features/chat_feature/presentation/widgets/chat_message_bubble.dart';

class ChatMessageList extends StatelessWidget {
  final List<UiChatMessage> messages;
  final ScrollController scrollController;

  const ChatMessageList({
    super.key,
    required this.messages,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return ChatMessageBubble(
          key: ValueKey(message.id),
          message: message,
        );
      },
    );
  }
}
