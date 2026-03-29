import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../../../core/constants/app_env.dart';
import '../constants/aura_system_prompt.dart';
import '../models/chat_message_model.dart';

class GeminiChatRemoteDataSource {
  GeminiChatRemoteDataSource()
    : _dio = Dio(
        BaseOptions(
          baseUrl: 'https://generativelanguage.googleapis.com/v1beta',
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {'Content-Type': 'application/json'},
        ),
      );

  final Dio _dio;

  Future<String> generateReply({
    required List<ChatMessageModel> history,
    required String userMessage,
    Map<String, dynamic>? userContext,
  }) async {
    final apiKey = AppEnv.geminiApiKey;
    if (apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY is missing. Add it in .env');
    }

    final contextPrefix = _buildUserContext(userContext);
    final enrichedUserMessage = contextPrefix.isEmpty
        ? userMessage
        : '$contextPrefix\n\nUser message:\n$userMessage';

    final conversation = history
        .where((message) => message.text.trim().isNotEmpty)
        .map((message) {
          final role = message.isUser ? 'user' : 'model';
          final parts = <Map<String, dynamic>>[
            {'text': message.text},
          ];

          // Add attachments if present
          if (message.attachments != null && message.attachments!.isNotEmpty) {
            for (final attachment in message.attachments!) {
              final filePart = _buildFilePart(attachment);
              if (filePart != null) {
                parts.add(filePart);
              }
            }
          }

          return {'role': role, 'parts': parts};
        })
        .toList();

    if (conversation.isEmpty || (conversation.last['role'] != 'user')) {
      final parts = <Map<String, dynamic>>[
        {'text': enrichedUserMessage},
      ];
      conversation.add({'role': 'user', 'parts': parts});
    } else {
      final lastConversation = conversation[conversation.length - 1];
      final parts = (lastConversation['parts'] as List<dynamic>)
          .cast<Map<String, dynamic>>();

      // Update the text part but preserve file parts
      if (parts.isNotEmpty && parts.first.containsKey('text')) {
        parts[0]['text'] = enrichedUserMessage;
      } else {
        parts.insert(0, {'text': enrichedUserMessage});
      }
    }

    final body = {
      'systemInstruction': {
        'parts': [
          {'text': auraSystemPrompt},
        ],
      },
      'contents': conversation,
      'generationConfig': {'temperature': 0.35, 'maxOutputTokens': 1536},
    };

    final modelsToTry = <String>{
      AppEnv.geminiModel,
      'gemini-2.5-pro',
      'gemini-2.5-flash',
      'gemini-2.5-flash-lite',
      'gemini-1.5-flash-latest',
      'gemini-1.5-flash',
    }.where((model) => model.trim().isNotEmpty).toList();

    String? lastError;

    for (final model in modelsToTry) {
      final path = '/models/$model:generateContent?key=$apiKey';

      for (var attempt = 1; attempt <= 3; attempt++) {
        try {
          final response = await _dio.post(path, data: body);
          final data = response.data as Map<String, dynamic>;
          final candidates = data['candidates'] as List<dynamic>?;
          if (candidates == null || candidates.isEmpty) {
            final promptFeedback = data['promptFeedback']?.toString();
            throw Exception(
              promptFeedback == null
                  ? 'No response from Gemini.'
                  : 'Gemini blocked or returned no output: $promptFeedback',
            );
          }

          final firstCandidate = candidates.first as Map<String, dynamic>;
          final text = _extractCandidateText(firstCandidate);

          if (text.isEmpty) {
            throw Exception('Gemini returned an empty response.');
          }

          if (_isTruncatedCandidate(firstCandidate) || _looksIncomplete(text)) {
            final completed = await _continueTruncatedReply(
              path: path,
              baseBody: body,
              conversation: conversation,
              firstChunk: text,
            );
            if (completed.trim().isNotEmpty) {
              return completed.trim();
            }
          }

          return text;
        } on DioException catch (error) {
          final isRetryable =
              error.type == DioExceptionType.connectionError ||
              error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout;

          if (attempt < 2 && isRetryable) {
            continue;
          }

          final statusCode = error.response?.statusCode;
          final responseMessage = _extractServerError(error.response?.data);

          if (statusCode == 401 || statusCode == 403) {
            throw Exception(
              'Gemini API key is invalid, unauthorized, or restricted.',
            );
          }
          if (statusCode == 429) {
            if (attempt < 3) {
              await Future<void>.delayed(Duration(seconds: attempt * 2));
              continue;
            }
            lastError =
                'Gemini quota/rate limit reached (429). Please wait 1-2 minutes, or enable billing/increase quota for this API key.';
            break;
          }
          if (statusCode != null && statusCode >= 500) {
            lastError = 'Gemini server is unavailable. Please try again later.';
            break;
          }
          if (statusCode == 404 || statusCode == 400) {
            lastError =
                responseMessage ??
                error.message ??
                'Model $model is not available.';
            break;
          }

          lastError =
              responseMessage ??
              error.message ??
              'Network error while calling Gemini.';
          break;
        } catch (error) {
          lastError = error.toString().replaceFirst('Exception: ', '');
        }
      }
    }

    throw Exception(lastError ?? 'Unable to get response from Gemini.');
  }

