import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:super_keyboard/src/keyboard.dart';

class SuperKeyboardAndroidBuilder extends StatefulWidget {
  const SuperKeyboardAndroidBuilder({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext, MobileWindowGeometry) builder;

  @override
  State<SuperKeyboardAndroidBuilder> createState() => _SuperKeyboardAndroidBuilderState();
}

class _SuperKeyboardAndroidBuilderState extends State<SuperKeyboardAndroidBuilder>
    implements SuperKeyboardAndroidListener {
  @override
  void initState() {
    super.initState();
    SuperKeyboardAndroid.instance.addListener(this);
  }

  @override
  void dispose() {
    SuperKeyboardAndroid.instance.removeListener(this);
    super.dispose();
  }

  @override
  void onKeyboardOpen() {
    setState(() {});
  }

  @override
  void onKeyboardOpening() {
    setState(() {});
  }

  @override
  void onKeyboardClosing() {
    setState(() {});
  }

  @override
  void onKeyboardClosed() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      SuperKeyboardAndroid.instance.geometry.value,
    );
  }
}

class SuperKeyboardAndroid {
  static SuperKeyboardAndroid? _instance;
  static SuperKeyboardAndroid get instance {
    _instance ??= SuperKeyboardAndroid._();
    return _instance!;
  }

  static final log = Logger("super_keyboard.android");

  SuperKeyboardAndroid._() {
    log.info("Initializing Android plugin for super_keyboard");
    assert(
      defaultTargetPlatform == TargetPlatform.android,
      "You shouldn't initialize SuperKeyboardAndroid when not on an Android platform. Current: $defaultTargetPlatform",
    );
    _methodChannel.setMethodCallHandler(_onPlatformMessage);
  }

  final _methodChannel = const MethodChannel('super_keyboard_android');

  /// Enable/disable platform-side logging, e.g., Android logs.
  Future<void> enablePlatformLogging(bool isEnabled) async {
    await _methodChannel.invokeMethod(isEnabled ? "startLogging" : "stopLogging");
  }

  ValueListenable<MobileWindowGeometry> get geometry => _geometry;
  final _geometry = ValueNotifier<MobileWindowGeometry>(const MobileWindowGeometry());

  final _listeners = <SuperKeyboardAndroidListener>{};
  void addListener(SuperKeyboardAndroidListener listener) => _listeners.add(listener);
  void removeListener(SuperKeyboardAndroidListener listener) => _listeners.remove(listener);

  Future<void> _onPlatformMessage(MethodCall message) async {
    log.fine("Android platform message: '${message.method}', args: ${message.arguments}");
    switch (message.method) {
      case "keyboardOpening":
        _geometry.value = _geometry.value.updateWith(
          MobileWindowGeometry(
            keyboardState: KeyboardState.opening,
            keyboardHeight: (message.arguments["keyboardHeight"] as num?)?.toDouble(),
            bottomPadding: (message.arguments["bottomPadding"] as num?)?.toDouble(),
          ),
        );

        for (final listener in _listeners) {
          listener.onKeyboardOpening();
        }
        break;
      case "keyboardOpened":
        _geometry.value = _geometry.value.updateWith(
          MobileWindowGeometry(
            keyboardState: KeyboardState.open,
            keyboardHeight: (message.arguments["keyboardHeight"] as num?)?.toDouble(),
            bottomPadding: (message.arguments["bottomPadding"] as num?)?.toDouble(),
          ),
        );

        for (final listener in _listeners) {
          listener.onKeyboardOpen();
        }
        break;
      case "keyboardClosing":
        _geometry.value = _geometry.value.updateWith(
          MobileWindowGeometry(
            keyboardState: KeyboardState.closing,
            keyboardHeight: (message.arguments["keyboardHeight"] as num?)?.toDouble(),
            bottomPadding: (message.arguments["bottomPadding"] as num?)?.toDouble(),
          ),
        );

        for (final listener in _listeners) {
          listener.onKeyboardClosing();
        }
        break;
      case "keyboardClosed":
        _geometry.value = _geometry.value.updateWith(
          MobileWindowGeometry(
            keyboardState: KeyboardState.closed,
            // Just in case the height got out of sync, perhaps due to Activity
            // lifecycle changes, explicitly set the keyboard height to zero.
            keyboardHeight: 0,
            bottomPadding: (message.arguments["bottomPadding"] as num?)?.toDouble(),
          ),
        );

        for (final listener in _listeners) {
          listener.onKeyboardClosed();
        }
        break;
      case "onProgress":
        _geometry.value = _geometry.value.updateWith(
          MobileWindowGeometry(
            keyboardHeight: (message.arguments["keyboardHeight"] as num?)?.toDouble(),
            bottomPadding: (message.arguments["bottomPadding"] as num?)?.toDouble(),
          ),
        );
        break;
      case "metricsUpdate":
        _geometry.value = _geometry.value.updateWith(
          MobileWindowGeometry(
            keyboardHeight: (message.arguments["keyboardHeight"] as num?)?.toDouble(),
            bottomPadding: (message.arguments["bottomPadding"] as num?)?.toDouble(),
          ),
        );
        break;
      default:
        log.warning("Unknown Android plugin platform message: $message");
    }
  }
}

abstract interface class SuperKeyboardAndroidListener {
  void onKeyboardOpening();
  void onKeyboardOpen();
  void onKeyboardClosing();
  void onKeyboardClosed();
}
