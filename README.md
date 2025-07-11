
## flutter版本
fvm use 3.32.6

## Melos
### 快速使用步骤
1. 安装 Melos
fvm dart pub global activate melos
2. 创建配置文件
在项目根目录创建 melos.yaml，内容示例：
yamlname: my_mono_repo
packages:
  - packages/*
scripts:
  pub-get:
    run: flutter pub get
3. 安装所有子包依赖
fvm dart run melos bootstrap
4. 运行自定义脚本（批量执行 pub get）
fvm dart run melos run pub-get
5. 查看所有管理的包
fvm dart run melos list
6. 在所有子包执行任意命令
fvm dart run melos exec <your-command>

### 常用命令总结
melos bootstrap - 初始化并安装所有依赖
melos list - 列出所有管理的包
melos exec <command> - 在所有包中执行命令
melos run <script> - 运行自定义脚本
melos clean - 清理所有包的构建文件
melos version - 管理包版本和发布

<p align="center">
  <img src="https://user-images.githubusercontent.com/7259036/170845431-e83699df-5c6c-4e9c-90fc-c12277cc2f48.png" width="300" alt="Super Editor"><br>
  <span><b>Open source, configurable, extensible text editor and document renderer for Flutter.</b></span><br><br>
</p>

<p align="center"><b>Super Editor works with any backend. Plug yours in and go!</b></p><br>

<img src="https://raw.githubusercontent.com/superlistapp/super_editor/main/super_editor/doc/marketing/readme-header.png" width="100%" alt="Super Editor">
<br> 

`super_editor` was initiated by [Superlist](https://superlist.com) and is being implemented and maintained by the [Flutter Bounty Hunters](https://flutterbountyhunters.com), Superlist, and the contributors.

## Supported Platforms

Super Editor aims to support all platforms. For now, Super Editor supports the following:

**Supported**

Super Editor is actively developed against these platforms.

 * Mac OS
 * Web
 * Android
 * iOS

**Unverified**

These platforms probably work, but our verification on these platforms is spotty.

 * Windows
 * Linux

## Run the example implementation

Super Editor comes with an example implementation to showcase the core functionality. It also exposes example UI elements on how to interact with the Editor.
The example app should build and run on any platform. You can run the example editor from the example directory:

```bash
cd example
flutter run -d macos
```

The example implementation is only a proof of concept. Expect separate packages to implement various UIs on top of the editor.


## Display an editor

Display a default text editor with the `SuperEditor` widget:

```dart
class _MyAppState extends State<MyApp> {
    void build(context) {
        // Display a visual, editable document.
        //
        // SuperEditor includes default magnifiers and popover toolbars for
        // iOS and Android, but does not include any popovers on desktop.
        // You can add your own, if desired.
        //
        // The standard editor displays and styles headers, paragraphs,
        // ordered and unordered lists, images, and horizontal rules. 
        // Paragraphs know how to display bold, italics, and strikethrough.
        // Key combinations are provided for bold (cmd+b) and italics (cmd+i).
        return SuperEditor.standard(
            editor: _myDocumentEditor,
        );
    }
}
```

A `SuperEditor` widget requires an `Editor`, which is a pure-Dart class that's responsible for 
applying changes to a `Document`. An `Editor`, in turn, requires a reference to the `Document` that 
it will alter. Specifically, a `Editor` requires a `MutableDocument`.

```dart
// A MutableDocument is an in-memory Document. Create the starting
// content that you want your editor to display.
//
// Your MutableDocument does not need to contain any content/nodes.
// In that case, your editor will initially display nothing.
final myDoc = MutableDocument(
  nodes: [
    ParagraphNode(
      id: DocumentEditor.createNodeId(),
      text: AttributedText(text: 'This is a header'),
      metadata: {
        'blockType': header1Attribution,
      },
    ),
    ParagraphNode(
      id: DocumentEditor.createNodeId(),
      text: AttributedText(text:'This is the first paragraph'),
    ),
  ],
);

// A DocumentComposer holds the user's selection. Your editor will likely want
// to observe, and possibly change the user's selection. Therefore, you should
// hold onto your own DocumentComposer and pass it to your Editor.
final myComposer = MutableDocumentComposer();

// With a MutableDocument, create an Editor, which knows how to apply changes 
// to the MutableDocument.
final editor = createDefaultDocumentEditor(document: myDoc, composer: myComposer);

// Next: pass the editor to your SuperEditor widget.
```

The `SuperEditor` widget can be customized.

```dart
class _MyAppState extends State<MyApp> {
    void build(context) {
        return SuperEditor(
            editor: _myDocumentEditor,
            selectionStyle: /** INSERT CUSTOMIZATION **/ null,
            stylesheet: defaultStylesheet.copyWith(
                addRulesAfter: [
                    // Add any custom document styles, for example, you might
                    // apply styles to a custom Task node type.
                    StyleRule(
                        const BlockSelector("task"),
                        (document, node) {
                            if (node is! TaskNode) {
                                return {};
                            }

                            return {
                                Styles.padding: const CascadingPadding.only(top: 24),
                            };
                        },
                    )
                ],
            ),
            componentBuilders: [
              ...defaultComponentBuilders,
              // Add any of your own custom builders for document
              // components, e.g., paragraphs, images, list items.
            ],
        );
    }
}
```

If your app requires deeper customization than `SuperEditor` provides, you can construct your own 
version of the `SuperEditor` widget by using lower level tools within the `super_editor` package.

See the wiki for more information about how to customize an editor experience.
