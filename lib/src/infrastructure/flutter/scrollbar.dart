import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

const double _kMinThumbExtent = 18.0;
const double _kMinInteractiveSize = 48.0;
const double _kScrollbarThickness = 6.0;
const Duration _kScrollbarFadeDuration = Duration(milliseconds: 300);
const Duration _kScrollbarTimeToFade = Duration(milliseconds: 600);

/// A copy of Flutter [RawScrollbar] with a configurable [ScrollPhysics].
///
/// Usually, the scrollbar uses the same [ScrollPhysics] from its [ScrollPosition].
/// Therefore, when using [NeverScrollableScrollPhysics], the user is prevented
/// from interacting with the scrollbar.
///
/// By using this widget, an app can use [NeverScrollableScrollPhysics], for example,
/// to prevent scrolling by drag, and still let users interact with the scrollbar.
class RawScrollbarWithCustomPhysics extends StatefulWidget {
  /// Creates a basic raw scrollbar that wraps the given [child].
  ///
  /// The [child], or a descendant of the [child], should be a source of
  /// [ScrollNotification] notifications, typically a [Scrollable] widget.
  const RawScrollbarWithCustomPhysics({
    super.key,
    required this.physics,
    required this.child,
    this.controller,
    this.thumbVisibility,
    this.shape,
    this.radius,
    this.thickness,
    this.thumbColor,
    this.minThumbLength = _kMinThumbExtent,
    this.minOverscrollLength,
    this.trackVisibility,
    this.trackRadius,
    this.trackColor,
    this.trackBorderColor,
    this.fadeDuration = _kScrollbarFadeDuration,
    this.timeToFade = _kScrollbarTimeToFade,
    this.pressDuration = Duration.zero,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.interactive,
    this.scrollbarOrientation,
    this.mainAxisMargin = 0.0,
    this.crossAxisMargin = 0.0,
    this.padding,
  }) : assert(
         !(thumbVisibility == false && (trackVisibility ?? false)),
         'A scrollbar track cannot be drawn without a scrollbar thumb.',
       ),
       assert(minThumbLength >= 0),
       assert(
         minOverscrollLength == null || minOverscrollLength <= minThumbLength,
       ),
       assert(minOverscrollLength == null || minOverscrollLength >= 0),
       assert(radius == null || shape == null);

  /// {@template flutter.widgets.Scrollbar.child}
  /// The widget below this widget in the tree.
  ///
  /// The scrollbar will be stacked on top of this child. This child (and its
  /// subtree) should include a source of [ScrollNotification] notifications.
  /// Typically a [Scrollbar] is created on desktop platforms by a
  /// [ScrollBehavior.buildScrollbar] method, in which case the child is usually
  /// the one provided as an argument to that method.
  ///
  /// Typically a [ListView] or [CustomScrollView].
  /// {@endtemplate}
  final Widget child;

  /// {@template flutter.widgets.Scrollbar.controller}
  /// The [ScrollController] used to implement Scrollbar dragging.
  ///
  /// If nothing is passed to controller, the default behavior is to automatically
  /// enable scrollbar dragging on the nearest ScrollController using
  /// [PrimaryScrollController.of].
  ///
  /// If a ScrollController is passed, then dragging on the scrollbar thumb will
  /// update the [ScrollPosition] attached to the controller. A stateful ancestor
  /// of this widget needs to manage the ScrollController and either pass it to
  /// a scrollable descendant or use a PrimaryScrollController to share it.
  ///
  /// {@tool snippet}
  /// Here is an example of using the [controller] attribute to enable
  /// scrollbar dragging for multiple independent ListViews:
  ///
  /// ```dart
  /// // (e.g. in a stateful widget)
  ///
  /// final ScrollController controllerOne = ScrollController();
  /// final ScrollController controllerTwo = ScrollController();
  ///
  /// @override
  /// Widget build(BuildContext context) {
  ///   return Column(
  ///     children: <Widget>[
  ///       SizedBox(
  ///        height: 200,
  ///        child: CupertinoScrollbar(
  ///          controller: controllerOne,
  ///          child: ListView.builder(
  ///            controller: controllerOne,
  ///            itemCount: 120,
  ///            itemBuilder: (BuildContext context, int index) => Text('item $index'),
  ///          ),
  ///        ),
  ///      ),
  ///      SizedBox(
  ///        height: 200,
  ///        child: CupertinoScrollbar(
  ///          controller: controllerTwo,
  ///          child: ListView.builder(
  ///            controller: controllerTwo,
  ///            itemCount: 120,
  ///            itemBuilder: (BuildContext context, int index) => Text('list 2 item $index'),
  ///          ),
  ///        ),
  ///      ),
  ///    ],
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  /// {@endtemplate}
  final ScrollController? controller;

  final ScrollPhysics physics;

  /// {@template flutter.widgets.Scrollbar.thumbVisibility}
  /// Indicates that the scrollbar thumb should be visible, even when a scroll
  /// is not underway.
  ///
  /// When false, the scrollbar will be shown during scrolling
  /// and will fade out otherwise.
  ///
  /// When true, the scrollbar will always be visible and never fade out. This
  /// requires that the Scrollbar can access the [ScrollController] of the
  /// associated Scrollable widget. This can either be the provided [controller],
  /// or the [PrimaryScrollController] of the current context.
  ///
  ///   * When providing a controller, the same ScrollController must also be
  ///     provided to the associated Scrollable widget.
  ///   * The [PrimaryScrollController] is used by default for a [ScrollView]
  ///     that has not been provided a [ScrollController] and that has a
  ///     [ScrollView.scrollDirection] of [Axis.vertical]. This automatic
  ///     behavior does not apply to those with [Axis.horizontal]. To explicitly
  ///     use the PrimaryScrollController, set [ScrollView.primary] to true.
  ///
  /// Defaults to false when null.
  ///
  /// {@tool snippet}
  ///
  /// ```dart
  /// // (e.g. in a stateful widget)
  ///
  /// final ScrollController controllerOne = ScrollController();
  /// final ScrollController controllerTwo = ScrollController();
  ///
  /// @override
  /// Widget build(BuildContext context) {
  /// return Column(
  ///   children: <Widget>[
  ///     SizedBox(
  ///        height: 200,
  ///        child: Scrollbar(
  ///          thumbVisibility: true,
  ///          controller: controllerOne,
  ///          child: ListView.builder(
  ///            controller: controllerOne,
  ///            itemCount: 120,
  ///            itemBuilder: (BuildContext context, int index) {
  ///              return Text('item $index');
  ///            },
  ///          ),
  ///        ),
  ///      ),
  ///      SizedBox(
  ///        height: 200,
  ///        child: CupertinoScrollbar(
  ///          thumbVisibility: true,
  ///          controller: controllerTwo,
  ///          child: SingleChildScrollView(
  ///            controller: controllerTwo,
  ///            child: const SizedBox(
  ///              height: 2000,
  ///              width: 500,
  ///              child: Placeholder(),
  ///            ),
  ///          ),
  ///        ),
  ///      ),
  ///    ],
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///   * [RawScrollbarWithCustomPhysicsState.showScrollbar], an overridable getter which uses
  ///     this value to override the default behavior.
  ///   * [ScrollView.primary], which indicates whether the ScrollView is the primary
  ///     scroll view associated with the parent [PrimaryScrollController].
  ///   * [PrimaryScrollController], which associates a [ScrollController] with
  ///     a subtree.
  /// {@endtemplate}
  ///
  /// Subclass [Scrollbar] can hide and show the scrollbar thumb in response to
  /// [MaterialState]s by using [ScrollbarThemeData.thumbVisibility].
  final bool? thumbVisibility;

  /// The [OutlinedBorder] of the scrollbar's thumb.
  ///
  /// Only one of [radius] and [shape] may be specified. For a rounded rectangle,
  /// it's simplest to just specify [radius]. By default, the scrollbar thumb's
  /// shape is a simple rectangle.
  ///
  /// If [shape] is specified, the thumb will take the shape of the passed
  /// [OutlinedBorder] and fill itself with [thumbColor] (or grey if it
  /// is unspecified).
  ///
  /// {@tool dartpad}
  /// This is an example of using a [StadiumBorder] for drawing the [shape] of the
  /// thumb in a [RawScrollbarWithCustomPhysics].
  ///
  /// ** See code in examples/api/lib/widgets/scrollbar/raw_scrollbar.shape.0.dart **
  /// {@end-tool}
  final OutlinedBorder? shape;

  /// The [Radius] of the scrollbar thumb's rounded rectangle corners.
  ///
  /// Scrollbar will be rectangular if [radius] is null, which is the default
  /// behavior.
  final Radius? radius;

  /// The thickness of the scrollbar in the cross axis of the scrollable.
  ///
  /// If null, will default to 6.0 pixels.
  final double? thickness;

  /// The color of the scrollbar thumb.
  ///
  /// If null, defaults to Color(0x66BCBCBC).
  final Color? thumbColor;