  String _extractCandidateText(Map<String, dynamic> candidate) {
    final content = candidate['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    return (parts ?? const [])
        .map(
          (part) => (part is Map<String, dynamic>)
              ? part['text']?.toString() ?? ''
              : '',
        )
        .join('\n')
        .trim();
  }

  bool _isTruncatedCandidate(Map<String, dynamic> candidate) {
    final finishReason = candidate['finishReason']?.toString().toUpperCase();
    return finishReason == 'MAX_TOKENS' || finishReason == 'LENGTH';
  }

  bool _looksIncomplete(String text) {
    final trimmed = text.trimRight();
    if (trimmed.isEmpty) return true;
    return !(trimmed.endsWith('.') ||
        trimmed.endsWith('!') ||
        trimmed.endsWith('?') ||
        trimmed.endsWith('।') ||
        trimmed.endsWith(']') ||
        trimmed.endsWith('"'));
  }

  Future<String> _continueTruncatedReply({
    required String path,
    required Map<String, dynamic> baseBody,
    required List<dynamic> conversation,
    required String firstChunk,
  }) async {
    var combined = firstChunk;
    var modelChunk = firstChunk;

    for (var i = 0; i < 4; i++) {
      final continueConversation = [
        ...conversation,
        {
          'role': 'model',
          'parts': [
            {'text': modelChunk},
          ],
        },
        {
          'role': 'user',
          'parts': [
            {
              'text':
                  'Continue exactly from where you stopped in the same language. Do not repeat previous lines. Complete the remaining answer only.',
            },
          ],
        },
      ];

      final continueBody = {
        ...baseBody,
        'contents': continueConversation,
        'generationConfig': {'temperature': 0.3, 'maxOutputTokens': 1536},
      };

      final response = await _dio.post(path, data: continueBody);
      final data = response.data as Map<String, dynamic>;
      final candidates = data['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        break;
      }

      final candidate = candidates.first as Map<String, dynamic>;
      final chunk = _extractCandidateText(candidate);
      if (chunk.isEmpty) {
        break;
      }

      combined = '$combined\n$chunk';
      modelChunk = chunk;

      if (!_isTruncatedCandidate(candidate)) {
        break;
      }
    }

    return combined;
  }

  String? _extractServerError(dynamic data) {
    if (data is Map<String, dynamic>) {
      final error = data['error'];
      if (error is Map<String, dynamic>) {
        final message = error['message']?.toString();
        if (message != null && message.trim().isNotEmpty) {
          return message;
        }
      }
      final message = data['message']?.toString();
      if (message != null && message.trim().isNotEmpty) {
        return message;
      }
    }
    return null;
  }

  String _buildUserContext(Map<String, dynamic>? userContext) {
    if (userContext == null || userContext.isEmpty) {
      return '';
    }

    final lines = <String>['User context (for safer, personalized guidance):'];
    userContext.forEach((key, value) {
      if (value != null && value.toString().trim().isNotEmpty) {
        lines.add('- $key: $value');
      }
    });

    return lines.length == 1 ? '' : lines.join('\n');
  }

  Map<String, dynamic>? _buildFilePart(ChatFileAttachment attachment) {
    try {
      final mimeType = attachment.mimeType?.trim().toLowerCase();
      final supportsInlineData =
          (mimeType?.startsWith('image/') ?? false) ||
          mimeType == 'application/pdf';

      if (supportsInlineData) {
        if (attachment.bytes != null && attachment.bytes!.isNotEmpty) {
          return {
            'inlineData': {
              'mimeType': attachment.mimeType,
              'data': base64Encode(attachment.bytes!),
            },
          };
        }

        if (attachment.path != null && File(attachment.path!).existsSync()) {
          final bytes = File(attachment.path!).readAsBytesSync();
          return {
            'inlineData': {
              'mimeType': attachment.mimeType,
              'data': base64Encode(bytes),
            },
          };
        }
      }

      if (attachment.filename != null) {
        return {
          'text':
              '[File attached: ${attachment.filename} (${attachment.mimeType ?? 'unknown'})]',
        };
      }

      return {'text': '[File attached]'};
    } catch (e) {
      return {'text': '[Could not process file: ${attachment.filename}]'};
    }
  }
}
