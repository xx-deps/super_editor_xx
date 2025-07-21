import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:super_editor/super_editor.dart';

class MentionOverlayBuilder implements SuperEditorLayerBuilder {
  final bool showDebugTag;
  const MentionOverlayBuilder({this.showDebugTag = false});

  @override
  ContentLayerWidget build(
    BuildContext context,
    SuperEditorContext editContext,
  ) {
    return MentionOverlay(
      composer: editContext.composer,
      showDebugTag: showDebugTag,
    );
  }
}

class MentionOverlay extends DocumentLayoutLayerStatefulWidget {
  final DocumentComposer composer;
  final bool showDebugTag;
  const MentionOverlay({
    super.key,
    required this.composer,
    required this.showDebugTag,
  });

  @override
  DocumentLayoutLayerState<MentionOverlay, Rect?> createState() =>
      _MentionOverlayState();
}

class _MentionOverlayState
    extends DocumentLayoutLayerState<MentionOverlay, Rect?> {
  Rect? _caretRect;
  @override
  void initState() {
    widget.composer.selectionNotifier.addListener(_onSelectionChange);
    super.initState();
  }

  void _onSelectionChange() {
    if (SchedulerBinding.instance.schedulerPhase !=
        SchedulerPhase.persistentCallbacks) {
      // The Flutter pipeline isn't running. Schedule a re-build and re-position the caret.
      setState(() {
        // The caret is positioned in the build() call.
      });
    }
  }

  @override
  dispose() {
    widget.composer.selectionNotifier.removeListener(_onSelectionChange);
    super.dispose();
  }

  @override
  Rect? computeLayoutDataWithDocumentLayout(
    BuildContext contentLayersContext,
    BuildContext documentContext,
    DocumentLayout documentLayout,
  ) {
    final documentSelection = widget.composer.selection;
    if (documentSelection == null) {
      return null;
    }

    final selectedComponent = documentLayout.getComponentByNodeId(
      widget.composer.selection!.extent.nodeId,
    );
    if (selectedComponent == null) {
      // Assume that we're in a momentary transitive state where the document layout
      // just gained or lost a component. We expect this method ot run again in a moment
      // to correct for this.
      return null;
    }

    final caretRect = documentLayout.getEdgeForPosition(
      documentSelection.extent,
    );

    _caretRect = caretRect;

    if (caretRect == null) {
      return null;
    }

    return _caretRect;
  }

  @override
  Widget doBuild(BuildContext context, Rect? layoutData) {
    if (widget.showDebugTag == false) {
      return SizedBox();
    }
    return Stack(
      children: [
        if (layoutData != null)
          Positioned(
            top: layoutData.top,
            left: layoutData.left,
            child: DecoratedBox(
              decoration: BoxDecoration(color: Colors.yellow),
              child: SizedBox(
                width: 30,
                height: 20,
                child: Text('debug', style: TextStyle(fontSize: 8)),
              ),
            ),
          ),
      ],
    );
  }
}
