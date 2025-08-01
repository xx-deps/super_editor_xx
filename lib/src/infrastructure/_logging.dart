// ignore_for_file: avoid_print

import 'package:logging/logging.dart' as logging;

export 'package:logging/logging.dart' show Level;

class SuperEditorLoggerName {
  static const editor = 'editor';
  static const editorEdits = 'editor.edits';
  static const editorPolicies = 'editor.policies';
  static const editorScrolling = 'editor.scrolling';
  static const editorGestures = 'editor.gestures';
  static const editorKeys = 'editor.keys';
  static const editorIme = 'editor.ime';
  static const editorImeConnection = 'editor.ime.connection';
  static const editorImeDeltas = 'editor.ime.deltas';
  static const editorIosFloatingCursor = 'editor.ios.floatingCursor';
  static const editorLayout = 'editor.layout';
  static const editorStyle = 'editor.style';
  static const editorDocument = 'editor.document';
  static const editorCommonOps = 'editor.ops';
  static const editorTokens = 'editor.tokens';
  static const editorTags = 'editor.tokens.tags';
  static const editorUserTags = 'editor.tokens.tags.users';
  static const editorHashTags = 'editor.tokens.tags.hash';
  static const editorActionTags = 'editor.tokens.tags.action';
  static const editorSpellingAndGrammar = 'editor.spellingAndGrammar';

  static const reader = 'reader';
  static const readerScrolling = 'reader.scrolling';
  static const readerGestures = 'reader.gestures';
  static const readerKeys = 'reader.keys';
  static const readerIme = 'reader.ime';
  static const readerLayout = 'reader.layout';
  static const readerStyle = 'reader.style';
  static const readerDocument = 'reader.document';
  static const readerCommonOps = 'reader.ops';

  static const documentGestures = 'document.gestures';

  static const textField = 'textfield';
  static const scrollingTextField = 'textfield.scrolling';
  static const imeTextField = 'textfield.ime';
  static const androidTextField = 'textfield.android';
  static const iosTextField = 'textfield.ios';

  static const infrastructure = 'infrastructure';
  static const keyboardPanel = 'infrastructure.keyboardPanel';
  static const longPressSelection = 'infrastructure.gestures.longPress';
  static const scheduler = 'infrastructure.scheduler';
  static const contentLayers = 'infrastructure.content_layers';
  static const attributions = 'infrastructure.attributions';
}

// Chat
final messagePageElementLog = logging.Logger('chat.messagePage.element');
final messagePageLayoutLog = logging.Logger('chat.messagePage.layout');
final messagePagePaintLog = logging.Logger('chat.messagePage.paint');
final messageEditorHeightLog = logging.Logger('chat.messagePage.editorHeight');

// Super Editor
final editorLog = logging.Logger(SuperEditorLoggerName.editor);
final editorEditsLog = logging.Logger(SuperEditorLoggerName.editorEdits);
final editorPoliciesLog = logging.Logger(SuperEditorLoggerName.editorPolicies);
final editorScrollingLog = logging.Logger(
  SuperEditorLoggerName.editorScrolling,
);
final editorGesturesLog = logging.Logger(SuperEditorLoggerName.editorGestures);
final editorKeyLog = logging.Logger(SuperEditorLoggerName.editorKeys);
final editorImeLog = logging.Logger(SuperEditorLoggerName.editorIme);
final editorImeConnectionLog = logging.Logger(
  SuperEditorLoggerName.editorImeConnection,
);
final editorImeDeltasLog = logging.Logger(
  SuperEditorLoggerName.editorImeDeltas,
);
final editorIosFloatingCursorLog = logging.Logger(
  SuperEditorLoggerName.editorIosFloatingCursor,
);
final editorLayoutLog = logging.Logger(SuperEditorLoggerName.editorLayout);
final editorStyleLog = logging.Logger(SuperEditorLoggerName.editorStyle);
final editorDocLog = logging.Logger(SuperEditorLoggerName.editorDocument);
final editorOpsLog = logging.Logger(SuperEditorLoggerName.editorCommonOps);
final editorTokensLog = logging.Logger(SuperEditorLoggerName.editorTokens);
final editorTagsLog = logging.Logger(SuperEditorLoggerName.editorTags);
final editorStableTagsLog = logging.Logger(
  SuperEditorLoggerName.editorUserTags,
);
final editorPatternTagsLog = logging.Logger(
  SuperEditorLoggerName.editorHashTags,
);
final editorActionTagsLog = logging.Logger(
  SuperEditorLoggerName.editorActionTags,
);
final editorSpellingAndGrammarLog = logging.Logger(
  SuperEditorLoggerName.editorSpellingAndGrammar,
);

