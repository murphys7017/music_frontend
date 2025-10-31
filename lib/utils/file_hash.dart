import 'dart:io';
import 'package:crypto/crypto.dart';
import 'logger.dart';

/// 文件哈希工具类
class FileHash {
  /// 计算文件的 MD5 哈希值
  ///
  /// [filePath] 文件路径
  /// [chunkSize] 分块读取大小（字节），默认 64KB
  ///
  /// Returns MD5 字符串（32位小写十六进制）
  static Future<String> calculateMD5(
    String filePath, {
    int chunkSize = 64 * 1024, // 64KB
  }) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        throw Exception('文件不存在: $filePath');
      }

      final fileSize = await file.length();
      Logger.dev('开始计算 MD5 - 文件大小: ${_formatFileSize(fileSize)}');

      final stopwatch = Stopwatch()..start();

      // 创建 MD5 摘要对象
      final output = AccumulatorSink<Digest>();
      final input = md5.startChunkedConversion(output);

      // 分块读取文件
      final stream = file.openRead();
      await for (final chunk in stream) {
        input.add(chunk);
      }

      input.close();
      final digest = output.events.single;

      stopwatch.stop();

      final hash = digest.toString();
      Logger.success(
        'MD5 计算完成 - 耗时: ${stopwatch.elapsedMilliseconds}ms, 哈希: $hash',
      );

      return hash;
    } catch (e) {
      Logger.error('MD5 计算失败: $e');
      rethrow;
    }
  }

  /// 计算文件的 SHA256 哈希值
  static Future<String> calculateSHA256(String filePath) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        throw Exception('文件不存在: $filePath');
      }

      final sha256Output = AccumulatorSink<Digest>();
      final sha256Input = sha256.startChunkedConversion(sha256Output);

      final stream = file.openRead();
      await for (final chunk in stream) {
        sha256Input.add(chunk);
      }

      sha256Input.close();
      final digest = sha256Output.events.single;

      return digest.toString();
    } catch (e) {
      Logger.error('SHA256 计算失败: $e');
      rethrow;
    }
  }

  /// 验证文件 MD5
  static Future<bool> verifyMD5(String filePath, String expectedMD5) async {
    try {
      final actualMD5 = await calculateMD5(filePath);
      return actualMD5.toLowerCase() == expectedMD5.toLowerCase();
    } catch (e) {
      Logger.error('MD5 验证失败: $e');
      return false;
    }
  }

  /// 格式化文件大小
  static String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  /// 获取文件大小（格式化字符串）
  static Future<String> getFileSize(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return '0 B';
    }
    final size = await file.length();
    return _formatFileSize(size);
  }

  /// 获取文件大小（字节）
  static Future<int> getFileSizeBytes(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return 0;
    }
    return await file.length();
  }
}

/// 累加器 Sink，用于收集 Digest 结果
class AccumulatorSink<T> implements Sink<T> {
  final List<T> events = [];

  @override
  void add(T event) {
    events.add(event);
  }

  @override
  void close() {}
}
