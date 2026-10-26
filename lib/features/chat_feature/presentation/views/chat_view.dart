import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_chat_bot/core/services/chat_service.dart';
import 'package:ai_chat_bot/features/chat_feature/data/repo/send_message_repository_impl.dart';
import 'package:ai_chat_bot/features/chat_feature/presentation/cubit/send_message_cubit.dart';
import '../widgets/chat_content_body.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SendMessageCubit>(
      create: (context) => SendMessageCubit(
        repository: SendMessageRepositoryImpl(
          chatService: ChatService(),
        ),
      ),
      child: const ChatContentBody(),
    );
  }
}
