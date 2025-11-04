// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlaylistAdapter extends TypeAdapter<Playlist> {
  @override
  final int typeId = 1;

  @override
  Playlist read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Playlist(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      coverUrl: fields[3] as String?,
      musicIds: (fields[4] as List?)?.cast<String>(),
      createdAt: fields[5] as DateTime?,
      updatedAt: fields[6] as DateTime?,
      playCount: fields[7] as int,
      type: fields[8] as PlaylistType,
      isFixed: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Playlist obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.coverUrl)
      ..writeByte(4)
      ..write(obj.musicIds)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.playCount)
      ..writeByte(8)
      ..write(obj.type)
      ..writeByte(9)
      ..write(obj.isFixed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlayHistoryAdapter extends TypeAdapter<PlayHistory> {
  @override
  final int typeId = 2;

  @override
  PlayHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayHistory(
      musicId: fields[0] as String,
      playedAt: fields[1] as DateTime?,
      playDuration: fields[2] as int,
      isCompleted: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PlayHistory obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.musicId)
      ..writeByte(1)
      ..write(obj.playedAt)
      ..writeByte(2)
      ..write(obj.playDuration)
      ..writeByte(3)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FavoriteMusicAdapter extends TypeAdapter<FavoriteMusic> {
  @override
  final int typeId = 3;

  @override
  FavoriteMusic read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteMusic(
      musicId: fields[0] as String,
      favoritedAt: fields[1] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteMusic obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.musicId)
      ..writeByte(1)
      ..write(obj.favoritedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteMusicAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlaylistTypeAdapter extends TypeAdapter<PlaylistType> {
  @override
  final int typeId = 0;

  @override
  PlaylistType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PlaylistType.userCreated;
      case 1:
        return PlaylistType.favorites;
      case 2:
        return PlaylistType.recent;
      case 3:
        return PlaylistType.smart;
      case 4:
        return PlaylistType.recommend;
      default:
        return PlaylistType.userCreated;
    }
  }

  @override
  void write(BinaryWriter writer, PlaylistType obj) {
    switch (obj) {
      case PlaylistType.userCreated:
        writer.writeByte(0);
        break;
      case PlaylistType.favorites:
        writer.writeByte(1);
        break;
      case PlaylistType.recent:
        writer.writeByte(2);
        break;
      case PlaylistType.smart:
        writer.writeByte(3);
        break;
      case PlaylistType.recommend:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
