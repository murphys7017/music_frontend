import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
import '../models/device_info.dart';
import '../utils/logger.dart';
import '../config/api_config.dart';

/// 设备服务 - 管理设备ID和设备信息
class DeviceService {
  // 单例模式
  static final DeviceService _instance = DeviceService._internal();
  factory DeviceService() => _instance;
  DeviceService._internal();

  // SharedPreferences 实例
  SharedPreferences? _prefs;

  // 当前设备信息
  DeviceInfo? _deviceInfo;

  // 存储键
  static const String _keyDeviceId = 'device_id';
  static const String _keyDeviceInfo = 'device_info';
  static const String _keyRegistered = 'device_registered';

  // 是否已初始化
  bool _initialized = false;

  /// 初始化服务
  Future<void> initialize() async {
    if (_initialized) {
      Logger.warning('DeviceService already initialized');
      return;
    }

    try {
      Logger.info('Initializing DeviceService...');

      // 初始化 SharedPreferences
      _prefs = await SharedPreferences.getInstance();

      // 加载或生成设备信息
      await _loadOrCreateDeviceInfo();

      // 检查是否需要注册
      await _checkAndRegister();

      _initialized = true;
      Logger.success('DeviceService initialized successfully');
      Logger.info('Device ID: ${_deviceInfo!.deviceId}');
      Logger.info('Device Name: ${_deviceInfo!.deviceName}');
    } catch (e) {
      Logger.error('Failed to initialize DeviceService: $e');
      rethrow;
    }
  }

  /// 加载或创建设备信息
  Future<void> _loadOrCreateDeviceInfo() async {
    // 尝试从本地加载
    final savedInfo = _prefs!.getString(_keyDeviceInfo);

    if (savedInfo != null) {
      try {
        final json = jsonDecode(savedInfo) as Map<String, dynamic>;
        _deviceInfo = DeviceInfo.fromJson(json);
        Logger.dev('Loaded existing device info from storage');
        return;
      } catch (e) {
        Logger.warning('Failed to parse saved device info: $e');
        // 继续创建新的设备信息
      }
    }

    // 创建新的设备信息
    await _createNewDeviceInfo();
  }

  /// 创建新的设备信息
  Future<void> _createNewDeviceInfo() async {
    Logger.info('Creating new device info...');

    // 优先使用ApiConfig.manualDeviceId，否则生成UUID
    final deviceId = ApiConfig.manualDeviceId?.isNotEmpty == true
        ? ApiConfig.manualDeviceId!
        : const Uuid().v4();

    // 创建设备信息
    _deviceInfo = DeviceInfo(
      deviceId: deviceId,
      deviceName: DeviceInfo.getDefaultDeviceName(),
      deviceType: DeviceInfo.getCurrentDeviceType(),
      platform: DeviceInfo.getCurrentPlatform(),
      appVersion: '1.0.0', // TODO: 从 package_info_plus 获取
    );

    // 保存到本地
    await _saveDeviceInfo();

    Logger.success('Created new device info');
    Logger.dev('Device ID: $deviceId');
  }

  /// 保存设备信息到本地
  Future<void> _saveDeviceInfo() async {
    if (_deviceInfo == null) return;

    final json = jsonEncode(_deviceInfo!.toJson());
    await _prefs!.setString(_keyDeviceInfo, json);
    await _prefs!.setString(_keyDeviceId, _deviceInfo!.deviceId);

    Logger.dev('Device info saved to storage');
  }

  /// 检查并注册设备
  Future<void> _checkAndRegister() async {
    final isRegistered = _prefs!.getBool(_keyRegistered) ?? false;

    if (!isRegistered) {
      Logger.info('Device not registered, registering...');
      await registerDevice();
    } else {
      Logger.dev('Device already registered');
    }
  }

  /// 注册设备到服务器
  Future<bool> registerDevice() async {
    if (_deviceInfo == null) {
      Logger.error('Cannot register: device info not initialized');
      return false;
    }

    try {
      Logger.info('Registering device to server...');

      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer ${ApiConfig.authToken}';

      final response = await dio.post(
        '${ApiConfig.baseUrl}/devices/register',
        data: _deviceInfo!.toRegisterRequest(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 标记为已注册
        await _prefs!.setBool(_keyRegistered, true);
        Logger.success('Device registered successfully');
        return true;
      } else {
        Logger.error('Device registration failed: ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        // 设备已存在,也算注册成功
        Logger.info('Device already exists on server');
        await _prefs!.setBool(_keyRegistered, true);
        return true;
      }

      Logger.error('Device registration failed: ${e.message}');
      Logger.dev('Error details: ${e.response?.data}');
      return false;
    } catch (e) {
      Logger.error('Device registration failed: $e');
      return false;
    }
  }

  /// 更新设备名称
  Future<void> updateDeviceName(String newName) async {
    if (_deviceInfo == null) return;

    _deviceInfo = _deviceInfo!.copyWith(
      deviceName: newName,
      updatedAt: DateTime.now(),
    );

    await _saveDeviceInfo();
    Logger.info('Device name updated: $newName');

    // TODO: 同步到服务器
  }

  /// 获取设备ID
  String get deviceId {
    _ensureInitialized();
    return _deviceInfo!.deviceId;
  }

  /// 获取设备信息
  DeviceInfo get deviceInfo {
    _ensureInitialized();
    return _deviceInfo!;
  }

  /// 获取设备名称
  String get deviceName {
    _ensureInitialized();
    return _deviceInfo!.deviceName;
  }

  /// 获取设备类型
  String get deviceType {
    _ensureInitialized();
    return _deviceInfo!.deviceType;
  }

  /// 获取平台
  String get platform {
    _ensureInitialized();
    return _deviceInfo!.platform;
  }

  /// 是否已初始化
  bool get isInitialized => _initialized;

  /// 是否已注册
  bool get isRegistered {
    return _prefs?.getBool(_keyRegistered) ?? false;
  }

  /// 重置设备信息(慎用)
  Future<void> reset() async {
    Logger.warning('Resetting device info...');

    await _prefs?.remove(_keyDeviceInfo);
    await _prefs?.remove(_keyDeviceId);
    await _prefs?.remove(_keyRegistered);

    _deviceInfo = null;
    _initialized = false;

    Logger.info('Device info reset complete');
  }

  /// 获取用于API请求的设备头信息
  Map<String, String> getDeviceHeaders() {
    _ensureInitialized();

    return {
      'X-Device-ID': _deviceInfo!.deviceId,
      'X-Device-Name': _deviceInfo!.deviceName,
      'X-Device-Type': _deviceInfo!.deviceType,
      'X-Platform': _deviceInfo!.platform,
    };
  }

  /// 确保已初始化
  void _ensureInitialized() {
    if (!_initialized || _deviceInfo == null) {
      throw StateError(
        'DeviceService not initialized. Call initialize() first.',
      );
    }
  }
}
