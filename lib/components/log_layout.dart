import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:epic2023/shared_resources.dart' show
        LogLevel, LogManager, LogEntry, logLevelTextColorMap, logLevelNameMap, deviceReadableNameMap;

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  final ScrollController _scrollController = ScrollController();
  LogLevel _logLevel = LogLevel.info;
  bool _autoScroll = true;

  Widget? _buildLogList(BuildContext context, int index) {
    if (index == 0) {
      return const Text('\n===== Log Start =====', style: TextStyle(fontFamily: 'JetBrainsMono'));
    }
    index -= 1;

    final List<LogEntry> logList = context.read<LogManager>().logs;
    final LogEntry log = logList[index];
    if (log.level.index < _logLevel.index) return const SizedBox(height: 0);
    late Color? textColor;
    if (log.level.index > LogLevel.info.index) {
      textColor = logLevelTextColorMap[log.level];
    } else {
      textColor = Theme.of(context).textTheme.bodyLarge?.color;
    }

    final String timestamp = '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}:'
        '${log.timestamp.second.toString().padLeft(2, '0')}.${(log.timestamp.millisecond).round().toString().padLeft(3, '0')}';
    final String levelName = "[${logLevelNameMap[log.level] ?? 'Unknown'}]".padRight(10);
    final String componentName = "<${(deviceReadableNameMap[log.componentName] ?? log.componentName)}>".padRight(7);

    return Text(
        '> $levelName $timestamp $componentName :${log.message}',
        style: TextStyle(color: textColor, fontFamily: 'JetBrainsMono', fontFamilyFallback: const ['NotoSansSC']),
    );
  }

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        _autoScroll = true;
      });
    } else if (_scrollController.offset <= _scrollController.position.maxScrollExtent - 40 &&
        !_scrollController.position.outOfRange) {
      setState(() {
        _autoScroll = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    if (_autoScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            snap: false,
            floating: false,
            expandedHeight: 120,
            actions: <Widget>[
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 10),
                child: PopupMenuButton<LogLevel>(
                  icon: const Icon(Icons.sort),
                  tooltip: '显示级别',
                  onSelected: (LogLevel result) {
                    setState(() {
                      _logLevel = result;
                    });
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<LogLevel>>[
                      const PopupMenuItem<LogLevel>(
                      value: LogLevel.debug,
                      child: Text('Debug'),
                    ),
                    const PopupMenuItem<LogLevel>(
                      value: LogLevel.info,
                      child: Text('Info'),
                    ),
                    const PopupMenuItem<LogLevel>(
                      value: LogLevel.warning,
                      child: Text('Warning'),
                    ),
                    const PopupMenuItem<LogLevel>(
                      value: LogLevel.error,
                      child: Text('Error'),
                    ),
                  ],
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1.7,
              title: Text('日志', style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black)),
              titlePadding: const EdgeInsetsDirectional.only(start: 25, bottom: 15),
            ),
          ),
          const SliverToBoxAdapter(
            child: Divider(height: 1),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            sliver: SliverList.builder(
              itemBuilder: _buildLogList,
              itemCount: context.watch<LogManager>().logs.length + 1,
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<LogManager>().clearLogs();
          context.read<LogManager>().addLog(
            level: LogLevel.info,
            componentName: 'global',
            message: 'Log cleared.',
          );
        },
        tooltip: '清空日志',
        child: const Icon(Icons.clear_all_outlined),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
