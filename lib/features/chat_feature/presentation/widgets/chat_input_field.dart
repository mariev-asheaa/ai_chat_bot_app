import 'package:flutter/material.dart';

class ChatInputField extends StatefulWidget {
  final ValueChanged<String> onSubmitted;
  final bool isLoading;

  const ChatInputField({
    super.key,
    required this.onSubmitted,
    this.isLoading = false,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _textController = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final textExists = _textController.text.trim().isNotEmpty;
    if (textExists != _hasText) {
      setState(() {
        _hasText = textExists;
      });
    }
  }

  void _handleSubmit() {
    final text = _textController.text.trim();
    if (text.isNotEmpty && !widget.isLoading) {
      widget.onSubmitted(text);
      _textController.clear();
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSend = _hasText && !widget.isLoading;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        border: Border(
          top: BorderSide(
            color: Colors.white.withAlpha(15),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2B36),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withAlpha(20),
                  width: 1,
                ),
              ),
              child: TextField(
                key:const Key('chat_input_field'),
                controller: _textController,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSubmit(),
                decoration: InputDecoration(
                  hintText: widget.isLoading
                      ? 'Gemini is typing...'
                      : 'Ask Gemini anything...',
                  hintStyle: TextStyle(
                    color: Colors.white.withAlpha(100),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: canSend
                  ? const Color(0xFF10A37F)
                  : const Color(0xFF2A2B36),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: canSend ? _handleSubmit : null,
              icon: Icon(
                Icons.arrow_upward_rounded,
                color: canSend
                    ? Colors.white
                    : Colors.white.withAlpha(60),
                size: 20,
              ),
              tooltip: 'Send message',
            ),
          ),
        ],
      ),
    );
  }
}
