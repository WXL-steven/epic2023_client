import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:epic2023/shared_resources.dart' show LogLevel, LogManager,
textToStatusMap, DeviceStatusEnum, DeviceStatus, TrashStatistics,
GarbageLoadData, DashboardManager, DashboardStatus, HistoryModel;

/// 状态管理
bool updateDeviceStatus(Map<String, dynamic> data) {
  final String deviceName = data.containsKey('deviceName') && data['deviceName'] is String
      ? data['deviceName'] : 'null';
  final String deviceStatus = data.containsKey('deviceStatus') && data['deviceStatus'] is String
      ? data['deviceStatus'] : 'null';

  /// 检查数据是否有效
  if (deviceName == 'null' || deviceStatus == 'null') {
    LogManager().addLog(
      level: LogLevel.warning,
      componentName: 'WebSocketParser',
      message: 'Backend wants to set the state of a device but does not get a valid device name: $deviceName'
    );
    return false;
  }

  final DeviceStatusEnum status = textToStatusMap[deviceStatus] ?? DeviceStatusEnum.unknown;

  /// 检查设备状态是否有效
  if (status == DeviceStatusEnum.unknown) {
    LogManager().addLog(
      level: LogLevel.warning,
      componentName: 'WebSocketParser',
      message: 'Backend wants to set the state of device $deviceName '
          'but does not get a valid state value'
    );
    return false;
  }

  /// 更新设备状态
  DeviceStatus().setDeviceStatus(deviceName, status);
  LogManager().addLog(
    level: LogLevel.info,
    componentName: 'WebSocketParser',
    message: 'The current state of the device $deviceName has been updated to $deviceStatus'
  );
  return true;
}

/// 垃圾数量管理
bool updateTrashCount(Map<String, dynamic> data) {
  final String trashType = data.containsKey('trashType') && data['trashType'] is String
      ? data['trashType'] : 'null';
  final int trashCount = data.containsKey('trashCount') && data['trashCount'] is int
      ? data['trashCount'] : 1;

  /// 更新垃圾数量
  try {
    TrashStatistics().addTrash(
      trashType,
      trashCount
    );
  } catch (e) {
    LogManager().addLog(
      level: LogLevel.warning,
      componentName: 'WebSocketParser',
      message: 'The backend gives an invalid garbage type $trashType'
    );
    return false;
  }
  LogManager().addLog(
    level: LogLevel.info,
    componentName: 'WebSocketParser',
    message: 'Garbage type $trashType changed by $trashCount'
  );
  return true;
}

/// 总质量管理
bool updateTotalWeight(Map<String, dynamic> data) {
  final double totalWeight = data.containsKey('value') && data['value'] is double
      ? data['value'] : -1;

  if (totalWeight < 0) {
    LogManager().addLog(
      level: LogLevel.warning,
      componentName: 'WebSocketParser',
      message: 'The back end gives an invalid total mass'
    );
    return false;
  }

  /// 更新总质量
  TrashStatistics().setTotalMass(totalWeight);
  LogManager().addLog(
    level: LogLevel.info,
    componentName: 'WebSocketParser',
    message: 'Total weight changed by $totalWeight'
  );
  return true;
}

/// 每类容器负载管理
bool updateContainerLoad(Map<String, dynamic> data) {
  final String containerName = data.containsKey('containerName') && data['containerName'] is String
      ? data['containerName'] : 'null';
  final double containerLoad = data.containsKey('value') && data['value'] is double
      ? data['value'] : -1;

  if (containerName == 'null') {
    LogManager().addLog(
      level: LogLevel.warning,
      componentName: 'WebSocketParser',
      message: 'The back end gives an invalid container name'
    );
    return false;
  }
  if (containerLoad < 0) {
    LogManager().addLog(
      level: LogLevel.warning,
      componentName: 'WebSocketParser',
      message: 'The back end gives an invalid container load'
    );
    return false;
  }

  /// 更新容器负载
  GarbageLoadData().setLoad(containerName, containerLoad);
  LogManager().addLog(
    level: LogLevel.info,
    componentName: 'WebSocketParser',
    message: 'Container $containerName load has been set to $containerLoad'
  );
  return true;
}

/// 工作状态管理
bool updateWorkStatus(Map<String, dynamic> data) {
  final String moduleName = data.containsKey('moduleName') && data['moduleName'] is String
      ? data['moduleName']
      : 'null';
  final String workStatus = data.containsKey('workStatus') && data['workStatus'] is String
      ? data['workStatus']
      : 'null';
  late DashboardStatus status;

  if (workStatus == 'null') {
    LogManager().addLog(
      level: LogLevel.warning,
      componentName: 'WebSocketParser',
      message: 'The back end gives an invalid work status'
    );
    return false;
  }

  switch (workStatus) {
    case 'working':
      status = DashboardStatus.busy;
      break;
    case 'idle':
      status = DashboardStatus.idle;
      break;
    default:
      status = DashboardStatus.unknown;
  }

  switch (moduleName) {
    case 'Classifier':
      DashboardManager().setNNStatus(status);
      break;
    case 'Conveyor':
      DashboardManager().setCBStatus(status);
      break;
    case 'Compactor':
      DashboardManager().setCPStatus(status);
      break;
    default:
      LogManager().addLog(
        level: LogLevel.warning,
        componentName: 'WebSocketParser',
        message: 'The back end gives an invalid module name'
      );
      return false;
  }
  return true;
}

