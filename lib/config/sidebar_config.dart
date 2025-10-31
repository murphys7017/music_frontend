import 'package:flutter/material.dart';

/// 侧边栏样式配置
class SidebarConfig {
  // ==================== 搜索框配置 ====================
  /// 搜索框宽度占侧边栏比例
  static const double searchBarWidthRatio = 1 / 3;

  /// 搜索框顶部间距
  static const double searchBarTopMargin = 20.0;

  /// 搜索框右侧间距
  static const double searchBarRightMargin = 20.0;

  /// 搜索框高度
  static const double searchBarHeight = 40.0;

  /// 搜索框圆角
  static const double searchBarBorderRadius = 16.0;

  /// 搜索框背景色
  static const Color searchBarBackgroundColor = Color(0x66FFFFFF);

  /// 搜索框背景透明度
  static const double searchBarBackgroundOpacity = 0.5;

  /// 搜索框毛玻璃模糊度
  static const double searchBarBlurSigma = 16.0;

  /// 搜索框边框色
  static const Color searchBarBorderColor = Color(0x22FFFFFF);

  /// 搜索框边框宽度
  static const double searchBarBorderWidth = 1.0;
  // ==================== 背景配置 ====================
  /// 侧边栏背景颜色
  static const Color backgroundColor = Color.fromARGB(87, 55, 16, 73);

  /// 背景透明度 (0.0 - 1.0)
  static const double backgroundOpacity = 0.85;

  /// 圆角半径
  static const double borderRadius = 24.0;

  // ==================== 阴影配置 ====================
  /// 阴影颜色
  static const Color shadowColor = Colors.black;

  /// 阴影透明度
  static const double shadowOpacity = 0.15;

  /// 阴影模糊半径
  static const double shadowBlurRadius = 20.0;

  // ==================== 文字颜色配置 ====================
  /// 普通菜单项文字颜色
  static const Color textColor = Color(0xFF2c3e50);

  /// 选中菜单项文字颜色
  static const Color selectedTextColor = Color(0xFF3498db);

  /// 分组标题文字颜色
  static const Color sectionTitleColor = Color(0xFF7f8c8d);

  // ==================== 图标颜色配置 ====================
  /// 普通图标颜色
  static const Color iconColor = Color(0xFF2c3e50);

  /// 选中图标颜色
  static const Color selectedIconColor = Color(0xFF3498db);

  /// Logo图标颜色
  static const Color logoIconColor = Color(0xFF3498db);

  // ==================== 选中状态配置 ====================
  /// 选中项背景颜色
  static const Color selectedBackgroundColor = Color(0xFF3498db);

  /// 选中项背景透明度
  static const double selectedBackgroundOpacity = 0.15;

  /// 选中项圆角
  static const double selectedBorderRadius = 14.0;

  // ==================== Logo卡片配置 ====================
  /// Logo卡片渐变起始颜色
  static const Color logoGradientStart = Color(0xFFe3f2fd);

  /// Logo卡片渐变结束颜色
  static const Color logoGradientEnd = Color(0xFFbbdefb);

  /// Logo卡片圆角
  static const double logoCardBorderRadius = 16.0;

  /// Logo卡片阴影颜色
  static const Color logoShadowColor = Color(0xFF3498db);

  /// Logo卡片阴影透明度
  static const double logoShadowOpacity = 0.3;

  // ==================== 尺寸配置 ====================
  /// 收起状态宽度
  static const double collapsedWidth = 65.0;

  /// 展开状态宽度
  static const double expandedWidth = 240.0;

  /// 侧边栏高度占屏幕百分比
  static const double heightRatio = 0.8;

  /// 外边距
  static const double margin = 5.0;

  /// 顶部额外偏移，可用于让侧边栏整体离窗口顶部更远
  static const double topExtraOffset = 25.0; // 可根据需要调整

  // ==================== 辅助方法 ====================
  /// 获取背景颜色（带透明度）
  static Color get backgroundColorWithOpacity =>
      backgroundColor.withOpacity(backgroundOpacity);

  /// 获取选中背景颜色（带透明度）
  static Color get selectedBackgroundColorWithOpacity =>
      selectedBackgroundColor.withOpacity(selectedBackgroundOpacity);

  /// 获取阴影
  static List<BoxShadow> get boxShadow => [
    BoxShadow(
      color: shadowColor.withOpacity(shadowOpacity),
      blurRadius: shadowBlurRadius,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];

  /// 获取Logo卡片阴影
  static List<BoxShadow> get logoBoxShadow => [
    BoxShadow(
      color: logoShadowColor.withOpacity(logoShadowOpacity),
      blurRadius: 12,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      spreadRadius: -2,
      offset: const Offset(0, 2),
    ),
  ];
}
