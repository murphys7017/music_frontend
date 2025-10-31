/// 音乐数据模型
class Music {
  final String uuid;
  final String name;
  final String author;
  final String? album;
  final int duration; // 秒
  final int size; // 字节
  final int bitrate; // kbps
  final String? coverUuid;
  final int playCount;
  final String playUrl;
  final String? coverUrl;

  Music({
    required this.uuid,
    required this.name,
    required this.author,
    this.album,
    required this.duration,
    required this.size,
    required this.bitrate,
    this.coverUuid,
    required this.playCount,
    required this.playUrl,
    this.coverUrl,
  });

  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      uuid: json['uuid'] as String? ?? '',
      name: json['name'] as String? ?? '未知歌曲',
      author: json['author'] as String? ?? '未知歌手',
      album: json['album'] as String?,
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? 0,
      bitrate: (json['bitrate'] as num?)?.toInt() ?? 0,
      coverUuid: json['cover_uuid'] as String?,
      playCount: (json['play_count'] as num?)?.toInt() ?? 0,
      playUrl: json['play_url'] as String? ?? '',
      coverUrl: json['cover_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'author': author,
      'album': album,
      'duration': duration,
      'size': size,
      'bitrate': bitrate,
      'cover_uuid': coverUuid,
      'play_count': playCount,
      'play_url': playUrl,
      'cover_url': coverUrl,
    };
  }

  /// 格式化时长为 mm:ss
  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 格式化文件大小
  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// 音乐列表响应
class MusicListResponse {
  final int total;
  final int page;
  final int pageSize;
  final List<Music> items;

  MusicListResponse({
    required this.total,
    required this.page,
    required this.pageSize,
    required this.items,
  });

  factory MusicListResponse.fromJson(Map<String, dynamic> json) {
    // 处理后端返回的包装结构 {code, message, data}
    final data = json['data'] ?? json;

    return MusicListResponse(
      total: (data['total'] as num?)?.toInt() ?? 0,
      page: (data['page'] as num?)?.toInt() ?? 1,
      pageSize: (data['page_size'] as num?)?.toInt() ?? 20,
      // 支持 'list' 和 'items' 两种字段名
      items:
          (data['list'] as List? ?? data['items'] as List?)
              ?.map((item) => Music.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  bool get hasMore => page * pageSize < total;
  int get totalPages => (total / pageSize).ceil();
}

/// 歌词模型
class Lyric {
  final String musicUuid;
  final String content;

  Lyric({required this.musicUuid, required this.content});

  factory Lyric.fromJson(Map<String, dynamic> json) {
    return Lyric(
      musicUuid: json['music_uuid'] as String? ?? '',
      content: json['content'] as String? ?? json['lyric'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'music_uuid': musicUuid, 'content': content};
  }
}
