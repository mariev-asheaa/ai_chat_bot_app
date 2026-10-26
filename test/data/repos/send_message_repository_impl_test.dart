import 'package:ai_chat_bot/core/services/chat_service.dart';
import 'package:ai_chat_bot/features/chat_feature/data/models/chat_message_model.dart';
import 'package:ai_chat_bot/features/chat_feature/data/models/chat_message_response_model.dart';
import 'package:ai_chat_bot/features/chat_feature/data/repo/send_message_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';


class MockChatService extends Mock implements ChatService {}

ChatMessageResponseModel fakeResponse() => ChatMessageResponseModel(
  id: 'id1',
  steps: [
    Step(
      type: 'model_output',
      content: [StepContent(text: 'reply', type: 'text')],
    ),
  ],
);

void main() {
  late MockChatService mockChatService;
  late SendMessageRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(ChatMessageModel(input: ''));
  });

  setUp(() {
    mockChatService = MockChatService();
    repo = SendMessageRepositoryImpl(chatService: mockChatService);

    when(() => mockChatService.sendMessage(any()))
        .thenAnswer((_) async => fakeResponse());
  });

  // بيبعت n رسالة ورا بعض: m0, m1, m2, ...
  Future<void> sendMessages(int n) async {
    for (var i = 0; i < n; i++) {
      await repo.sendMessage(ChatMessageModel(input: 'm$i'));
    }
  }

  // بيرجع آخر ChatMessageModel وصل للـ service
  ChatMessageModel lastSent() => verify(
        () => mockChatService.sendMessage(captureAny()),
  ).captured.last as ChatMessageModel;


  group('Chat history length validation logic in send message', (){
    test('أول رسالة تتبعت من غير previousInteractionId', () async {
      await sendMessages(1);

      final sent = lastSent();
      expect(sent.previousInteractionId, isNull);
      expect(sent.input, 'm0');
    });

    test('الرسالة اللي بعدها تتبعت بالـ id اللي رجع قبلها', () async {
      await sendMessages(2);

      expect(lastSent().previousInteractionId, 'id1');
    });

    test('لو الهيستوري 20 أو أقل مفيش ريسيت', () async {
      await sendMessages(11); // الرسالة 11 بتتبعت والهيستوري = 20

      final sent = lastSent();
      expect(sent.previousInteractionId, 'id1');
      expect(sent.input, 'm10');
    });

    test('لو الهيستوري أكتر من 20 يبدأ سلسلة جديدة بآخر 5 بس', () async {
      await sendMessages(12); // الرسالة 12 بتتبعت والهيستوري = 22

      final sent = lastSent();
      expect(sent.previousInteractionId, isNull);
      expect(sent.input, contains('User: m11')); // الرسالة الجديدة
      expect(sent.input, contains('User: m10')); // من آخر 5
      expect(sent.input, contains('User: m9')); // من آخر 5
      expect(sent.input, isNot(contains('User: m8'))); // قديمة، اتشالت
    });

    test('بعد الريسيت الرسالة اللي بعدها مفيهاش ريسيت تاني', () async {
      await sendMessages(13);

      final sent = lastSent();
      expect(sent.previousInteractionId, 'id1');
      expect(sent.input, 'm12');
    });

    test('resetConversation يرجّع كل حاجة للبداية', () async {
      await sendMessages(3);
      repo.resetConversation();
      await repo.sendMessage(ChatMessageModel(input: 'fresh'));

      final sent = lastSent();
      expect(sent.previousInteractionId, isNull);
      expect(sent.input, 'fresh');
    });
  });

}