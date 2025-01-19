import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:voice_assistant/presentation/controllers/home_controller.dart';
import 'package:voice_assistant/widgets/prompt_messages.dart';

class PromptContainerChild extends StatelessWidget {
  const PromptContainerChild({super.key, required this.ctrl});

  final HomeController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PromptMessagesWidget(ctrl: ctrl, message: ctrl.messages),
          (!ctrl.isLoading.value)
              ? const SizedBox.shrink()
              : Align(
                  alignment: Alignment.centerLeft,
                  child: LoadingAnimationWidget.progressiveDots(
                      color: Colors.grey.shade400, size: 40),
                ),
        ],
      ),
    );
  }
}
