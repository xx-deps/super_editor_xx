import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_robots/src/input_method_engine.dart';

/// Simulates keyboard input in your Flutter app.
///
/// Flutter's [WidgetTester] provides a few key-event behaviors, but simulating
/// common key presses requires calling a number of these methods in succession.
/// This extension combines those methods to make it easy to simulate common
/// key presses, like [pressShiftEnter]. Additionally, this extension automatically
/// pumps and settles after every simulation to avoid pumping after every call.
///
/// The [KeyboardInput] extension also simulates text input with [typeKeyboardText],
/// which types one character after another, and pumps a frame between every key
/// press.
extension KeyboardInput on WidgetTester {
  /// Simulates typing the given [plainText] using a physical keyboard.
  ///
  /// A frame is `pump()`ed between every character in [plainText].
  ///
  /// This method only works with widgets that are configured to handle
  /// keyboard keys, which is different from the standard text input system,
  /// called the Input Method Engine (IME). For example, a standard Flutter
  /// `TextField` only responds to the IME, so this method would have no
  /// effect on a `TextField`.
  Future<void> typeKeyboardText(String plainText) async {
    // Avoid generating characters with an "ios" platform due to Flutter bug.
    // TODO: Remove special platform selection when Flutter issue is solved (https://github.com/flutter/flutter/issues/133956)
    final platform = _keyEventPlatform != "ios" ? _keyEventPlatform : "android";

    for (int i = 0; i < plainText.length; i += 1) {
      final character = plainText[i];
      final keyCombo = _keyComboForCharacter(character);

      if (keyCombo.isShiftPressed) {
        await sendKeyDownEvent(LogicalKeyboardKey.shift, platform: platform);
      }

      if (keyCombo.isShiftPressed) {
        await sendKeyDownEvent(keyCombo.physicalKey!,
            platform: platform, character: character);
        await sendKeyUpEvent(keyCombo.physicalKey!, platform: platform);
      } else {
        await sendKeyEvent(keyCombo.key, platform: platform);
      }

      if (keyCombo.isShiftPressed) {
        await sendKeyUpEvent(LogicalKeyboardKey.shift, platform: platform);
      }

      await pump();
    }
  }

  /// Runs [sendKeyEvent], using the current [defaultTargetPlatform] as the key simulators `platform` value.
  ///
  /// {@template flutter_key_simulation_override}
  /// This method was created because developers often use convenience methods in this package,
  /// along with Flutter's standard simulation methods. But, the convenience methods in this package
  /// simulate a key press `platform` based on the current [defaultTargetPlatform], whereas Flutter's
  /// standard simulation methods always default to "android". Using mismatched platforms across
  /// key simulations leads to unexpected results. By always using methods in this package, instead of
  /// standard Flutter methods, the simulated platform is guaranteed to match across calls, and also
  /// match the platform that's simulated within the surrounding test, i.e., [defaultTargetPlatform].
  /// {@endtemplate}
  Future<void> pressKey(LogicalKeyboardKey key) =>
      sendKeyEvent(key, platform: _keyEventPlatform);

  /// Runs [simulateKeyDownEvent], using the current [defaultTargetPlatform] as the key simulators `platform` value.
  ///
  /// {@macro flutter_key_simulation_override}
  Future<void> pressKeyDown(LogicalKeyboardKey key) =>
      simulateKeyDownEvent(key, platform: _keyEventPlatform);

  /// Runs [simulateKeyUpEvent], using the current [defaultTargetPlatform] as the key simulators `platform` value.
  ///
  /// {@macro flutter_key_simulation_override}
  Future<void> releaseKeyUp(LogicalKeyboardKey key) =>
      simulateKeyUpEvent(key, platform: _keyEventPlatform);

  /// Runs [simulateKeyRepeatEvent], using the current [defaultTargetPlatform] as the key simulators `platform` value.
  ///
  /// {@macro flutter_key_simulation_override}
  Future<void> repeatKey(LogicalKeyboardKey key) =>
      simulateKeyRepeatEvent(key, platform: _keyEventPlatform);

