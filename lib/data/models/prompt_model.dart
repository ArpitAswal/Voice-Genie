import 'package:flutter_gemini/flutter_gemini.dart';

class ChatBoxModel {
  final String id;
  final String title;
  final List<PromptModel> messages;

  ChatBoxModel({required this.id, required this.title, required this.messages});

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'messages': messages.map((msg) => msg.toJson()).toList(),
      };

  factory ChatBoxModel.fromJson(Map<String, dynamic> json) => ChatBoxModel(
        id: json['id'],
        title: json['title'],
        messages: (json['messages'] as List)
            .map((msg) => PromptModel.fromJson(msg))
            .toList(),
      );
}

class PromptModel {
  final TextPart part;
  final bool isUser;
  final String? imagePath;
  final String? filePath;

  PromptModel(
      {required this.part,
      required this.isUser,
      this.imagePath,
      this.filePath});

  Map<String, dynamic> toJson() => {
        'text': part,
        'isUser': isUser,
        'imagePath': imagePath,
        'filePath': filePath
      };

  factory PromptModel.fromJson(Map<String, dynamic> json) => PromptModel(
      part: json['text'],
      isUser: json['isUser'],
      imagePath: json['imagePath'],
      filePath: json['filePath']);
}
