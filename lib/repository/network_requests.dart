import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/chat_model.dart';
import '../models/chat_response_model.dart';

class NetworkRequests {
  final List<Map<String, String>> messages = [];

  final String _geminiAIKey = "AIzaSyBYplFVmDHsQo9UiXvV10jyL5hluvDtgwI";
  final String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=';
  final String _imageGeneratorKey =
      "vk-usJFHYb9BDbKjZA7TwddKys1Z33LrxfKZjAhNgAn7cnip";

  Future<String> isArtPromptAPI(String prompt) async {
    try {
      final lastPrompt =
          "Does this prompt want to generate or drawn an AI image, photo, art, picture, drawing or scenery something related?. then, simply answer with a YES or No. here is a prompt: $prompt.";
      final res = await http.post(
        Uri.parse("$_apiUrl$_geminiAIKey"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'role': "user",
              'parts': [
                {'text': lastPrompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.1,
            'topK': 40,
            'topP': 1,
            'maxOutputTokens': 2048,
            'responseMimeType': 'text/plain',
          },
        }),
      );

      if (res.statusCode == 200) {
        final response = ChatResponseModel.fromJson(jsonDecode(res.body));
        if (response.candidates!.first.content.parts.first.text == "YES") {
          return "YES";
        } else {
          return "NO";
        }
      }
      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }

  Future<ChatResponseModel?> geminiAPI(
      {required List<Contents> messages}) async {
    try {
      // Build the payload
      final res = await http.post(
        Uri.parse("$_apiUrl$_geminiAIKey"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': messages.map((e) => e.toJson()).toList(),
          'generationConfig': {
            'temperature': 0.1,
            'topK': 40,
            'topP': 1,
            'maxOutputTokens': 2048,
            'responseMimeType': 'text/plain',
          },
        }),
      );

      // Check if the request was successful
      if (res.statusCode == 200) {
        final responseData = jsonDecode(res.body);
        return ChatResponseModel.fromJson(responseData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<String> imagineAPI(String prompt) async {
    final url = Uri.parse('https://api.vyro.ai/v1/imagine/api/generations');

    try {
      final fields = {
        'prompt': prompt,
        'style_id': '122',
        'aspect_ratio': "3:4",
        'high_res_results': '1',
        'cfg': '7',
        'samples': '1',
        // Add more parameters as needed for safety and quality
      };
      final multipartRequest = http.MultipartRequest('POST', url);
      multipartRequest.headers['Authorization'] = 'Bearer $_imageGeneratorKey';
      multipartRequest.fields.addAll(fields);

      http.Response response =
          await http.Response.fromStream(await multipartRequest.send());

      if (response.statusCode == 200) {
        final imageBytes = response.bodyBytes;
        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}/image.png');
        await tempFile.writeAsBytes(imageBytes);
        return tempFile.path;
      } else if(response.statusCode == 500){
        return "Internal Server Error: Retry the request or contact support";
      } else if(response.statusCode == 503){
        return "Service Unavailable Error: The service is currently unavailable. Retry the request later";
      }
      else {
        return 'Error: Failed to generate image';
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}