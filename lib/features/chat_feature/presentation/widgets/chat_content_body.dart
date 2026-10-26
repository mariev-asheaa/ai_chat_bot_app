import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/send_message_cubit.dart';
import 'chat_app_bar.dart';
import 'chat_empty_state.dart';
import 'chat_input_field.dart';
import 'chat_message_list.dart';

class ChatContentBody extends StatefulWidget {
  const ChatContentBody({super.key});

  @override
  State<ChatContentBody> createState() => _ChatContentBodyState();
}

class _ChatContentBodyState extends State<ChatContentBody> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SendMessageCubit>();

    return BlocConsumer<SendMessageCubit, SendMessageState>(
      listener: (context, state) {
        _scrollToBottom();
      },
      builder: (context, state) {
        final messages = cubit.messages;
        final isCurrentlyLoading = state is SendMessageLoading;

        return Scaffold(
          backgroundColor: const Color(0xFF1A1B23),
          appBar: ChatAppBar(
            onClearChat:
            messages.isNotEmpty ? () => cubit.resetConversation() : null,
            onNewChat: () => cubit.resetConversation(),
          ),
          body: Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? ChatEmptyState(
                  onSuggestionSelected: (text) => cubit.sendMessage(text),
                )
                    : ChatMessageList(
                  messages: messages,
                  scrollController: _scrollController,
                ),
              ),
              ChatInputField(
                onSubmitted: (text) => cubit.sendMessage(text),
                isLoading: isCurrentlyLoading,
              ),
            ],
          ),
        );
      },
    );
  }
}
