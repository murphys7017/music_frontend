# 音乐播放器 Music Player

一个基于 Flutter 开发的现代化跨平台音乐播放器,采用 Material Design 3 设计语言。

![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-Latest-blue.svg)
![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)

## ✨ 特性

- 🎨 **现代化 UI**: Material Design 3 设计,深色主题优化
- 📱 **响应式布局**: 适配不同窗口尺寸
- 🎵 **音频播放**: 基于 just_audio 的高质量音频播放
- 🔍 **智能搜索**: 支持音乐、歌手、歌词搜索
- 📂 **播放列表**: 自定义播放列表管理
- 🎚️ **播放控制**: 完整的播放控制界面
- 📊 **日志系统**: 三级日志系统,便于调试
- 🔐 **安全认证**: Bearer Token 认证机制

## 📸 截图

_待添加截图_

## 🚀 快速开始

### 前置要求

- Flutter SDK >= 3.9.2
- Dart SDK (随 Flutter 安装)
- Windows 10/11 (或其他支持的平台)

### 安装

```bash
# 克隆项目
git clone [项目地址]
cd music_frontend

# 安装依赖
flutter pub get

# 运行应用
flutter run -d windows
```

### 配置

编辑 `lib/config/api_config.dart` 配置后端 API:

```dart
class ApiConfig {
  static const String baseUrl = 'http://127.0.0.1:8000';
  static const String authToken = 'YOUR_TOKEN_HERE';
  static LogLevel logLevel = LogLevel.dev;
}
```

详细说明请参考 [快速开始指南](docs/QUICK_START.md)

## 📚 文档

- [快速开始指南](docs/QUICK_START.md)
- [UI 结构说明](docs/UI_STRUCTURE.md)
- [API 使用文档](docs/API_USAGE.md)
- [项目总结](docs/PROJECT_SUMMARY.md)
- [更新日志](docs/changelog.md)

## 🏗️ 项目结构

```
lib/
├── main.dart                    # 应用入口
├── models/                      # 数据模型
│   ├── music.dart              # 音乐数据模型
│   └── sidebar_menu.dart       # 侧边栏菜单模型
├── services/                    # 服务层
│   └── music_api_service.dart  # API 服务
├── widgets/                     # UI 组件
│   ├── collapsible_sidebar.dart # 可折叠侧边栏
│   └── player_control_bar.dart  # 播放控制栏
├── pages/                       # 页面组件
│   └── pages.dart              # 主要页面
├── config/                      # 配置
│   └── api_config.dart         # API 配置
├── utils/                       # 工具类
│   └── logger.dart             # 日志工具
└── music_player_service.dart    # 音乐播放服务
```

## 🔧 技术栈

### 核心框架
- **Flutter**: 3.9.2+
- **Dart**: Latest stable

### 主要依赖
- `just_audio`: 音频播放
- `just_audio_media_kit`: 媒体控制
- `audio_service`: 后台音频服务
- `dio`: HTTP 网络请求
- `get`: 状态管理 (可选)
- `hive`: 本地数据存储
- `cached_network_image`: 图片缓存

## 🎯 功能状态

### ✅ 已完成
- [x] 可折叠侧边栏 (鼠标悬停展开)
- [x] 播放控制栏
- [x] 顶部搜索栏
- [x] 多页面导航
- [x] 深色主题
- [x] API 服务层
- [x] 日志系统

### 🚧 开发中
- [ ] 音乐列表显示
- [ ] 实际播放功能
- [ ] 搜索功能实现

### 📋 计划中
- [ ] 播放列表管理
- [ ] 歌词显示
- [ ] 收藏功能
- [ ] 播放历史
- [ ] 设置页面
- [ ] 均衡器
- [ ] 桌面集成 (媒体控制)

## 🛠️ 开发

### 开发模式运行
```bash
flutter run -d windows --debug
```

### 热重载
运行时按 `r` 触发热重载,按 `R` 触发热重启

### 代码质量
```bash
# 代码分析
flutter analyze

# 代码格式化
dart format lib/

# 运行测试
flutter test
```

### 构建发布版本
```bash
flutter build windows --release
```

## 🐛 已知问题

1. **布局溢出**: 在较小窗口尺寸下播放控制栏可能溢出,建议最小窗口宽度 1024px
2. **数据集成**: 当前使用模拟数据,需要连接后端 API

## 🤝 贡献

欢迎贡献代码!请遵循以下步骤:

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

详细贡献指南请参考 [CONTRIBUTING.md](CONTRIBUTING.md) (待创建)

## 📄 许可证

本项目采用 [待定] 许可证

## 👥 作者

- **开发者**: [待填写]

## 🙏 致谢

- [Flutter](https://flutter.dev/) - UI 框架
- [just_audio](https://pub.dev/packages/just_audio) - 音频播放
- [dio](https://pub.dev/packages/dio) - HTTP 客户端
- Material Design 团队

## 📞 联系方式

- 项目主页: [待填写]
- Issue 追踪: [待填写]
- 邮箱: [待填写]

---

⭐ 如果这个项目对你有帮助,请给个星标!
