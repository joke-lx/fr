import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/lab/providers/lab_clock_provider.dart';
import 'package:flutter_application_1/lab/models/lab_clock.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // 初始化测试 binding
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LabClockProvider - 简化架构测试', () {
    late LabClockProvider provider;

    setUp(() async {
      // 设置 mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      provider = LabClockProvider();
      await provider.loadClocks();
    });

    test('启动-暂停-恢复-暂停-重置流程', () async {
      final clock = await provider.createClock(
        title: '测试时钟',
        durationSeconds: 300, // 5分钟
      );

      // 启动
      await provider.startCountdown(clock.id);

      // 模拟倒计时运行10秒（直接修改时钟状态）
      provider.clocks[0] = provider.clocks[0].copyWith(
        isRunning: true,
        remainingSeconds: 290, // 已消耗10秒
      );

      // 暂停
      await provider.pauseCountdown(clock.id);

      var record = provider.records.first;
      print('第一次暂停后时长: ${record.actualDuration}');
      expect(record.actualDuration, 10); // 应该是10秒

      // 恢复
      await provider.startCountdown(clock.id);

      // 模拟再运行20秒
      provider.clocks[0] = provider.clocks[0].copyWith(
        isRunning: true,
        remainingSeconds: 270, // 再消耗20秒
      );

      // 暂停
      await provider.pauseCountdown(clock.id);

      record = provider.records.first;
      print('第二次暂停后时长: ${record.actualDuration}');
      expect(record.actualDuration, 30); // 应该是30秒 (10 + 20)

      // 恢复
      await provider.startCountdown(clock.id);

      // 模拟再运行15秒
      provider.clocks[0] = provider.clocks[0].copyWith(
        isRunning: true,
        remainingSeconds: 255, // 再消耗15秒
      );

      // 重置
      await provider.resetCountdown(clock.id);

      record = provider.records.first;
      print('重置后时长: ${record.actualDuration}');
      expect(record.completed, true);
      expect(record.actualDuration, 45); // 应该是45秒 (10 + 20 + 15)
    });

    test('编辑时钟时间', () async {
      final clock = await provider.createClock(
        title: '测试时钟',
        durationSeconds: 300,
      );

      // 编辑时间
      await provider.updateClock(
        id: clock.id,
        durationSeconds: 600,
      );

      final updatedClock = provider.clocks.first;
      expect(updatedClock.durationSeconds, 600);
      expect(updatedClock.remainingSeconds, 600); // 应该立即更新
    });
  });
}
