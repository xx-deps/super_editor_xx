import 'dart:io';
import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';

class CustomerImageComponentBuilder implements ComponentBuilder {
  const CustomerImageComponentBuilder();

  @override
  SingleColumnLayoutComponentViewModel? createViewModel(
    Document document,
    DocumentNode node,
  ) {
    if (node is! ImageNode) {
      return null;
    }

    return ImageComponentViewModel(
      nodeId: node.id,
      createdAt: node.metadata[NodeMetadata.createdAt],
      imageUrl: node.imageUrl,
      expectedSize: node.expectedBitmapSize,
      selectionColor: const Color(0x00000000),
    );
  }

  @override
  Widget? createComponent(
    SingleColumnDocumentComponentContext componentContext,
    SingleColumnLayoutComponentViewModel componentViewModel,
  ) {
    if (componentViewModel is! ImageComponentViewModel) {
      return null;
    }

    final double? width = (componentViewModel.expectedSize?.width)?.toDouble();
    final double? height = (componentViewModel.expectedSize?.height)
        ?.toDouble();
    return ImageComponent(
      componentKey: componentContext.componentKey,
      imageUrl: componentViewModel.imageUrl,
      expectedSize: componentViewModel.expectedSize,
      selection:
          componentViewModel.selection?.nodeSelection
              as UpstreamDownstreamNodeSelection?,
      selectionColor: componentViewModel.selectionColor,
      opacity: componentViewModel.opacity,
      imageBuilder: (context, imageUrl) {
        return imageUrl.startsWith('http')
            ? Image.network(imageUrl, width: width, height: height)
            : Image.file(File(imageUrl), width: width, height: height);
      },
    );
  }
}
