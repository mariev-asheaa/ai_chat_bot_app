import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:ai_chat_bot/features/chat_feature/domain/entities/ui_chat_message.dart';
import 'package:ai_chat_bot/features/chat_feature/presentation/widgets/chat_typing_indicator.dart';

import 'failure_bubble.dart';

class ChatMessageBubble extends StatelessWidget {
  final UiChatMessage message;
  final VoidCallback? onRetry;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.onRetry,
  });

  bool get isUser => message.sender == MessageSender.user;

  @override
  Widget build(BuildContext context) {
    if (message.isError) {
      return FailureBubble(message: message, formatTime: _formatTime,onRetry: onRetry,);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              key: const ValueKey('AI Response'),
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF10A37F),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? const Color(0xFF10A37F)
                        : const Color(0xFF2A2B36),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: isUser
                          ? const Radius.circular(18)
                          : const Radius.circular(4),
                      bottomRight: isUser
                          ? const Radius.circular(4)
                          : const Radius.circular(18),
                    ),
                    border: Border.all(
                      color: isUser
                          ? Colors.transparent
                          : Colors.white.withAlpha(12),
                      width: 1,
                    ),
                  ),
                  child: message.isLoading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: ChatTypingIndicator(),
                        )
                      : MarkdownBody(
                          data: message.text,
                          styleSheet:
                              MarkdownStyleSheet.fromTheme(Theme.of(context))
                                  .copyWith(
                            p: TextStyle(
                              color: isUser
                                  ? Colors.white
                                  : const Color(0xFFECECF1),
                              fontSize: 15,
                              height: 1.4,
                            ),
                            strong: TextStyle(
                              color: isUser
                                  ? Colors.white
                                  : const Color(0xFFECECF1),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              height: 1.4,
                            ),
                            listBullet: TextStyle(
                              color: isUser
                                  ? Colors.white
                                  : const Color(0xFFECECF1),
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                        ),
                ),
                if (!message.isLoading) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          color: Colors.white.withAlpha(90),
                          fontSize: 10,
                        ),
                      ),
                      if (!isUser && message.text.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(text: message.text),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Copied to clipboard'),
                                duration: Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Icon(
                            Icons.copy_rounded,
                            size: 13,
                            color: Colors.white.withAlpha(120),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 10),
            Container(
              key: const ValueKey('User Input'),
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF3E3F4C),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
