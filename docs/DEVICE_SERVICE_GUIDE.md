# DeviceService 使用指南

## 📱 概述

DeviceService 是一个用于管理设备唯一标识和设备信息的服务,支持:
- 自动生成设备 UUID
- 本地持久化存储设备信息
- 首次启动自动注册设备到服务器
- 自动在所有 API 请求中注入设备头信息

## 🚀 快速开始

### 1. 初始化

在应用启动时初始化 DeviceService:

```dart
import 'package:flutter/material.dart';
import 'services/device_service.dart';
import 'utils/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化设备服务
  try {
    await DeviceService().initialize();
  } catch (e) {
    Logger.error('DeviceService 初始化失败: $e');
  }
  
  runApp(const MyApp());
}
```

### 2. 获取设备信息

```dart
final deviceService = DeviceService();

// 获取设备ID (UUID)
String deviceId = deviceService.deviceId;

// 获取设备名称
String deviceName = deviceService.deviceName;

// 获取设备类型 (mobile/desktop/web)
String deviceType = deviceService.deviceType;

// 获取平台 (Windows/macOS/Linux/iOS/Android/web)
String platform = deviceService.platform;

// 检查是否已注册
bool isRegistered = deviceService.isRegistered;
```

### 3. 获取完整设备信息对象

```dart
DeviceInfo deviceInfo = deviceService.deviceInfo;

print('Device ID: ${deviceInfo.deviceId}');
print('Device Name: ${deviceInfo.deviceName}');
print('Device Type: ${deviceInfo.deviceType}');
print('Platform: ${deviceInfo.platform}');
print('App Version: ${deviceInfo.appVersion}');
print('Created At: ${deviceInfo.createdAt}');
print('Updated At: ${deviceInfo.updatedAt}');
```

## 🔧 核心功能

### 自动设备识别

DeviceService 会自动检测:
- **设备类型**: 根据平台自动判断 (mobile/desktop/web)
- **平台名称**: iOS, Android, Windows, macOS, Linux, web
- **设备名称**: 自动组合 "平台 - 主机名" (如 "Windows - Akis4070")

```dart
// 静态方法可直接调用
String deviceType = DeviceInfo.getCurrentDeviceType(); // desktop
String platform = DeviceInfo.getCurrentPlatform();      // Windows
String deviceName = DeviceInfo.getDefaultDeviceName();  // Windows - Akis4070
```

### UUID 生成

首次运行时自动生成 UUID v4:

```dart
// 示例: 3dd914a6-b8bb-44db-a376-7bc018f0f7ba
```

### 本地存储

设备信息使用 `shared_preferences` 持久化存储:

- `device_id`: 设备 UUID
- `device_info`: 完整设备信息 JSON
- `device_registered`: 注册状态标记

### 设备注册

首次启动时自动向服务器注册设备:

```dart
// 手动注册
bool success = await deviceService.registerDevice();

if (success) {
  print('设备注册成功');
} else {
  print('设备注册失败');
}
```

注册请求格式:

```json
POST /devices/register
Headers: Authorization: Bearer <token>
Body: {
  "device_id": "3dd914a6-b8bb-44db-a376-7bc018f0f7ba",
  "device_name": "Windows - Akis4070",
  "device_type": "desktop",
  "platform": "Windows",
  "app_version": "1.0.0"
}
```

### API 请求头自动注入

MusicApiService 已集成 DeviceService,所有请求自动添加设备头:

```http
X-Device-ID: 3dd914a6-b8bb-44db-a376-7bc018f0f7ba
X-Device-Name: Windows - Akis4070
X-Device-Type: desktop
X-Platform: Windows
```

获取设备头信息:

```dart
Map<String, String> headers = deviceService.getDeviceHeaders();

// 示例:
// {
//   'X-Device-ID': '3dd914a6-b8bb-44db-a376-7bc018f0f7ba',
//   'X-Device-Name': 'Windows - Akis4070',
//   'X-Device-Type': 'desktop',
//   'X-Platform': 'Windows'
// }
```

## 🛠️ 高级功能

