import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/chatbot_cubit.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChatbotCubit>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'AURA AI Assistant',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Clear chat',
            onPressed: () async {
              final shouldClear = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear chat?'),
                  content: const Text('This will remove your local chat history.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );

              if (shouldClear == true && context.mounted) {
                await cubit.clearChat();
              }
            },
            icon: const Icon(Icons.delete_outline, color: AppColors.primary),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocConsumer<ChatbotCubit, ChatbotState>(
                listener: (context, state) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!_scrollController.hasClients) return;
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                  });
                },
                builder: (context, state) {
                  final messages = state.messages;
                  if (messages.isEmpty) {
                    return const Center(child: Text('Start a conversation with AURA'));
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: messages.length + (state.isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (state.isTyping && index == messages.length) {
                        return const _TypingBubble();
                      }

                      final message = messages[index];
                      final isUser = message.isUser;

                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          constraints: const BoxConstraints(maxWidth: 320),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isUser
                                ? AppColors.primary
                                : (message.isError
                                    ? Colors.red.withValues(alpha: 0.08)
                                    : AppColors.surfaceContainerLow),
                            borderRadius: BorderRadius.circular(14),
                            border: message.isError
                                ? Border.all(color: Colors.red.withValues(alpha: 0.3))
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment:
                                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              if (isUser)
                                Text(
                                  message.text,
                                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                                )
                              else
                                MarkdownBody(
                                  data: message.text,
                                  styleSheet: MarkdownStyleSheet(
                                    p: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.onSurface,
                                      height: 1.35,
                                    ),
                                    listBullet: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    DateFormat('hh:mm a').format(message.timestamp),
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: isUser
                                          ? Colors.white.withValues(alpha: 0.85)
                                          : AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  if (!isUser) ...[
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () {
                                        Clipboard.setData(ClipboardData(text: message.text));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Copied to clipboard')),
                                        );
                                      },
                                      child: Icon(
                                        Icons.copy_rounded,
                                        size: 14,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                  if (message.isError && message.retryPrompt != null) ...[
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () =>
                                          context.read<ChatbotCubit>().retryLast(message.retryPrompt!),
                                      child: const Icon(
                                        Icons.refresh_rounded,
                                        size: 16,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1),
            _SuggestionsRow(
              onTapSuggestion: (text) {
                _controller.text = text;
                _onSend();
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      minLines: 1,
                      maxLines: 5,
                      onSubmitted: (_) => _onSend(),
                      decoration: InputDecoration(
                        hintText: 'Ask AURA about health guidance...',
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  BlocBuilder<ChatbotCubit, ChatbotState>(
                    builder: (context, state) {
                      return IconButton.filled(
                        onPressed: state.isTyping ? null : _onSend,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor:
                              AppColors.primary.withValues(alpha: 0.35),
                        ),
                        icon: state.isTyping
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send_rounded, color: Colors.white),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<ChatbotCubit>().sendMessage(text);
    _controller.clear();
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 10),
            Text(
              'AURA is typing...',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionsRow extends StatelessWidget {
  final ValueChanged<String> onTapSuggestion;

  const _SuggestionsRow({required this.onTapSuggestion});

  @override
  Widget build(BuildContext context) {
    final suggestions = context.read<ChatbotCubit>().quickSuggestions;

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = suggestions[index];
          return ActionChip(
            backgroundColor: AppColors.surfaceContainerLow,
            label: Text(item, overflow: TextOverflow.ellipsis),
            onPressed: () => onTapSuggestion(item),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemCount: suggestions.length,
      ),
    );
  }
}
