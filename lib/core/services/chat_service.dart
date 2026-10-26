import 'package:ai_chat_bot/core/services/api_client.dart';
import 'package:ai_chat_bot/features/chat_feature/data/models/chat_message_model.dart';
import 'package:ai_chat_bot/features/chat_feature/data/models/chat_message_response_model.dart';
import 'package:dio/dio.dart';

import '../utiles/keys.dart';

class ChatService {
  final ApiClient _apiClient;
  final String apiKey;

  ChatService({ApiClient? apiClient, this.apiKey = Keys.apiKey})
      : _apiClient = apiClient ?? ApiClient();

  Future<ChatMessageResponseModel> sendMessage(ChatMessageModel request) async {
    late Exception exception;
    for(int i=0;i<3;i++) {
      try {
        final response = await _apiClient.postRequest(
          'https://generativelanguage.googleapis.com/v1beta/interactions',
          {
            'Content-Type': 'application/json',
            'x-goog-api-key': apiKey,
          },
          {

          },
          request.toJson(),
        );
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return ChatMessageResponseModel.fromJson(data);
        } else if (data != null) {
          return ChatMessageResponseModel.fromJson(
            Map<String, dynamic>.from(data as Map),
          );
        } else {
          throw Exception('Failed to receive response from Gemini service.');
        }
      }
      on DioException catch (e) {
        exception=e;
        if(!isRetriableDioException(e)){
          rethrow;
        }
        //gap between retries
        if(i<2){
          Future.delayed(Duration(seconds: i+1));
        }
      }

    }
    throw exception;
  }

  bool isRetriableDioException(DioException e) {
      switch(e.type){
     case DioExceptionType.connectionTimeout:
     case DioExceptionType.sendTimeout:
     case DioExceptionType.receiveTimeout:
     case DioExceptionType.connectionError:
       return true;
     case DioExceptionType.badResponse:
     case DioExceptionType.badCertificate:
     case DioExceptionType.cancel:
     case DioExceptionType.unknown:
         return false;
        case DioExceptionType.transformTimeout:
          throw UnimplementedError();
   }
  }
}
