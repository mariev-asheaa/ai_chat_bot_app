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

  static const int _maxHistory = 20;
  static const int _keepLast = 5;

  final List<String> _history = [];
  String? _previousInteractionId;

  @override
  void resetConversation() {
    _history.clear();
    _previousInteractionId = null;
  }

  @override
  Future<Either<Failure, ChatMessageResponseModel>> sendMessage(
      ChatMessageModel message,
      ) async {
    try {
      var input = message.input;
      var prevId = _previousInteractionId;

      if (_history.length > _maxHistory) {
        final last = _history.sublist(_history.length - _keepLast);
        _history..clear()..addAll(last);

        prevId = null;
        input =
        'Previous conversation:\n${last.join('\n')}\n\nUser: ${message.input}';
      }

      final result = await chatService.sendMessage(
        ChatMessageModel(
          model: message.model,
          input: input,
          previousInteractionId: prevId,
          generationConfig: message.generationConfig,
        ),
      );

      _previousInteractionId = result.id;
      _history
        ..add('User: ${message.input}')
        ..add('Bot: ${result.outputText ?? ''}');

      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}