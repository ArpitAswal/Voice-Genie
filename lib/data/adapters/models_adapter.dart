import 'package:hive/hive.dart';

part 'models_adapter.g.dart';

@HiveType(typeId: 0)
class HiveChatBox extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  List<HiveChatBoxMessages> messages;

  HiveChatBox({required this.id, required this.title, required this.messages});
}

@HiveType(typeId: 1)
class HiveChatBoxMessages extends HiveObject {
  @HiveField(0)
  String text;

  @HiveField(1)
  bool isUser;

  @HiveField(2)
  List<String>? visualPath;

  HiveChatBoxMessages(
      {required this.text, required this.isUser, this.visualPath});
}
