# 更新日志 (Changelog)

所有重要更改都将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)。

---

## [Unreleased]

### 新增 (Added) - 2025-11-01

#### 日志系统
- ✅ 创建 `lib/utils/logger.dart` - 完整的日志工具类
  - 支持三个日志等级：`LogLevel.off`（关闭）、`LogLevel.info`（信息）、`LogLevel.dev`（开发/最详细）
  - 日志方法：
    - `Logger.dev()` - 开发级别日志（仅 dev 模式显示）
    - `Logger.info()` - 信息级别日志（info 和 dev 模式显示）
    - `Logger.error()` - 错误日志（所有模式显示，除了 off）
    - `Logger.warning()` - 警告日志（info 和 dev 模式显示）
    - `Logger.success()` - 成功日志（仅 dev 模式显示）
    - `Logger.devJson()` - JSON 数据格式化输出（仅 dev 模式）
  - 自动添加时间戳和标签
  - 支持错误详情输出（dev 模式）

#### API 配置更新
- ✅ 更新 `lib/config/api_config.dart`
  - 添加 `defaultLogLevel` 常量（默认：`LogLevel.dev`）
  - 添加 `logLevel` 静态属性
  - 新增 `setLogLevel()` 方法 - 动态设置日志等级
  - 更新 `resetToDefault()` 方法 - 同时重置日志等级

#### API 服务日志集成
- ✅ 更新 `lib/services/music_api_service.dart`
  - 在所有 API 请求方法中集成日志记录：
    - `listMusic()` - 列出音乐（dev 级别参数，success 级别结果）
    - `searchMusic()` - 搜索音乐（info 级别请求，dev 级别参数）
    - `getMusicDetail()` - 获取音乐详情
    - `getLyric()` - 获取歌词
    - `searchMusicByLyric()` - 按歌词搜索
  - 所有错误自动记录为 error 级别
  - dev 模式下输出完整响应数据（JSON 格式）

### 使用说明

#### 设置日志等级

```dart
import 'package:music_frontend/config/api_config.dart';
import 'package:music_frontend/utils/logger.dart';

// 方式 1: 通过 ApiConfig（推荐）
ApiConfig.setLogLevel(LogLevel.info);  // 生产环境
ApiConfig.setLogLevel(LogLevel.dev);   // 开发环境
ApiConfig.setLogLevel(LogLevel.off);   // 关闭日志

// 方式 2: 直接设置 Logger
Logger.setLevel(LogLevel.info);
```

#### 日志等级说明

| 等级 | 说明 | 输出内容 |
|------|------|----------|
| `LogLevel.off` | 关闭 | 仅显示错误日志 |
| `LogLevel.info` | 信息 | info、warning、error 日志 |
| `LogLevel.dev` | 开发 | 所有日志（最详细，包括请求参数、响应数据） |

#### 日志输出示例

**dev 模式（默认）:**
```
23:45:12.345 🔧 DEV [API] 搜索音乐 - 关键词: "Aimer"
23:45:12.346 🔧 DEV [API] 搜索参数 - page: 1, pageSize: 3
23:45:12.567 ✅ SUCCESS [API] 搜索成功 - 找到 1 首歌曲
23:45:12.568 🔧 DEV [API] 响应数据
   └─ {code: 200, message: success, data: {...}}
```

**info 模式:**
```
23:45:12.345 ℹ️ INFO [API] 搜索音乐 - 关键词: "Aimer"
23:45:12.567 ℹ️ INFO [API] 搜索成功 - 找到 1 首歌曲
```

**off 模式:**
```
(无输出，除非发生错误)
```

#### 在应用启动时配置

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 根据环境设置日志等级
  const bool isProduction = bool.fromEnvironment('dart.vm.product');
  ApiConfig.setLogLevel(isProduction ? LogLevel.off : LogLevel.dev);
  
  await MusicPlayerService.ensureInitialized();
  runApp(const MyApp());
}
```

---

## [之前的更新] - 2025-10-29 至 2025-11-01

### 新增
- ✅ 创建音乐播放服务 `MusicPlayerService`
  - 支持本地、网络音乐播放
  - 自动缓存网络音乐
  - 集成 `just_audio_media_kit` 以支持多平台
  
- ✅ 创建 API 服务层
  - 数据模型：`Music`、`MusicListResponse`、`Lyric`
  - API 服务：`MusicApiService` - 8 个完整接口
  - 配置管理：`ApiConfig` - API 地址和 Token 管理
  
- ✅ Authorization 认证支持
  - 自动添加 `Bearer` 前缀
  - 支持动态更新 Token
  
- ✅ 数据模型容错处理
  - 安全的 JSON 解析
  - 支持后端包装结构 `{code, message, data}`
  - 支持 `list` 和 `items` 两种字段名

### 修复
- ✅ 修复类型转换错误（null 值处理）
- ✅ 修复后端响应结构适配问题
- ✅ 优化 `.gitignore` 配置

### 文档
- ✅ 创建 `docs/API_USAGE.md` - 完整的 API 使用文档
- ✅ 创建 `docs/changelog.md` - 本更新日志

---

## 下一步计划

- [ ] 创建音乐列表页面
- [ ] 创建搜索页面
- [ ] 创建播放器界面
- [ ] 集成播放器与 API 服务
- [ ] 添加状态管理（GetX）
- [ ] 实现播放列表功能
- [ ] 添加收藏和历史记录


user
我先描述一下我设想的整体功能
我希望添加这样一个功能：添加本地音乐
客户端添加本地音乐，计算uuid和md5获取元数据文件名文件路径等信息发到服务端，服务端记录到音乐库，后续我会开发匹配音乐信息等功能补充信息。
我觉得music表应该添加一个字段设备id，如果设备是服务器，那么所有的客户端都可以获取到，如果是某个设备添加的音乐，设备id就是那个设备，只有那个设备才能获取到。各设备音乐隔离，不互通。

其中的uuid格式变为 数据类型加uuid有必要吗类似 music-xxxxx-xxxxx

文件路径隐私问题的话，客户端建立一个uuid到文件实际位置的对应库，这样封面和歌词也同样可以通过uuid来映射，当本地没有这个uuid时便从服务器端获取，有便从本地获取

先不用执行，先说说你的想法


user
麻烦你完成
创建 DeviceService 管理设备ID，客户端首次启动生成并注册设备ID，添加设备信息到所有API请求