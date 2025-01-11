import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voice_assistant/widgets/preview_images.dart';
import 'package:voice_assistant/widgets/prompt_container.dart';

import '../presentation/controllers/home_controller.dart';
import '../utils/alert_messages.dart';

class ImagePrompt extends StatefulWidget {
  const ImagePrompt({super.key});

  @override
  State<ImagePrompt> createState() => _ImagePromptState();
}

class _ImagePromptState extends State<ImagePrompt> with WidgetsBindingObserver {
  final TextEditingController editController = TextEditingController();
  final FocusScopeNode textFieldFocus = FocusScopeNode();
  final ctrl = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    ctrl.imagesFileList.clear();
    ctrl.filePath.value = "";
    WidgetsBinding.instance.removeObserver(this);
    editController.dispose();
    textFieldFocus.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (editController.text.isEmpty) {
        textFieldFocus.requestScopeFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PromptContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PreviewImages(),
          TextFormField(
            controller: editController,
            showCursor: true,
            focusNode: textFieldFocus,
            maxLines: null,
            cursorColor: Colors.black45,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.sentences,
            canRequestFocus: true,
            decoration: InputDecoration(
                border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black45, width: 2)),
                enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black45, width: 2)),
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black45, width: 2)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
                hintText: "prompt...",
                filled: true,
                fillColor: Colors.grey.shade200,
                hintStyle: const TextStyle(
                    fontFamily: 'Cera', color: Colors.black54, fontSize: 16),
                suffix: InkWell(
                    onTap: () {
                      (ctrl.imagesFileList.isEmpty && ctrl.filePath.isEmpty)
                          ? AlertMessages.showSnackBar(
                              "Add at least one image/file.")
                          : (editController.text.isEmpty)
                              ? AlertMessages.showSnackBar(
                                  "write the prompt for images/files")
                              : (ctrl.imagesFileList.isNotEmpty)
                                  ? ctrl.sendPrompt(editController.text)
                                  : ctrl.uploadPdf(editController.text);
                      editController.clear();
                    },
                    child: const Icon(Icons.send_rounded))),
          ),
        ],
      ),
    );
  }
}
