import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'package:epic2023/websocket_manager.dart' show WebSocketManager;
import 'package:epic2023/shared_resources.dart' show TrashStatistics,
DeviceStatus, DevicesInfoManager, LogManager, GarbageLoadData, DashboardManager,
PlayerManager, HistoryModel;
import 'package:epic2023/components/navigation_layout.dart' show NavigationPage;

void main() async {
  final WebSocketManager webSocketManager = WebSocketManager();
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await windowManager.ensureInitialized();
  await webSocketManager.connect();

  runApp(const MyApp());
}

class LinuxTouchScrollBehavior extends MaterialScrollBehavior {
// Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.unknown,
  };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2023工训',
      scrollBehavior: LinuxTouchScrollBehavior(),
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'NotoSansSC',
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => TrashStatistics()),
          ChangeNotifierProvider(create: (context) => DeviceStatus()),
          ChangeNotifierProvider(create: (context) => DevicesInfoManager()),
          ChangeNotifierProvider(create: (context) => LogManager()),
          ChangeNotifierProvider(create: (context) => GarbageLoadData()),
          ChangeNotifierProvider(create: (context) => DashboardManager()),
          ChangeNotifierProvider(create: (context) => PlayerManager()),
          ChangeNotifierProvider(create: (context) => HistoryModel()),
        ],
        child: const NavigationPage(),
      ),
    );
  }
}
