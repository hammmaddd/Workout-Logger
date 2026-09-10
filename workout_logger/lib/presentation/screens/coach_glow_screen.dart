import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/backend_api_service.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/providers/auth_provider.dart' as app_auth;
import '../theme/app_theme.dart';

class CoachGlowScreen extends StatefulWidget {
  const CoachGlowScreen({super.key});

  @override
  State<CoachGlowScreen> createState() => _CoachGlowScreenState();
}

class _CoachGlowScreenState extends State<CoachGlowScreen> {
  final BackendApiService _backendApi = BackendApiService();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessageModel> _messages = [];
  bool _isSending = false;

  static const _starterPrompts = [
    'How much protein do I need daily?',
    'Suggest a beginner leg day',
    'Tips for staying consistent',
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send([String? presetText]) async {
    final text = (presetText ?? _inputController.text).trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _messages.add(ChatMessageModel(role: 'user', text: text));
      _isSending = true;
      _inputController.clear();
    });
    _scrollToBottom();

    try {
      // FIX: Remove the unnecessary 'as String?' cast. 'getIdToken()' already returns 'String?'.
      final idToken = await context.read<app_auth.AuthProvider>().user?.getIdToken();
      if (idToken == null) throw Exception('Not signed in');

      final history = _messages.map((m) => m.toJson()).toList();
      // Now the compiler knows idToken is String (promoted), so this will work!
      final reply = await _backendApi.sendCoachMessage(idToken: idToken, messages: history);

      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessageModel(role: 'assistant', text: reply as String));
        _isSending = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessageModel(role: 'assistant', text: 'Couldn\'t get a reply. Tap to retry.', failed: true));
        _isSending = false;
      });
      _scrollToBottom();
    }
  }

  void _retryLast() {
    if (_messages.isEmpty) return;
    final lastUserMessage = _messages.lastWhere((m) => m.isUser, orElse: () => _messages.first);
    setState(() {
      if (_messages.last.failed) _messages.removeLast();
    });
    _send(lastUserMessage.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach Glow'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty ? _buildEmptyState(context) : _buildMessageList(context),
          ),
          if (_isSending) _buildTypingIndicator(context),
          _buildInputBar(context),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _glowAvatar(size: 72),
            const SizedBox(height: 20),
            Text('Hey, I\'m Coach Glow', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
            const SizedBox(height: 6),
            Text(
              'Ask me anything about workouts, nutrition, or tips for staying on track.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary(context)),
            ),
            const SizedBox(height: 24),
            ..._starterPrompts.map((prompt) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () => _send(prompt),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.card(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.divider(context)),
                      ),
                      child: Text(prompt, style: TextStyle(fontSize: 13, color: AppTheme.textPrimary(context))),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _glowAvatar({double size = 36}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(colors: [AppTheme.lime, AppTheme.cyan]),
        boxShadow: [
          BoxShadow(color: AppTheme.lime.withValues(alpha: 0.35), blurRadius: size * 0.4, spreadRadius: size * 0.04),
        ],
      ),
      child: Icon(Icons.auto_awesome, color: Colors.black, size: size * 0.5),
    );
  }

  Widget _buildMessageList(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: message.isUser ? _userBubble(context, message) : _botBubble(context, message),
        );
      },
    );
  }

  Widget _userBubble(BuildContext context, ChatMessageModel message) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: AppTheme.lime, borderRadius: BorderRadius.circular(16)),
            child: Text(message.text, style: const TextStyle(fontSize: 13.5, color: Colors.black)),
          ),
        ),
      ],
    );
  }

  Widget _botBubble(BuildContext context, ChatMessageModel message) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _glowAvatar(size: 28),
        const SizedBox(width: 8),
        Flexible(
          child: GestureDetector(
            onTap: message.failed ? _retryLast : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: message.failed ? AppTheme.danger.withValues(alpha: 0.1) : AppTheme.card(context),
                borderRadius: BorderRadius.circular(16),
                border: message.failed ? Border.all(color: AppTheme.danger.withValues(alpha: 0.4)) : null,
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 13.5,
                  color: message.failed ? AppTheme.danger : AppTheme.textPrimary(context),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        children: [
          _glowAvatar(size: 24),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: AppTheme.card(context), borderRadius: BorderRadius.circular(16)),
            child: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.textSecondary(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          border: Border(top: BorderSide(color: AppTheme.divider(context))),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                maxLength: 500,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: const InputDecoration(
                  hintText: 'Ask about workouts, nutrition...',
                  counterText: '',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _isSending ? null : () => _send(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _isSending ? AppTheme.textSecondary(context) : AppTheme.lime,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_upward, color: Colors.black, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}