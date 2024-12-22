// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models_adapter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveChatBoxAdapter extends TypeAdapter<HiveChatBox> {
  @override
  final int typeId = 0;

  @override
  HiveChatBox read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveChatBox(
      id: fields[0] as String,
      title: fields[1] as String,
      messages: (fields[2] as List).cast<HiveChatBoxMessages>(),
    );
  }

  @override
  void write(BinaryWriter writer, HiveChatBox obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.messages);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveChatBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HiveChatBoxMessagesAdapter extends TypeAdapter<HiveChatBoxMessages> {
  @override
  final int typeId = 1;

  @override
  HiveChatBoxMessages read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveChatBoxMessages(
      text: fields[0] as String,
      isUser: fields[1] as bool,
      visualPath: (fields[2] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, HiveChatBoxMessages obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.text)
      ..writeByte(1)
      ..write(obj.isUser)
      ..writeByte(2)
      ..write(obj.visualPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveChatBoxMessagesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
