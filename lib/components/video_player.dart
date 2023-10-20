import 'package:flutter/material.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final logManager = context.read<LogManager>();
      final videoPath = await extractVideo();
      await player.open(Media(videoPath));
      await player.setPlaylistMode(PlaylistMode.single);
      logManager.addLog(level: LogLevel.info, componentName: "global", message: "Video loaded from $videoPath.");
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
                player.dispose();
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