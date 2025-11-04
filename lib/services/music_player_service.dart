import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class PlaylistItem {
  final bool isLocal;
  final String path;

  PlaylistItem({required this.isLocal, required this.path});
}

class MusicPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Dio _dio = Dio();

  /// 播放列表
  final List<PlaylistItem> _playlist = [];

  /// 当前播放索引
  int _currentIndex = -1;

  /// 在应用启动时调用一次，确保 media_kit 平台已初始化。
  static Future<void> ensureInitialized({
    bool prefetchPlaylist = true,
    List<String>? protocolWhitelist,
  }) async {
    if (prefetchPlaylist) {
      JustAudioMediaKit.prefetchPlaylist = true; // 预取播放列表（实验特性）
    }
    if (protocolWhitelist != null) {
      JustAudioMediaKit.protocolWhitelist = protocolWhitelist;
    } else {
      // 默认允许 http/https/file
      JustAudioMediaKit.protocolWhitelist = ["http", "https", "file"];
    }
    JustAudioMediaKit.ensureInitialized();
  }

  /// 设置播放列表
  void setPlaylist(List<PlaylistItem> playlist) {
    _playlist.clear();
    _playlist.addAll(playlist);
    _currentIndex = playlist.isNotEmpty ? 0 : -1;
  }

  /// 播放当前索引的音乐
  Future<void> playCurrent() async {
    if (_currentIndex < 0 || _currentIndex >= _playlist.length) return;
    final currentItem = _playlist[_currentIndex];
    if (currentItem.isLocal) {
      await playLocal(currentItem.path);
    } else {
      await playNetwork(currentItem.path);
    }
  }

  /// 播放下一首音乐
  Future<void> playNext() async {
    if (_currentIndex + 1 < _playlist.length) {
      _currentIndex++;
      await playCurrent();
    }
  }

  /// 播放上一首音乐
  Future<void> playPrevious() async {
    if (_currentIndex - 1 >= 0) {
      _currentIndex--;
      await playCurrent();
    }
  }

  /// 播放网络音乐（优先在线播放，失败则缓存）
  Future<void> playNetwork(String url) async {
    try {
      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(url)));
      await _audioPlayer.play();

      // 监听播放进度，预读取下一首音乐
      _audioPlayer.positionStream.listen((position) {
        final duration = _audioPlayer.duration;
        if (duration != null && position >= duration * 0.5) {
          _prefetchNext();
        }
      });
    } catch (e) {
      print('在线播放失败，尝试缓存: $e');
      final file = await _getCachedFile(url);
      await _downloadAndCache(url, file);
      await playLocal(file.path);
    }
  }

  /// 预读取下一首音乐
  Future<void> _prefetchNext() async {
    if (_currentIndex + 1 < _playlist.length) {
      final nextItem = _playlist[_currentIndex + 1];
      if (!nextItem.isLocal) {
        try {
          await _audioPlayer.setAudioSource(
            AudioSource.uri(Uri.parse(nextItem.path)),
          );
        } catch (e) {
          print('预读取失败: $e');
        }
      }
    }
  }

  /// 播放本地文件
  Future<void> playLocal(String filePath) async {
    await _audioPlayer.setFilePath(filePath);
    await _audioPlayer.play();
  }

  Future<void> pause() async => _audioPlayer.pause();
  Future<void> resume() async => _audioPlayer.play();
  Future<void> stop() async => _audioPlayer.stop();

  /// 获取缓存文件路径
  Future<File> _getCachedFile(String url) async {
    final dir = await getTemporaryDirectory(); // 更合适的缓存路径
    final fileName = Uri.parse(url).pathSegments.last;
    return File(p.join(dir.path, 'music_cache', fileName));
  }

  /// 下载并缓存音乐
  Future<void> _downloadAndCache(String url, File file) async {
    final cacheDir = file.parent;
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    final response = await _dio.download(url, file.path);
    if (response.statusCode != 200) {
      throw Exception('下载失败: $url');
    }
  }

  /// 进度与状态流
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  /// 释放资源
  Future<void> dispose() async => _audioPlayer.dispose();
}
