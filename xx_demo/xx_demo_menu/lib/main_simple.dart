import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';

class DemoSimple extends StatelessWidget {
  const DemoSimple({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Super Editor Simple',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PageView(
        // scrollDirection: Axis.vertical,
        children: [
          Column(
            children: [
              SizedBox(width: 100, height: 200, child: const EditorPage()),
            ],
          ),
          SizedBox(width: 100, height: 200),
        ],
      ),
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
    _editorFocusNode.removeListener(_onFocusChanged);
    _editorFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
    );
  }
}
