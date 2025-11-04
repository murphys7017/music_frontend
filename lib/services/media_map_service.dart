import 'dart:io';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../models/media_resource.dart';
import '../models/music.dart';
import '../utils/logger.dart';

/// 文件映射服务 - 管理 UUID 到本地文件路径的映射关系
class MediaMapService {
  final Dio _dio = Dio();

  /// 清理所有无效的本地路径映射（本地文件不存在的）
  /// 返回被清理的uuid列表
  Future<List<String>> cleanInvalidMappings({MediaType? type}) async {
    _ensureInitialized();
    final List<String> removedUuids = [];
    final resources = getAllResources(type: type);
    for (final resource in resources) {
      if (resource.localPath == null) continue;
      final file = File(resource.localPath!);
      final exists = await file.exists();
      if (!exists) {
        await removeMapping(resource.uuid, type: resource.type);
        removedUuids.add(resource.uuid);
        Logger.info(
          'Cleaned invalid mapping: ${resource.uuid} (${resource.type.name})',
        );
      }
    }
    if (removedUuids.isNotEmpty) {
      Logger.warning('Cleaned ${removedUuids.length} invalid mappings');
    } else {
      Logger.info('No invalid mappings found');
    }
    return removedUuids;
  }

  // 单例模式
  static final MediaMapService _instance = MediaMapService._internal();
  factory MediaMapService() => _instance;
  MediaMapService._internal();

  /// Hive Box: uuid_type -> MediaResource
  late Box<MediaResource> _resourceBox;

  /// 是否已初始化
  bool _initialized = false;

  /// 缓存根目录
  late Directory _cacheRoot;

  /// 初始化服务
  Future<void> initialize() async {
    if (_initialized) {
      Logger.warning('MediaMapService already initialized');
      return;
    }

    try {
      Logger.info('Initializing MediaMapService...');

      // 获取缓存目录
      _cacheRoot = await _getCacheRootDirectory();
      Logger.dev('Cache root directory: ${_cacheRoot.path}');

      // 确保缓存目录存在
      await _ensureCacheDirectories();

      // 打开Hive Box
      _resourceBox = await Hive.openBox<MediaResource>('media_map');

      _initialized = true;
      Logger.success('MediaMapService initialized successfully');
      Logger.info('Total mapped resources: ${_resourceBox.length}');
    } catch (e) {
      Logger.error('Failed to initialize MediaMapService: $e');
      rethrow;
    }
  }

