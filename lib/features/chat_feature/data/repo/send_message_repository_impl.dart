import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:ai_chat_bot/core/errors/failure.dart';
import 'package:ai_chat_bot/core/services/chat_service.dart';
import 'package:ai_chat_bot/features/chat_feature/data/models/chat_message_model.dart';
import 'package:ai_chat_bot/features/chat_feature/data/models/chat_message_response_model.dart';
import 'package:ai_chat_bot/features/chat_feature/data/repo/chat_history_manager.dart';
import 'package:ai_chat_bot/features/chat_feature/domain/repo/send_message_repository.dart';

class SendMessageRepositoryImpl implements SendMessageRepository {
  final ChatService chatService;
  final ChatHistoryManager historyManager;

  SendMessageRepositoryImpl({
    required this.chatService,
    ChatHistoryManager? historyManager,
  }) : historyManager = historyManager ?? ChatHistoryManager();

  @override
  void resetConversation() {
    historyManager.reset();
  }

  @override
  Future<Either<Failure, ChatMessageResponseModel>> sendMessage(
    ChatMessageModel message,
  ) async {
    try {
      final preparedMessage = historyManager.prepareMessage(message);

      final result = await chatService.sendMessage(preparedMessage);

      historyManager.addTurn(
        userInput: message.input,
        botOutput: result.outputText ?? '',
        interactionId: result.id,
      );

      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
