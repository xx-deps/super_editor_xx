
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class FakeViewport extends SingleChildRenderObjectWidget {
  const FakeViewport({super.key, required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderFakeViewport();
  }
}
class _RenderFakeViewport extends RenderBox
    with RenderObjectWithChildMixin<RenderSliver>
    implements RenderAbstractViewport {
  @override
  void debugAssertDoesMeetConstraints() {}

  @override
  RevealedOffset getOffsetToReveal(RenderObject target, double alignment, {Rect? rect, Axis? axis}) {
    return const RevealedOffset(offset: 0, rect: Rect.zero);
  }

  @override
  void setupParentData(RenderObject child) {}

  @override
  Rect get paintBounds => Rect.zero;

  @override
  void performLayout() {
    final childConstraints = SliverConstraints(
      axisDirection: AxisDirection.down,
      growthDirection: GrowthDirection.forward,
      userScrollDirection: ScrollDirection.forward,
      scrollOffset: 0,
      precedingScrollExtent: 0,
      overlap: 0,
      remainingPaintExtent: constraints.maxHeight,
      crossAxisExtent: constraints.maxWidth,
      crossAxisDirection: AxisDirection.right,
      viewportMainAxisExtent: constraints.maxHeight,
      remainingCacheExtent: double.infinity,
      cacheOrigin: 0,
    );
    child!.layout(childConstraints, parentUsesSize: true);
    final geometry = child!.geometry;
    size = Size(constraints.maxWidth, geometry!.scrollExtent);
  }

  RenderBox _getBox(RenderSliver sliver) {
    RenderSliver? firstSliver;
    RenderBox? firstBox;
    sliver.visitChildren((child) {
      if (child is RenderSliver && firstSliver == null) {
        firstSliver = child;
      }
      if (child is RenderBox && firstBox == null) {
        firstBox = child;
      }
    });
    return firstSliver != null ? _getBox(firstSliver!) : firstBox!;
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    final layoutBox = _getBox(child!);
    return layoutBox.computeDryLayout(constraints);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    final layoutBox = _getBox(child!);
    return layoutBox.computeMaxIntrinsicWidth(height);
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    final layoutBox = _getBox(child!);
    return layoutBox.computeMinIntrinsicWidth(height);
  }

  @override
  computeMaxIntrinsicHeight(double width) {
    final layoutBox = _getBox(child!);
    return layoutBox.computeMaxIntrinsicHeight(width);
  }

  @override
  computeMinIntrinsicHeight(double width) {
    final layoutBox = _getBox(child!);
    return layoutBox.computeMinIntrinsicHeight(width);
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {}

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return child!.hitTest(
      SliverHitTestResult.wrap(result),
      mainAxisPosition: position.dy,
      crossAxisPosition: position.dx,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.paintChild(child!, offset);
  }

  @override
  void performResize() {}

  @override
  Rect get semanticBounds => Offset.zero & size;
}
