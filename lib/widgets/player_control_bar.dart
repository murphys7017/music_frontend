import 'package:flutter/material.dart';

/// 底部播放控制栏
class PlayerControlBar extends StatefulWidget {
  const PlayerControlBar({super.key});

  @override
  State<PlayerControlBar> createState() => _PlayerControlBarState();
}

class _PlayerControlBarState extends State<PlayerControlBar> {
  bool _isPlaying = false;
  double _currentPosition = 0.3; // 当前播放进度 (0.0 - 1.0)
  double _volume = 0.7; // 音量 (0.0 - 1.0)
  bool _showVolumeSlider = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          // 左侧：当前播放歌曲信息
          _buildCurrentTrackInfo(),
          const Spacer(),
          // 中间：播放控制按钮
          Expanded(flex: 2, child: _buildPlaybackControls()),
          const Spacer(),
          // 右侧：音量控制等
          _buildRightControls(),
        ],
      ),
    );
  }

  /// 左侧:当前播放歌曲信息
  Widget _buildCurrentTrackInfo() {
    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // 封面
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.music_note, color: Colors.grey[600], size: 24),
          ),
          const SizedBox(width: 10),
          // 歌曲信息
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '暂无播放',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  '未知歌手',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          // 收藏按钮
          IconButton(
            icon: const Icon(Icons.favorite_border, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  /// 中间：播放控制
  Widget _buildPlaybackControls() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 播放控制按钮行
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(icon: const Icon(Icons.shuffle), onPressed: () {}),
            IconButton(icon: const Icon(Icons.skip_previous), onPressed: () {}),
            // 播放/暂停按钮（大号）
            IconButton(
              icon: Icon(
                _isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
              ),
              iconSize: 48,
              onPressed: () {
                setState(() => _isPlaying = !_isPlaying);
              },
            ),
            IconButton(icon: const Icon(Icons.skip_next), onPressed: () {}),
            IconButton(icon: const Icon(Icons.repeat), onPressed: () {}),
          ],
        ),
        // 进度条
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                _formatDuration(
                  Duration(seconds: (180 * _currentPosition).toInt()),
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Expanded(
                child: Slider(
                  value: _currentPosition,
                  onChanged: (value) {
                    setState(() => _currentPosition = value);
                  },
                ),
              ),
              Text(
                _formatDuration(const Duration(seconds: 180)),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 右侧:音量等控制
  Widget _buildRightControls() {
    return Container(
      width: 180,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 播放列表按钮
          IconButton(
            icon: const Icon(Icons.queue_music, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
          // 音量控制
          MouseRegion(
            onEnter: (_) => setState(() => _showVolumeSlider = true),
            onExit: (_) => setState(() => _showVolumeSlider = false),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_showVolumeSlider) ...[
                  SizedBox(
                    width: 70,
                    child: Slider(
                      value: _volume,
                      onChanged: (value) {
                        setState(() => _volume = value);
                      },
                    ),
                  ),
                ],
                IconButton(
                  icon: Icon(
                    _volume > 0.5
                        ? Icons.volume_up
                        : _volume > 0
                        ? Icons.volume_down
                        : Icons.volume_off,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  onPressed: () {
                    setState(() => _volume = _volume > 0 ? 0 : 0.7);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 格式化时长
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
