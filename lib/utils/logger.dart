/// 日志等级
enum LogLevel {
  /// 关闭日志
  off,

  /// 信息级别 - 仅显示重要信息
  info,

  /// 开发级别 - 显示详细调试信息
  dev,
}

/// 日志工具类
class Logger {
  static LogLevel _level = LogLevel.dev;

  /// 设置日志等级
  static void setLevel(LogLevel level) {
    _level = level;
  }

  /// 获取当前日志等级
  static LogLevel get level => _level;

  /// 开发级别日志（最详细）
  static void dev(String message, [String? tag]) {
    if (_level == LogLevel.dev) {
      _log('🔧 DEV', tag, message);
    }
  }

  /// 信息级别日志
  static void info(String message, [String? tag]) {
    if (_level == LogLevel.info || _level == LogLevel.dev) {
      _log('ℹ️ INFO', tag, message);
    }
  }

  /// 错误日志（所有级别都显示，除了 off）
  static void error(String message, [String? tag, Object? error]) {
    if (_level != LogLevel.off) {
      _log('❌ ERROR', tag, message);
      if (error != null && _level == LogLevel.dev) {
        print('   └─ 详细错误: $error');
      }
    }
  }

  /// 警告日志
  static void warning(String message, [String? tag]) {
    if (_level == LogLevel.info || _level == LogLevel.dev) {
      _log('⚠️ WARNING', tag, message);
    }
  }

  /// 成功日志
  static void success(String message, [String? tag]) {
    if (_level == LogLevel.dev) {
      _log('✅ SUCCESS', tag, message);
    }
  }

  /// 内部日志打印方法
  static void _log(String level, String? tag, String message) {
    final timestamp = DateTime.now().toString().substring(11, 23);
    final tagStr = tag != null ? '[$tag] ' : '';
    print('$timestamp $level $tagStr$message');
  }

  /// 格式化 JSON 数据（仅在 dev 模式）
  static void devJson(String message, dynamic json, [String? tag]) {
    if (_level == LogLevel.dev) {
      _log('🔧 DEV', tag, message);
      print('   └─ $json');
    }
  }
}
