import 'package:flutter/material.dart';
import 'music_player_service.dart';
import 'widgets/collapsible_sidebar.dart';
import 'widgets/player_control_bar.dart';
import 'models/sidebar_menu.dart';
import 'pages/pages.dart';
import 'services/device_service.dart';
import 'utils/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize device service
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

/// ScrollBehavior that disables scrollbars globally
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

  // Return the page matching the selected menu item
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

  // Build the top search bar
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
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
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
                  // TODO: implement search
                  debugPrint('Search for: $value');
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          // User avatar / settings button
          IconButton(
            icon: const Icon(Icons.account_circle),
            iconSize: 32,
            onPressed: () {
              // TODO: show user menu
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: Column(
        children: [
          // Main content area (sidebar + pages)
          Expanded(
            child: Row(
              children: [
                // Collapsible sidebar
                CollapsibleSidebar(
                  selectedMenuItem: _selectedMenuItem,
                  onMenuItemSelected: (menuType) {
                    setState(() {
                      _selectedMenuItem = menuType;
                      _selectedSubItem = null;
                    });
                  },
                ),

                // Right content area
                Expanded(
                  child: Column(
                    children: [
                      // Top search bar
                      _buildSearchBar(),

                      // Active page
                      Expanded(child: _buildCurrentPage()),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom player controls
          const PlayerControlBar(),
        ],
      ),
    );
  }
}
