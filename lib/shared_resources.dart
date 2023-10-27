import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// 垃圾分类统计类，使用单例模式和ChangeNotifier进行状态管理
class TrashStatistics with ChangeNotifier {
  /// 垃圾分类统计映射
  Map<String, int> _trashMap = {
    'hazardous': 0,  // 有害垃圾
    'recyclable': 0,  // 可回收垃圾
    'kitchen': 0,  // 厨余垃圾
    'other': 0,  // 其他垃圾
  };

  /// 总质量统计
  double _totalMass = 0.0;

  /// 单例对象
  static final TrashStatistics _singleton = TrashStatistics._internal();

  /// 工厂构造函数返回单例对象
  factory TrashStatistics() {
    return _singleton;
  }

  /// 私有构造函数
  TrashStatistics._internal();

  /// 获取指定类型垃圾的数量
  /// [type] 垃圾类型
  /// 返回对应类型垃圾的数量，如果类型不存在则返回0
  int getTrashCount(String type) {
    return _trashMap[type] ?? 0;
  }

  /// 获取总质量
  /// 返回总质量
  double getTotalMass() {
    return _totalMass;
  }

  /// 获取所有垃圾的数量
  /// 返回所有垃圾的数量
  int getAmount() {
    int amount = 0;
    _trashMap.forEach((key, value) {
      amount += value;
    });
    return amount;
  }

  /// 添加指定类型和数量的垃圾
  /// [type] 垃圾类型
  /// [count] 垃圾数量，默认为1
  /// 如果类型不存在，抛出异常
  void addTrash(String type, [int count = 1]) {
    if (_trashMap.containsKey(type)) {
      _trashMap[type] = count + (_trashMap[type]??0);
      notifyListeners();
    } else {
      throw Exception('Invalid trash type: $type');
    }
  }

  /// 设置总质量
  /// [mass] 总质量
  void setTotalMass(double mass) {
    _totalMass = mass;
    notifyListeners();
  }
}

/// 垃圾种类与负载数据类，使用单例模式和ChangeNotifier进行状态管理
class GarbageLoadData extends ChangeNotifier {
  /// 单例对象
  static final GarbageLoadData _singleton = GarbageLoadData._internal();

  /// 工厂构造函数返回单例对象
  factory GarbageLoadData() {
    return _singleton;
  }

  /// 私有构造函数
  GarbageLoadData._internal();

  /// 垃圾种类与其对应的负载数据
  Map<String, double> _garbageLoad = {
    'max': 80.0, // 最大负载
    'hazardous': 0.0, // 有害垃圾
    'recyclable': 0.0, // 可回收垃圾
    'kitchen': 0.0, // 厨余垃圾
    'other': 0.0, // 其他垃圾
  };

  /// 获取特定垃圾种类的负载数据
  double getLoad(String type) {
    return _garbageLoad[type] ?? 0.0; // 如果请求的类型不存在，则返回 0.0
  }

  // /// 获取全部垃圾负载，以List<double>形式返回(不包含最大负载)
  // List<double> getLoadList() {
  //   List<double> loadList = [];
  //   _garbageLoad.forEach((key, value) {
  //     if (key != 'max') {
  //       loadList.add(value);
  //     }
  //   });
  //   return loadList;
  // }

  /// 设置特定垃圾种类的负载数据
  void setLoad(String type, double load) {
    _garbageLoad[type] = load;
    notifyListeners(); // 在负载数据改变时通知听众
  }
}

final trashNameList = ['hazardous', 'recyclable', 'kitchen', 'other'];

Map<String, bool> waringIgnoreState = {
  'hazardous': false,
  'recyclable': false,
  'kitchen': false,
  'other': false,
};

final trashReadableNameMap = {
  'hazardous': '有害垃圾',
  'recyclable': '可回收垃圾',
  'kitchen': '厨余垃圾',
  'other': '其他垃圾',
};

final trashIconMap = {
  'hazardous': Icons.dangerous_outlined,
  'recyclable': Icons.recycling_outlined,
  'kitchen': Icons.food_bank_outlined,
  'other': Icons.delete_outline,
};

/// 设备状态枚举类
enum DeviceStatusEnum {
  ready,  // 设备就绪
  offline,  // 设备离线
  error,  // 设备故障
  unknown,  // 设备状态未知
}

