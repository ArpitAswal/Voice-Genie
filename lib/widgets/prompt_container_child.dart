import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:voice_assistant/presentation/controllers/home_controller.dart';
import 'package:voice_assistant/widgets/prompt_messages.dart';

class PromptContainerChild extends StatelessWidget {
  const PromptContainerChild({super.key, required this.ctrl});

  final HomeController ctrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PromptMessagesWidget(ctrl: ctrl, message: ctrl.messages),
        Obx(
          () => (!ctrl.isLoading.value)
              ? const SizedBox.shrink()
              : (ctrl.callImagine.value)
                  ? Align(
                      alignment: Alignment.centerRight,
                      child: Shimmer.fromColors(
                          baseColor: Colors.grey.shade200,
                          highlightColor: Colors.grey.shade400,
                          child: Container(
                              height: Get.height * 0.3,
                              width: Get.width * 0.5,
                              margin: const EdgeInsets.only(right: 12.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.0),
                              ))))
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: LoadingAnimationWidget.progressiveDots(
                          color: Colors.grey.shade400, size: 40),
                    ),
        )
      ],
    );
  }
}
