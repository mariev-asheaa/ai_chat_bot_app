import 'package:ai_chat_bot/core/services/api_client.dart';
import 'package:ai_chat_bot/features/chat_feature/data/models/chat_message_model.dart';
import 'package:ai_chat_bot/features/chat_feature/data/models/chat_message_response_model.dart';

import '../utiles/keys.dart';

class ChatService {
  final ApiClient _apiClient;
  final String apiKey;

  ChatService({ApiClient? apiClient, this.apiKey = Keys.apiKey})
      : _apiClient = apiClient ?? ApiClient();

  Future<ChatMessageResponseModel> sendMessage(ChatMessageModel request) async {
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
}
