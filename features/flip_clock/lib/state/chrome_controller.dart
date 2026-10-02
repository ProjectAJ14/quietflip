import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';

/// What the chrome shows: how much of it, and an optional HUD over it.
@immutable
class Chrome {
  const Chrome(this.state, [this.hud]);

  /// Hidden, a dot, or the full controls.
  final ChromeState state;

  /// A readout shown during a gesture; [state] is what returns after it.
  final IslandHud? hud;

  @override
  bool operator ==(Object other) =>
      other is Chrome && other.state == state && other.hud == hud;

  @override
  int get hashCode => Object.hash(state, hud);
}

/// Shows and collapses the chrome: expanded -> dot after [idle], dot ->
/// hidden after `dotIdle` more; a hidden chrome has no timer. Starts
/// hidden, so launch shows the clock alone until a tap, hover or key. An
/// [idle] of [Duration.zero] never collapses.
class ChromeController extends Cubit<Chrome> {
  ChromeController({
    Duration idle = DesignMotion.controlsIdle,
    Duration dotIdle = DesignMotion.dotIdle,
    Duration hudHold = DesignMotion.hudHold,
  }) : _idle = idle,
       _dotIdle = dotIdle,
       _hudHold = hudHold,
       super(const Chrome(ChromeState.hidden));

  Duration _idle;
  final Duration _dotIdle;
  final Duration _hudHold;
  Timer? _idleTimer;
  Timer? _hudTimer;

  /// A click this soon after a hover showed the chrome keeps it shown:
  /// the person moved the mouse to the clock and clicked in one motion.
  static const Duration hoverGrace = Duration(milliseconds: 300);

  /// Running for [hoverGrace] after a hover showed the chrome.
  Timer? _hoverWoke;

  /// The press under way began inside [hoverGrace], so its tap is ignored.
  bool _keepNextTap = false;

  /// The gesture behind the HUD has ended; a late [showHud] (an async
  /// brightness change landing after the finger lifted) must not keep it.
  bool _released = false;

  /// Any pointer event or gesture: restarts the idle timer, same state. A
  /// new gesture holds the HUD again until its own release.
  void activity() {
    _released = false;
    _restartIdle();
  }

  /// Any key: shows the controls.
  void wake() => _set(ChromeState.expanded);

  /// A pointer hover on desktop: shows the controls; a click right after
  /// (within [hoverGrace]) does not hide them again.
  void hover() {
    if (state.state == ChromeState.expanded) return;
    _hoverWoke?.cancel();
    _hoverWoke = Timer(hoverGrace, () {});
    wake();
  }

  /// A pointer went down: [activity], and remembers whether it is the first
  /// press within [hoverGrace] of a hover that showed the chrome.
  void pointerDown() {
    // Only the first press after the hover is spared.
    _keepNextTap = _hoverWoke?.isActive ?? false;
    _hoverWoke?.cancel();
    activity();
  }

  /// A tap: hidden or dot -> expanded; expanded -> hidden, unless the press
  /// began right after a hover showed the chrome.
  void tap() {
    if (_keepNextTap) {
      _keepNextTap = false;
      return;
    }
    _set(
      state.state == ChromeState.expanded
          ? ChromeState.hidden
          : ChromeState.expanded,
    );
  }

  /// Esc: hides the chrome now.
  void hide() => _set(ChromeState.hidden);

  /// During a gesture: shows [hud] over the current state. After
  /// [releaseHud] it re-arms the hold instead, so the HUD still goes.
  void showHud(IslandHud hud) {
    if (_released) {
      _armRelease();
    } else {
      _hudTimer?.cancel();
    }
    emit(Chrome(state.state, hud));
    _restartIdle();
  }

  /// The gesture ended: the HUD goes after `hudHold`, back to the state
  /// underneath.
  void releaseHud() {
    _released = true;
    _armRelease();
  }

  void _armRelease() {
    _hudTimer?.cancel();
    _hudTimer = Timer(_hudHold, () {
      if (!isClosed) emit(Chrome(state.state));
    });
  }

  /// The idle setting changed.
  void setIdle(Duration idle) {
    _idle = idle;
    _restartIdle();
  }

  void _set(ChromeState next) {
    emit(Chrome(next, state.hud));
    _restartIdle();
  }

  void _restartIdle() {
    _idleTimer?.cancel();
    _idleTimer = null;
    if (_idle == Duration.zero) return;
    final step = switch (state.state) {
      ChromeState.expanded => (_idle, ChromeState.dot),
      ChromeState.dot => (_dotIdle, ChromeState.hidden),
      ChromeState.hidden => null,
    };
    if (step == null) return;
    final (after, next) = step;
    _idleTimer = Timer(after, () {
      if (isClosed) return;
      _set(next);
    });
  }

  @override
  Future<void> close() {
    _idleTimer?.cancel();
    _hudTimer?.cancel();
    _hoverWoke?.cancel();
    return super.close();
  }
}
