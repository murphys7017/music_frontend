# 文件映射模块使用指南

## 概述

文件映射模块 (Media Map Service) 提供了 UUID 到本地文件路径的映射管理功能。这是实现本地缓存和远程流媒体混合播放的基础模块。

## 核心组件

### 1. MediaType (媒体类型枚举)

```dart
enum MediaType {
  audio,      // 音频文件 (.mp3)
  cover,      // 封面图片 (.jpg)
  thumbnail,  // 缩略图 (.jpg)
  lyric,      // 歌词文件 (.lrc)
}
```

每个类型都有:
- `dirName`: 在缓存目录中的子目录名
- `defaultExtension`: 默认文件扩展名

### 2. MediaResource (媒体资源模型)

```dart
class MediaResource {
  final String uuid;           // 资源唯一标识
  final String remoteUrl;      // 远程URL
  final MediaType type;        // 资源类型
  String? localPath;           // 本地路径(如果已缓存)
  int? fileSize;               // 文件大小(字节)
  DateTime? cachedAt;          // 缓存时间
  DateTime? lastAccessedAt;    // 最后访问时间
  int accessCount;             // 访问次数
  String? fileHash;            // 文件哈希值
  
  bool get isCached;           // 是否已缓存
  bool get isAccessible;       // 是否可访问
}
```

### 3. MediaMapService (映射服务)

单例服务,管理所有资源映射关系。

## 目录结构

```
ApplicationDocuments/
└── media_cache/
    ├── audio/          # 音频文件缓存目录
    ├── cover/          # 封面图片缓存目录
    ├── thumbnail/      # 缩略图缓存目录
    └── lyric/          # 歌词文件缓存目录
```

## 基本使用

### 初始化服务

```dart
import 'package:music_frontend/services/media_map_service.dart';

final mapService = MediaMapService();

// 应用启动时初始化
await mapService.initialize();
```

### 添加映射

```dart
// 创建资源对象
final resource = MediaResource(
  uuid: 'audio-uuid-12345',
  remoteUrl: 'http://127.0.0.1:8000/music/play/1',
  type: MediaType.audio,
  localPath: '/path/to/cache/audio/audio-uuid-12345.mp3',
  fileSize: 5242880,  // 5MB
  cachedAt: DateTime.now(),
);

// 添加映射
await mapService.mapResource(resource);
```

### 批量添加映射

```dart
final resources = [
  MediaResource(
    uuid: 'audio-uuid-001',
    remoteUrl: 'http://example.com/audio/1',
    type: MediaType.audio,
  ),
  MediaResource(
    uuid: 'cover-uuid-001',
    remoteUrl: 'http://example.com/cover/1',
    type: MediaType.cover,
  ),
];

await mapService.mapResources(resources);
```

### 查询映射

```dart
// 检查是否已映射
bool isMapped = mapService.isMapped('audio-uuid-001', type: MediaType.audio);

// 获取资源对象
MediaResource? resource = mapService.getResource('audio-uuid-001', type: MediaType.audio);

// 仅获取本地路径
String? localPath = mapService.getLocalPath('audio-uuid-001', type: MediaType.audio);

// 获取所有资源
List<MediaResource> allResources = mapService.getAllResources();

// 获取特定类型的所有资源
List<MediaResource> audioResources = mapService.getAllResources(type: MediaType.audio);
```

### 更新访问信息

```dart
// 每次访问资源时更新访问信息(用于LRU/LFU缓存策略)
await mapService.updateAccessInfo('audio-uuid-001', type: MediaType.audio);

// 这会自动更新:
// - lastAccessedAt: 最后访问时间
// - accessCount: 访问次数 +1
```

### 验证本地文件

```dart
// 验证本地文件是否真实存在
bool exists = await mapService.verifyLocalFile('audio-uuid-001', type: MediaType.audio);

// 如果文件不存在,会自动清理映射关系
```

### 移除映射

```dart
// 移除指定类型的映射
await mapService.removeMapping('audio-uuid-001', type: MediaType.audio);

// 移除该UUID的所有类型映射
await mapService.removeAllMappings('audio-uuid-001');
```

### 获取统计信息

```dart
final stats = await mapService.getStatistics();

print('Total files: ${stats.totalFiles}');
print('Total size: ${stats.formattedTotalSize}');
print('Audio files: ${stats.typeCounts[MediaType.audio]}');
print('Cover files: ${stats.typeCounts[MediaType.cover]}');

// 输出完整统计
print(stats.toString());
```

输出示例:
```
CacheStatistics{
  totalFiles: 10,
  totalSize: 52.43 MB,
  audio: 5 files (48.20 MB),
  cover: 3 files (3.52 MB),
  thumbnail: 0 files (0 B),
  lyric: 2 files (0.71 MB)
}
```

## 高级使用

### 在播放器中集成

