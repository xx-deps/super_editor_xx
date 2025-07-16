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
    return CustomerImageComponent(
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


class CustomerImageComponent extends StatelessWidget {
  const CustomerImageComponent({
    Key? key,
    required this.componentKey,
    required this.imageUrl,
    this.expectedSize,
    this.selectionColor = Colors.blue,
    this.selection,
    this.opacity = 1.0,
    this.imageBuilder,
  }) : super(key: key);

  final GlobalKey componentKey;
  final String imageUrl;
  final ExpectedSize? expectedSize;
  final Color selectionColor;
  final UpstreamDownstreamNodeSelection? selection;

  final double opacity;

  /// Called to obtain the inner image for the given [imageUrl].
  ///
  /// This builder is used in tests to 'mock' an [Image], avoiding accessing the network.
  ///
  /// If [imageBuilder] is `null` an [Image] is used.
  final Widget Function(BuildContext context, String imageUrl)? imageBuilder;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      hitTestBehavior: HitTestBehavior.translucent,
      child: IgnorePointer(
        child: Row(
          children: [
            SelectableBox(
            selection: selection,
            selectionColor: selectionColor,
            child: BoxComponent(
              key: componentKey,
              opacity: opacity,
              child: imageBuilder != null
                  ? imageBuilder!(context, imageUrl)
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                        if (frame != null) {
                          // The image is already loaded. Use the image as is.
                          return child;
                        }

                        if (expectedSize != null && expectedSize!.width != null && expectedSize!.height != null) {
                          // Both width and height were provide.
                          // Preserve the aspect ratio of the original image.
                          return AspectRatio(
                            aspectRatio: expectedSize!.aspectRatio,
                            child: SizedBox(
                              width: expectedSize!.width!.toDouble(),
                              height: expectedSize!.height!.toDouble(),
                            ),
                          );
                        }

                        // The image is still loading and only one dimension was provided.
                        // Use the given dimension.
                        return SizedBox(
                          width: expectedSize?.width?.toDouble(),
                          height: expectedSize?.height?.toDouble(),
                        );
                      },
                    ),
            ),
          )
          ],
        ),
      ),
    );
  }
}