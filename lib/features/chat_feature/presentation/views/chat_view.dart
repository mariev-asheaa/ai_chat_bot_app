import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_chat_bot/core/services/chat_service.dart';
import  'package:ai_chat_bot/features/chat_feature/domain/entities/ui_chat_message.dart';
import 'package:ai_chat_bot/features/chat_feature/presentation/cubit/send_message_cubit.dart';
import 'package:ai_chat_bot/features/chat_feature/presentation/widgets/chat_app_bar.dart';
import 'package:ai_chat_bot/features/chat_feature/presentation/widgets/chat_empty_state.dart';
import 'package:ai_chat_bot/features/chat_feature/presentation/widgets/chat_input_field.dart';
import 'package:ai_chat_bot/features/chat_feature/presentation/widgets/chat_message_list.dart';

import '../../data/repo/send_message_repository_impl.dart';

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
      child: const ChatScreenContent(),
    );
  }
}

class ChatScreenContent extends StatefulWidget {
  const ChatScreenContent({super.key});

  @override
  State<ChatScreenContent> createState() => _ChatScreenContentState();
}

class _ChatScreenContentState extends State<ChatScreenContent> {
  final List<UiChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  String? _previousInteractionId;
  String? _loadingBotMessageId;

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

  void _handleSendMessage(String text) {
    if (text.trim().isEmpty) return;

    final userMessageId = DateTime.now().millisecondsSinceEpoch.toString();
    final botMessageId = '${userMessageId}_bot';

    final userMsg = UiChatMessage(
      id: userMessageId,
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    final loadingBotMsg = UiChatMessage(
      id: botMessageId,
      text: '',
      sender: MessageSender.bot,
      timestamp: DateTime.now(),
      isLoading: true,
    );

    setState(() {
      _messages.add(userMsg);
      _messages.add(loadingBotMsg);
      _loadingBotMessageId = botMessageId;
    });

    _scrollToBottom();

    context.read<SendMessageCubit>().sendInput(
          text,
          previousInteractionId: _previousInteractionId,
        );
  }

  void _handleClearChat() {
    setState(() {
      _messages.clear();
      _previousInteractionId = null;
      _loadingBotMessageId = null;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1B23),
      appBar: ChatAppBar(
        onClearChat: _messages.isNotEmpty ? _handleClearChat : null,
        onNewChat: _handleClearChat,
      ),
      body: BlocConsumer<SendMessageCubit, SendMessageState>(
        listener: (context, state) {
          if (state is SendMessageSuccess) {
            final responseText =
                state.response.outputText ?? 'No response content available.';
            setState(() {
              if (_loadingBotMessageId != null) {
                final index = _messages
                    .indexWhere((m) => m.id == _loadingBotMessageId);
                if (index != -1) {
                  _messages[index] = _messages[index].copyWith(
                    text: responseText,
                    isLoading: false,
                  );
                }
              }
              if (state.response.id != null &&
                  state.response.id!.isNotEmpty) {
                _previousInteractionId = state.response.id;
              }
              _loadingBotMessageId = null;
            });
            _scrollToBottom();
          } else if (state is SendMessageError) {
            setState(() {
              if (_loadingBotMessageId != null) {
                final index = _messages
                    .indexWhere((m) => m.id == _loadingBotMessageId);
                if (index != -1) {
                  _messages[index] = _messages[index].copyWith(
                    text: 'Error: ${state.message}',
                    isLoading: false,
                  );
                }
              }
              _loadingBotMessageId = null;
            });
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          final isCurrentlyLoading = state is SendMessageLoading;

          return Column(
            children: [
              Expanded(
                child: _messages.isEmpty
                    ? ChatEmptyState(
                        onSuggestionSelected: _handleSendMessage,
                      )
                    : ChatMessageList(
                        messages: _messages,
                        scrollController: _scrollController,
                      ),
              ),
              ChatInputField(
                onSubmitted: _handleSendMessage,
                isLoading: isCurrentlyLoading,
              ),
            ],
          );
        },
      ),
    );
  }
}
