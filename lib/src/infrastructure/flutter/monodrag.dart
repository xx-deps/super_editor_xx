import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';

/// A copy of Flutter's `DragGestureRecognizer` with public abstract methods.
///
/// Flutter's `DragGestureRecognizer` relies on private abstract methods to work. Since the
/// built-in subclasses live on the same package, they can override these methods, but we don't.
///
/// Original file: https://github.com/flutter/flutter/blob/02aaaa0bf9096fc85c76d316fec1ce2b2890fcc3/packages/flutter/lib/src/gestures/monodrag.dart
///
/// This class can be removed if https://github.com/flutter/flutter/issues/151446 is resolved.
abstract class DragGestureRecognizer extends OneSequenceGestureRecognizer {
  /// Initialize the object.
  ///
  /// {@macro flutter.gestures.GestureRecognizer.supportedDevices}
  DragGestureRecognizer({
    super.debugOwner,
    this.dragStartBehavior = DragStartBehavior.start,
    this.multitouchDragStrategy = MultitouchDragStrategy.latestPointer,
    this.velocityTrackerBuilder = _defaultBuilder,
    this.onlyAcceptDragOnThreshold = false,
    super.supportedDevices,
    AllowedButtonsFilter? allowedButtonsFilter,
  }) : super(
         allowedButtonsFilter:
             allowedButtonsFilter ?? _defaultButtonAcceptBehavior,
       );

  static VelocityTracker _defaultBuilder(PointerEvent event) =>
      VelocityTracker.withKind(event.kind);

  // Accept the input if, and only if, [kPrimaryButton] is pressed.
  static bool _defaultButtonAcceptBehavior(int buttons) =>
      buttons == kPrimaryButton;

  /// Configure the behavior of offsets passed to [onStart].
  ///
  /// If set to [DragStartBehavior.start], the [onStart] callback will be called
  /// with the position of the pointer at the time this gesture recognizer won
  /// the arena. If [DragStartBehavior.down], [onStart] will be called with
  /// the position of the first detected down event for the pointer. When there
  /// are no other gestures competing with this gesture in the arena, there's
  /// no difference in behavior between the two settings.
  ///
  /// For more information about the gesture arena:
  /// https://flutter.dev/docs/development/ui/advanced/gestures#gesture-disambiguation
  ///
  /// By default, the drag start behavior is [DragStartBehavior.start].
  ///
  /// ## Example:
  ///
  /// A [HorizontalDragGestureRecognizer] and a [VerticalDragGestureRecognizer]
  /// compete with each other. A finger presses down on the screen with
  /// offset (500.0, 500.0), and then moves to position (510.0, 500.0) before
  /// the [HorizontalDragGestureRecognizer] wins the arena. With
  /// [dragStartBehavior] set to [DragStartBehavior.down], the [onStart]
  /// callback will be called with position (500.0, 500.0). If it is
  /// instead set to [DragStartBehavior.start], [onStart] will be called with
  /// position (510.0, 500.0).
  DragStartBehavior dragStartBehavior;

  /// {@template flutter.gestures.monodrag.DragGestureRecognizer.multitouchDragStrategy}
  /// Configure the multi-finger drag strategy on multi-touch devices.
  ///
  /// If set to [MultitouchDragStrategy.latestPointer], the drag gesture recognizer
  /// will only track the latest active (accepted by this recognizer) pointer, which
  /// appears to be only one finger dragging.
  ///
  /// If set to [MultitouchDragStrategy.averageBoundaryPointers], all active
  /// pointers will be tracked, and the result is computed from the boundary pointers.
  ///
  /// If set to [MultitouchDragStrategy.sumAllPointers],
  /// all active pointers will be tracked together and the scrolling offset
  /// is the sum of the offsets of all active pointers
  /// {@endtemplate}
  ///
  /// By default, the strategy is [MultitouchDragStrategy.latestPointer].
  ///
  /// See also:
  ///
  ///  * [MultitouchDragStrategy], which defines several different drag strategies for
  ///  multi-finger drag.
  MultitouchDragStrategy multitouchDragStrategy;

