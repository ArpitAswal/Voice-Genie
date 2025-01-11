import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../adapters/models_adapter.dart';

class ChatData {
  final Box<HiveChatBox> chatBox;

  ChatData({required this.chatBox});
  // Fetches chat history for a specific box ID
  List<HiveChatBoxMessages>? getChatHistory(String boxId) {
    final HiveChatBox? chat = chatBox.get(boxId);
    return chat?.messages;
  }

  // Saves a new message to the chat box
  void saveMessage(
      String boxId, String boxTitle, RxList<HiveChatBoxMessages> messages) {
    final chat = chatBox.get(boxId);
    if (chat != null) {
      chat.messages = messages;
      chat.save();
    } else {
      // Create a new chat box if it doesn't exist
      final newChat =
          HiveChatBox(id: boxId, messages: messages, title: boxTitle);
      chatBox.put(boxId, newChat);
    }
  }

  // Retrieves all chat boxes
  List<HiveChatBox> getAllChatBoxes() {
    return chatBox.values.toList();
  }

  HiveChatBox getLastChatBox() {
    final list = getAllChatBoxes();
    return list.last;
  }

  Future<bool> deleteChatBox({required String chatId}) async {
    bool b = await chatBox.delete(chatId).then((value) {
      return true;
    }).catchError((error) {
      return false;
    });
    return b;
  }
}
