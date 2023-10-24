import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:epic2023/shared_resources.dart' show trashNameList,
trashReadableNameMap, trashIconMap, TrashStatistics, GarbageLoadData;

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int pieChartTouchedIndex = -1;
  int barChartTouchedIndex = -1;

  Widget _buildVarietyOverviewInfo(BuildContext context, int index) {
    final variety = trashNameList[index];
    final varietyName = trashReadableNameMap[variety] ?? variety;
    final varietyIcon = trashIconMap[variety] ?? Icons.question_mark_outlined;
    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 16, 0, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(varietyIcon, size: 30),
            Expanded(
              child: ListTile(
                title: Text(
                  context.watch<TrashStatistics>().getTrashCount(variety).toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('$varietyName数量'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLine1(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 24, 16, 0),
              child: Text('已分拣垃圾${context.read<TrashStatistics>().getAmount()}件',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          IntrinsicHeight(
            child: Row(
              children: <Widget>[
                ...List.generate(4, (index) {
                  return [
                    _buildVarietyOverviewInfo(context, index),
                    if (index != 3) const VerticalDivider(indent: 24, endIndent: 8),
                  ];
                }).expand((item) => item).toList(),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 16, 32, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(Icons.scale_outlined, size: 30),
                        Expanded(
                          child: ListTile(
                            title: Text(
                              "${context.read<TrashStatistics>().getTotalMass().toStringAsFixed(2)}kg",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text('总质量'),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
        ]
      )
    );
  }

  final List<Color> colorList = [
    const Color(0xFFF5B7B1), // 有害垃圾
    const Color(0xFFAED6F1), // 可回收垃圾
    const Color(0xFFABEBC6), // 厨余垃圾
    const Color(0xFFABB2B9), // 其他垃圾
  ];

  /// 构建构建饼图依赖的数据列表
  List<PieChartSectionData> _buildPieChartDataList(BuildContext context){
    final List<PieChartSectionData> pieChartDataList = [];
    final amount = context.read<TrashStatistics>().getAmount();
    for (int i = 0; i < trashNameList.length; i++) {
      final trashName = trashNameList[i];
      final trashCount = amount == 0 ? 1 :
        context.read<TrashStatistics>().getTrashCount(trashName);
      final percentage = amount == 0 ? 0 : trashCount / amount;
      pieChartDataList.add(
          PieChartSectionData(
            color: colorList[i],
            value: trashCount.toDouble() + 1e-6,
            showTitle: trashCount != 0,
            titleStyle: Theme.of(context).textTheme.titleMedium,
            title: "${(percentage * 100).toInt()}%",
            radius: pieChartTouchedIndex == i ? 110 : 100,
            titlePositionPercentageOffset: 0.55,
          )
      );
    }
    return pieChartDataList;
  }

  /// 构建每类垃圾数量占比的饼图
  Widget _buildPercentageOfCategories(BuildContext context) {
    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                pieChartTouchedIndex = -1;
                return;
              }
              pieChartTouchedIndex = pieTouchResponse
                  .touchedSection!.touchedSectionIndex;
            });
          },
        ),
        borderData: FlBorderData(
          show: false,
        ),
        sections: _buildPieChartDataList(context),
      ),
    );
  }

  List<Widget> _buildPicChartLegendList(BuildContext context) {
    final List<Widget> legendList = [];
    final amount = context.read<TrashStatistics>().getAmount();
    for (int i = 0; i < trashNameList.length; i++) {
      final trashName = trashNameList[i];
      final trashCount = context.read<TrashStatistics>().getTrashCount(trashName);
      final trashIcon = trashIconMap[trashName] ?? Icons.question_mark_outlined;
      final trashNameReadable = trashReadableNameMap[trashName] ?? trashName;
      final percentage = amount == 0 ? 0 : trashCount / amount;
      legendList.add(
        ListTile(
          leading: Icon(
            trashIcon,
            color: colorList[i],
            size: pieChartTouchedIndex == i ? 30 : 24,
          ),
          title: Text(
            "${(percentage * 100).toInt()}%",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Text("$trashNameReadable占比"),
        )
      );
    }
    return legendList;
  }

  List<Widget> _buildBarChartLegendList(BuildContext context) {
    final List<Widget> legendList = [];
    final maxLoad = context.read<GarbageLoadData>().getLoad('max');
    for (int i = 0; i < trashNameList.length; i++) {
      final trashName = trashNameList[i];
      final trashLoad = context.read<GarbageLoadData>().getLoad(trashName);
      final trashIcon = trashIconMap[trashName] ?? Icons.question_mark_outlined;
      final trashNameReadable = trashReadableNameMap[trashName] ?? trashName;
      final loadPercentage = maxLoad == 0 ? 0 : trashLoad / maxLoad;
      legendList.add(
          ListTile(
            leading: Icon(
              trashIcon,
              size: barChartTouchedIndex == i ? 30 : 24,
            ),
            title: Text(
              "${(loadPercentage * 100).toInt()}%",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Text("$trashNameReadable负载"),
          )
      );
    }
    return legendList;
  }

  List<BarChartGroupData> _buildBarGroups(BuildContext context) {
    List<BarChartGroupData> barGroups = [];
    final maxLoad = context.read<GarbageLoadData>().getLoad('max');
    for (int i = 0; i < trashNameList.length; i++) {
      final trashName = trashNameList[i];
      final formLoad = context.read<GarbageLoadData>().getLoad(trashName);
      barGroups.add(
        BarChartGroupData(
          x: 2 * i + 1,
          barRods: [
            BarChartRodData(
              fromY: 0,
              toY: formLoad == 0 ? maxLoad/100 : formLoad,
              width: barChartTouchedIndex == i ? 20 : 16,
              borderRadius: barChartTouchedIndex == i
                ?const BorderRadius.vertical(top: Radius.circular(10))
                :const BorderRadius.vertical(top: Radius.circular(8)),
            ),
          ],
        ),
      );
    }
    return barGroups;
  }

  Widget _buildBarChart(BuildContext context) {
    BarTouchData barTouchData = BarTouchData(
      enabled: true,
      touchCallback: (FlTouchEvent event, barTouchResponse) {
        setState(() {
          if (!event.isInterestedForInteractions ||
              barTouchResponse == null ||
              barTouchResponse.spot == null) {
            barChartTouchedIndex = -1;
            return;
          }
          barChartTouchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
        });
      },
      touchTooltipData: BarTouchTooltipData(
        tooltipBgColor: Colors.blueGrey.shade700,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final trashName = trashNameList[group.x ~/ 2];
          final trashLoad = context.read<GarbageLoadData>().getLoad(trashName);
          return BarTooltipItem(
            trashLoad.toStringAsFixed(2),
            TextStyle(
              color: rod.gradient?.colors.first ?? rod.color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          );
        },
      ),
    );
    return BarChart(
      BarChartData(
        barGroups: _buildBarGroups(context),
        barTouchData: barTouchData,
        maxY: context.read<GarbageLoadData>().getLoad('max').toDouble(),
        minY: 0,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              getTitlesWidget: (double value, TitleMeta meta){
                final trashName = trashNameList[value ~/ 2];
                final trashNameReadable = trashReadableNameMap[trashName] ?? trashName;
                return Text(
                  trashNameReadable.substring(0, trashNameReadable.length - 2),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta){
                return Text(
                  value.toInt().toString(),
                );
              },
              reservedSize: 35,
            ),
          ),
          topTitles: AxisTitles(
            axisNameSize: 24,
            axisNameWidget: Text(
              '负载(mm)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
      ),
    );
  }

  Widget _buildLine2(BuildContext context) {
    return AspectRatio(
      aspectRatio: 17 / 6,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildPercentageOfCategories(context),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _buildPicChartLegendList(context),
                        ),
                      ),
                    )
                  ],
                )
              )
            )
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child:Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildBarChart(context),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _buildBarChartLegendList(context),
                        ),
                      ),
                    )
                  ],
                )
              )
            )
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget line1 = _buildLine1(context);
    Widget line2 = _buildLine2(context);
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
              title: Text('统计数据', style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black)),
              titlePadding: const EdgeInsetsDirectional.only(start: 25, bottom: 15),
            ),
          ),
          const SliverToBoxAdapter(
            child: Divider(height: 1),
          ),
          const SliverPadding(padding: EdgeInsets.symmetric(horizontal: 25, vertical: 8)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
            sliver: SliverList.list(
              children: [
                line1,
                const SizedBox(height: 16),
                line2,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
