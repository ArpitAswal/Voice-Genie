import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/config.dart';

class GenerateContentUseCase {
  late GenerativeModel generativeModel;

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
      required String message,
      required bool isTextOnly,
      required List<XFile> images}) async {
    try {
      final content = await getContent(
          message: message, isTextOnly: isTextOnly, images: images);
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

      return Content.multi([prompt, ...imageParts]);
    }
  }
}
