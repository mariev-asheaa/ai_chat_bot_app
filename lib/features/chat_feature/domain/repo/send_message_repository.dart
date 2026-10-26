import 'package:dartz/dartz.dart';
import 'package:ai_chat_bot/core/errors/failure.dart';
import 'package:ai_chat_bot/features/chat_feature/data/models/chat_message_model.dart';
import 'package:ai_chat_bot/features/chat_feature/data/models/chat_message_response_model.dart';

abstract class SendMessageRepository {
  Future<Either<Failure, ChatMessageResponseModel>> sendMessage(
    ChatMessageModel message,
  );
  void resetConversation();
}

