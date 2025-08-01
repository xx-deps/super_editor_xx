import 'package:attributed_text/attributed_text.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:super_editor/src/core/document.dart';
import 'package:super_editor/src/core/document_composer.dart';
import 'package:super_editor/src/core/document_selection.dart';
import 'package:super_editor/src/core/editor.dart';
import 'package:super_editor/src/default_editor/attributions.dart';
import 'package:super_editor/src/default_editor/horizontal_rule.dart';
import 'package:super_editor/src/default_editor/list_items.dart';
import 'package:super_editor/src/default_editor/paragraph.dart';

import 'package:super_editor/src/default_editor/text.dart';
import 'package:super_editor/src/infrastructure/strings.dart';

import 'multi_node_editing.dart';

/// Converts a [ParagraphNode] from a regular paragraph to a header when the
/// user types "# " (or similar) at the start of the paragraph.
class HeaderConversionReaction extends ParagraphPrefixConversionReaction {
  static Attribution _getHeaderAttributionForLevel(int level) {
    switch (level) {
      case 1:
        return header1Attribution;
      case 2:
        return header2Attribution;
      case 3:
        return header3Attribution;
      case 4:
        return header4Attribution;
      case 5:
        return header5Attribution;
      case 6:
        return header6Attribution;
      default:
        throw Exception(
          "Tried to match a header pattern level ($level) to a header attribution, but there's no attribution for that level.",
        );
    }
  }

  HeaderConversionReaction([
    this.maxLevel = 6,
    this.mapping = _getHeaderAttributionForLevel,
  ]) {
    _headerRegExp = RegExp("^#{1,$maxLevel}\\s+\$");
  }

  /// The highest level of header that this reaction will recognize, e.g., `3` -> "### ".
  final int maxLevel;

  /// The mapping from integer header levels to header [Attribution]s.
  final HeaderAttributionMapping mapping;

  @override
  RegExp get pattern => _headerRegExp;
  late final RegExp _headerRegExp;

  @override
  void onPrefixMatched(
    EditContext editContext,
    RequestDispatcher requestDispatcher,
    List<EditEvent> changeList,
    ParagraphNode paragraph,
    String match,
  ) {
    final prefixLength = match.length - 1; // -1 for the space on the end
    late Attribution headerAttribution = _getHeaderAttributionForLevel(
      prefixLength,
    );

    final paragraphPatternSelection = DocumentSelection(
      base: DocumentPosition(
        nodeId: paragraph.id,
        nodePosition: const TextNodePosition(offset: 0),
      ),
      extent: DocumentPosition(
        nodeId: paragraph.id,
        nodePosition: TextNodePosition(
          offset: paragraph.text.toPlainText().indexOf(" ") + 1,
        ),
      ),
    );

    requestDispatcher.execute([
      // Change the paragraph to a header.
      ChangeParagraphBlockTypeRequest(
        nodeId: paragraph.id,
        blockType: headerAttribution,
      ),
      // Delete the header pattern from the content.
      ChangeSelectionRequest(
        paragraphPatternSelection,
        SelectionChangeType.expandSelection,
        SelectionReason.contentChange,
      ),
      DeleteContentRequest(documentRange: paragraphPatternSelection),
      ChangeSelectionRequest(
        DocumentSelection.collapsed(
          position: DocumentPosition(
            nodeId: paragraph.id,
            nodePosition: const TextNodePosition(offset: 0),
          ),
        ),
        SelectionChangeType.deleteContent,
        SelectionReason.userInteraction,
      ),
    ]);
  }
}

typedef HeaderAttributionMapping = Attribution Function(int level);

/// Converts a [ParagraphNode] to an [UnorderedListItemNode] when the
/// user types "* " (or similar) at the start of the paragraph.
class UnorderedListItemConversionReaction
    extends ParagraphPrefixConversionReaction {
  static final _unorderedListItemPattern = RegExp(r'^\s*[*-]\s+$');

  const UnorderedListItemConversionReaction();

  @override
  RegExp get pattern => _unorderedListItemPattern;

  @override
  void onPrefixMatched(
    EditContext editContext,
    RequestDispatcher requestDispatcher,
    List<EditEvent> changeList,
    ParagraphNode paragraph,
    String match,
  ) {
    // The user started a paragraph with an unordered list item pattern.
    // Convert the paragraph to an unordered list item.
    requestDispatcher.execute([
      ReplaceNodeRequest(
        existingNodeId: paragraph.id,
        newNode: ListItemNode.unordered(
          id: paragraph.id,
          text: AttributedText(),
        ),
      ),
      ChangeSelectionRequest(
        DocumentSelection.collapsed(
          position: DocumentPosition(
            nodeId: paragraph.id,
            nodePosition: const TextNodePosition(offset: 0),
          ),
        ),
        SelectionChangeType.placeCaret,
        SelectionReason.contentChange,
      ),
    ]);
  }
}

