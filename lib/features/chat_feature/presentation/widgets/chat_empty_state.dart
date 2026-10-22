import 'package:flutter/material.dart';
import 'package:ai_chat_bot/features/chat_feature/presentation/widgets/suggestion_chip.dart';

import '../../../../core/utiles/constants.dart';

class ChatEmptyState extends StatelessWidget {
  final ValueChanged<String> onSuggestionSelected;

  const ChatEmptyState({
    super.key,
    required this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF10A37F).withAlpha(25),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10A37F).withAlpha(30),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFF10A37F),
              size: 50,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Gemini AI Assistant',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How can I help you today?',
            style: TextStyle(
              color: Colors.white.withAlpha(160),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 36),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'EXAMPLES',
              style: TextStyle(
                color: Colors.white.withAlpha(120),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: suggestions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = suggestions[index];
              return SuggestionCard(
                title: item['title'] as String,
                subtitle: item['subtitle'] as String,
                icon: item['icon'] as IconData,
                onTap: () => onSuggestionSelected(item['prompt'] as String),
              );
            },
          ),
        ],
      ),
    );
  }
}
