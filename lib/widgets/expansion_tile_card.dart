library expansion_tile_card;

// 最初基于 Flutter 的 ExpansionTile。
//
// 版权所有 2014 The Flutter Authors。保留所有权利。
// 版权所有 2020 Kyle Bradshaw。保留所有权利。
//
// 使用此源代码需遵守 BSD 风格的许可证，
// 许可证内容请参阅 LICENSE 文件。

import 'package:flutter/material.dart';

/// 一个单行 [ListTile]，带有一个尾部按钮，可展开或折叠
/// 以显示或隐藏 [children]。
///
/// 此小部件通常与 [ListView] 一起使用，以创建一个
/// "展开/折叠" 的列表项。当与 [ListView] 等滚动小部件一起使用时，
/// 必须指定唯一的 [PageStorageKey]，以便 [ExpansionTileCard]
/// 在滚动进出视图时保存和恢复其展开状态。
///
/// 另请参阅：
///
///  * [ListTile]，在扩展项表示子列表时，
///    可用于创建扩展项的 [children]。
///  * [ExpansionTile]，此小部件的原始版本。
///  * "展开/折叠" 部分，参见
///    <https://material.io/guidelines/components/lists-controls.html>。
class ExpansionTileCard extends StatefulWidget {
  /// 创建一个单行 [ListTile]，带有一个尾部按钮，可展开或折叠
  /// 以显示或隐藏 [children]。 [initiallyExpanded] 属性必须
  /// 为非空。
  const ExpansionTileCard({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.onExpansionChanged,
    this.children = const <Widget>[],
    this.trailing,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.elevation = 2.0,
    this.initialElevation = 0.0,
    this.initiallyExpanded = false,
    this.initialPadding = EdgeInsets.zero,
    this.finalPadding = const EdgeInsets.only(bottom: 6.0),
    this.contentPadding,
    this.baseColor,
    this.expandedColor,
    this.expandedTextColor,
    this.duration = const Duration(milliseconds: 200),
    this.elevationCurve = Curves.easeOut,
    this.heightFactorCurve = Curves.easeIn,
    this.colorCurve = Curves.easeIn,
    this.paddingCurve = Curves.easeIn,
    this.isThreeLine = false,
    this.shadowColor = const Color(0xffaaaaaa),
    this.animateTrailing = false,
  });

  final bool isThreeLine;

  /// 在标题之前显示的小部件。
  ///
  /// 通常是一个 [CircleAvatar] 小部件。
  final Widget? leading;

  /// 列表项的主要内容。
  ///
  /// 通常是一个 [Text] 小部件。
  final Widget title;

  /// 显示在标题下方的附加内容。
  ///
  /// 通常是一个 [Text] 小部件。
  final Widget? subtitle;

  /// 当扩展项展开或折叠时调用。
  ///
  /// 当扩展项开始展开时，此函数会以值 true 调用。
  /// 当扩展项开始折叠时，此函数会以值 false 调用。
  final ValueChanged<bool>? onExpansionChanged;

  /// 扩展项展开时显示的小部件。
  ///
  /// 通常是 [ListTile] 小部件。
  final List<Widget> children;

  /// 用于替代旋转箭头图标的小部件。
  final Widget? trailing;

  /// 是否为自定义尾部小部件启用动画。
  ///
  /// 默认为 false。
  final bool animateTrailing;

  /// Material 小部件的边框半径。仅在展开后可见。
  ///
  /// 默认为半径为 8.0 的圆角边框。
  final BorderRadiusGeometry borderRadius;

  /// 展开后 Material 小部件的最终阴影高度。
  ///
  /// 默认为 2.0。
  final double elevation;

  /// 折叠时的阴影高度。
  ///
  /// 默认为 0.0。
  final double initialElevation;

  /// 卡片阴影的颜色。
  ///
  /// 默认为 Color(0xffaaaaaa)。
  final Color shadowColor;

  /// 指定列表项是初始展开（true）还是折叠（false，默认值）。
  final bool initiallyExpanded;

  /// 折叠时 ExpansionTileCard 外部的填充。
  ///
  /// 默认为 EdgeInsets.zero。
  final EdgeInsetsGeometry initialPadding;

  /// 展开时 ExpansionTileCard 外部的填充。
  ///
  /// 默认为 6.0 的垂直填充。
  final EdgeInsetsGeometry finalPadding;

  /// ListTile 小部件的内部 `contentPadding`。
  ///
  /// 如果为 null，ListTile 默认为 16.0 的水平填充。
  final EdgeInsetsGeometry? contentPadding;

  /// 未展开时的背景颜色。
  ///
  /// 如果为 null，默认为 Theme.of(context).canvasColor。
  final Color? baseColor;

  /// 展开卡片时的背景颜色。
  ///
  /// 如果为 null，默认为 Theme.of(context).cardColor。
  final Color? expandedColor;

  /// 展开卡片时文本的颜色。
  ///
  /// 如果为 null，默认为 Theme.of(context).colorScheme.secondary。
  final Color? expandedTextColor;

  /// 展开和折叠动画的持续时间。
  ///
  /// 默认为 200 毫秒。
  final Duration duration;

  /// 用于控制展开卡片阴影的动画曲线。
  ///
  /// 默认为 Curves.easeOut。
  final Curve elevationCurve;