// Super Reader
final readerLog = logging.Logger(SuperEditorLoggerName.reader);
final readerScrollingLog = logging.Logger(
  SuperEditorLoggerName.readerScrolling,
);
final readerGesturesLog = logging.Logger(SuperEditorLoggerName.readerGestures);
final readerKeyLog = logging.Logger(SuperEditorLoggerName.readerKeys);
final readerImeLog = logging.Logger(SuperEditorLoggerName.readerIme);
final readerLayoutLog = logging.Logger(SuperEditorLoggerName.readerLayout);
final readerStyleLog = logging.Logger(SuperEditorLoggerName.readerStyle);
final readerDocLog = logging.Logger(SuperEditorLoggerName.readerDocument);
final readerOpsLog = logging.Logger(SuperEditorLoggerName.readerCommonOps);

final textFieldLog = logging.Logger(SuperEditorLoggerName.textField);
final scrollingTextFieldLog = logging.Logger(
  SuperEditorLoggerName.scrollingTextField,
);
final imeTextFieldLog = logging.Logger(SuperEditorLoggerName.imeTextField);
final androidTextFieldLog = logging.Logger(
  SuperEditorLoggerName.androidTextField,
);
final iosTextFieldLog = logging.Logger(SuperEditorLoggerName.iosTextField);

final docGesturesLog = logging.Logger(SuperEditorLoggerName.documentGestures);
final infrastructureLog = logging.Logger(SuperEditorLoggerName.infrastructure);
final keyboardPanelLog = logging.Logger(SuperEditorLoggerName.keyboardPanel);
final longPressSelectionLog = logging.Logger(
  SuperEditorLoggerName.longPressSelection,
);
final schedulerLog = logging.Logger(SuperEditorLoggerName.scheduler);
final contentLayersLog = logging.Logger(SuperEditorLoggerName.contentLayers);
final attributionsLog = logging.Logger(SuperEditorLoggerName.attributions);

final _activeLoggers = <logging.Logger>{};

void initAllLogs(logging.Level level) {
  initLoggers(level, {logging.Logger.root});
}

void initLoggers(logging.Level level, Set<logging.Logger> loggers) {
  logging.hierarchicalLoggingEnabled = true;

  for (final logger in loggers) {
    if (!_activeLoggers.contains(logger)) {
      print('Initializing logger: ${logger.name}');
      logger
        ..level = level
        ..onRecord.listen(printLog);

      _activeLoggers.add(logger);
    }
  }
}

/// Returns `true` if the given [logger] is currently logging, or
/// `false` otherwise.
///
/// Generally, developers should call loggers, regardless of whether
/// a given logger is active. However, sometimes you may want to log
/// information that's costly to compute. In such a case, you can
/// choose to compute the expensive information only if the given
/// logger will actually log the information.
bool isLogActive(logging.Logger logger) {
  return _activeLoggers.contains(logger);
}

void deactivateLoggers(Set<logging.Logger> loggers) {
  for (final logger in loggers) {
    if (_activeLoggers.contains(logger)) {
      print('Deactivating logger: ${logger.name}');
      logger.clearListeners();

      _activeLoggers.remove(logger);
    }
  }
}

void printLog(logging.LogRecord record) {
  print(
    '(${record.time.second}.${record.time.millisecond.toString().padLeft(3, '0')}) ${record.loggerName} > ${record.level.name}: ${record.message}',
  );
}

// TODO: get rid of this custom Logger when all references are replaced with logging package
class Logger {
  static bool _printLogs = false;
  static void setLoggingMode(bool enabled) {
    _printLogs = enabled;
  }

  Logger({required scope}) : _scope = scope;

  final String _scope;

  void log(String tag, String message, [Exception? exception]) {
    if (!Logger._printLogs) {
      return;
    }

    print('[$_scope] - $tag: $message');
    if (exception != null) {
      print(' - ${exception.toString()}');
    }
  }
}
