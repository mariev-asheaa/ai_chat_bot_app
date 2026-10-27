import 'package:ai_chat_bot/features/chat_feature/data/models/chat_message_model.dart';

class ChatHistoryManager {
  static const int maxHistory = 20;
  static const int keepLast = 5;

  final List<String> _history = [];
  String? _previousInteractionId;

  String? get previousInteractionId => _previousInteractionId;
  List<String> get history => List.unmodifiable(_history);

  void reset() {
    _history.clear();
    _previousInteractionId = null;
  }

  ChatMessageModel prepareMessage(ChatMessageModel message) {
    var input = message.input;
    var prevId = _previousInteractionId;

    if (_history.length > maxHistory) {
      final last = _history.sublist(_history.length - keepLast);
      _history
        ..clear()
        ..addAll(last);

      prevId = null;
      input =
          'Previous conversation:\n${last.join('\n')}\n\nUser: ${message.input}';
    }

    return ChatMessageModel(
      model: message.model,
      input: input,
      previousInteractionId: prevId,
      generationConfig: message.generationConfig,
    );
  }

  void addTurn({
    required String userInput,
    required String botOutput,
    String? interactionId,
  }) {
    _previousInteractionId = interactionId;
    _history
      ..add('User: $userInput')
      ..add('Bot: $botOutput');
  }
}
