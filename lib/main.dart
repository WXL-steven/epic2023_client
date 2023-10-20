import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'package:epic2023/websocket_manager.dart' show WebSocketManager;
import 'package:epic2023/shared_resources.dart' show TrashStatistics,
DeviceStatus, DevicesInfoManager, LogManager, GarbageLoadData, DashboardManager,
PlayerManager;
import 'package:epic2023/components/navigation_layout.dart' show NavigationPage;

void main() async {
  final WebSocketManager webSocketManager = WebSocketManager();
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await windowManager.ensureInitialized();
  await webSocketManager.connect();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
        ],
        child: const NavigationPage(),
      ),
    );
  }
}
