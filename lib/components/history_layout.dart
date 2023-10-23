import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:epic2023/shared_resources.dart' show HistoryRecord,
HistoryModel;

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class NoHistoryWidget extends StatelessWidget {
  const NoHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const AspectRatio(
      aspectRatio: 2 / 1,
      child: Center(
        child: Text('暂无历史记录'),
      ),
    );
  }
}

class HistoryRecordCard extends StatelessWidget {
  const HistoryRecordCard({
    super.key,
    required this.historyRecord,
    required this.index,
  });

  final HistoryRecord historyRecord;
  final int index;

  void showMetaData(BuildContext context) {
    final String _metadata = historyRecord.metadata;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("元数据"),
          content: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 32.0),
              child: Text(_metadata),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String _componentName = historyRecord.category;
    final Uint8List? _image = historyRecord.image;
    return AspectRatio(
      aspectRatio: 1 / 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          // elevation: 20,
          clipBehavior: Clip.hardEdge,
          child: Column(
            children:[
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _image == null
                      ? const Icon(
                        Icons.image_not_supported_outlined,
                        size: 100,
                      )
                      : Image.memory(
                        _image,
                        fit: BoxFit.fill,
                      ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        color: Colors.white.withOpacity(0.75),  // 半透明的灰色蒙版
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ListTile(
                            leading: Icon(
                              Icons.category_outlined,
                              color: Colors.blueGrey.shade800,
                            ),
                            title: Text(
                              // 首字母大写
                              _componentName[0].toUpperCase() + _componentName.substring(1),
                              style: const TextStyle(fontSize: 20),
                            ),
                            subtitle: Text(
                              '${historyRecord.time.year}.'
                                  '${historyRecord.time.month}.'
                                  '${historyRecord.time.day} '
                                  '${historyRecord.time.hour}:'
                                  '${historyRecord.time.minute}:'
                                  '${historyRecord.time.second}',
                              // 淡化颜色
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          showMetaData(context);
                        },
                        child: Container(
                          color: Colors.white38.withOpacity(0.1),  // 半透明的灰色蒙版
                        ),
                      ),
                    ),
                    // 左上角的数字
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0
                        ),
                        child: Text(
                          index.toString(),
                          style: TextStyle(
                            fontSize: 32,
                            color: Colors.blueGrey.shade800,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                    // 右上角的按钮
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: IconButton(
                          icon: Icon(
                            Icons.delete_forever_outlined,
                            color: Colors.blueGrey.shade800
                          ),
                          onPressed: () {
                            context.read<HistoryModel>().removeRecord(index - 1);
                          },
                          tooltip: '删除记录',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]
          )
        ),
      ),
    );
  }
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    List<HistoryRecord> _historyList = context.watch<HistoryModel>().historyList;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            snap: false,
            floating: false,
            expandedHeight: 120,
            actions: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 10),
                child: PopupMenuButton<int>(
                  icon: const Icon(Icons.clear_all_outlined),
                  tooltip: '清空历史记录',
                  onSelected: (int result) {
                    setState(() {
                      if (result == 0) {
                        context.read<HistoryModel>().clearRecords();
                      }
                    });
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                    const PopupMenuItem<int>(
                      value: 0,
                      child: Text('再次点击以确认'),
                    ),
                  ],
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1.7,
              title: Text(
                '历史记录',
                style: TextStyle(
                    color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black)
                ),
              titlePadding: const EdgeInsetsDirectional.only(start: 25, bottom: 15),
            ),
          ),
          const SliverToBoxAdapter(
            child: Divider(height: 1),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(8.0),
            sliver: _historyList.isEmpty
              ? const SliverToBoxAdapter(
                child: NoHistoryWidget(),
              )
              : SliverGrid.count(
              crossAxisCount: 4,
              children: List.generate(
                _historyList.length,
                    (index) => LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: HistoryRecordCard(
                        historyRecord: _historyList[index],
                        index: index + 1,
                      ),
                    );
                  },
                )
              ),
            )
          )
        ],
      ),
    );
  }
}
