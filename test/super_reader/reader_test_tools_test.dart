import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_runners/flutter_test_runners.dart';
import 'package:super_editor/super_reader_test.dart';

import 'reader_test_tools.dart';

void main() {
  group("SuperReader test tools", () {
    group("configures document from markdown", () {
      testWidgetsOnMac("when the document is empty", (tester) async {
        await tester //
            .createDocument() //
            .fromMarkdown("") //
            .forDesktop() //
            .pump();

        expect(
          SuperReaderInspector.findDocument(),
          equalsMarkdown(""),
        );
      });

      testWidgetsOnMac("when the document has a single paragraph", (tester) async {
        await tester //
            .createDocument() //
            .fromMarkdown("Hello, **world!**") //
            .forDesktop() //
            .pump();

        expect(
          SuperReaderInspector.findDocument()!,
          equalsMarkdown("Hello, **world!**"),
        );
      });

      testWidgetsOnMac("when the document has multiple paragraphs", (tester) async {
        await tester //
            .createDocument() //
            .fromMarkdown('''This is **paragraph 1**.

This is *paragraph 2*.

This is [paragraph 3](https://flutter.dev).''') //
            .forDesktop() //
            .pump();

        expect(
          SuperReaderInspector.findDocument()!,
          equalsMarkdown('''This is **paragraph 1**.

This is *paragraph 2*.

This is [paragraph 3](https://flutter.dev).'''),
        );
      });
    });
  });
}
