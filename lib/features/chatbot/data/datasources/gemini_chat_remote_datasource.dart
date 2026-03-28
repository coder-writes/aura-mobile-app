import 'package:dio/dio.dart';
import 'dart:async';

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
            headers: {
              'Content-Type': 'application/json',
            },
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
          return {
            'role': role,
            'parts': [
              {'text': message.text}
            ],
          };
        }).toList();

    if (conversation.isEmpty || (conversation.last['role'] != 'user')) {
      conversation.add({
        'role': 'user',
        'parts': [
          {'text': enrichedUserMessage}
        ],
      });
    } else {
      conversation[conversation.length - 1] = {
        'role': 'user',
        'parts': [
          {'text': enrichedUserMessage}
        ],
      };
    }

    final body = {
      'systemInstruction': {
        'parts': [
          {'text': auraSystemPrompt}
        ]
      },
      'contents': conversation,
      'generationConfig': {
        'temperature': 0.4,
        'maxOutputTokens': 400,
      },
    };

    final modelsToTry = <String>{
      AppEnv.geminiModel,
      'gemini-1.5-flash-latest',
      'gemini-1.5-flash',
      'gemini-2.0-flash',
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

          final content = candidates.first['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List<dynamic>?;
          final text = (parts ?? const [])
              .map((part) => (part is Map<String, dynamic>) ? part['text']?.toString() ?? '' : '')
              .join('\n')
              .trim();

          if (text.isEmpty) {
            throw Exception('Gemini returned an empty response.');
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
            throw Exception('Gemini API key is invalid, unauthorized, or restricted.');
          }
          if (statusCode == 429) {
            if (attempt < 3) {
              await Future<void>.delayed(Duration(seconds: attempt * 2));
              continue;
            }
            lastError = 'Gemini quota/rate limit reached (429). Please wait 1-2 minutes, or enable billing/increase quota for this API key.';
            break;
          }
          if (statusCode != null && statusCode >= 500) {
            lastError = 'Gemini server is unavailable. Please try again later.';
            break;
          }
          if (statusCode == 404 || statusCode == 400) {
            lastError = responseMessage ?? error.message ?? 'Model $model is not available.';
            break;
          }

          lastError = responseMessage ?? error.message ?? 'Network error while calling Gemini.';
          break;
        } catch (error) {
          lastError = error.toString().replaceFirst('Exception: ', '');
        }
      }
    }

    throw Exception(lastError ?? 'Unable to get response from Gemini.');
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
}
