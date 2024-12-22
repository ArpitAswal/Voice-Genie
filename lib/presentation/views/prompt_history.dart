import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:voice_assistant/data/adapters/models_adapter.dart';
import 'package:voice_assistant/presentation/controllers/home_controller.dart';
import 'package:voice_assistant/utils/alert_messages.dart';
import 'package:voice_assistant/widgets/prompt_container.dart';
import 'package:voice_assistant/widgets/prompt_messages.dart';
import 'package:voice_assistant/widgets/virtual_assistant_image.dart';

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
    _scrollController.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0.0) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(seconds: 3),
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
            onPressed: widget.ctrl.pickFile,
          ),
          IconButton(
            icon: const Icon(
              Icons.photo_library,
              color: Colors.white,
            ),
            onPressed: () {
              AlertMessages.getStoragePermission(context, widget.ctrl);
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
      floatingActionButton: Obx(
        () => (widget.ctrl.isImagePrompt.value)
            ? navigatingFloating()
            : MultipleFloating(fabKey: fabKey2),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(children: [
          SizedBox(
            height: Get.height * 0.02,
          ),
          const VirtualAssistantImage(),
          PromptContainer(child: Obx(() {
            Future.microtask(_scrollToBottom);
            return (widget.ctrl.messages.isEmpty)
                ? Align(
                    alignment: Alignment.centerRight,
                    child: LoadingAnimationWidget.progressiveDots(
                        color: Colors.grey.shade400, size: 40))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PromptMessagesWidget(
                          ctrl: widget.ctrl, message: widget.ctrl.messages),
                      (widget.ctrl.isLoading.value)
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: LoadingAnimationWidget.progressiveDots(
                                  color: Colors.grey.shade400, size: 40),
                            )
                          : const SizedBox.shrink()
                    ],
                  );
          })),
        ]),
      ),
    );
  }

  Widget navigatingFloating() {
    return FloatingActionButton(
      onPressed: () async {
        widget.ctrl.isImagePrompt.value = false;
        widget.ctrl.isTextPrompt.value = false;
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
}
