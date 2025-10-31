/// 媒体资源类型枚举
enum MediaType {
  audio('audio', 'mp3'), // 音频文件
  cover('cover', 'jpg'), // 封面图片
  thumbnail('thumbnail', 'jpg'), // 缩略图
  lyric('lyric', 'lrc'); // 歌词文件

  const MediaType(this.dirName, this.defaultExtension);

  final String dirName; // 在缓存目录中的子目录名
  final String defaultExtension; // 默认文件扩展名

  /// 获取文件扩展名(从URL或使用默认值)
  String getExtension(String? url) {
    if (url != null && url.contains('.')) {
      final ext = url.split('.').last.split('?').first;
      if (ext.isNotEmpty && ext.length <= 5) {
        return ext;
      }
    }
    return defaultExtension;
  }
}

/// 媒体资源模型
class MediaResource {
  /// 资源唯一标识(UUID)
  final String uuid;

  /// 远程URL
  final String remoteUrl;

  /// 资源类型
  final MediaType type;

  /// 本地文件路径(如果已缓存)
  String? localPath;

  /// 文件大小(字节)
  int? fileSize;

  /// 缓存时间
  DateTime? cachedAt;

  /// 最后访问时间
  DateTime? lastAccessedAt;

  /// 访问次数(用于LFU缓存策略)
  int accessCount;

  /// 文件哈希值(用于完整性验证)
  String? fileHash;

  MediaResource({
    required this.uuid,
    required this.remoteUrl,
    required this.type,
    this.localPath,
    this.fileSize,
    this.cachedAt,
    this.lastAccessedAt,
    this.accessCount = 0,
    this.fileHash,
  });

  /// 是否已缓存
  bool get isCached => localPath != null && localPath!.isNotEmpty;

  /// 是否可以访问(本地文件存在)
  bool get isAccessible => isCached;

  /// 从 JSON 创建
  factory MediaResource.fromJson(Map<String, dynamic> json) {
    return MediaResource(
      uuid: json['uuid'] as String,
      remoteUrl: json['remoteUrl'] as String,
      type: MediaType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MediaType.audio,
      ),
      localPath: json['localPath'] as String?,
      fileSize: json['fileSize'] as int?,
      cachedAt: json['cachedAt'] != null
          ? DateTime.parse(json['cachedAt'] as String)
          : null,
      lastAccessedAt: json['lastAccessedAt'] != null
          ? DateTime.parse(json['lastAccessedAt'] as String)
          : null,
      accessCount: (json['accessCount'] as int?) ?? 0,
      fileHash: json['fileHash'] as String?,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'remoteUrl': remoteUrl,
      'type': type.name,
      'localPath': localPath,
      'fileSize': fileSize,
      'cachedAt': cachedAt?.toIso8601String(),
      'lastAccessedAt': lastAccessedAt?.toIso8601String(),
      'accessCount': accessCount,
      'fileHash': fileHash,
    };
  }

  /// 复制并更新字段
  MediaResource copyWith({
    String? uuid,
    String? remoteUrl,
    MediaType? type,
    String? localPath,
    int? fileSize,
    DateTime? cachedAt,
    DateTime? lastAccessedAt,
    int? accessCount,
    String? fileHash,
  }) {
    return MediaResource(
      uuid: uuid ?? this.uuid,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      type: type ?? this.type,
      localPath: localPath ?? this.localPath,
      fileSize: fileSize ?? this.fileSize,
      cachedAt: cachedAt ?? this.cachedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      accessCount: accessCount ?? this.accessCount,
      fileHash: fileHash ?? this.fileHash,
    );
  }

  /// 更新访问信息
  void updateAccessInfo() {
    lastAccessedAt = DateTime.now();
    accessCount++;
  }

  @override
  String toString() {
    return 'MediaResource{uuid: $uuid, type: ${type.name}, cached: $isCached, '
        'localPath: $localPath, accessCount: $accessCount}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MediaResource && other.uuid == uuid && other.type == type;
  }

  @override
  int get hashCode => uuid.hashCode ^ type.hashCode;
}
