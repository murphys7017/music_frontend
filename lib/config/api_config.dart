import '../utils/logger.dart';

/// API 配置
class ApiConfig {
  // 默认开发环境地址
  static const String defaultBaseUrl = 'http://127.0.0.1:8000';

  // 默认 Authorization Token（不含 Bearer 前缀，会自动添加）
  static const String defaultAuthToken =
      'EjSYN_2hc2wcYvEsprgd5oEdnliiWtJ8ueGwEETZMlY';

  // 默认日志等级
  static const LogLevel defaultLogLevel = LogLevel.dev;

  // 当前使用的基础 URL
  static String baseUrl = defaultBaseUrl;

  // 当前使用的 Token
  static String authToken = defaultAuthToken;

  // 当前日志等级
  static LogLevel logLevel = defaultLogLevel;

  /// 设置自定义 API 地址
  static void setBaseUrl(String url) {
    baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  /// 设置 Authorization Token
  static void setAuthToken(String token) {
    authToken = token;
  }

  /// 设置日志等级
  static void setLogLevel(LogLevel level) {
    logLevel = level;
    Logger.setLevel(level);
  }

  /// 重置为默认地址
  static void resetToDefault() {
    baseUrl = defaultBaseUrl;
    authToken = defaultAuthToken;
    setLogLevel(defaultLogLevel);
  }
}