/// Converts a [ParagraphNode] to an [OrderedListItemNode] when the
/// user types " 1. " (or similar) at the start of the paragraph.
class OrderedListItemConversionReaction
    extends ParagraphPrefixConversionReaction {
  /// Matches strings like ` 1. `, ` 2. `, ` 1) `, ` 2) `, etc.
  static final _orderedListPattern = RegExp(r'^\s*\d+[.)]\s+$');

  /// Matches one or more numbers.
  static final _numberRegex = RegExp(r'\d+');

  const OrderedListItemConversionReaction();

  @override
  RegExp get pattern => _orderedListPattern;

  @override
  void onPrefixMatched(
    EditContext editContext,
    RequestDispatcher requestDispatcher,
    List<EditEvent> changeList,
    ParagraphNode paragraph,
    String match,
  ) {
    // Extract the number from the match.
    final numberMatch = _numberRegex.firstMatch(match)!;
    final numberTyped = int.parse(
      match.substring(numberMatch.start, numberMatch.end),
    );

    if (numberTyped > 1) {
      // Check if the user typed a number that continues the sequence of an upstream
      // ordered list item. For example, the list has the items 1, 2, 3 and 4,
      // and the user types " 5. ".

      final document = editContext.document;

      final upstreamNode = document.getNodeBefore(paragraph);
      if (upstreamNode == null ||
          upstreamNode is! ListItemNode ||
          upstreamNode.type != ListItemType.ordered) {
        // There isn't an ordered list item immediately before this paragraph. Fizzle.
        return;
      }

      // The node immediately before this paragraph is an ordered list item. Compute its ordinal value,
      // so we can check if the user typed the next number in the sequence.
      int upstreamListItemOrdinalValue = computeListItemOrdinalValue(
        upstreamNode,
        document,
      );
      if (numberTyped != upstreamListItemOrdinalValue + 1) {
        // The user typed a number that doesn't continue the sequence of the upstream ordered list item.
        return;
      }
    }

    // The user started a paragraph with an ordered list item pattern.
    // Convert the paragraph to an unordered list item.
    requestDispatcher.execute([
      ReplaceNodeRequest(
        existingNodeId: paragraph.id,
        newNode: ListItemNode.ordered(id: paragraph.id, text: AttributedText()),
      ),
      ChangeSelectionRequest(
        DocumentSelection.collapsed(
          position: DocumentPosition(
            nodeId: paragraph.id,
            nodePosition: const TextNodePosition(offset: 0),
          ),
        ),
        SelectionChangeType.placeCaret,
        SelectionReason.contentChange,
      ),
    ]);
  }
}

/// Adjusts a [ParagraphNode] to use a blockquote block attribution when a
/// user types " > " (or similar) at the start of the paragraph.
class BlockquoteConversionReaction extends ParagraphPrefixConversionReaction {
  static final _blockquotePattern = RegExp(r'^>\s$');

  const BlockquoteConversionReaction();

  @override
  RegExp get pattern => _blockquotePattern;

  @override
  void onPrefixMatched(
    EditContext editContext,
    RequestDispatcher requestDispatcher,
    List<EditEvent> changeList,
    ParagraphNode paragraph,
    String match,
  ) {
    // The user started a paragraph with blockquote pattern.
    // Convert the paragraph to a blockquote.
    requestDispatcher.execute([
      ReplaceNodeRequest(
        existingNodeId: paragraph.id,
        newNode: ParagraphNode(
          id: paragraph.id,
          text: AttributedText(),
          metadata: {"blockType": blockquoteAttribution},
        ),
      ),
      ChangeSelectionRequest(
        DocumentSelection.collapsed(
          position: DocumentPosition(
            nodeId: paragraph.id,
            nodePosition: const TextNodePosition(offset: 0),
          ),
        ),
        SelectionChangeType.placeCaret,
        SelectionReason.contentChange,
      ),
    ]);
  }
}

