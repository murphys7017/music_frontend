import 'package:hive/hive.dart';

part 'playlist.g.dart';

/// 歌单类型
@HiveType(typeId: 0)
enum PlaylistType {
  @HiveField(0)
  userCreated, // 用户创建

  @HiveField(1)
  favorites, // 我喜欢的

  @HiveField(2)
  recent, // 最近播放

  @HiveField(3)
  smart, // 智能歌单
}

/// 歌单模型
@HiveType(typeId: 1)
class Playlist extends HiveObject {
  /// 歌单 UUID
  @HiveField(0)
  late String id;

  /// 歌单名称
  @HiveField(1)
  late String name;

  /// 描述
  @HiveField(2)
  String? description;

  /// 封面 URL 或本地路径
  @HiveField(3)
  String? coverUrl;

  /// 音乐 UUID 列表（有序）
  @HiveField(4)
  late List<String> musicIds;

  /// 创建时间
  @HiveField(5)
  late DateTime createdAt;

  /// 更新时间
  @HiveField(6)
  late DateTime updatedAt;

  /// 播放次数
  @HiveField(7)
  int playCount;

  /// 歌单类型
  @HiveField(8)
  late PlaylistType type;

  /// 是否固定（不可删除）
  @HiveField(9)
  bool isFixed;

  Playlist({
    required this.id,
    required this.name,
    this.description,
    this.coverUrl,
    List<String>? musicIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.playCount = 0,
    required this.type,
    this.isFixed = false,
  }) : musicIds = musicIds ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// 音乐数量
  int get musicCount => musicIds.length;

  /// 是否为空歌单
  bool get isEmpty => musicIds.isEmpty;

  /// 添加音乐
  void addMusic(String musicId) {
    if (!musicIds.contains(musicId)) {
      musicIds.add(musicId);
      updatedAt = DateTime.now();
    }
  }

  /// 批量添加音乐
  void addMusicList(List<String> ids) {
    for (final id in ids) {
      if (!musicIds.contains(id)) {
        musicIds.add(id);
      }
    }
    updatedAt = DateTime.now();
  }

  /// 移除音乐
  void removeMusic(String musicId) {
    if (musicIds.remove(musicId)) {
      updatedAt = DateTime.now();
    }
  }

  /// 移动音乐位置
  void reorderMusic(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= musicIds.length) return;
    if (newIndex < 0 || newIndex >= musicIds.length) return;

    final musicId = musicIds.removeAt(oldIndex);
    musicIds.insert(newIndex, musicId);
    updatedAt = DateTime.now();
  }

  /// 清空歌单
  void clear() {
    musicIds.clear();
    updatedAt = DateTime.now();
  }

  /// 更新封面
  void updateCover(String? newCoverUrl) {
    coverUrl = newCoverUrl;
    updatedAt = DateTime.now();
  }

  /// 增加播放次数
  void incrementPlayCount() {
    playCount++;
    updatedAt = DateTime.now();
  }

  /// 复制并更新字段
  Playlist copyWith({
    String? id,
    String? name,
    String? description,
    String? coverUrl,
    List<String>? musicIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? playCount,
    PlaylistType? type,
    bool? isFixed,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      musicIds: musicIds ?? List<String>.from(this.musicIds),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      playCount: playCount ?? this.playCount,
      type: type ?? this.type,
      isFixed: isFixed ?? this.isFixed,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coverUrl': coverUrl,
      'musicIds': musicIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'playCount': playCount,
      'type': type.name,
      'isFixed': isFixed,
      'musicCount': musicCount,
    };
  }

  /// 从 JSON 创建
  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      coverUrl: json['coverUrl'] as String?,
      musicIds:
          (json['musicIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      playCount: (json['playCount'] as num?)?.toInt() ?? 0,
      type: PlaylistType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PlaylistType.userCreated,
      ),
      isFixed: json['isFixed'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'Playlist{id: $id, name: $name, musicCount: $musicCount, type: ${type.name}}';
  }
}

/// 播放历史模型
@HiveType(typeId: 2)
class PlayHistory extends HiveObject {
  /// 音乐 UUID
  @HiveField(0)
  late String musicId;

  /// 播放时间
  @HiveField(1)
  late DateTime playedAt;

  /// 播放时长（秒）
  @HiveField(2)
  int playDuration;

  /// 是否播放完成
  @HiveField(3)
  bool isCompleted;

  PlayHistory({
    required this.musicId,
    DateTime? playedAt,
    this.playDuration = 0,
    this.isCompleted = false,
  }) : playedAt = playedAt ?? DateTime.now();

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'musicId': musicId,
      'playedAt': playedAt.toIso8601String(),
      'playDuration': playDuration,
      'isCompleted': isCompleted,
    };
  }

  /// 从 JSON 创建
  factory PlayHistory.fromJson(Map<String, dynamic> json) {
    return PlayHistory(
      musicId: json['musicId'] as String,
      playedAt: json['playedAt'] != null
          ? DateTime.parse(json['playedAt'] as String)
          : DateTime.now(),
      playDuration: (json['playDuration'] as num?)?.toInt() ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'PlayHistory{musicId: $musicId, playedAt: $playedAt, duration: ${playDuration}s}';
  }
}

/// 收藏音乐模型
@HiveType(typeId: 3)
class FavoriteMusic extends HiveObject {
  /// 音乐 UUID
  @HiveField(0)
  late String musicId;

  /// 收藏时间
  @HiveField(1)
  late DateTime favoritedAt;

  FavoriteMusic({required this.musicId, DateTime? favoritedAt})
    : favoritedAt = favoritedAt ?? DateTime.now();

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {'musicId': musicId, 'favoritedAt': favoritedAt.toIso8601String()};
  }

  /// 从 JSON 创建
  factory FavoriteMusic.fromJson(Map<String, dynamic> json) {
    return FavoriteMusic(
      musicId: json['musicId'] as String,
      favoritedAt: json['favoritedAt'] != null
          ? DateTime.parse(json['favoritedAt'] as String)
          : DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'FavoriteMusic{musicId: $musicId, favoritedAt: $favoritedAt}';
  }
}
