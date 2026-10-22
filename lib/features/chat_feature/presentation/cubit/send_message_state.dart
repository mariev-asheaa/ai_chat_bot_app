part of 'send_message_cubit.dart';

@immutable
sealed class SendMessageState {}

final class SendMessageInitial extends SendMessageState {}

final class SendMessageLoading extends SendMessageState {}

final class SendMessageSuccess extends SendMessageState {
  final ChatMessageResponseModel response;

  SendMessageSuccess({required this.response});
}

final class SendMessageError extends SendMessageState {
  final String message;

  SendMessageError({required this.message});
}
