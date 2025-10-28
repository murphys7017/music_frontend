import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class MusicPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Dio _dio = Dio();

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

  /// 播放本地文件
  Future<void> playLocal(String filePath) async {
    await _audioPlayer.setFilePath(filePath);
    await _audioPlayer.play();
  }

  /// 播放网络音乐（优先在线播放，失败则缓存）
  Future<void> playNetwork(String url) async {
    try {
      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(url)));
      await _audioPlayer.play();
    } catch (e) {
      print('在线播放失败，尝试缓存: $e');
      final file = await _getCachedFile(url);
      await _downloadAndCache(url, file);
      await playLocal(file.path);
    }
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
