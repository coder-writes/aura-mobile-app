import '../datasources/gemini_chat_remote_datasource.dart';
import '../models/chat_message_model.dart';

class ChatbotRepository {
  final GeminiChatRemoteDataSource remoteDataSource;

  ChatbotRepository({required this.remoteDataSource});

  Future<String> generateReply({
    required List<ChatMessageModel> history,
    required String userMessage,
    Map<String, dynamic>? userContext,
  }) {
    return remoteDataSource.generateReply(
      history: history,
      userMessage: userMessage,
      userContext: userContext,
    );
  }
}
