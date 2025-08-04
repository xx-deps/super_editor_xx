import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_editor/super_editor.dart';
part 'focus.dart';
// class MacNoProxyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     var client = super.createHttpClient(context);
//     client.findProxy = (uri) => 'DIRECT';
//     client.connectionTimeout = Duration(seconds: 10);
//     // 忽略证书错误（仅用于开发）
//     client.badCertificateCallback =
//         (X509Certificate cert, String host, int port) => true;
//     return client;
//   }
// }

class MenuDemo extends StatelessWidget {
  const MenuDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Super Editor Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const EditorPage(),
    );
  }
}

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  late MutableDocument _document;
  late MutableDocumentComposer _composer;
  late Editor _editor;
  late FocusNode _editorFocusNode;

  OverlayEntry? _contextMenu;

  bool get _hasSelection => (_composer.selection?.isCollapsed ?? true) == false;

  final GlobalKey<SuperEditorState> _editorKey = GlobalKey<SuperEditorState>();

  @override
  void initState() {
    super.initState();

    _document = MutableDocument(
      nodes: [
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText(
            '在遥远的森林深处，有一颗迷路的小星星，它从天上掉了下来，落在了树叶上。小星星叫做闪闪，它很想回到夜空，但不知道该怎么做。',
          ),
        ),
        ImageNode(
          id: Editor.createNodeId(),
          imageUrl:
              "https://web.oopz.cn/web/0062067df94c7tgk9/splash/img/light-background.png",
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText(
            '森林里的小动物们看见了闪闪，都很喜欢它。聪明的小兔子说：“我们一起帮闪闪回家吧！”小松鼠带来了几颗坚果，说：“闪闪，吃点东西补充能量。”小狐狸用尾巴画了个大圈，说：“也许这是个魔法阵，可以帮你飞起来。”',
          ),
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText(
            '可是，夜晚很快就过去了，闪闪还是没有飞回去。最后，温柔的老猫头鹰说：“真正的光来自心里，只要你相信自己，就能找到回家的路。”',
          ),
        ),
      ],
    );

    _composer = MutableDocumentComposer();
    _editorFocusNode = FocusNode(debugLabel: '_editorFocusNode');
    _editorFocusNode.addListener(_onFocusChanged);
    _editor = createDefaultDocumentEditor(
      document: _document,
      composer: _composer,
      isHistoryEnabled: true,
    );
  }

  void _onFocusChanged() {
    print('editor focus ${_editorFocusNode.hasFocus} ');
  }

  @override
  void dispose() {
    _contextMenu?.remove();
    _editorFocusNode.removeListener(_onFocusChanged);
    _editorFocusNode.dispose();
    super.dispose();
  }

  void _showContextMenu(BuildContext context, Offset globalPosition) {
    _hideContextMenu();
    final overlay = Overlay.of(context, rootOverlay: true);
    _contextMenu = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 透明点击区域，用于点击外部关闭菜单
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _hideContextMenu();
              },
              onSecondaryTap: () {
                _hideContextMenu();
              },
              child: const SizedBox.expand(),
            ),
          ),
          // 菜单本体
          Positioned(
            left: globalPosition.dx,
            top: globalPosition.dy,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(4),
              child: IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_hasSelection)
                      _buildMenuItem('复制', () {
                        _copyContent();
                        _hideContextMenu();
                      }),
                    _buildMenuItem('粘贴', () {
                      _pasteContent();
                      _hideContextMenu();
                    }),
                    _buildMenuItem('撤销', () {
                      _undo();
                      _hideContextMenu();
                    }),
                    _buildMenuItem('重做', () {
                      _redo();
                      _hideContextMenu();
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(_contextMenu!);
  }

  void _hideContextMenu() {
    _contextMenu?.remove();
    _contextMenu = null;
  }

  Widget _buildMenuItem(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Text(text),
      ),
    );
  }

  String _inputText = '';
  String _markdownText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Super Editor Demo')),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onSecondaryTapUp: (details) {
          _showContextMenu(context, details.globalPosition);
        },
        onTap: _hideContextMenu,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 200,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        final markdown = serializeDocumentToMarkdown(_document);
                        _markdownText = markdown;
                        print(markdown);
                      },
                      child: Text('导出markdown'),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Markdown',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        // 可以在这里处理输入的Markdown文本
                        _inputText = value;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          final document = deserializeMarkdownToDocument(
                            _inputText,
                          );
                          print(document);
                          _document = document;
                          _composer = MutableDocumentComposer();
                          _editorFocusNode = FocusNode();

                          _editor = createDefaultDocumentEditor(
                            document: _document,
                            composer: _composer,
                            isHistoryEnabled: true,
                          );
                        });
                      },
                      child: Text('导入markdown'),
                    ),
                    FocusButton(),
                    TextField(),
                  ],
                ),
              ),
            ),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.amber),
                child: SizedBox(
                  height: 800,
                  child: TapRegion(
                    onTapOutside: (event) {
                      _editorFocusNode.unfocus();
                    },
                    child: SuperEditor(
                      key: _editorKey,
                      editor: _editor,
                      focusNode: _editorFocusNode,
                      selectionPolicies: const SuperEditorSelectionPolicies(
                        clearSelectionWhenEditorLosesFocus: false,
                      ),
                      plugins: {XXMenuPlugin()},
                      inputSource: TextInputSource.ime,
                      stylesheet: defaultStylesheet.copyWith(
                        addRulesAfter: [
                          StyleRule(BlockSelector.all, (doc, docNode) {
                            return {
                              Styles.padding: const CascadingPadding.symmetric(
                                vertical: 4.0,
                              ),
                            };
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyContent() {
    final selection = _composer.selection;
    if (selection?.isCollapsed ?? true) {
      return;
    }
    _editorKey.currentState?.editContext.commonOps.copy();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已复制')));
  }

  void _pasteContent() {
    _editorKey.currentState?.editContext.commonOps.paste();
  }

  void _undo() => _editor.undo();
  void _redo() => _editor.redo();
}

ExecutionInstruction enterToInsertBlockNewline({
  required SuperEditorContext editContext,
  required KeyEvent keyEvent,
}) {
  if (keyEvent is! KeyDownEvent && keyEvent is! KeyRepeatEvent) {
    return ExecutionInstruction.continueExecution;
  }

  if (keyEvent.logicalKey != LogicalKeyboardKey.enter &&
      keyEvent.logicalKey != LogicalKeyboardKey.numpadEnter) {
    return ExecutionInstruction.continueExecution;
  }

  // editContext.editor.execute([
  //   InsertNewlineAtCaretRequest(Editor.createNodeId()),
  // ]);

  return ExecutionInstruction.haltExecution;
}

ExecutionInstruction copyWhenCmdCIsPressed({
  required SuperEditorContext editContext,
  required KeyEvent keyEvent,
}) {
  if (keyEvent is! KeyDownEvent && keyEvent is! KeyRepeatEvent) {
    return ExecutionInstruction.continueExecution;
  }

  if (!keyEvent.isPrimaryShortcutKeyPressed ||
      keyEvent.logicalKey != LogicalKeyboardKey.keyC) {
    return ExecutionInstruction.continueExecution;
  }
  if (editContext.composer.selection == null) {
    return ExecutionInstruction.continueExecution;
  }
  if (editContext.composer.selection!.isCollapsed) {
    // Nothing to copy, but we technically handled the task.
    return ExecutionInstruction.haltExecution;
  }

  editContext.commonOps.copy();

  return ExecutionInstruction.haltExecution;
}

ExecutionInstruction cutWhenCmdXIsPressed({
  required SuperEditorContext editContext,
  required KeyEvent keyEvent,
}) {
  if (keyEvent is! KeyDownEvent && keyEvent is! KeyRepeatEvent) {
    return ExecutionInstruction.continueExecution;
  }

  if (!keyEvent.isPrimaryShortcutKeyPressed ||
      keyEvent.logicalKey != LogicalKeyboardKey.keyX) {
    return ExecutionInstruction.continueExecution;
  }
  if (editContext.composer.selection == null) {
    return ExecutionInstruction.continueExecution;
  }
  if (editContext.composer.selection!.isCollapsed) {
    // Nothing to cut, but we technically handled the task.
    return ExecutionInstruction.haltExecution;
  }

  editContext.commonOps.cut();

  return ExecutionInstruction.haltExecution;
}

ExecutionInstruction pasteWhenCmdVIsPressed({
  required SuperEditorContext editContext,
  required KeyEvent keyEvent,
}) {
  if (keyEvent is! KeyDownEvent && keyEvent is! KeyRepeatEvent) {
    return ExecutionInstruction.continueExecution;
  }

  if (!keyEvent.isPrimaryShortcutKeyPressed ||
      keyEvent.logicalKey != LogicalKeyboardKey.keyV) {
    return ExecutionInstruction.continueExecution;
  }
  if (editContext.composer.selection == null) {
    return ExecutionInstruction.continueExecution;
  }

  editContext.commonOps.paste();

  return ExecutionInstruction.haltExecution;
}

class XXMenuPlugin extends SuperEditorPlugin {
  XXMenuPlugin();

  @override
  List<DocumentKeyboardAction> get keyboardActions => [
    enterToInsertBlockNewline,
    copyWhenCmdCIsPressed,
    cutWhenCmdXIsPressed,
    pasteWhenCmdVIsPressed,
  ];

  @override
  void attach(Editor editor) {}
}
