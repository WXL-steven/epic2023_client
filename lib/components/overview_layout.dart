import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:epic2023/shared_resources.dart' show DeviceInfo, DeviceStatus,
DeviceStatusEnum, DevicesInfoManager, VideoPlayerSwitcher, deviceIconMap,
deviceList, deviceReadableNameMap, deviceStatusReadableNameMap,
showAboutDialogWithContent;
import 'package:epic2023/websocket_manager.dart' show WebSocketManager;
import 'package:window_manager/window_manager.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() =>
      _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  final double _scrollViewExpandedHeight = 150.0;
  final double _titleStartExpanded = 70.0;
  final double _titleStartCollapsed  = 25.0;
  final double _titleBottomExpanded = 15.0;
  final double _titleBottomCollapsed  = 25.0;

  bool _isFullScreen = false;

  List<Widget> _overviewCardList(BuildContext context) {
    List<Widget> cardList = [];
    cardList.add(
      Card(
        color: Theme.of(context).colorScheme.secondaryContainer,
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () {
            context.read<VideoPlayerSwitcher>().setPlaying(true);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: ListTile(
                title: const Text('继续播放'),
                subtitle: const Text('宣传视频'),
                leading: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8.0),
                  child: Icon(Icons.smart_display_outlined, size: 30, color: Theme.of(context).colorScheme.onSurfaceVariant),
                )
              ),
            ),
          ),
        ),
      )
    );
    for (String device in deviceList) {
      DeviceStatusEnum deviceStatus = context.watch<DeviceStatus>().getDeviceStatus(device);
      bool isDeviceReady = deviceStatus == DeviceStatusEnum.ready;
      String deviceReadableName = deviceReadableNameMap[device]??device;
      cardList.add(
        Card(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Center(
              child: ListTile(
                title: Text(deviceReadableName),
                subtitle: Text("设备${deviceStatusReadableNameMap[deviceStatus]??deviceStatus}"),
                leading: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8.0),
                  child: Icon(
                    deviceIconMap[device]??Icons.device_unknown_outlined,
                    size: 30.0, color: isDeviceReady
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : Theme.of(context).colorScheme.error),
                ),
              ),
            )
          ),
        )
      );
    }
    return cardList;
  }

  List<Widget> _detailList(BuildContext context) {
    List<Widget> devicesList = [
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 4.0)
      ),
      // HeadLine
    ];
    for (String device in deviceList){
      DeviceInfo deviceInfo = context.watch<DevicesInfoManager>().getDeviceInfo(device);
      if (device != deviceList[0]) {
        devicesList.add(
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(
              height: 1,
              thickness: 1,
              indent: 32,
              endIndent: 32,
            )
          )
        );
      }
      devicesList.addAll(
          [
            ListTile(
              leading: Icon(deviceIconMap[device]??Icons.device_unknown_outlined),
              title: Text(deviceReadableNameMap[device]??"未知设备",
                  style: Theme.of(context).textTheme.headlineSmall),
              contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 24.0),
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: ListTile(
                    title: Text("${deviceReadableNameMap[device]}型号"),
                    subtitle: Text(context.watch<DeviceStatus>().isDeviceReady(device) ?
                    deviceInfo.model : "${deviceReadableNameMap[device]}未就绪"),
                    contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 48.0),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: ListTile(
                    title: const Text("设备名称"),
                    subtitle: Text(context.watch<DeviceStatus>().isDeviceReady(device) ?
                    deviceInfo.name : "不可用"),
                    contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 48.0),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: ListTile(
                    title: const Text("软件版本"),
                    subtitle: Text(context.watch<DeviceStatus>().isDeviceReady(device) ?
                    deviceInfo.softwareVersion
                        : "不可用"),
                    contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 48.0),
                  ),
                ),
              ],
            ),
            ListTile(
              title: const Text("备注信息"),
              subtitle: Text(context.watch<DeviceStatus>().isDeviceReady(device) ?
              deviceInfo.softwareVersion : "不可用"),
              contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 48.0),
            ),
          ]
      );
    }
    return devicesList;
  }

  @override
  Widget build(BuildContext context) {
    bool systemIsReady = context.watch<DeviceStatus>().isDeviceReady("global");
    final statusStrBuilder = StringBuffer('设备${systemIsReady ? '已' : '未'}就绪');

    if (!systemIsReady) {
      statusStrBuilder.write(':');

      final deviceStatus = context.watch<DeviceStatus>();
      if (!deviceStatus.isDeviceReady("backend")) statusStrBuilder.write(' 后端异常');
      if (!deviceStatus.isDeviceReady("camera")) statusStrBuilder.write(' 摄像头异常');
      if (!deviceStatus.isDeviceReady("mcu")) statusStrBuilder.write(' 单片机异常');
      if (!deviceStatus.isDeviceReady("conveyorBelt")) statusStrBuilder.write(' 传送带异常');
      if (!deviceStatus.isDeviceReady("turntable")) statusStrBuilder.write(' 转盘异常');
      if (!deviceStatus.isDeviceReady("compressor")) statusStrBuilder.write(' 压缩机异常');
      if (!deviceStatus.isDeviceReady("tiltingPlate")) statusStrBuilder.write(' 倾倒盘异常');
      if (!deviceStatus.isDeviceReady("weighing")) statusStrBuilder.write(' 计重异常');
      if (!deviceStatus.isDeviceReady("metering")) statusStrBuilder.write(' 计量异常');
    } else {
      statusStrBuilder.write(',所有组件在线');
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            snap: false,
            floating: false,
            expandedHeight: _scrollViewExpandedHeight,
            leading: IconButton.filledTonal(
              icon: const Icon(Icons.recycling),
              onPressed: () {
                showAboutDialogWithContent(context);
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                tooltip: '关于',
                onPressed: () {
                  showAboutDialogWithContent(context);
                },
              ),
              const SizedBox(width: 8.0),
              IconButton(
                icon: _isFullScreen ? const Icon(Icons.fullscreen_exit_outlined) : const Icon(Icons.fullscreen_outlined),
                tooltip: _isFullScreen ? '还原' : '最大化',
                onPressed: () {
                  setState(() {
                    _isFullScreen = !_isFullScreen;
                    if (_isFullScreen) {
                      windowManager.setFullScreen(true);
                    } else {
                      windowManager.setFullScreen(false);
                    }
                  });
                },
              ),
              const SizedBox(width: 8.0),
            ],
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                double minExtent = MediaQuery.of(context).padding.top + kToolbarHeight;
                double currentExtent = constraints.biggest.height;
                double fraction = (currentExtent - minExtent) / (_scrollViewExpandedHeight - minExtent);
                double start = _titleStartExpanded - (_titleStartExpanded - _titleStartCollapsed) * fraction;
                double bottom = _titleBottomExpanded - (_titleBottomExpanded - _titleBottomCollapsed) * fraction;

                return FlexibleSpaceBar(
                  expandedTitleScale: 1.7,
                  title: Text('智能垃圾桶', style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black)),
                  titlePadding: EdgeInsetsDirectional.only(start: start, bottom: bottom),
                );
              }
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            sliver: SliverList.list(
              children: [
                Card(
                  color: systemIsReady ? CardTheme.of(context).color : Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                    child: ListTile(
                      title: const Text('设备状态', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle:
                      Text(statusStrBuilder.toString()),
                      leading: Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8.0),
                        child: systemIsReady
                          ? const Icon(Icons.check_circle_outline, size: 40.0, color: Colors.green)
                          : const Icon(Icons.error_outline, size: 40.0),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.restart_alt_outlined),
                        tooltip: '重新连接',
                        onPressed: () {
                          WebSocketManager().disconnect();
                          WebSocketManager().connect();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            sliver: SliverGrid.count(
              crossAxisCount: 5,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 16 / 9,
              children: _overviewCardList(context),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            sliver: SliverList.list(
              children: [
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
                  child: ListBody(
                    children: _detailList(context),
                  ),
                ),
              ],
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 16.0)),
        ],
      ),
    );
  }
}
