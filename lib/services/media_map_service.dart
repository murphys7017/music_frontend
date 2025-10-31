import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../models/media_resource.dart';
import '../utils/logger.dart';

/// 文件映射服务 - 管理 UUID 到本地文件路径的映射关系
class MediaMapService {
  // 单例模式
  static final MediaMapService _instance = MediaMapService._internal();
  factory MediaMapService() => _instance;
  MediaMapService._internal();

  /// UUID -> MediaResource 映射表
  final Map<String, MediaResource> _resourceMap = {};

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

      // TODO: 从 Hive 加载已保存的映射关系
      // await _loadFromStorage();

      _initialized = true;
      Logger.success('MediaMapService initialized successfully');
      Logger.info('Total mapped resources: ${_resourceMap.length}');
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
    return _resourceMap.containsKey(key);
  }

  /// 获取资源信息
  MediaResource? getResource(String uuid, {MediaType? type}) {
    final key = _makeKey(uuid, type);
    return _resourceMap[key];
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
    final oldResource = _resourceMap[key];

    _resourceMap[key] = resource;

    if (oldResource == null) {
      Logger.dev('Added new mapping: ${resource.uuid} (${resource.type.name})');
    } else {
      Logger.dev('Updated mapping: ${resource.uuid} (${resource.type.name})');
    }

    // TODO: 保存到 Hive
    // await _saveToStorage(resource);
  }

  /// 批量添加映射
  Future<void> mapResources(List<MediaResource> resources) async {
    _ensureInitialized();

    for (final resource in resources) {
      final key = _makeKey(resource.uuid, resource.type);
      _resourceMap[key] = resource;
    }

    Logger.info('Mapped ${resources.length} resources');

    // TODO: 批量保存到 Hive
    // await _batchSaveToStorage(resources);
  }

  /// 移除映射
  Future<void> removeMapping(String uuid, {MediaType? type}) async {
    _ensureInitialized();

    final key = _makeKey(uuid, type);
    final resource = _resourceMap.remove(key);

    if (resource != null) {
      Logger.dev('Removed mapping: $uuid (${resource.type.name})');

      // TODO: 从 Hive 中删除
      // await _removeFromStorage(uuid, type);
    }
  }

  /// 移除指定 UUID 的所有类型映射
  Future<void> removeAllMappings(String uuid) async {
    _ensureInitialized();

    int removed = 0;
    for (final type in MediaType.values) {
      final key = _makeKey(uuid, type);
      if (_resourceMap.remove(key) != null) {
        removed++;
      }
    }

    if (removed > 0) {
      Logger.info('Removed $removed mappings for UUID: $uuid');

      // TODO: 从 Hive 中批量删除
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

    if (type == null) {
      return _resourceMap.values.toList();
    }

    return _resourceMap.values.where((r) => r.type == type).toList();
  }

  /// 获取映射数量
  int getMappingCount({MediaType? type}) {
    _ensureInitialized();

    if (type == null) {
      return _resourceMap.length;
    }

    return _resourceMap.values.where((r) => r.type == type).length;
  }

  /// 获取缓存统计信息
  Future<CacheStatistics> getStatistics() async {
    _ensureInitialized();

    int totalFiles = 0;
    int totalSize = 0;
    final typeCounts = <MediaType, int>{};
    final typeSizes = <MediaType, int>{};

    for (final resource in _resourceMap.values) {
      if (resource.isCached) {
        totalFiles++;
        totalSize += resource.fileSize ?? 0;

        typeCounts[resource.type] = (typeCounts[resource.type] ?? 0) + 1;
        typeSizes[resource.type] =
            (typeSizes[resource.type] ?? 0) + (resource.fileSize ?? 0);
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

    final count = _resourceMap.length;
    _resourceMap.clear();

    Logger.warning('Cleared all mappings: $count items');

    // TODO: 清空 Hive
    // await _clearStorage();
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