/// Converts node content that looks like "--- " or "—- " (an em-dash followed by a regular dash)
/// at the beginning of a paragraph into a horizontal rule.
///
/// The horizontal rule is inserted before the current node and the remainder of
/// the node's text is kept.
///
/// Applied only to all [TextNode]s.
class HorizontalRuleConversionReaction extends EditReaction {
  // Matches "---" or "—-" (an em-dash followed by a regular dash) at the beginning of a line,
  // followed by a space.
  static final _hrPattern = RegExp(r'^(---|—-)\s');

  const HorizontalRuleConversionReaction();

  @override
  void react(
    EditContext editorContext,
    RequestDispatcher requestDispatcher,
    List<EditEvent> changeList,
  ) {
    if (changeList.length < 2) {
      // This reaction requires at least an insertion event and a selection change event.
      // There are less than two events in the the change list, therefore this reaction
      // shouldn't apply. Fizzle.
      return;
    }

    final document = editorContext.document;

    final didTypeSpace = EditInspector.didTypeSpace(document, changeList);
    if (!didTypeSpace) {
      return;
    }

    // final edit = changeList[changeList.length - 2] as DocumentEdit;
    final edit =
        changeList.reversed.firstWhere((edit) => edit is DocumentEdit)
            as DocumentEdit;
    if (edit.change is! TextInsertionEvent) {
      // This reaction requires that the two last events are an insertion event
      // followed by a selection change event.
      // The second to last event isn't a text insertion event, therefore this reaction
      // shouldn't apply. Fizzle.
    }

    final textInsertionEvent = edit.change as TextInsertionEvent;
    final paragraph =
        document.getNodeById(textInsertionEvent.nodeId) as TextNode;
    final match = _hrPattern.firstMatch(paragraph.text.toPlainText())?.group(0);
    if (match == null) {
      return;
    }

    // The user typed a horizontal rule pattern at the beginning of a paragraph.
    // - Remove the dashes and the space.
    // - Insert a horizontal rule before the paragraph.
    // - Place caret at the start of the paragraph.
    requestDispatcher.execute([
      DeleteContentRequest(
        documentRange: DocumentRange(
          start: DocumentPosition(
            nodeId: paragraph.id,
            nodePosition: const TextNodePosition(offset: 0),
          ),
          end: DocumentPosition(
            nodeId: paragraph.id,
            nodePosition: TextNodePosition(offset: match.length),
          ),
        ),
      ),
      InsertNodeAtIndexRequest(
        nodeIndex: document.getNodeIndexById(paragraph.id),
        newNode: HorizontalRuleNode(id: Editor.createNodeId()),
      ),
      ChangeSelectionRequest(
        DocumentSelection.collapsed(
          position: DocumentPosition(
            nodeId: paragraph.id,
            nodePosition: const TextNodePosition(offset: 0),
          ),
        ),
        SelectionChangeType.placeCaret,
        SelectionReason.contentChange,
      ),
    ]);
  }
}

/// Base class for [EditReaction]s that want to take action when the user types text at
/// the beginning of a paragraph, which matches a given [RegExp].
abstract class ParagraphPrefixConversionReaction extends EditReaction {
  const ParagraphPrefixConversionReaction({bool requireSpaceInsertion = true})
    : _requireSpaceInsertion = requireSpaceInsertion;

  /// Whether the [_prefixPattern] requires a trailing space.
  ///
  /// The [_prefixPattern] will always be honored. This hint provides a performance
  /// optimization so that the pattern expression is never evaluated in cases where the
  /// user didn't insert a space into the paragraph.
  final bool _requireSpaceInsertion;

  /// Pattern that is matched at the beginning of a paragraph and then passed to
  /// sub-classes for processing.
  RegExp get pattern;