  /// A pointer has contacted the screen with a primary button and might begin
  /// to move.
  ///
  /// The position of the pointer is provided in the callback's `details`
  /// argument, which is a [DragDownDetails] object.
  ///
  /// See also:
  ///
  ///  * [allowedButtonsFilter], which decides which button will be allowed.
  ///  * [DragDownDetails], which is passed as an argument to this callback.
  GestureDragDownCallback? onDown;

  /// {@template flutter.gestures.monodrag.DragGestureRecognizer.onStart}
  /// A pointer has contacted the screen with a primary button and has begun to
  /// move.
  /// {@endtemplate}
  ///
  /// The position of the pointer is provided in the callback's `details`
  /// argument, which is a [DragStartDetails] object. The [dragStartBehavior]
  /// determines this position.
  ///
  /// See also:
  ///
  ///  * [allowedButtonsFilter], which decides which button will be allowed.
  ///  * [DragStartDetails], which is passed as an argument to this callback.
  GestureDragStartCallback? onStart;

  /// {@template flutter.gestures.monodrag.DragGestureRecognizer.onUpdate}
  /// A pointer that is in contact with the screen with a primary button and
  /// moving has moved again.
  /// {@endtemplate}
  ///
  /// The distance traveled by the pointer since the last update is provided in
  /// the callback's `details` argument, which is a [DragUpdateDetails] object.
  ///
  /// If this gesture recognizer recognizes movement on a single axis (a
  /// [VerticalDragGestureRecognizer] or [HorizontalDragGestureRecognizer]),
  /// then `details` will reflect movement only on that axis and its
  /// [DragUpdateDetails.primaryDelta] will be non-null.
  /// If this gesture recognizer recognizes movement in all directions
  /// (a [PanGestureRecognizer]), then `details` will reflect movement on
  /// both axes and its [DragUpdateDetails.primaryDelta] will be null.
  ///
  /// See also:
  ///
  ///  * [allowedButtonsFilter], which decides which button will be allowed.
  ///  * [DragUpdateDetails], which is passed as an argument to this callback.
  GestureDragUpdateCallback? onUpdate;

  /// {@template flutter.gestures.monodrag.DragGestureRecognizer.onEnd}
  /// A pointer that was previously in contact with the screen with a primary
  /// button and moving is no longer in contact with the screen and was moving
  /// at a specific velocity when it stopped contacting the screen.
  /// {@endtemplate}
  ///
  /// The velocity is provided in the callback's `details` argument, which is a
  /// [DragEndDetails] object.
  ///
  /// If this gesture recognizer recognizes movement on a single axis (a
  /// [VerticalDragGestureRecognizer] or [HorizontalDragGestureRecognizer]),
  /// then `details` will reflect movement only on that axis and its
  /// [DragEndDetails.primaryVelocity] will be non-null.
  /// If this gesture recognizer recognizes movement in all directions
  /// (a [PanGestureRecognizer]), then `details` will reflect movement on
  /// both axes and its [DragEndDetails.primaryVelocity] will be null.
  ///
  /// See also:
  ///
  ///  * [allowedButtonsFilter], which decides which button will be allowed.
  ///  * [DragEndDetails], which is passed as an argument to this callback.
  GestureDragEndCallback? onEnd;

  /// The pointer that previously triggered [onDown] did not complete.
  ///
  /// See also:
  ///
  ///  * [allowedButtonsFilter], which decides which button will be allowed.
  GestureDragCancelCallback? onCancel;

  /// The minimum distance an input pointer drag must have moved
  /// to be considered a fling gesture.
  ///
  /// This value is typically compared with the distance traveled along the
  /// scrolling axis. If null then [kTouchSlop] is used.
  double? minFlingDistance;

  /// The minimum velocity for an input pointer drag to be considered fling.
  ///
  /// This value is typically compared with the magnitude of fling gesture's
  /// velocity along the scrolling axis. If null then [kMinFlingVelocity]
  /// is used.
  double? minFlingVelocity;