  /// 获取缓存根目录
  Future<Directory> _getCacheRootDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory(path.join(appDir.path, 'media_cache'));
  }

  /// 确保所有媒体类型的缓存目录存在
  Future<void> _ensureCacheDirectories() async {
    for (final type in MediaType.values) {
      final dir = Directory(path.join(_cacheRoot.path, type.dirName));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
        Logger.dev('Created cache directory: ${dir.path}');
      }
    }
  }

  /// 获取指定媒体类型的缓存目录
  Directory getCacheDirectory(MediaType type) {
    return Directory(path.join(_cacheRoot.path, type.dirName));
  }

  /// 检查 UUID 是否已映射
  bool isMapped(String uuid, {MediaType? type}) {
    final key = _makeKey(uuid, type);
    return _resourceBox.containsKey(key);
  }

  /// 获取资源信息
  MediaResource? getResource(String uuid, {MediaType? type}) {
    final key = _makeKey(uuid, type);
    return _resourceBox.get(key);
  }

  /// 获取本地路径
  String? getLocalPath(String uuid, {MediaType? type}) {
    final resource = getResource(uuid, type: type);
    return resource?.localPath;
  }

  /// 添加或更新映射
  Future<void> mapResource(MediaResource resource) async {
    _ensureInitialized();
    final key = _makeKey(resource.uuid, resource.type);
    await _resourceBox.put(key, resource);
    Logger.dev('Mapped resource: ${resource.uuid} (${resource.type.name})');
  }

  /// 批量添加映射
  Future<void> mapResources(List<MediaResource> resources) async {
    _ensureInitialized();
    final entries = {for (var r in resources) _makeKey(r.uuid, r.type): r};
    await _resourceBox.putAll(entries);
    Logger.info('Mapped ${resources.length} resources');
  }

  /// 移除映射
  Future<void> removeMapping(String uuid, {MediaType? type}) async {
    _ensureInitialized();
    final key = _makeKey(uuid, type);
    await _resourceBox.delete(key);
    Logger.dev('Removed mapping: $uuid (${type?.name ?? 'audio'})');
  }

  /// 移除指定 UUID 的所有类型映射
  Future<void> removeAllMappings(String uuid) async {
    _ensureInitialized();
    int removed = 0;
    for (final type in MediaType.values) {
      final key = _makeKey(uuid, type);
      if (_resourceBox.containsKey(key)) {
        await _resourceBox.delete(key);
        removed++;
      }
    }
    if (removed > 0) {
      Logger.info('Removed $removed mappings for UUID: $uuid');
    }
  }

  /// 验证本地文件是否存在
  Future<bool> verifyLocalFile(String uuid, {MediaType? type}) async {
    _ensureInitialized();

    final resource = getResource(uuid, type: type);
    if (resource == null || !resource.isCached) {
      return false;
    }

    final file = File(resource.localPath!);
    final exists = await file.exists();

    if (!exists) {
      Logger.warning('Local file not found: ${resource.localPath}');
      // 文件不存在,清理映射
      await removeMapping(uuid, type: type);
    }

    return exists;
  }

  /// 更新访问信息
  Future<void> updateAccessInfo(String uuid, {MediaType? type}) async {
    _ensureInitialized();

    final resource = getResource(uuid, type: type);
    if (resource != null) {
      resource.updateAccessInfo();

      // TODO: 更新到 Hive
      // await _updateAccessInfoInStorage(resource);

      Logger.dev('Updated access info: $uuid, count: ${resource.accessCount}');
    }
  }

  /// 获取所有映射的资源
  List<MediaResource> getAllResources({MediaType? type}) {
    _ensureInitialized();
    final all = _resourceBox.values;
    if (type == null) {
      return all.toList();
    }
    return all.where((r) => r.type == type).toList();
  }

  /// 获取映射数量
  int getMappingCount({MediaType? type}) {
    _ensureInitialized();
    if (type == null) {
      return _resourceBox.length;
    }
    return _resourceBox.values.where((r) => r.type == type).length;
  }

  /// 获取缓存统计信息
  Future<CacheStatistics> getStatistics() async {
    _ensureInitialized();

    int totalFiles = 0;
    int totalSize = 0;
    final typeCounts = <MediaType, int>{};
    final typeSizes = <MediaType, int>{};

    for (final resource in _resourceBox.values) {
      if (resource.isCached) {
        totalFiles++;
        totalSize += ((resource.fileSize ?? 0) as num).toInt();

        typeCounts[resource.type] = (typeCounts[resource.type] ?? 0) + 1;
        typeSizes[resource.type] =
            (typeSizes[resource.type] ?? 0) +
            ((resource.fileSize ?? 0) as num).toInt();
      }
    }

    return CacheStatistics(
      totalFiles: totalFiles,
      totalSizeBytes: totalSize,
      typeCounts: typeCounts,
      typeSizes: typeSizes,
    );
  }

  /// 清空所有映射(慎用)
  Future<void> clearAll() async {
    _ensureInitialized();
    final count = _resourceBox.length;
    await _resourceBox.clear();
    Logger.warning('Cleared all mappings: $count items');
  }

  /// 生成映射键
  String _makeKey(String uuid, MediaType? type) {
    if (type == null) {
      // 如果没有指定类型,默认使用 audio
      return '${uuid}_audio';
    }
    return '${uuid}_${type.name}';
  }

  /// 确保已初始化
  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'MediaMapService not initialized. Call initialize() first.',
      );
    }
  }

  /// 获取缓存根目录路径
  String get cacheRootPath => _cacheRoot.path;

  /// 是否已初始化
  bool get isInitialized => _initialized;

  /// 获取缓存路径
  Future<String> getCachePath(String uuid, String type) async {
    final cacheDir = await getTemporaryDirectory();
    return path.join(
      cacheDir.path,
      '${type}_cache',
      '$uuid.${_getFileExtension(type)}',
    );
  }

  /// 检查文件是否存在
  Future<bool> fileExists(String uuid, String type) async {
    final filePath = await getCachePath(uuid, type);
    return File(filePath).existsSync();
  }

  /// 读取文件内容
  Future<String?> readFile(String uuid, String type) async {
    final filePath = await getCachePath(uuid, type);
    final file = File(filePath);
    if (await file.exists()) {
      return await file.readAsString();
    }
    return null;
  }

  /// 下载并缓存文件
  Future<void> downloadAndCache(String url, String uuid, String type) async {
    final filePath = await getCachePath(uuid, type);
    final file = File(filePath);
    final cacheDir = file.parent;
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    final response = await _dio.download(url, filePath);
    if (response.statusCode != 200) {
      throw Exception('下载失败: $url');
    }
    Logger.info('文件已缓存: $filePath');
  }

  /// 清理缓存
  Future<void> clearCache() async {
    final cacheDir = await getTemporaryDirectory();
    final cacheRoot = Directory(path.join(cacheDir.path));
    if (await cacheRoot.exists()) {
      await cacheRoot.delete(recursive: true);
      Logger.info('缓存已清理');
    }
  }

  /// 获取文件扩展名
  String _getFileExtension(String type) {
    switch (type) {
      case 'music':
        return 'mp3';
      case 'cover':
        return 'jpg';
      case 'lyric':
        return 'lrc';
      default:
        return 'dat';
    }
  }

  /// 映射单个音乐对象的本地数据
  Future<Music> mapMusicWithLocalData(Music music) async {
    // 检查本地缓存的音乐文件
    if (await fileExists(music.uuid, 'music')) {
      music = music.copyWith(playUrl: await getCachePath(music.uuid, 'music'));
    }

    // 检查本地缓存的封面图片
    if (music.coverUuid != null &&
        await fileExists(music.coverUuid!, 'cover')) {
      music = music.copyWith(
        coverUrl: await getCachePath(music.coverUuid!, 'cover'),
      );
    }

    // 检查本地缓存的歌词文件
    final lyrics = await readFile(music.uuid, 'lyric');
    if (lyrics != null) {
      music = music.copyWith(lyrics: lyrics);
    }

    return music;
  }

  /// 映射音乐列表的本地数据
  Future<List<Music>> mapMusicListWithLocalData(List<Music> musicList) async {
    final List<Music> updatedList = [];
    for (final music in musicList) {
      updatedList.add(await mapMusicWithLocalData(music));
    }
    return updatedList;
  }
}

