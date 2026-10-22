import 'package:flutter/material.dart';
import 'package:ai_chat_bot/features/chat_feature/presentation/views/chat_view.dart';

void main() {
  runApp(const AiChatBot());
}

class AiChatBot extends StatelessWidget {
  const AiChatBot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A1B23),
        primaryColor: const Color(0xFF10A37F),
      ),
      home: const ChatView(),
    );
  }
}