  @override
  void react(
    EditContext editContext,
    RequestDispatcher requestDispatcher,
    List<EditEvent> changeList,
  ) {
    final document = editContext.document;
    final typedText = EditInspector.findLastTextUserTyped(document, changeList);
    if (typedText == null) {
      return;
    }
    if (_requireSpaceInsertion && !typedText.text.toPlainText().endsWith(" ")) {
      return;
    }

    final paragraph = document.getNodeById(typedText.nodeId);
    if (paragraph is! ParagraphNode) {
      return;
    }

    final match = pattern.firstMatch(paragraph.text.toPlainText())?.group(0);
    if (match == null) {
      return;
    }

    // The user started a paragraph with the desired pattern. Delegate to the subclass
    // to do whatever it wants.
    onPrefixMatched(
      editContext,
      requestDispatcher,
      changeList,
      paragraph,
      match,
    );
  }

  /// Hook, called by the superclass, when the user starts the given [paragraph] with
  /// the given [match], which fits the desired [pattern].
  @protected
  void onPrefixMatched(
    EditContext editContext,
    RequestDispatcher requestDispatcher,
    List<EditEvent> changeList,
    ParagraphNode paragraph,
    String match,
  );
}


/// Configuration for the action that should happen when a text containing
/// a link attribution is modified, e.g., "google.com" becomes "gogle.com".
enum LinkUpdatePolicy {
  /// When a linkified URL has characters added or deleted, the link remains the same.
  preserve,

  /// When a linkified URL has characters added or removed, the link is updated to reflect the new URL value.
  update,

  /// When a linkified URL has characters added or removed, the link is completely removed.
  remove,
}

/// An [EditReaction] which converts two dashes (--) to an em-dash (—).
///
/// This reaction only applies when the user enters a dash (-) after
/// another dash in the same node. The upstream dash and the newly inserted
/// dash are removed and an em-dash (—) is inserted.
///
/// This reaction applies to all [TextNode]s in the document.
class DashConversionReaction extends EditReaction {
  const DashConversionReaction();

  @override
  void react(
    EditContext editorContext,
    RequestDispatcher requestDispatcher,
    List<EditEvent> changeList,
  ) {
    final document = editorContext.document;
    final composer = editorContext.find<MutableDocumentComposer>(
      Editor.composerKey,
    );

    if (changeList.length < 2) {
      // This reaction requires at least an insertion event and a selection change event.
      // There are less than two events in the the change list, therefore this reaction
      // shouldn't apply. Fizzle.
      return;
    }

    TextInsertionEvent? dashInsertionEvent;
    for (final event in changeList) {
      if (event is! DocumentEdit) {
        continue;
      }

      final change = event.change;
      if (change is! TextInsertionEvent) {
        continue;
      }
      if (change.text.toPlainText() != "-") {
        continue;
      }

      dashInsertionEvent = change;
      break;
    }
    if (dashInsertionEvent == null) {
      // The user didn't type a dash.
      return;
    }

    if (dashInsertionEvent.offset == 0) {
      // There's nothing upstream from this dash, therefore it can't
      // be a 2nd dash.
      return;
    }

    final insertionNode =
        document.getNodeById(dashInsertionEvent.nodeId) as TextNode;
    final upstreamCharacter = insertionNode.text
        .toPlainText()[dashInsertionEvent.offset - 1];
    if (upstreamCharacter != '-') {
      return;
    }

    // A dash was inserted after another dash.
    // Convert the two dashes to an em-dash.
    requestDispatcher.execute([
      DeleteContentRequest(
        documentRange: DocumentRange(
          start: DocumentPosition(
            nodeId: insertionNode.id,
            nodePosition: TextNodePosition(
              offset: dashInsertionEvent.offset - 1,
            ),
          ),
          end: DocumentPosition(
            nodeId: insertionNode.id,
            nodePosition: TextNodePosition(
              offset: dashInsertionEvent.offset + 1,
            ),
          ),
        ),
      ),
      InsertTextRequest(
        documentPosition: DocumentPosition(
          nodeId: insertionNode.id,
          nodePosition: TextNodePosition(offset: dashInsertionEvent.offset - 1),
        ),
        textToInsert: SpecialCharacters.emDash,
        attributions: composer.preferences.currentAttributions,
      ),
      ChangeSelectionRequest(
        DocumentSelection.collapsed(
          position: DocumentPosition(
            nodeId: insertionNode.id,
            nodePosition: TextNodePosition(offset: dashInsertionEvent.offset),
          ),
        ),
        SelectionChangeType.placeCaret,
        SelectionReason.contentChange,
      ),
    ]);
  }
}

