import 'package:dio/dio.dart';
import '../models/music.dart';
import '../utils/logger.dart';
import 'device_service.dart';

/// 音乐 API 服务
class MusicApiService {
  final Dio _dio;
  final String baseUrl;
  final String authToken;
  final DeviceService _deviceService = DeviceService();

  MusicApiService({
    required this.baseUrl,
    this.authToken = 'your_static_token_here',
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    // 设置全局请求头，添加 Bearer 前缀
    _dio.options.headers['Authorization'] = 'Bearer $authToken';

    // 添加拦截器，自动注入设备信息
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 如果 DeviceService 已初始化，自动添加设备头信息
          if (_deviceService.isInitialized) {
            options.headers.addAll(_deviceService.getDeviceHeaders());
            Logger.dev('已添加设备头信息到请求', 'API');
          }
          return handler.next(options);
        },
      ),
    );
  }

  /// 1. 列出音乐 (分页)
  Future<MusicListResponse> listMusic({int page = 1, int pageSize = 20}) async {
    try {
      Logger.dev('列出音乐 - page: $page, pageSize: $pageSize', 'API');
      final response = await _dio.get(
        '/music/list',
        queryParameters: {'page': page, 'page_size': pageSize},
      );
      Logger.success('列出音乐成功 - 共 ${response.data['data']['total']} 首', 'API');
      Logger.devJson('响应数据', response.data, 'API');
      return MusicListResponse.fromJson(response.data);
    } catch (e) {
      Logger.error('列出音乐失败', 'API', e);
      throw _handleError(e);
    }
  }

  /// 2. 搜索音乐
  Future<MusicListResponse> searchMusic({
    required String keyword,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      Logger.info('搜索音乐 - 关键词: "$keyword"', 'API');
      Logger.dev('搜索参数 - page: $page, pageSize: $pageSize', 'API');
      final response = await _dio.get(
        '/music/search',
        queryParameters: {
          'keyword': keyword,
          'page': page,
          'page_size': pageSize,
        },
      );
      final total = response.data['data']['total'];
      Logger.success('搜索成功 - 找到 $total 首歌曲', 'API');
      Logger.devJson('响应数据', response.data, 'API');
      return MusicListResponse.fromJson(response.data);
    } catch (e) {
      Logger.error('搜索失败 - 关键词: "$keyword"', 'API', e);
      throw _handleError(e);
    }
  }

  /// 3. 获取音乐详情
  Future<Music> getMusicDetail(String musicUuid) async {
    try {
      Logger.dev('获取音乐详情 - UUID: $musicUuid', 'API');
      final response = await _dio.get('/music/$musicUuid');
      Logger.success('获取音乐详情成功', 'API');
      Logger.devJson('响应数据', response.data, 'API');
      return Music.fromJson(response.data);
    } catch (e) {
      Logger.error('获取音乐详情失败 - UUID: $musicUuid', 'API', e);
      throw _handleError(e);
    }
  }

  /// 4. 获取播放 URL（带 Authorization 请求头）
  String getPlayUrl(String musicUuid) {
    return '$baseUrl/music/play/$musicUuid';
  }

  /// 5. 获取封面 URL（带 Authorization 请求头）
  String getCoverUrl(String coverUuid) {
    return '$baseUrl/music/cover/$coverUuid';
  }

  /// 6. 获取歌词
  Future<Lyric> getLyric(String musicUuid) async {
    try {
      Logger.dev('获取歌词 - UUID: $musicUuid', 'API');
      final response = await _dio.get('/music/lyric/$musicUuid');
      Logger.success('获取歌词成功', 'API');
      return Lyric.fromJson(response.data);
    } catch (e) {
      Logger.error('获取歌词失败 - UUID: $musicUuid', 'API', e);
      throw _handleError(e);
    }
  }

  /// 7. 根据歌词搜索音乐
  Future<MusicListResponse> searchMusicByLyric({
    required String keyword,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      Logger.info('按歌词搜索 - 关键词: "$keyword"', 'API');
      final response = await _dio.get(
        '/music/search/lyric',
        queryParameters: {
          'keyword': keyword,
          'page': page,
          'page_size': pageSize,
        },
      );
      Logger.success('按歌词搜索成功', 'API');
      return MusicListResponse.fromJson(response.data);
    } catch (e) {
      Logger.error('按歌词搜索失败 - 关键词: "$keyword"', 'API', e);
      throw _handleError(e);
    }
  }

  /// 8. 获取缩略图 URL（带 Authorization 请求头）
  String getThumbnailUrl(String coverUuid) {
    return '$baseUrl/music/thumbnail/$coverUuid';
  }

  /// 9. 添加音乐（客户端上传元数据）
  /// device_id 自动从请求头注入
  Future<Map<String, dynamic>> addMusic({
    required String uuid,
    required String md5,
    required String name,
    String author = '未知',
    String album = '',
    String source = 'local',
    int duration = 0,
    int size = 0,
    int bitrate = 0,
    String? fileFormat,
    String? coverUuid,
    String? lyric,
  }) async {
    try {
      Logger.info('添加音乐 - $name by $author', 'API');

      final data = {
        'uuid': uuid,
        'md5': md5,
        'device_id': _deviceService.deviceId, // 从 DeviceService 获取
        'name': name,
        'author': author,
        'album': album,
        'source': source,
        'duration': duration,
        'size': size,
        'bitrate': bitrate,
        if (fileFormat != null) 'file_format': fileFormat,
        if (coverUuid != null) 'cover_uuid': coverUuid,
        if (lyric != null) 'lyric': lyric,
      };

      Logger.devJson('请求数据', data, 'API');

      final response = await _dio.post('/music/add', data: data);

      Logger.success('音乐添加成功 - UUID: $uuid', 'API');
      Logger.devJson('响应数据', response.data, 'API');

      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      Logger.error('添加音乐失败 - $name', 'API', e);
      throw _handleError(e);
    }
  }

  /// 10. 删除音乐
  /// device_id 自动从请求头注入，只能删除当前设备的音乐
  Future<void> deleteMusic(String uuid) async {
    try {
      Logger.info('删除音乐 - UUID: $uuid', 'API');

      await _dio.delete('/music/$uuid');

      Logger.success('音乐删除成功', 'API');
    } catch (e) {
      Logger.error('删除音乐失败 - UUID: $uuid', 'API', e);
      throw _handleError(e);
    }
  }

  /// 更新 Authorization Token（自动添加 Bearer 前缀）
  void updateAuthToken(String newToken) {
    _dio.options.headers['Authorization'] = 'Bearer $newToken';
  }

  /// 下载封面图片（返回字节数据）
  Future<List<int>> downloadCover(String coverUuid) async {
    try {
      final response = await _dio.get(
        '/music/cover/$coverUuid',
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data as List<int>;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 下载缩略图（返回字节数据）
  Future<List<int>> downloadThumbnail(String coverUuid) async {
    try {
      final response = await _dio.get(
        '/music/thumbnail/$coverUuid',
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data as List<int>;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 错误处理
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('网络连接超时，请检查网络设置');
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = error.response?.data?['detail'] ?? '服务器错误';
          return Exception('请求失败 ($statusCode): $message');
        case DioExceptionType.cancel:
          return Exception('请求已取消');
        default:
          return Exception('网络错误: ${error.message}');
      }
    }
    return Exception('未知错误: $error');
  }

  /// 取消所有请求
  void cancelRequests() {
    _dio.close(force: true);
  }
}
