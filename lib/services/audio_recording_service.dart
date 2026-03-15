import 'package:flutter/foundation.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

/// 录音服务
/// 支持Android、iOS平台（Web平台暂不支持）
class AudioRecordingService {
  bool _isRecording = false;
  String? _recordPath;
  DateTime? _startTime;

  bool get isRecording => _isRecording;
  String? get recordPath => _recordPath;

  /// 检查麦克风权限
  Future<bool> checkPermission() async {
    if (kIsWeb) {
      // Web平台暂不支持录音
      return false;
    }
    return await Permission.microphone.request().isGranted;
  }

  /// 开始录音
  Future<bool> startRecording() async {
    if (_isRecording) return false;

    if (kIsWeb) {
      debugPrint('Web平台暂不支持录音功能');
      return false;
    }

    // 检查权限
    final hasPermission = await checkPermission();
    if (!hasPermission) {
      debugPrint('没有麦克风权限');
      return false;
    }

    try {
      // 保存到临时目录
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _recordPath = '${tempDir.path}/recording_$timestamp.mp3';

      final success = RecordMp3.instance.start(
        _recordPath!,
        (error) {
          debugPrint('录音错误: $error');
          _isRecording = false;
          _startTime = null;
        },
      );

      if (success) {
        _isRecording = true;
        _startTime = DateTime.now();
        debugPrint('录音开始: $_recordPath');
      }
      return success;
    } catch (e) {
      debugPrint('录音失败: $e');
      _isRecording = false;
      _startTime = null;
      return false;
    }
  }

  /// 停止录音
  Future<String?> stopRecording() async {
    if (!_isRecording) return null;

    try {
      final success = RecordMp3.instance.stop();
      _isRecording = false;

      if (success && _recordPath != null) {
        debugPrint('录音完成: $_recordPath');
        return _recordPath;
      }

      _startTime = null;
      return null;
    } catch (e) {
      debugPrint('停止录音失败: $e');
      _isRecording = false;
      _startTime = null;
      return null;
    }
  }

  /// 取消录音
  Future<void> cancelRecording() async {
    if (!_isRecording) return;

    try {
      RecordMp3.instance.stop();
      _isRecording = false;
      _startTime = null;

      // 删除临时文件
      if (_recordPath != null) {
        try {
          final file = File(_recordPath!);
          if (file.existsSync()) {
            await file.delete();
          }
        } catch (e) {
          debugPrint('删除临时录音文件失败: $e');
        }
      }

      _recordPath = null;
      debugPrint('录音已取消');
    } catch (e) {
      debugPrint('取消录音失败: $e');
    }
  }

  /// 获取录音时长（秒）
  int getDurationInSeconds() {
    if (_startTime == null) return 0;
    final duration = DateTime.now().difference(_startTime!);
    return duration.inSeconds;
  }

  /// 获取录音文件大小（MB）
  double getFileSizeInMB() {
    if (_recordPath == null) return 0;
    try {
      final file = File(_recordPath!);
      if (file.existsSync()) {
        final bytes = file.lengthSync();
        return bytes / (1024 * 1024);
      }
    } catch (e) {
      debugPrint('获取文件大小失败: $e');
    }
    return 0;
  }

  /// 删除录音文件
  Future<void> deleteRecording() async {
    if (_recordPath == null) return;

    try {
      final file = File(_recordPath!);
      if (file.existsSync()) {
        await file.delete();
        debugPrint('录音文件已删除');
      }
      _recordPath = null;
      _startTime = null;
    } catch (e) {
      debugPrint('删除录音文件失败: $e');
    }
  }

  /// 检查平台是否支持录音
  bool get isPlatformSupported => !kIsWeb;
}
