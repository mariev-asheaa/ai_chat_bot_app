import 'dart:async';
import 'package:ai_chat_bot/core/di/get_it_setup.dart';
import 'package:ai_chat_bot/core/errors/failure.dart';
import 'package:ai_chat_bot/features/chat_feature/data/models/chat_message_model.dart';
import 'package:ai_chat_bot/features/chat_feature/data/models/chat_message_response_model.dart';
import 'package:ai_chat_bot/features/chat_feature/domain/repo/send_message_repository.dart';
import 'package:ai_chat_bot/features/chat_feature/presentation/cubit/send_message_cubit.dart';
import 'package:ai_chat_bot/features/chat_feature/presentation/views/chat_view.dart';
import 'package:ai_chat_bot/features/chat_feature/presentation/widgets/chat_typing_indicator.dart';
import 'package:ai_chat_bot/features/chat_feature/presentation/widgets/failure_bubble.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSendMessageRepository extends Mock implements SendMessageRepository{}

FutureOr<Either<Failure, ChatMessageResponseModel>> getChatMessageModel(){
  return Right(ChatMessageResponseModel());
}
void main(){
late MockSendMessageRepository mockSendMessageRepository;

setUpAll(() {
  registerFallbackValue(ChatMessageModel(input: ''));
});

setUp(()
async{
  mockSendMessageRepository=MockSendMessageRepository();
 await getIt.reset();
getIt.registerSingleton<SendMessageRepository>(mockSendMessageRepository);
getIt.registerFactory<SendMessageCubit>(()=>SendMessageCubit(repository: getIt<SendMessageRepository>()));
});

group('Send Message Flow', (){

  testWidgets('Loading Indicator On Send Message', (tester)async{
    when(()=>mockSendMessageRepository.sendMessage(any())).
    thenAnswer((_)async{
      return Future.delayed(const Duration(seconds: 1),(){
        return getChatMessageModel();
      });
    });

    await tester.pumpWidget(const MaterialApp(home: ChatView()));
    await tester.pumpAndSettle(); // build frames to update the ui
    var textField= find.byKey(const Key('chat_input_field'));
    await tester.enterText(textField, 'Hello');
    await tester.pumpAndSettle();
   var sendButton=find.byIcon(Icons.arrow_upward_rounded);
    await tester.tap(sendButton);
    await tester.pump();    // take the animation of ChatTypingIndicator as frame
   expect(find.byType(ChatTypingIndicator), findsOneWidget);
   await tester.pumpAndSettle();
  });



  testWidgets('Successful AI Response', (tester)async{
    when(()=>mockSendMessageRepository.sendMessage(any())).
    thenAnswer((_)async{
      return Future.delayed(const Duration(seconds: 1),(){
        return getChatMessageModel();
      });
    });

    await tester.pumpWidget(const MaterialApp(home: ChatView()));
    await tester.pumpAndSettle(); // build frames to update the ui
    var textField= find.byKey(const Key('chat_input_field'));
    await tester.enterText(textField, 'Hello');
    await tester.pumpAndSettle();
    var sendButton=find.byIcon(Icons.arrow_upward_rounded);
    await tester.tap(sendButton);
    await tester.pumpAndSettle();
    expect(find.byKey(ValueKey('AI Response')), findsOneWidget);
  });


  testWidgets('failure AI Response', (tester)async{
    when(()=>mockSendMessageRepository.sendMessage(any())).
    thenAnswer((_)async{
      return Future.delayed(const Duration(seconds: 1),(){
        return Left(ServerFailure('Connection timeout'));
      });
    });

    await tester.pumpWidget(const MaterialApp(home: ChatView()));
    await tester.pumpAndSettle(); // build frames to update the ui
    var textField= find.byKey(const Key('chat_input_field'));
    await tester.enterText(textField, 'Hello');
    await tester.pumpAndSettle();
    var sendButton=find.byIcon(Icons.arrow_upward_rounded);
    await tester.tap(sendButton);
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byType(FailureBubble), matching: find.textContaining('Error:')), findsOneWidget);
  });


  testWidgets('failure AI Response and Successful Retry', (tester)async{
    var counter=0;
    when(()=>mockSendMessageRepository.sendMessage(any())).
    thenAnswer((_)async{
      counter++;
      return Future.delayed(const Duration(seconds: 1),(){
      if(counter==1){
        return Left(ServerFailure('Connection timeout'));
      }
      return getChatMessageModel();
      });
    });

    await tester.pumpWidget(const MaterialApp(home: ChatView()));
    await tester.pumpAndSettle(); // build frames to update the ui
    var textField= find.byKey(const Key('chat_input_field'));
    await tester.enterText(textField, 'Hello');
    await tester.pumpAndSettle();
    var sendButton=find.byIcon(Icons.arrow_upward_rounded);
    await tester.tap(sendButton);
    await tester.pumpAndSettle();
   var elevatedButton=find.descendant(of: find.byType(FailureBubble), matching: find.byType(ElevatedButton));
   await tester.tap(elevatedButton);
   await tester.pumpAndSettle();
    expect(find.byKey(ValueKey('User Input')), findsNWidgets(2));
    expect(find.byKey(ValueKey('AI Response')), findsOneWidget);
    expect(find.byType(FailureBubble), findsNothing);
  });


  testWidgets('Repeated Retry failure ', (tester)async{
    when(()=>mockSendMessageRepository.sendMessage(any())).
    thenAnswer((_)async{
      return Future.delayed(const Duration(seconds: 1),(){
          return Left(ServerFailure('Connection timeout'));
      });
    });

    await tester.pumpWidget(const MaterialApp(home: ChatView()));
    await tester.pumpAndSettle(); // build frames to update the ui
    var textField= find.byKey(const Key('chat_input_field'));
    await tester.enterText(textField, 'Hello');
    await tester.pumpAndSettle();
    var sendButton=find.byIcon(Icons.arrow_upward_rounded);
    await tester.tap(sendButton);
    await tester.pumpAndSettle();
    var elevatedButton=find.descendant(of: find.byType(FailureBubble), matching: find.byType(ElevatedButton));
    await tester.tap(elevatedButton);
    await tester.pumpAndSettle();
    expect(find.byKey(ValueKey('User Input')), findsNWidgets(2));
    expect(find.byType(FailureBubble), findsOneWidget);
  });


  testWidgets('UI Freeze while Loading', (tester) async {
    when(() => mockSendMessageRepository.sendMessage(any())).thenAnswer(
          (_) async => Future.delayed(
        const Duration(seconds: 1),
            () => getChatMessageModel(),
      ),
    );

    await tester.pumpWidget(MaterialApp(home: ChatView()));
    await tester.pumpAndSettle();

    final textField = find.byKey(const Key('chat_input_field'));
    final sendButton = find.byIcon(Icons.arrow_upward_rounded);

    await tester.enterText(textField, 'Hello');
    await tester.pumpAndSettle();
    await tester.tap(sendButton);
    await tester.pump();

    expect(find.byType(ChatTypingIndicator), findsOneWidget);

    await tester.enterText(textField, 'hi');
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('User Input')), findsOneWidget);
    verify(() => mockSendMessageRepository.sendMessage(any())).called(1);
  });
});
}

