import 'package:flutter/material.dart';

/// 菜单项类型
enum MenuItemType {
  home, // 首页
  library, // 音乐库
  recommend, // 推荐
  others, // 其他
}

/// 侧边栏菜单项
class SidebarMenuItem {
  final String title;
  final IconData icon;
  final MenuItemType type;
  final List<String>? subItems; // 二级菜单项（可选）

  SidebarMenuItem({
    required this.title,
    required this.icon,
    required this.type,
    this.subItems,
  });
}

/// 模拟数据
class MockData {
  /// 一级菜单
  static final List<SidebarMenuItem> menuItems = [
    SidebarMenuItem(
      title: '首页',
      icon: Icons.home_outlined,
      type: MenuItemType.home,
      subItems: ['我的最爱', '工作专注', '周末放松', '运动健身', '学习时光', '夜晚安眠'],
    ),
    SidebarMenuItem(
      title: '音乐库',
      icon: Icons.library_music_outlined,
      type: MenuItemType.library,
    ),
    SidebarMenuItem(
      title: '推荐',
      icon: Icons.recommend_outlined,
      type: MenuItemType.recommend,
    ),
    SidebarMenuItem(
      title: '其他',
      icon: Icons.more_horiz,
      type: MenuItemType.others,
      subItems: ['播放历史', '设置'],
    ),
  ];

  /// 获取指定菜单项的二级菜单
  static List<String>? getSubItems(MenuItemType type) {
    return menuItems.firstWhere((item) => item.type == type).subItems;
  }
}
