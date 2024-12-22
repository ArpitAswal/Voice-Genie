import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voice_assistant/presentation/views/prompt_history.dart';
import 'package:voice_assistant/utils/alert_messages.dart';

import '../controllers/home_controller.dart';

class PreviousPromptsScreen extends StatefulWidget {
  const PreviousPromptsScreen({
    super.key,
  });

  @override
  State<PreviousPromptsScreen> createState() => _PreviousPromptsScreenState();
}

class _PreviousPromptsScreenState extends State<PreviousPromptsScreen> {
  final controller = Get.find<HomeController>();
  final textFocus = FocusScopeNode();
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.totalChatBoxes.isEmpty
          ? const Center(
              child: Text("No Chat/Prompt Box Created Yet!"),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              itemCount: controller.totalChatBoxes.length,
              itemBuilder: (context, index) {
                final chat = controller.totalChatBoxes[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PromptHistoryScreen(
                                promptId: chat.id,
                                promptTitle: chat.title,
                                promptMessages: chat.messages,
                                ctrl: controller)));
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 6.0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: Colors.lightBlue,
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 2.0,
                            spreadRadius: 1.0),
                        const BoxShadow(
                            color: Colors.black38,
                            blurRadius: 4.0,
                            spreadRadius: 1.0)
                      ],
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.shade300,
                          Colors.lightGreenAccent.shade100
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const CircleAvatar(
                            backgroundImage:
                                AssetImage("assets/images/botImage.jpg")),
                        Flexible(
                          child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                chat.title,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontFamily: 'Cera',
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                            highlightColor: Colors.redAccent,
                            onTap: () {
                              AlertMessages.titleDialog(
                                  textController, context, textFocus, chat.id);
                              textFocus.requestFocus();
                            },
                            child: const Icon(
                              Icons.edit_rounded,
                              color: Colors.lightBlue,
                            )),
                        IconButton(
                            color: Colors.lightBlue,
                            highlightColor: Colors.redAccent,
                            padding: const EdgeInsets.all(0),
                            onPressed: () =>
                                AlertMessages.deleteDialog(context, chat.id),
                            icon: const Icon(
                              Icons.delete_forever_rounded,
                            )),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
