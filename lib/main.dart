import 'package:flutter/material.dart';
import 'music_player_service.dart';
import 'widgets/collapsible_sidebar.dart';
import 'widgets/player_control_bar.dart';
import 'models/sidebar_menu.dart';
import 'pages/pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MusicPlayerService.ensureInitialized(
    prefetchPlaylist: true,
    protocolWhitelist: ["http", "https", "file"],
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.dark,
      home: const MusicPlayerHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MusicPlayerHome extends StatefulWidget {
  const MusicPlayerHome({super.key});

  @override
  State<MusicPlayerHome> createState() => _MusicPlayerHomeState();
}

class _MusicPlayerHomeState extends State<MusicPlayerHome> {
  MenuItemType _selectedMenuItem = MenuItemType.home;
  String? _selectedSubItem;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 根据选中的菜单项返回对应的页面
  Widget _buildCurrentPage() {
    switch (_selectedMenuItem) {
      case MenuItemType.home:
        return HomePage(selectedPlaylist: _selectedSubItem);
      case MenuItemType.library:
        return const LibraryPage();
      case MenuItemType.recommend:
        return const RecommendPage();
      case MenuItemType.others:
        return OthersPage(selectedItem: _selectedSubItem);
    }
  }

  // 构建搜索栏
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '搜索音乐、歌手、歌词...',
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
                onSubmitted: (value) {
                  // TODO: 实现搜索功能
                  debugPrint('Search for: $value');
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 用户头像/设置按钮
          IconButton(
            icon: const Icon(Icons.account_circle),
            iconSize: 32,
            onPressed: () {
              // TODO: 显示用户菜单
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 主内容区域 (包含侧边栏和内容)
          Expanded(
            child: Row(
              children: [
                // 可折叠侧边栏
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
                ),

                // 右侧主内容区域
                Expanded(
                  child: Column(
                    children: [
                      // 顶部搜索栏
                      _buildSearchBar(),

                      // 主内容页面
                      Expanded(child: _buildCurrentPage()),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 底部播放控制栏
          const PlayerControlBar(),
        ],
      ),
    );
  }
}
