import 'package:super_editor/super_editor.dart';

class InsertImageCommandRequest implements EditRequest {
  const InsertImageCommandRequest({required this.url});

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
  const InsertImageCommand({required this.url});

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
