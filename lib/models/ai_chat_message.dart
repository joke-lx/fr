import 'dart:convert';

/// AI 聊天消息模型
class AIChatMessage {
  final String id;
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;
  final bool isLoading; // 是否正在加载中

  AIChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isLoading = false,
  });

  factory AIChatMessage.user(String content) {
    return AIChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: content,
      timestamp: DateTime.now(),
    );
  }

  factory AIChatMessage.assistant(String content) {
    return AIChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'assistant',
      content: content,
      timestamp: DateTime.now(),
    );
  }

  factory AIChatMessage.loading() {
    return AIChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'assistant',
      content: '',
      timestamp: DateTime.now(),
      isLoading: true,
    );
  }

  AIChatMessage copyWith({
    String? id,
    String? role,
    String? content,
    DateTime? timestamp,
    bool? isLoading,
  }) {
    return AIChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isLoading': isLoading,
    };
  }

  factory AIChatMessage.fromJson(Map<String, dynamic> json) {
    return AIChatMessage(
      id: json['id'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isLoading: json['isLoading'] as bool? ?? false,
    );
  }

  static String encodeList(List<AIChatMessage> messages) {
    return jsonEncode(messages.map((e) => e.toJson()).toList());
  }

  static List<AIChatMessage> decodeList(String jsonString) {
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((e) => AIChatMessage.fromJson(e)).toList();
  }
}

/// AI 设置模型
class AISettings {
  final String apiKey;
  final String model;
  final String baseURL;
  final String type;

  AISettings({
    this.apiKey = '',
    this.model = '',
    this.baseURL = '',
    this.type = 'claude',
  });

  bool get isConfigured => apiKey.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'apiKey': apiKey,
      'model': model,
      'baseURL': baseURL,
      'type': type,
    };
  }

  factory AISettings.fromJson(Map<String, dynamic> json) {
    return AISettings(
      apiKey: json['apiKey'] as String? ?? '',
      model: json['model'] as String? ?? '',
      baseURL: json['baseURL'] as String? ?? '',
      type: json['type'] as String? ?? 'claude',
    );
  }

  static String encode(AISettings settings) {
    return jsonEncode(settings.toJson());
  }

  static AISettings decode(String jsonString) {
    return AISettings.fromJson(jsonDecode(jsonString));
  }
}
