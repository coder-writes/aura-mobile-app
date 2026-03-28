import 'dart:convert';

class ChatMessageModel {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;
  final String? retryPrompt;

  const ChatMessageModel({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
    this.retryPrompt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'isError': isError,
      'retryPrompt': retryPrompt,
    };
  }

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: (map['id'] ?? '').toString(),
      text: (map['text'] ?? '').toString(),
      isUser: (map['isUser'] ?? false) as bool,
      timestamp: DateTime.tryParse((map['timestamp'] ?? '').toString()) ?? DateTime.now(),
      isError: (map['isError'] ?? false) as bool,
      retryPrompt: map['retryPrompt']?.toString(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory ChatMessageModel.fromJson(String source) =>
      ChatMessageModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
