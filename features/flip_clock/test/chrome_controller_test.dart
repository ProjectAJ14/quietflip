import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flip_clock/state/chrome_controller.dart';
import 'package:flutter_test/flutter_test.dart';

const _hud = IslandBrightnessHud(0.5, '50%');

/// Runs [body] in fake time with a fresh controller and its emissions,
/// shown (launch is hidden) unless [shown] is false.
void _run(
  void Function(FakeAsync async, ChromeController c, List<Chrome> out) body, {
  Duration idle = DesignMotion.controlsIdle,
  bool shown = true,
}) {
  fakeAsync((async) {
    final c = ChromeController(idle: idle);
    if (shown) c.wake();
    final out = <Chrome>[];
    final sub = c.stream.listen(out.add);
    body(async, c, out);
    unawaited(sub.cancel());
    unawaited(c.close());
    async.flushMicrotasks();
  });
}

ChromeState _state(ChromeController c) => c.state.state;

void main() {
  test('starts hidden with no hud and no timer; equality', () {
    final c = ChromeController();
    expect(c.state, const Chrome(ChromeState.hidden));
    expect(c.state.hud, isNull);
    expect(
      const Chrome(ChromeState.dot, _hud).hashCode,
      const Chrome(ChromeState.dot, _hud).hashCode,
    );
    expect(
      const Chrome(ChromeState.dot),
      isNot(const Chrome(ChromeState.hidden)),
    );
    expect(
      const Chrome(ChromeState.dot),
      isNot(const Chrome(ChromeState.dot, _hud)),
    );
    unawaited(c.close());
  });

  test('launch stays hidden; the first tap shows the controls', () {
    _run(shown: false, (async, c, out) {
      expect(async.pendingTimers, isEmpty);
      async.elapse(const Duration(seconds: 30));
      expect(out, isEmpty);
      c.tap();
      expect(_state(c), ChromeState.expanded);
      async.elapse(const Duration(seconds: 4));
      expect(_state(c), ChromeState.dot);
      async.elapse(const Duration(seconds: 3));
      expect(_state(c), ChromeState.hidden);
    });
  });

  test('tap toggles: expanded -> hidden -> expanded, dot -> expanded', () {
    _run((async, c, _) {
      c.tap();
      expect(_state(c), ChromeState.hidden);
      c.tap();
      expect(_state(c), ChromeState.expanded);
      async.elapse(const Duration(seconds: 4));
      expect(_state(c), ChromeState.dot);
      c.tap();
      expect(_state(c), ChromeState.expanded);
    });
  });

  test('collapses to a dot at 4 s, hidden at 7 s, then stays', () {
    _run((async, c, out) {
      async.elapse(const Duration(milliseconds: 3999));
      expect(_state(c), ChromeState.expanded);
      async.elapse(const Duration(milliseconds: 1));
      expect(_state(c), ChromeState.dot);
      async.elapse(const Duration(milliseconds: 2999));
      expect(_state(c), ChromeState.dot);
      async.elapse(const Duration(milliseconds: 1));
      expect(_state(c), ChromeState.hidden);
      async.elapse(const Duration(seconds: 10));
      expect(out, const [Chrome(ChromeState.dot), Chrome(ChromeState.hidden)]);
      expect(async.pendingTimers, isEmpty);
    });
  });

  test('activity restarts the timer without changing state', () {
    _run((async, c, out) {
      async.elapse(const Duration(milliseconds: 3900));
      c.activity();
      expect(out, isEmpty);
      async.elapse(const Duration(milliseconds: 3999));
      expect(_state(c), ChromeState.expanded);
      async.elapse(const Duration(milliseconds: 1));
      expect(_state(c), ChromeState.dot);
      // In the dot, activity delays hiding by a full dotIdle.
      async.elapse(const Duration(seconds: 2));
      c.activity();
      async.elapse(const Duration(milliseconds: 2999));
      expect(_state(c), ChromeState.dot);
      async.elapse(const Duration(milliseconds: 1));
      expect(_state(c), ChromeState.hidden);
    });
  });

  test('wake from hidden expands and restarts the idle timer', () {
    _run((async, c, _) {
      c.hide();
      c.wake();
      expect(_state(c), ChromeState.expanded);
      async.elapse(const Duration(seconds: 4));
      expect(_state(c), ChromeState.dot);
    });
  });

  test('hide cancels the idle timers', () {
    _run((async, c, out) {
      c.hide();
      expect(_state(c), ChromeState.hidden);
      expect(async.pendingTimers, isEmpty);
      async.elapse(const Duration(seconds: 20));
      expect(out, const [Chrome(ChromeState.hidden)]);
    });
  });

  test('hud shows over hidden and returns to hidden 1.2 s after release', () {
    _run((async, c, _) {
      c.hide();
      c.showHud(_hud);
      expect(c.state, const Chrome(ChromeState.hidden, _hud));
      c.releaseHud();
      async.elapse(const Duration(milliseconds: 1199));
      expect(c.state.hud, _hud);
      async.elapse(const Duration(milliseconds: 1));
      expect(c.state, const Chrome(ChromeState.hidden));
    });
  });

  test('hud returns to expanded, and to the dot, likewise', () {
    _run((async, c, _) {
      c.showHud(_hud);
      c.releaseHud();
      async.elapse(const Duration(milliseconds: 1200));
      expect(c.state, const Chrome(ChromeState.expanded));
      async.elapse(const Duration(seconds: 4));
      expect(_state(c), ChromeState.dot);
      c.showHud(_hud);
      expect(c.state, const Chrome(ChromeState.dot, _hud));
      c.releaseHud();
      async.elapse(const Duration(milliseconds: 1200));
      expect(c.state, const Chrome(ChromeState.dot));
    });
  });

  test('a state change under the hud keeps the hud', () {
    _run((async, c, _) {
      c.showHud(_hud);
      async.elapse(const Duration(seconds: 4));
      expect(c.state, const Chrome(ChromeState.dot, _hud));
    });
  });

  test('a late showHud after releaseHud still clears after hudHold', () {
    _run((async, c, _) {
      c.hide();
      c.showHud(_hud);
      c.releaseHud();
      async.elapse(const Duration(milliseconds: 1000));
      // The last drag update resolving after the finger lifted.
      c.showHud(_hud);
      async.elapse(const Duration(milliseconds: 1199));
      expect(c.state.hud, _hud);
      async.elapse(const Duration(milliseconds: 1));
      expect(c.state, const Chrome(ChromeState.hidden));
    });
  });

  test('a new gesture after release holds the hud until its own release', () {
    _run((async, c, _) {
      c.hide();
      c.showHud(_hud);
      c.releaseHud();
      async.elapse(const Duration(milliseconds: 1000));
      c.activity();
      const next = IslandBrightnessHud(0.7, '70%');
      c.showHud(next);
      async.elapse(const Duration(seconds: 5));
      expect(c.state, const Chrome(ChromeState.hidden, next));
    });
  });

  test('a click right after a hover showed the chrome keeps it shown', () {
    _run((async, c, _) {
      c.hide();
      c.hover();
      expect(_state(c), ChromeState.expanded);
      // Moved onto the clock and clicked in one motion.
      async.elapse(const Duration(milliseconds: 299));
      c
        ..pointerDown()
        ..tap();
      expect(_state(c), ChromeState.expanded);
      // The next click toggles as usual.
      c
        ..pointerDown()
        ..tap();
      expect(_state(c), ChromeState.hidden);
    });
  });

  test('a click after the grace, or a hover over shown chrome, toggles', () {
    _run((async, c, _) {
      c.hide();
      c.hover();
      async.elapse(ChromeController.hoverGrace);
      c
        ..pointerDown()
        ..tap();
      expect(_state(c), ChromeState.hidden);
      // Already shown: a hover arms nothing, so a quick click hides it.
      c.wake();
      c.hover();
      c
        ..pointerDown()
        ..tap();
      expect(_state(c), ChromeState.hidden);
      // A touch tap with no hover toggles.
      c.tap();
      expect(_state(c), ChromeState.expanded);
    });
  });

  test('setIdle(zero) never collapses', () {
    _run((async, c, out) {
      c.setIdle(Duration.zero);
      async.elapse(const Duration(seconds: 60));
      expect(out, isEmpty);
      expect(async.pendingTimers, isEmpty);
    });
  });

  test('setIdle(2 s) collapses at 2 s', () {
    _run((async, c, _) {
      c.setIdle(const Duration(seconds: 2));
      async.elapse(const Duration(milliseconds: 1999));
      expect(_state(c), ChromeState.expanded);
      async.elapse(const Duration(milliseconds: 1));
      expect(_state(c), ChromeState.dot);
    });
  });

  test('close cancels timers; nothing is emitted after', () {
    fakeAsync((async) {
      final c = ChromeController()..wake();
      final out = <Chrome>[];
      c.stream.listen(out.add);
      c
        ..showHud(_hud)
        ..releaseHud();
      unawaited(c.close());
      async.elapse(const Duration(seconds: 30));
      expect(out, const [Chrome(ChromeState.expanded, _hud)]);
      expect(async.pendingTimers, isEmpty);
    });
  });
}
