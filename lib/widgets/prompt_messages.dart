import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:voice_assistant/data/adapters/models_adapter.dart';
import 'package:voice_assistant/widgets/image_background.dart';

import '../presentation/controllers/home_controller.dart';
import 'image_gridview.dart';

class PromptMessagesWidget extends StatelessWidget {
  const PromptMessagesWidget(
      {super.key, required this.ctrl, required this.message});

  final List<HiveChatBoxMessages> message;
  final HomeController ctrl;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: message.map((msg) {
        // Combine media and text messages
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (msg.isUser &&
                (msg.imagePath != null || msg.filePath != null)) ...[
              buildMediaMessage(width, msg),
              Text(
                "Prompt: ${msg.text}",
                style: const TextStyle(
                  fontFamily: 'Cera',
                  color: Colors.black87,
                  fontSize: 16,
                ),
              ),
            ] else ...[
              buildTextMessage(msg),
              if (msg.imagePath != null)
                ImageBackground(
                  maxWidth: width * 0.5,
                  minWidth: width * 0.25,
                  childWidget: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.file(
                      File(msg.imagePath![0]),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
            ],
          ],
        );
      }).toList(),
    );
  }

  // Widget for image or file messages
  Widget buildMediaMessage(double width, HiveChatBoxMessages msg) {
    return ImageBackground(
      maxWidth: width *
          (msg.imagePath != null && msg.imagePath!.length <= 4 ? 0.5 : 0.75),
      minWidth: width * 0.25,
      childWidget: msg.imagePath != null
          ? ImageGridView(images: msg.imagePath!)
          : Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.picture_as_pdf,
                    color: Colors.red.shade300, size: 30),
                SizedBox(width: width * 0.015),
                Flexible(
                  child: Text(
                    msg.filePath!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: "Cera",
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // Widget for text message
  Widget buildTextMessage(HiveChatBoxMessages msg) {
    final isLastMessage = message.indexOf(msg) == message.length - 1;
    final shouldAnimate = isLastMessage && ctrl.shouldTextAnimate.value;

    return shouldAnimate
        ? AnimatedTextKit(
            onFinished: () => ctrl.shouldTextAnimate.value = false,
            animatedTexts: [
              TyperAnimatedText(
                "Response: ${msg.text}",
                speed: const Duration(milliseconds: 60),
                textStyle: TextStyle(
                  fontFamily: 'Cera',
                  color: (msg.text.startsWith("Sorry,"))
                      ? Colors.redAccent
                      : Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
            isRepeatingAnimation: false,
          )
        : Text(
            msg.isUser ? "Prompt: ${msg.text}" : "Response: ${msg.text}",
            style: TextStyle(
              fontFamily: 'Cera',
              color: msg.isUser
                  ? Colors.black87
                  : (msg.text.startsWith("Sorry,"))
                      ? Colors.redAccent
                      : Colors.grey,
              fontSize: 16,
            ),
          );
  }
}
