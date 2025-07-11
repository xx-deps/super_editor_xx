import 'package:example/demos/supertextfield/demo_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:super_editor/super_text_field.dart';

/// Demo of [SuperDesktopTextField] inside Slivers with scrollable content.
class TextFieldInsideSliversDemo extends StatefulWidget {
  const TextFieldInsideSliversDemo({super.key});

  @override
  State<TextFieldInsideSliversDemo> createState() => _TextFieldInsideSliversDemoState();
}

class _TextFieldInsideSliversDemoState extends State<TextFieldInsideSliversDemo> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            // Occupy 80% of the vertical space to avoid pushing text field off-screen
            // and to provide a visual clue on text field's position within demo.
            height: MediaQuery.of(context).size.height * 0.8,
            width: double.infinity,
            child: Placeholder(
              child: Center(
                child: Text("Content"),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SuperDesktopTextField(
              // This demo tests scrolling text field behavior. Force the text field to be tall
              // enough to easily see content scrolling by, but short enough to ensure that
              // the content is scrollable.
              minLines: 5,
              maxLines: 5,
              textStyleBuilder: demoTextStyleBuilder,
              decorationBuilder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: child,
                );
              },
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            child: Placeholder(
              child: Center(
                child: Text("Content"),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
