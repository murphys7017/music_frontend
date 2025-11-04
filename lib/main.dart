import 'package:flutter/material.dart';
import 'dart:ui';
import 'services/music_player_service.dart';
import 'widgets/collapsible_sidebar.dart';
import 'widgets/player_control_bar.dart';
import 'models/sidebar_menu.dart';
import 'pages/pages.dart';
import 'services/device_service.dart';
import 'utils/logger.dart';
import 'config/sidebar_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await DeviceService().initialize();
  } catch (e) {
    Logger.error('DeviceService 初始化失败: $e');
  }
  await MusicPlayerService.ensureInitialized(
    prefetchPlaylist: true,
    protocolWhitelist: ["http", "https", "file"],
  );
  runApp(const MyApp());
}

class NoScrollbarBehavior extends MaterialScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: NoScrollbarBehavior(),
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

  Widget _buildCurrentPage() {
    switch (_selectedMenuItem) {
      case MenuItemType.home:
        return HomePage(selectedPlaylist: _selectedSubItem);
      case MenuItemType.library:
        return LibraryPageWrapper();
      case MenuItemType.recommend:
        return const RecommendPage();
      case MenuItemType.others:
        return OthersPage(selectedItem: _selectedSubItem);
    }
  }

  // 悬浮搜索栏（宽度为窗口宽度的1/3，靠右，毛玻璃，参数配置化）
  Widget _buildFloatingSearchBar(double windowWidth) {
    final searchBarWidth = windowWidth * SidebarConfig.searchBarWidthRatio;
    return Positioned(
      top: SidebarConfig.searchBarTopMargin,
      right: SidebarConfig.searchBarRightMargin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          SidebarConfig.searchBarBorderRadius,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: SidebarConfig.searchBarBlurSigma,
            sigmaY: SidebarConfig.searchBarBlurSigma,
          ),
          child: Container(
            width: searchBarWidth,
            height: SidebarConfig.searchBarHeight,
            decoration: BoxDecoration(
              color: SidebarConfig.searchBarBackgroundColor.withOpacity(
                SidebarConfig.searchBarBackgroundOpacity,
              ),
              borderRadius: BorderRadius.circular(
                SidebarConfig.searchBarBorderRadius,
              ),
              border: Border.all(
                color: SidebarConfig.searchBarBorderColor,
                width: SidebarConfig.searchBarBorderWidth,
              ),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: '搜索音乐、歌手、歌词...',
                hintStyle: TextStyle(color: SidebarConfig.sectionTitleColor),
                prefixIcon: Icon(
                  Icons.search,
                  color: SidebarConfig.sectionTitleColor,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: SidebarConfig.sectionTitleColor,
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
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
              onSubmitted: (value) {
                debugPrint('Search for: $value');
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final windowWidth = constraints.maxWidth;
        final windowHeight = constraints.maxHeight;
        return Scaffold(
          backgroundColor: const Color(0xFF1a1a2e),
          body: Stack(
            children: [
              // 主内容区始终填满窗口
              Positioned.fill(
                child: Padding(
                  // 留出底部播放栏高度
                  padding: EdgeInsets.only(bottom: 80),
                  child: _buildCurrentPage(),
                ),
              ),
              // 悬浮侧边栏（限制最大高度）
              Positioned(
                left: SidebarConfig.margin,
                top: SidebarConfig.margin + SidebarConfig.topExtraOffset,
                child: SizedBox(
                  height: windowHeight * SidebarConfig.heightRatio,
                  child: CollapsibleSidebar(
                    selectedMenuItem: _selectedMenuItem,
                    onMenuItemSelected: (menuType) {
                      setState(() {
                        _selectedMenuItem = menuType;
                        _selectedSubItem = null;
                      });
                    },
                  ),
                ),
              ),
              // 悬浮搜索栏
              _buildFloatingSearchBar(windowWidth),
              // 悬浮底部播放栏
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: const PlayerControlBar(),
              ),
            ],
          ),
        );
      },
    );
  }
}
