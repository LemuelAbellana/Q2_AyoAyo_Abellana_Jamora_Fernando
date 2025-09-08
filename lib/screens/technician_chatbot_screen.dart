import 'package:ayoayo/services/gemini_diagnosis_service.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class TechnicianChatbotScreen extends StatefulWidget {
  const TechnicianChatbotScreen({super.key});

  @override
  State<TechnicianChatbotScreen> createState() =>
      _TechnicianChatbotScreenState();
}

class _TechnicianChatbotScreenState extends State<TechnicianChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _chatMessages = [];
  final GeminiDiagnosisService _geminiService = GeminiDiagnosisService();
  bool _isLoading = false;

  void _sendMessage() async {
    final messageText = _messageController.text;
    if (messageText.isEmpty) return;

    setState(() {
      _chatMessages.add(ChatMessage(text: messageText, isUser: true));
      _isLoading = true;
    });

    _messageController.clear();

    try {
      final response = await _geminiService.getTechnicianChatbotResponse(
        messageText,
      );
      setState(() {
        _chatMessages.add(ChatMessage(text: response, isUser: false));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _chatMessages.add(
          ChatMessage(text: "Sorry, something went wrong.", isUser: false),
        );
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final message = _chatMessages[index];
                return ListTile(
                  title: Align(
                    alignment: message.isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: message.isUser
                            ? Colors.blue
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        message.text,
                        style: TextStyle(
                          color: message.isUser ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Ask a question...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