/// 设备状态单例类
class DeviceStatus with ChangeNotifier {
  /// 设备状态映射
  Map<String, DeviceStatusEnum> _deviceStatusMap = {
    'global': DeviceStatusEnum.offline,  // 全局
    'backend': DeviceStatusEnum.offline,  // 后端
    'camera': DeviceStatusEnum.offline,  // 摄像头
    'mcu': DeviceStatusEnum.offline,  // 单片机
    'conveyorBelt': DeviceStatusEnum.offline,  // 传送带
    'turntable': DeviceStatusEnum.offline,  // 转盘
    'compressor': DeviceStatusEnum.offline,  // 压缩机
    'tiltingPlate': DeviceStatusEnum.offline,  // 倾倒盘
    'weighing': DeviceStatusEnum.offline,  // 计重
    'metering': DeviceStatusEnum.offline,  // 计量
  };

  /// 单例对象
  static final DeviceStatus _singleton = DeviceStatus._internal();

  /// 工厂构造函数返回单例对象
  factory DeviceStatus() {
    return _singleton;
  }

  /// 私有构造函数
  DeviceStatus._internal();

  /// 获取指定设备是否就绪
  /// [device] 设备名称
  /// 返回设备的是否就绪，如果设备不存在则返回false
  bool isDeviceReady(String device) {
    return _deviceStatusMap[device] == DeviceStatusEnum.ready;
  }

  /// 获取指定设备状态
  /// [device] 设备名称
  /// 返回设备的状态，如果设备不存在则返回DeviceStatusEnum.offline
  DeviceStatusEnum getDeviceStatus(String device) {
    return _deviceStatusMap[device] ?? DeviceStatusEnum.offline;
  }

  /// 设置指定设备的状态
  /// [device] 设备名称
  /// [status] 设备状态
  /// 如果设备不存在，抛出异常；如果所有设备都就绪，则设置全局状态为就绪，否则设置为离线
  void setDeviceStatus(String device, DeviceStatusEnum status) {
    if (_deviceStatusMap.containsKey(device)) {
      _deviceStatusMap[device] = status;
      final List<String> keysToCheck = ['backend', 'camera', 'mcu'];
      if (keysToCheck.every((key) => _deviceStatusMap[key] == DeviceStatusEnum.ready)) {
        _deviceStatusMap['global'] = DeviceStatusEnum.ready;
      } else {
        _deviceStatusMap['global'] = DeviceStatusEnum.offline;
      }
      notifyListeners();
    } else {
      throw Exception('Invalid device name: $device');
    }
  }

  /// 全部设置为离线
  /// 用于断开连接时
  void setAllOffline() {
    _deviceStatusMap.forEach((key, value) {
      _deviceStatusMap[key] = DeviceStatusEnum.offline;
    });
    notifyListeners();
  }
}

/// 设备信息
class DeviceInfo {
  String name;
  String model;
  String remark;
  String hardwareVersion;
  String softwareVersion;

  DeviceInfo({
    this.name = 'Nameless Device',
    this.model = 'Unknown Model',
    this.remark = 'No Comment',
    this.hardwareVersion = '0000',
    this.softwareVersion = '0000',
  });
}

/// 设备信息单例类
class DevicesInfoManager with ChangeNotifier {
  /// 设备信息映射
  Map<String, DeviceInfo> _deviceInfoMap = {};

  /// 单例对象
  static final DevicesInfoManager _singleton = DevicesInfoManager._internal();

  /// 工厂构造函数返回单例对象
  factory DevicesInfoManager() {
    return _singleton;
  }

  /// 私有构造函数
  DevicesInfoManager._internal();

  /// 获取指定设备的信息
  /// [device] 设备名称
  /// 返回设备的信息，如果设备不存在则返回缺省设备信息
  DeviceInfo getDeviceInfo(String device) {
    return _deviceInfoMap[device] ?? DeviceInfo();
  }

  /// 设置指定设备的信息
  /// [device] 设备名称
  /// [info] 设备信息
  /// 如果设备不存在，新增设备
  void setDeviceInfo(String device, DeviceInfo info) {
    _deviceInfoMap[device] = info;
    notifyListeners();
  }
}

/// 设备名称列表
final List<String> deviceList = ["backend", "camera", "mcu", "conveyorBelt", "turntable", "compressor", "tiltingPlate", "weighing", "metering"];

/// 设备名称映射
final Map<String, String> deviceReadableNameMap = {
  'global': '全局',
  'WebSocketParser': '套接字',
  'backend': '后端',
  'camera': '摄像头',
  'mcu': '单片机',
  'conveyorBelt': '传送带',
  'turntable': '转盘',
  'compressor': '压缩机',
  'tiltingPlate': '倾倒盘',
  'weighing': '计重组件',
  'metering': '计量组件',
};

