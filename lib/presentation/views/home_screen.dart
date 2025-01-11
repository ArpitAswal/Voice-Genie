import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:voice_assistant/domain/usecases/generate_content.dart';
import 'package:voice_assistant/presentation/views/prompt_screen.dart';
import 'package:voice_assistant/presentation/views/previous_prompts.dart';
import 'package:voice_assistant/utils/alert_messages.dart';

import '../../data/hivedata/chat_data.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final controller = Get.put(
      HomeController(
          chatData: ChatData(chatBox: Hive.box('ChatBoxesHistories')),
          generateContent: GenerateContentUseCase()),
      permanent: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(
            child: const Text(
          "Voice Genie",
          style: TextStyle(fontWeight: FontWeight.w400, fontFamily: "Cera"),
        )),
        actions: [
          Obx(() => (controller.currentIndex.value == 0)
              ? IconButton(
                  icon: const Icon(
                    Icons.attach_file,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    bool b = await AlertMessages.getStoragePermission();
                    if (b) {
                      controller.pickFile();
                    } else {
                      AlertMessages.alertPermission(context);
                    }
                  })
              : const SizedBox.shrink()),
          Obx(() => (controller.currentIndex.value == 0)
              ? IconButton(
                  icon: const Icon(
                    Icons.photo_library,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    bool b = await AlertMessages.getStoragePermission();
                    if (b) {
                      controller.pickImage();
                    } else {
                      AlertMessages.alertPermission(context);
                    }
                  })
              : const SizedBox.shrink())
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade300, Colors.lightGreenAccent.shade100],
            ),
          ),
        ),
      ),
      body: PageView(
        controller: controller.pageController,
        onPageChanged: (index) {
          controller.currentIndexValue(index);
        },
        children: const [
          PromptScreen(),
          PreviousPromptsScreen(),
        ],
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          elevation: 12.0,
          unselectedItemColor: Colors.grey,
          selectedItemColor: Colors.tealAccent.shade400,
          currentIndex: controller.currentIndex.value,
          onTap: (index) {
            controller.pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            controller.currentIndexValue(index);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.chat,
              ),
              label: 'Prompt',
            ),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.history,
                ),
                label: 'History'),
          ],
        ),
      ),
    );
  }
}
