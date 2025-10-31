import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/playlist.dart';
import '../utils/logger.dart';

/// 歌单服务 - 管理歌单、播放历史、收藏
class PlaylistService {
  // 单例模式
  static final PlaylistService _instance = PlaylistService._internal();
  factory PlaylistService() => _instance;
  PlaylistService._internal();

  // Box 名称
  static const String _playlistBoxName = 'playlists';
  static const String _historyBoxName = 'play_history';
  static const String _favoriteBoxName = 'favorites';

  // Hive Box
  Box<Playlist>? _playlistBox;
  Box<PlayHistory>? _historyBox;
  Box<FavoriteMusic>? _favoriteBox;

  // 特殊歌单 ID
  static const String favoritesPlaylistId = 'favorites';
  static const String recentPlaylistId = 'recent';

  bool _initialized = false;

  /// 初始化服务
  Future<void> initialize() async {
    if (_initialized) {
      Logger.warning('PlaylistService already initialized');
      return;
    }

    try {
      Logger.info('Initializing PlaylistService...');

      // 初始化 Hive
      await Hive.initFlutter();

      // 注册适配器
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(PlaylistTypeAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(PlaylistAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(PlayHistoryAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(FavoriteMusicAdapter());
      }

      // 打开 Box
      _playlistBox = await Hive.openBox<Playlist>(_playlistBoxName);
      _historyBox = await Hive.openBox<PlayHistory>(_historyBoxName);
      _favoriteBox = await Hive.openBox<FavoriteMusic>(_favoriteBoxName);

      // 初始化特殊歌单
      await _initializeSpecialPlaylists();

      _initialized = true;
      Logger.success('PlaylistService initialized successfully');
      Logger.info(
        'Playlists: ${_playlistBox!.length}, History: ${_historyBox!.length}, Favorites: ${_favoriteBox!.length}',
      );
    } catch (e) {
      Logger.error('Failed to initialize PlaylistService: $e');
      rethrow;
    }
  }

  /// 初始化特殊歌单
  Future<void> _initializeSpecialPlaylists() async {
    // 我喜欢的
    if (!_playlistBox!.containsKey(favoritesPlaylistId)) {
      final favorites = Playlist(
        id: favoritesPlaylistId,
        name: '我喜欢的',
        type: PlaylistType.favorites,
        isFixed: true,
      );
      await _playlistBox!.put(favoritesPlaylistId, favorites);
      Logger.dev('Created "我喜欢的" playlist');
    }

    // 最近播放
    if (!_playlistBox!.containsKey(recentPlaylistId)) {
      final recent = Playlist(
        id: recentPlaylistId,
        name: '最近播放',
        type: PlaylistType.recent,
        isFixed: true,
      );
      await _playlistBox!.put(recentPlaylistId, recent);
      Logger.dev('Created "最近播放" playlist');
    }
  }

  /// 确保已初始化
  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'PlaylistService not initialized. Call initialize() first.',
      );
    }
  }

  // ==================== 歌单 CRUD ====================

  /// 创建歌单
  Future<Playlist> createPlaylist({
    required String name,
    String? description,
    String? coverUrl,
    PlaylistType type = PlaylistType.userCreated,
  }) async {
    _ensureInitialized();

    final playlist = Playlist(
      id: const Uuid().v4(),
      name: name,
      description: description,
      coverUrl: coverUrl,
      type: type,
    );

    await _playlistBox!.put(playlist.id, playlist);
    Logger.info('Created playlist: $name (ID: ${playlist.id})');

    return playlist;
  }

  /// 获取歌单
  Playlist? getPlaylist(String id) {
    _ensureInitialized();
    return _playlistBox!.get(id);
  }

  /// 获取所有歌单
  List<Playlist> getAllPlaylists() {
    _ensureInitialized();
    return _playlistBox!.values.toList();
  }

  /// 获取用户创建的歌单
  List<Playlist> getUserPlaylists() {
    _ensureInitialized();
    return _playlistBox!.values
        .where((p) => p.type == PlaylistType.userCreated)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  /// 更新歌单
  Future<void> updatePlaylist(
    String id, {
    String? name,
    String? description,
    String? coverUrl,
  }) async {
    _ensureInitialized();

    final playlist = _playlistBox!.get(id);
    if (playlist == null) {
      throw Exception('Playlist not found: $id');
    }

    if (name != null) playlist.name = name;
    if (description != null) playlist.description = description;
    if (coverUrl != null) playlist.coverUrl = coverUrl;
    playlist.updatedAt = DateTime.now();

    await playlist.save();
    Logger.info('Updated playlist: ${playlist.name}');
  }

  /// 删除歌单
  Future<bool> deletePlaylist(String id) async {
    _ensureInitialized();

    final playlist = _playlistBox!.get(id);
    if (playlist == null) return false;

    if (playlist.isFixed) {
      Logger.warning('Cannot delete fixed playlist: ${playlist.name}');
      return false;
    }

    await _playlistBox!.delete(id);
    Logger.info('Deleted playlist: ${playlist.name}');
    return true;
  }

  // ==================== 音乐管理 ====================

  /// 添加音乐到歌单
  Future<void> addMusicToPlaylist(String playlistId, String musicId) async {
    _ensureInitialized();

    final playlist = _playlistBox!.get(playlistId);
    if (playlist == null) {
      throw Exception('Playlist not found: $playlistId');
    }

    playlist.addMusic(musicId);
    await playlist.save();
    Logger.info('Added music $musicId to playlist ${playlist.name}');
  }

  /// 批量添加音乐到歌单
  Future<void> addMusicListToPlaylist(
    String playlistId,
    List<String> musicIds,
  ) async {
    _ensureInitialized();

    final playlist = _playlistBox!.get(playlistId);
    if (playlist == null) {
      throw Exception('Playlist not found: $playlistId');
    }

    playlist.addMusicList(musicIds);
    await playlist.save();
    Logger.info('Added ${musicIds.length} musics to playlist ${playlist.name}');
  }

  /// 从歌单移除音乐
  Future<void> removeMusicFromPlaylist(
    String playlistId,
    String musicId,
  ) async {
    _ensureInitialized();

    final playlist = _playlistBox!.get(playlistId);
    if (playlist == null) {
      throw Exception('Playlist not found: $playlistId');
    }

    playlist.removeMusic(musicId);
    await playlist.save();
    Logger.info('Removed music $musicId from playlist ${playlist.name}');
  }

  /// 重新排序歌单中的音乐
  Future<void> reorderMusic(
    String playlistId,
    int oldIndex,
    int newIndex,
  ) async {
    _ensureInitialized();

    final playlist = _playlistBox!.get(playlistId);
    if (playlist == null) {
      throw Exception('Playlist not found: $playlistId');
    }

    playlist.reorderMusic(oldIndex, newIndex);
    await playlist.save();
    Logger.dev('Reordered music in playlist ${playlist.name}');
  }

  /// 清空歌单
  Future<void> clearPlaylist(String playlistId) async {
    _ensureInitialized();

    final playlist = _playlistBox!.get(playlistId);
    if (playlist == null) {
      throw Exception('Playlist not found: $playlistId');
    }

    playlist.clear();
    await playlist.save();
    Logger.info('Cleared playlist ${playlist.name}');
  }

  // ==================== 收藏功能 ====================

  /// 添加到"我喜欢的"
  Future<void> addToFavorites(String musicId) async {
    _ensureInitialized();

    // 检查是否已收藏
    if (isFavorite(musicId)) {
      Logger.dev('Music $musicId already in favorites');
      return;
    }

    // 添加到收藏 Box
    final favorite = FavoriteMusic(musicId: musicId);
    await _favoriteBox!.add(favorite);

    // 添加到"我喜欢的"歌单
    await addMusicToPlaylist(favoritesPlaylistId, musicId);

    Logger.info('Added music $musicId to favorites');
  }

  /// 从"我喜欢的"移除
  Future<void> removeFromFavorites(String musicId) async {
    _ensureInitialized();

    // 从收藏 Box 移除
    final favorites = _favoriteBox!.values
        .where((f) => f.musicId == musicId)
        .toList();
    for (final favorite in favorites) {
      await favorite.delete();
    }

    // 从"我喜欢的"歌单移除
    await removeMusicFromPlaylist(favoritesPlaylistId, musicId);

    Logger.info('Removed music $musicId from favorites');
  }

  /// 检查是否已收藏
  bool isFavorite(String musicId) {
    _ensureInitialized();
    return _favoriteBox!.values.any((f) => f.musicId == musicId);
  }

  /// 获取所有收藏的音乐ID
  List<String> getFavoriteMusicIds() {
    _ensureInitialized();
    return _favoriteBox!.values.map((f) => f.musicId).toList();
  }

  // ==================== 播放历史 ====================

  /// 记录播放历史
  Future<void> recordPlay(
    String musicId, {
    int duration = 0,
    bool completed = false,
  }) async {
    _ensureInitialized();

    // 添加到历史 Box
    final history = PlayHistory(
      musicId: musicId,
      playDuration: duration,
      isCompleted: completed,
    );
    await _historyBox!.add(history);

    // 更新"最近播放"歌单（最多保留100首，去重）
    final recentPlaylist = _playlistBox!.get(recentPlaylistId);
    if (recentPlaylist != null) {
      // 移除已存在的
      recentPlaylist.removeMusic(musicId);
      // 添加到开头
      recentPlaylist.musicIds.insert(0, musicId);
      // 限制数量
      if (recentPlaylist.musicIds.length > 100) {
        recentPlaylist.musicIds.removeLast();
      }
      recentPlaylist.updatedAt = DateTime.now();
      await recentPlaylist.save();
    }

    Logger.dev('Recorded play history for music $musicId');

    // 清理过期历史（保留最近1000条）
    await _cleanupHistory();
  }

  /// 清理过期历史
  Future<void> _cleanupHistory() async {
    if (_historyBox!.length > 1000) {
      final histories = _historyBox!.values.toList()
        ..sort((a, b) => b.playedAt.compareTo(a.playedAt));

      // 删除旧的历史记录
      for (int i = 1000; i < histories.length; i++) {
        await histories[i].delete();
      }

      Logger.dev('Cleaned up ${histories.length - 1000} old history records');
    }
  }

  /// 获取播放历史（最近N条）
  List<PlayHistory> getPlayHistory({int limit = 50}) {
    _ensureInitialized();

    final histories = _historyBox!.values.toList()
      ..sort((a, b) => b.playedAt.compareTo(a.playedAt));

    return histories.take(limit).toList();
  }

  /// 清空播放历史
  Future<void> clearHistory() async {
    _ensureInitialized();

    await _historyBox!.clear();
    Logger.info('Cleared play history');

    // 同时清空"最近播放"歌单
    await clearPlaylist(recentPlaylistId);
  }

  // ==================== 工具方法 ====================

  /// 获取"我喜欢的"歌单
  Playlist? getFavoritesPlaylist() {
    return getPlaylist(favoritesPlaylistId);
  }

  /// 获取"最近播放"歌单
  Playlist? getRecentPlaylist() {
    return getPlaylist(recentPlaylistId);
  }

  /// 导出所有数据为 JSON
  Map<String, dynamic> exportData() {
    _ensureInitialized();

    return {
      'playlists': _playlistBox!.values.map((p) => p.toJson()).toList(),
      'favorites': _favoriteBox!.values.map((f) => f.toJson()).toList(),
      'history': _historyBox!.values.map((h) => h.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// 关闭所有 Box
  Future<void> dispose() async {
    await _playlistBox?.close();
    await _historyBox?.close();
    await _favoriteBox?.close();
    _initialized = false;
    Logger.info('PlaylistService disposed');
  }
}
