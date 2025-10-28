import 'package:flutter/material.dart';
import 'music_player_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MusicPlayerService.ensureInitialized(
    prefetchPlaylist: true,
    protocolWhitelist: ["http", "https", "file"],
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Music Player',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: '音乐播放器'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  final MusicPlayerService _musicPlayerService = MusicPlayerService();
  bool _isPlaying = false;
  String? _lastInput;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: '输入本地或网络音乐地址',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final input = _controller.text.trim();
                      if (input.isEmpty) return;
                      setState(() {
                        _isPlaying = true;
                        _lastInput = input;
                      });
                      if (input.startsWith('http')) {
                        await _musicPlayerService.playNetwork(input);
                      } else {
                        await _musicPlayerService.playLocal(input);
                      }
                    },
                    child: const Text('播放'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      await _musicPlayerService.pause();
                      setState(() {
                        _isPlaying = false;
                      });
                    },
                    child: const Text('暂停'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      await _musicPlayerService.resume();
                      setState(() {
                        _isPlaying = true;
                      });
                    },
                    child: const Text('恢复'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      await _musicPlayerService.stop();
                      setState(() {
                        _isPlaying = false;
                      });
                    },
                    child: const Text('停止'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(_isPlaying ? '正在播放: ${_lastInput ?? ''}' : '未播放'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _musicPlayerService.dispose();
    super.dispose();
  }
}
