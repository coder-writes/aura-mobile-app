import 'dart:convert';

class ChatFileAttachment {
  final String? path; // Local file path
  final String? filename;
  final String? mimeType;
  final int? size;
  final String? remoteUrl; // URL if stored on server
  final DateTime? uploadedAt;
  final List<int>? bytes; // File bytes for reliable transmission

  const ChatFileAttachment({
    this.path,
    this.filename,
    this.mimeType,
    this.size,
    this.remoteUrl,
    this.uploadedAt,
    this.bytes,
  });

  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'filename': filename,
      'mimeType': mimeType,
      'size': size,
      'remoteUrl': remoteUrl,
      'uploadedAt': uploadedAt?.toIso8601String(),
      'bytes': bytes != null ? base64Encode(bytes!) : null,
    };
  }

  factory ChatFileAttachment.fromMap(Map<String, dynamic> map) {
    List<int>? decodeBytes = null;
    if (map['bytes'] != null) {
      try {
        decodeBytes = base64Decode(map['bytes'].toString());
      } catch (_) {}
    }
    return ChatFileAttachment(
      path: map['path']?.toString(),
      filename: map['filename']?.toString(),
      mimeType: map['mimeType']?.toString(),
      size: map['size'] is int
          ? map['size'] as int
          : int.tryParse(map['size']?.toString() ?? ''),
      remoteUrl: map['remoteUrl']?.toString(),
      uploadedAt: map['uploadedAt'] != null
          ? DateTime.tryParse(map['uploadedAt'].toString())
          : null,
      bytes: decodeBytes,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory ChatFileAttachment.fromJson(String source) =>
      ChatFileAttachment.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

class ChatMessageModel {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;
  final String? retryPrompt;
  final List<ChatFileAttachment>? attachments;

  const ChatMessageModel({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
    this.retryPrompt,
    this.attachments,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'isError': isError,
      'retryPrompt': retryPrompt,
      'attachments': attachments?.map((a) => a.toMap()).toList(),
    };
  }

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: (map['id'] ?? '').toString(),
      text: (map['text'] ?? '').toString(),
      isUser: (map['isUser'] ?? false) as bool,
      timestamp:
          DateTime.tryParse((map['timestamp'] ?? '').toString()) ??
          DateTime.now(),
      isError: (map['isError'] ?? false) as bool,
      retryPrompt: map['retryPrompt']?.toString(),
      attachments: (map['attachments'] as List?)
          ?.map((a) => ChatFileAttachment.fromMap(a as Map<String, dynamic>))
          .toList(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory ChatMessageModel.fromJson(String source) =>
      ChatMessageModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
