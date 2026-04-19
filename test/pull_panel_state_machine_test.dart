import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/lab/demos/pull_panel_demo.dart';

void main() {
  group('PullPanelStateMachine (WeChat semantics)', () {
    test('hintText matches thresholds', () {
      final sm = PullPanelStateMachine();

      sm.debugSetProgressForTest(0.0);
      expect(sm.hintText, '继续下拉');

      sm.debugSetProgressForTest(PullPanelStateMachine.refreshThreshold);
      expect(sm.hintText, '松手刷新');

      sm.debugSetProgressForTest(PullPanelStateMachine.openThreshold - 0.01);
      expect(sm.hintText, '松手刷新');

      sm.debugSetProgressForTest(PullPanelStateMachine.openThreshold);
      expect(sm.hintText, '松手打开面板');

      sm.debugSetStateForTest(PullPanelState.refreshHolding);
      expect(sm.hintText, '刷新中…');

      sm.debugSetStateForTest(PullPanelState.refreshing);
      expect(sm.hintText, '刷新中…');
    });

    test('release below refreshThreshold animates back to 0.0', () {
      final sm = PullPanelStateMachine();

      sm.onMainDragStart();
      sm.debugSetProgressForTest(PullPanelStateMachine.refreshThreshold - 0.01);

      final effect = sm.onMainDragEnd(velocityDy: 0);
      expect(effect.startRefresh, isFalse);
      expect(effect.animateTo, 0.0);
      expect(sm.state, PullPanelState.settling);
    });

    test('release between thresholds starts refresh and holds', () {
      final sm = PullPanelStateMachine();

      sm.onMainDragStart();
      sm.debugSetProgressForTest(
        (PullPanelStateMachine.refreshThreshold +
                PullPanelStateMachine.openThreshold) /
            2,
      );

      final effect = sm.onMainDragEnd(velocityDy: 0);
      expect(effect.startRefresh, isTrue);
      expect(effect.animateTo, PullPanelStateMachine.refreshHoldProgress);
      expect(sm.state, PullPanelState.refreshHolding);
    });

    test('release above openThreshold opens to 1.0', () {
      final sm = PullPanelStateMachine();

      sm.onMainDragStart();
      sm.debugSetProgressForTest(PullPanelStateMachine.openThreshold);

      final effect = sm.onMainDragEnd(velocityDy: 0);
      expect(effect.startRefresh, isFalse);
      expect(effect.animateTo, 1.0);
      expect(sm.state, PullPanelState.settling);
    });

    test('fast downward velocity opens even below thresholds', () {
      final sm = PullPanelStateMachine();

      sm.onMainDragStart();
      sm.debugSetProgressForTest(0.10);

      final effect = sm.onMainDragEnd(
        velocityDy: PullPanelStateMachine.velocityOpen + 1,
      );
      expect(effect.startRefresh, isFalse);
      expect(effect.animateTo, 1.0);
    });

    test('onMainDragEnd is a no-op when not dragging', () {
      final sm = PullPanelStateMachine();

      sm.debugSetProgressForTest(0.6);
      final effect = sm.onMainDragEnd(velocityDy: 0);
      expect(effect.isNone, isTrue);
    });
  });
}
