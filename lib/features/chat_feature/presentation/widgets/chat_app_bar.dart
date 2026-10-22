import 'package:flutter/material.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onClearChat;
  final VoidCallback? onNewChat;

  const ChatAppBar({
    super.key,
    this.onClearChat,
    this.onNewChat,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF1E1E2C),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.add_comment_outlined, color: Colors.white70),
        tooltip: 'New Chat',
        onPressed: onNewChat,
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF10A37F).withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFF10A37F),
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Gemini',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '3.6 Flash',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: Colors.white70),
          tooltip: 'Clear Conversation',
          onPressed: onClearChat,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
