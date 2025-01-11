class ChatResponseModel {
  final List<Candidate>? candidates;

  ChatResponseModel({this.candidates});

  factory ChatResponseModel.fromJson(Map<String, dynamic> json) {
    return ChatResponseModel(
      candidates: json['candidates'] != null
          ? (json['candidates'] as List)
              .map((e) => Candidate.fromJson(e))
              .toList()
          : null,
    );
  }
}

class Candidate {
  final ResponseContent content;

  Candidate({required this.content});

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      content: ResponseContent.fromJson(json['content']),
    );
  }
}

class ResponseContent {
  final List<Part> parts;

  ResponseContent({required this.parts});

  factory ResponseContent.fromJson(Map<String, dynamic> json) {
    return ResponseContent(
      parts: (json['parts'] as List).map((e) => Part.fromJson(e)).toList(),
    );
  }
}

class Part {
  final String text;

  Part({required this.text});

  factory Part.fromJson(Map<String, dynamic> json) {
    return Part(text: json['text']);
  }
}
