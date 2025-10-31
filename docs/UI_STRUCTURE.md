# 音乐播放器 UI 结构说明

## 项目概述

这是一个基于 Flutter 开发的桌面音乐播放器应用,采用 Material Design 3 设计语言,支持深色主题。

## UI 布局结构

### 整体布局

```
┌────────────────────────────────────────────────────────────────┐
│                         Scaffold                                │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                        Column                             │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │                    Expanded (主内容区)              │  │  │
│  │  │  ┌──────────────────────────────────────────────┐  │  │  │
│  │  │  │                   Row                        │  │  │  │
│  │  │  │  ┌──────┬──────────────────────────────┐    │  │  │  │
│  │  │  │  │ 侧边栏│       主内容区 Column         │    │  │  │  │
│  │  │  │  │ 60px │  ┌─────────────────────────┐ │    │  │  │  │
│  │  │  │  │ 或   │  │    SearchBar (顶部)     │ │    │  │  │  │
│  │  │  │  │220px │  ├─────────────────────────┤ │    │  │  │  │
│  │  │  │  │      │  │                         │ │    │  │  │  │
│  │  │  │  │      │  │   Expanded (页面内容)    │ │    │  │  │  │
│  │  │  │  │      │  │                         │ │    │  │  │  │
│  │  │  │  └──────┴──┴─────────────────────────┘ │    │  │  │  │
│  │  │  └──────────────────────────────────────────────┘  │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │            PlayerControlBar (80px 固定)            │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────┘
```

## 核心组件说明

### 1. CollapsibleSidebar (可折叠侧边栏)

**文件位置**: `lib/widgets/collapsible_sidebar.dart`

**功能特性**:
- 默认收起状态宽度: 60px (仅显示图标)
- 鼠标悬停展开宽度: 220px (显示完整菜单)
- 动画过渡时间: 200ms
- 支持一级和二级菜单
- 二级菜单最大高度: 屏幕高度的 40%,可滚动

**菜单结构**:
```
├── 首页 (home)
│   ├── 我的最爱
│   ├── 工作专注
│   ├── 周末放松
│   ├── 运动健身
│   ├── 学习时光
│   └── 夜晚安眠
├── 音乐库 (library)
├── 推荐 (recommend)
└── 其他 (others)
    ├── 播放历史
    └── 设置
```

**使用示例**:
```dart
CollapsibleSidebar(
  selectedMenuItem: _selectedMenuItem,
  onMenuItemSelected: (menuType) {
    setState(() {
      _selectedMenuItem = menuType;
      _selectedSubItem = null;
    });
  },
  onSubItemSelected: (subItemTitle) {
    setState(() {
      _selectedSubItem = subItemTitle;
    });
  },
)
```

### 2. PlayerControlBar (播放控制栏)

**文件位置**: `lib/widgets/player_control_bar.dart`

**功能特性**:
- 固定高度: 80px
- 三段式布局: 当前曲目 (300px) | 播放控制 (居中) | 音量等控制 (200px)

**控件说明**:
- **左侧 (300px)**: 封面缩略图 + 曲目信息 + 收藏按钮
- **中间 (居中)**: 
  - 播放控制按钮: 随机播放 | 上一曲 | 播放/暂停 | 下一曲 | 循环模式
  - 进度条: 当前时间 | 滑动条 | 总时长
- **右侧 (200px)**: 播放列表按钮 + 音量控制 (悬停显示滑块)

### 3. SearchBar (搜索栏)

**位置**: `lib/main.dart` 中的 `_buildSearchBar()` 方法

**功能特性**:
- 高度: 40px
- 圆角: 20px
- 支持搜索和清空
- 提示文本: "搜索音乐、歌手、歌词..."
- 右侧用户头像/设置按钮

### 4. 页面组件

**文件位置**: `lib/pages/pages.dart`

包含四个主要页面:
- `HomePage`: 首页,显示选中的播放列表
- `LibraryPage`: 音乐库页面
- `RecommendPage`: 推荐页面
- `OthersPage`: 其他功能页面 (播放历史/设置)

当前为占位组件,后续将集成 API 数据。

## 数据模型

### SidebarMenuItem (侧边栏菜单项)

**文件位置**: `lib/models/sidebar_menu.dart`

```dart
class SidebarMenuItem {
  final String title;           // 菜单标题
  final IconData icon;          // 图标
  final MenuItemType type;      // 菜单类型
  final List<String>? subItems; // 二级菜单项 (可选)
}

enum MenuItemType {
  home,      // 首页
  library,   // 音乐库
  recommend, // 推荐
  others,    // 其他
}
```

