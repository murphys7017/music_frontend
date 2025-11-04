import 'package:flutter/material.dart';
import '../../services/music_api_service.dart';
import '../../models/music.dart';
import '../../config/api_config.dart';

/// 控制音乐库逻辑（如加载音乐、刷新、状态管理等）
class LibraryController extends ChangeNotifier {
  final MusicApiService _apiService = MusicApiService(
    baseUrl: ApiConfig.baseUrl,
    authToken: ApiConfig.authToken,
  );

  List<Music> musicList = [];
  int total = 0;
  int page = 1;
  int pageSize = 20;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;
  String? error;

  LibraryController() {
    fetchMusicList(reset: true);
  }

  Future<void> fetchMusicList({bool reset = false}) async {
    if (isLoading || isLoadingMore) return;
    if (reset) {
      page = 1;
      hasMore = true;
      musicList.clear();
      error = null;
      isLoading = true;
      notifyListeners();
      debugPrint('Fetching music list (reset)...');
    } else {
      if (!hasMore) return;
      isLoadingMore = true;
      notifyListeners();
      debugPrint('Fetching more music (page: $page)...');
    }
    try {
      final resp = await _apiService.listMusic(page: page, pageSize: pageSize);
      debugPrint(
        'API response: ${resp.items.length} items, total: ${resp.total}, page: ${resp.page}',
      );
      if (reset) {
        musicList = resp.items;
      } else {
        musicList.addAll(resp.items);
      }
      total = resp.total;
      hasMore = musicList.length < total;
      page = resp.page + 1;
      error = null; // 清除之前的错误
      debugPrint(
        'Updated musicList length: ${musicList.length}, hasMore: $hasMore',
      );
    } catch (e, stackTrace) {
      error = e.toString();
      debugPrint('Error fetching music: $error');
      debugPrint('Stack trace: $stackTrace');
    } finally {
      isLoading = false;
      isLoadingMore = false;
      notifyListeners();
      debugPrint(
        'Fetch complete. isLoading: $isLoading, isLoadingMore: $isLoadingMore, hasMore: $hasMore, musicList.length: ${musicList.length}',
      );
    }
  }

  void refresh() {
    fetchMusicList(reset: true);
  }

  void loadMore() {
    if (hasMore && !isLoading && !isLoadingMore) {
      fetchMusicList();
    }
  }

  void setPageSize(int size) {
    pageSize = size;
    refresh();
  }
}
