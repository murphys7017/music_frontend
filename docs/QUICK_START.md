# 快速开始指南

## 项目简介

这是一个基于 Flutter 开发的跨平台音乐播放器,目前主要针对 Windows 桌面平台优化。

## 前置要求

- Flutter SDK >= 3.9.2
- Dart SDK (随 Flutter 安装)
- Windows 10/11 (用于桌面开发)
- Git

## 安装步骤

### 1. 克隆项目

```bash
git clone [项目地址]
cd music_frontend
```

### 2. 安装依赖

```bash
flutter pub get
```

### 3. 配置后端 API

编辑 `lib/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'http://127.0.0.1:8000';  // 修改为你的后端地址
  static const String authToken = 'YOUR_TOKEN_HERE';       // 修改为你的认证token
}
```

### 4. 运行应用

```bash
# 在 Windows 桌面运行
flutter run -d windows

# 在调试模式运行
flutter run -d windows --debug

# 在发布模式运行
flutter run -d windows --release
```

## 开发工具

### VS Code (推荐)

安装以下扩展:
- Flutter
- Dart
- Flutter Widget Snippets

### Android Studio / IntelliJ IDEA

安装 Flutter 和 Dart 插件

## 项目结构

```
lib/
├── main.dart                    # 应用入口
├── models/                      # 数据模型
├── services/                    # API 服务
├── widgets/                     # UI 组件
├── pages/                       # 页面
├── config/                      # 配置
└── utils/                       # 工具类
```

## 常用命令

### 开发命令

```bash
# 运行应用
flutter run -d windows

# 热重载 (在运行时按 'r')
# 热重启 (在运行时按 'R')

# 代码分析
flutter analyze

# 代码格式化
dart format lib/

# 清理构建缓存
flutter clean
```

### 构建命令

```bash
# 构建 Windows 桌面应用
flutter build windows --release

# 构建其他平台
flutter build macos --release  # macOS
flutter build linux --release  # Linux
flutter build apk --release    # Android
flutter build ios --release    # iOS
```

## 功能特性

### 已实现
- ✅ 可折叠侧边栏 (鼠标悬停展开)
- ✅ 播放控制栏 (进度、音量控制)
- ✅ 顶部搜索栏
- ✅ 多页面导航
- ✅ 深色主题
- ✅ API 服务层
- ✅ 日志系统

### 待实现
- ⏳ 音乐列表显示
- ⏳ 实际播放功能
- ⏳ 搜索功能
- ⏳ 播放列表管理
- ⏳ 歌词显示
- ⏳ 收藏功能

## 调试

### 启用日志

编辑 `lib/config/api_config.dart`:

```dart
class ApiConfig {
  static LogLevel logLevel = LogLevel.dev;  // off, info, dev
}
```

日志级别:
- `off`: 关闭所有日志
- `info`: 仅显示重要信息
- `dev`: 显示详细的调试信息 (包括 API 请求/响应)

### 查看日志

运行应用后,日志会输出到控制台:

```
[DEV] 2024-01-01 12:00:00 - API Request: GET /music/list
[INFO] 2024-01-01 12:00:01 - Music list loaded: 20 items
[ERROR] 2024-01-01 12:00:02 - Network error: Connection timeout
```

## 常见问题

### Q1: 应用无法启动

**解决方案**:
```bash
# 清理缓存并重新构建
flutter clean
flutter pub get
flutter run -d windows
```

### Q2: 热重载不生效

**解决方案**:
- 使用热重启 (按 'R')
- 或完全停止应用重新运行

### Q3: API 请求失败

**检查项**:
1. 后端服务是否运行 (http://127.0.0.1:8000)
2. 认证 Token 是否正确
3. 网络连接是否正常
4. 检查日志输出的错误信息

### Q4: 布局溢出警告

当前已知问题,建议窗口最小宽度 1024px。正在优化中。

### Q5: just_audio 初始化错误

**解决方案**:
确保 `main.dart` 中包含:
```dart
WidgetsFlutterBinding.ensureInitialized();
await MusicPlayerService.ensureInitialized();
```

## 性能优化建议

### 开发模式
- 使用 `flutter run --debug` 进行开发
- 启用热重载加快开发速度

### 发布模式
- 使用 `flutter build windows --release` 构建
- 发布版本性能显著提升

### 日志配置
- 开发时使用 `LogLevel.dev`
- 生产环境设置为 `LogLevel.off` 或 `LogLevel.info`

## 贡献指南

### 提交代码前

1. 运行代码分析
```bash
flutter analyze
```

2. 格式化代码
```bash
dart format lib/
```

3. 确保没有错误
```bash
flutter build windows --debug
```

### 代码规范

- 遵循 Dart 官方风格指南
- 为公共 API 添加注释
- 保持代码简洁清晰

## 获取帮助

### 文档
- [Flutter 官方文档](https://flutter.dev/docs)
- [Dart 语言指南](https://dart.dev/guides)
- [项目 API 文档](./API_USAGE.md)
- [UI 结构说明](./UI_STRUCTURE.md)

### 问题反馈
- 提交 Issue
- 查看已有的 Issue 是否有解决方案

## 下一步

1. 熟悉项目结构
2. 查看 [UI_STRUCTURE.md](./UI_STRUCTURE.md) 了解界面设计
3. 查看 [API_USAGE.md](./API_USAGE.md) 了解 API 使用
4. 开始开发你的功能!

---

祝你开发愉快! 🎵🎶
