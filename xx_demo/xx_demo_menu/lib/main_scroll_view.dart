import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';

class DemoScrollView extends StatelessWidget {
  const DemoScrollView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Super Editor Scroll',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(body: EditorLayout()),
    );
  }
}

class EditorLayout extends StatelessWidget {
  const EditorLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 100, color: Colors.blue, width: 20),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 100),
          child: EditorPage(),
        ),
        Container(height: 100, color: Colors.blue, width: 200),
      ],
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
        ParagraphNode(id: Editor.createNodeId(), text: AttributedText('')),
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
    return CustomScrollView(
      shrinkWrap: true,
      slivers: [
        SuperEditor(
          key: _editorKey,
          editor: _editor,

          focusNode: _editorFocusNode,
          selectionPolicies: const SuperEditorSelectionPolicies(
            clearSelectionWhenEditorLosesFocus: false,
          ),
          shrinkWrap: true,
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
      ],
    );
  }
}
