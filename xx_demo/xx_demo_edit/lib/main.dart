import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:super_editor/super_editor.dart';
import 'package:xx_demo_edit/customer_command.dart';
import 'package:xx_demo_edit/customer_image_builder.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // late MutableDocument _doc;
  late MutableDocumentComposer _composer;
  late Editor _docEditor;

  late FocusNode _focusNode;

  late final StableTagPlugin _userTagPlugin;

  bool _hasFocus = false;

  final _composingLink = LeaderLink();

  @override
  void initState() {
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      print('_focusNode:${_focusNode.hasFocus}');
      _hasFocus = _focusNode.hasFocus;
      // setState(() {});
    });

    // _doc = _createDocument();
    _composer = MutableDocumentComposer()..addListener(() {});
    _docEditor = createDefaultDocumentEditor(
      // document: _doc,
      composer: _composer,
      isHistoryEnabled: false,
      isStateHistoryEnable: true,
      // historyGroupingPolicy: HistoryGroupingPolicyList([
      //   // _NeverMergePolicy()
      //   // mergeRepeatSelectionChangesPolicy,
      //   // mergeRapidTextInputPolicy,
      //   // ignorePureSelectionOnlyChangesPolicy,
      // ]),
    );

    _userTagPlugin = StableTagPlugin()
      ..tagIndex.composingStableTag.addListener(onTagChange)
      ..tagIndex.addListener(onTagChange);

    super.initState();
  }

  void onTagChange() {
    print('_userTagPlugin:${_userTagPlugin.tagIndex.composingStableTag.value}');
    // setState(() {});
  }

  Editor createDefaultDocumentEditor({
    // required MutableDocument document,
    required MutableDocumentComposer composer,
    HistoryGroupingPolicy historyGroupingPolicy = defaultMergePolicy,
    bool isHistoryEnabled = true,
    bool isStateHistoryEnable = false,
  }) {
    final editor = Editor(
      editables: {
        Editor.documentKey: MutableDocument.empty(),
        Editor.composerKey: composer,
      },
      requestHandlers: [
        (editor, request) => request is InsertImageCommandRequest
            ? InsertImageCommand(
                url: request.url,
                expectedSize: request.expectedSize,
              )
            : null,
        ...defaultRequestHandlers,
      ],
      // historyGroupingPolicy: historyGroupingPolicy,
      reactionPipeline: List.from(defaultEditorReactions),
      // isHistoryEnabled: isHistoryEnabled,
      isStateHistoryEnable: isStateHistoryEnable,
    );

    return editor;
  }

  void _bold() {
    final selection = _docEditor.composer.selection;
    if (selection == null) {
      return;
    }

    _docEditor.execute([
      ToggleTextAttributionsRequest(
        attributions: {NamedAttribution('bold')},
        documentRange: selection,
      ),
    ]);
  }

  void _italic() {
    final selection = _docEditor.composer.selection;
    if (selection == null) {
      return;
    }

    _docEditor.execute([
      ToggleTextAttributionsRequest(
        attributions: {NamedAttribution('italics')},
        documentRange: selection,
      ),
    ]);
  }

  void _delete() {
    final selection = _docEditor.composer.selection;
    if (selection == null) {
      return;
    }

    _docEditor.execute([
      ToggleTextAttributionsRequest(
        attributions: {NamedAttribution('strikethrough')},
        documentRange: selection,
      ),
    ]);
  }

  void _underLine() {
    final selection = _docEditor.composer.selection;
    if (selection == null) {
      return;
    }

    _docEditor.execute([
      ToggleTextAttributionsRequest(
        attributions: {NamedAttribution('underline')},
        documentRange: selection,
      ),
    ]);
  }

  Future<void> _insertImage() async {
    /// todo 这里还需要分选中和不选中空白的情况
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) return;
    final path = image.path;

    if (path.isEmpty) return;

    _docEditor.execute([InsertImageCommandRequest(url: path)]);
  }

  MutableDocument _createDocument() {
    return MutableDocument(
      nodes: [
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText('Document #1'),
          metadata: {'blockType': header1Attribution},
        ),
        ParagraphNode(id: Editor.createNodeId(), text: AttributedText('test')),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 500,
                    decoration: BoxDecoration(
                      border: _hasFocus
                          ? Border.all(
                              color: Colors.blue, // 边框颜色
                              width: 1, // 边框宽度
                              style: BorderStyle.solid, // 边框样式（实线）
                            )
                          : null,
                      borderRadius: BorderRadius.circular(8.0), // 圆角半径
                    ),
                    child: Center(
                      child: SuperEditor(
                        editor: _docEditor,
                        focusNode: _focusNode,
                        inputSource: TextInputSource.ime,
                        stylesheet: defaultStylesheet.copyWith(
                          documentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 0,
                          ),
                          inlineTextStyler: (attributions, existingStyle) {
                            TextStyle style = defaultInlineTextStyler(
                              attributions,
                              existingStyle,
                            );
                            if (attributions
                                .whereType<CommittedStableTagAttribution>()
                                .isNotEmpty) {
                              style = style.copyWith(color: Colors.orange);
                            }
                            return style;
                          },
                        ),
                        componentBuilders: [
                          HintComponentBuilder(
                            "请输入内容...",
                            (context) => TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                          ),
                          // BlockquoteComponentBuilder(),
                          ParagraphComponentBuilder(),
                          // ListItemComponentBuilder(),
                          CustomerImageComponentBuilder(),
                          // HorizontalRuleComponentBuilder(),
                        ],

                        plugins: {_userTagPlugin},
                        documentOverlayBuilders: [
                          DefaultCaretOverlayBuilder(),
                          // MentionOverlayBuilder(showDebugTag: true),
                          AttributedTextBoundsOverlay(
                            selector: (a) => a == stableTagComposingAttribution,
                            builder: (context, attribution) {
                              return Leader(
                                link: _composingLink,
                                child: const SizedBox(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        _focusNode.unfocus();
                      },
                      child: SizedBox.expand(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(onPressed: _bold, child: Text('B')),
                            TextButton(onPressed: _italic, child: Text('I')),
                            TextButton(onPressed: _delete, child: Text('D')),
                            TextButton(onPressed: _underLine, child: Text('U')),
                            TextButton(
                              onPressed: () async {
                                await _insertImage();
                              },
                              child: Text('添加图片'),
                            ),
                            TextButton(
                              onPressed: () {
                                _docEditor.resetEditor();
                                // _docEditor.execute([ClearDocumentRequest()]);
                              },
                              child: Text("notext"),
                            ),
                            TextButton(
                              onPressed: () {
                                // _docEditor.resetEditor();

                                final documentNew =
                                    deserializeMarkdownToDocument("啊哈哈哈哈哈哈");
                                _docEditor.resetAndLoadDocument(documentNew);
                                // _docEditor.resetAndLoadDocument(documentNew);
                                // _docEditor.execute([
                                //   ...documentNew.map(
                                //     (e) => InsertNodeAtEndOfDocumentRequest(e),
                                //   ),
                                // ]);
                                // _docEditor.execute([
                                //   ChangeSelectionRequest(
                                //     DocumentSelection.collapsed(
                                //       position: DocumentPosition(
                                //         nodeId: _docEditor.document.last.id,
                                //         nodePosition: _docEditor
                                //             .document
                                //             .last
                                //             .endPosition,
                                //       ),
                                //     ),
                                //     SelectionChangeType.insertContent,
                                //     SelectionReason.userInteraction,
                                //   ),
                                // ]);
                              },

                              child: Text("text"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_userTagPlugin.tagIndex.composingStableTag.value != null)
              Follower.withOffset(
                link: _composingLink,
                offset: Offset(0, 16),
                leaderAnchor: Alignment.bottomCenter,
                followerAnchor: Alignment.topCenter,
                showWhenUnlinked: false,
                child: GestureDetector(
                  onTap: () {
                    _docEditor.execute([
                      FillInComposingStableTagRequest('你好哦', userTagRule),
                    ]);
                    final markdown = serializeDocumentToMarkdown(
                      _docEditor.document,
                    );
                    print(markdown);
                  },
                  child: Container(
                    height: 300,
                    width: 300,
                    color: Colors.yellow,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