### 更新设备名称

```dart
await deviceService.updateDeviceName('我的音乐播放器');

// 新名称会保存到本地存储
// TODO: 需要实现同步到服务器
```

### 重置设备信息 (慎用)

```dart
await deviceService.reset();

// 清除所有本地存储的设备信息
// 应用需要重启才能重新生成设备ID
```

## 📊 测试程序

运行设备管理测试程序:

```bash
flutter run -d windows lib/main_device_test.dart
```

测试程序输出示例:

```
========================================
📱 设备管理测试程序
========================================

--- 测试 DeviceService ---

1️⃣ 初始化前状态:
   isInitialized: false
   isRegistered: false

2️⃣ 初始化 DeviceService...
   ✅ 初始化完成

3️⃣ 设备信息:
   Device ID: 3dd914a6-b8bb-44db-a376-7bc018f0f7ba
   Device Name: Windows - Akis4070
   Device Type: desktop
   Platform: Windows
   isInitialized: true
   isRegistered: false

4️⃣ 设备请求头:
   X-Device-ID: 3dd914a6-b8bb-44db-a376-7bc018f0f7ba
   X-Device-Name: Windows - Akis4070
   X-Device-Type: desktop
   X-Platform: Windows

...
```

## 🔒 设备隔离应用

### 音乐库隔离

基于设备ID实现各设备音乐库隔离:

```dart
// 添加音乐时自动关联设备ID
await musicApiService.addMusic(
  uuid: musicUuid,
  md5: fileMd5,
  // device_id 自动从请求头获取
);

// 列表查询自动过滤当前设备的音乐
MusicListResponse response = await musicApiService.listMusic();

// 服务器通过 X-Device-ID 请求头识别设备
// 返回: device_id = "server" (所有设备共享) 或 device_id = 当前设备UUID (仅当前设备)
```

### 服务器端实现

服务器应该:
1. 从请求头读取 `X-Device-ID`
2. 将 device_id 关联到音乐记录
3. 查询时过滤: `device_id = "server" OR device_id = <当前设备UUID>`

## 📝 注意事项

1. **初始化时机**: 必须在 `WidgetsFlutterBinding.ensureInitialized()` 之后,`runApp()` 之前初始化

2. **错误处理**: initialize() 可能抛出异常,建议使用 try-catch

3. **注册失败**: 如果服务器注册接口未实现(404),不影响正常使用,只是 isRegistered 为 false

4. **设备名称更新**: 目前仅更新本地存储,同步到服务器功能待实现

5. **重置功能**: 重置后必须重启应用才能重新生成设备ID

## 🔗 相关文件

- `lib/services/device_service.dart`: DeviceService 实现
- `lib/models/device_info.dart`: DeviceInfo 数据模型
- `lib/services/music_api_service.dart`: API 服务集成
- `lib/main_device_test.dart`: 测试程序

## 📚 数据模型

### DeviceInfo

| 字段 | 类型 | 说明 |
|------|------|------|
| deviceId | String | 设备 UUID (v4) |
| deviceName | String | 设备名称 |
| deviceType | String | 设备类型: mobile/desktop/web |
| platform | String | 平台: iOS/Android/Windows/macOS/Linux/web |
| appVersion | String? | 应用版本 |
| createdAt | DateTime | 创建时间 |
| updatedAt | DateTime | 更新时间 |

### 方法

- `fromJson()`: 从 JSON 反序列化
- `toJson()`: 序列化为 JSON
- `toRegisterRequest()`: 生成注册请求数据
- `copyWith()`: 创建副本并更新字段
- `toString()`: 字符串表示
- `==` / `hashCode`: 基于 deviceId 的相等性比较

## 🎯 使用场景

1. **多设备音乐库隔离**: 每个设备有独立的音乐库,互不干扰
2. **用户行为追踪**: 基于设备ID统计使用情况
3. **设备管理**: 用户可在服务器端查看和管理已注册设备
4. **离线同步**: 设备ID作为离线数据同步的标识
5. **设备授权**: 基于设备ID实现设备授权管理
