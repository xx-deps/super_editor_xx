import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:super_editor/src/infrastructure/_logging.dart';

/// Widget that opens and closes the software keyboard, when requested.
///
/// This widget's [State] object implements [SoftwareKeyboardControllerDelegate],
/// which can be controlled with a [SoftwareKeyboardController].
///
/// Opening the software keyboard requires that a connection be established to the
/// platform IME. Therefore, this widget requires [createImeClient] and [createImeConfiguration]
/// to establish that connection, if it doesn't exist already.
class SoftwareKeyboardOpener extends StatefulWidget {
  const SoftwareKeyboardOpener({
    Key? key,
    required this.controller,
    required this.imeConnection,
    required this.createImeClient,
    required this.createImeConfiguration,
    required this.child,
  }) : super(key: key);

  final SoftwareKeyboardController? controller;

  final ValueNotifier<TextInputConnection?> imeConnection;

  final TextInputClient Function() createImeClient;

  final TextInputConfiguration Function() createImeConfiguration;

  final Widget child;

  @override
  State<SoftwareKeyboardOpener> createState() => _SoftwareKeyboardOpenerState();
}

class _SoftwareKeyboardOpenerState extends State<SoftwareKeyboardOpener> implements SoftwareKeyboardControllerDelegate {
  @override
  void initState() {
    super.initState();
    widget.controller?.attach(this);
  }

  @override
  void didUpdateWidget(SoftwareKeyboardOpener oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.detach();
      widget.controller?.attach(this);
    }
  }

  @override
  void dispose() {
    // Detach from the controller at the end of the frame, so that
    // ancestor widgets can still call `close()` on the keyboard in
    // their `dispose()` methods. If we `detach()` right now, the
    // ancestor widgets would cause errors in their `dispose()` methods.
    WidgetsBinding.instance.scheduleFrameCallback((timeStamp) {
      widget.controller?.detach();
    });
    super.dispose();
  }

  @override
  bool get isConnectedToIme => widget.imeConnection.value?.attached ?? false;

  @override
  void open({
    required int viewId,
  }) {
    editorImeLog.info("[SoftwareKeyboard] - showing keyboard");
    widget.imeConnection.value ??= TextInput.attach(widget.createImeClient(), widget.createImeConfiguration());
    widget.imeConnection.value!.show();
  }

  @override
  void hide() {
    SystemChannels.textInput.invokeListMethod("TextInput.hide");
  }

  @override
  void close() {
    editorImeLog.info("[SoftwareKeyboard] - closing IME connection.");
    widget.imeConnection.value?.close();
    widget.imeConnection.value = null;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// `SuperEditor` controller that opens and closes the software keyboard.
///
/// A [SoftwareKeyboardController] must be attached to a
/// [SoftwareKeyboardControllerDelegate] to open and close the software keyboard.
class SoftwareKeyboardController {
  SoftwareKeyboardControllerDelegate? _delegate;

  /// Whether this controller is currently attached to a delegate that
  /// knows how to open and close the software keyboard.
  bool get hasDelegate => _delegate != null;

  /// Attaches this controller to a delegate that knows how to open and
  /// close the software keyboard.
  void attach(SoftwareKeyboardControllerDelegate delegate) {
    editorImeLog.finer("[SoftwareKeyboardController] - Attaching to delegate: $delegate");
    _delegate = delegate;
  }

  /// Detaches this controller from its delegate.
  ///
  /// This controller can't open or close the software keyboard while
  /// detached from a delegate that knows how to make that happen.
  void detach() {
    editorImeLog.finer("[SoftwareKeyboardController] - Detaching from delegate: $_delegate");
    _delegate = null;
  }

  /// Whether the delegate is currently connected to the platform IME.
  bool get isConnectedToIme {
    assert(hasDelegate);
    return _delegate?.isConnectedToIme ?? false;
  }

  /// Opens the software keyboard.
  ///
  /// The [viewId] is required do determine the view that the text input belongs to. You can call
  /// `View.of(context).viewId` to get the current view's ID.
  void open({
    required int viewId,
  }) {
    assert(hasDelegate);
    _delegate?.open(viewId: viewId);
  }

  void hide() {
    assert(hasDelegate);
    _delegate?.hide();
  }

  /// Closes the software keyboard.
  void close() {
    assert(hasDelegate);
    _delegate?.close();
  }
}

/// Delegate that's attached to a [SoftwareKeyboardController], which implements
/// the opening and closing of the software keyboard.
abstract class SoftwareKeyboardControllerDelegate {
  /// Whether this delegate is currently connected to the platform IME.
  bool get isConnectedToIme;

  /// Opens the software keyboard.
  ///
  /// The [viewId] is required do determine the view that the text input belongs to. You can call
  /// `View.of(context).viewId` to get the current view's ID.
  void open({
    required int viewId,
  });

  /// Hides the software keyboard without closing the IME connection.
  void hide();

  /// Closes the software keyboard, and the IME connection.
  void close();
}