class EditInspector {
  /// Returns `true` if the given [edits] end with the user typing a space anywhere
  /// within a [TextNode], e.g., typing a " " between two words in a paragraph.
  static bool didTypeSpace(Document document, List<EditEvent> edits) {
    if (edits.length < 2) {
      // This reaction requires at least an insertion event and a selection change event.
      // There are less than two events in the the change list, therefore this reaction
      // shouldn't apply. Fizzle.
      return false;
    }

    // If the user typed a space, then the final document edit should be a text
    // insertion event with a space " ".
    DocumentEdit? lastDocumentEditEvent;
    SelectionChangeEvent? lastSelectionChangeEvent;
    for (int i = edits.length - 1; i >= 0; i -= 1) {
      if (edits[i] is DocumentEdit) {
        lastDocumentEditEvent = edits[i] as DocumentEdit;
      } else if (lastSelectionChangeEvent == null &&
          edits[i] is SelectionChangeEvent) {
        lastSelectionChangeEvent = edits[i] as SelectionChangeEvent;
      }

      if (lastDocumentEditEvent != null) {
        break;
      }
    }
    if (lastDocumentEditEvent == null) {
      return false;
    }
    if (lastSelectionChangeEvent == null) {
      return false;
    }

    final textInsertionEvent = lastDocumentEditEvent.change;
    if (textInsertionEvent is! TextInsertionEvent) {
      return false;
    }
    if (textInsertionEvent.text.toPlainText() != " ") {
      return false;
    }

    if (lastSelectionChangeEvent.newSelection!.extent.nodeId !=
        textInsertionEvent.nodeId) {
      return false;
    }

    final editedNode = document.getNodeById(textInsertionEvent.nodeId)!;
    if (editedNode is! TextNode) {
      return false;
    }

    // The inserted text was a space. We assume this means that the user just typed a space.
    return true;
  }

  /// Finds and returns the last text the user typed within the given [edit]s, or `null` if
  /// no text was typed.
  static UserTypedText? findLastTextUserTyped(
    Document document,
    List<EditEvent> edits,
  ) {
    final lastSpaceInsertion = edits.whereType<DocumentEdit>().lastWhereOrNull(
      (edit) =>
          edit.change is TextInsertionEvent &&
          (edit.change as TextInsertionEvent).text.toPlainText().endsWith(" "),
    );
    if (lastSpaceInsertion == null) {
      // The user didn't insert any text segment that ended with a space.
      return null;
    }

    final spaceInsertionChangeIndex = edits.indexWhere(
      (edit) => edit == lastSpaceInsertion,
    );
    final selectionAfterInsertionIndex = edits.indexWhere(
      (edit) => edit is SelectionChangeEvent,
      spaceInsertionChangeIndex,
    );
    if (selectionAfterInsertionIndex < 0) {
      // The text insertion wasn't followed by a selection change. It's not clear what this
      // means, but we can't say with confidence that the user typed the space. Perhaps the
      // space was injected by some other means.
      return null;
    }

    final newSelection =
        (edits[selectionAfterInsertionIndex] as SelectionChangeEvent)
            .newSelection;
    if (newSelection == null) {
      // There's no selection, which indicates something other than the user typing.
      return null;
    }
    if (!newSelection.isCollapsed) {
      // The selection is expanded, which indicates something other than the user typing.
      return null;
    }

    final textInsertionEvent = lastSpaceInsertion.change as TextInsertionEvent;
    if (textInsertionEvent.nodeId != newSelection.extent.nodeId) {
      // The selection is in a different node than where tex was inserted. This indicates
      // something other than a user typing.
      return null;
    }

    final newCaretOffset =
        (newSelection.extent.nodePosition as TextNodePosition).offset;
    if (textInsertionEvent.offset + textInsertionEvent.text.length !=
        newCaretOffset) {
      return null;
    }

    return UserTypedText(
      textInsertionEvent.nodeId,
      textInsertionEvent.offset,
      textInsertionEvent.text,
    );
  }

  EditInspector._();
}

class UserTypedText {
  const UserTypedText(this.nodeId, this.offset, this.text);

  final String nodeId;
  final int offset;
  final AttributedText text;
}
