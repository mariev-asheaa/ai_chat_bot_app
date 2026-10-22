import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:ai_chat_bot/core/errors/failure.dart';
import 'package:ai_chat_bot/core/services/chat_service.dart';
import 'package:ai_chat_bot/features/chat_feature/data/models/chat_message_model.dart';
import 'package:ai_chat_bot/features/chat_feature/data/models/chat_message_response_model.dart';
import 'package:ai_chat_bot/features/chat_feature/domain/repo/send_message_repository.dart';

class SendMessageRepositoryImpl implements SendMessageRepository {
  final ChatService chatService;

  SendMessageRepositoryImpl({required this.chatService});

  @override
  Future<Either<Failure, ChatMessageResponseModel>> sendMessage(
    ChatMessageModel message,
  ) async {
    try {
      final result = await chatService.sendMessage(message);
      return Right<Failure, ChatMessageResponseModel>(result);
    } on DioException catch (e) {
      return Left<Failure, ChatMessageResponseModel>(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left<Failure, ChatMessageResponseModel>(ServerFailure(e.toString()));
    }
  }
}
