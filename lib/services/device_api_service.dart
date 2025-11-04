import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../utils/logger.dart';

class DeviceApiService {
  final Dio _dio;

  DeviceApiService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers['Authorization'] = 'Bearer ${ApiConfig.authToken}';
  }

  /// 注册设备
  Future<Map<String, dynamic>> registerDevice(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/device/register', data: data);
      Logger.success('设备注册成功', 'API');
      return response.data;
    } catch (e) {
      Logger.error('设备注册失败', 'API', e);
      rethrow;
    }
  }

  /// 获取设备列表
  Future<Map<String, dynamic>> getDeviceList() async {
    try {
      final response = await _dio.get('/device/list');
      Logger.success('获取设备列表成功', 'API');
      return response.data;
    } catch (e) {
      Logger.error('获取设备列表失败', 'API', e);
      rethrow;
    }
  }

  /// 获取设备详情
  Future<Map<String, dynamic>> getDeviceDetail(String deviceId) async {
    try {
      final response = await _dio.get('/device/$deviceId');
      Logger.success('获取设备详情成功', 'API');
      return response.data;
    } catch (e) {
      Logger.error('获取设备详情失败', 'API', e);
      rethrow;
    }
  }

  /// 更新设备信息
  Future<Map<String, dynamic>> updateDevice(
    String deviceId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put('/device/$deviceId', data: data);
      Logger.success('设备信息更新成功', 'API');
      return response.data;
    } catch (e) {
      Logger.error('设备信息更新失败', 'API', e);
      rethrow;
    }
  }

  /// 删除设备
  Future<Map<String, dynamic>> deleteDevice(String deviceId) async {
    try {
      final response = await _dio.delete('/device/$deviceId');
      Logger.success('设备删除成功', 'API');
      return response.data;
    } catch (e) {
      Logger.error('设备删除失败', 'API', e);
      rethrow;
    }
  }
}
