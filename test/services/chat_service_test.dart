import 'package:ai_chat_bot/core/services/api_client.dart';
import 'package:ai_chat_bot/core/services/chat_service.dart';
import 'package:ai_chat_bot/features/chat_feature/data/models/chat_message_model.dart';
import 'package:ai_chat_bot/features/chat_feature/data/models/chat_message_response_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class ApiClintMock extends Mock implements ApiClient{}
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

DioException _getRetryableDioException()=>DioException(
    type: DioExceptionType.connectionTimeout,
    requestOptions: RequestOptions(
      path: '/v1beta/interactions',
    ),
);
DioException _getNonRetryableDioException() =>DioException(
  type: DioExceptionType.badResponse,
  requestOptions: RequestOptions(
    path: '/v1beta/interactions',
  ),
);

void main(){
  late ChatService chatService;
  late ApiClintMock apiClientMock;
setUpAll((){
  registerFallbackValue('');
});
  setUp((){
    apiClientMock=ApiClintMock();
    chatService=ChatService(apiClient: apiClientMock);
  });

  group('Retry logic', (){

    test('Succeed on first attempt', ()
    async {
      when(()=>apiClientMock.postRequest(any(),any(),any(),any())).thenAnswer((_)async=>_getSuccessResponse());
      var result=await chatService.sendMessage(ChatMessageModel(input: 'test'));
      verify(()=>apiClientMock.postRequest(any(),any(),any(),any())).called(1);
      expect(result, isA<ChatMessageResponseModel>());
    });

    test('fail on first attempt but succeed on second attempt if retryable exception', ()
    async {
      var counter=0;
      when(()=>apiClientMock.postRequest(any(),any(),any(),any())).
      thenAnswer((_)async {
        counter++;
        if(counter==1){
          throw _getRetryableDioException();
        }else{
          return _getSuccessResponse();
      }
      });
      var result=await chatService.sendMessage(ChatMessageModel(input: 'test'));
      verify(()=>apiClientMock.postRequest(any(),any(),any(),any())).called(2);
      expect(result, isA<ChatMessageResponseModel>());
    });

    test('fail on first attempt can not be retried non retryable exception', ()
    async {
      when(()=>apiClientMock.postRequest(any(),any(),any(),any())).thenAnswer((_)async{
        throw _getNonRetryableDioException();
      });
   // expectLater used to await the request to be finished if there is a delay before go tho verity
     await expectLater(()=>chatService.sendMessage(ChatMessageModel(input: 'test')),
          throwsA(isA<DioException>()));

      verify(()=>apiClientMock.postRequest(any(),any(),any(),any())).called(1);

    });


    test('fail on first and second attempt but succeed on third attempt if retryable exception', ()
    async {
      var counter=0;
      when(()=>apiClientMock.postRequest(any(),any(),any(),any())).
      thenAnswer((_)async {
        counter++;
        if(counter==3){
          return _getSuccessResponse();
        }else{
          throw _getRetryableDioException();
        }
      });
      var result=await chatService.sendMessage(ChatMessageModel(input: 'test'));
      verify(()=>apiClientMock.postRequest(any(),any(),any(),any())).called(3);
      expect(result, isA<ChatMessageResponseModel>());
    });

    test('fail on the 3 attempts', () async {
      when(()=>apiClientMock.postRequest(any(),any(),any(),any())).thenAnswer((_)async{
        throw _getRetryableDioException();
      });
      // expectLater used to await the request to be finished if there is a delay before go tho verity
      await expectLater(()=>chatService.sendMessage(ChatMessageModel(input: 'test')),
          throwsA(isA<DioException>()));

      verify(()=>apiClientMock.postRequest(any(),any(),any(),any())).called(3);

    });
  });
}
