import 'dart:io';
import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf_gemini/pdf_gemini.dart';

import '../../utils/config.dart';

class GenerateContentUseCase {
  late GenerativeModel generativeModel;
  final genService = GenaiClient(geminiApiKey: Config.geminiKey);

  GenerateContentUseCase() {
    generativeModel = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: Config.geminiKey,
        generationConfig: GenerationConfig(
          temperature: 0.4,
          topK: 32,
          topP: 1,
          maxOutputTokens: 4096,
        ),
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
        ]);
  }

  // Sends a prompt to the generative model and returns the response
  Future<Stream<GenerateContentResponse>> execute(
      {required String prompt,
      required List<Content>? history,
      required bool isTextOnly,
      required List<XFile> images}) async {
    try {
      final content = await getContent(
          message: prompt, isTextOnly: isTextOnly, images: images);
      final chat = generativeModel.startChat(history: history);
      return chat.sendMessageStream(content).asyncMap((event) {
        return event;
      });
    } catch (e) {
      throw Exception("Error generating content: $e");
    }
  }

  Future<Content> getContent(
      {required String message,
      required bool isTextOnly,
      required List<XFile> images}) async {
    if (isTextOnly) {
      // generate text from text-only input
      return Content.text(message);
    } else {
      // generate image from text and image input
      final imageFutures = images
          .map((imageFile) => imageFile.readAsBytes())
          .toList(growable: false);

      final imageBytes = await Future.wait(imageFutures);
      final prompt = TextPart(message);
      final imageParts = imageBytes
          .map((bytes) => DataPart('image/jpeg', Uint8List.fromList(bytes)))
          .toList();

      return Content.multi([...imageParts, prompt]);
    }
  }

  Future<String> sendPromptFile(
      {required String prompt,
      required File file,
      required String fileName}) async {
    final data = await genService.promptDocument(
      fileName,
      'pdf',
      file.readAsBytesSync(),
      prompt,
    );
    return data.text;
  }
}