**模拟数据**: `MockData.menuItems` - 包含完整的菜单结构

## 主题配置

### 亮色主题
```dart
ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  useMaterial3: true,
  brightness: Brightness.light,
)
```

### 深色主题 (默认)
```dart
ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.dark,
  ),
  useMaterial3: true,
  brightness: Brightness.dark,
)
```

## 状态管理

当前使用 `StatefulWidget` 进行基本状态管理:

```dart
class _MusicPlayerHomeState extends State<MusicPlayerHome> {
  MenuItemType _selectedMenuItem = MenuItemType.home;  // 当前选中的菜单
  String? _selectedSubItem;                            // 当前选中的子菜单
  final TextEditingController _searchController;       // 搜索框控制器
}
```

### 状态流转

1. **菜单切换**:
   ```
   用户点击侧边栏菜单 
   → onMenuItemSelected 回调 
   → 更新 _selectedMenuItem 
   → 重建 UI 显示对应页面
   ```

2. **子菜单切换**:
   ```
   用户点击二级菜单 
   → onSubItemSelected 回调 
   → 更新 _selectedSubItem 
   → 页面组件接收参数更新显示
   ```

3. **搜索操作**:
   ```
   用户输入搜索内容 
   → onChanged 触发 setState 
   → 显示/隐藏清除按钮
   → onSubmitted 执行搜索 (待实现)
   ```

## 响应式设计

### 侧边栏响应
- 使用 `MouseRegion` 检测鼠标进入/离开
- `AnimatedContainer` 实现平滑宽度过渡
- 二级菜单高度动态计算 (不超过屏幕 40%)

### 搜索栏响应
- `Expanded` 占据剩余空间
- 固定右侧按钮宽度
- 自适应窗口宽度变化

### 播放控制栏响应
- 左右固定宽度 (300px + 200px)
- 中间播放控制居中显示
- 进度条自适应宽度

## 后续集成计划

### API 集成
1. 连接 `MusicApiService` 获取真实数据
2. 实现搜索功能 (调用 `searchMusic` 接口)
3. 加载播放列表数据
4. 获取音乐详情和封面

### 状态管理升级
- 考虑使用 GetX 或 Provider 进行全局状态管理
- 管理当前播放状态
- 管理播放列表状态
- 管理用户收藏状态

### 功能增强
1. **首页**: 显示歌曲列表,支持排序和筛选
2. **音乐库**: 展示本地音乐和在线收藏
3. **推荐**: 根据用户喜好推荐歌曲
4. **播放历史**: 显示最近播放记录
5. **设置**: 应用配置和偏好设置

### 播放器集成
- 连接 `MusicPlayerService` 实现真实播放
- 更新播放状态到 UI
- 同步进度条显示
- 实现播放队列管理

## 运行应用

### 开发环境
```bash
flutter run -d windows
```

### 生产构建
```bash
flutter build windows --release
```

## 文件结构总结

```
lib/
├── main.dart                           # 应用入口和主布局
├── models/
│   ├── music.dart                      # 音乐数据模型
│   └── sidebar_menu.dart               # 侧边栏菜单数据模型
├── services/
│   └── music_api_service.dart          # API 服务层
├── widgets/
│   ├── collapsible_sidebar.dart        # 可折叠侧边栏组件
│   └── player_control_bar.dart         # 播放控制栏组件
├── pages/
│   └── pages.dart                      # 各个页面组件
├── config/
│   └── api_config.dart                 # API 配置
├── utils/
│   └── logger.dart                     # 日志工具
└── music_player_service.dart           # 音乐播放服务
```

## 设计原则

1. **模块化**: 每个组件独立封装,职责清晰
2. **可复用**: 通用组件支持参数配置
3. **响应式**: 适配不同窗口尺寸
4. **Material Design 3**: 遵循最新设计规范
5. **深色主题**: 优化夜间使用体验
6. **动画流畅**: 提供平滑的交互反馈

## 性能优化

1. **懒加载**: 页面内容按需加载
2. **缓存策略**: 使用 `cached_network_image` 缓存封面
3. **列表优化**: 二级菜单使用 `ListView.builder`
4. **状态最小化**: 只在必要时触发 `setState`

## 开发建议

1. 先完成 UI 布局,确保交互流畅
2. 逐步集成 API,一次一个模块
3. 使用 Logger 工具调试网络请求
4. 测试不同窗口尺寸下的显示效果
5. 考虑添加加载状态和错误处理
