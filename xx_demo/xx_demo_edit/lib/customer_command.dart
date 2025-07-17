
import 'package:super_editor/super_editor.dart';

class InsertImageCommandRequest implements EditRequest {
  final ExpectedSize? expectedSize;
  const InsertImageCommandRequest({required this.url, this.expectedSize});

  final String url;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InsertImageCommand &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode;
}

class InsertImageCommand extends EditCommand {
  final ExpectedSize? expectedSize;
  const InsertImageCommand({required this.url, this.expectedSize});

  final String url;

  @override
  HistoryBehavior get historyBehavior => HistoryBehavior.undoable;

  @override
  void execute(EditContext context, CommandExecutor executor) {
    final document = context.document;

    final composer = context.find<MutableDocumentComposer>(Editor.composerKey);

    final endId = composer.selection?.end.nodeId ?? document.last.id;

    if (endId.isEmpty) {
      return;
    }

    final imageNode = ImageNode(
      id: Editor.createNodeId(),
      imageUrl: url,
      altText: 'image',
      expectedBitmapSize: expectedSize,
    );

    if (composer.selection == null) {
      executor.executeCommand(
        InsertNodeAfterNodeCommand(
          existingNodeId: document.last.id,
          newNode: imageNode,
        ),
      );

      return;
    }

    executor.executeCommand(InsertNodeAtCaretCommand(newNode: imageNode));
  }
}
