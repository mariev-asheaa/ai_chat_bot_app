enum MessageSender { user, bot }

class UiChatMessage {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final bool isLoading;

  UiChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.isLoading = false,
  });

  UiChatMessage copyWith({
    String? id,
    String? text,
    MessageSender? sender,
    DateTime? timestamp,
    bool? isLoading,
  }) {
    return UiChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