  /// Fling velocity magnitudes will be clamped to this value.
  ///
  /// If null then [kMaxFlingVelocity] is used.
  double? maxFlingVelocity;

  /// Whether the drag threshold should be met before dispatching any drag callbacks.
  ///
  /// The drag threshold is met when the global distance traveled by a pointer has
  /// exceeded the defined threshold on the relevant axis, i.e. y-axis for the
  /// [VerticalDragGestureRecognizer], x-axis for the [HorizontalDragGestureRecognizer],
  /// and the entire plane for [PanGestureRecognizer]. The threshold for both
  /// [VerticalDragGestureRecognizer] and [HorizontalDragGestureRecognizer] are
  /// calculated by [computeHitSlop], while [computePanSlop] is used for
  /// [PanGestureRecognizer].
  ///
  /// If true, the drag callbacks will only be dispatched when this recognizer has
  /// won the arena and the drag threshold has been met.
  ///
  /// If false, the drag callbacks will be dispatched immediately when this recognizer
  /// has won the arena.
  ///
  /// This value defaults to false.
  bool onlyAcceptDragOnThreshold;

  /// Determines the type of velocity estimation method to use for a potential
  /// drag gesture, when a new pointer is added.
  ///
  /// To estimate the velocity of a gesture, [DragGestureRecognizer] calls
  /// [velocityTrackerBuilder] when it starts to track a new pointer in
  /// [addAllowedPointer], and add subsequent updates on the pointer to the
  /// resulting velocity tracker, until the gesture recognizer stops tracking
  /// the pointer. This allows you to specify a different velocity estimation
  /// strategy for each allowed pointer added, by changing the type of velocity
  /// tracker this [GestureVelocityTrackerBuilder] returns.
  ///
  /// If left unspecified the default [velocityTrackerBuilder] creates a new
  /// [VelocityTracker] for every pointer added.
  ///
  /// See also:
  ///
  ///  * [VelocityTracker], a velocity tracker that uses least squares estimation
  ///    on the 20 most recent pointer data samples. It's a well-rounded velocity
  ///    tracker and is used by default.
  ///  * [IOSScrollViewFlingVelocityTracker], a specialized velocity tracker for
  ///    determining the initial fling velocity for a [Scrollable] on iOS, to
  ///    match the native behavior on that platform.
  GestureVelocityTrackerBuilder velocityTrackerBuilder;

  _DragState _state = _DragState.ready;
  late OffsetPair _initialPosition;
  late OffsetPair _pendingDragOffset;
  OffsetPair get finalPosition => _finalPosition;
  late OffsetPair _finalPosition;
  Duration? _lastPendingEventTimestamp;

  /// When asserts are enabled, returns the last tracked pending event timestamp
  /// for this recognizer.
  ///
  /// Otherwise, returns null.
  ///
  /// This getter is intended for use in framework unit tests. Applications must
  /// not depend on its value.
  @visibleForTesting
  Duration? get debugLastPendingEventTimestamp {
    Duration? lastPendingEventTimestamp;
    assert(() {
      lastPendingEventTimestamp = _lastPendingEventTimestamp;
      return true;
    }());
    return lastPendingEventTimestamp;
  }

  // The buttons sent by `PointerDownEvent`. If a `PointerMoveEvent` comes with a
  // different set of buttons, the gesture is canceled.
  int? _initialButtons;
  Matrix4? _lastTransform;

  /// Distance moved in the global coordinate space of the screen in drag direction.
  ///
  /// If drag is only allowed along a defined axis, this value may be negative to
  /// differentiate the direction of the drag.
  double get globalDistanceMoved => _globalDistanceMoved;
  late double _globalDistanceMoved;

  /// Determines if a gesture is a fling or not based on velocity.
  ///
  /// A fling calls its gesture end callback with a velocity, allowing the
  /// provider of the callback to respond by carrying the gesture forward with
  /// inertia, for example.
  bool isFlingGesture(VelocityEstimate estimate, PointerDeviceKind kind);

