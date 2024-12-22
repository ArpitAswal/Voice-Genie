import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:voice_assistant/data/adapters/models_adapter.dart';

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
      children: message.asMap().entries.map((entry) {
        final index = entry.key;
        final msg = entry.value;

        // Check if it's the last message
        final isLastMessage = index == message.length - 1;

        if (msg.isUser && msg.visualPath != null) {
          return Align(
            alignment: Alignment.centerRight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: (msg.visualPath!.length == 1)
                      ? width * 0.25
                      : width * 0.5,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        spreadRadius: 1.0,
                        blurRadius: 6.0,
                      ),
                    ],
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.shade300,
                        Colors.lightGreenAccent.shade100
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24).copyWith(
                        topLeft: Radius.zero, bottomRight: Radius.zero),
                  ),
                  child: ImageGridView(images: msg.visualPath!),
                ),
                Text(
                  "Prompt: ${msg.text}",
                  softWrap: true,
                  style: const TextStyle(
                    fontFamily: 'Cera',
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        } else {
          return (isLastMessage && ctrl.shouldTextAnimate.value)
              ? AnimatedTextKit(
                  onFinished: () {
                    ctrl.shouldTextAnimate.value = false;
                  },
                  onTap: () {
                    ctrl.shouldTextAnimate.value = false;
                  },
                  displayFullTextOnTap: true,
                  animatedTexts: [
                    TyperAnimatedText(
                      speed: const Duration(milliseconds: 45),
                      msg.isUser
                          ? "Prompt: ${msg.text}"
                          : "Response: ${msg.text}",
                      textStyle: TextStyle(
                        fontFamily: 'Cera',
                        color: msg.isUser
                            ? Colors.black87
                            : (msg.text == "Failed")
                                ? Colors.red
                                : Colors.grey,
                        fontSize: 16,
                      ),
                      textAlign: (!msg.isUser && msg.text == "Failed")
                          ? TextAlign.end
                          : TextAlign.start,
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
                        : (msg.text == "Failed")
                            ? Colors.red
                            : Colors.grey,
                    fontSize: 16,
                  ),
                  textAlign: (!msg.isUser && msg.text == "Failed")
                      ? TextAlign.end
                      : TextAlign.start,
                );
        }
      }).toList(),
    );
  }
}
