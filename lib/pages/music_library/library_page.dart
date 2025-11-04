import 'package:flutter/material.dart';
import '../../models/music.dart';
import '../../services/music_api_service.dart';
import '../../config/api_config.dart';
import '../../widgets/music_card.dart';
import 'library_controller.dart';

class LibraryPage extends StatefulWidget {
  final LibraryController controller;
  const LibraryPage({Key? key, required this.controller}) : super(key: key);

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late final MusicApiService _apiService;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdate);
    _apiService = MusicApiService(
      baseUrl: ApiConfig.baseUrl,
      authToken: ApiConfig.authToken,
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      widget.controller.loadMore();
    }
  }

  void _onControllerUpdate() {
    if (mounted) {
      debugPrint(
        'Controller updated: isLoading=${widget.controller.isLoading}, musicList.length=${widget.controller.musicList.length}, error=${widget.controller.error}',
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    debugPrint(
      'Building LibraryPage: isLoading=${c.isLoading}, musicList.length=${c.musicList.length}',
    );
    return Scaffold(
      appBar: AppBar(title: const Text('音乐库')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: c.isLoading && c.musicList.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : c.error != null && c.musicList.isEmpty
            ? Center(child: Text('加载失败: ${c.error}')) // 修复错误信息显示问题
            : c.musicList.isEmpty
            ? const Center(child: Text('暂无音乐'))
            : NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollEndNotification) {
                    _onScroll();
                  }
                  return false;
                },
                child: GridView.builder(
                  controller: _scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: c.musicList.length + (c.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= c.musicList.length) {
                      // 加载更多指示器
                      if (c.isLoadingMore) {
                        return const Center(child: CircularProgressIndicator());
                      } else {
                        return const SizedBox.shrink();
                      }
                    }
                    final Music music = c.musicList[index];
                    return MusicCard(
                      coverUrl: _getFullCoverUrl(music),
                      tag: music.author,
                      playCount: _formatPlayCount(music.playCount),
                      title: music.name,
                      subtitle: music.album ?? '',
                      onTap: () {
                        // TODO: 播放或进入详情
                      },
                    );
                  },
                ),
              ),
      ),
    );
  }

  String _getFullCoverUrl(Music music) {
    final url = music.coverUrl;
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    if (music.coverUuid != null && music.coverUuid!.isNotEmpty) {
      return _apiService.getCoverUrl(music.coverUuid!);
    }
    return '';
  }

  String _formatPlayCount(int count) {
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}万';
    }
    return count.toString();
  }
}
