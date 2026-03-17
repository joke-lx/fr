import 'package:json_annotation/json_annotation.dart';

part 'lab_clock_record.g.dart';

/// 时钟记录事件类型
enum ClockEventType {
  start,   // 开始倒计时
  pause,   // 暂停
  resume,  // 恢复
  reset,   // 重置/结束
}

/// 时钟记录事件
@JsonSerializable()
class ClockEvent {
  final ClockEventType type;
  final DateTime timestamp;

  ClockEvent({
    required this.type,
    required this.timestamp,
  });

  factory ClockEvent.fromJson(Map<String, dynamic> json) => _$ClockEventFromJson(json);

  Map<String, dynamic> toJson() => _$ClockEventToJson(this);

  ClockEvent copyWith({
    ClockEventType? type,
    DateTime? timestamp,
  }) {
    return ClockEvent(
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

@JsonSerializable()
class LabClockRecord {
  final String id;
  final String clockId;
  final String clockTitle;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds; // 本次倒计时时长（秒）
  final bool completed; // 是否完成
  final List<ClockEvent> events; // 事件列表

  LabClockRecord({
    required this.id,
    required this.clockId,
    required this.clockTitle,
    required this.startTime,
    this.endTime,
    required this.durationSeconds,
    this.completed = false,
    List<ClockEvent>? events,
  }) : events = events ?? [];

  factory LabClockRecord.fromJson(Map<String, dynamic> json) => _$LabClockRecordFromJson(json);

  Map<String, dynamic> toJson() => _$LabClockRecordToJson(this);

  LabClockRecord copyWith({
    String? id,
    String? clockId,
    String? clockTitle,
    DateTime? startTime,
    DateTime? endTime,
    int? durationSeconds,
    bool? completed,
    List<ClockEvent>? events,
  }) {
    return LabClockRecord(
      id: id ?? this.id,
      clockId: clockId ?? this.clockId,
      clockTitle: clockTitle ?? this.clockTitle,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      completed: completed ?? this.completed,
      events: events ?? this.events,
    );
  }

  /// 添加事件
  LabClockRecord addEvent(ClockEvent event) {
    return LabClockRecord(
      id: id,
      clockId: clockId,
      clockTitle: clockTitle,
      startTime: startTime,
      endTime: endTime,
      durationSeconds: durationSeconds,
      completed: completed,
      events: [...events, event],
    );
  }

  /// 获取实际使用时长（秒）- 基于事件计算
  /// 只计算从 start 到 pause、resume 到 pause、resume 到 reset 之间的时间
  /// 不包括暂停期间
  int get actualDuration {
    int totalSeconds = 0;
    DateTime? sessionStart;
    bool isRunning = false;

    for (final event in events) {
      switch (event.type) {
        case ClockEventType.start:
        case ClockEventType.resume:
          // 开始一个新的运行会话
          sessionStart = event.timestamp;
          isRunning = true;
          break;
        case ClockEventType.pause:
        case ClockEventType.reset:
          // 结束当前运行会话
          if (isRunning && sessionStart != null) {
            totalSeconds += event.timestamp.difference(sessionStart!).inSeconds;
            sessionStart = null;
            isRunning = false;
          }
          break;
      }
    }

    // 如果记录已完成（有 reset 事件），返回累计时间
    // 如果记录未完成，也返回已累计的时间（不包括当前运行中的时间）
    // 这样避免了计算物理时间的问题
    return totalSeconds;
  }

  /// 获取格式化的事件描述
  String get eventsDescription {
    if (events.isEmpty) return '无事件';

    final buffer = StringBuffer();
    for (final event in events) {
      final timeStr = '${event.timestamp.hour.toString().padLeft(2, '0')}:${event.timestamp.minute.toString().padLeft(2, '0')}';
      buffer.write('$timeStr ${_eventTypeToString(event.type)} ');
    }
    return buffer.toString().trim();
  }

  String _eventTypeToString(ClockEventType type) {
    switch (type) {
      case ClockEventType.start: return '开始';
      case ClockEventType.pause: return '暂停';
      case ClockEventType.resume: return '恢复';
      case ClockEventType.reset: return '重置';
    }
  }
}
