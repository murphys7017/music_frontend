import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 音乐卡片组件，圆角小巧，适合音乐库卡片式展示
class MusicCard extends StatelessWidget {
  final String coverUrl;
  final String tag;
  final String playCount;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const MusicCard({
    Key? key,
    required this.coverUrl,
    required this.tag,
    required this.playCount,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget coverWidget;
    if (coverUrl.startsWith('file://') || coverUrl.startsWith('/')) {
      // 本地图片
      coverWidget = Image.asset(
        coverUrl.replaceFirst('file://', ''),
        height: 100,
        width: 180,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _errorPlaceholder(),
      );
    } else if (coverUrl.isNotEmpty) {
      // 网络图片
      coverWidget = CachedNetworkImage(
        imageUrl: coverUrl,
        height: 100,
        width: 180,
        fit: BoxFit.cover,
        placeholder: (context, url) => SizedBox(
          height: 100,
          width: 180,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => _errorPlaceholder(),
      );
    } else {
      // 空图片
      coverWidget = _errorPlaceholder();
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: const EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  coverWidget,
                  // 左上角角标
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            size: 16,
                            color: Colors.pink,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 左下角播放量
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.play_arrow, size: 14, color: Colors.white),
                          const SizedBox(width: 2),
                          Text(
                            playCount,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // 标题和副标题
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorPlaceholder() {
    return Container(
      height: 100,
      width: 180,
      color: Colors.grey[300],
      child: const Icon(Icons.music_note, size: 40, color: Colors.grey),
    );
  }
}
