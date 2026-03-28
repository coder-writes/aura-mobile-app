import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/repositories/chatbot_repository.dart';

class ChatbotState {
  final List<ChatMessageModel> messages;
  final bool isTyping;
  final String? error;

  const ChatbotState({
    required this.messages,
    this.isTyping = false,
    this.error,
  });

  ChatbotState copyWith({
    List<ChatMessageModel>? messages,
    bool? isTyping,
    String? error,
  }) {
    return ChatbotState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      error: error,
    );
  }
}

class ChatbotCubit extends Cubit<ChatbotState> {
  ChatbotCubit({
    required this.repository,
    required this.authCubit,
  }) : super(const ChatbotState(messages: []));

  static const _historyKey = 'aura_chat_history_v1';
  static const int _maxMessages = 50;

  final ChatbotRepository repository;
  final AuthCubit authCubit;

  final List<String> quickSuggestions = const [
    'Explain my anemia scan result in simple language.',
    'I have cough for 2 weeks, what should I do?',
    'Suggest iron-rich foods for rural diet.',
    'Help me book a doctor appointment step by step.',
  ];

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_historyKey) ?? <String>[];

    final messages = raw
        .map((item) => ChatMessageModel.fromJson(item))
        .toList(growable: false);

    emit(state.copyWith(messages: messages));

    if (messages.isEmpty) {
      await _appendAssistantMessage(
        'ℹ️ I provide health guidance only — not medical diagnosis. Always consult a qualified doctor for treatment decisions.\n\nमैं सिर्फ स्वास्थ्य मार्गदर्शन देती हूं — निदान नहीं। इलाज के लिए हमेशा डॉक्टर से मिलें।',
      );
    }
  }

  Future<void> sendMessage(String input) async {
    final text = input.trim();
    if (text.isEmpty || state.isTyping) return;

    final userMessage = ChatMessageModel(
      id: _id(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final updated = [...state.messages, userMessage];
    emit(state.copyWith(messages: updated, isTyping: true, error: null));
    await _persist(updated);

    try {
      final reply = await repository.generateReply(
        history: updated
            .takeLast(8)
            .map(
              (message) => ChatMessageModel(
                id: message.id,
                text: message.text.length > 500
                    ? '${message.text.substring(0, 500)}...'
                    : message.text,
                isUser: message.isUser,
                timestamp: message.timestamp,
                isError: message.isError,
                retryPrompt: message.retryPrompt,
              ),
            )
            .toList(growable: false),
        userMessage: text,
        userContext: _buildUserContext(),
      );

      await _appendAssistantMessage(reply);
      emit(state.copyWith(isTyping: false, error: null));
    } catch (error) {
      final reason = error.toString().replaceFirst('Exception: ', '');
      final isQuotaError =
          reason.contains('quota') || reason.contains('429') || reason.contains('Too many requests');
      final failed = ChatMessageModel(
        id: _id(),
        text:
            isQuotaError
                ? 'I am temporarily rate-limited by Gemini (quota reached).\nReason: $reason\n\nTry again after 1-2 minutes. If it keeps happening, enable billing or increase quota for this API key.\n\nमैं अभी Gemini quota limit के कारण जवाब नहीं दे पा रही हूं।\nकारण: $reason\n\n1-2 मिनट बाद फिर प्रयास करें। अगर बार-बार हो रहा है, तो इस API key के लिए billing/quota बढ़ाएं।'
                : 'I am unable to respond right now.\nReason: $reason\n\nPlease retry after checking API key/model/network.\n\nमैं अभी जवाब नहीं दे पा रही हूं।\nकारण: $reason\n\nकृपया API key/model/network जांचकर दोबारा कोशिश करें।',
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
        retryPrompt: text,
      );

      final withError = [...state.messages, failed];
      emit(state.copyWith(messages: withError, isTyping: false, error: error.toString()));
      await _persist(withError);
    }
  }

  Future<void> retryLast(String prompt) async {
    await sendMessage(prompt);
  }

  Future<void> clearChat() async {
    emit(state.copyWith(messages: []));
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  Future<void> _appendAssistantMessage(String text) async {
    final assistantMessage = ChatMessageModel(
      id: _id(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
    );

    final updated = [...state.messages, assistantMessage];
    emit(state.copyWith(messages: updated));
    await _persist(updated);
  }

  Future<void> _persist(List<ChatMessageModel> messages) async {
    final trimmed = messages.length > _maxMessages
        ? messages.sublist(messages.length - _maxMessages)
        : messages;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, trimmed.map((m) => m.toJson()).toList());
  }

  Map<String, dynamic> _buildUserContext() {
    final authState = authCubit.state;
    if (authState is! AuthAuthenticated) return {};

    final user = authState.user;
    return {
      'firstName': user.firstName,
      'age': user.age,
      'gender': user.gender,
      'state': user.state,
      'district': user.district,
      'bloodGroup': user.bloodGroup,
      'isPregnant': null,
    };
  }

  String _id() {
    final random = Random().nextInt(999999).toString().padLeft(6, '0');
    return '${DateTime.now().microsecondsSinceEpoch}_$random';
  }
}

extension _TakeLastExt<T> on List<T> {
  List<T> takeLast(int count) {
    if (length <= count) return this;
    return sublist(length - count);
  }
}