  /// 用于控制展开/折叠卡片高度的动画曲线。
  ///
  /// 默认为 Curves.easeIn。
  final Curve heightFactorCurve;

  /// 用于控制标题、图标和 Material 颜色的动画曲线。
  ///
  /// 默认为 Curves.easeIn。
  final Curve colorCurve;

  /// 用于展开/折叠填充的动画曲线。
  ///
  /// 默认为 Curves.easeIn。
  final Curve paddingCurve;

  @override
  ExpansionTileCardState createState() => ExpansionTileCardState();
}

class ExpansionTileCardState extends State<ExpansionTileCard>
    with SingleTickerProviderStateMixin {
  final ColorTween _headerColorTween = ColorTween();
  final ColorTween _iconColorTween = ColorTween();
  final ColorTween _materialColorTween = ColorTween();
  late EdgeInsetsTween _edgeInsetsTween;
  late Animatable<double> _elevationTween;
  late Animatable<double> _heightFactorTween;
  late Animatable<double> _colorTween;
  late Animatable<double> _paddingTween;

  late AnimationController _controller;
  late Animation<double> _heightFactor;
  late Animation<double> _elevation;
  late Animation<Color?> _headerColor;
  late Animation<Color?> _iconColor;
  late Animation<Color?> _materialColor;
  late Animation<EdgeInsets> _padding;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _edgeInsetsTween = EdgeInsetsTween(
      begin: widget.initialPadding as EdgeInsets?,
      end: widget.finalPadding as EdgeInsets?,
    );
    _elevationTween = CurveTween(curve: widget.elevationCurve);
    _heightFactorTween = CurveTween(curve: widget.heightFactorCurve);
    _colorTween = CurveTween(curve: widget.colorCurve);
    _paddingTween = CurveTween(curve: widget.paddingCurve);

    _controller = AnimationController(duration: widget.duration, vsync: this);
    _heightFactor = _controller.drive(_heightFactorTween);
    _headerColor = _controller.drive(_headerColorTween.chain(_colorTween));
    _materialColor = _controller.drive(_materialColorTween.chain(_colorTween));
    _iconColor = _controller.drive(_iconColorTween.chain(_colorTween));
    _elevation = _controller.drive(
      Tween<double>(
        begin: widget.initialElevation,
        end: widget.elevation,
      ).chain(_elevationTween),
    );
    _padding = _controller.drive(_edgeInsetsTween.chain(_paddingTween));
    _isExpanded =
        PageStorage.of(context).readState(context) as bool? ??
        widget.initiallyExpanded;
    if (_isExpanded) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Credit: Simon Lightfoot - https://stackoverflow.com/a/48935106/955974
  void _setExpansion(bool shouldBeExpanded) {
    if (shouldBeExpanded != _isExpanded) {
      setState(() {
        _isExpanded = shouldBeExpanded;
        if (_isExpanded) {
          _controller.forward();
        } else {
          _controller.reverse().then<void>((void value) {
            if (!mounted) return;
            setState(() {
              // Rebuild without widget.children.
            });
          });
        }
        PageStorage.of(context).writeState(context, _isExpanded);
      });
      if (widget.onExpansionChanged != null)
        widget.onExpansionChanged!(_isExpanded);
    }
  }

  void expand() {
    _setExpansion(true);
  }

  void collapse() {
    _setExpansion(false);
  }

  void toggleExpansion() {
    _setExpansion(!_isExpanded);
  }

  Widget _buildChildren(BuildContext context, Widget? child) {
    return Padding(
      padding: _padding.value,
      child: Material(
        type: MaterialType.card,
        color: _materialColor.value,
        borderRadius: widget.borderRadius,
        elevation: _elevation.value,
        shadowColor: widget.shadowColor,
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              InkWell(
                customBorder: RoundedRectangleBorder(
                  borderRadius: widget.borderRadius,
                ),
                onTap: toggleExpansion,
                child: ListTileTheme.merge(
                  iconColor: _iconColor.value,
                  textColor: _headerColor.value,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ListTile(
                      isThreeLine: widget.isThreeLine,
                      contentPadding: widget.contentPadding,
                      leading: IconButton(
                        icon: Icon(
                          _isExpanded
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                        ),
                        onPressed: () {
                          toggleExpansion();
                        },
                      ),
                      title: widget.title,
                      subtitle: widget.subtitle,
                      trailing: widget.trailing ?? Icon(Icons.expand_more),
                    ),
                  ),
                ),
              ),
              ClipRect(
                child: Align(heightFactor: _heightFactor.value, child: child),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    final ThemeData theme = Theme.of(context);
    _headerColorTween
      ..begin = theme.textTheme.titleMedium!.color
      ..end = widget.expandedTextColor ?? theme.colorScheme.secondary;
    _iconColorTween
      ..begin = theme.unselectedWidgetColor
      ..end = widget.expandedTextColor ?? theme.colorScheme.secondary;
    _materialColorTween
      ..begin = widget.baseColor ?? theme.canvasColor
      ..end = widget.expandedColor ?? theme.cardColor;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final bool closed = !_isExpanded && _controller.isDismissed;
    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
      child: closed ? null : Column(children: widget.children),
    );
  }
}