/// 识别结果管理
bool updateResult(Map<String, dynamic> data) {
  late final String reEncodedResult;
  late final List<dynamic> decodedResult;
  final String result = data.containsKey('result') && data['result'] is String
      ? data['result']
      : 'null';

  if (result == 'null') {
    LogManager().addLog(
      level: LogLevel.warning,
      componentName: 'WebSocketParser',
      message: 'The back end gives an invalid result'
    );
    return false;
  }

  try {
    decodedResult = jsonDecode(result);
    reEncodedResult = const JsonEncoder.withIndent('  ').convert(decodedResult);
  } catch (e) {
    LogManager().addLog(
      level: LogLevel.warning,
      componentName: 'WebSocketParser',
      message: 'Cannot decode the result: $e'
    );
    return false;
  }

  /// 更新识别结果
  DashboardManager().updateLastResult(reEncodedResult);
  if (decodedResult[0].containsKey('label') && decodedResult[0]['label'] is String) {
    HistoryModel().addRecord(decodedResult[0]['label'], reEncodedResult, DateTime.now());
  }
  return true;
}

/// 图片接收器类
class ImageReceiver {
  /// 总共需要接收的块数
  int _totalChunks = 0;
  /// 已经接收的块数
  int _receivedChunks = 0;
  /// 当前正在接收的图片的时间戳
  int _timestamp = 0;
  /// 用于存储接收到的块的 Map
  Map<int, Uint8List>? _buffer;
  /// 当所有块都已接收时将调用的函数
  final Function(Uint8List) _onComplete;

  /// ImageReceiver 的构造函数
  /// onComplete - 当所有块都已接收时将调用的函数
  ImageReceiver(this._onComplete);

  void jsonToImage(Map<String, dynamic> data) {
    final int totalChunks = data.containsKey('totalChunks') && data['totalChunks'] is int
        ? data['totalChunks']
        : -1;
    final int chunkIndex = data.containsKey('chunkIndex') && data['chunkIndex'] is int
        ? data['chunkIndex']
        : -1;
    final int timestamp = data.containsKey('timestamp') && data['timestamp'] is int
        ? data['timestamp']
        : -1;
    final String base64Data = data.containsKey('base64Data') && data['base64Data'] is String
        ? data['base64Data']
        : '';

    if (totalChunks < 0 || chunkIndex < 0 || timestamp < 0 || base64Data == '') {
      LogManager().addLog(
        level: LogLevel.warning,
        componentName: 'WebSocketParser',
        message: 'Cannot parse the image data from the backend'
      );
      return;
    }

    receiveImgChunk(totalChunks, chunkIndex, timestamp, base64Data);
  }

  /// 接收一个JPEG图像块
  /// totalChunks - 总共的块数
  /// chunkIndex - 当前块的索引
  /// timestamp - 图片的时间戳
  /// base64Data - 块的 base64 编码的数据
  /// callback - 图片接收完成后的回调函数
  void receiveImgChunk(
    int totalChunks,
    int chunkIndex,
    int timestamp,
    String base64Data,
  ) {
    // 如果接收到的块时间戳比当前缓冲区时间戳旧，忽略
    if (timestamp < _timestamp) {
      return;
    }

    // 如果接收到新的块时间戳比当前缓冲区图片的新，清除旧的缓冲区图片
    if (timestamp > _timestamp) {
      _timestamp = timestamp;
      _totalChunks = totalChunks;
      _receivedChunks = 0;
      _buffer = {};
    }

    // 将base64数据解码为Uint8List
    Uint8List chunkData = base64Decode(base64Data);

    // 如果缓冲区中没有这个索引，说明这是一个新接收的块，_receivedChunks 计数器加一
    if (_buffer![chunkIndex] == null) {
      _receivedChunks++;
    }
    // 添加块到缓冲区
    _buffer![chunkIndex] = chunkData;

    // 检查是否已接收所有块
    if (_receivedChunks == _totalChunks) {
      // 合并所有块并创建Image对象
      try {
        Uint8List imageData = _buffer!.values.fold(Uint8List(0), (previous, element) => Uint8List.fromList([...previous, ...element]));

        // 清空缓冲区
        _buffer = null;
        _receivedChunks = 0;
        _totalChunks = 0;

        _onComplete(imageData);
      } catch (e) {
        LogManager().addLog(
          level: LogLevel.warning,
          componentName: 'WebSocketParser',
          message: 'Cannot create image from the received chunks: $e'
        );
        return;
      }
    }
  }
}

/// WebSocket管理类
class WebSocketManager {
  /// 单例对象
  static final WebSocketManager _singleton = WebSocketManager._internal();

  late final Map<String, Function(Map<String, dynamic>)> _dataHandlers;