/// 设备图标映射
final Map<String, IconData> deviceIconMap = {
  'global': Icons.devices_outlined,
  'backend': Icons.dns_outlined,
  'camera': Icons.videocam_outlined,
  'mcu': Icons.developer_board_outlined,
  'conveyorBelt': Icons.conveyor_belt,
  'turntable': Icons.change_circle_outlined,
  'compressor': Icons.compress_outlined,
  'tiltingPlate': Icons.pivot_table_chart_outlined,
  'weighing': Icons.monitor_weight_outlined,
  'metering': Icons.straighten_outlined,
};

/// 设备状态可读名称映射
final Map<DeviceStatusEnum, String> deviceStatusReadableNameMap = {
  DeviceStatusEnum.ready: '就绪',
  DeviceStatusEnum.offline: '离线',
  DeviceStatusEnum.error: '故障',
  DeviceStatusEnum.unknown: '未知',
};

/// 文本-设备状态映射
final Map<String, DeviceStatusEnum> textToStatusMap = {
  'ready': DeviceStatusEnum.ready,
  'offline': DeviceStatusEnum.offline,
  'error': DeviceStatusEnum.error,
};

/// 日志等级枚举类，包含了 debug、info、warning 和 error 四个等级
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// 日志等级-文本颜色映射
final Map<LogLevel, Color> logLevelTextColorMap = {
  LogLevel.debug: Colors.grey,
  LogLevel.info: Colors.blue,
  LogLevel.warning: Colors.orange,
  LogLevel.error: Colors.red,
};

/// 日志等级-名称映射
final Map<LogLevel, String> logLevelNameMap = {
  LogLevel.debug: 'Debug',
  LogLevel.info: 'Info',
  LogLevel.warning: 'Warning',
  LogLevel.error: 'Error',
};

/// LogEntry 类表示一条日志。每条日志包含了时间戳、日志等级、组件名称和消息内容
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String componentName;
  final String message;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.componentName,
    required this.message,
  });
}

/// LogManager 类使用单例模式和 ChangeNotifier 进行状态管理
class LogManager with ChangeNotifier {
  static LogManager? _instance;

  LogManager._internal();

  factory LogManager() {
    _instance ??= LogManager._internal();
    return _instance!;
  }

  List<LogEntry> _logs = [];

  /// 获取当前的日志列表
  List<LogEntry> get logs => _logs;

  /// 添加一条新的日志。这个方法会自动获取当前的时间作为日志的时间戳
  void addLog({
    required LogLevel level,
    required String componentName,
    required String message,
  }) {
    _logs.add(LogEntry(
      timestamp: DateTime.now(),
      level: level,
      componentName: componentName,
      message: message,
    ));
    notifyListeners();
  }

  /// 清空所有的日志
  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }
}

/// 提取视频文件到缓存目录
Future<String> extractVideo() async {
  const filename = "video.mp4";
  final cacheDir = await getTemporaryDirectory();

  if (!await Directory('${cacheDir.path}/.cache').exists()) {
    await Directory('${cacheDir.path}/.cache').create(recursive: true);
  }

  final filePath = '${cacheDir.path}/.cache/$filename';

  if (!await File(filePath).exists()) {
    ByteData data = await rootBundle.load("assets/videos/$filename");
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(filePath).writeAsBytes(bytes, flush: true);
  }

  return filePath;
}

/// 仪表盘状态枚举类
enum DashboardStatus {
  unknown, // 未知
  idle, // 空闲
  busy, // 忙碌
}

/// 仪表盘管理类，使用单例模式和 ChangeNotifier 进行状态管理
class DashboardManager with ChangeNotifier {
  /// 单例对象
  static final DashboardManager _singleton = DashboardManager._internal();

  /// 工厂构造函数返回单例对象
  factory DashboardManager() {
    return _singleton;
  }

  /// 私有构造函数
  DashboardManager._internal();

  DashboardStatus _nnStatus = DashboardStatus.unknown;  // 神经网络状态
  DashboardStatus _cbStatus = DashboardStatus.unknown;  // 传送带状态
  DashboardStatus _cpStatus = DashboardStatus.unknown;  // 压缩机状态
  Uint8List? _lastObject = null;  // 最后识别的物体图像
  String? _lastResult = null;  // 最后识别的结果
  Uint8List? _realtime = null;  // 实时识别的物体图像

  Timer? _realtimeTimer;

  DashboardStatus get nnStatus => _nnStatus;
  DashboardStatus get cbStatus => _cbStatus;
  DashboardStatus get cpStatus => _cpStatus;
  Uint8List? get lastObject => _lastObject;
  String? get lastResult => _lastResult;
  Uint8List? get realtime => _realtime;

