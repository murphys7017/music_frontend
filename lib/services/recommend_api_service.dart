import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../utils/logger.dart';

class RecommendApiService {
  final Dio _dio;

  RecommendApiService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers['Authorization'] = 'Bearer ${ApiConfig.authToken}';
  }

  /// 获取热门推荐音乐
  Future<Map<String, dynamic>> getHotRecommend({int pick = 30}) async {
    try {
      final response = await _dio.get(
        '/recommend/mymusic/hot',
        queryParameters: {'pick': pick},
      );
      Logger.success('获取热门推荐成功', 'API');
      return response.data;
    } catch (e) {
      Logger.error('获取热门推荐失败', 'API', e);
      rethrow;
    }
  }

  /// 获取冷门推荐音乐
  Future<Map<String, dynamic>> getColdRecommend({int pick = 15}) async {
    try {
      final response = await _dio.get(
        '/recommend/mymusic/cold',
        queryParameters: {'pick': pick},
      );
      Logger.success('获取冷门推荐成功', 'API');
      return response.data;
    } catch (e) {
      Logger.error('获取冷门推荐失败', 'API', e);
      rethrow;
    }
  }
}
