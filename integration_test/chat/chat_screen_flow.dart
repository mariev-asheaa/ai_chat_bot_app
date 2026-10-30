import 'dart:async';
import 'package:ai_chat_bot/core/di/get_it_setup.dart';
import 'package:ai_chat_bot/core/errors/failure.dart';
import 'package:ai_chat_bot/core/services/api_client.dart';
import 'package:ai_chat_bot/features/chat_feature/data/models/chat_message_model.dart';
import 'package:ai_chat_bot/features/chat_feature/data/models/chat_message_response_model.dart';
import 'package:ai_chat_bot/features/chat_feature/presentation/views/chat_view.dart';
import 'package:ai_chat_bot/features/chat_feature/presentation/widgets/chat_typing_indicator.dart';
import 'package:ai_chat_bot/features/chat_feature/presentation/widgets/failure_bubble.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient{}

FutureOr<Either<Failure, ChatMessageResponseModel>> getChatMessageModel(){
  return Right(ChatMessageResponseModel());
}
Map<String, Object> _successResponseBody() =>{
  "id": "v1_ChdaMm5hYXR5d0V2cWxrZFVQNW9uTjJRbxIXR1puZmF2eWlEZTNpa2RVUG1xTGctUWM",
  "status": "completed",
  "usage": {
    "total_tokens": 331,
    "total_input_tokens": 219,
    "input_tokens_by_modality": [
      {
        "modality": "text",
        "tokens": 219
      }
    ],
    "total_cached_tokens": 0,
    "total_output_tokens": 6,
    "total_tool_use_tokens": 0,
    "total_thought_tokens": 106
  },
  "created": "2026-10-26T18:16:59Z",
  "updated": "2026-10-26T18:16:59Z",
  "service_tier": "standard",
  "steps": [
    {
      "signature": "EuYDCuMDAWkUfRP4Mo0cLyHyncrDZTDYJDYWABeqt+p3XLOnhGEkHk+P+Ya1tjA7wjvcyujlMvZRvlwnhpxWforwC/GkzUDXxnxYonkgLAeIn78+VOmyeD1sEFHEPK/Aop8BwuA9aYOVGnAekBgHcYcQyxzwnnNHtHadKPzOw6+4AdW5yP/imhr5KpXS28xX62JSmB7wYSLGDfQZ8w6641GO3xoPlmJD8FVfZmkIrPX6Db8kpxJ/toNuEZB0mOPiuulzPtGqI0s42tXddgXoKEHocHx6cxzSgZGOlgSt2sLtcJPotcjDPuDNEzk3WBWcYIbwXC6/Vp62HuuXKj6CLGVU09lRMfK0WOoiNDPL2rkEwo1q3OBXDe1fQMSw1C5TAvfEC16WT0fJUPWN4XLXhPdXHf1YyxjJAW4sSSssL+xvcWLlUtLtPCYQmnTONtLlUAu3Avsl12EChBQvmR+tLR2hXmX5Ql8DG9BYg5uER/MWPHhRFIpFh2pGQnAUWMwOWB6Chi8kMqlaQI1jWimtkjMdwGf7UDhLlQ1UUTCKO05+zg7dKXlKgQKvPnCUDF5uZMXQelVJlAyTjMih/0E5k5VsCnnbwOJNX8NMpqRF0rR6iow+jstVtBIRCqafb6qodxHzA2a4wpmY",
      "type": "thought"
    },
    {
      "content": [
        {
          "text": "Your name is Mariev!",
          "type": "text"
        }
      ],
      "type": "model_output"
    }
  ],
  "object": "interaction",
  "model": "gemini-3.6-flash"
};
Response<Map<String,dynamic>> _getSuccessResponse()=>
    Response(
      data: _successResponseBody(),
      statusCode: 200,
      requestOptions: RequestOptions(path: '/v1beta/interactions'),

    );



void main(){
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late MockApiClient mockApiClient;

  setUpAll(() {
    registerFallbackValue(ChatMessageModel(input: ''));
  });

  setUp(()
  async{
    mockApiClient=MockApiClient();
    await getIt.reset();
    getItSetup();
    await getIt.unregister<ApiClient>();
    getIt.registerSingleton<ApiClient>(mockApiClient);

      });

  group('Send Message Flow', (){

    testWidgets('Loading Indicator On Send Message', (tester)async{
      when(()=>mockApiClient.postRequest(any(),any(),any(),any())).
      thenAnswer((_)async{
        return Future.delayed(const Duration(seconds: 1),(){
          return _getSuccessResponse();
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
      when(()=>mockApiClient.postRequest(any(),any(),any(),any())).
      thenAnswer((_)async{
        return Future.delayed(const Duration(seconds: 1),(){
          return _getSuccessResponse();
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
      when(()=>mockApiClient.postRequest(any(),any(),any(),any())).
      thenAnswer((_)async{
        return Future.delayed(const Duration(seconds: 1),(){
          throw Left(ServerFailure('Connection timeout'));
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
      when(()=>mockApiClient.postRequest(any(),any(),any(),any())).
      thenAnswer((_)async{
        counter++;
        return Future.delayed(const Duration(seconds: 1),(){
          if(counter==1){
            throw Left(ServerFailure('Connection timeout'));
          }
          return _getSuccessResponse();
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
      when(()=>mockApiClient.postRequest(any(),any(),any(),any())).
      thenAnswer((_)async{
        return Future.delayed(const Duration(seconds: 1),(){
          throw Left(ServerFailure('Connection timeout'));
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
      when(() =>mockApiClient.postRequest(any(),any(),any(),any())).thenAnswer(
            (_) async => Future.delayed(
          const Duration(seconds: 1),
              () => _getSuccessResponse(),
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
    });
  });
}

