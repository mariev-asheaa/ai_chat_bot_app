import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_chat_bot/features/chat_feature/data/models/chat_message_model.dart';
import 'package:ai_chat_bot/features/chat_feature/data/models/chat_message_response_model.dart';
import 'package:ai_chat_bot/features/chat_feature/domain/entities/ui_chat_message.dart';
import 'package:ai_chat_bot/features/chat_feature/domain/repo/send_message_repository.dart';

part 'send_message_state.dart';

class SendMessageCubit extends Cubit<SendMessageState> {
  final SendMessageRepository repository;

  SendMessageCubit({required this.repository}) : super(SendMessageInitial());

  final List<UiChatMessage> _messages = [];

  List<UiChatMessage> get messages => List.unmodifiable(_messages);

  Future<void> sendMessage(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    final userMessageId = DateTime.now().millisecondsSinceEpoch.toString();
    final botMessageId = '${userMessageId}_bot';

    final userMsg = UiChatMessage(
      id: userMessageId,
      text: trimmedText,
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

    _messages.add(userMsg);
    _messages.add(loadingBotMsg);

    emit(SendMessageLoading());

    final result = await repository.sendMessage(
      ChatMessageModel(input: trimmedText),
    );

    result.fold(
      (failure) {
        final index = _messages.indexWhere((m) => m.id == botMessageId);
        if (index != -1) {
          _messages[index] = _messages[index].copyWith(
            text: 'Error: ${failure.errMessage}',
            isLoading: false,
            isError: true,
            failedInput: trimmedText,
          );
        }
        emit(SendMessageError(message: failure.errMessage));
      },
      (response) {
        final index = _messages.indexWhere((m) => m.id == botMessageId);
        final responseText =
            response.outputText ?? 'No response content available.';
        if (index != -1) {
          _messages[index] = _messages[index].copyWith(
            text: responseText,
            isLoading: false,
            isError: false,
          );
        }
        emit(SendMessageSuccess(response: response));
      },
    );
  }
  Future<void> retryMessage(UiChatMessage errorMessage) async {
    final inputToRetry = errorMessage.failedInput;
    if (inputToRetry != null && inputToRetry.isNotEmpty) {
      _messages.removeWhere((m) => m.id == errorMessage.id);
      await sendMessage(inputToRetry);
    }
  }
  void resetConversation() {
    _messages.clear();
    repository.resetConversation();
    emit(SendMessageInitial());
  }
}
