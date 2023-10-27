import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

import 'package:epic2023/components/overview_layout.dart' show OverviewPage;
import 'package:epic2023/components/dashboard_layout.dart' show DashboardPage;
import 'package:epic2023/components/statistics_layout.dart' show StatisticsPage;
import 'package:epic2023/components/history_layout.dart' show HistoryPage;
import 'package:epic2023/components/log_layout.dart' show LogPage;
import 'package:epic2023/components/video_player.dart' show MyScreen;
import 'package:epic2023/shared_resources.dart' show GarbageLoadData, PlayerManager, extractVideo, showOverLoadDialog, trashNameList, waringIgnoreState;
import 'package:provider/provider.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPage();
}

class _NavigationPage extends State<NavigationPage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    PlayerManager().dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final playerManager = context.read<PlayerManager>();
      final videoPath = await extractVideo();
      await playerManager.init(videoPath);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 满载检测
    for (String typeName in trashNameList) {
      if (context.watch<GarbageLoadData>().getLoad(typeName) >
          context.read<GarbageLoadData>().getLoad("max") * 50 / 100
          && waringIgnoreState[typeName] == false) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showOverLoadDialog(context, typeName);
          waringIgnoreState[typeName] == true;
        });
      }else if (context.watch<GarbageLoadData>().getLoad(typeName) <
          context.watch<GarbageLoadData>().getLoad("max") * 50 / 100
          && waringIgnoreState[typeName] == true) {
        waringIgnoreState[typeName] = false;
      }
    }

    return PageTransitionSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation, Animation<double> secondaryAnimation) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.scaled,
          child: child,
        );
      },
      child: context.watch<PlayerManager>().isPlaying
          ? const MyScreen()
      : Scaffold(
        body: SafeArea(
          child: Row(
            children: <Widget>[
              NavigationRail(
                selectedIndex: _selectedIndex,
                groupAlignment: 0,
                onDestinationSelected: (int index) {
                  _pageController.animateToPage(index, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                },
                labelType: NavigationRailLabelType.all,
                destinations: const <NavigationRailDestination>[
                  NavigationRailDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: Text('概览'),
                    padding: EdgeInsets.symmetric(vertical: 4),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard),
                    label: Text('仪表盘'),
                    padding: EdgeInsets.symmetric(vertical: 4),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.analytics_outlined),
                    selectedIcon: Icon(Icons.analytics),
                    label: Text('统计'),
                    padding: EdgeInsets.symmetric(vertical: 4),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.watch_later_outlined),
                    selectedIcon: Icon(Icons.watch_later),
                    label: Text('记录'),
                    padding: EdgeInsets.symmetric(vertical: 4),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.bug_report_outlined),
                    selectedIcon: Icon(Icons.bug_report),
                    label: Text('日志'),
                    padding: EdgeInsets.symmetric(vertical: 4),
                  ),
                ],
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: PageView(
                  allowImplicitScrolling: false,
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  children: const <Widget>[
                    Center(
                      child: OverviewPage(),
                    ),
                    Center(
                      child: DashboardPage(),
                    ),
                    Center(
                      child: StatisticsPage(),
                    ),
                    Center(
                      child: HistoryPage(),
                    ),
                    Center(
                      child: LogPage(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