  /// The preferred smallest size the scrollbar thumb can shrink to when the total
  /// scrollable extent is large, the current visible viewport is small, and the
  /// viewport is not overscrolled.
  ///
  /// The size of the scrollbar's thumb may shrink to a smaller size than [minThumbLength]
  /// to fit in the available paint area (e.g., when [minThumbLength] is greater
  /// than [ScrollMetrics.viewportDimension] and [mainAxisMargin] combined).
  ///
  /// Mustn't be null and the value has to be greater or equal to
  /// [minOverscrollLength], which in turn is >= 0. Defaults to 18.0.
  final double minThumbLength;

  /// The preferred smallest size the scrollbar thumb can shrink to when viewport is
  /// overscrolled.
  ///
  /// When overscrolling, the size of the scrollbar's thumb may shrink to a smaller size
  /// than [minOverscrollLength] to fit in the available paint area (e.g., when
  /// [minOverscrollLength] is greater than [ScrollMetrics.viewportDimension] and
  /// [mainAxisMargin] combined).
  ///
  /// Overscrolling can be made possible by setting the `physics` property
  /// of the `child` Widget to a `BouncingScrollPhysics`, which is a special
  /// `ScrollPhysics` that allows overscrolling.
  ///
  /// The value is less than or equal to [minThumbLength] and greater than or equal to 0.
  /// When null, it will default to the value of [minThumbLength].
  final double? minOverscrollLength;

  /// {@template flutter.widgets.Scrollbar.trackVisibility}
  /// Indicates that the scrollbar track should be visible.
  ///
  /// When true, the scrollbar track will always be visible so long as the thumb
  /// is visible. If the scrollbar thumb is not visible, the track will not be
  /// visible either.
  ///
  /// Defaults to false when null.
  /// {@endtemplate}
  ///
  /// Subclass [Scrollbar] can hide and show the scrollbar thumb in response to
  /// [MaterialState]s by using [ScrollbarThemeData.trackVisibility].
  final bool? trackVisibility;

  /// The [Radius] of the scrollbar track's rounded rectangle corners.
  ///
  /// Scrollbar's track will be rectangular if [trackRadius] is null, which is
  /// the default behavior.
  final Radius? trackRadius;

  /// The color of the scrollbar track.
  ///
  /// The scrollbar track will only be visible when [trackVisibility] and
  /// [thumbVisibility] are true.
  ///
  /// If null, defaults to Color(0x08000000).
  final Color? trackColor;

  /// The color of the scrollbar track's border.
  ///
  /// The scrollbar track will only be visible when [trackVisibility] and
  /// [thumbVisibility] are true.
  ///
  /// If null, defaults to Color(0x1a000000).
  final Color? trackBorderColor;

  /// The [Duration] of the fade animation.
  ///
  /// Defaults to a [Duration] of 300 milliseconds.
  final Duration fadeDuration;

  /// The [Duration] of time until the fade animation begins.
  ///
  /// Defaults to a [Duration] of 600 milliseconds.
  final Duration timeToFade;

  /// The [Duration] of time that a LongPress will trigger the drag gesture of
  /// the scrollbar thumb.
  ///
  /// Defaults to [Duration.zero].
  final Duration pressDuration;

  /// {@template flutter.widgets.Scrollbar.notificationPredicate}
  /// A check that specifies whether a [ScrollNotification] should be
  /// handled by this widget.
  ///
  /// By default, checks whether `notification.depth == 0`. That means if the
  /// scrollbar is wrapped around multiple [ScrollView]s, it only responds to the
  /// nearest scrollView and shows the corresponding scrollbar thumb.
  /// {@endtemplate}
  final ScrollNotificationPredicate notificationPredicate;

  /// {@template flutter.widgets.Scrollbar.interactive}
  /// Whether the Scrollbar should be interactive and respond to dragging on the
  /// thumb, or tapping in the track area.
  ///
  /// Does not apply to the [CupertinoScrollbar], which is always interactive to
  /// match native behavior. On Android, the scrollbar is not interactive by
  /// default.
  ///
  /// When false, the scrollbar will not respond to gesture or hover events,
  /// and will allow to click through it.
  ///
  /// Defaults to true when null, unless on Android, which will default to false
  /// when null.
  ///
  /// See also:
  ///
  ///   * [RawScrollbarWithCustomPhysicsState.enableGestures], an overridable getter which uses
  ///     this value to override the default behavior.
  /// {@endtemplate}
  final bool? interactive;

  /// {@macro flutter.widgets.Scrollbar.scrollbarOrientation}
  final ScrollbarOrientation? scrollbarOrientation;

  /// Distance from the scrollbar thumb's start or end to the nearest edge of
  /// the viewport in logical pixels. It affects the amount of available
  /// paint area.
  ///
  /// The scrollbar track consumes this space.
  ///
  /// Mustn't be null and defaults to 0.
  final double mainAxisMargin;

  /// Distance from the scrollbar thumb's side to the nearest cross axis edge
  /// in logical pixels.
  ///
  /// The scrollbar track consumes this space.
  ///
  /// Defaults to zero.
  final double crossAxisMargin;

  /// The insets by which the scrollbar thumb and track should be padded.
  ///
  /// When null, the inherited [MediaQueryData.padding] is used.
  ///
  /// Defaults to null.
  final EdgeInsets? padding;

  @override
  RawScrollbarWithCustomPhysicsState<RawScrollbarWithCustomPhysics>
  createState() =>
      RawScrollbarWithCustomPhysicsState<RawScrollbarWithCustomPhysics>();
}

/// The state for a [RawScrollbarWithCustomPhysics] widget, also shared by the [Scrollbar] and
/// [CupertinoScrollbar] widgets.
///
/// Controls the animation that fades a scrollbar's thumb in and out of view.
///
/// Provides defaults gestures for dragging the scrollbar thumb and tapping on the
/// scrollbar track.
class RawScrollbarWithCustomPhysicsState<
  T extends RawScrollbarWithCustomPhysics
