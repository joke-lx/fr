import 'package:flutter/foundation.dart';

/// 录音服务
/// 支持Android、iOS平台（当前为stub实现）
/// TODO: 使用兼容的音频录制包替代
class AudioRecordingService {
  bool _isRecording = false;
  String? _recordPath;
  DateTime? _startTime;

  bool get isRecording => _isRecording;
  String? get recordPath => _recordPath;

  /// 检查麦克风权限
  Future<bool> checkPermission() async {
    if (kIsWeb) {
      return false;
    }
    // Stub实现 - 实际权限检查由调用处处理
    return true;
  }

  /// 开始录音
  /// 注意：当前为stub实现，暂不支持实际录音
  Future<bool> startRecording() async {
    if (_isRecording) return false;

    debugPrint('注意：录音功能暂为stub实现，请在pubspec中添加支持的录音包');
    return false;
  }

  /// 停止录音
  Future<String?> stopRecording() async {
    if (!_isRecording) return null;

    _isRecording = false;
    _startTime = null;
    return _recordPath;
  }

  /// 取消录音
  Future<void> cancelRecording() async {
    if (!_isRecording) return;

    _isRecording = false;
    _startTime = null;
    _recordPath = null;
  }

  /// 获取录音时长（秒）
  int getDurationInSeconds() {
    if (_startTime == null) return 0;
    final duration = DateTime.now().difference(_startTime!);
    return duration.inSeconds;
  }

  /// 获取录音文件大小（MB）
  double getFileSizeInMB() {
    return 0;
  }

  /// 删除录音文件
  Future<void> deleteRecording() async {
    _recordPath = null;
    _startTime = null;
  }

  /// 检查平台是否支持录音
  bool get isPlatformSupported => !kIsWeb;
}
