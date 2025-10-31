import 'package:flutter/material.dart';
import 'services/device_service.dart';
import 'utils/logger.dart';
import 'config/api_config.dart';

/// 设备管理测试程序
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 设置日志级别
  Logger.setLevel(LogLevel.dev);

  print('\n========================================');
  print('📱 设备管理测试程序');
  print('========================================\n');

  try {
    // 测试 DeviceService
    await testDeviceService();
  } catch (e) {
    Logger.error('测试失败: $e');
  }

  runApp(const DeviceTestApp());
}

/// 测试 DeviceService
Future<void> testDeviceService() async {
  print('--- 测试 DeviceService ---\n');

  final deviceService = DeviceService();

  // 1. 测试初始化前状态
  print('1️⃣ 初始化前状态:');
  print('   isInitialized: ${deviceService.isInitialized}');
  print('   isRegistered: ${deviceService.isRegistered}\n');

  // 2. 初始化 DeviceService
  print('2️⃣ 初始化 DeviceService...');
  await deviceService.initialize();
  print('   ✅ 初始化完成\n');

  // 3. 读取设备信息
  print('3️⃣ 设备信息:');
  print('   Device ID: ${deviceService.deviceId}');
  print('   Device Name: ${deviceService.deviceName}');
  print('   Device Type: ${deviceService.deviceType}');
  print('   Platform: ${deviceService.platform}');
  print('   isInitialized: ${deviceService.isInitialized}');
  print('   isRegistered: ${deviceService.isRegistered}\n');

  // 4. 获取设备头信息
  print('4️⃣ 设备请求头:');
  final headers = deviceService.getDeviceHeaders();
  headers.forEach((key, value) {
    print('   $key: $value');
  });
  print('');

  // 5. 测试完整设备信息对象
  print('5️⃣ 完整设备信息对象:');
  final deviceInfo = deviceService.deviceInfo;
  print('   toString: $deviceInfo');
  print('   toJson:');
  deviceInfo.toJson().forEach((key, value) {
    print('     $key: $value');
  });
  print('');

  // 6. 测试更新设备名称
  print('6️⃣ 测试更新设备名称:');
  final oldName = deviceService.deviceName;
  print('   旧名称: $oldName');
  await deviceService.updateDeviceName('我的测试设备');
  print('   新名称: ${deviceService.deviceName}');
  print('');

  // 7. 测试注册请求格式
  print('7️⃣ 注册请求格式:');
  final registerData = deviceService.deviceInfo.toRegisterRequest();
  print('   POST ${ApiConfig.baseUrl}/devices/register');
  registerData.forEach((key, value) {
    print('     $key: $value');
  });
  print('');

  print('========================================');
  print('✅ 所有测试完成');
  print('========================================\n');
}

/// 测试应用 UI
class DeviceTestApp extends StatelessWidget {
  const DeviceTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Device Service Test',
      theme: ThemeData.dark(),
      home: const DeviceTestPage(),
    );
  }
}

class DeviceTestPage extends StatelessWidget {
  const DeviceTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceService = DeviceService();

    return Scaffold(
      appBar: AppBar(title: const Text('设备管理测试')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📱 设备信息',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildInfoRow('设备 ID', deviceService.deviceId),
              _buildInfoRow('设备名称', deviceService.deviceName),
              _buildInfoRow('设备类型', deviceService.deviceType),
              _buildInfoRow('平台', deviceService.platform),
              _buildInfoRow('已注册', deviceService.isRegistered ? '✅ 是' : '❌ 否'),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () async {
                  final success = await deviceService.registerDevice();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(success ? '注册成功' : '注册失败')),
                    );
                  }
                },
                icon: const Icon(Icons.cloud_upload),
                label: const Text('注册设备'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  await deviceService.reset();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('设备信息已重置，请重启应用')),
                    );
                  }
                },
                icon: const Icon(Icons.delete_forever),
                label: const Text('重置设备信息'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