  /// Determines if a gesture is a fling or not, and if so its effective velocity.
  ///
  /// A fling calls its gesture end callback with a velocity, allowing the
  /// provider of the callback to respond by carrying the gesture forward with
  /// inertia, for example.
  DragEndDetails? considerFling(
    VelocityEstimate estimate,
    PointerDeviceKind kind,
  );

  Offset getDeltaForDetails(Offset delta);
  double? getPrimaryValueFromOffset(Offset value);

  /// The axis (horizontal or vertical) corresponding to the primary drag direction.
  ///
  /// The [PanGestureRecognizer] returns null.
  _DragDirection? _getPrimaryDragAxis() => null;
  bool hasSufficientGlobalDistanceToAccept(
    PointerDeviceKind pointerDeviceKind,
    double? deviceTouchSlop,
  );
  bool _hasDragThresholdBeenMet = false;

  final Map<int, VelocityTracker> _velocityTrackers = <int, VelocityTracker>{};

  // The move delta of each pointer before the next frame.
  //
  // The key is the pointer ID. It is cleared whenever a new batch of pointer events is detected.
  final Map<int, Offset> _moveDeltaBeforeFrame = <int, Offset>{};

  // The timestamp of all events of the current frame.
  //
  // On a event with a different timestamp, the event is considered a new batch.
  Duration? _frameTimeStamp;
  Offset _lastUpdatedDeltaForPan = Offset.zero;

  @override
  bool isPointerAllowed(PointerEvent event) {
    if (_initialButtons == null) {
      if (onDown == null &&
          onStart == null &&
          onUpdate == null &&
          onEnd == null &&
          onCancel == null) {
        return false;
      }
    } else {
      // There can be multiple drags simultaneously. Their effects are combined.
      if (event.buttons != _initialButtons) {
        return false;
      }
    }
    return super.isPointerAllowed(event as PointerDownEvent);
  }

