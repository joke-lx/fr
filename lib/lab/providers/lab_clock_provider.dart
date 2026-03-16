import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/lab_clock.dart';

class LabClockProvider with ChangeNotifier {
  List<LabClock> _clocks = [];
  static const String _storageKey = 'lab_clocks';
  Timer? _timer;

  List<LabClock> get clocks => _clocks;

  LabClockProvider() {
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdowns();
    });
  }

  void _updateCountdowns() {
    bool hasChanges = false;
    for (int i = 0; i < _clocks.length; i++) {
      final clock = _clocks[i];
      if (clock.isRunning && clock.remainingSeconds > 0) {
        _clocks[i] = clock.copyWith(remainingSeconds: clock.remainingSeconds - 1);
        hasChanges = true;
      } else if (clock.isRunning && clock.remainingSeconds <= 0) {
        // 倒计时结束，自动暂停
        _clocks[i] = clock.copyWith(isRunning: false, remainingSeconds: 0);
        hasChanges = true;
      }
    }
    if (hasChanges) {
      notifyListeners();
      _saveClocks(); // 实时保存状态
    }
  }

  Future<void> loadClocks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final clocksJson = prefs.getString(_storageKey);
      if (clocksJson != null) {
        final List<dynamic> clocksList = json.decode(clocksJson);
        _clocks = clocksList.map((e) => LabClock.fromJson(e)).toList();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('加载时钟失败: $e');
    }
  }

  Future<void> _saveClocks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final clocksJson = json.encode(_clocks.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, clocksJson);
    } catch (e) {
      debugPrint('保存时钟失败: $e');
    }
  }

  Future<LabClock> createClock({
    String title = '新时钟',
    String description = '',
    String? targetTime,
    int? durationSeconds,
    String? color,
  }) async {
    final clock = LabClock(
      id: const Uuid().v4(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      targetTime: targetTime,
      durationSeconds: durationSeconds,
      isRunning: false,
      remainingSeconds: durationSeconds ?? 0,
      color: color ?? '#2196F3',
    );

    _clocks.insert(0, clock);
    await _saveClocks();
    notifyListeners();
    return clock;
  }

  Future<void> updateClock({
    required String id,
    String? title,
    String? description,
    String? targetTime,
    int? durationSeconds,
    String? color,
  }) async {
    final index = _clocks.indexWhere((c) => c.id == id);
    if (index != -1) {
      final clock = _clocks[index];
      _clocks[index] = clock.copyWith(
        title: title ?? clock.title,
        description: description ?? clock.description,
        targetTime: targetTime ?? clock.targetTime,
        durationSeconds: durationSeconds ?? clock.durationSeconds,
        color: color ?? clock.color,
      );
      await _saveClocks();
      notifyListeners();
    }
  }

  Future<void> startCountdown(String id) async {
    final index = _clocks.indexWhere((c) => c.id == id);
    if (index != -1) {
      final clock = _clocks[index];
      _clocks[index] = clock.copyWith(
        isRunning: true,
        remainingSeconds: clock.durationSeconds ?? 0,
      );
      await _saveClocks();
      notifyListeners();
    }
  }

  Future<void> pauseCountdown(String id) async {
    final index = _clocks.indexWhere((c) => c.id == id);
    if (index != -1) {
      final clock = _clocks[index];
      _clocks[index] = clock.copyWith(isRunning: false);
      await _saveClocks();
      notifyListeners();
    }
  }

  Future<void> resetCountdown(String id) async {
    final index = _clocks.indexWhere((c) => c.id == id);
    if (index != -1) {
      final clock = _clocks[index];
      _clocks[index] = clock.copyWith(
        isRunning: false,
        remainingSeconds: clock.durationSeconds ?? 0,
      );
      await _saveClocks();
      notifyListeners();
    }
  }

  Future<void> deleteClock(String id) async {
    _clocks.removeWhere((c) => c.id == id);
    await _saveClocks();
    notifyListeners();
  }

  LabClock? getClockById(String id) {
    try {
      return _clocks.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