/// 缓存统计信息
class CacheStatistics {
  final int totalFiles;
  final int totalSizeBytes;
  final Map<MediaType, int> typeCounts;
  final Map<MediaType, int> typeSizes;

  CacheStatistics({
    required this.totalFiles,
    required this.totalSizeBytes,
    required this.typeCounts,
    required this.typeSizes,
  });

  /// 格式化的总大小
  String get formattedTotalSize => _formatBytes(totalSizeBytes);

  /// 获取指定类型的格式化大小
  String getFormattedSize(MediaType type) {
    return _formatBytes(typeSizes[type] ?? 0);
  }

  /// 格式化字节大小
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  @override
  String toString() {
    return 'CacheStatistics{\n'
        '  totalFiles: $totalFiles,\n'
        '  totalSize: $formattedTotalSize,\n'
        '  audio: ${typeCounts[MediaType.audio] ?? 0} files (${getFormattedSize(MediaType.audio)}),\n'
        '  cover: ${typeCounts[MediaType.cover] ?? 0} files (${getFormattedSize(MediaType.cover)}),\n'
        '  thumbnail: ${typeCounts[MediaType.thumbnail] ?? 0} files (${getFormattedSize(MediaType.thumbnail)}),\n'
        '  lyric: ${typeCounts[MediaType.lyric] ?? 0} files (${getFormattedSize(MediaType.lyric)})\n'
        '}';
  }
}

extension MusicCopyWith on Music {
  Music copyWith({String? playUrl, String? coverUrl, String? lyrics}) {
    return Music(
      uuid: uuid,
      name: name,
      author: author,
      album: album,
      duration: duration,
      size: size,
      bitrate: bitrate,
      coverUuid: coverUuid,
      playCount: playCount,
      playUrl: playUrl ?? this.playUrl,
      coverUrl: coverUrl ?? this.coverUrl,
    );
  }
}
