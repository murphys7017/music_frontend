# 音乐 API 使用说明

## 项目结构

```
lib/
├── config/
│   └── api_config.dart          # API 配置
├── models/
│   └── music.dart               # 数据模型
├── services/
│   └── music_api_service.dart   # API 服务
└── main.dart
```

## 快速开始

### 1. 初始化 API 服务

```dart
import 'package:music_frontend/config/api_config.dart';
import 'package:music_frontend/services/music_api_service.dart';

// 使用默认地址和默认 Token
final apiService = MusicApiService(
  baseUrl: ApiConfig.baseUrl,
  authToken: ApiConfig.authToken, // 默认: 'your_static_token_here'
);

// 或自定义地址和 Token
ApiConfig.setBaseUrl('http://192.168.1.100:8000');
ApiConfig.setAuthToken('your_custom_token');
final apiService = MusicApiService(
  baseUrl: ApiConfig.baseUrl,
  authToken: ApiConfig.authToken,
);

// 后续更新 Token（如用户登录后）
apiService.updateAuthToken('new_token_after_login');
```

### 2. 获取音乐列表

```dart
// 获取第一页，每页 20 条
final response = await apiService.listMusic(page: 1, pageSize: 20);
print('总数: ${response.total}');
print('当前页: ${response.page}');
print('是否有更多: ${response.hasMore}');

for (var music in response.items) {
  print('${music.name} - ${music.author}');
  print('时长: ${music.formattedDuration}');
  print('大小: ${music.formattedSize}');
}
```

### 3. 搜索音乐

```dart
// 按歌曲名或歌手搜索
final searchResult = await apiService.searchMusic(
  keyword: '玉盘',
  page: 1,
  pageSize: 20,
);

// 按歌词搜索
final lyricResult = await apiService.searchMusicByLyric(
  keyword: 'love',
  page: 1,
  pageSize: 20,
);
```

### 4. 获取音乐详情

```dart
final music = await apiService.getMusicDetail('music-uuid-here');
print('歌曲: ${music.name}');
print('歌手: ${music.author}');
print('专辑: ${music.album}');
print('播放次数: ${music.playCount}');
```

### 5. 播放音乐

```dart
// 获取播放 URL
final playUrl = apiService.getPlayUrl('music-uuid-here');

// 使用 MusicPlayerService 播放
await musicPlayerService.playNetwork(playUrl);
```

### 6. 获取歌词

```dart
final lyric = await apiService.getLyric('music-uuid-here');
print('歌词内容:');
print(lyric.content);
```

### 7. 获取封面和缩略图

```dart
// 获取封面 URL
final coverUrl = apiService.getCoverUrl('cover-uuid-here');

// 获取缩略图 URL (200x200)
final thumbnailUrl = apiService.getThumbnailUrl('cover-uuid-here');

// 使用 CachedNetworkImage 显示
CachedNetworkImage(
  imageUrl: thumbnailUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)

// 或下载为字节数据
final imageBytes = await apiService.downloadThumbnail('cover-uuid-here');
```

## 完整示例：音乐列表页面

```dart
import 'package:flutter/material.dart';
import 'package:music_frontend/config/api_config.dart';
import 'package:music_frontend/services/music_api_service.dart';
import 'package:music_frontend/models/music.dart';

class MusicListPage extends StatefulWidget {
  const MusicListPage({super.key});

  @override
  State<MusicListPage> createState() => _MusicListPageState();
}

class _MusicListPageState extends State<MusicListPage> {
  final _apiService = MusicApiService(
    baseUrl: ApiConfig.baseUrl,
    authToken: ApiConfig.authToken,
  );
  List<Music> _musicList = [];
  bool _isLoading = false;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadMusic();
  }

  Future<void> _loadMusic() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.listMusic(
        page: _currentPage,
        pageSize: 20,
      );

      setState(() {
        _musicList.addAll(response.items);
        _currentPage++;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载失败: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('音乐列表')),
      body: ListView.builder(
        itemCount: _musicList.length + 1,
        itemBuilder: (context, index) {
          if (index == _musicList.length) {
            return _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TextButton(
                    onPressed: _loadMusic,
                    child: const Text('加载更多'),
                  );
          }

          final music = _musicList[index];
          return ListTile(
            leading: music.coverUuid != null
                ? Image.network(
                    _apiService.getThumbnailUrl(music.coverUuid!),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.music_note),
            title: Text(music.name),
            subtitle: Text('${music.author} - ${music.formattedDuration}'),
            trailing: Text(music.formattedSize),
            onTap: () {
              // 播放音乐
              final playUrl = _apiService.getPlayUrl(music.uuid);
              // TODO: 调用播放器
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _apiService.cancelRequests();
    super.dispose();
  }
}
```

## 错误处理

API 服务已内置错误处理，会将 Dio 错误转换为友好的异常消息：

```dart
try {
  final music = await apiService.getMusicDetail('invalid-uuid');
} catch (e) {
  print('错误: $e'); // 自动显示友好的错误信息
}
```

## 测试建议

### 1. 测试 API 连接

```dart
void main() async {
  final apiService = MusicApiService(
    baseUrl: 'http://127.0.0.1:8000',
    authToken: 'your_static_token_here',
  );
  
  try {
    final response = await apiService.listMusic(page: 1, pageSize: 5);
    print('连接成功！共 ${response.total} 首歌曲');
    print('前 5 首:');
    for (var music in response.items) {
      print('- ${music.name} (${music.author})');
    }
  } catch (e) {
    print('连接失败: $e');
  }
}
```

**注意**: 所有请求都会自动包含 `Authorization` 请求头。

### 2. 在浏览器测试接口

确保后端服务已启动：
- 列表: http://127.0.0.1:8000/music/list?page=1&page_size=20
- 搜索: http://127.0.0.1:8000/music/search?keyword=玉盘
- 文档: http://127.0.0.1:8000/docs

### 3. 检查网络权限

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## 下一步

1. 集成到现有的 `MusicPlayerService` 中
2. 添加状态管理（如 GetX、Provider）
3. 实现音乐播放队列
4. 添加收藏、历史记录功能
5. 实现离线缓存策略
