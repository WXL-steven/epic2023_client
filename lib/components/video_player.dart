import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';

import 'package:epic2023/shared_resources.dart' show PlayerManager;

class MyScreen extends StatefulWidget {
  const MyScreen({Key? key}) : super(key: key);
  @override
  State<MyScreen> createState() => MyScreenState();
}

class MyScreenState extends State<MyScreen> {
  bool _unmute = false;

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
                  _unmute
                    ? context.read<PlayerManager>().mute()
                    : context.read<PlayerManager>().unmute();
                });
              },
            ),
            PopupMenuItem(
              child: const Text('关闭'),
              onTap: () {
                context.read<PlayerManager>().pause();
              },
            ),
          ],
        );
      },
      child: Center(
        child: SizedBox(
          child: Video(
            controller: context.watch<PlayerManager>().controller,
            controls: NoVideoControls,
          ),
        ),
      ),
    );
  }
}