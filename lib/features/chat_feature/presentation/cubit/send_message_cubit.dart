import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_chat_bot/features/chat_feature/data/models/chat_message_model.dart';
import 'package:ai_chat_bot/features/chat_feature/data/models/chat_message_response_model.dart';
import 'package:ai_chat_bot/features/chat_feature/domain/repo/send_message_repository.dart';

part 'send_message_state.dart';

class SendMessageCubit extends Cubit<SendMessageState> {
  final SendMessageRepository repository;

  SendMessageCubit({required this.repository}) : super(SendMessageInitial());

  Future<void> sendMessage(ChatMessageModel message) async {
    emit(SendMessageLoading());
    try {
      final response = await repository.sendMessage(message);
      response.fold(
        (failure) => emit(SendMessageError(message: failure.errMessage)),
        (response) => emit(SendMessageSuccess(response: response)),
      );
    } catch (e) {
      emit(SendMessageError(message: e.toString()));
    }
  }

  Future<void> sendInput(
    String input, {
    String? previousInteractionId,
    String model = 'gemini-3.6-flash',
  }) async {
    final message = ChatMessageModel(
      input: input,
      previousInteractionId: previousInteractionId,
      model: model,
    );
    await sendMessage(message);
  }
}