  void _addPointer(PointerEvent event) {
    _velocityTrackers[event.pointer] = velocityTrackerBuilder(event);
    switch (_state) {
      case _DragState.ready:
        _state = _DragState.possible;
        _initialPosition = OffsetPair(
          global: event.position,
          local: event.localPosition,
        );
        _finalPosition = _initialPosition;
        _pendingDragOffset = OffsetPair.zero;
        _globalDistanceMoved = 0.0;
        _lastPendingEventTimestamp = event.timeStamp;
        _lastTransform = event.transform;
        _checkDown();
      case _DragState.possible:
        break;
      case _DragState.accepted:
        resolve(GestureDisposition.accepted);
    }
  }

  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    if (_state == _DragState.ready) {
      _initialButtons = event.buttons;
    }
    _addPointer(event);
  }

  @override
  void addAllowedPointerPanZoom(PointerPanZoomStartEvent event) {
    super.addAllowedPointerPanZoom(event);
    startTrackingPointer(event.pointer, event.transform);
    if (_state == _DragState.ready) {
      _initialButtons = kPrimaryButton;
    }
    _addPointer(event);
  }

  bool _shouldTrackMoveEvent(int pointer) {
    final bool result;
    switch (multitouchDragStrategy) {
      case MultitouchDragStrategy.sumAllPointers:
      case MultitouchDragStrategy.averageBoundaryPointers:
        result = true;
      case MultitouchDragStrategy.latestPointer:
        result = _activePointer == null || pointer == _activePointer;
    }
    return result;
  }

  void _recordMoveDeltaForMultitouch(int pointer, Offset localDelta) {
    if (multitouchDragStrategy !=
        MultitouchDragStrategy.averageBoundaryPointers) {
      assert(_frameTimeStamp == null);
      assert(_moveDeltaBeforeFrame.isEmpty);
      return;
    }

    assert(
      _frameTimeStamp == SchedulerBinding.instance.currentSystemFrameTimeStamp,
    );

    if (_state != _DragState.accepted || localDelta == Offset.zero) {
      return;
    }

    if (_moveDeltaBeforeFrame.containsKey(pointer)) {
      final Offset offset = _moveDeltaBeforeFrame[pointer]!;
      _moveDeltaBeforeFrame[pointer] = offset + localDelta;
    } else {
      _moveDeltaBeforeFrame[pointer] = localDelta;
    }
  }

  double _getSumDelta({
    required int pointer,
    required bool positive,
    required _DragDirection axis,
  }) {
    double sum = 0.0;

    if (!_moveDeltaBeforeFrame.containsKey(pointer)) {
      return sum;
    }

    final Offset offset = _moveDeltaBeforeFrame[pointer]!;
    if (positive) {
      if (axis == _DragDirection.vertical) {
        sum = max(offset.dy, 0.0);
      } else {
        sum = max(offset.dx, 0.0);
      }
    } else {
      if (axis == _DragDirection.vertical) {
        sum = min(offset.dy, 0.0);
      } else {
        sum = min(offset.dx, 0.0);
      }
    }

    return sum;
  }

  int? _getMaxSumDeltaPointer({
    required bool positive,
    required _DragDirection axis,
  }) {
    if (_moveDeltaBeforeFrame.isEmpty) {
      return null;
    }

    int? ret;
    double? max;
    double sum;
    for (final int pointer in _moveDeltaBeforeFrame.keys) {
      sum = _getSumDelta(pointer: pointer, positive: positive, axis: axis);
      if (ret == null) {
        ret = pointer;
        max = sum;
      } else {
        if (positive) {
          if (sum > max!) {
            ret = pointer;
            max = sum;
          }
        } else {
          if (sum < max!) {
            ret = pointer;
            max = sum;
          }
        }
      }
    }
    assert(ret != null);
    return ret;
  }

  Offset _resolveLocalDeltaForMultitouch(int pointer, Offset localDelta) {
    if (multitouchDragStrategy !=
        MultitouchDragStrategy.averageBoundaryPointers) {
      if (_frameTimeStamp != null) {
        _moveDeltaBeforeFrame.clear();
        _frameTimeStamp = null;
        _lastUpdatedDeltaForPan = Offset.zero;
      }
      return localDelta;
    }

    final Duration currentSystemFrameTimeStamp =
        SchedulerBinding.instance.currentSystemFrameTimeStamp;
    if (_frameTimeStamp != currentSystemFrameTimeStamp) {
      _moveDeltaBeforeFrame.clear();
      _lastUpdatedDeltaForPan = Offset.zero;
      _frameTimeStamp = currentSystemFrameTimeStamp;
    }

    assert(
      _frameTimeStamp == SchedulerBinding.instance.currentSystemFrameTimeStamp,
    );

    final _DragDirection? axis = _getPrimaryDragAxis();

    if (_state != _DragState.accepted ||
        localDelta == Offset.zero ||
        (_moveDeltaBeforeFrame.isEmpty && axis != null)) {
      return localDelta;
    }

    final double dx, dy;
    if (axis == _DragDirection.horizontal) {
      dx = _resolveDelta(
        pointer: pointer,
        axis: _DragDirection.horizontal,
        localDelta: localDelta,
      );
      assert(dx.abs() <= localDelta.dx.abs());
      dy = 0.0;
    } else if (axis == _DragDirection.vertical) {
      dx = 0.0;
      dy = _resolveDelta(
        pointer: pointer,
        axis: _DragDirection.vertical,
        localDelta: localDelta,
      );
      assert(dy.abs() <= localDelta.dy.abs());
    } else {
      final double averageX = _resolveDeltaForPanGesture(
        axis: _DragDirection.horizontal,
        localDelta: localDelta,
      );
      final double averageY = _resolveDeltaForPanGesture(
        axis: _DragDirection.vertical,
        localDelta: localDelta,
      );
      final Offset updatedDelta =
          Offset(averageX, averageY) - _lastUpdatedDeltaForPan;
      _lastUpdatedDeltaForPan = Offset(averageX, averageY);
      dx = updatedDelta.dx;
      dy = updatedDelta.dy;
    }

    return Offset(dx, dy);
  }

  double _resolveDelta({
    required int pointer,
    required _DragDirection axis,
    required Offset localDelta,
  }) {
    final bool positive = axis == _DragDirection.horizontal
        ? localDelta.dx > 0
        : localDelta.dy > 0;
    final double delta = axis == _DragDirection.horizontal
        ? localDelta.dx
        : localDelta.dy;
    final int? maxSumDeltaPointer = _getMaxSumDeltaPointer(
      positive: positive,
      axis: axis,
    );
    assert(maxSumDeltaPointer != null);

    if (maxSumDeltaPointer == pointer) {
      return delta;
    } else {
      final double maxSumDelta = _getSumDelta(
        pointer: maxSumDeltaPointer!,
        positive: positive,
        axis: axis,
      );
      final double curPointerSumDelta = _getSumDelta(
        pointer: pointer,
        positive: positive,
        axis: axis,
      );
      if (positive) {
        if (curPointerSumDelta + delta > maxSumDelta) {
          return curPointerSumDelta + delta - maxSumDelta;
        } else {
          return 0.0;
        }
      } else {
        if (curPointerSumDelta + delta < maxSumDelta) {
          return curPointerSumDelta + delta - maxSumDelta;
        } else {
          return 0.0;
        }
      }
    }
  }

  double _resolveDeltaForPanGesture({
    required _DragDirection axis,
    required Offset localDelta,
  }) {
    final double delta = axis == _DragDirection.horizontal
        ? localDelta.dx
        : localDelta.dy;
    final int pointerCount = _acceptedActivePointers.length;
    assert(pointerCount >= 1);

    double sum = delta;
    for (final Offset offset in _moveDeltaBeforeFrame.values) {
      if (axis == _DragDirection.horizontal) {
        sum += offset.dx;
      } else {
        sum += offset.dy;
      }
    }
    return sum / pointerCount;
  }

  @override
  void handleEvent(PointerEvent event) {
    assert(_state != _DragState.ready);
    if (!event.synthesized &&
        (event is PointerDownEvent ||
            event is PointerMoveEvent ||
            event is PointerPanZoomStartEvent ||
            event is PointerPanZoomUpdateEvent)) {
      final Offset position = switch (event) {
        PointerPanZoomStartEvent() => Offset.zero,
        PointerPanZoomUpdateEvent() => event.pan,
        _ => event.localPosition,
      };
      _velocityTrackers[event.pointer]!.addPosition(event.timeStamp, position);
    }
    if (event is PointerMoveEvent && event.buttons != _initialButtons) {
      _giveUpPointer(event.pointer);
      return;
    }
    if ((event is PointerMoveEvent || event is PointerPanZoomUpdateEvent) &&
        _shouldTrackMoveEvent(event.pointer)) {
      final Offset delta = (event is PointerMoveEvent)
          ? event.delta
          : (event as PointerPanZoomUpdateEvent).panDelta;
      final Offset localDelta = (event is PointerMoveEvent)
          ? event.localDelta
          : (event as PointerPanZoomUpdateEvent).localPanDelta;
      final Offset position = (event is PointerMoveEvent)
          ? event.position
          : (event.position + (event as PointerPanZoomUpdateEvent).pan);
      final Offset localPosition = (event is PointerMoveEvent)
          ? event.localPosition
          : (event.localPosition +
                (event as PointerPanZoomUpdateEvent).localPan);
      _finalPosition = OffsetPair(local: localPosition, global: position);
      final Offset resolvedDelta = _resolveLocalDeltaForMultitouch(
        event.pointer,
        localDelta,
      );
      switch (_state) {
        case _DragState.ready || _DragState.possible:
          _pendingDragOffset += OffsetPair(local: localDelta, global: delta);
          _lastPendingEventTimestamp = event.timeStamp;
          _lastTransform = event.transform;
          final Offset movedLocally = getDeltaForDetails(localDelta);
          final Matrix4? localToGlobalTransform = event.transform == null
              ? null
              : Matrix4.tryInvert(event.transform!);
          _globalDistanceMoved +=
              PointerEvent.transformDeltaViaPositions(
                transform: localToGlobalTransform,
                untransformedDelta: movedLocally,
                untransformedEndPosition: localPosition,
              ).distance *
              (getPrimaryValueFromOffset(movedLocally) ?? 1).sign;
          if (hasSufficientGlobalDistanceToAccept(
            event.kind,
            gestureSettings?.touchSlop,
          )) {
            _hasDragThresholdBeenMet = true;
            if (_acceptedActivePointers.contains(event.pointer)) {
              _checkDrag(event.pointer);
            } else {
              resolve(GestureDisposition.accepted);
            }
          }
        case _DragState.accepted:
          _checkUpdate(
            sourceTimeStamp: event.timeStamp,
            delta: getDeltaForDetails(resolvedDelta),
            primaryDelta: getPrimaryValueFromOffset(resolvedDelta),
            globalPosition: position,
            localPosition: localPosition,
          );
      }
      _recordMoveDeltaForMultitouch(event.pointer, localDelta);
    }
    if (event
        case PointerUpEvent() ||
            PointerCancelEvent() ||
            PointerPanZoomEndEvent()) {
      _giveUpPointer(event.pointer);
    }
  }

  final List<int> _acceptedActivePointers = <int>[];
  // This value is used when the multitouch strategy is `latestPointer`,
  // it keeps track of the last accepted pointer. If this active pointer
  // leave up, it will be set to the first accepted pointer.
  // Refer to the implementation of Android `RecyclerView`(line 3846):
  // https://android.googlesource.com/platform/frameworks/support/+/refs/heads/androidx-main/recyclerview/recyclerview/src/main/java/androidx/recyclerview/widget/RecyclerView.java
  int? _activePointer;

  @override
  void acceptGesture(int pointer) {
    assert(!_acceptedActivePointers.contains(pointer));
    _acceptedActivePointers.add(pointer);
    _activePointer = pointer;
    if (!onlyAcceptDragOnThreshold || _hasDragThresholdBeenMet) {
      _checkDrag(pointer);
    }
  }

  @override
  void rejectGesture(int pointer) {
    _giveUpPointer(pointer);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    assert(_state != _DragState.ready);
    switch (_state) {
      case _DragState.ready:
        break;

      case _DragState.possible:
        resolve(GestureDisposition.rejected);
        _checkCancel();

      case _DragState.accepted:
        _checkEnd(pointer);
    }
    _hasDragThresholdBeenMet = false;
    _velocityTrackers.clear();
    _initialButtons = null;
    _state = _DragState.ready;
  }

  void _giveUpPointer(int pointer) {
    stopTrackingPointer(pointer);
    // If we never accepted the pointer, we reject it since we are no longer
    // interested in winning the gesture arena for it.
    if (!_acceptedActivePointers.remove(pointer)) {
      resolvePointer(pointer, GestureDisposition.rejected);
    }

    _moveDeltaBeforeFrame.remove(pointer);
    if (_activePointer == pointer) {
      _activePointer = _acceptedActivePointers.isNotEmpty
          ? _acceptedActivePointers.first
          : null;
    }
  }

  void _checkDown() {
    if (onDown != null) {
      final DragDownDetails details = DragDownDetails(
        globalPosition: _initialPosition.global,
        localPosition: _initialPosition.local,
      );
      invokeCallback<void>('onDown', () => onDown!(details));
    }
  }

  void _checkDrag(int pointer) {
    if (_state == _DragState.accepted) {
      return;
    }
    _state = _DragState.accepted;
    final OffsetPair delta = _pendingDragOffset;
    final Duration? timestamp = _lastPendingEventTimestamp;
    final Matrix4? transform = _lastTransform;
    final Offset localUpdateDelta;
    switch (dragStartBehavior) {
      case DragStartBehavior.start:
        _initialPosition = _initialPosition + delta;
        localUpdateDelta = Offset.zero;
      case DragStartBehavior.down:
        localUpdateDelta = getDeltaForDetails(delta.local);
    }
    _pendingDragOffset = OffsetPair.zero;
    _lastPendingEventTimestamp = null;
    _lastTransform = null;
    _checkStart(timestamp, pointer);
    if (localUpdateDelta != Offset.zero && onUpdate != null) {
      final Matrix4? localToGlobal = transform != null
          ? Matrix4.tryInvert(transform)
          : null;
      final Offset correctedLocalPosition =
          _initialPosition.local + localUpdateDelta;
      final Offset globalUpdateDelta = PointerEvent.transformDeltaViaPositions(
        untransformedEndPosition: correctedLocalPosition,
        untransformedDelta: localUpdateDelta,
        transform: localToGlobal,
      );
      final OffsetPair updateDelta = OffsetPair(
        local: localUpdateDelta,
        global: globalUpdateDelta,
      );
      final OffsetPair correctedPosition =
          _initialPosition + updateDelta; // Only adds delta for down behaviour
      _checkUpdate(
        sourceTimeStamp: timestamp,
        delta: localUpdateDelta,
        primaryDelta: getPrimaryValueFromOffset(localUpdateDelta),
        globalPosition: correctedPosition.global,
        localPosition: correctedPosition.local,
      );
    }
    // This acceptGesture might have been called only for one pointer, instead
    // of all pointers. Resolve all pointers to `accepted`. This won't cause
    // infinite recursion because an accepted pointer won't be accepted again.
    resolve(GestureDisposition.accepted);
  }

  void _checkStart(Duration? timestamp, int pointer) {
    if (onStart != null) {
      final DragStartDetails details = DragStartDetails(
        sourceTimeStamp: timestamp,
        globalPosition: _initialPosition.global,
        localPosition: _initialPosition.local,
        kind: getKindForPointer(pointer),
      );
      invokeCallback<void>('onStart', () => onStart!(details));
    }
  }

  void _checkUpdate({
    Duration? sourceTimeStamp,
    required Offset delta,
    double? primaryDelta,
    required Offset globalPosition,
    Offset? localPosition,
  }) {
    if (onUpdate != null) {
      final DragUpdateDetails details = DragUpdateDetails(
        sourceTimeStamp: sourceTimeStamp,
        delta: delta,
        primaryDelta: primaryDelta,
        globalPosition: globalPosition,
        localPosition: localPosition,
      );
      invokeCallback<void>('onUpdate', () => onUpdate!(details));
    }
  }

  void _checkEnd(int pointer) {
    if (onEnd == null) {
      return;
    }

    final VelocityTracker tracker = _velocityTrackers[pointer]!;
    final VelocityEstimate? estimate = tracker.getVelocityEstimate();

    DragEndDetails? details;
    final String Function() debugReport;
    if (estimate == null) {
      debugReport = () => 'Could not estimate velocity.';
    } else {
      details = considerFling(estimate, tracker.kind);
      debugReport = (details != null)
          ? () => '$estimate; fling at ${details!.velocity}.'
          : () => '$estimate; judged to not be a fling.';
    }
    details ??= DragEndDetails(
      primaryVelocity: 0.0,
      globalPosition: _finalPosition.global,
      localPosition: _finalPosition.local,
    );

    invokeCallback<void>(
      'onEnd',
      () => onEnd!(details!),
      debugReport: debugReport,
    );
  }

  void _checkCancel() {
    if (onCancel != null) {
      invokeCallback<void>('onCancel', onCancel!);
    }
  }

  @override
  void dispose() {
    _velocityTrackers.clear();
    super.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      EnumProperty<DragStartBehavior>('start behavior', dragStartBehavior),
    );
  }
}

enum _DragState { ready, possible, accepted }

enum _DragDirection { horizontal, vertical }
