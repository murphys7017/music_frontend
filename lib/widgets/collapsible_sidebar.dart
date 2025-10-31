import 'package:flutter/material.dart';
import '../models/sidebar_menu.dart';
import '../services/playlist_service.dart';
import '../models/playlist.dart';
import '../config/sidebar_config.dart';

/// 可折叠侧边栏 - 扁平化设计，圆角胶囊选中效果
class CollapsibleSidebar extends StatefulWidget {
  final MenuItemType selectedMenuItem;
  final Function(MenuItemType) onMenuItemSelected;
  final Function(String)? onPlaylistSelected;
  final String? selectedPlaylistId;

  const CollapsibleSidebar({
    super.key,
    required this.selectedMenuItem,
    required this.onMenuItemSelected,
    this.onPlaylistSelected,
    this.selectedPlaylistId,
  });

  @override
  State<CollapsibleSidebar> createState() => _CollapsibleSidebarState();
}

class _CollapsibleSidebarState extends State<CollapsibleSidebar> {
  bool _isExpanded = false;
  final PlaylistService _playlistService = PlaylistService();
  List<Playlist> _userPlaylists = [];
  Playlist? _favoritesPlaylist;
  Playlist? _recentPlaylist;

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    try {
      // 确保服务已初始化
      await _playlistService.initialize();

      setState(() {
        _userPlaylists = _playlistService.getUserPlaylists();
        _favoritesPlaylist = _playlistService.getFavoritesPlaylist();
        _recentPlaylist = _playlistService.getRecentPlaylist();
      });
    } catch (e) {
      // 静默处理错误
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isExpanded = true),
      onExit: (_) => setState(() => _isExpanded = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        clipBehavior: Clip.hardEdge,
        width: _isExpanded
            ? SidebarConfig.expandedWidth
            : SidebarConfig.collapsedWidth,
        // 使用顶部分离的额外偏移，让侧边栏整体下移
        margin: EdgeInsets.fromLTRB(
          SidebarConfig.margin,
          SidebarConfig.margin + SidebarConfig.topExtraOffset,
          SidebarConfig.margin,
          SidebarConfig.margin,
        ),
        decoration: BoxDecoration(
          color: SidebarConfig.backgroundColorWithOpacity,
          borderRadius: BorderRadius.circular(SidebarConfig.borderRadius),
          boxShadow: SidebarConfig.boxShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 音乐库区域（顶部间距移到 ListView padding 内部）
            Expanded(
              child: ListView(
                // 统一顶部内边距，保证第一项（音乐库标题 + 首页）位置稳定
                padding: const EdgeInsets.fromLTRB(4, 16, 4, 0),
                physics: const ClampingScrollPhysics(),
                children: [
                  // 音乐库分组
                  _buildSectionTitle('音乐库'),
                  _buildMenuItem(
                    icon: Icons.home_rounded,
                    title: '首页',
                    isSelected: widget.selectedMenuItem == MenuItemType.home,
                    onTap: () => widget.onMenuItemSelected(MenuItemType.home),
                  ),
                  _buildMenuItem(
                    icon: Icons.library_music_rounded,
                    title: '我的音乐',
                    isSelected: widget.selectedMenuItem == MenuItemType.library,
                    onTap: () =>
                        widget.onMenuItemSelected(MenuItemType.library),
                  ),

                  const SizedBox(height: 20),

                  // 我的歌单分组
                  _buildSectionTitle('我的歌单'),
                  // 我喜欢的
                  if (_favoritesPlaylist != null)
                    _buildPlaylistItem(
                      icon: Icons.favorite_rounded,
                      playlist: _favoritesPlaylist!,
                      isSelected:
                          widget.selectedPlaylistId == _favoritesPlaylist!.id,
                      onTap: () => widget.onPlaylistSelected?.call(
                        _favoritesPlaylist!.id,
                      ),
                    ),
                  // 最近播放
                  if (_recentPlaylist != null)
                    _buildPlaylistItem(
                      icon: Icons.history_rounded,
                      playlist: _recentPlaylist!,
                      isSelected:
                          widget.selectedPlaylistId == _recentPlaylist!.id,
                      onTap: () =>
                          widget.onPlaylistSelected?.call(_recentPlaylist!.id),
                    ),

                  const SizedBox(height: 8),

                  // 用户创建的歌单
                  ..._userPlaylists.map(
                    (playlist) => _buildPlaylistItem(
                      icon: Icons.queue_music_rounded,
                      playlist: playlist,
                      isSelected: widget.selectedPlaylistId == playlist.id,
                      onTap: () => widget.onPlaylistSelected?.call(playlist.id),
                    ),
                  ),

                  // 创建歌单按钮
                  if (_isExpanded)
                    _buildCreatePlaylistButton()
                  else
                    _buildMenuItem(
                      icon: Icons.add_rounded,
                      title: '创建歌单',
                      isSelected: false,
                      onTap: _showCreatePlaylistDialog,
                    ),

                  const SizedBox(height: 20),

                  // 发现分组
                  _buildSectionTitle('发现'),
                  _buildMenuItem(
                    icon: Icons.explore_rounded,
                    title: '推荐',
                    isSelected:
                        widget.selectedMenuItem == MenuItemType.recommend,
                    onTap: () =>
                        widget.onMenuItemSelected(MenuItemType.recommend),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建分组标题
  Widget _buildSectionTitle(String title) {
    // 固定高度，避免收缩时其他元素补位造成跳动
    const double kSectionHeight = 28; // 可微调
    return SizedBox(
      height: kSectionHeight,
      child: AnimatedOpacity(
        opacity: _isExpanded ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 4),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: SidebarConfig.sectionTitleColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建菜单项（扁平化圆角胶囊）
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SidebarConfig.selectedBorderRadius),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: isSelected
                ? SidebarConfig.selectedBackgroundColorWithOpacity
                : Colors.transparent,
            borderRadius: BorderRadius.circular(
              SidebarConfig.selectedBorderRadius,
            ),
          ),
          child: _isExpanded
              ? Row(
                  children: [
                    // 展开状态：固定宽度图标 + 文字
                    SizedBox(
                      width: 46,
                      child: Icon(
                        icon,
                        size: 22,
                        color: isSelected
                            ? SidebarConfig.selectedIconColor
                            : SidebarConfig.iconColor,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? SidebarConfig.selectedTextColor
                                      : SidebarConfig.textColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            if (trailing != null) ...[
                              const SizedBox(width: 4),
                              trailing,
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Icon(
                      icon,
                      size: 22,
                      color: isSelected
                          ? SidebarConfig.selectedIconColor
                          : SidebarConfig.iconColor,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  /// 构建歌单项
  Widget _buildPlaylistItem({
    required IconData icon,
    required Playlist playlist,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return _buildMenuItem(
      icon: icon,
      title: playlist.name,
      isSelected: isSelected,
      onTap: onTap,
      trailing: _isExpanded && playlist.musicCount > 0
          ? Text(
              '${playlist.musicCount}',
              style: const TextStyle(
                fontSize: 12,
                color: SidebarConfig.sectionTitleColor,
              ),
            )
          : null,
    );
  }

  /// 构建创建歌单按钮
  Widget _buildCreatePlaylistButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: InkWell(
        onTap: _showCreatePlaylistDialog,
        borderRadius: BorderRadius.circular(SidebarConfig.selectedBorderRadius),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: SidebarConfig.selectedIconColor.withOpacity(0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(
              SidebarConfig.selectedBorderRadius,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.add_rounded,
                size: 20,
                color: SidebarConfig.selectedIconColor,
              ),
              const SizedBox(width: 6),
              const Flexible(
                child: Text(
                  '创建歌单',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: SidebarConfig.selectedTextColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 显示创建歌单对话框
  void _showCreatePlaylistDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建歌单'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '请输入歌单名称',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              _createPlaylist(value.trim());
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _createPlaylist(controller.text.trim());
                Navigator.of(context).pop();
              }
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  /// 创建歌单
  Future<void> _createPlaylist(String name) async {
    try {
      await _playlistService.createPlaylist(name: name);
      await _loadPlaylists(); // 重新加载歌单列表

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('歌单 "$name" 创建成功')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('创建歌单失败: $e')));
      }
    }
  }
}
