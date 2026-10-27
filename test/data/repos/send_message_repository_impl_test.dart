import 'package:ai_chat_bot/features/chat_feature/data/models/chat_message_model.dart';
import 'package:ai_chat_bot/features/chat_feature/data/repo/chat_history_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ChatHistoryManager historyManager;

  setUp(() {
    historyManager = ChatHistoryManager();
  });

  // simulates sending n turns through history manager directly
  void sendTurns(int n) {
    for (var i = 0; i < n; i++) {
      historyManager.prepareMessage(ChatMessageModel(input: 'm$i'));
      historyManager.addTurn(
        userInput: 'm$i',
        botOutput: 'reply',
        interactionId: 'id1',
      );
    }
  }

  group('Chat history length validation logic in send message', () {
    test('أول رسالة تتبعت من غير previousInteractionId', () {
      final sent = historyManager.prepareMessage(ChatMessageModel(input: 'm0'));

      expect(sent.previousInteractionId, isNull);
      expect(sent.input, 'm0');
    });

    test('الرسالة اللي بعدها تتبعت بالـ id اللي رجع قبلها', () {
      sendTurns(1);

      final sent = historyManager.prepareMessage(ChatMessageModel(input: 'm1'));

      expect(sent.previousInteractionId, 'id1');
    });

    test('لو الهيستوري 20 أو أقل مفيش ريسيت', () {
      sendTurns(10); // الرسالة 11 بتتبعت والهيستوري = 20 (10 turns)

      final sent = historyManager.prepareMessage(ChatMessageModel(input: 'm10'));

      expect(sent.previousInteractionId, 'id1');
      expect(sent.input, 'm10');
    });

    test('لو الهيستوري أكتر من 20 يبدأ سلسلة جديدة بآخر 5 بس', () {
      sendTurns(11); // الرسالة 12 بتتبعت والهيستوري = 22 (11 turns)

      final sent = historyManager.prepareMessage(ChatMessageModel(input: 'm11'));

      expect(sent.previousInteractionId, isNull);
      expect(sent.input, contains('User: m11')); // الرسالة الجديدة
      expect(sent.input, contains('User: m10')); // من آخر 5
      expect(sent.input, contains('User: m9')); // من آخر 5
      expect(sent.input, isNot(contains('User: m8'))); // قديمة، اتشالت
    });

    test('بعد الريسيت الرسالة اللي بعدها مفيهاش ريسيت تاني', () {
      sendTurns(12);

      final sent = historyManager.prepareMessage(ChatMessageModel(input: 'm12'));

      expect(sent.previousInteractionId, 'id1');
      expect(sent.input, 'm12');
    });

    test('resetConversation يرجّع كل حاجة للبداية', () {
      sendTurns(3);
      historyManager.reset();

      final sent = historyManager.prepareMessage(ChatMessageModel(input: 'fresh'));

      expect(sent.previousInteractionId, isNull);
      expect(sent.input, 'fresh');
    });
  });
}