  Future<void> pressEnter() async {
    await sendKeyEvent(LogicalKeyboardKey.enter, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  /// Simulates the user pressing ENTER in a widget attached to the IME.
  ///
  /// Instead of key events, this method generates a "\n" insertion followed by a TextInputAction.newline.
  ///
  /// {@template ime_client_getter}
  /// The given [finder] must find a [StatefulWidget] whose [State] implements
  /// [DeltaTextInputClient].
  ///
  /// If the [DeltaTextInputClient] currently has selected text, that text is first deleted,
  /// which is the standard behavior when typing new characters with an existing selection.
  /// {@endtemplate}
  Future<void> pressEnterWithIme({
    Finder? finder,
    GetDeltaTextInputClient? getter,
  }) async {
    if (!testTextInput.hasAnyClients) {
      // There isn't any IME connections.
      return;
    }

    await ime.typeText('\n', finder: finder, getter: getter);
    await pump();
    await testTextInput.receiveAction(TextInputAction.newline);
    await pump();
  }

  /// Simulates pressing an ENTER button, either as a keyboard key, or as a software keyboard action button.
  ///
  /// First, this method simulates pressing the ENTER key on a physical keyboard. If that key event goes unhandled
  /// then this method simulates pressing the newline action button on a software keyboard, which inserts "/n"
  /// into the text, and also sends a NEWLINE action to the IME client.
  ///
  /// {@macro ime_client_getter}
  Future<void> pressEnterAdaptive({
    Finder? finder,
    GetDeltaTextInputClient? getter,
  }) async {
    final handled = await sendKeyEvent(LogicalKeyboardKey.enter,
        platform: _keyEventPlatform);
    if (handled) {
      // The textfield handled the key event.
      // It won't bubble up to the OS to generate text deltas or input actions.
      await pumpAndSettle();
      return;
    }

    await pressEnterWithIme(finder: finder, getter: getter);
  }

  /// Simulates pressing the SPACE key.
  ///
  /// First, this method simulates pressing the SPACE key on a physical keyboard. If that key event goes unhandled
  /// then this method generates an insertion delta of " ".
  ///
  /// If there isn't an active IME connection, no deltas are generated.
  ///
  /// {@macro ime_client_getter}
  Future<void> pressSpaceAdaptive({
    Finder? finder,
    GetDeltaTextInputClient? getter,
  }) async {
    final handled = await sendKeyEvent(LogicalKeyboardKey.space,
        platform: _keyEventPlatform);

    if (handled) {
      // The key press was handled by the app. We shouldn't generate any deltas.
      await pumpAndSettle();
      return;
    }

    if (!testTextInput.hasAnyClients) {
      // There isn't any IME connections. Fizzle.
      return;
    }

    await ime.typeText(' ', finder: finder, getter: getter);
  }

  Future<void> pressShiftEnter() async {
    await sendKeyDownEvent(LogicalKeyboardKey.shift,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.enter,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.enter, platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.shift, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressCmdEnter() async {
    await sendKeyDownEvent(LogicalKeyboardKey.meta,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.enter,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.enter, platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.meta, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressCtlEnter() async {
    await sendKeyDownEvent(LogicalKeyboardKey.control,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.enter,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.enter, platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.control,
        platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressNumpadEnter() async {
    await sendKeyEvent(LogicalKeyboardKey.numpadEnter,
        platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  /// Simulates the user pressing NUMPAD ENTER in a widget attached to the IME.
  ///
  /// Instead of key events, this method generates a "\n" insertion followed by a TextInputAction.newline.
  /// Does nothing if there isn't an active IME connection.
  ///
  /// {@macro ime_client_getter}
  Future<void> pressNumpadEnterWithIme({
    Finder? finder,
    GetDeltaTextInputClient? getter,
  }) async {
    if (!testTextInput.hasAnyClients) {
      // There isn't any IME connections.
      return;
    }

    await ime.typeText('\n', finder: finder, getter: getter);
    await testTextInput.receiveAction(TextInputAction.newline);
    await pump();
  }

  /// Simulates pressing an NUMPAD ENTER button, either as a keyboard key, or as a software keyboard action button.
  ///
  /// First, this method simulates pressing the NUMPAD ENTER key on a physical keyboard. If that key event goes unhandled
  /// then this method simulates pressing the newline action button on a software keyboard, which inserts "/n"
  /// into the text, and also sends a NEWLINE action to the IME client.
  ///
  /// {@macro ime_client_getter}
  Future<void> pressNumpadEnterAdaptive({
    Finder? finder,
    GetDeltaTextInputClient? getter,
  }) async {
    final handled = await sendKeyEvent(LogicalKeyboardKey.numpadEnter,
        platform: _keyEventPlatform);
    if (handled) {
      // The textfield handled the key event.
      // It won't bubble up to the OS to generate text deltas or input actions.
      await pumpAndSettle();
      return;
    }

    await pressNumpadEnterWithIme(finder: finder, getter: getter);
  }

  Future<void> pressShiftNumpadEnter() async {
    await sendKeyDownEvent(LogicalKeyboardKey.shift,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.numpadEnter,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.numpadEnter,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.shift, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressTab() async {
    await sendKeyEvent(LogicalKeyboardKey.tab, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressBackspace() async {
    await sendKeyEvent(LogicalKeyboardKey.backspace,
        platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressCmdBackspace() async {
    await sendKeyDownEvent(LogicalKeyboardKey.meta,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.backspace,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.backspace,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.meta, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressAltBackspace() async {
    await sendKeyDownEvent(LogicalKeyboardKey.alt, platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.backspace,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.backspace,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.alt, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressCtlBackspace() async {
    await sendKeyDownEvent(LogicalKeyboardKey.control,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.backspace,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.backspace,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.control,
        platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressDelete() async {
    await sendKeyEvent(LogicalKeyboardKey.delete, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressCmdB() async {
    await sendKeyDownEvent(LogicalKeyboardKey.meta,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.keyB,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.keyB, platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.meta, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressCtlB() async {
    await sendKeyDownEvent(LogicalKeyboardKey.control,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.keyB,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.keyB, platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.control,
        platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressCmdC() async {
    await sendKeyDownEvent(LogicalKeyboardKey.meta,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.keyC,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.keyC, platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.meta, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressCtlC() async {
    await sendKeyDownEvent(LogicalKeyboardKey.control,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.keyC,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.keyC, platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.control,
        platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressCmdI() async {
    await sendKeyDownEvent(LogicalKeyboardKey.meta,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.keyI,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.keyI, platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.meta, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressCtlI() async {
    await sendKeyDownEvent(LogicalKeyboardKey.control,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.keyI,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.keyI, platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.control,
        platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressCmdX() async {
    await sendKeyDownEvent(LogicalKeyboardKey.meta,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.keyX,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.keyX, platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.meta, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressCtlX() async {
    await sendKeyDownEvent(LogicalKeyboardKey.control,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.keyX,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.keyX, platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.control,
        platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressCmdV() async {
    await sendKeyDownEvent(LogicalKeyboardKey.meta,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.keyV,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.keyV, platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.meta, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressCtlV() async {
    await sendKeyDownEvent(LogicalKeyboardKey.control,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.keyV,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.keyV, platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.control,
        platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressCmdA() async {
    await sendKeyDownEvent(LogicalKeyboardKey.meta,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.keyA,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.keyA, platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.meta, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressCtlA() async {
    await sendKeyDownEvent(LogicalKeyboardKey.control,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.keyA,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.keyA, platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.control,
        platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressCtlE() async {
    await sendKeyDownEvent(LogicalKeyboardKey.control,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.keyE,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.keyE, platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.control,
        platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressHome() async {
    await sendKeyDownEvent(LogicalKeyboardKey.home,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.home, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressEnd() async {
    await sendKeyDownEvent(LogicalKeyboardKey.end, platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.end, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressLeftArrow() async {
    await sendKeyEvent(LogicalKeyboardKey.arrowLeft,
        platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressShiftLeftArrow() async {
    await sendKeyDownEvent(LogicalKeyboardKey.shift,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.arrowLeft,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.arrowLeft,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.shift, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressAltLeftArrow() async {
    await sendKeyDownEvent(LogicalKeyboardKey.alt, platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.arrowLeft,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.arrowLeft,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.alt, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressShiftAltLeftArrow() async {
    await sendKeyDownEvent(LogicalKeyboardKey.shift,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.alt, platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.arrowLeft,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.arrowLeft,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.alt, platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.shift, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressCtlLeftArrow() async {
    await sendKeyDownEvent(LogicalKeyboardKey.control,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.arrowLeft,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.arrowLeft,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.control,
        platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressShiftCtlLeftArrow() async {
    await sendKeyDownEvent(LogicalKeyboardKey.shift,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.control,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.arrowLeft,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.arrowLeft,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.control,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.shift, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressCmdLeftArrow() async {
    await sendKeyDownEvent(LogicalKeyboardKey.meta,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.arrowLeft,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.arrowLeft,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.meta, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressShiftCmdLeftArrow() async {
    await sendKeyDownEvent(LogicalKeyboardKey.shift,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.meta,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.arrowLeft,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.arrowLeft,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.meta, platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.shift, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressRightArrow() async {
    await sendKeyEvent(LogicalKeyboardKey.arrowRight,
        platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressShiftRightArrow() async {
    await sendKeyDownEvent(LogicalKeyboardKey.shift,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.arrowRight,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.arrowRight,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.shift, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressAltRightArrow() async {
    await sendKeyDownEvent(LogicalKeyboardKey.alt, platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.arrowRight,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.arrowRight,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.alt, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressShiftAltRightArrow() async {
    await sendKeyDownEvent(LogicalKeyboardKey.shift,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.alt, platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.arrowRight,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.arrowRight,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.alt, platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.shift, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressCtlRightArrow() async {
    await sendKeyDownEvent(LogicalKeyboardKey.control,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.arrowRight,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.arrowRight,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.control,
        platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressShiftCtlRightArrow() async {
    await sendKeyDownEvent(LogicalKeyboardKey.shift,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.control,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.arrowRight,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.arrowRight,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.control,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.shift, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressCmdRightArrow() async {
    await sendKeyDownEvent(LogicalKeyboardKey.meta,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.arrowRight,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.arrowRight,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.meta, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressShiftCmdRightArrow() async {
    await sendKeyDownEvent(LogicalKeyboardKey.shift,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.meta,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.arrowRight,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.arrowRight,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.meta, platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.shift, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressUpArrow() async {
    await sendKeyEvent(LogicalKeyboardKey.arrowUp, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressShiftUpArrow() async {
    await sendKeyDownEvent(LogicalKeyboardKey.shift,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.arrowUp,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.arrowUp,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.shift, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressCmdUpArrow() async {
    await sendKeyDownEvent(LogicalKeyboardKey.meta,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.arrowUp,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.arrowUp,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.meta, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressShiftCmdUpArrow() async {
    await sendKeyDownEvent(LogicalKeyboardKey.shift,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.meta,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.arrowUp,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.arrowUp,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.meta, platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.shift, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressAltUpArrow() async {
    await sendKeyDownEvent(LogicalKeyboardKey.alt, platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.arrowUp,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.arrowUp,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.alt, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressShiftAltUpArrow() async {
    await sendKeyDownEvent(LogicalKeyboardKey.shift,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.alt, platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.arrowUp,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.arrowUp,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.alt, platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.shift, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressDownArrow() async {
    await sendKeyEvent(LogicalKeyboardKey.arrowDown,
        platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressShiftDownArrow() async {
    await sendKeyDownEvent(LogicalKeyboardKey.shift,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.arrowDown,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.arrowDown,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.shift, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressCmdDownArrow() async {
    await sendKeyDownEvent(LogicalKeyboardKey.meta,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.arrowDown,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.arrowDown,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.meta, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressShiftCmdDownArrow() async {
    await sendKeyDownEvent(LogicalKeyboardKey.shift,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.meta,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.arrowDown,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.arrowDown,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.meta, platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.shift, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressAltDownArrow() async {
    await sendKeyDownEvent(LogicalKeyboardKey.alt, platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.arrowDown,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.arrowDown,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.alt, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressShiftAltDownArrow() async {
    await sendKeyDownEvent(LogicalKeyboardKey.shift,
        platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.alt, platform: _keyEventPlatform);
    await sendKeyDownEvent(LogicalKeyboardKey.arrowDown,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.arrowDown,
        platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.alt, platform: _keyEventPlatform);
    await sendKeyUpEvent(LogicalKeyboardKey.shift, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressEscape() async {
    await sendKeyEvent(LogicalKeyboardKey.escape, platform: _keyEventPlatform);
    await pumpAndSettle();
  }

  Future<void> pressCmdHome(WidgetTester tester) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.meta,
        platform: _keyEventPlatform);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.home,
        platform: _keyEventPlatform);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.meta,
        platform: _keyEventPlatform);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.home,
        platform: _keyEventPlatform);
    await tester.pumpAndSettle();
  }

  Future<void> pressCmdEnd(WidgetTester tester) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.meta,
        platform: _keyEventPlatform);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.end,
        platform: _keyEventPlatform);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.meta,
        platform: _keyEventPlatform);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.end,
        platform: _keyEventPlatform);
    await tester.pumpAndSettle();
  }

  Future<void> pressCtrlHome(WidgetTester tester) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.control,
        platform: _keyEventPlatform);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.home,
        platform: _keyEventPlatform);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.control,
        platform: _keyEventPlatform);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.home,
        platform: _keyEventPlatform);
    await tester.pumpAndSettle();
  }

  Future<void> pressCtrlEnd(WidgetTester tester) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.control,
        platform: _keyEventPlatform);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.end,
        platform: _keyEventPlatform);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.control,
        platform: _keyEventPlatform);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.end,
        platform: _keyEventPlatform);
    await tester.pumpAndSettle();
  }

  Future<void> pressCmdZ(WidgetTester tester) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.meta,
        platform: _keyEventPlatform);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyZ,
        platform: _keyEventPlatform);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyZ,
        platform: _keyEventPlatform);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.meta,
        platform: _keyEventPlatform);
  }

  Future<void> pressCtrlZ(WidgetTester tester) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.control,
        platform: _keyEventPlatform);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyZ,
        platform: _keyEventPlatform);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyZ,
        platform: _keyEventPlatform);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.control,
        platform: _keyEventPlatform);
  }

  Future<void> pressCmdShiftZ(WidgetTester tester) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.meta,
        platform: _keyEventPlatform);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shift,
        platform: _keyEventPlatform);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyZ,
        platform: _keyEventPlatform);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyZ,
        platform: _keyEventPlatform);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shift,
        platform: _keyEventPlatform);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.meta,
        platform: _keyEventPlatform);
  }

  Future<void> pressCtrlShiftZ(WidgetTester tester) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.control,
        platform: _keyEventPlatform);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shift,
        platform: _keyEventPlatform);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyZ,
        platform: _keyEventPlatform);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyZ,
        platform: _keyEventPlatform);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shift,
        platform: _keyEventPlatform);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.control,
        platform: _keyEventPlatform);
  }
}

String get _keyEventPlatform {
  if (keyEventPlatformOverride != null) {
    return keyEventPlatformOverride!;
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return "android";
    case TargetPlatform.iOS:
      return "ios";
    case TargetPlatform.macOS:
      return "macos";
    case TargetPlatform.windows:
      return "windows";
    case TargetPlatform.fuchsia:
    case TargetPlatform.linux:
      return "linux";
  }
}

/// Override for the `platform` value that's passed to every key simulation event.
///
/// When `null`, Flutter's `defaultTargetPlatform` determines the `platform` value
/// that's passed to every key simulation event.
///
/// It is your responsibility to nullify this value when you're done with your
/// platform overrides.
String? keyEventPlatformOverride;

/// Returns a physical keyboard key combination that expects to create the
/// given [character].
_KeyCombo _keyComboForCharacter(String character) {
  if (_charactersToKey.containsKey(character)) {
    return _KeyCombo(_charactersToKey[character]!);
  }
  if (_shiftCharactersToKey.containsKey(character)) {
    final physicalKey = _enUSShiftCharactersToPhysicalKey[character] ??
        _shiftCharactersToKey[character]!;

    return _KeyCombo(
      _shiftCharactersToKey[character]!,
      isShiftPressed: true,
      physicalKey: physicalKey,
    );
  }

  throw Exception("Couldn't convert '$character' to a key combo.");
}

const _charactersToKey = {
  'a': LogicalKeyboardKey.keyA,
  'b': LogicalKeyboardKey.keyB,
  'c': LogicalKeyboardKey.keyC,
  'd': LogicalKeyboardKey.keyD,
  'e': LogicalKeyboardKey.keyE,
  'f': LogicalKeyboardKey.keyF,
  'g': LogicalKeyboardKey.keyG,
  'h': LogicalKeyboardKey.keyH,
  'i': LogicalKeyboardKey.keyI,
  'j': LogicalKeyboardKey.keyJ,
  'k': LogicalKeyboardKey.keyK,
  'l': LogicalKeyboardKey.keyL,
  'm': LogicalKeyboardKey.keyM,
  'n': LogicalKeyboardKey.keyN,
  'o': LogicalKeyboardKey.keyO,
  'p': LogicalKeyboardKey.keyP,
  'q': LogicalKeyboardKey.keyQ,
  'r': LogicalKeyboardKey.keyR,
  's': LogicalKeyboardKey.keyS,
  't': LogicalKeyboardKey.keyT,
  'u': LogicalKeyboardKey.keyU,
  'v': LogicalKeyboardKey.keyV,
  'w': LogicalKeyboardKey.keyW,
  'x': LogicalKeyboardKey.keyX,
  'y': LogicalKeyboardKey.keyY,
  'z': LogicalKeyboardKey.keyZ,
  ' ': LogicalKeyboardKey.space,
  '0': LogicalKeyboardKey.digit0,
  '1': LogicalKeyboardKey.digit1,
  '2': LogicalKeyboardKey.digit2,
  '3': LogicalKeyboardKey.digit3,
  '4': LogicalKeyboardKey.digit4,
  '5': LogicalKeyboardKey.digit5,
  '6': LogicalKeyboardKey.digit6,
  '7': LogicalKeyboardKey.digit7,
  '8': LogicalKeyboardKey.digit8,
  '9': LogicalKeyboardKey.digit9,
  '`': LogicalKeyboardKey.backquote,
  '-': LogicalKeyboardKey.minus,
  '=': LogicalKeyboardKey.equal,
  '[': LogicalKeyboardKey.bracketLeft,
  ']': LogicalKeyboardKey.bracketRight,
  '\\': LogicalKeyboardKey.backslash,
  ';': LogicalKeyboardKey.semicolon,
  '\'': LogicalKeyboardKey.quoteSingle,
  ',': LogicalKeyboardKey.comma,
  '.': LogicalKeyboardKey.period,
  '/': LogicalKeyboardKey.slash,
};

const _shiftCharactersToKey = {
  'A': LogicalKeyboardKey.keyA,
  'B': LogicalKeyboardKey.keyB,
  'C': LogicalKeyboardKey.keyC,
  'D': LogicalKeyboardKey.keyD,
  'E': LogicalKeyboardKey.keyE,
  'F': LogicalKeyboardKey.keyF,
  'G': LogicalKeyboardKey.keyG,
  'H': LogicalKeyboardKey.keyH,
  'I': LogicalKeyboardKey.keyI,
  'J': LogicalKeyboardKey.keyJ,
  'K': LogicalKeyboardKey.keyK,
  'L': LogicalKeyboardKey.keyL,
  'M': LogicalKeyboardKey.keyM,
  'N': LogicalKeyboardKey.keyN,
  'O': LogicalKeyboardKey.keyO,
  'P': LogicalKeyboardKey.keyP,
  'Q': LogicalKeyboardKey.keyQ,
  'R': LogicalKeyboardKey.keyR,
  'S': LogicalKeyboardKey.keyS,
  'T': LogicalKeyboardKey.keyT,
  'U': LogicalKeyboardKey.keyU,
  'V': LogicalKeyboardKey.keyV,
  'W': LogicalKeyboardKey.keyW,
  'X': LogicalKeyboardKey.keyX,
  'Y': LogicalKeyboardKey.keyY,
  'Z': LogicalKeyboardKey.keyZ,
  '!': LogicalKeyboardKey.exclamation,
  '@': LogicalKeyboardKey.at,
  '#': LogicalKeyboardKey.numberSign,
  '\$': LogicalKeyboardKey.dollar,
  '%': LogicalKeyboardKey.percent,
  '^': LogicalKeyboardKey.caret,
  '&': LogicalKeyboardKey.ampersand,
  '*': LogicalKeyboardKey.asterisk,
  '(': LogicalKeyboardKey.parenthesisLeft,
  ')': LogicalKeyboardKey.parenthesisRight,
  '~': LogicalKeyboardKey.tilde,
  '_': LogicalKeyboardKey.underscore,
  '+': LogicalKeyboardKey.add,
  '{': LogicalKeyboardKey.braceLeft,
  '}': LogicalKeyboardKey.braceRight,
  '|': LogicalKeyboardKey.bar,
  ':': LogicalKeyboardKey.colon,
  '"': LogicalKeyboardKey.quote,
  '<': LogicalKeyboardKey.less,
  '>': LogicalKeyboardKey.greater,
  '?': LogicalKeyboardKey.question,
};

/// A mapping of shift characters to physical keys on en_US keyboards
const _enUSShiftCharactersToPhysicalKey = {
  '!': LogicalKeyboardKey.digit1,
  '@': LogicalKeyboardKey.digit2,
  '#': LogicalKeyboardKey.digit3,
  '\$': LogicalKeyboardKey.digit4,
  '%': LogicalKeyboardKey.digit5,
  '^': LogicalKeyboardKey.digit6,
  '&': LogicalKeyboardKey.digit7,
  '*': LogicalKeyboardKey.digit8,
  '(': LogicalKeyboardKey.digit9,
  ')': LogicalKeyboardKey.digit0,
  '~': LogicalKeyboardKey.backquote,
  '_': LogicalKeyboardKey.minus,
  '+': LogicalKeyboardKey.equal,
  '{': LogicalKeyboardKey.bracketLeft,
  '}': LogicalKeyboardKey.bracketRight,
  '|': LogicalKeyboardKey.backslash,
  ':': LogicalKeyboardKey.semicolon,
  '"': LogicalKeyboardKey.quoteSingle,
  '<': LogicalKeyboardKey.comma,
  '>': LogicalKeyboardKey.period,
  '?': LogicalKeyboardKey.slash,
};

/// A combination of pressed keys, including a logical key, and possibly one or
/// more modifier keys, such as "shift".
class _KeyCombo {
  _KeyCombo(
    this.key, {
    this.isShiftPressed = false,
    this.physicalKey,
  }) : assert(isShiftPressed ? physicalKey != null : physicalKey == null);

  final LogicalKeyboardKey key;
  final bool isShiftPressed;
  final LogicalKeyboardKey? physicalKey;
}
