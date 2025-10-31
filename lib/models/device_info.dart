import 'dart:io';
import 'package:flutter/foundation.dart';

/// 设备信息模型
class DeviceInfo {
  /// 设备唯一ID (UUID)
  final String deviceId;

  /// 设备名称
  final String deviceName;

  /// 设备类型 (mobile/desktop/web)
  final String deviceType;

  /// 平台信息 (iOS/Android/Windows/macOS/Linux/web)
  final String platform;

  /// 应用版本
  final String? appVersion;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  DeviceInfo({
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    required this.platform,
    this.appVersion,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// 从 JSON 创建
  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      deviceId: json['device_id'] as String,
      deviceName: json['device_name'] as String,
      deviceType: json['device_type'] as String,
      platform: json['platform'] as String,
      appVersion: json['app_version'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'device_name': deviceName,
      'device_type': deviceType,
      'platform': platform,
      'app_version': appVersion,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 转换为服务器注册请求格式
  Map<String, dynamic> toRegisterRequest() {
    return {
      'device_id': deviceId,
      'device_name': deviceName,
      'device_type': deviceType,
      'platform': platform,
      'app_version': appVersion,
    };
  }

  /// 获取当前平台的设备类型
  static String getCurrentDeviceType() {
    if (kIsWeb) {
      return 'web';
    } else if (Platform.isAndroid || Platform.isIOS) {
      return 'mobile';
    } else {
      return 'desktop';
    }
  }

  /// 获取当前平台名称
  static String getCurrentPlatform() {
    if (kIsWeb) {
      return 'web';
    } else if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isIOS) {
      return 'iOS';
    } else if (Platform.isWindows) {
      return 'Windows';
    } else if (Platform.isMacOS) {
      return 'macOS';
    } else if (Platform.isLinux) {
      return 'Linux';
    } else {
      return 'Unknown';
    }
  }

  /// 获取默认设备名称
  static String getDefaultDeviceName() {
    final platform = getCurrentPlatform();
    final hostname = _getHostname();
    return hostname.isNotEmpty ? '$platform - $hostname' : platform;
  }

  /// 获取主机名
  static String _getHostname() {
    try {
      if (!kIsWeb) {
        final hostname = Platform.localHostname;
        return hostname;
      }
    } catch (e) {
      // 获取主机名失败,忽略
    }
    return '';
  }

  @override
  String toString() {
    return 'DeviceInfo{deviceId: $deviceId, deviceName: $deviceName, '
        'deviceType: $deviceType, platform: $platform}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeviceInfo && other.deviceId == deviceId;
  }

  @override
  int get hashCode => deviceId.hashCode;

  /// 复制并更新
  DeviceInfo copyWith({
    String? deviceId,
    String? deviceName,
    String? deviceType,
    String? platform,
    String? appVersion,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeviceInfo(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      deviceType: deviceType ?? this.deviceType,
      platform: platform ?? this.platform,
      appVersion: appVersion ?? this.appVersion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