>
    extends State<T>
    with TickerProviderStateMixin<T> {
  Offset? _startDragScrollbarAxisOffset;
  Offset? _lastDragUpdateOffset;
  double? _startDragThumbOffset;
  ScrollController? _cachedController;
  Timer? _fadeoutTimer;
  late AnimationController _fadeoutAnimationController;
  late Animation<double> _fadeoutOpacityAnimation;
  final GlobalKey _scrollbarPainterKey = GlobalKey();
  bool _hoverIsActive = false;
  bool _thumbDragging = false;
  bool _isHoveringThumb = false;

  ScrollController? get _effectiveScrollController =>
      widget.controller ?? PrimaryScrollController.maybeOf(context);

  /// Used to paint the scrollbar.
  ///
  /// Can be customized by subclasses to change scrollbar behavior by overriding
  /// [updateScrollbarPainter].
  @protected
  late final ScrollbarPainter scrollbarPainter;

  /// Overridable getter to indicate that the scrollbar should be visible, even
  /// when a scroll is not underway.
  ///
  /// Subclasses can override this getter to make its value depend on an inherited
  /// theme.
  ///
  /// Defaults to false when [RawScrollbarWithCustomPhysics.thumbVisibility] is null.
  @protected
  bool get showScrollbar => widget.thumbVisibility ?? false;

  bool get _showTrack => showScrollbar && (widget.trackVisibility ?? false);

  /// Overridable getter to indicate is gestures should be enabled on the
  /// scrollbar.
  ///
  /// When false, the scrollbar will not respond to gesture or hover events,
  /// and will allow to click through it.
  ///
  /// Subclasses can override this getter to make its value depend on an inherited
  /// theme.
  ///
  /// Defaults to true when [RawScrollbarWithCustomPhysics.interactive] is null.
  ///
  /// See also:
  ///
  ///   * [RawScrollbarWithCustomPhysics.interactive], which overrides the default behavior.
  @protected
  bool get enableGestures => widget.interactive ?? true;

  @override
  void initState() {
    super.initState();
    _fadeoutAnimationController = AnimationController(
      vsync: this,
      duration: widget.fadeDuration,
    )..addStatusListener(_validateInteractions);
    _fadeoutOpacityAnimation = CurvedAnimation(
      parent: _fadeoutAnimationController,
      curve: Curves.fastOutSlowIn,
    );
    scrollbarPainter = ScrollbarPainter(
      color: widget.thumbColor ?? const Color(0x66BCBCBC),
      fadeoutOpacityAnimation: _fadeoutOpacityAnimation,
      thickness: widget.thickness ?? _kScrollbarThickness,
      radius: widget.radius,
      trackRadius: widget.trackRadius,
      scrollbarOrientation: widget.scrollbarOrientation,
      mainAxisMargin: widget.mainAxisMargin,
      shape: widget.shape,
      crossAxisMargin: widget.crossAxisMargin,
      minLength: widget.minThumbLength,
      minOverscrollLength: widget.minOverscrollLength ?? widget.minThumbLength,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    assert(_debugScheduleCheckHasValidScrollPosition());
  }

  bool _debugScheduleCheckHasValidScrollPosition() {
    if (!showScrollbar) {
      return true;
    }
    WidgetsBinding.instance.addPostFrameCallback((Duration duration) {
      assert(_debugCheckHasValidScrollPosition());
    });
    return true;
  }

  void _validateInteractions(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      assert(_fadeoutOpacityAnimation.value == 0.0);
      // We do not check for a valid scroll position if the scrollbar is not
      // visible, because it cannot be interacted with.
    } else if (_effectiveScrollController != null && enableGestures) {
      // Interactive scrollbars need to be properly configured. If it is visible
      // for interaction, ensure we are set up properly.
      assert(_debugCheckHasValidScrollPosition());
    }
  }

  bool _debugCheckHasValidScrollPosition() {
    if (!mounted) {
      return true;
    }
    final ScrollController? scrollController = _effectiveScrollController;
    final bool tryPrimary = widget.controller == null;
    final String controllerForError = tryPrimary
        ? 'PrimaryScrollController'
        : 'provided ScrollController';

    String when = '';
    if (widget.thumbVisibility ?? false) {
      when = 'Scrollbar.thumbVisibility is true';
    } else if (enableGestures) {
      when = 'the scrollbar is interactive';
    } else {
      when = 'using the Scrollbar';
    }

    assert(
      scrollController != null,
      'A ScrollController is required when $when. '
      '${tryPrimary ? 'The Scrollbar was not provided a ScrollController, '
                'and attempted to use the PrimaryScrollController, but none was found.' : ''}',
    );
    assert(() {
      if (!scrollController!.hasClients) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            "The Scrollbar's ScrollController has no ScrollPosition attached.",
          ),
          ErrorDescription(
            'A Scrollbar cannot be painted without a ScrollPosition. ',
          ),
          ErrorHint(
            'The Scrollbar attempted to use the $controllerForError. This '
            'ScrollController should be associated with the ScrollView that '
            'the Scrollbar is being applied to.'
            '${tryPrimary ? 'When ScrollView.scrollDirection is Axis.vertical on mobile '
                      'platforms will automatically use the '
                      'PrimaryScrollController if the user has not provided a '
                      'ScrollController. To use the PrimaryScrollController '
                      'explicitly, set ScrollView.primary to true for the Scrollable '
                      'widget.' : 'When providing your own ScrollController, ensure both the '
                      'Scrollbar and the Scrollable widget use the same one.'}',
          ),
        ]);
      }
      return true;
    }());
    assert(() {
      try {
        scrollController!.position;
      } catch (error) {
        if (scrollController == null ||
            scrollController.positions.length <= 1) {
          rethrow;
        }
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            'The $controllerForError is currently attached to more than one '
            'ScrollPosition.',
          ),
          ErrorDescription(
            'The Scrollbar requires a single ScrollPosition in order to be painted.',
          ),
          ErrorHint(
            'When $when, the associated ScrollController must only have one '
            'ScrollPosition attached.'
            '${tryPrimary ? 'If a ScrollController has not been provided, the '
                      'PrimaryScrollController is used by default on mobile platforms '
                      'for ScrollViews with an Axis.vertical scroll direction. More '
                      'than one ScrollView may have tried to use the '
                      'PrimaryScrollController of the current context. '
                      'ScrollView.primary can override this behavior.' : 'The provided ScrollController must be unique to one '
                      'ScrollView widget.'}',
          ),
        ]);
      }
      return true;
    }());
    return true;
  }

  /// This method is responsible for configuring the [scrollbarPainter]
  /// according to the [widget]'s properties and any inherited widgets the
  /// painter depends on, like [Directionality] and [MediaQuery].
  ///
  /// Subclasses can override to configure the [scrollbarPainter].
  @protected
  void updateScrollbarPainter() {
    scrollbarPainter
      ..color = widget.thumbColor ?? const Color(0x66BCBCBC)
      ..trackRadius = widget.trackRadius
      ..trackColor = _showTrack
          ? widget.trackColor ?? const Color(0x08000000)
          : const Color(0x00000000)
      ..trackBorderColor = _showTrack
          ? widget.trackBorderColor ?? const Color(0x1a000000)
          : const Color(0x00000000)
      ..textDirection = Directionality.of(context)
      ..thickness = widget.thickness ?? _kScrollbarThickness
      ..radius = widget.radius
      ..padding = widget.padding ?? MediaQuery.paddingOf(context)
      ..scrollbarOrientation = widget.scrollbarOrientation
      ..mainAxisMargin = widget.mainAxisMargin
      ..shape = widget.shape
      ..crossAxisMargin = widget.crossAxisMargin
      ..minLength = widget.minThumbLength
      ..minOverscrollLength =
          widget.minOverscrollLength ?? widget.minThumbLength
      ..ignorePointer = !enableGestures;
  }

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.thumbVisibility != oldWidget.thumbVisibility) {
      if (widget.thumbVisibility ?? false) {
        assert(_debugScheduleCheckHasValidScrollPosition());
        _fadeoutTimer?.cancel();
        _fadeoutAnimationController.animateTo(1.0);
      } else {
        _fadeoutAnimationController.reverse();
      }
    }
  }

  void _updateScrollPosition(Offset updatedOffset) {
    assert(_cachedController != null);
    assert(_startDragScrollbarAxisOffset != null);
    assert(_lastDragUpdateOffset != null);
    assert(_startDragThumbOffset != null);

    final ScrollPosition position = _cachedController!.position;
    late double primaryDeltaFromDragStart;
    late double primaryDeltaFromLastDragUpdate;
    switch (position.axisDirection) {
      case AxisDirection.up:
        primaryDeltaFromDragStart =
            _startDragScrollbarAxisOffset!.dy - updatedOffset.dy;
        primaryDeltaFromLastDragUpdate =
            _lastDragUpdateOffset!.dy - updatedOffset.dy;
      case AxisDirection.right:
        primaryDeltaFromDragStart =
            updatedOffset.dx - _startDragScrollbarAxisOffset!.dx;
        primaryDeltaFromLastDragUpdate =
            updatedOffset.dx - _lastDragUpdateOffset!.dx;
      case AxisDirection.down:
        primaryDeltaFromDragStart =
            updatedOffset.dy - _startDragScrollbarAxisOffset!.dy;
        primaryDeltaFromLastDragUpdate =
            updatedOffset.dy - _lastDragUpdateOffset!.dy;
      case AxisDirection.left:
        primaryDeltaFromDragStart =
            _startDragScrollbarAxisOffset!.dx - updatedOffset.dx;
        primaryDeltaFromLastDragUpdate =
            _lastDragUpdateOffset!.dx - updatedOffset.dx;
    }

    // Convert primaryDelta, the amount that the scrollbar moved since the last
    // time when drag started or last updated, into the coordinate space of the scroll
    // position, and jump to that position.
    double scrollOffsetGlobal = scrollbarPainter.getTrackToScroll(
      primaryDeltaFromDragStart + _startDragThumbOffset!,
    );
    if (primaryDeltaFromDragStart > 0 && scrollOffsetGlobal < position.pixels ||
        primaryDeltaFromDragStart < 0 && scrollOffsetGlobal > position.pixels) {
      // Adjust the position value if the scrolling direction conflicts with
      // the dragging direction due to scroll metrics shrink.
      scrollOffsetGlobal =
          position.pixels +
          scrollbarPainter.getTrackToScroll(primaryDeltaFromLastDragUpdate);
    }
    if (scrollOffsetGlobal != position.pixels) {
      // Ensure we don't drag into overscroll if the physics do not allow it.
      final double physicsAdjustment = position.physics.applyBoundaryConditions(
        position,
        scrollOffsetGlobal,
      );
      double newPosition = scrollOffsetGlobal - physicsAdjustment;

      // The physics may allow overscroll when actually *scrolling*, but
      // dragging on the scrollbar does not always allow us to enter overscroll.
      switch (ScrollConfiguration.of(context).getPlatform(context)) {
        case TargetPlatform.fuchsia:
        case TargetPlatform.linux:
        case TargetPlatform.macOS:
        case TargetPlatform.windows:
          newPosition = clampDouble(
            newPosition,
            position.minScrollExtent,
            position.maxScrollExtent,
          );
        case TargetPlatform.iOS:
        case TargetPlatform.android:
          // We can only drag the scrollbar into overscroll on mobile
          // platforms, and only then if the physics allow it.
          break;
      }
      position.jumpTo(newPosition);
    }
  }

  void _maybeStartFadeoutTimer() {
    if (!showScrollbar) {
      _fadeoutTimer?.cancel();
      _fadeoutTimer = Timer(widget.timeToFade, () {
        _fadeoutAnimationController.reverse();
        _fadeoutTimer = null;
      });
    }
  }

  /// Returns the [Axis] of the child scroll view, or null if the
  /// current scroll controller does not have any attached positions.
  @protected
  Axis? getScrollbarDirection() {
    assert(_cachedController != null);
    if (_cachedController!.hasClients) {
      return _cachedController!.position.axis;
    }
    return null;
  }

  /// Handler called when a press on the scrollbar thumb has been recognized.
  ///
  /// Cancels the [Timer] associated with the fade animation of the scrollbar.
  @protected
  @mustCallSuper
  void handleThumbPress() {
    assert(_debugCheckHasValidScrollPosition());
    if (getScrollbarDirection() == null) {
      return;
    }
    _fadeoutTimer?.cancel();
  }

  /// Handler called when a long press gesture has started.
  ///
  /// Begins the fade out animation and initializes dragging the scrollbar thumb.
  @protected
  @mustCallSuper
  void handleThumbPressStart(Offset localPosition) {
    assert(_debugCheckHasValidScrollPosition());
    _cachedController = _effectiveScrollController;
    final Axis? direction = getScrollbarDirection();
    if (direction == null) {
      return;
    }
    _fadeoutTimer?.cancel();
    _fadeoutAnimationController.forward();
    _startDragScrollbarAxisOffset = localPosition;
    _lastDragUpdateOffset = localPosition;
    _startDragThumbOffset = scrollbarPainter.getThumbScrollOffset();
    _thumbDragging = true;
  }

  /// Handler called when a currently active long press gesture moves.
  ///
  /// Updates the position of the child scrollable.
  @protected
  @mustCallSuper
  void handleThumbPressUpdate(Offset localPosition) {
    assert(_debugCheckHasValidScrollPosition());
    if (_lastDragUpdateOffset == localPosition) {
      return;
    }
    final ScrollPosition position = _cachedController!.position;
    if (!widget.physics.shouldAcceptUserOffset(position)) {
      return;
    }
    final Axis? direction = getScrollbarDirection();
    if (direction == null) {
      return;
    }
    _updateScrollPosition(localPosition);
    _lastDragUpdateOffset = localPosition;
  }

  /// Handler called when a long press has ended.
  @protected
  @mustCallSuper
  void handleThumbPressEnd(Offset localPosition, Velocity velocity) {
    assert(_debugCheckHasValidScrollPosition());
    _thumbDragging = false;
    final Axis? direction = getScrollbarDirection();
    if (direction == null) {
      return;
    }
    _maybeStartFadeoutTimer();
    _startDragScrollbarAxisOffset = null;
    _lastDragUpdateOffset = null;
    _startDragThumbOffset = null;
    _cachedController = null;
  }

  void _handleTrackTapDown(TapDownDetails details) {
    // The Scrollbar should page towards the position of the tap on the track.
    assert(_debugCheckHasValidScrollPosition());
    _cachedController = _effectiveScrollController;

    final ScrollPosition position = _cachedController!.position;
    if (!position.physics.shouldAcceptUserOffset(position)) {
      return;
    }

    // Determines the scroll direction.
    final AxisDirection scrollDirection;

    switch (position.axisDirection) {
      case AxisDirection.up:
      case AxisDirection.down:
        if (details.localPosition.dy > scrollbarPainter._thumbOffset) {
          scrollDirection = AxisDirection.down;
        } else {
          scrollDirection = AxisDirection.up;
        }
      case AxisDirection.left:
      case AxisDirection.right:
        if (details.localPosition.dx > scrollbarPainter._thumbOffset) {
          scrollDirection = AxisDirection.right;
        } else {
          scrollDirection = AxisDirection.left;
        }
    }

    final ScrollableState? state = Scrollable.maybeOf(
      position.context.notificationContext!,
    );
    final ScrollIntent intent = ScrollIntent(
      direction: scrollDirection,
      type: ScrollIncrementType.page,
    );
    assert(state != null);
    final double scrollIncrement = ScrollAction.getDirectionalIncrement(
      state!,
      intent,
    );

    _cachedController!.position.moveTo(
      _cachedController!.position.pixels + scrollIncrement,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
  }

  // ScrollController takes precedence over ScrollNotification
  bool _shouldUpdatePainter(Axis notificationAxis) {
    final ScrollController? scrollController = _effectiveScrollController;
    // Only update the painter of this scrollbar if the notification
    // metrics do not conflict with the information we have from the scroll
    // controller.

    // We do not have a scroll controller dictating axis.
    if (scrollController == null) {
      return true;
    }
    // Has more than one attached positions.
    if (scrollController.positions.length > 1) {
      return false;
    }

    return
    // The scroll controller is not attached to a position.
    !scrollController.hasClients
        // The notification matches the scroll controller's axis.
        ||
        scrollController.position.axis == notificationAxis;
  }

  bool _handleScrollMetricsNotification(
    ScrollMetricsNotification notification,
  ) {
    if (!widget.notificationPredicate(notification.asScrollUpdate())) {
      return false;
    }

    if (showScrollbar) {
      if (_fadeoutAnimationController.status != AnimationStatus.forward &&
          _fadeoutAnimationController.status != AnimationStatus.completed) {
        _fadeoutAnimationController.forward();
      }
    }

    final ScrollMetrics metrics = notification.metrics;
    if (_shouldUpdatePainter(metrics.axis)) {
      scrollbarPainter.update(metrics, metrics.axisDirection);
    }
    return false;
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (!widget.notificationPredicate(notification)) {
      return false;
    }

    final ScrollMetrics metrics = notification.metrics;
    if (metrics.maxScrollExtent <= metrics.minScrollExtent) {
      // Hide the bar when the Scrollable widget has no space to scroll.
      if (_fadeoutAnimationController.status != AnimationStatus.dismissed &&
          _fadeoutAnimationController.status != AnimationStatus.reverse) {
        _fadeoutAnimationController.reverse();
      }

      if (_shouldUpdatePainter(metrics.axis)) {
        scrollbarPainter.update(metrics, metrics.axisDirection);
      }
      return false;
    }

    if (notification is ScrollUpdateNotification ||
        notification is OverscrollNotification) {
      // Any movements always makes the scrollbar start showing up.
      if (_fadeoutAnimationController.status != AnimationStatus.forward &&
          _fadeoutAnimationController.status != AnimationStatus.completed) {
        _fadeoutAnimationController.forward();
      }

      _fadeoutTimer?.cancel();

      if (_shouldUpdatePainter(metrics.axis)) {
        scrollbarPainter.update(metrics, metrics.axisDirection);
      }
    } else if (notification is ScrollEndNotification) {
      if (_startDragScrollbarAxisOffset == null) {
        _maybeStartFadeoutTimer();
      }
    }
    return false;
  }

  Map<Type, GestureRecognizerFactory> get _gestures {
    final Map<Type, GestureRecognizerFactory> gestures =
        <Type, GestureRecognizerFactory>{};
    if (_effectiveScrollController == null || !enableGestures) {
      return gestures;
    }

    gestures[_ThumbPressGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<_ThumbPressGestureRecognizer>(
          () => _ThumbPressGestureRecognizer(
            debugOwner: this,
            customPaintKey: _scrollbarPainterKey,
            duration: widget.pressDuration,
          ),
          (_ThumbPressGestureRecognizer instance) {
            instance.onLongPress = handleThumbPress;
            instance.onLongPressStart = (LongPressStartDetails details) =>
                handleThumbPressStart(details.localPosition);
            instance.onLongPressMoveUpdate =
                (LongPressMoveUpdateDetails details) =>
                    handleThumbPressUpdate(details.localPosition);
            instance.onLongPressEnd = (LongPressEndDetails details) =>
                handleThumbPressEnd(details.localPosition, details.velocity);
          },
        );

    gestures[_TrackTapGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<_TrackTapGestureRecognizer>(
          () => _TrackTapGestureRecognizer(
            debugOwner: this,
            customPaintKey: _scrollbarPainterKey,
          ),
          (_TrackTapGestureRecognizer instance) {
            instance.onTapDown = _handleTrackTapDown;
          },
        );

    return gestures;
  }

  /// Returns true if the provided [Offset] is located over the track of the
  /// [RawScrollbarWithCustomPhysics].
  ///
  /// Excludes the [RawScrollbarWithCustomPhysics] thumb.
  @protected
  bool isPointerOverTrack(Offset position, PointerDeviceKind kind) {
    if (_scrollbarPainterKey.currentContext == null) {
      return false;
    }
    final Offset localOffset = _getLocalOffset(_scrollbarPainterKey, position);
    return scrollbarPainter.hitTestInteractive(localOffset, kind) &&
        !scrollbarPainter.hitTestOnlyThumbInteractive(localOffset, kind);
  }

  /// Returns true if the provided [Offset] is located over the thumb of the
  /// [RawScrollbarWithCustomPhysics].
  @protected
  bool isPointerOverThumb(Offset position, PointerDeviceKind kind) {
    if (_scrollbarPainterKey.currentContext == null) {
      return false;
    }
    final Offset localOffset = _getLocalOffset(_scrollbarPainterKey, position);
    return scrollbarPainter.hitTestOnlyThumbInteractive(localOffset, kind);
  }

  /// Returns true if the provided [Offset] is located over the track or thumb
  /// of the [RawScrollbarWithCustomPhysics].
  ///
  /// The hit test area for mouse hovering over the scrollbar is larger than
  /// regular hit testing. This is to make it easier to interact with the
  /// scrollbar and present it to the mouse for interaction based on proximity.
  /// When `forHover` is true, the larger hit test area will be used.
  @protected
  bool isPointerOverScrollbar(
    Offset position,
    PointerDeviceKind kind, {
    bool forHover = false,
  }) {
    if (_scrollbarPainterKey.currentContext == null) {
      return false;
    }
    final Offset localOffset = _getLocalOffset(_scrollbarPainterKey, position);
    return scrollbarPainter.hitTestInteractive(
      localOffset,
      kind,
      forHover: true,
    );
  }

  /// Cancels the fade out animation so the scrollbar will remain visible for
  /// interaction.
  ///
  /// Can be overridden by subclasses to respond to a [PointerHoverEvent].
  ///
  /// Helper methods [isPointerOverScrollbar], [isPointerOverThumb], and
  /// [isPointerOverTrack] can be used to determine the location of the pointer
  /// relative to the painter scrollbar elements.
  @protected
  @mustCallSuper
  void handleHover(PointerHoverEvent event) {
    setState(() {
      _isHoveringThumb = isPointerOverThumb(event.position, event.kind);
    });

    // Check if the position of the pointer falls over the painted scrollbar
    if (isPointerOverScrollbar(event.position, event.kind, forHover: true)) {
      _hoverIsActive = true;
      // Bring the scrollbar back into view if it has faded or started to fade
      // away.
      _fadeoutAnimationController.forward();
      _fadeoutTimer?.cancel();
    } else if (_hoverIsActive) {
      // Pointer is not over painted scrollbar.
      _hoverIsActive = false;
      _maybeStartFadeoutTimer();
    }
  }

  /// Initiates the fade out animation.
  ///
  /// Can be overridden by subclasses to respond to a [PointerExitEvent].
  @protected
  @mustCallSuper
  void handleHoverExit(PointerExitEvent event) {
    _hoverIsActive = false;
    setState(() {
      _isHoveringThumb = false;
    });
    _maybeStartFadeoutTimer();
  }

  // Returns the delta that should result from applying [event] with axis and
  // direction taken into account.
  double _pointerSignalEventDelta(PointerScrollEvent event) {
    assert(_cachedController != null);
    double delta = _cachedController!.position.axis == Axis.horizontal
        ? event.scrollDelta.dx
        : event.scrollDelta.dy;

    if (axisDirectionIsReversed(_cachedController!.position.axisDirection)) {
      delta *= -1;
    }
    return delta;
  }

  // Returns the offset that should result from applying [event] to the current
  // position, taking min/max scroll extent into account.
  double _targetScrollOffsetForPointerScroll(double delta) {
    assert(_cachedController != null);
    return math.min(
      math.max(
        _cachedController!.position.pixels + delta,
        _cachedController!.position.minScrollExtent,
      ),
      _cachedController!.position.maxScrollExtent,
    );
  }

  void _handlePointerScroll(PointerEvent event) {
    assert(event is PointerScrollEvent);
    _cachedController = _effectiveScrollController;
    final double delta = _pointerSignalEventDelta(event as PointerScrollEvent);
    final double targetScrollOffset = _targetScrollOffsetForPointerScroll(
      delta,
    );
    if (delta != 0.0 &&
        targetScrollOffset != _cachedController!.position.pixels) {
      _cachedController!.position.pointerScroll(delta);
    }
  }

  void _receivedPointerSignal(PointerSignalEvent event) {
    _cachedController = _effectiveScrollController;
    // Only try to scroll if the bar absorb the hit test.
    if ((scrollbarPainter.hitTest(event.localPosition) ?? false) &&
        _cachedController != null &&
        _cachedController!.hasClients &&
        (!_thumbDragging || kIsWeb)) {
      final ScrollPosition position = _cachedController!.position;
      if (event is PointerScrollEvent) {
        if (!position.physics.shouldAcceptUserOffset(position)) {
          return;
        }
        final double delta = _pointerSignalEventDelta(event);
        final double targetScrollOffset = _targetScrollOffsetForPointerScroll(
          delta,
        );
        if (delta != 0.0 && targetScrollOffset != position.pixels) {
          GestureBinding.instance.pointerSignalResolver.register(
            event,
            _handlePointerScroll,
          );
        }
      } else if (event is PointerScrollInertiaCancelEvent) {
        position.jumpTo(position.pixels);
        // Don't use the pointer signal resolver, all hit-tested scrollables should stop.
      }
    }
  }

  @override
  void dispose() {
    _fadeoutAnimationController.dispose();
    _fadeoutTimer?.cancel();
    scrollbarPainter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    updateScrollbarPainter();

    return NotificationListener<ScrollMetricsNotification>(
      onNotification: _handleScrollMetricsNotification,
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: RepaintBoundary(
          child: Listener(
            onPointerSignal: _receivedPointerSignal,
            child: RawGestureDetector(
              gestures: _gestures,
              child: MouseRegion(
                cursor: _isHoveringThumb
                    ? SystemMouseCursors.basic
                    : MouseCursor.defer,
                onExit: (PointerExitEvent event) {
                  switch (event.kind) {
                    case PointerDeviceKind.mouse:
                    case PointerDeviceKind.trackpad:
                      if (enableGestures) {
                        handleHoverExit(event);
                      }
                    case PointerDeviceKind.stylus:
                    case PointerDeviceKind.invertedStylus:
                    case PointerDeviceKind.unknown:
                    case PointerDeviceKind.touch:
                      break;
                  }
                },
                onHover: (PointerHoverEvent event) {
                  switch (event.kind) {
                    case PointerDeviceKind.mouse:
                    case PointerDeviceKind.trackpad:
                      if (enableGestures) {
                        handleHover(event);
                      }
                    case PointerDeviceKind.stylus:
                    case PointerDeviceKind.invertedStylus:
                    case PointerDeviceKind.unknown:
                    case PointerDeviceKind.touch:
                      break;
                  }
                },
                child: CustomPaint(
                  key: _scrollbarPainterKey,
                  foregroundPainter: scrollbarPainter,
                  child: RepaintBoundary(child: widget.child),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints a scrollbar's track and thumb.
///
/// The size of the scrollbar along its scroll direction is typically
/// proportional to the percentage of content completely visible on screen,
/// as long as its size isn't less than [minLength] and it isn't overscrolling.
///
/// Unlike [CustomPainter]s that subclasses [CustomPainter] and only repaint
/// when [shouldRepaint] returns true (which requires this [CustomPainter] to
/// be rebuilt), this painter has the added optimization of repainting and not
/// rebuilding when:
///
///  * the scroll position changes; and
///  * when the scrollbar fades away.
///
/// Calling [update] with the new [ScrollMetrics] will repaint the new scrollbar
/// position.
///
/// Updating the value on the provided [fadeoutOpacityAnimation] will repaint
/// with the new opacity.
///
/// You must call [dispose] on this [ScrollbarPainter] when it's no longer used.
///
/// See also:
///
///  * [Scrollbar] for a widget showing a scrollbar around a [Scrollable] in the
///    Material Design style.
///  * [CupertinoScrollbar] for a widget showing a scrollbar around a
///    [Scrollable] in the iOS style.
class ScrollbarPainter extends ChangeNotifier implements CustomPainter {
  /// Creates a scrollbar with customizations given by construction arguments.
  ScrollbarPainter({
    required Color color,
    required this.fadeoutOpacityAnimation,
    Color trackColor = const Color(0x00000000),
    Color trackBorderColor = const Color(0x00000000),
    TextDirection? textDirection,
    double thickness = _kScrollbarThickness,
    EdgeInsets padding = EdgeInsets.zero,
    double mainAxisMargin = 0.0,
    double crossAxisMargin = 0.0,
    Radius? radius,
    Radius? trackRadius,
    OutlinedBorder? shape,
    double minLength = _kMinThumbExtent,
    double? minOverscrollLength,
    ScrollbarOrientation? scrollbarOrientation,
    bool ignorePointer = false,
  }) : assert(radius == null || shape == null),
       assert(minLength >= 0),
       assert(minOverscrollLength == null || minOverscrollLength <= minLength),
       assert(minOverscrollLength == null || minOverscrollLength >= 0),
       assert(padding.isNonNegative),
       _color = color,
       _textDirection = textDirection,
       _thickness = thickness,
       _radius = radius,
       _shape = shape,
       _padding = padding,
       _mainAxisMargin = mainAxisMargin,
       _crossAxisMargin = crossAxisMargin,
       _minLength = minLength,
       _trackColor = trackColor,
       _trackBorderColor = trackBorderColor,
       _trackRadius = trackRadius,
       _scrollbarOrientation = scrollbarOrientation,
       _minOverscrollLength = minOverscrollLength ?? minLength,
       _ignorePointer = ignorePointer {
    fadeoutOpacityAnimation.addListener(notifyListeners);
  }

  /// [Color] of the thumb. Mustn't be null.
  Color get color => _color;
  Color _color;
  set color(Color value) {
    if (color == value) {
      return;
    }

    _color = value;
    notifyListeners();
  }

  /// [Color] of the track. Mustn't be null.
  Color get trackColor => _trackColor;
  Color _trackColor;
  set trackColor(Color value) {
    if (trackColor == value) {
      return;
    }

    _trackColor = value;
    notifyListeners();
  }

  /// [Color] of the track border. Mustn't be null.
  Color get trackBorderColor => _trackBorderColor;
  Color _trackBorderColor;
  set trackBorderColor(Color value) {
    if (trackBorderColor == value) {
      return;
    }

    _trackBorderColor = value;
    notifyListeners();
  }

  /// [Radius] of corners of the Scrollbar's track.
  ///
  /// Scrollbar's track will be rectangular if [trackRadius] is null.
  Radius? get trackRadius => _trackRadius;
  Radius? _trackRadius;
  set trackRadius(Radius? value) {
    if (trackRadius == value) {
      return;
    }

    _trackRadius = value;
    notifyListeners();
  }

  /// [TextDirection] of the [BuildContext] which dictates the side of the
  /// screen the scrollbar appears in (the trailing side). Must be set prior to
  /// calling paint.
  TextDirection? get textDirection => _textDirection;
  TextDirection? _textDirection;
  set textDirection(TextDirection? value) {
    assert(value != null);
    if (textDirection == value) {
      return;
    }

    _textDirection = value;
    notifyListeners();
  }

  /// Thickness of the scrollbar in its cross-axis in logical pixels. Mustn't be null.
  double get thickness => _thickness;
  double _thickness;
  set thickness(double value) {
    if (thickness == value) {
      return;
    }

    _thickness = value;
    notifyListeners();
  }

  /// An opacity [Animation] that dictates the opacity of the thumb.
  /// Changes in value of this [Listenable] will automatically trigger repaints.
  /// Mustn't be null.
  final Animation<double> fadeoutOpacityAnimation;

  /// Distance from the scrollbar thumb's start and end to the edge of the
  /// viewport in logical pixels. It affects the amount of available paint area.
  ///
  /// The scrollbar track consumes this space.
  ///
  /// Mustn't be null and defaults to 0.
  double get mainAxisMargin => _mainAxisMargin;
  double _mainAxisMargin;
  set mainAxisMargin(double value) {
    if (mainAxisMargin == value) {
      return;
    }

    _mainAxisMargin = value;
    notifyListeners();
  }

  /// Distance from the scrollbar thumb to the nearest cross axis edge
  /// in logical pixels.
  ///
  /// The scrollbar track consumes this space.
  ///
  /// Defaults to zero.
  double get crossAxisMargin => _crossAxisMargin;
  double _crossAxisMargin;
  set crossAxisMargin(double value) {
    if (crossAxisMargin == value) {
      return;
    }

    _crossAxisMargin = value;
    notifyListeners();
  }

  /// [Radius] of corners if the scrollbar should have rounded corners.
  ///
  /// Scrollbar will be rectangular if [radius] is null.
  Radius? get radius => _radius;
  Radius? _radius;
  set radius(Radius? value) {
    assert(shape == null || value == null);
    if (radius == value) {
      return;
    }

    _radius = value;
    notifyListeners();
  }

  /// The [OutlinedBorder] of the scrollbar's thumb.
  ///
  /// Only one of [radius] and [shape] may be specified. For a rounded rectangle,
  /// it's simplest to just specify [radius]. By default, the scrollbar thumb's
  /// shape is a simple rectangle.
  ///
  /// If [shape] is specified, the thumb will take the shape of the passed
  /// [OutlinedBorder] and fill itself with [color] (or grey if it
  /// is unspecified).
  ///
  OutlinedBorder? get shape => _shape;
  OutlinedBorder? _shape;
  set shape(OutlinedBorder? value) {
    assert(radius == null || value == null);
    if (shape == value) {
      return;
    }

    _shape = value;
    notifyListeners();
  }

  /// The amount of space by which to inset the scrollbar's start and end, as
  /// well as its side to the nearest edge, in logical pixels.
  ///
  /// This is typically set to the current [MediaQueryData.padding] to avoid
  /// partial obstructions such as display notches. If you only want additional
  /// margins around the scrollbar, see [mainAxisMargin].
  ///
  /// Defaults to [EdgeInsets.zero]. Offsets from all four directions must be
  /// greater than or equal to zero.
  EdgeInsets get padding => _padding;
  EdgeInsets _padding;
  set padding(EdgeInsets value) {
    if (padding == value) {
      return;
    }

    _padding = value;
    notifyListeners();
  }

  /// The preferred smallest size the scrollbar thumb can shrink to when the total
  /// scrollable extent is large, the current visible viewport is small, and the
  /// viewport is not overscrolled.
  ///
  /// The size of the scrollbar may shrink to a smaller size than [minLength] to
  /// fit in the available paint area. E.g., when [minLength] is
  /// `double.infinity`, it will not be respected if
  /// [ScrollMetrics.viewportDimension] and [mainAxisMargin] are finite.
  ///
  /// Mustn't be null and the value has to be greater or equal to
  /// [minOverscrollLength], which in turn is >= 0. Defaults to 18.0.
  double get minLength => _minLength;
  double _minLength;
  set minLength(double value) {
    if (minLength == value) {
      return;
    }

    _minLength = value;
    notifyListeners();
  }

  /// The preferred smallest size the scrollbar thumb can shrink to when viewport is
  /// overscrolled.
  ///
  /// When overscrolling, the size of the scrollbar may shrink to a smaller size
  /// than [minOverscrollLength] to fit in the available paint area. E.g., when
  /// [minOverscrollLength] is `double.infinity`, it will not be respected if
  /// the [ScrollMetrics.viewportDimension] and [mainAxisMargin] are finite.
  ///
  /// The value is less than or equal to [minLength] and greater than or equal to 0.
  /// When null, it will default to the value of [minLength].
  double get minOverscrollLength => _minOverscrollLength;
  double _minOverscrollLength;
  set minOverscrollLength(double value) {
    if (minOverscrollLength == value) {
      return;
    }

    _minOverscrollLength = value;
    notifyListeners();
  }

  /// {@template flutter.widgets.Scrollbar.scrollbarOrientation}
  /// Dictates the orientation of the scrollbar.
  ///
  /// [ScrollbarOrientation.top] places the scrollbar on top of the screen.
  /// [ScrollbarOrientation.bottom] places the scrollbar on the bottom of the screen.
  /// [ScrollbarOrientation.left] places the scrollbar on the left of the screen.
  /// [ScrollbarOrientation.right] places the scrollbar on the right of the screen.
  ///
  /// [ScrollbarOrientation.top] and [ScrollbarOrientation.bottom] can only be
  /// used with a vertical scroll.
  /// [ScrollbarOrientation.left] and [ScrollbarOrientation.right] can only be
  /// used with a horizontal scroll.
  ///
  /// For a vertical scroll the orientation defaults to
  /// [ScrollbarOrientation.right] for [TextDirection.ltr] and
  /// [ScrollbarOrientation.left] for [TextDirection.rtl].
  /// For a horizontal scroll the orientation defaults to [ScrollbarOrientation.bottom].
  /// {@endtemplate}
  ScrollbarOrientation? get scrollbarOrientation => _scrollbarOrientation;
  ScrollbarOrientation? _scrollbarOrientation;
  set scrollbarOrientation(ScrollbarOrientation? value) {
    if (scrollbarOrientation == value) {
      return;
    }

    _scrollbarOrientation = value;
    notifyListeners();
  }

  /// Whether the painter will be ignored during hit testing.
  bool get ignorePointer => _ignorePointer;
  bool _ignorePointer;
  set ignorePointer(bool value) {
    if (ignorePointer == value) {
      return;
    }

    _ignorePointer = value;
    notifyListeners();
  }

  // - Scrollbar Details

  Rect? _trackRect;
  // The full painted length of the track
  double get _trackExtent =>
      _lastMetrics!.viewportDimension - _totalTrackMainAxisOffsets;
  // The full length of the track that the thumb can travel
  double get _traversableTrackExtent => _trackExtent - (2 * mainAxisMargin);
  // Track Offsets
  // The track is offset by only padding.
  double get _totalTrackMainAxisOffsets =>
      _isVertical ? padding.vertical : padding.horizontal;
  double get _leadingTrackMainAxisOffset {
    switch (_resolvedOrientation) {
      case ScrollbarOrientation.left:
      case ScrollbarOrientation.right:
        return padding.top;
      case ScrollbarOrientation.top:
      case ScrollbarOrientation.bottom:
        return padding.left;
    }
  }

  Rect? _thumbRect;
  // The current scroll position + _leadingThumbMainAxisOffset
  late double _thumbOffset;
  // The fraction visible in relation to the traversable length of the track.
  late double _thumbExtent;
  // Thumb Offsets
  // The thumb is offset by padding and margins.
  double get _leadingThumbMainAxisOffset {
    switch (_resolvedOrientation) {
      case ScrollbarOrientation.left:
      case ScrollbarOrientation.right:
        return padding.top + mainAxisMargin;
      case ScrollbarOrientation.top:
      case ScrollbarOrientation.bottom:
        return padding.left + mainAxisMargin;
    }
  }

  void _setThumbExtent() {
    // Thumb extent reflects fraction of content visible, as long as this
    // isn't less than the absolute minimum size.
    // _totalContentExtent >= viewportDimension, so (_totalContentExtent - _mainAxisPadding) > 0
    final double fractionVisible = clampDouble(
      (_lastMetrics!.extentInside - _totalTrackMainAxisOffsets) /
          (_totalContentExtent - _totalTrackMainAxisOffsets),
      0.0,
      1.0,
    );

    final double thumbExtent = math.max(
      math.min(_traversableTrackExtent, minOverscrollLength),
      _traversableTrackExtent * fractionVisible,
    );

    final double fractionOverscrolled =
        1.0 - _lastMetrics!.extentInside / _lastMetrics!.viewportDimension;
    final double safeMinLength = math.min(minLength, _traversableTrackExtent);
    final double newMinLength = (_beforeExtent > 0 && _afterExtent > 0)
        // Thumb extent is no smaller than minLength if scrolling normally.
        ? safeMinLength
        // User is overscrolling. Thumb extent can be less than minLength
        // but no smaller than minOverscrollLength. We can't use the
        // fractionVisible to produce intermediate values between minLength and
        // minOverscrollLength when the user is transitioning from regular
        // scrolling to overscrolling, so we instead use the percentage of the
        // content that is still in the viewport to determine the size of the
        // thumb. iOS behavior appears to have the thumb reach its minimum size
        // with ~20% of overscroll. We map the percentage of minLength from
        // [0.8, 1.0] to [0.0, 1.0], so 0% to 20% of overscroll will produce
        // values for the thumb that range between minLength and the smallest
        // possible value, minOverscrollLength.
        : safeMinLength *
              (1.0 - clampDouble(fractionOverscrolled, 0.0, 0.2) / 0.2);

    // The `thumbExtent` should be no greater than `trackSize`, otherwise
    // the scrollbar may scroll towards the wrong direction.
    _thumbExtent = clampDouble(
      thumbExtent,
      newMinLength,
      _traversableTrackExtent,
    );
  }

  // - Scrollable Details

  ScrollMetrics? _lastMetrics;
  bool get _lastMetricsAreScrollable =>
      _lastMetrics!.minScrollExtent != _lastMetrics!.maxScrollExtent;
  AxisDirection? _lastAxisDirection;

  bool get _isVertical =>
      _lastAxisDirection == AxisDirection.down ||
      _lastAxisDirection == AxisDirection.up;
  bool get _isReversed =>
      _lastAxisDirection == AxisDirection.up ||
      _lastAxisDirection == AxisDirection.left;
  // The amount of scroll distance before and after the current position.
  double get _beforeExtent =>
      _isReversed ? _lastMetrics!.extentAfter : _lastMetrics!.extentBefore;
  double get _afterExtent =>
      _isReversed ? _lastMetrics!.extentBefore : _lastMetrics!.extentAfter;

  // The total size of the scrollable content.
  double get _totalContentExtent {
    return _lastMetrics!.maxScrollExtent -
        _lastMetrics!.minScrollExtent +
        _lastMetrics!.viewportDimension;
  }

  ScrollbarOrientation get _resolvedOrientation {
    if (scrollbarOrientation == null) {
      if (_isVertical) {
        return textDirection == TextDirection.ltr
            ? ScrollbarOrientation.right
            : ScrollbarOrientation.left;
      }
      return ScrollbarOrientation.bottom;
    }
    return scrollbarOrientation!;
  }

  void _debugAssertIsValidOrientation(ScrollbarOrientation orientation) {
    assert(
      () {
        bool isVerticalOrientation(ScrollbarOrientation orientation) =>
            orientation == ScrollbarOrientation.left ||
            orientation == ScrollbarOrientation.right;
        return (_isVertical && isVerticalOrientation(orientation)) ||
            (!_isVertical && !isVerticalOrientation(orientation));
      }(),
      'The given ScrollbarOrientation: $orientation is incompatible with the '
      'current AxisDirection: $_lastAxisDirection.',
    );
  }

  // - Updating

  /// Update with new [ScrollMetrics]. If the metrics change, the scrollbar will
  /// show and redraw itself based on these new metrics.
  ///
  /// The scrollbar will remain on screen.
  void update(ScrollMetrics metrics, AxisDirection axisDirection) {
    if (_lastMetrics != null &&
        _lastMetrics!.extentBefore == metrics.extentBefore &&
        _lastMetrics!.extentInside == metrics.extentInside &&
        _lastMetrics!.extentAfter == metrics.extentAfter &&
        _lastAxisDirection == axisDirection) {
      return;
    }

    final ScrollMetrics? oldMetrics = _lastMetrics;
    _lastMetrics = metrics;
    _lastAxisDirection = axisDirection;

    bool needPaint(ScrollMetrics? metrics) =>
        metrics != null && metrics.maxScrollExtent > metrics.minScrollExtent;
    if (!needPaint(oldMetrics) && !needPaint(metrics)) {
      return;
    }
    notifyListeners();
  }

  /// Update and redraw with new scrollbar thickness and radius.
  void updateThickness(double nextThickness, Radius nextRadius) {
    thickness = nextThickness;
    radius = nextRadius;
  }

  // - Painting

  Paint get _paintThumb {
    return Paint()
      ..color = color.withValues(
        alpha: color.a * fadeoutOpacityAnimation.value,
      );
  }

  Paint _paintTrack({bool isBorder = false}) {
    if (isBorder) {
      return Paint()
        ..color = trackBorderColor.withValues(
          alpha: trackBorderColor.a * fadeoutOpacityAnimation.value,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
    }
    return Paint()
      ..color = trackColor.withValues(
        alpha: trackColor.a * fadeoutOpacityAnimation.value,
      );
  }

  void _paintScrollbar(Canvas canvas, Size size) {
    assert(
      textDirection != null,
      'A TextDirection must be provided before a Scrollbar can be painted.',
    );

    final double x, y;
    final Size thumbSize, trackSize;
    final Offset trackOffset, borderStart, borderEnd;
    _debugAssertIsValidOrientation(_resolvedOrientation);
    switch (_resolvedOrientation) {
      case ScrollbarOrientation.left:
        thumbSize = Size(thickness, _thumbExtent);
        trackSize = Size(thickness + 2 * crossAxisMargin, _trackExtent);
        x = crossAxisMargin + padding.left;
        y = _thumbOffset;
        trackOffset = Offset(x - crossAxisMargin, _leadingTrackMainAxisOffset);
        borderStart = trackOffset + Offset(trackSize.width, 0.0);
        borderEnd = Offset(
          trackOffset.dx + trackSize.width,
          trackOffset.dy + _trackExtent,
        );
      case ScrollbarOrientation.right:
        thumbSize = Size(thickness, _thumbExtent);
        trackSize = Size(thickness + 2 * crossAxisMargin, _trackExtent);
        x = size.width - thickness - crossAxisMargin - padding.right;
        y = _thumbOffset;
        trackOffset = Offset(x - crossAxisMargin, _leadingTrackMainAxisOffset);
        borderStart = trackOffset;
        borderEnd = Offset(trackOffset.dx, trackOffset.dy + _trackExtent);
      case ScrollbarOrientation.top:
        thumbSize = Size(_thumbExtent, thickness);
        trackSize = Size(_trackExtent, thickness + 2 * crossAxisMargin);
        x = _thumbOffset;
        y = crossAxisMargin + padding.top;
        trackOffset = Offset(_leadingTrackMainAxisOffset, y - crossAxisMargin);
        borderStart = trackOffset + Offset(0.0, trackSize.height);
        borderEnd = Offset(
          trackOffset.dx + _trackExtent,
          trackOffset.dy + trackSize.height,
        );
      case ScrollbarOrientation.bottom:
        thumbSize = Size(_thumbExtent, thickness);
        trackSize = Size(_trackExtent, thickness + 2 * crossAxisMargin);
        x = _thumbOffset;
        y = size.height - thickness - crossAxisMargin - padding.bottom;
        trackOffset = Offset(_leadingTrackMainAxisOffset, y - crossAxisMargin);
        borderStart = trackOffset;
        borderEnd = Offset(trackOffset.dx + _trackExtent, trackOffset.dy);
    }

    // Whether we paint or not, calculating these rects allows us to hit test
    // when the scrollbar is transparent.
    _trackRect = trackOffset & trackSize;
    _thumbRect = Offset(x, y) & thumbSize;

    // Paint if the opacity dictates visibility
    if (fadeoutOpacityAnimation.value != 0.0) {
      // Track
      if (trackRadius == null) {
        canvas.drawRect(_trackRect!, _paintTrack());
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(_trackRect!, trackRadius!),
          _paintTrack(),
        );
      }
      // Track Border
      canvas.drawLine(borderStart, borderEnd, _paintTrack(isBorder: true));
      if (radius != null) {
        // Rounded rect thumb
        canvas.drawRRect(
          RRect.fromRectAndRadius(_thumbRect!, radius!),
          _paintThumb,
        );
        return;
      }
      if (shape == null) {
        // Square thumb
        canvas.drawRect(_thumbRect!, _paintThumb);
        return;
      }
      // Custom-shaped thumb
      final Path outerPath = shape!.getOuterPath(_thumbRect!);
      canvas.drawPath(outerPath, _paintThumb);
      shape!.paint(canvas, _thumbRect!);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_lastAxisDirection == null ||
        _lastMetrics == null ||
        _lastMetrics!.maxScrollExtent <= _lastMetrics!.minScrollExtent) {
      return;
    }
    // Skip painting if there's not enough space.
    if (_traversableTrackExtent <= 0) {
      return;
    }
    // Do not paint a scrollbar if the scroll view is infinitely long.
    // TODO(Piinks): Special handling for infinite scroll views,
    //  https://github.com/flutter/flutter/issues/41434
    if (_lastMetrics!.maxScrollExtent.isInfinite) {
      return;
    }

    _setThumbExtent();
    final double thumbPositionOffset = _getScrollToTrack(
      _lastMetrics!,
      _thumbExtent,
    );
    _thumbOffset = thumbPositionOffset + _leadingThumbMainAxisOffset;

    return _paintScrollbar(canvas, size);
  }

  // - Scroll Position Conversion

  /// Convert between a thumb track position and the corresponding scroll
  /// position.
  ///
  /// The `thumbOffsetLocal` argument is a position in the thumb track.
  double getTrackToScroll(double thumbOffsetLocal) {
    final double scrollableExtent =
        _lastMetrics!.maxScrollExtent - _lastMetrics!.minScrollExtent;
    final double thumbMovableExtent = _traversableTrackExtent - _thumbExtent;

    return scrollableExtent * thumbOffsetLocal / thumbMovableExtent;
  }

  /// The thumb's corresponding scroll offset in the track.
  double getThumbScrollOffset() {
    final double scrollableExtent =
        _lastMetrics!.maxScrollExtent - _lastMetrics!.minScrollExtent;

    final double fractionPast = (scrollableExtent > 0)
        ? clampDouble(_lastMetrics!.pixels / scrollableExtent, 0.0, 1.0)
        : 0;

    return fractionPast * (_traversableTrackExtent - _thumbExtent);
  }

  // Converts between a scroll position and the corresponding position in the
  // thumb track.
  double _getScrollToTrack(ScrollMetrics metrics, double thumbExtent) {
    final double scrollableExtent =
        metrics.maxScrollExtent - metrics.minScrollExtent;

    final double fractionPast = (scrollableExtent > 0)
        ? clampDouble(
            (metrics.pixels - metrics.minScrollExtent) / scrollableExtent,
            0.0,
            1.0,
          )
        : 0;

    return (_isReversed ? 1 - fractionPast : fractionPast) *
        (_traversableTrackExtent - thumbExtent);
  }

  // - Hit Testing

  @override
  bool? hitTest(Offset? position) {
    // There is nothing painted to hit.
    if (_thumbRect == null) {
      return null;
    }

    // Interaction disabled.
    if (ignorePointer
        // The thumb is not able to be hit when transparent.
        ||
        fadeoutOpacityAnimation.value == 0.0
        // Not scrollable
        ||
        !_lastMetricsAreScrollable) {
      return false;
    }

    return _trackRect!.contains(position!);
  }

  /// Same as hitTest, but includes some padding when the [PointerEvent] is
  /// caused by [PointerDeviceKind.touch] to make sure that the region
  /// isn't too small to be interacted with by the user.
  ///
  /// The hit test area for hovering with [PointerDeviceKind.mouse] over the
  /// scrollbar also uses this extra padding. This is to make it easier to
  /// interact with the scrollbar by presenting it to the mouse for interaction
  /// based on proximity. When `forHover` is true, the larger hit test area will
  /// be used.
  bool hitTestInteractive(
    Offset position,
    PointerDeviceKind kind, {
    bool forHover = false,
  }) {
    if (_trackRect == null) {
      // We have not computed the scrollbar position yet.
      return false;
    }
    if (ignorePointer) {
      return false;
    }

    if (!_lastMetricsAreScrollable) {
      return false;
    }

    final Rect interactiveRect = _trackRect!;
    final Rect paddedRect = interactiveRect.expandToInclude(
      Rect.fromCircle(
        center: _thumbRect!.center,
        radius: _kMinInteractiveSize / 2,
      ),
    );

    // The scrollbar is not able to be hit when transparent - except when
    // hovering with a mouse. This should bring the scrollbar into view so the
    // mouse can interact with it.
    if (fadeoutOpacityAnimation.value == 0.0) {
      if (forHover && kind == PointerDeviceKind.mouse) {
        return paddedRect.contains(position);
      }
      return false;
    }

    switch (kind) {
      case PointerDeviceKind.touch:
      case PointerDeviceKind.trackpad:
        return paddedRect.contains(position);
      case PointerDeviceKind.mouse:
      case PointerDeviceKind.stylus:
      case PointerDeviceKind.invertedStylus:
      case PointerDeviceKind.unknown:
        return interactiveRect.contains(position);
    }
  }

  /// Same as hitTestInteractive, but excludes the track portion of the scrollbar.
  /// Used to evaluate interactions with only the scrollbar thumb.
  bool hitTestOnlyThumbInteractive(Offset position, PointerDeviceKind kind) {
    if (_thumbRect == null) {
      return false;
    }
    if (ignorePointer) {
      return false;
    }
    // The thumb is not able to be hit when transparent.
    if (fadeoutOpacityAnimation.value == 0.0) {
      return false;
    }

    if (!_lastMetricsAreScrollable) {
      return false;
    }

    switch (kind) {
      case PointerDeviceKind.touch:
      case PointerDeviceKind.trackpad:
        final Rect touchThumbRect = _thumbRect!.expandToInclude(
          Rect.fromCircle(
            center: _thumbRect!.center,
            radius: _kMinInteractiveSize / 2,
          ),
        );
        return touchThumbRect.contains(position);
      case PointerDeviceKind.mouse:
      case PointerDeviceKind.stylus:
      case PointerDeviceKind.invertedStylus:
      case PointerDeviceKind.unknown:
        return _thumbRect!.contains(position);
    }
  }

  @override
  bool shouldRepaint(ScrollbarPainter oldDelegate) {
    // Should repaint if any properties changed.
    return color != oldDelegate.color ||
        trackColor != oldDelegate.trackColor ||
        trackBorderColor != oldDelegate.trackBorderColor ||
        textDirection != oldDelegate.textDirection ||
        thickness != oldDelegate.thickness ||
        fadeoutOpacityAnimation != oldDelegate.fadeoutOpacityAnimation ||
        mainAxisMargin != oldDelegate.mainAxisMargin ||
        crossAxisMargin != oldDelegate.crossAxisMargin ||
        radius != oldDelegate.radius ||
        trackRadius != oldDelegate.trackRadius ||
        shape != oldDelegate.shape ||
        padding != oldDelegate.padding ||
        minLength != oldDelegate.minLength ||
        minOverscrollLength != oldDelegate.minOverscrollLength ||
        scrollbarOrientation != oldDelegate.scrollbarOrientation ||
        ignorePointer != oldDelegate.ignorePointer;
  }

  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) => false;

  @override
  SemanticsBuilderCallback? get semanticsBuilder => null;

  @override
  String toString() => describeIdentity(this);

  @override
  void dispose() {
    fadeoutOpacityAnimation.removeListener(notifyListeners);
    super.dispose();
  }
}

// A long press gesture detector that only responds to events on the scrollbar's
// thumb and ignores everything else.
class _ThumbPressGestureRecognizer extends LongPressGestureRecognizer {
  _ThumbPressGestureRecognizer({
    required Object super.debugOwner,
    required GlobalKey customPaintKey,
    required super.duration,
  }) : _customPaintKey = customPaintKey;

  final GlobalKey _customPaintKey;

  @override
  bool isPointerAllowed(PointerDownEvent event) {
    if (!_hitTestInteractive(_customPaintKey, event.position, event.kind)) {
      return false;
    }
    return super.isPointerAllowed(event);
  }

  bool _hitTestInteractive(
    GlobalKey customPaintKey,
    Offset offset,
    PointerDeviceKind kind,
  ) {
    if (customPaintKey.currentContext == null) {
      return false;
    }
    final CustomPaint customPaint =
        customPaintKey.currentContext!.widget as CustomPaint;
    final ScrollbarPainter painter =
        customPaint.foregroundPainter! as ScrollbarPainter;
    final Offset localOffset = _getLocalOffset(customPaintKey, offset);
    return painter.hitTestOnlyThumbInteractive(localOffset, kind);
  }
}

// A tap gesture detector that only responds to events on the scrollbar's
// track and ignores everything else, including the thumb.
class _TrackTapGestureRecognizer extends TapGestureRecognizer {
  _TrackTapGestureRecognizer({
    required super.debugOwner,
    required GlobalKey customPaintKey,
  }) : _customPaintKey = customPaintKey;

  final GlobalKey _customPaintKey;

  @override
  bool isPointerAllowed(PointerDownEvent event) {
    if (!_hitTestInteractive(_customPaintKey, event.position, event.kind)) {
      return false;
    }
    return super.isPointerAllowed(event);
  }

  bool _hitTestInteractive(
    GlobalKey customPaintKey,
    Offset offset,
    PointerDeviceKind kind,
  ) {
    if (customPaintKey.currentContext == null) {
      return false;
    }
    final CustomPaint customPaint =
        customPaintKey.currentContext!.widget as CustomPaint;
    final ScrollbarPainter painter =
        customPaint.foregroundPainter! as ScrollbarPainter;
    final Offset localOffset = _getLocalOffset(customPaintKey, offset);
    // We only receive track taps that are not on the thumb.
    return painter.hitTestInteractive(localOffset, kind) &&
        !painter.hitTestOnlyThumbInteractive(localOffset, kind);
  }
}

Offset _getLocalOffset(GlobalKey scrollbarPainterKey, Offset position) {
  final RenderBox renderBox =
      scrollbarPainterKey.currentContext!.findRenderObject()! as RenderBox;
  return renderBox.globalToLocal(position);
}