```dart
class MusicPlayerService {
  final MediaMapService _mapService = MediaMapService();
  
  Future<void> playMusic(String audioUuid, String remoteUrl) async {
    // 1. 检查本地是否有缓存
    if (_mapService.isMapped(audioUuid, type: MediaType.audio)) {
      // 验证文件是否存在
      final exists = await _mapService.verifyLocalFile(audioUuid, type: MediaType.audio);
      
      if (exists) {
        // 使用本地文件
        final localPath = _mapService.getLocalPath(audioUuid, type: MediaType.audio);
        await _player.setFilePath(localPath!);
        
        // 更新访问信息
        await _mapService.updateAccessInfo(audioUuid, type: MediaType.audio);
        
        Logger.info('Playing from local cache: $localPath');
        return;
      }
    }
    
    // 2. 本地没有,使用远程URL
    await _player.setUrl(remoteUrl);
    Logger.info('Playing from remote: $remoteUrl');
    
    // 3. (可选) 后台下载并缓存
    _downloadAndCache(audioUuid, remoteUrl);
  }
  
  Future<void> _downloadAndCache(String uuid, String url) async {
    // 下载逻辑...
    // 下载完成后添加映射
    final resource = MediaResource(
      uuid: uuid,
      remoteUrl: url,
      type: MediaType.audio,
      localPath: downloadedPath,
      fileSize: fileSize,
      cachedAt: DateTime.now(),
    );
    await _mapService.mapResource(resource);
  }
}
```

### 封面图片集成

```dart
class CoverImageWidget extends StatelessWidget {
  final String coverUuid;
  final String remoteUrl;
  
  @override
  Widget build(BuildContext context) {
    final mapService = MediaMapService();
    final localPath = mapService.getLocalPath(coverUuid, type: MediaType.cover);
    
    if (localPath != null) {
      // 使用本地缓存
      return Image.file(File(localPath));
    } else {
      // 使用网络图片,并在加载后缓存
      return CachedNetworkImage(
        imageUrl: remoteUrl,
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.error),
      );
    }
  }
}
```

## API 参考

### MediaMapService 方法

| 方法 | 说明 | 返回值 |
|------|------|--------|
| `initialize()` | 初始化服务 | `Future<void>` |
| `isMapped(uuid, type)` | 检查是否已映射 | `bool` |
| `getResource(uuid, type)` | 获取资源对象 | `MediaResource?` |
| `getLocalPath(uuid, type)` | 获取本地路径 | `String?` |
| `mapResource(resource)` | 添加/更新映射 | `Future<void>` |
| `mapResources(resources)` | 批量添加映射 | `Future<void>` |
| `removeMapping(uuid, type)` | 移除映射 | `Future<void>` |
| `removeAllMappings(uuid)` | 移除所有类型映射 | `Future<void>` |
| `verifyLocalFile(uuid, type)` | 验证本地文件 | `Future<bool>` |
| `updateAccessInfo(uuid, type)` | 更新访问信息 | `Future<void>` |
| `getAllResources(type)` | 获取所有资源 | `List<MediaResource>` |
| `getMappingCount(type)` | 获取映射数量 | `int` |
| `getStatistics()` | 获取统计信息 | `Future<CacheStatistics>` |
| `clearAll()` | 清空所有映射 | `Future<void>` |

### MediaResource 方法

| 方法 | 说明 | 返回值 |
|------|------|--------|
| `fromJson(json)` | 从JSON创建 | `MediaResource` |
| `toJson()` | 转换为JSON | `Map<String, dynamic>` |
| `copyWith(...)` | 复制并更新 | `MediaResource` |
| `updateAccessInfo()` | 更新访问信息 | `void` |

### CacheStatistics 属性

| 属性 | 说明 | 类型 |
|------|------|------|
| `totalFiles` | 总文件数 | `int` |
| `totalSizeBytes` | 总大小(字节) | `int` |
| `formattedTotalSize` | 格式化的总大小 | `String` |
| `typeCounts` | 各类型文件数 | `Map<MediaType, int>` |
| `typeSizes` | 各类型大小 | `Map<MediaType, int>` |

## 运行测试

我们提供了完整的测试示例:

```bash
flutter run -d windows lib/main_media_map_test.dart
```

测试内容包括:
1. ✅ 添加音频映射
2. ✅ 添加封面映射
3. ✅ 批量映射
4. ✅ 更新访问信息
5. ✅ 获取统计信息
6. ✅ 移除映射
7. ✅ 获取所有资源

## 注意事项

### 1. 线程安全
当前版本的 `MediaMapService` 是单例模式,但**不是线程安全**的。如果需要在多线程环境使用,请添加锁机制。

### 2. 持久化存储
当前版本的映射关系仅保存在内存中。应用重启后会丢失。**建议集成 Hive 进行持久化**。

### 3. 文件验证
定期调用 `verifyLocalFile()` 验证文件完整性,自动清理失效映射。

### 4. 内存管理
如果映射数量很大(>10000),考虑分页加载或懒加载策略。

## 下一步计划

- [ ] **Hive 持久化**: 将映射关系持久化到本地数据库
- [ ] **文件下载器**: 实现自动下载和缓存功能
- [ ] **缓存策略**: LRU/LFU 自动清理
- [ ] **完整性校验**: 使用文件哈希验证完整性
- [ ] **并发控制**: 添加下载队列和并发限制
- [ ] **断点续传**: 支持大文件断点续传

## 相关文件

- `lib/models/media_resource.dart` - 媒体资源数据模型
- `lib/services/media_map_service.dart` - 文件映射服务
- `lib/main_media_map_test.dart` - 测试示例

## 更新日志

### 2025-11-01
- ✅ 创建 MediaResource 数据模型
- ✅ 实现 MediaMapService 核心功能
- ✅ 添加完整的测试示例
- ✅ 支持统计信息查询
- ✅ 支持文件验证功能

---

**文档版本**: v1.0  
**最后更新**: 2025-11-01  
**维护者**: [待填写]
