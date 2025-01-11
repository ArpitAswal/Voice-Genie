import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:get/get.dart';
import 'package:voice_assistant/widgets/prompt_messages.dart';

import '../../widgets/feature_box.dart';
import '../../widgets/image_prompt.dart';
import '../../widgets/multiple_floating.dart';
import '../../widgets/prompt_container.dart';
import '../../widgets/virtual_assistant_image.dart';
import '../controllers/home_controller.dart';

class PromptScreen extends StatefulWidget {
  const PromptScreen({super.key});

  @override
  State<PromptScreen> createState() => _PromptScreenState();
}

class _PromptScreenState extends State<PromptScreen> {
  final ctrl = Get.find<HomeController>();
  final _scrollController = ScrollController();
  final fabKey1 = GlobalKey<ExpandableFabState>();

  @override
  void initState() {
    super.initState();
    ctrl.checkAlreadyCreated();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0.0) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(seconds: 1),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: ZoomIn(
          delay: const Duration(milliseconds: 800),
          duration: const Duration(milliseconds: 600),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Obx(
              () => (ctrl.isImagePrompt.value)
                  ? navigatingFloating()
                  : MultipleFloating(fabKey: fabKey1),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              height: Get.height * 0.02,
            ),
            const VirtualAssistantImage(),
            FadeIn(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 600),
                child: Obx(() => (ctrl.isImagePrompt.value)
                    ? const ImagePrompt()
                    : (!ctrl.isTextPrompt.value && ctrl.messages.isEmpty)
                        ? initialPrompt()
                        : promptSpace())),
            Obx(
              () => Visibility(
                visible: !ctrl.isTextPrompt.value,
                child: SlideInLeft(
                  delay: const Duration(milliseconds: 200),
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Here are a few features',
                      style: TextStyle(
                        fontFamily: 'Cera',
                        color: Colors.indigo.shade800,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Obx(
              () => Visibility(
                visible: !ctrl.isTextPrompt.value,
                child: Column(
                  children: [
                    SlideInRight(
                      delay: const Duration(milliseconds: 400),
                      duration: const Duration(milliseconds: 600),
                      child: const FeatureBox(
                        headerText: 'Gemini',
                        descriptionText:
                            'A smarter way to stay organized and informed with Gemini AI',
                      ),
                    ),
                    SlideInLeft(
                      delay: const Duration(milliseconds: 600),
                      duration: const Duration(milliseconds: 600),
                      child: const FeatureBox(
                        headerText: 'Imagine AI',
                        descriptionText:
                            'Get inspired and stay creative with your personal assistant powered by Imagine, Your commercial Generative AI solution',
                      ),
                    ),
                    SlideInRight(
                      delay: const Duration(milliseconds: 800),
                      duration: const Duration(milliseconds: 600),
                      child: const FeatureBox(
                        headerText: 'Smart Voice Assistant',
                        descriptionText:
                            'Get the best of both worlds with a voice assistant powered by Imagine and Gemini',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget initialPrompt() {
    return PromptContainer(
        child: AnimatedTextKit(
      key: UniqueKey(),
      animatedTexts: [
        TyperAnimatedText("${ctrl.greetingMessage}, what can I do for you?",
            textStyle: const TextStyle(
                fontFamily: 'Cera', color: Colors.black54, fontSize: 16),
            textAlign: TextAlign.start),
      ],
      isRepeatingAnimation: false,
    ));
  }

  Widget promptSpace() {
    Future.microtask(_scrollToBottom);
    return PromptContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PromptMessagesWidget(message: ctrl.messages, ctrl: ctrl),
          (ctrl.isLoading.value)
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: LoadingAnimationWidget.progressiveDots(
                      color: Colors.grey.shade400, size: 40),
                )
              : const SizedBox.shrink()
        ],
      ),
    );
  }

  Widget navigatingFloating() {
    return FloatingActionButton(
      onPressed: () async {
        if (ctrl.messages.isEmpty) {
          ctrl.isTextPrompt.value = false;
        }
        ctrl.isImagePrompt.value = false;
        ctrl.imagesFileList.clear();
      },
      shape:
          const CircleBorder(side: BorderSide(color: Colors.white, width: 2)),
      backgroundColor: Colors.tealAccent.shade400,
      child: const Icon(
        Icons.arrow_back,
        color: Colors.white,
      ),
    );
  }
}
