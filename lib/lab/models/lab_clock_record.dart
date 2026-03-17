import 'package:json_annotation/json_annotation.dart';

part 'lab_clock_record.g.dart';

@JsonSerializable()
class LabClockRecord {
  final String id;
  final String clockId;
  final String clockTitle;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds; // 计划倒计时时长（秒）
  final bool completed; // 是否完成
  final int? accumulatedRunningSeconds; // 累计实际运行时间（秒）

  LabClockRecord({
    required this.id,
    required this.clockId,
    required this.clockTitle,
    required this.startTime,
    this.endTime,
    required this.durationSeconds,
    this.completed = false,
    this.accumulatedRunningSeconds,
  });

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
    int? accumulatedRunningSeconds,
  }) {
    return LabClockRecord(
      id: id ?? this.id,
      clockId: clockId ?? this.clockId,
      clockTitle: clockTitle ?? this.clockTitle,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      completed: completed ?? this.completed,
      accumulatedRunningSeconds: accumulatedRunningSeconds ?? this.accumulatedRunningSeconds,
    );
  }

  /// 获取实际运行时长（秒）
  int get actualDuration => accumulatedRunningSeconds ?? 0;

  /// 是否正在运行（未完成且没有结束时间）
  bool get isRunning => !completed && endTime == null;
}
