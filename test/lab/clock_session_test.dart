import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/lab/models/lab_clock_record.dart';

void main() {
  group('ClockSession Tests', () {
    test('新会话没有结束时，duration应该为0', () {
      final session = ClockSession(
        id: '1',
        startTime: DateTime(2025, 1, 1, 10, 0, 0),
      );

      expect(session.duration, 0);
      expect(session.isCompleted, false);
    });

    test('会话结束后，duration应该正确计算', () {
      final session = ClockSession(
        id: '1',
        startTime: DateTime(2025, 1, 1, 10, 0, 0),
        endTime: DateTime(2025, 1, 1, 10, 0, 30),
      );

      expect(session.duration, 30);
      expect(session.isCompleted, true);
    });

    test('end()方法应该结束会话', () {
      final session = ClockSession(
        id: '1',
        startTime: DateTime(2025, 1, 1, 10, 0, 0),
      ).end();

      expect(session.isCompleted, true);
      expect(session.duration, greaterThan(0));
    });
  });

  group('LabClockRecord Tests', () {
    test('新记录的actualDuration应该为0', () {
      final record = LabClockRecord(
        id: '1',
        clockId: 'clock1',
        clockTitle: '测试时钟',
        startTime: DateTime(2025, 1, 1, 10, 0, 0),
        durationSeconds: 300,
      );

      expect(record.actualDuration, 0);
      expect(record.isRunning, false);
    });

    test('添加进行中的会话，isRunning为true，但duration仍为0', () {
      final session = ClockSession(
        id: 's1',
        startTime: DateTime(2025, 1, 1, 10, 0, 0),
      );

      final record = LabClockRecord(
        id: '1',
        clockId: 'clock1',
        clockTitle: '测试时钟',
        startTime: DateTime(2025, 1, 1, 10, 0, 0),
        durationSeconds: 300,
        sessions: [session],
      );

      expect(record.actualDuration, 0);
      expect(record.isRunning, true);
      expect(record.currentSession, same(session));
    });

    test('添加已结束的会话，actualDuration应该正确计算', () {
      final session = ClockSession(
        id: 's1',
        startTime: DateTime(2025, 1, 1, 10, 0, 0),
        endTime: DateTime(2025, 1, 1, 10, 0, 30),
      );

      final record = LabClockRecord(
        id: '1',
        clockId: 'clock1',
        clockTitle: '测试时钟',
        startTime: DateTime(2025, 1, 1, 10, 0, 0),
        durationSeconds: 300,
        sessions: [session],
      );

      expect(record.actualDuration, 30);
      expect(record.isRunning, false);
    });

    test('多个会话累计计算', () {
      final session1 = ClockSession(
        id: 's1',
        startTime: DateTime(2025, 1, 1, 10, 0, 0),
        endTime: DateTime(2025, 1, 1, 10, 0, 30),
      );

      final session2 = ClockSession(
        id: 's2',
        startTime: DateTime(2025, 1, 1, 10, 1, 0),
        endTime: DateTime(2025, 1, 1, 10, 1, 20),
      );

      final session3 = ClockSession(
        id: 's3',
        startTime: DateTime(2025, 1, 1, 10, 2, 0),
        endTime: DateTime(2025, 1, 1, 10, 2, 10),
      );

      final record = LabClockRecord(
        id: '1',
        clockId: 'clock1',
        clockTitle: '测试时钟',
        startTime: DateTime(2025, 1, 1, 10, 0, 0),
        durationSeconds: 300,
        sessions: [session1, session2, session3],
      );

      expect(record.actualDuration, 60); // 30 + 20 + 10
    });

    test('endCurrentSession应该结束最后一个会话', () {
      final session1 = ClockSession(
        id: 's1',
        startTime: DateTime(2025, 1, 1, 10, 0, 0),
        endTime: DateTime(2025, 1, 1, 10, 0, 30),
      );

      final session2 = ClockSession(
        id: 's2',
        startTime: DateTime(2025, 1, 1, 10, 1, 0),
      );

      var record = LabClockRecord(
        id: '1',
        clockId: 'clock1',
        clockTitle: '测试时钟',
        startTime: DateTime(2025, 1, 1, 10, 0, 0),
        durationSeconds: 300,
        sessions: [session1, session2],
      );

      expect(record.actualDuration, 30); // 只有session1结束了
      expect(record.isRunning, true);

      record = record.endCurrentSession();

      expect(record.actualDuration, greaterThan(30)); // session2也结束了
      expect(record.isRunning, false);
    });

    test('addSession应该添加新会话', () {
      final session1 = ClockSession(
        id: 's1',
        startTime: DateTime(2025, 1, 1, 10, 0, 0),
        endTime: DateTime(2025, 1, 1, 10, 0, 30),
      );

      final session2 = ClockSession(
        id: 's2',
        startTime: DateTime(2025, 1, 1, 10, 1, 0),
      );

      var record = LabClockRecord(
        id: '1',
        clockId: 'clock1',
        clockTitle: '测试时钟',
        startTime: DateTime(2025, 1, 1, 10, 0, 0),
        durationSeconds: 300,
        sessions: [session1],
      );

      record = record.addSession(session2);

      expect(record.sessions.length, 2);
      expect(record.isRunning, true);
    });

    test('完整流程：启动-暂停-恢复-暂停-恢复-重置', () {
      // 启动：创建第一个会话
      var record = LabClockRecord(
        id: '1',
        clockId: 'clock1',
        clockTitle: '测试时钟',
        startTime: DateTime(2025, 1, 1, 10, 0, 0),
        durationSeconds: 300,
      );

      final session1 = ClockSession(
        id: 's1',
        startTime: DateTime(2025, 1, 1, 10, 0, 0),
      );
      record = record.addSession(session1);
      expect(record.isRunning, true);
      expect(record.actualDuration, 0);

      // 暂停：结束第一个会话（假设运行了30秒）
      final pausedSession1 = ClockSession(
        id: 's1',
        startTime: DateTime(2025, 1, 1, 10, 0, 0),
        endTime: DateTime(2025, 1, 1, 10, 0, 30),
      );
      record = LabClockRecord(
        id: '1',
        clockId: 'clock1',
        clockTitle: '测试时钟',
        startTime: DateTime(2025, 1, 1, 10, 0, 0),
        durationSeconds: 300,
        sessions: [pausedSession1],
      );
      expect(record.actualDuration, 30);
      expect(record.isRunning, false);

      // 恢复：创建第二个会话
      final session2 = ClockSession(
        id: 's2',
        startTime: DateTime(2025, 1, 1, 10, 1, 0),
      );
      record = record.addSession(session2);
      expect(record.isRunning, true);
      expect(record.actualDuration, 30); // 已结束的会话时长不变

      // 暂停：结束第二个会话（假设运行了20秒）
      final pausedSession2 = ClockSession(
        id: 's2',
        startTime: DateTime(2025, 1, 1, 10, 1, 0),
        endTime: DateTime(2025, 1, 1, 10, 1, 20),
      );
      record = LabClockRecord(
        id: '1',
        clockId: 'clock1',
        clockTitle: '测试时钟',
        startTime: DateTime(2025, 1, 1, 10, 0, 0),
        durationSeconds: 300,
        sessions: [pausedSession1, pausedSession2],
      );
      expect(record.actualDuration, 50); // 30 + 20
      expect(record.isRunning, false);

      // 重置：结束记录
      record = record.copyWith(
        endTime: DateTime(2025, 1, 1, 10, 2, 0),
        completed: true,
      );

      expect(record.actualDuration, 50);
      expect(record.completed, true);
    });
  });
}
