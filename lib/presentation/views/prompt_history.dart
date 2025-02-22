import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:get/get.dart';
import 'package:voice_assistant/data/adapters/models_adapter.dart';
import 'package:voice_assistant/presentation/controllers/home_controller.dart';
import 'package:voice_assistant/widgets/prompt_container.dart';
import 'package:voice_assistant/widgets/prompt_container_child.dart';
import 'package:voice_assistant/widgets/virtual_assistant_image.dart';

import '../../widgets/image_prompt.dart';
import '../../widgets/multiple_floating.dart';

class PromptHistoryScreen extends StatefulWidget {
  const PromptHistoryScreen(
      {super.key,
      required this.promptId,
      required this.promptTitle,
      required this.promptMessages,
      required this.ctrl});

  final List<HiveChatBoxMessages> promptMessages;
  final String promptId;
  final String promptTitle;
  final HomeController ctrl;

  @override
  State<PromptHistoryScreen> createState() => _PromptHistoryScreenState();
}

class _PromptHistoryScreenState extends State<PromptHistoryScreen> {
  final GlobalKey<ExpandableFabState> fabKey2 = GlobalKey<ExpandableFabState>();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.ctrl.isNewPrompt.value = false;
    widget.ctrl.isTextPrompt.value = true;
    widget.ctrl.setCurrentChatId(newChatId: widget.promptId);
    widget.ctrl.changeChatBoxTitle(newChatTitle: widget.promptTitle);
    widget.ctrl.messages.value = widget.promptMessages.map((e) => e).toList();
  }

  @override
  void dispose() {
    super.dispose();
    widget.ctrl.setCurrentChatId(newChatId: "");
    widget.ctrl.changeChatBoxTitle(newChatTitle: "");
    widget.ctrl.isNewPrompt.value = true;
    widget.ctrl.isTextPrompt.value = false;
    _scrollController.dispose();
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
            onPressed: Navigator.of(context).pop,
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        title: BounceInDown(
            child: Text(
          widget.promptTitle,
          style:
              const TextStyle(fontWeight: FontWeight.w400, fontFamily: "Cera"),
        )),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.attach_file,
              color: Colors.white,
            ),
            onPressed: () {
              widget.ctrl.pickFile();
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.photo_library,
              color: Colors.white,
            ),
            onPressed: () {
              widget.ctrl.pickImage();
            },
          )
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
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Obx(
            () => (widget.ctrl.isImagePrompt.value)
                ? navigatingFloating()
                : MultipleFloating(fabKey: fabKey2),
          ),
        ),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(children: [
          SizedBox(
            height: Get.height * 0.02,
          ),
          const VirtualAssistantImage(),
          Obx(() => AnimatedSwitcher(
                duration:
                    const Duration(milliseconds: 600), // Animation duration
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: PromptContainer(
                  key: ValueKey<bool>(widget.ctrl.isImagePrompt.value),
                  child: (widget.ctrl.isImagePrompt.value)
                      ? const ImagePrompt()
                      : promptSpace(),
                ),
              ))
        ]),
      ),
    );
  }

  Widget navigatingFloating() {
    return FloatingActionButton(
      onPressed: () async {
        widget.ctrl.isImagePrompt.value = false;
        widget.ctrl.isTextPrompt.value = true;
        widget.ctrl.imagesFileList.clear();
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

  Widget promptSpace() {
    Future.microtask(_scrollToBottom);
    return PromptContainerChild(ctrl: widget.ctrl);
  }
}