  /// 设置神经网络状态
  void setNNStatus(DashboardStatus status) {
    _nnStatus = status;
    notifyListeners();
  }

  /// 设置传送带状态
  void setCBStatus(DashboardStatus status) {
    _cbStatus = status;
    notifyListeners();
  }

  /// 设置压缩机状态
  void setCPStatus(DashboardStatus status) {
    _cpStatus = status;
    notifyListeners();
  }

  /// 更新最后识别的物体图像
  void updateLastObjectImage(Uint8List? image) {
    _lastObject = image;
    notifyListeners();
  }

  /// 更新最后识别的结果
  void updateLastResult(String? result) {
    _lastResult = result;
    notifyListeners();
  }

  /// 更新实时的物体图像
  void updateRealtime(Uint8List? image) {
    _realtime = image;
    notifyListeners();

    _realtimeTimer?.cancel();
    _realtimeTimer = Timer(const Duration(seconds: 5), () {
      _realtime = null;
      notifyListeners();
    });
  }
}

/// 显示关于对话框
void showAboutDialogWithContent(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('关于'),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('© 2023 Steven'),
              Text('Coming Soon...'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('确定'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      );
    },
  );
}

/// 显示满载检测对话框
void showOverLoadDialog(BuildContext context, String type) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        icon: Icon(Icons.warning_amber_outlined, size: 40,color: Theme.of(context).colorScheme.error),
        title: const Text('满载警告'),
        content: Text('${trashReadableNameMap[type]}接近满载，请及时清理垃圾桶'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('忽略'),
          ),
        ],
      );
    },
  );
}

/// 视频播放器管理类，使用单例模式和 ChangeNotifier 进行状态管理
class PlayerManager with ChangeNotifier {
  static final PlayerManager _singleton = PlayerManager._internal();

  factory PlayerManager() {
    return _singleton;
  }

  PlayerManager._internal();

  bool _isPlaying = false;
  late final Player _player;
  late final VideoController _controller;

  VideoController get controller => _controller;
  bool get isPlaying => _isPlaying;

  init(String videoPath) {
    _player = Player();
    _controller = VideoController(_player);
    _player.open(Media(videoPath), play: false);
    _player.setPlaylistMode(PlaylistMode.single);
    LogManager().addLog(
      level: LogLevel.info,
      componentName: 'PlayerManager',
      message: 'Video player successfully loaded video from $videoPath',
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  /// 播放
  void play() {
    _player.play();
    _isPlaying = true;
    LogManager().addLog(
      level: LogLevel.info,
      componentName: 'PlayerManager',
      message: 'Video player started playing',
    );
    notifyListeners();
  }

  /// 暂停
  void pause() {
    _player.pause();
    _isPlaying = false;
    LogManager().addLog(
      level: LogLevel.info,
      componentName: 'PlayerManager',
      message: 'Video player paused',
    );
    // 等待500ms，确保视频播放器已经暂停
    Future.delayed(const Duration(milliseconds: 500), () {
      notifyListeners();
    });
  }

  /// 静音
  void mute() {
    _player.setVolume(0);
    LogManager().addLog(
      level: LogLevel.info,
      componentName: 'PlayerManager',
      message: 'Video player muted',
    );
    notifyListeners();
  }

  /// 取消静音
  void unmute() {
    _player.setVolume(100);
    LogManager().addLog(
      level: LogLevel.info,
      componentName: 'PlayerManager',
      message: 'Video player unmuted',
    );
    notifyListeners();
  }
}

/// 历史记录结构体
class HistoryRecord {
  Uint8List? image;
  String category;
  String metadata;
  DateTime time;

  HistoryRecord({
    required this.image,
    required this.category,
    required this.metadata,
    required this.time,
  });
}

/// 历史记录管理类，使用单例模式和 ChangeNotifier 进行状态管理
class HistoryModel with ChangeNotifier {
  static HistoryModel? _instance;

  factory HistoryModel() {
    _instance ??= HistoryModel._internal();
    return _instance!;
  }

  HistoryModel._internal();

  List<HistoryRecord> _historyList = [];

  List<HistoryRecord> get historyList => _historyList;

  void addRecord(String category, String metadata, DateTime time) {
    Uint8List? image = DashboardManager().lastObject;
    final record = HistoryRecord(
      image: image,
      category: category,
      metadata: metadata,
      time: time,
    );
    _historyList.add(record);
    notifyListeners();
  }

  void removeRecord(int index) {
    _historyList.removeAt(index);
    notifyListeners();
  }

  void clearRecords() {
    _historyList.clear();
    notifyListeners();
  }
}

bool isFullScreen = false;
