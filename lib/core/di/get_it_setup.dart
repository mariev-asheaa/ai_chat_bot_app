import 'package:ai_chat_bot/features/chat_feature/presentation/cubit/send_message_cubit.dart';
import 'package:get_it/get_it.dart';

import '../../features/chat_feature/data/repo/send_message_repository_impl.dart';
import '../../features/chat_feature/domain/repo/send_message_repository.dart';
import '../services/api_client.dart';
import '../services/chat_service.dart';

var getIt=GetIt.instance;
void getItSetup(){
  getIt.registerLazySingleton<ChatService>(()=>ChatService(apiClient: getIt<ApiClient>()));
  getIt.registerSingleton<ApiClient>(ApiClient());

  getIt.registerLazySingleton<SendMessageRepository>(()=>SendMessageRepositoryImpl(chatService: getIt<ChatService>()));
  getIt.registerFactory<SendMessageCubit>(()=>SendMessageCubit(repository: getIt<SendMessageRepository>()));

}