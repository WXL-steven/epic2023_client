import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';

import 'package:epic2023/shared_resources.dart' show VideoPlayerSwitcher, LogManager, LogLevel, extractVideo;

class MyScreen extends StatefulWidget {
  const MyScreen({Key? key}) : super(key: key);
  @override
  State<MyScreen> createState() => MyScreenState();
}

class MyScreenState extends State<MyScreen> {
  late final player = Player();
  late final controller = VideoController(player);
  bool _unmute = false;

  @override
  void initState() {
    super.initState();
    final logManager = context.read<LogManager>();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final videoPath = await extractVideo();
      player.open(Media(videoPath));
      player.setPlaylistMode(PlaylistMode.single);
      logManager.addLog(level: LogLevel.info, componentName: "global", message: "Video player initialized.");
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (TapDownDetails details) {
        final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
        showMenu(
          context: context,
          position: RelativeRect.fromRect(
            Rect.fromPoints(
              details.globalPosition,
              details.globalPosition,
            ),
            Offset.zero & overlay.size,
          ),
          items: <PopupMenuEntry>[
            PopupMenuItem(
              child: Text('${_unmute ? '取消' : ''}静音'),
              onTap: () {
                setState(() {
                  _unmute = !_unmute;
                  player.setVolume(_unmute ? 0 : 100);
                });
              },
            ),
            PopupMenuItem(
              child: const Text('关闭'),
              onTap: () {
                context.read<LogManager>().addLog(level: LogLevel.info, componentName: "global", message: "Video player closed.");
                context.read<VideoPlayerSwitcher>().setPlaying(false);
              },
            ),
          ],
        );
      },
      child: Center(
        child: SizedBox(
          child: Video(
            controller: controller,
            controls: NoVideoControls,
          ),
        ),
      ),
    );
  }
}