  /// 内部构造方法，可防止外部暴露构造函数，进行多实例创建
  WebSocketManager._internal() {
    _dataHandlers = {
      'deviceStatusManager': updateDeviceStatus, // 更新设备状态
      'updateTrashCount': updateTrashCount, // 更新垃圾数量
      'updateTotalWeight': updateTotalWeight, // 更新总质量
      'containerLoadManager': updateContainerLoad, // 更新容器负载
      'workStatusManager': updateWorkStatus, // 更新工作状态
      'updateResult': updateResult, // 更新识别结果
      'resultImageTransfer': _lastResultImageReceiver.jsonToImage, // 更新上一结果图片
      'realtimeImageTransfer': _realtimeImageReceiver.jsonToImage, // 更新实时图片
    };
  }

  /// 工厂构造方法，这里使用命名构造函数方式进行声明
  factory WebSocketManager() => _singleton;

  /// WebSocket连接
  WebSocket? _socket;

  /// WebSocket连接状态
  bool get isConnected => _socket != null;

  /// 上一结果图片接收器
  final ImageReceiver _lastResultImageReceiver = ImageReceiver(DashboardManager().updateLastObjectImage);

  /// 实时图片接收器
  final ImageReceiver _realtimeImageReceiver = ImageReceiver(DashboardManager().updateRealtime);

  /// 连接到WebSocket服务器
  ///
  /// [url] 是服务器的地址
  Future<void> connect([String url = 'ws://localhost:22334']) async {
    try {
      _socket = await WebSocket.connect(url);
      LogManager().addLog(
        level: LogLevel.info,
        componentName: 'WebSocketParser',
        message: 'WebSocket connection established'
      );
      DashboardManager().setCPStatus(DashboardStatus.idle);
      DashboardManager().setNNStatus(DashboardStatus.idle);
      DeviceStatus().setDeviceStatus('backend', DeviceStatusEnum.ready);
      _socket!.listen(
            (data) {
          // 检查数据的类型，如果是字符串，则处理，否则忽略
          if (data is String) {
            handleData(data);
          }
        },
        onError: (error) {
          disconnect();
          LogManager().addLog(
            level: LogLevel.error,
            componentName: 'WebSocketParser',
            message: 'WebSocket connection error: $error'
          );
        },
        onDone: () {
          DeviceStatus().setAllOffline();
          DashboardManager().setNNStatus(DashboardStatus.unknown);
          DashboardManager().setCPStatus(DashboardStatus.unknown);
          DashboardManager().setCBStatus(DashboardStatus.unknown);
          LogManager().addLog(
            level: LogLevel.warning,
            componentName: 'WebSocketParser',
            message: 'WebSocket connection closed'
          );
        },
      );
    } catch (e) {
      DeviceStatus().setDeviceStatus('backend', DeviceStatusEnum.error);
      LogManager().addLog(
        level: LogLevel.error,
        componentName: 'WebSocketParser',
        message: 'WebSocket connection error: $e'
      );
    }
  }

  /// 断开WebSocket连接
  void disconnect() {
    if (_socket != null) {
      _socket!.close();
      _socket = null;
    }
    LogManager().addLog(
      level: LogLevel.warning,
      componentName: 'WebSocketParser',
      message: 'WebSocket connection closed'
    );
  }

  /// 向服务器发送数据
  ///
  /// [message] 是要发送的数据
  void send(String message) {
    if (_socket != null) {
      LogManager().addLog(
        level: LogLevel.info,
        componentName: 'WebSocketParser',
        message: 'Sending message to server: $message'
      );
      _socket!.add(message);
    }
  }

  ///打包并发送数据
  ///
  /// [service] 是要发送的数据的服务名称
  /// [data] 是要发送的数据
  void packAndSend(String service, Map<String, dynamic> data) {
    data['application'] = 'epic2023';
    data['service'] = service;
    send(jsonEncode(data));
  }

  /// 处理服务器返回的数据
  ///
  /// [data] 是服务器返回的数据
  void handleData(String data) {
    Map<String, dynamic>? jsonData;
    // 尝试将数据解析为 JSON
    try {
      jsonData = jsonDecode(data);
    } catch (e) {
      LogManager().addLog(
        level: LogLevel.warning,
        componentName: 'WebSocketParser',
        message: 'The provided string could not be parsed as JSON: $e'
      );
      return;
    }

    // 检查解析后的数据是否为 Map
    if (jsonData is! Map<String, dynamic>) {
      LogManager().addLog(
        level: LogLevel.warning,
        componentName: 'WebSocketParser',
        message: 'The parsed JSON is not a Map'
      );
      return;
    }

    // 检查数据包是否正确
    if (jsonData['application'] != 'epic2023' || !jsonData.containsKey('service')) {
      LogManager().addLog(
        level: LogLevel.warning,
        componentName: 'WebSocketParser',
        message: 'The parsed JSON is not a valid data package'
      );
      return;
    }

    final Function(Map<String, dynamic>)? handler = _dataHandlers[jsonData['service']];
    if (handler == null) {
      LogManager().addLog(
        level: LogLevel.warning,
        componentName: 'WebSocketParser',
        message: 'The parsed JSON does not contain a valid service name: ${jsonData['service']}'
      );
      return;
    }

    handler(jsonData);
  }
}