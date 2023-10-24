import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:epic2023/shared_resources.dart' show DashboardManager,
DashboardStatus;
import 'package:epic2023/websocket_manager.dart' show WebSocketManager;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DashboardStatus _neuralNetworkStatus = DashboardStatus.unknown;
  DashboardStatus _conveyorBeltsStatus = DashboardStatus.unknown;
  DashboardStatus _compactorStatus = DashboardStatus.unknown;
  Uint8List? _lastIdentificationImage;
  String? _lastIdentificationResult;
  Uint8List? _realTimeIdentificationResult;

  @override
  Widget build(BuildContext context) {
    _neuralNetworkStatus = context.watch<DashboardManager>().nnStatus;
    _conveyorBeltsStatus = context.watch<DashboardManager>().cbStatus;
    _compactorStatus = context.watch<DashboardManager>().cpStatus;
    _lastIdentificationImage = context.watch<DashboardManager>().lastObject;
    _lastIdentificationResult = context.watch<DashboardManager>().lastResult;
    _realTimeIdentificationResult = context.watch<DashboardManager>().realtime;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            snap: false,
            floating: false,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1.7,
              title: Text('控制台', style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black)),
              titlePadding: const EdgeInsetsDirectional.only(start: 25, bottom: 15),
            ),
          ),
          const SliverToBoxAdapter(
            child: Divider(height: 1),
          ),
          const SliverPadding(padding: EdgeInsets.symmetric(vertical: 8)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            sliver: SliverList.list(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child:Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text("分类网络状态", style: Theme.of(context).textTheme.titleLarge),
                              ),
                              const SizedBox(height: 10),
                              ListTile(
                                leading: const Icon(Icons.polyline_outlined),
                                title: _neuralNetworkStatus == DashboardStatus.idle
                                  ? const Text('后端空闲')
                                  : _neuralNetworkStatus == DashboardStatus.busy
                                    ? const Text('识别中')
                                    : const Text('后端错误'),
                                trailing: _neuralNetworkStatus == DashboardStatus.idle
                                  ? const Icon(Icons.done_all_outlined)
                                  : _neuralNetworkStatus == DashboardStatus.busy
                                    ? const CircularProgressIndicator()
                                    : Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                              ),
                            ],
                          ),
                        )
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child:Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text("传送带状态", style: Theme.of(context).textTheme.titleLarge),
                              ),
                              const SizedBox(height: 10),
                              ListTile(
                                leading: const Icon(Icons.conveyor_belt),
                                title: _conveyorBeltsStatus == DashboardStatus.idle
                                  ? const Text('队列空闲')
                                  : _conveyorBeltsStatus == DashboardStatus.busy
                                    ? const Text('输送中')
                                    : const Text('无法读取'),
                                trailing: _conveyorBeltsStatus == DashboardStatus.idle
                                  ? const Icon(Icons.done_all_outlined)
                                  : _conveyorBeltsStatus == DashboardStatus.busy
                                    ? const CircularProgressIndicator()
                                    : Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                              ),
                            ],
                          ),
                        )
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AspectRatio(
                  aspectRatio: 16 / 6,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Card(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child:
                                        Text("上一有效结果", style: Theme.of(context).textTheme.titleLarge),
                                      ),
                                      const SizedBox(height: 16),
                                      Flexible(
                                        child: Row(
                                          children: [
                                            const SizedBox(width: 8),
                                            AspectRatio(
                                              aspectRatio: 1,
                                              child: Center(
                                                child: _lastIdentificationImage != null
                                                    ? Image.memory(
                                                      _lastIdentificationImage!,
                                                      gaplessPlayback: true,  // 设置为true以避免闪烁
                                                    )
                                                    : const Icon(Icons.image_not_supported_outlined, size: 64),
                                              ),
                                            ),
                                            const SizedBox(width: 32),
                                            const VerticalDivider(
                                                thickness: 1,
                                                width: 1,
                                                indent: 8,
                                                endIndent: 8,
                                            ),
                                            const SizedBox(width: 32),
                                            Expanded(
                                              child: ListView(
                                                children: [
                                                  Text("识别结果", style: Theme.of(context).textTheme.titleMedium),
                                                  const SizedBox(height: 16),
                                                  _lastIdentificationResult == null
                                                      ? const Center(child: Text("无"))
                                                      : SelectableText(
                                                        _lastIdentificationResult!,
                                                        style: const TextStyle(fontFamily: 'JetBrainsMono', fontFamilyFallback: ['NotoSansSC']),
                                                      ),
                                                ],
                                              ),
                                            )
                                          ],
                                        )
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              ),
                              const VerticalDivider(
                                thickness: 2,
                                width: 2,
                                indent: 24,
                                endIndent: 24
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: Text("实时视野", style: Theme.of(context).textTheme.titleLarge),
                                      ),
                                      const SizedBox(height: 16),
                                      Flexible(
                                        child: AspectRatio(
                                          aspectRatio: 1,
                                          child: Center(
                                            child:
                                              _realTimeIdentificationResult != null
                                                ? Image.memory(
                                                  _realTimeIdentificationResult!,
                                                  gaplessPlayback: true,
                                                )
                                                : const Icon(Icons.image_not_supported_outlined, size: 64)
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: Card(
                          color: _compactorStatus == DashboardStatus.idle
                            ? Theme.of(context).colorScheme.surface
                            : _compactorStatus == DashboardStatus.busy
                              ? Theme.of(context).colorScheme.surfaceVariant
                              : Theme.of(context).colorScheme.errorContainer,
                          clipBehavior: Clip.hardEdge,
                          child: InkWell(
                            onTap: _compactorStatus == DashboardStatus.idle
                              ? () {
                                WebSocketManager().packAndSend('C', {});
                              }
                              : null,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _compactorStatus == DashboardStatus.idle
                                    ? const Icon(Icons.compress_outlined, size: 64)
                                    : _compactorStatus == DashboardStatus.busy
                                      ? const CircularProgressIndicator()
                                      : Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 64),
                                  const SizedBox(height: 16),
                                  _compactorStatus == DashboardStatus.idle
                                    ? Text('手动压缩', style: Theme.of(context).textTheme.titleMedium)
                                    : _compactorStatus == DashboardStatus.busy
                                      ? Text('压缩中', style: Theme.of(context).textTheme.titleMedium)
                                      : Text('压缩机离线', style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
