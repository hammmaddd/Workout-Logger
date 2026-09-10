class ChatMessageModel {
  final String role; // 'user' or 'assistant'
  final String text;
  bool failed;

  ChatMessageModel({
    required this.role,
    required this.text,
    this.failed = false,
  });

  bool get isUser => role == 'user';

  Map<String, dynamic> toJson() => {'role': role, 'text': text};
}