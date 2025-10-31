import 'package:flutter/material.dart';
import 'services/media_map_service.dart';
import 'models/media_resource.dart';
import 'utils/logger.dart';
import 'config/api_config.dart';

/// 文件映射模块测试示例
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 设置日志级别为开发模式
  ApiConfig.setLogLevel(LogLevel.dev);

  runApp(const MediaMapTestApp());
}

class MediaMapTestApp extends StatelessWidget {
  const MediaMapTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Media Map Service Test',
      theme: ThemeData.dark(useMaterial3: true),
      home: const MediaMapTestPage(),
    );
  }
}

class MediaMapTestPage extends StatefulWidget {
  const MediaMapTestPage({super.key});

  @override
  State<MediaMapTestPage> createState() => _MediaMapTestPageState();
}

class _MediaMapTestPageState extends State<MediaMapTestPage> {
  final MediaMapService _mapService = MediaMapService();
  final List<String> _logs = [];
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  /// 初始化服务
  Future<void> _initializeService() async {
    _addLog('Initializing MediaMapService...');
    try {
      await _mapService.initialize();
      setState(() {
        _initialized = true;
      });
      _addLog('✅ Initialization successful');
      _addLog('Cache root: ${_mapService.cacheRootPath}');
    } catch (e) {
      _addLog('❌ Initialization failed: $e');
    }
  }

  /// 测试添加音频映射
  Future<void> _testAddAudioMapping() async {
    _addLog('\n--- Test: Add Audio Mapping ---');

    final resource = MediaResource(
      uuid: 'audio-uuid-001',
      remoteUrl: 'http://127.0.0.1:8000/music/play/1',
      type: MediaType.audio,
      localPath: '${_mapService.cacheRootPath}/audio/audio-uuid-001.mp3',
      fileSize: 5242880, // 5MB
      cachedAt: DateTime.now(),
      lastAccessedAt: DateTime.now(),
    );

    await _mapService.mapResource(resource);
    _addLog('✅ Added audio mapping: ${resource.uuid}');

    // 验证映射
    final isMapped = _mapService.isMapped(resource.uuid, type: MediaType.audio);
    _addLog('Is mapped: $isMapped');

    final localPath = _mapService.getLocalPath(
      resource.uuid,
      type: MediaType.audio,
    );
    _addLog('Local path: $localPath');
  }

  /// 测试添加封面映射
  Future<void> _testAddCoverMapping() async {
    _addLog('\n--- Test: Add Cover Mapping ---');

    final resource = MediaResource(
      uuid: 'cover-uuid-001',
      remoteUrl: 'http://127.0.0.1:8000/music/cover/1',
      type: MediaType.cover,
      localPath: '${_mapService.cacheRootPath}/cover/cover-uuid-001.jpg',
      fileSize: 102400, // 100KB
      cachedAt: DateTime.now(),
    );

    await _mapService.mapResource(resource);
    _addLog('✅ Added cover mapping: ${resource.uuid}');
  }

  /// 测试批量添加映射
  Future<void> _testBatchMapping() async {
    _addLog('\n--- Test: Batch Mapping ---');

    final resources = [
      MediaResource(
        uuid: 'audio-uuid-002',
        remoteUrl: 'http://127.0.0.1:8000/music/play/2',
        type: MediaType.audio,
      ),
      MediaResource(
        uuid: 'cover-uuid-002',
        remoteUrl: 'http://127.0.0.1:8000/music/cover/2',
        type: MediaType.cover,
      ),
      MediaResource(
        uuid: 'lyric-uuid-001',
        remoteUrl: 'http://127.0.0.1:8000/music/lyric/1',
        type: MediaType.lyric,
      ),
    ];

    await _mapService.mapResources(resources);
    _addLog('✅ Batch mapped ${resources.length} resources');
  }

  /// 测试更新访问信息
  Future<void> _testUpdateAccessInfo() async {
    _addLog('\n--- Test: Update Access Info ---');

    // 获取资源
    final resource = _mapService.getResource(
      'audio-uuid-001',
      type: MediaType.audio,
    );
    if (resource != null) {
      _addLog('Before: accessCount = ${resource.accessCount}');

      // 更新访问信息
      await _mapService.updateAccessInfo(
        'audio-uuid-001',
        type: MediaType.audio,
      );

      // 再次获取查看更新
      final updated = _mapService.getResource(
        'audio-uuid-001',
        type: MediaType.audio,
      );
      _addLog('After: accessCount = ${updated?.accessCount}');
      _addLog('Last accessed: ${updated?.lastAccessedAt}');
    } else {
      _addLog('❌ Resource not found');
    }
  }

