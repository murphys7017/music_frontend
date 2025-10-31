import 'package:flutter/material.dart';

/// 首页 - 展示收藏音乐和自建歌单
class HomePage extends StatelessWidget {
  final String? selectedPlaylist;

  const HomePage({super.key, this.selectedPlaylist});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            selectedPlaylist != null ? '歌单: $selectedPlaylist' : '首页',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '收藏音乐 + 自建歌单',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

/// 音乐库页面 - 展示所有音乐
class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_music, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('音乐库', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            '服务器 + 本地全部音乐',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

/// 推荐页面 - 展示推荐音乐和歌单
class RecommendPage extends StatelessWidget {
  const RecommendPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.recommend, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('推荐', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            '服务器推荐音乐和歌单',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

/// 其他页面 - 播放历史、设置等
class OthersPage extends StatelessWidget {
  final String? selectedItem;

  const OthersPage({super.key, this.selectedItem});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.more_horiz, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            selectedItem ?? '其他',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '播放历史 / 设置',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
