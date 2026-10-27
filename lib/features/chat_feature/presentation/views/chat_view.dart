import 'package:ai_chat_bot/core/di/get_it_setup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_chat_bot/features/chat_feature/presentation/cubit/send_message_cubit.dart';
import '../widgets/chat_content_body.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SendMessageCubit>(
      create: (context) => getIt<SendMessageCubit>(),
      child: const ChatContentBody(),
    );
  }
}
