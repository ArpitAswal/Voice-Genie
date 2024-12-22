import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../presentation/controllers/home_controller.dart';

class AlertMessages {
  static void showSnackBar(String message, {int? duration}) {
    Get.showSnackbar(GetSnackBar(
        message: message,
        duration: Duration(
          seconds: duration ?? 5,
        ),
        backgroundGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade300, Colors.lightGreenAccent.shade100],
        ),
        boxShadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
        snackPosition: SnackPosition.BOTTOM,
        borderRadius: 20,
        margin: const EdgeInsets.all(12),
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        forwardAnimationCurve: Curves.easeOutBack,
        icon: const Icon(
          Icons.error,
          color: Colors.white,
        ),
        borderColor: Colors.white,
        borderWidth: 2));
  }

  static Future audioBottomSheet(String error) {
    return Get.bottomSheet(
        elevation: 8.0,
        ignoreSafeArea: true,
        persistent: true,
        isDismissible: false,
        enableDrag: false,
        permissionCard(msg: "Error: $error"));
  }

  static Widget permissionCard({required String msg}) {
    return Card(
      elevation: 8,
      shadowColor: Colors.grey[400],
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Container(
        width: Get.width,
        height: Get.height * .12,
        margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 18.0),
        child: SizedBox(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.settings_voice_rounded,
                color: Colors.red,
                size: Get.height * .04,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Audio Record Permission",
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      "$msg Please grant audio record permission to use this feature.",
                      softWrap: true,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                          fontSize: 12,
                          fontFamily: "Cera",
                          color: Colors.black54,
                          fontWeight: FontWeight.w400),
                    )
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(color: Colors.white),
                    backgroundColor: Colors.red[500],
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0))),
                    padding: const EdgeInsets.symmetric(
                        vertical: 2.0, horizontal: 12.0)),
                child: const Text(
                  'Enable',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  Get.find<HomeController>().askPermission();
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void getStoragePermission(
      BuildContext context, HomeController controller) async {
    var status = await Permission.storage.status;
    if (status.isGranted) {
      controller.pickImage();
    } else if (status.isDenied) {
      status = await Permission.storage.request();
      if (status.isGranted) {
        controller.pickImage();
      }
    } else if (status.isPermanentlyDenied) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              elevation: 8,
              shadowColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.0),
              ),
              title: const Text("Photos Permission"),
              content: const Text(
                  "Allow the permission to access photos from device gallery."),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0)
                  .copyWith(bottom: 0),
              actionsPadding: const EdgeInsets.symmetric(vertical: 0),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel")),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      openAppSettings();
                    },
                    child: const Text("Allow"))
              ],
            );
          });
    }
  }

  static Future<dynamic> titleDialog(TextEditingController textController,
      BuildContext context, FocusScopeNode textFocus, String id) async {
    return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: Get.height * 0.2,
          child: AlertDialog(
            titlePadding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 18.0),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            title: const Text('Prompt Box Tile'),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 0.0, horizontal: 18.0),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Enter the new name of the PromptBox.",
                  style: TextStyle(
                      fontFamily: 'Cera', fontWeight: FontWeight.w500),
                ),
                TextField(
                  controller: textController,
                  focusNode: textFocus,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.sentences,
                  autofocus: true,
                  maxLength: 26,
                  cursorColor: Theme.of(context).primaryColor,
                  decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor)),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor)),
                      hintText: "Name...",
                      hintStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontFamily: "Cera")),
                )
              ],
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor),
                child: const Text('Cancel'),
                onPressed: () {
                  textController.clear();
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor),
                child: const Text('Submit'),
                onPressed: () {
                  if (textController.text.isNotEmpty) {
                    Get.find<HomeController>().changeChatBoxTitle(
                        newChatTitle: textController.text, chatId: id);
                    textController.clear();
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<dynamic> deleteDialog(
      BuildContext context, String promptId) async {
    return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: Get.height * 0.2,
          child: AlertDialog(
            titlePadding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 18.0),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            title: const Text('Delete Prompt Box'),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 0.0, horizontal: 18.0),
            content: const Text(
              "Are you sure you want to delete this PromptBox permanently.",
              style: TextStyle(fontFamily: 'Cera', fontWeight: FontWeight.w500),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor),
                child: const Text('NO'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor),
                  child: const Text('YES'),
                  onPressed: () {
                    Get.find<HomeController>().deleteChatBox(chatId: promptId);
                  }),
            ],
          ),
        );
      },
    );
  }
}
