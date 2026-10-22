class GenerationConfig {
  final String? thinkingLevel;

  GenerationConfig({this.thinkingLevel});

  factory GenerationConfig.fromJson(Map<String, dynamic> json) {
    return GenerationConfig(
      thinkingLevel: json['thinking_level'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (thinkingLevel != null) {
      data['thinking_level'] = thinkingLevel;
    }
    return data;
  }
}

class ChatMessageModel {
  final String model;
  final String input;
  final String? previousInteractionId;
  final GenerationConfig? generationConfig;

  ChatMessageModel({
    this.model = 'gemini-3.6-flash',
    required this.input,
    this.previousInteractionId,
    this.generationConfig,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      model: json['model'] as String? ?? 'gemini-3.6-flash',
      input: json['input'] as String? ?? '',
      previousInteractionId: json['previous_interaction_id'] as String?,
      generationConfig: json['generation_config'] != null
          ? GenerationConfig.fromJson(
              json['generation_config'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'model': model,
      'input': input,
    };
    if (previousInteractionId != null) {
      data['previous_interaction_id'] = previousInteractionId;
    }
    if (generationConfig != null) {
      data['generation_config'] = generationConfig!.toJson();
    }
    return data;
  }
}

typedef ChatMessageRequest = ChatMessageModel;
