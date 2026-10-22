class ChatMessageResponseModel {
  final String? id;
  final String? status;
  final Usage? usage;
  final String? created;
  final String? updated;
  final String? serviceTier;
  final List<Step>? steps;
  final String? object;
  final String? model;

  ChatMessageResponseModel({
    this.id,
    this.status,
    this.usage,
    this.created,
    this.updated,
    this.serviceTier,
    this.steps,
    this.object,
    this.model,
  });

  factory ChatMessageResponseModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageResponseModel(
      id: json['id'] as String?,
      status: json['status'] as String?,
      usage: json['usage'] != null
          ? Usage.fromJson(json['usage'] as Map<String, dynamic>)
          : null,
      created: json['created'] as String?,
      updated: json['updated'] as String?,
      serviceTier: json['service_tier'] as String?,
      steps: json['steps'] != null
          ? (json['steps'] as List<dynamic>)
              .map((e) => Step.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      object: json['object'] as String?,
      model: json['model'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (id != null) data['id'] = id;
    if (status != null) data['status'] = status;
    if (usage != null) data['usage'] = usage!.toJson();
    if (created != null) data['created'] = created;
    if (updated != null) data['updated'] = updated;
    if (serviceTier != null) data['service_tier'] = serviceTier;
    if (steps != null) {
      data['steps'] = steps!.map((v) => v.toJson()).toList();
    }
    if (object != null) data['object'] = object;
    if (model != null) data['model'] = model;
    return data;
  }

  /// Convenience getter to quickly access the text from model_output
  String? get outputText {
    if (steps == null) return null;
    for (final step in steps!) {
      if (step.type == 'model_output' && step.content != null) {
        for (final content in step.content!) {
          if (content.text != null && content.text!.isNotEmpty) {
            return content.text;
          }
        }
      }
    }
    return null;
  }
}

class Usage {
  final int? totalTokens;
  final int? totalInputTokens;
  final List<InputTokensByModality>? inputTokensByModality;
  final int? totalCachedTokens;
  final int? totalOutputTokens;
  final int? totalToolUseTokens;
  final int? totalThoughtTokens;

  Usage({
    this.totalTokens,
    this.totalInputTokens,
    this.inputTokensByModality,
    this.totalCachedTokens,
    this.totalOutputTokens,
    this.totalToolUseTokens,
    this.totalThoughtTokens,
  });

  factory Usage.fromJson(Map<String, dynamic> json) {
    return Usage(
      totalTokens: json['total_tokens'] as int?,
      totalInputTokens: json['total_input_tokens'] as int?,
      inputTokensByModality: json['input_tokens_by_modality'] != null
          ? (json['input_tokens_by_modality'] as List<dynamic>)
              .map((e) =>
                  InputTokensByModality.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      totalCachedTokens: json['total_cached_tokens'] as int?,
      totalOutputTokens: json['total_output_tokens'] as int?,
      totalToolUseTokens: json['total_tool_use_tokens'] as int?,
      totalThoughtTokens: json['total_thought_tokens'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (totalTokens != null) data['total_tokens'] = totalTokens;
    if (totalInputTokens != null) data['total_input_tokens'] = totalInputTokens;
    if (inputTokensByModality != null) {
      data['input_tokens_by_modality'] =
          inputTokensByModality!.map((v) => v.toJson()).toList();
    }
    if (totalCachedTokens != null) data['total_cached_tokens'] = totalCachedTokens;
    if (totalOutputTokens != null) data['total_output_tokens'] = totalOutputTokens;
    if (totalToolUseTokens != null) data['total_tool_use_tokens'] = totalToolUseTokens;
    if (totalThoughtTokens != null) data['total_thought_tokens'] = totalThoughtTokens;
    return data;
  }
}

class InputTokensByModality {
  final String? modality;
  final int? tokens;

  InputTokensByModality({this.modality, this.tokens});

  factory InputTokensByModality.fromJson(Map<String, dynamic> json) {
    return InputTokensByModality(
      modality: json['modality'] as String?,
      tokens: json['tokens'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (modality != null) data['modality'] = modality;
    if (tokens != null) data['tokens'] = tokens;
    return data;
  }
}

class Step {
  final String? signature;
  final String? type;
  final List<StepContent>? content;

  Step({this.signature, this.type, this.content});

  factory Step.fromJson(Map<String, dynamic> json) {
    return Step(
      signature: json['signature'] as String?,
      type: json['type'] as String?,
      content: json['content'] != null
          ? (json['content'] as List<dynamic>)
              .map((e) => StepContent.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (signature != null) data['signature'] = signature;
    if (type != null) data['type'] = type;
    if (content != null) {
      data['content'] = content!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class StepContent {
  final String? text;
  final String? type;

  StepContent({this.text, this.type});

  factory StepContent.fromJson(Map<String, dynamic> json) {
    return StepContent(
      text: json['text'] as String?,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (text != null) data['text'] = text;
    if (type != null) data['type'] = type;
    return data;
  }
}

typedef ChatMessageResponse = ChatMessageResponseModel;