  /// 测试获取统计信息
  Future<void> _testGetStatistics() async {
    _addLog('\n--- Test: Get Statistics ---');

    final stats = await _mapService.getStatistics();
    _addLog('Total files: ${stats.totalFiles}');
    _addLog('Total size: ${stats.formattedTotalSize}');
    _addLog('Audio files: ${stats.typeCounts[MediaType.audio] ?? 0}');
    _addLog('Cover files: ${stats.typeCounts[MediaType.cover] ?? 0}');
    _addLog('Lyric files: ${stats.typeCounts[MediaType.lyric] ?? 0}');

    _addLog('\n$stats');
  }

  /// 测试移除映射
  Future<void> _testRemoveMapping() async {
    _addLog('\n--- Test: Remove Mapping ---');

    await _mapService.removeMapping('audio-uuid-002', type: MediaType.audio);
    _addLog('✅ Removed audio-uuid-002');

    final isMapped = _mapService.isMapped(
      'audio-uuid-002',
      type: MediaType.audio,
    );
    _addLog('Is still mapped: $isMapped');
  }

  /// 测试获取所有资源
  Future<void> _testGetAllResources() async {
    _addLog('\n--- Test: Get All Resources ---');

    final allResources = _mapService.getAllResources();
    _addLog('Total resources: ${allResources.length}');

    for (final resource in allResources) {
      _addLog('  - ${resource.uuid} (${resource.type.name})');
    }

    _addLog('\nAudio resources only:');
    final audioResources = _mapService.getAllResources(type: MediaType.audio);
    _addLog('Count: ${audioResources.length}');
  }

  /// 运行所有测试
  Future<void> _runAllTests() async {
    if (!_initialized) {
      _addLog('❌ Service not initialized');
      return;
    }

    _logs.clear();
    setState(() {});

    await _testAddAudioMapping();
    await _testAddCoverMapping();
    await _testBatchMapping();
    await _testUpdateAccessInfo();
    await _testGetStatistics();
    await _testRemoveMapping();
    await _testGetAllResources();

    _addLog('\n🎉 All tests completed!');
  }

  void _addLog(String message) {
    setState(() {
      _logs.add(message);
    });
    Logger.dev(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Media Map Service Test')),
      body: Column(
        children: [
          // 状态栏
          Container(
            padding: const EdgeInsets.all(16),
            color: _initialized
                ? Colors.green.shade900
                : Colors.orange.shade900,
            child: Row(
              children: [
                Icon(
                  _initialized ? Icons.check_circle : Icons.hourglass_empty,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  _initialized ? 'Service Initialized' : 'Initializing...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_initialized)
                  Text(
                    'Mappings: ${_mapService.getMappingCount()}',
                    style: const TextStyle(color: Colors.white),
                  ),
              ],
            ),
          ),

          // 测试按钮
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _initialized ? _runAllTests : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Run All Tests'),
                ),
                ElevatedButton.icon(
                  onPressed: _initialized ? _testAddAudioMapping : null,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Audio'),
                ),
                ElevatedButton.icon(
                  onPressed: _initialized ? _testGetStatistics : null,
                  icon: const Icon(Icons.analytics),
                  label: const Text('Statistics'),
                ),
                ElevatedButton.icon(
                  onPressed: _initialized
                      ? () {
                          setState(() {
                            _logs.clear();
                          });
                        }
                      : null,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Logs'),
                ),
              ],
            ),
          ),

          const Divider(),

          // 日志区域
          Expanded(
            child: _logs.isEmpty
                ? const Center(
                    child: Text('No logs yet. Click "Run All Tests" to start.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          log,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: log.startsWith('✅')
                                ? Colors.green
                                : log.startsWith('❌')
                                ? Colors.red
                                : log.startsWith('---')
                                ? Colors.blue
                                : Colors.white70,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
