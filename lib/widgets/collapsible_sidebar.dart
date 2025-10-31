import 'package:flutter/material.dart';
import '../models/sidebar_menu.dart';

/// 可折叠侧边栏
class CollapsibleSidebar extends StatefulWidget {
  final MenuItemType selectedMenuItem;
  final Function(MenuItemType) onMenuItemSelected;
  final Function(String)? onSubItemSelected;

  const CollapsibleSidebar({
    super.key,
    required this.selectedMenuItem,
    required this.onMenuItemSelected,
    this.onSubItemSelected,
  });

  @override
  State<CollapsibleSidebar> createState() => _CollapsibleSidebarState();
}

class _CollapsibleSidebarState extends State<CollapsibleSidebar> {
  bool _isExpanded = false; // 侧边栏是否展开
  MenuItemType? _expandedMenuItem; // 当前展开的一级菜单项
  final double _collapsedWidth = 60.0; // 收起时的宽度
  final double _expandedWidth = 220.0; // 展开时的宽度

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isExpanded = true),
      onExit: (_) => setState(() => _isExpanded = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _isExpanded ? _expandedWidth : _collapsedWidth,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          border: Border(
            right: BorderSide(color: Theme.of(context).dividerColor, width: 1),
          ),
        ),
        child: Column(
          children: [
            // Logo 或标题区域
            Container(
              height: 60,
              alignment: Alignment.center,
              child: _isExpanded
                  ? const Text(
                      '音乐播放器',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : const Icon(Icons.music_note, size: 28),
            ),
            const Divider(height: 1),
            // 菜单列表
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: MockData.menuItems.length,
                itemBuilder: (context, index) {
                  final menuItem = MockData.menuItems[index];
                  final isSelected = widget.selectedMenuItem == menuItem.type;
                  final isExpanded = _expandedMenuItem == menuItem.type;

                  return Column(
                    children: [
                      // 一级菜单项
                      _buildMenuItem(
                        menuItem: menuItem,
                        isSelected: isSelected,
                        isExpanded: isExpanded,
                        onTap: () {
                          setState(() {
                            // 如果有二级菜单，切换展开状态
                            if (menuItem.subItems != null &&
                                menuItem.subItems!.isNotEmpty) {
                              _expandedMenuItem = isExpanded
                                  ? null
                                  : menuItem.type;
                            } else {
                              _expandedMenuItem = null;
                            }
                          });
                          widget.onMenuItemSelected(menuItem.type);
                        },
                      ),
                      // 二级菜单项（动态渲染）
                      if (_isExpanded &&
                          isExpanded &&
                          menuItem.subItems != null)
                        _buildSubMenu(menuItem.subItems!),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建一级菜单项
  Widget _buildMenuItem({
    required SidebarMenuItem menuItem,
    required bool isSelected,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: _isExpanded ? 16 : 12),
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
            : null,
        child: Row(
          children: [
            Icon(
              menuItem.icon,
              size: 24,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            if (_isExpanded) ...[
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  menuItem.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              // 如果有二级菜单，显示展开图标
              if (menuItem.subItems != null && menuItem.subItems!.isNotEmpty)
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建二级菜单
  Widget _buildSubMenu(List<String> subItems) {
    return Container(
      constraints: BoxConstraints(
        // 根据侧边栏高度动态计算最大高度
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: subItems.length,
        itemBuilder: (context, index) {
          final subItem = subItems[index];
          return InkWell(
            onTap: () {
              widget.onSubItemSelected?.call(subItem);
            },
            child: Container(
              height: 40,
              padding: const EdgeInsets.only(left: 56, right: 16),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      subItem,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
